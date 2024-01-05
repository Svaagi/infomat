import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/Colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';

class PasswordChange extends StatefulWidget {
  final void Function() isPassword;

  const PasswordChange({
    Key? key,
    required this.isPassword,
  }) : super(key: key);

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  TextEditingController _adminEmailController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  String emailError = '';
  String generatedCode = '';
  String generatedPassword = '';

  int _selectedIndex = 0;

   final PageController _pageController = PageController();

  int generateRandomInt({int length = 6}) {
    final Random random = Random();
    final int min = pow(10, length - 1).toInt(); // Cast to int
    final int max = pow(10, length).toInt() - 1; // Cast to int
    return min + random.nextInt(max - min + 1);
  }
  

  Future<void> sendVerificationCode( String recipientEmail,  String verificationCode) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance; // Create an instance of FirebaseFirestore


    await firestore.collection('mail').add(
      {
        'to': [recipientEmail],
        'message': {
          'from': 'Infomat', // Specify sender name here
          'subject': 'Verifikácia',
          'html': 'Dobrý deň, <br>váš overovací kód je <b>$verificationCode</b>.<br><br>Na túto správu neodpovedajte, bola odoslaná automaticky.'
        },
      },
    ).then(
      (value) {
        print('Queued email for delivery!');
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:
    
    PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              Column(
                  children: <Widget>[
                    SizedBox(height: 50),
                    Container(
                        child: SvgPicture.asset(
                          'assets/logoFilled.svg',
                          width:   172,
                        ),
                        padding: EdgeInsets.all(16),
                      ),
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 900),
                          padding: EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10,),
                                Text(
                                  'Email',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor('mono').grey,
                                      ),
                                ),
                                reTextField(
                                  'Email',
                                  false,
                                  _adminEmailController,
                                  AppColors.getColor('mono').lightGrey,
                                  errorText: emailError
                                ),
                                Text(
                                  'Na tento email vám bude zaslaný verifikačný kód',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor('mono').grey,
                                      ),
                                ),
                              ],
                            ),
                        )
                      ),
                      ReButton(
                        color: "green", 
                        text: 'ĎALEJ',
                        onTap: () async {
                          if(_adminEmailController.text != '') emailError = '';
                          if (_adminEmailController.text != '') {
                            _onNavigationItemSelected(_selectedIndex + 1);
                            
                            setState(() {
                              generatedCode = generateRandomInt().toString();
                            });
                            sendVerificationCode( _adminEmailController.text, generatedCode!);
                          } else {
                            setState(() {
                              if(_adminEmailController.text == '') emailError = 'E-mail je poviné pole';
                            });
                          }
                        },
                      ),
                      SizedBox(height: 60),
                    ],
                ),
               Column( 
              children: <Widget>[
                SizedBox(height: 60),
                  Container(
                    width: 900,
                    child: Row(
                      children: [
                        Spacer(),
                          Container(
                        child: SvgPicture.asset(
                          'assets/logoFilled.svg',
                          width:  172,
                        ),
                        padding: EdgeInsets.all(16),
                      ),
                        Spacer(),
                        Container(width: 2.5,)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 900),
                      padding: EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verifikácia emailovej adresy',
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    color: AppColors.getColor('mono').black,
                                  ),
                            ),
                            Text(
                              'Na adresu ${_adminEmailController.text} sme vám zaslali 6-miestny overovací kód. ',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.getColor('mono').grey,
                                  ),
                            ),
                            SizedBox(height: 20,),
                            Text(
                              'Overovací kód',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.getColor('mono').grey,
                                  ),
                            ),
                            SizedBox(height: 10,),
                            reTextField(
                              'Zadajte 6-miestny kód',
                              false,
                              _codeController,
                              AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
                            ),
                          ],
                        ),
                    )
                  ),
                  ReButton(
                    color: "green",
                    text: 'ZMENIŤ HESLO',
                    onTap: () async {
                      if(_codeController.text == generatedCode) {
                        print('hey');
                        setState(() {
                          generatedPassword = generateRandomPassword();
                        });
                        final functions = FirebaseFunctions.instance;

                        await functions.httpsCallable('updatePassword').call({
                          'userEmail': _adminEmailController.text,
                          'newPassword': generatedPassword,
                        });
                        await sendUserPasswordEmail(_adminEmailController.text);
                        reShowToast('Heslo bolo zmenené', false, context);
                        widget.isPassword();
                        
                      };
                    },
                  ),
                  SizedBox(height: 60),
                ],
               )
            ]
    )
    );
  }

  Future<void> sendUserPasswordEmail(String recipientEmail) async {
    final firestore = FirebaseFirestore.instance;

     await firestore.collection('mail').add(
        {
          'to': [recipientEmail],
          'message': {
            'subject': 'Heslo',
            'html': 'Dobrý deň, <br>vaše heslo je <b>$generatedPassword</b>.<br><br>Na túto správu neodpovedajte, bola odoslaná automaticky.'
          },
        },
      ).then(
        (value) {
          print('Queued email for delivery!');
        },
      );
}
  
    void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

