import 'package:flutter/material.dart';

class ProfilePhotoScreen extends StatefulWidget {
  static String id = 'profile_photo_screen';

  const ProfilePhotoScreen({Key key}) : super(key: key);

  @override
  _ProfilePhotoScreenState createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile photo'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 180.0),
          child: Hero(
            tag: 'photo',
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/avatar_default.png'),
                    fit: BoxFit.fill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
