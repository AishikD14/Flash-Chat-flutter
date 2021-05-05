import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsScreen extends StatefulWidget {
  static String id = 'contacts_screen';

  const ContactsScreen({Key key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;

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
            ListView(
              children: [
                Column(
                  children: [],
                )
              ],
            ),
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
