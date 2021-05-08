import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
String email;
String name;
String status;

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  AnimationController controller;
  String nameText = '';
  String statusText = '';

  void getUserData() {
    email = _auth.currentUser.email;
    _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      name = value.docs.first.data()['userName'];
      status = value.docs.first.data()['status'];
      setState(() {
        nameText = name;
        statusText = status;
      });
    }).catchError((error) => print("Failed to get data: $error"));
  }

  @override
  void initState() {
    super.initState();

    getUserData();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
      lowerBound: 0.0,
      upperBound: 24.0,
    );

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    radius: 76.0,
                    backgroundImage: AssetImage('images/avatar_default.png'),
                  ),
                  Material(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    child: IconButton(
                        iconSize: controller.value,
                        icon: Icon(
                          FontAwesomeIcons.camera,
                          color: Colors.white,
                        ),
                        onPressed: () {}),
                  ),
                ],
              ),
              SizedBox(
                height: 25.0,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      FontAwesomeIcons.user,
                      color: Colors.blue[500],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              nameText,
                              style: TextStyle(
                                fontSize: 19.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      FontAwesomeIcons.pencilAlt,
                      color: Colors.blue[500],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      FontAwesomeIcons.infoCircle,
                      color: Colors.blue[500],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      FontAwesomeIcons.pencilAlt,
                      color: Colors.blue[500],
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
