import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RoomCreation {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String email;
  String roomId;
  String users;

  RoomCreation() {
    email = _auth.currentUser.email;
  }

  Future<String> goToRoom(
      String name, String contactName, String contactEmail) async {
    if (contactEmail.toLowerCase().compareTo(email.toLowerCase()) == 1) {
      roomId = email + contactEmail;
      users = name + '|' + contactName;
    } else {
      roomId = contactEmail + email;
      users = contactName + '|' + name;
    }
    roomId = sha256.convert(utf8.encode(roomId)).toString();

    DocumentSnapshot room =
        await _firestore.collection('rooms').doc(roomId).get();
    if (!room.exists) {
      await _firestore.collection('rooms').doc(roomId).set({
        'type': 'personal',
        'users': users,
      });
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(Timestamp.now().toString())
          .set({
        'text': 'This is the start of your chat with ',
        'sender': 'System',
      });
      return roomId;
    } else {
      return roomId;
    }
  }
}
