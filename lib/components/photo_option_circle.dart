import 'package:flutter/material.dart';

class PhotoOptionCircle extends StatelessWidget {
  final String text;
  final IconData photoIcon;
  final Function onPress;

  PhotoOptionCircle({this.text, this.photoIcon, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          child: IconButton(
            icon: Icon(
              photoIcon,
              color: Colors.white,
            ),
            onPressed: onPress,
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
