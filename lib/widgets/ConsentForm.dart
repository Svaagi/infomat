import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/controllers/UserController.dart';

class ConsentForm extends StatefulWidget {
  void Function() confirm;


  ConsentForm({
    required this.confirm,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
        child :Container(
          width: 800,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/gdpr/1.png'),
            Image.asset('assets/gdpr/2.png'),
            Image.asset('assets/gdpr/3.png'),
            Image.asset('assets/gdpr/4.png'),
            Image.asset('assets/gdpr/5.png'),
            Image.asset('assets/gdpr/6.png'),
            
            
            Container(
              width: 600,
              child: Column(children: [
                Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                Text('Súhlasím s pravidlami a podmienkami.',
                  style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(
                  color: Colors.black,
                ),
                ),
                Checkbox(
                  value: _isConfirmed,
                  onChanged:  (bool? value) {
                    setState(() {
                      _isConfirmed = value!;
                    });
                  } ,
                ),
              ],
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

            
            
            SizedBox(height: 20,),
            ReButton(color: 'green',
            text: "SÚHLASIM",
              onTap: () {
                if (_isConfirmed) {
                  User? user = FirebaseAuth.instance.currentUser;
                  setUserSigned(user!.uid);
                  widget.confirm();
                }
              },
            )
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