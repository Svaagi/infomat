import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  String _type = 'Nahlásenie problému';
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
    return Container(
      padding: EdgeInsets.all(8),
      width: 900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Ensure the dialog takes up minimum height
        children: [
          Center(
            child: Text(
              'Kontaktujte nás',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
          const SizedBox(height: 30,),
              Text(
              'Moja správa je:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 10,),
            InkWell(
              onTap: () {
                setState(() {
                  _type = 'Nahlásenie problému';
                });
              },
              child: Container(
                padding: EdgeInsets.only(right: 8),
                height: 30,
                width: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _type == 'Nahlásenie problému' ? AppColors.getColor('primary').lighter : AppColors.getColor('mono').lighterGrey,
                ),
                child: Row(
                  children: [
                    Radio(
                      value: 'Nahlásenie problému',
                      groupValue: _type,
                      onChanged: (newValue) {
                        setState(() {
                          if (newValue != null) _type = newValue;
                        });
                      },
                      activeColor: AppColors.getColor('primary').main,
                    ),
                    Text(
                      'Nahlásenie problému',
                      style: TextStyle(
                        color:  _type == 'Nahlásenie problému' ? AppColors.getColor('primary').main : AppColors.getColor('mono').darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10,),
            InkWell(
              onTap: () {
                setState(() {
                  _type = 'Otázka';
                });
              },
              child:Container(
                padding: EdgeInsets.only(right: 8),
                height: 30,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _type == 'Otázka' ? AppColors.getColor('primary').lighter : AppColors.getColor('mono').lighterGrey,
                ),
                child: Row(
                  children: [
                      Radio(
                      value: 'Otázka',
                        groupValue: _type,
                        onChanged: (newValue) {
                          setState(() {
                            if (newValue != null) _type = newValue;
                          });
                        },
                        activeColor: AppColors.getColor('primary').main,
                      ),
                    Text(
                      'Otázka',
                      style: TextStyle(
                        color: _type == 'Otázka' ? AppColors.getColor('primary').main : AppColors.getColor('mono').darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20,),
            Text(
              'E-mail/Telefónne číslo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(
                hintText: 'Prosím, uveďte kontakt, prostredníctvom ktorého vás môžeme spätne kontaktovať.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Adjust the value for less rounded corners
                  borderSide: BorderSide(color: AppColors.getColor('mono').lightGrey), // Light grey border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.getColor('mono').lightGrey), // Light grey border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.getColor('mono').lightGrey), // Light grey border color
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 10,),
            Text(
              'Správa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            TextField(
              minLines: 5,
              maxLines: 20,
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Popíšte svoj problém s aplikáciou alebo nám napíšte otázku.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Adjust the value for less rounded corners
                  borderSide: BorderSide(color: AppColors.getColor('mono').lightGrey), // Light grey border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.getColor('mono').lightGrey), // Light grey border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.getColor('mono').lightGrey), // Light grey border color
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          SizedBox(height: 30,),
            Center(
              child: ReButton(
              color: "green", 
              text: 'ODOSLAŤ',
              onTap: () {
                if(_messageController.text != '') {
                  sendMessage(_messageController.text, _contactController.text, _type);
                  Navigator.of(context).pop();
                  _messageController.text = '';
                  sendContactEvent();
                }
              },
            ),
          ),
          
          SizedBox(height: 30,),
        ],
      ),
    );
  }
}