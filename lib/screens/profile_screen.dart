import 'package:flutter/material.dart';
import 'profile_photo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Column(
                children: [
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, ProfilePhotoScreen.id);
                        },
                        child: Hero(
                          tag: 'photo',
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      AssetImage('images/avatar_default.png'),
                                  fit: BoxFit.fill),
                            ),
                          ),
                        ),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
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
                        GestureDetector(
                          onTap: () async {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  String modalName;
                                  TextEditingController nameController =
                                      TextEditingController(text: name);
                                  nameController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: nameController.text.length);
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Enter your name',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextField(
                                          controller: nameController,
                                          autofocus: true,
                                          onChanged: (value) {
                                            modalName = value;
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('CANCEL'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _firestore.collection('users')
                                                  ..where('email',
                                                          isEqualTo: email)
                                                      .get()
                                                      .then((value) {
                                                    _firestore
                                                        .collection('users')
                                                        .doc(
                                                            value.docs.first.id)
                                                        .update({
                                                      'userName': modalName,
                                                    }).then((val) {
                                                      setState(() {
                                                        nameText = modalName;
                                                      });
                                                      Navigator.pop(context);
                                                    }).catchError((error) => print(
                                                            "Failed to update data: $error"));
                                                  }).catchError((error) => print(
                                                          "Failed to get data: $error"));
                                              },
                                              child: Text('SUBMIT'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Icon(
                            FontAwesomeIcons.pencilAlt,
                            color: Colors.blue[500],
                          ),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
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
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  String modalStatus;
                                  TextEditingController statusController =
                                      TextEditingController(text: status);
                                  statusController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          statusController.text.length);
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Enter your status',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextField(
                                          controller: statusController,
                                          autofocus: true,
                                          onChanged: (value) {
                                            modalStatus = value;
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('CANCEL'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _firestore.collection('users')
                                                  ..where('email',
                                                          isEqualTo: email)
                                                      .get()
                                                      .then((value) {
                                                    _firestore
                                                        .collection('users')
                                                        .doc(
                                                            value.docs.first.id)
                                                        .update({
                                                      'status': modalStatus,
                                                    }).then((val) {
                                                      setState(() {
                                                        statusText =
                                                            modalStatus;
                                                      });
                                                      Navigator.pop(context);
                                                    }).catchError((error) => print(
                                                            "Failed to update data: $error"));
                                                  }).catchError((error) => print(
                                                          "Failed to get data: $error"));
                                              },
                                              child: Text('SUBMIT'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Icon(
                            FontAwesomeIcons.pencilAlt,
                            color: Colors.blue[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
