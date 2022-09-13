import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class roundedButton extends StatelessWidget {
  roundedButton({required this.title, required this.onPressed});

  final String title;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        //Go to login screen.
        //Navigator.pushNamed(context, LoginScreen.id);
        onPressed;
      },
      minWidth: 200.0,
      height: 42.0,
      child: Text(
        title,
      ),
    );
  }
}
