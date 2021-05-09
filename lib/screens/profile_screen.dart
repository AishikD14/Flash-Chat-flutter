import 'package:flutter/material.dart';
import 'dart:io';
import 'profile_photo.dart';
import 'package:flash_chat/components/photo_option_circle.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final _firestore = FirebaseFirestore.instance;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
String docID;
String email;
String encryptedEmail;
String name;
String status;
bool userDefaultImage;

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  AnimationController controller;
  String nameText = '';
  String statusText = '';
  bool imageUpdated = false;
  bool imageDefault = false;
  File _image;
  final picker = ImagePicker();
  ImageProvider imageWidget = AssetImage('images/avatar_default.png');

  Future uploadImage(ImageSource src) async {
    final pickedFile = await picker.getImage(source: src);

    if (pickedFile != null) {
      try {
        setState(() {
          showSpinner = true;
        });
        await firebase_storage.FirebaseStorage.instance
            .ref('profile/$encryptedEmail.png')
            .putFile(File(pickedFile.path));
        _firestore
            .collection('users')
            .doc(docID)
            .update({'defaultImage': false}).then((val) {
          setState(() {
            imageUpdated = true;
            imageDefault = false;
            _image = File(pickedFile.path);
            showSpinner = false;
          });
          Navigator.pop(context);
        }).catchError((error) {
          print("Failed to update data: $error");
          setState(() {
            showSpinner = false;
          });
        });
      } catch (e) {
        // e.g, e.code == 'canceled'
        print('Failed to upload image');
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  void getUserData() {
    email = _auth.currentUser.email;
    _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      docID = value.docs.first.id;
      name = value.docs.first.data()['userName'];
      status = value.docs.first.data()['status'];
      userDefaultImage = value.docs.first.data()['defaultImage'];
      encryptedEmail = sha256.convert(utf8.encode(email)).toString();
      getImageFromDB();
      setState(() {
        nameText = name;
        statusText = status;
      });
    }).catchError((error) => print("Failed to get data: $error"));
  }

  void updateUserName() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          String modalName;
          TextEditingController nameController =
              TextEditingController(text: name);
          nameController.selection = TextSelection(
              baseOffset: 0, extentOffset: nameController.text.length);
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (modalName == '') {
                          return;
                        }
                        _firestore.collection('users')
                          ..where('email', isEqualTo: email).get().then(
                              (value) {
                            _firestore
                                .collection('users')
                                .doc(value.docs.first.id)
                                .update({
                              'userName': modalName,
                            }).then((val) {
                              setState(() {
                                nameText = modalName;
                              });
                              Navigator.pop(context);
                            }).catchError((error) =>
                                    print("Failed to update data: $error"));
                          }).catchError(
                              (error) => print("Failed to get data: $error"));
                      },
                      child: Text('SUBMIT'),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void updateStatus() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          String modalStatus;
          TextEditingController statusController =
              TextEditingController(text: status);
          statusController.selection = TextSelection(
              baseOffset: 0, extentOffset: statusController.text.length);
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (modalStatus == '') {
                          return;
                        }
                        _firestore.collection('users')
                          ..where('email', isEqualTo: email).get().then(
                              (value) {
                            _firestore
                                .collection('users')
                                .doc(value.docs.first.id)
                                .update({
                              'status': modalStatus,
                            }).then((val) {
                              setState(() {
                                statusText = modalStatus;
                              });
                              Navigator.pop(context);
                            }).catchError((error) =>
                                    print("Failed to update data: $error"));
                          }).catchError(
                              (error) => print("Failed to get data: $error"));
                      },
                      child: Text('SUBMIT'),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void resetDefaultPhoto() {
    setState(() {
      showSpinner = true;
    });
    _firestore
        .collection('users')
        .doc(docID)
        .update({'defaultImage': true}).then((val) {
      setState(() {
        imageUpdated = true;
        imageDefault = true;
        showSpinner = false;
      });
      Navigator.pop(context);
    }).catchError((error) => print("Failed to update data: $error"));
  }

  void getImageFromDB() async {
    if (userDefaultImage == false) {
      try {
        String downloadUrl = await firebase_storage.FirebaseStorage.instance
            .ref('profile/$encryptedEmail.png')
            .getDownloadURL();
        setState(() {
          imageWidget = Image.network(downloadUrl).image;
        });
      } catch (e) {
        // e.g, e.code == 'canceled'
        print('Failed to get image');
        print(e);
      }
    }
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if ((imageUpdated == false &&
                                    userDefaultImage == true) ||
                                imageDefault == true) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePhotoScreen(
                                      isDefault: true,
                                    ),
                                  ));
                            } else if (imageUpdated == false &&
                                userDefaultImage == false) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePhotoScreen(
                                      isDefault: false,
                                      image: imageWidget,
                                    ),
                                  ));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePhotoScreen(
                                      isDefault: false,
                                      image: Image.file(_image).image,
                                    ),
                                  ));
                            }
                          },
                          child: Hero(
                            tag: 'photo',
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageUpdated == false
                                        ? imageWidget
                                        : imageDefault == false
                                            ? Image.file(_image).image
                                            : AssetImage(
                                                'images/avatar_default.png'),
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
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Profile Photo',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  PhotoOptionCircle(
                                                    text: 'Remove \n photo',
                                                    photoIcon:
                                                        FontAwesomeIcons.trash,
                                                    onPress: () {
                                                      resetDefaultPhoto();
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  PhotoOptionCircle(
                                                    text: 'Gallery',
                                                    photoIcon: FontAwesomeIcons
                                                        .photoVideo,
                                                    onPress: () {
                                                      uploadImage(
                                                          ImageSource.gallery);
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  PhotoOptionCircle(
                                                    text: 'Camera',
                                                    photoIcon:
                                                        FontAwesomeIcons.camera,
                                                    onPress: () {
                                                      uploadImage(
                                                          ImageSource.camera);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              }),
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
                            onTap: () {
                              updateUserName();
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
                              updateStatus();
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
      ),
    );
  }
}
