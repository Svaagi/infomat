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
    final url = '/GDPR.pdf'; // Replace with your PDF's URL
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

            SizedBox(height: 60,),
                Text(
              textAlign: TextAlign.center,
              'V súlade s GDPR (Všeobecným nariadením o ochrane údajov) by sme vás taktiež radi informovali, že naša aplikácia používa cookies. Sú tu dva typy cookies, ktoré zhromažďujeme:',
              style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(
                  color: Colors.black,
                ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                Text('Povinné Cookies:',
                    style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(
                  color: Colors.black,
                ),
                  ),
                Checkbox(
                  value: true,
                  onChanged:  (bool? value) {
                    
                  } ,
                ),
              ]
              ),
              Padding(padding: EdgeInsets.only(left: 20),
                child:  Text('"Povinné Cookies: Tieto cookies sú nevyhnutné pre základnú funkcionalitu a bezpečnosť aplikácie. Sú nevyhnutné pre správne fungovanie aplikácie a nevyžadujú váš súhlas, pretože sú v súlade s výnimkami povolenými podľa GDPR."')
              ),

            SizedBox(height: 20,),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                Text('Analytické Cookies:',
                    style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(
                  color: Colors.black,
                ),
                  ),
                Checkbox(
                  value: _isAnalytics,
                  onChanged:  (bool? value) {
                    setState(() {
                      _isAnalytics = value!;
                    });
                  } ,
                ),
              ]
              ),

            Padding(padding: EdgeInsets.only(left: 20),
              child:Text(' Tieto cookies používame na zhromažďovanie informácií o tom, ako interagujete s našou aplikáciou. Pomáhajú nám pochopiť, ako užívatelia používajú aplikáciu, čo nám umožňuje zlepšovať jej obsah a funkcie. Tieto údaje sú anonymizované a slúžia iba na štatistické účely. Váš súhlas s týmito cookies je dobrovoľný.'),
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