import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'package:flash_chat/components/room-creation.dart';
import 'package:flash_chat/components/default_image_circle.dart';
import 'package:flash_chat/components/picture_overlay.dart';
import 'package:flash_chat/components/notification_plugin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

final _firestore = FirebaseFirestore.instance;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
String email;
String name;

class ContactsScreen extends StatefulWidget {
  static String id = 'contacts_screen';

  const ContactsScreen({Key key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;
  ImageProvider pictureWidget = AssetImage('images/avatar_default.png');
  NotificationPlugin notificationPlugin = NotificationPlugin();

  Future<void> saveTokenToDatabase(String token) async {
    await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((response) {
      _firestore
          .collection('users')
          .doc(response.docs.first.id)
          .update({
            'tokens': FieldValue.arrayUnion([token]),
          })
          .then((val) => print('Token data updated'))
          .catchError((error) => print("Failed to update token data: $error"));
    });
  }

  void updateLogin() async {
    email = _auth.currentUser.email;
    String token = await FirebaseMessaging.instance.getToken();

    await saveTokenToDatabase(token);

    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

    _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((response) {
      name = response.docs.first.data()['userName'];
      _firestore
          .collection('users')
          .doc(response.docs.first.id)
          .update({'lastLoggedIn': Timestamp.now()})
          .then((val) => print('Login data updated'))
          .catchError((error) => print("Failed to update data: $error"));
    }).catchError((error) => print("Failed to get data: $error"));
  }

  void setupNotification() async {
    notificationPlugin.setOnNotificationClick(onNotificationClick);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        print('Got a message whilst in the foreground!');
        print(
            'Message also contained a notification: ${message.notification.body}');

        await notificationPlugin.showNotification(notification);
      }
    });
  }

  void onNotificationClick(String payload) {
    print('Payload is $payload');
  }

  @override
  void initState() {
    super.initState();
    updateLogin();
    setupNotification();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'Profile') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                } else {
                  _auth.signOut();
                  Navigator.popAndPushNamed(context, WelcomeScreen.id);
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry>[
                  PopupMenuItem<String>(
                    value: 'Profile',
                    child: Text('Profile'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Logout',
                    child: Text('Logout'),
                  ),
                ];
              },
              tooltip: 'Options',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Chats',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Groups',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Calls',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          title: Text('⚡️ Flash Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: TabBarView(
          children: [
            ContactsStream(),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.lightBlueAccent,
          tooltip: 'New chat',
          onPressed: () {},
        ),
      ),
    );
  }
}

class ContactsStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final contacts = snapshot.data.docs;
        List<ContactBubble> contactBubbles = [];
        for (var contact in contacts) {
          if (contact.data()['email'] == email) {
            continue;
          }
          final contactName = contact.data()['userName'];
          final contactEmail = contact.data()['email'];
          final contactDefaultImage = contact.data()['defaultImage'];
          if (contactDefaultImage == true) {
            final contactBubble = ContactBubble(
              contactName: contactName,
              contactEmail: contactEmail,
              isDefaultImage: true,
            );
            contactBubbles.add(contactBubble);
          } else {
            final encryptedEmail =
                sha256.convert(utf8.encode(contactEmail)).toString();
            final contactBubble = ContactBubble(
              contactName: contactName,
              contactEmail: contactEmail,
              encryptedEmail: encryptedEmail,
              isDefaultImage: false,
            );
            contactBubbles.add(contactBubble);
          }
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          children: contactBubbles,
        );
      },
    );
  }
}

class ContactBubble extends StatefulWidget {
  final String contactName;
  final String contactEmail;
  final String encryptedEmail;
  final bool isDefaultImage;
  final RoomCreation room = RoomCreation();

  ContactBubble(
      {this.contactName,
      this.contactEmail,
      this.encryptedEmail,
      this.isDefaultImage});

  @override
  _ContactBubbleState createState() => _ContactBubbleState();
}

class _ContactBubbleState extends State<ContactBubble> {
  ImageProvider profileImage = AssetImage('images/avatar_default.png');

  void getProfileImage() async {
    try {
      final downloadUrl = await storage
          .ref('profile/${widget.encryptedEmail}.png')
          .getDownloadURL();
      setState(() {
        profileImage = Image.network(downloadUrl).image;
      });
    } catch (e) {
      print("Image error is $e");
    }
  }

  void openChat() async {
    String roomId = await widget.room
        .goToRoom(name, widget.contactName, widget.contactEmail);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatName: widget.contactName,
          roomId: roomId,
          chatEmail: widget.contactEmail,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isDefaultImage) {
      getProfileImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              String dialogClosed = await showDialog(
                context: context,
                builder: (_) {
                  return PictureOverlay(
                    profileImage: profileImage,
                    contactName: widget.contactName,
                  );
                },
              );
              if (dialogClosed == "goToChat") {
                openChat();
              }
            },
            child: widget.isDefaultImage
                ? DefaultImageCircle()
                : Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: profileImage, fit: BoxFit.cover),
                    ),
                  ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                openChat();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        widget.contactName,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    LastMessage(
                      contactEmail: widget.contactEmail,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              LastMessageTime(
                contactEmail: widget.contactEmail,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LastMessage extends StatelessWidget {
  final String contactEmail;

  LastMessage({this.contactEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('rooms')
          .doc(GetRoomId().getRoomId(contactEmail))
          .snapshots(),
      builder: (context, snapshot) {
        String lastMessage;
        try {
          lastMessage = snapshot.data['lastMessage'];
        } catch (e) {
          return Text(
            'No previous message',
            style: TextStyle(
              color: Colors.grey,
            ),
          );
        }
        return Text(
          lastMessage,
          maxLines: 1,
          style: TextStyle(
            color: Colors.grey,
          ),
        );
      },
    );
  }
}

class LastMessageTime extends StatelessWidget {
  final String contactEmail;

  LastMessageTime({this.contactEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('rooms')
          .doc(GetRoomId().getRoomId(contactEmail))
          .snapshots(),
      builder: (context, snapshot) {
        Timestamp lastMessageTime;
        try {
          lastMessageTime = snapshot.data['lastMessageTime'];
        } catch (e) {
          return Text(
            '',
            style: TextStyle(
              color: Colors.grey,
            ),
          );
        }
        return Text(
          DateFormat('h:mm a').format(lastMessageTime.toDate()),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13.0,
          ),
        );
      },
    );
  }
}
