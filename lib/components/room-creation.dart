import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class RoomCreation {
  String email;
  String roomId;
  String users;

  RoomCreation() {
    email = _auth.currentUser.email;
  }

  Future<String> goToRoom(
      String name, String contactName, String contactEmail) async {
    roomId = GetRoomId().getRoomId(contactEmail);
    users = GetRoomId().getUsersInRoom(name, contactName, contactEmail);

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

class GetRoomId {
  String email;
  String roomId;
  String users;

  GetRoomId() {
    email = _auth.currentUser.email;
  }

  String getRoomId(contactEmail) {
    if (contactEmail.toLowerCase().compareTo(email.toLowerCase()) == 1) {
      roomId = email + contactEmail;
    } else {
      roomId = contactEmail + email;
    }
    roomId = sha256.convert(utf8.encode(roomId)).toString();
    return roomId;
  }

  String getUsersInRoom(name, contactName, contactEmail) {
    if (contactEmail.toLowerCase().compareTo(email.toLowerCase()) == 1) {
      users = name + '|' + contactName;
    } else {
      users = contactName + '|' + name;
    }
    return users;
  }
}
