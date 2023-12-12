import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/widgets/ContactButton.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final String _type = 'Nahlásenie problému';
  final TextEditingController _messageController = TextEditingController();

  Future<void> sendMessage(String message, String type) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance; // Create an instance of FirebaseFirestore

    await firestore.collection('mail').add(
      {
        'to': ['support@info-mat.sk'],
        'message': {
          'subject': type,
          'text': message
        },
      },
    ).then(
      (value) {
        print('Queued email for delivery!');
      },
    );
    
    reShowToast( 'Správa odoslaná', false, context);
  }

  @override
  Widget build(BuildContext context) {
    return ContactButton(type: _type, messageController: _messageController, sendMessage: sendMessage,);
  }
}