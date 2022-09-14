import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
late User loggedinUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  late String messageText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser!;
      if (user != null) {
        loggedinUser = user;
        print(loggedinUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data()['text']);
  //   }
  // }
  //
  // void getStreamMessages() async {
  //   await for (var snap in _firestore.collection('messages').snapshots()) {
  //     for (var message in snap.docs) {
  //       print(message.data()['text']);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    //getStreamMessages();
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data?.docs.reversed;
                    List<Widget> messageWidgets = [];
                    for (var message in messages!) {
                      final messageText = message["text"];
                      final messageSender = message["sender"];
                      final currentUser = loggedinUser.email;

                      final messageWidget = textBubble(
                        messageText: messageText,
                        messageSender: messageSender,
                        isMe: currentUser == messageSender,
                      );
                      messageWidgets.add(messageWidget);
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        children: messageWidgets,
                      ),
                    );
                  }
                  return Text('No messages');
                },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        onChanged: (value) {
                          //Do something with the user input.
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageController.clear();
                        //Implement send functionality.
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedinUser.email,
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class textBubble extends StatelessWidget {
  textBubble(
      {required this.messageText,
      required this.messageSender,
      required this.isMe});

  final String messageText;
  final String messageSender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          messageSender,
          style: TextStyle(color: Colors.black, fontSize: 10.0),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            color: isMe ? Colors.blue : Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "$messageText",
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
