import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_bubble.dart';

class MessageStream extends StatelessWidget {
  const MessageStream({
    required FirebaseFirestore db,
    this.currentUser,
  }) : _db = db;

  final FirebaseFirestore _db;
  final currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          Map<String, dynamic> data = message.data()! as Map<String, dynamic>;
          final messageText = data['text'];
          final messageSender = data['sender'];
          final currentUserEmail = currentUser.email;
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUserEmail == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            children: messageBubbles,
          ),
        );
      },
      stream: _db.collection('messages').snapshots(),
    );
  }
}
