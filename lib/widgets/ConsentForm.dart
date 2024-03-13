import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/controllers/UserController.dart';
import 'dart:html' as html;
import 'package:infomat/Colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;




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

  void downloadPDF() async {
    try {
    // Fetch the download URL
    String downloadUrl = await firebase_storage.FirebaseStorage.instance
        .ref('Infomat.pdf')
        .getDownloadURL();

    // Open the URL in a new tab
    html.window.open(downloadUrl, '_blank');
  } catch (e) {
    print("Error fetching PDF URL: $e");
  }
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
                  Text(
                    'Podmienky využívania aplikácie Infomat',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: AppColors.getColor('mono').black,
                        ),
                  ),
                  SizedBox(height: 100,),
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
            MediaQuery.of(context).size.width > 1000
                ? SizedBox(
              width: 400,
              child: ReButton(color: 'green',
                  text: "Súhlasím s podmienkami používania aplikácie",
                    onTap: () {
                        User? user = FirebaseAuth.instance.currentUser;
                        setUserSigned(user!.uid);
                        widget.confirm();
                    },
                  ),
            ) : SizedBox(
              width: 400,
              child: ReButton(color: 'green',
                  text: "Súhlasím s podmienkami používania",
                    onTap: () {
                        User? user = FirebaseAuth.instance.currentUser;
                        setUserSigned(user!.uid);
                        widget.confirm();
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