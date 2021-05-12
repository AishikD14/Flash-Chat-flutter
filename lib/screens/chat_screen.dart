import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:flash_chat/services/notification.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;
String email;
String room;
String contactName;
String contactEmail;
String userName;
bool group;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  final String chatName;
  final String chatEmail;
  final String roomId;

  ChatScreen({this.chatName, this.roomId, this.chatEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String messageText;

  void getCurrentUser() {
    email = _auth.currentUser.email;
    _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((val) {
      userName = val.docs.first.data()['userName'];
    }).catchError((error) => print("Failed to get data: $error"));
  }

  void checkIfGroup() {
    _firestore.collection('rooms').doc(room).get().then((val) {
      group = val.data()['type'] == 'personal' ? false : true;
    }).catchError((error) => print("Failed to get data: $error"));
  }

  void sendMessage() {
    messageTextController.clear();
    //Implement send functionality.
    _firestore
        .collection('rooms')
        .doc(room)
        .collection('messages')
        .doc(Timestamp.now().toString())
        .set({
      'text': messageText,
      'sender': email,
      'time': Timestamp.now(),
    });
    _firestore.collection('rooms').doc(room).update({
      'lastMessage': messageText,
      'lastMessageTime': Timestamp.now(),
    });

    ChatNotification notification = ChatNotification();
    notification.sendNotification(userName, contactEmail, messageText);
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  // }

  // void messageStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    room = widget.roomId;
    checkIfGroup();
    contactName = widget.chatName;
    contactEmail = widget.chatEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                // Navigator.pop(context);
                Navigator.popAndPushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text(widget.chatName),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      sendMessage();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('rooms')
          .doc(room)
          .collection('messages')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<Widget> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data()['text'];
          final messageSender = message.data()['sender'];
          final messageTime = message.data()['time'];
          final currentUser = email;
          if (messageSender == 'System') {
            final messageBubble = SystemMessageBubble(
              text: messageText,
            );
            messageBubbles.add(messageBubble);
          } else {
            final messageBubble = MessageBubble(
              sender: currentUser == messageSender ? userName : contactName,
              text: messageText,
              time: messageTime,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
          }
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final Timestamp time;
  final bool isMe;

  MessageBubble({this.sender, this.text, this.time, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          isMe
              ? Container()
              : group
                  ? Text(
                      sender,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                    )
                  : Container(),
          Material(
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
          Padding(
            padding: isMe
                ? EdgeInsets.only(right: 8.0, top: 8.0)
                : EdgeInsets.only(left: 8.0, top: 8.0),
            child: Text(
              // time.toDate().toLocal().hour.toString() +
              //     ':' +
              //     time.toDate().toLocal().minute.toString(),
              DateFormat('h:mm a').format(time.toDate()),
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SystemMessageBubble extends StatelessWidget {
  final String text;

  SystemMessageBubble({this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            color: Colors.blueGrey,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text + contactName,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
