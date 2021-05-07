import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:flash_chat/components/room-creation.dart';

final _firestore = FirebaseFirestore.instance;
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

  void updateLogin() {
    email = _auth.currentUser.email;
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

  @override
  void initState() {
    super.initState();
    updateLogin();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  //Implement logout functionality
                  _auth.signOut();
                  // // Navigator.pop(context);
                  Navigator.popAndPushNamed(context, WelcomeScreen.id);
                }),
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
          final contactBubble = ContactBubble(
            contactName: contactName,
            contactEmail: contactEmail,
          );
          contactBubbles.add(contactBubble);
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          children: contactBubbles,
        );
      },
    );
  }
}

class ContactBubble extends StatelessWidget {
  final String contactName;
  final String contactEmail;
  final RoomCreation room = RoomCreation();

  ContactBubble({this.contactName, this.contactEmail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.0,
            backgroundImage: AssetImage('images/avatar_default.png'),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                String roomId =
                    await room.goToRoom(name, contactName, contactEmail);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatName: contactName,
                      roomId: roomId,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        contactName,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text('Last message'),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text('Yesterday'),
            ],
          ),
        ],
      ),
    );
  }
}
