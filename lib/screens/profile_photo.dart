import 'package:flutter/material.dart';

class ProfilePhotoScreen extends StatefulWidget {
  static String id = 'profile_photo_screen';
  final bool isDefault;
  final ImageProvider image;

  ProfilePhotoScreen({this.isDefault, this.image});

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
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 180.0),
                child: Hero(
                  tag: 'photo',
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: widget.isDefault == true
                              ? AssetImage('images/avatar_default.png')
                              : widget.image,
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 240.0),
                child: Hero(
                  tag: 'photo',
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: widget.isDefault == true
                              ? AssetImage('images/avatar_default.png')
                              : widget.image,
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
