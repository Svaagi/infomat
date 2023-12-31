import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/widgets/ContactButton.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final String _type = 'Nahlásenie problému';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> sendContactEvent() async {
    await analytics.logEvent(
      name: 'kontatk',
      parameters: {
        'event': 'kontatk', // replace with your actual page/screen name
      },
    );
  }


  Future<void> sendMessage(String message, String contact, String type) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance; // Create an instance of FirebaseFirestore

    await firestore.collection('mail').add(
      {
        'to': ['support@info-mat.sk'],
        'message': {
          'subject': type,
          'text': 'Správa: $message\n Kontakt: $contact'
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
    return ContactButton(type: _type, messageController: _messageController, contactController: _contactController, sendMessage: sendMessage, sendContact: sendContactEvent(),);
  }
}