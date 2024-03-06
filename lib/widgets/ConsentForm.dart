import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/controllers/UserController.dart';
import 'dart:html' as html;
import 'package:infomat/Colors.dart';
import 'package:flutter/gestures.dart';



class ConsentForm extends StatefulWidget {
  void Function() confirm;
  final void Function() logOut;


  ConsentForm({
    required this.confirm,
    required this.logOut
  });

  @override
  _ConsentFormState createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToEnd = false;
  bool _isConfirmed = false;
  bool _isAnalytics = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          _isScrolledToEnd = true;
        });
      }
    });
  }

  void downloadPDF() {
    final url = 'assets/gdpr.pdf'; // Replace with your PDF's URL
    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'Infomat.pdf') // Optional: Set the download file name
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
        child :Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: MediaQuery.of(context).size.width > 1000 ? AppColors.getColor('primary').main.withOpacity(0.8) : Colors.white,

        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              width: 800,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                        ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Pre pokračovanie a používanie aplikácie Infomat je potrebné vyjadriť váš súhlas s ',
                      ),
                      TextSpan(
                        text: 'podmienkami používania aplikácie.',
                        style: TextStyle(
                          color: Colors.blue, // Change the color to indicate it's clickable
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () => downloadPDF(),
                      ),
                    ],
                  ),
                ),
            SizedBox(height: 30,),
            SizedBox(
              width: 350,
              child: ReButton(color: 'green',
                  text: "Súhlasím s pravidlami a podmienkami.",
                    onTap: () {
                      if (_isConfirmed) {
                        User? user = FirebaseAuth.instance.currentUser;
                        setUserSigned(user!.uid);
                        widget.confirm();
                      }
                    },
                  ),
            ),
            SizedBox(height: 10,),

            ReButton(
              color: "white",
              delete: true,
              text: 'Nesúhlasím',
              onTap: () {
                widget.logOut();
              },
            ),
              ],),
            )
            
          ],
        ),
      ),
        )
      )
      
      
    );
    
  }
}