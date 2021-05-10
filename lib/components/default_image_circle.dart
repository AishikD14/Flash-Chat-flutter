import 'package:flutter/material.dart';

class DefaultImageCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: AssetImage('images/avatar_default.png'), fit: BoxFit.fill),
      ),
    );
  }
}
