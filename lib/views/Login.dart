import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/auth/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/SchoolForm.dart';
import 'package:infomat/widgets/PasswordChange.dart';
import 'package:flutter/gestures.dart'; // Import this line
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:js' as js;



class Login extends StatefulWidget {
  
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  Color _emailBorderColor = Colors.white;
  Color _passwordBorderColor = Colors.white;
  String? _errorMessage;
  bool _isEnterScreen = true;
  bool _isVisible = true;
  bool isMobile = false;
  bool isDesktop = false;
  bool isSchool = false;
  bool isPassword = false;
  final TextEditingController _passwordTextController = TextEditingController();
  String createdViewId = 'map_element';
  bool disable = false;

            

  final userAgent = html.window.navigator.userAgent.toLowerCase();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    isMobile = userAgent.contains('mobile');
    isDesktop = userAgent.contains('macintosh') ||
        userAgent.contains('windows') ||
        userAgent.contains('linux');

    ui.platformViewRegistry.registerViewFactory(
      createdViewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..style.height = '100%'
          ..style.width = '100%'
          ..src = '/recaptcha.html'
          ..style.border = 'none';

        // Set the webViewController when the iframe is created
        return iframe;
      },
    );

    js.context['FlutterApp'] = js.JsObject.jsify({
    'receiveToken': (String token) {
      verifyRecaptchaToken(token);
    },
  });

  }

  void verifyRecaptchaToken(String token) async {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('verifyRecaptcha');
    try {
      final response = await callable.call({'token': token});
      if (response.data['success']) {
        // reCAPTCHA verification succeeded
        // Proceed with login or other actions
        setState(() {
          disable =false;
          _showCaptcha = false;
        });
      } else {
        // reCAPTCHA verification failed
        // Handle the failure
        print('Robot');
      }
    } catch (e) {
      // Handle errors
      print('Error verifying reCAPTCHA: $e');
    }
  }

  Future<bool> verifyToken(String token) async {
  Uri uri = Uri.parse('https://www.google.com/recaptcha/api/siteverify');
  final response = await http.post(
    uri,
    body: {
      'secret': '6LeEcF8pAAAAAFuWQalaZZfyeCSnniPo_j_IN2sL',
      'response': token,
    },
  );
  final Map<String, dynamic> jsonResponse = json.decode(response.body);
  if (jsonResponse['success']) {
    return true;
  } else {
    return false;
  }
}


  int _loginAttempts = 0;
  bool _showCaptcha = false;

  toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  handleLogin() async {
    final email = _emailTextController.value.text;
    final password = _passwordTextController.value.text;


    // Perform validation
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _emailBorderColor = Colors.white;
        _passwordBorderColor = Colors.white;
      });

      try {
        // Call your login function here
        // Replace the 'signIn' method with your actual authentication logic
        await Auth().signIn(email, password);
      } catch (error) {
        setState(() {
          _errorMessage = 'Nesprávne prihlasovacie meno alebo heslo';
          _emailBorderColor = Theme.of(context).colorScheme.error;
          _passwordBorderColor = Theme.of(context).colorScheme.error;
        });

        // Check if the login attempts exceed 10
        _loginAttempts++;
        if (_loginAttempts >= 10) {
          // Show the CAPTCHA
          setState(() {
            _showCaptcha = true;
            disable = true;
          });

        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEnterScreen) {
      return Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SvgPicture.asset('assets/logo.svg', width: 500),
                  ),
                ],
              ),
            ),
            Center(
              child: ReButton(
                color: "white", 
                text: 'PRIHLÁSENIE',
                bold: true,
                onTap: () {
                  setState(() {
                    _isEnterScreen = false;
                  });
                },
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      );
    }
    if (isSchool){ 
      return SchoolForm(isSchool: () {setState(() {
      isSchool = false;
    }); });
    }
    if (isPassword){ 
      return PasswordChange(isPassword: () {setState(() {
      isPassword = false;
    }); });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height <= 700
          ? 700
          : MediaQuery.of(context).size.height >= 900
              ? 900
              : MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 60),
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width:  isMobile ? 132 : 172,
                ),
                padding: const EdgeInsets.all(16),
              ),
              Expanded(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Prihlásenie',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 100, bottom: 4, right: 4, left: 4),
                              child:reTextField(
                              "Email",
                              false,
                              _emailTextController,
                              _emailBorderColor,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(4),
                            child:  reTextField(
                              "Heslo",
                              true,
                              _passwordTextController,
                              _passwordBorderColor,
                              visibility: _isVisible,
                              toggle: toggleVisibility
                            ),
                          ),
                          _errorMessage != null
                            ? Container(
                                margin: const EdgeInsets.only(top: 22),
                                width: 300,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.getColor('red').lighter,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 20,),
                                       SvgPicture.asset('assets/icons/smallErrorIcon.svg', color: Theme.of(context).colorScheme.error, height: 16,),
                                      Flexible( // Use Flexible to allow text wrapping
                                        child: Container(
                                          margin: const EdgeInsets.all(12),
                                          child: Text(
                                          _errorMessage!,
                                          style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                          )
                                        ),
                                      ),
                                        const SizedBox(width: 8,)
                                    ],
                                  ),
                                ),
                              )
                            : Container(),

                          /*if (_showCaptcha)
                            RecaptchaV3(
                              controller: recaptchaV3Controller,
                              onVerified: (response) {
                                // CAPTCHA verified successfully
                                // You can access response.token here
                                handleLogin();
                              },
                              onError: (e) {
                                // Handle CAPTCHA verification error
                                // For example: _showSnackBar('CAPTCHA verification failed');
                              },
                            ),*/
                          Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: Text(
                              'Ak prihlasovacie údaje nemáš, vypýtaj ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                            ),
                          ),
                          Text(
                            'si ich od svojho vyučujúceho.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'pridať školu',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              // You can also add onTap to make it clickable
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle the tap event here, e.g., open a URL
                                  // You can use packages like url_launcher to launch URLs.
                                  setState(() {
                                    isSchool = true;
                                  });
                                },
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if(_showCaptcha)
              Center(
                child:  SizedBox(
              // Use a Webview widget to embed the reCAPTCHA widget
              child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: HtmlElementView(
                  viewType: createdViewId,
                  ),
              ),
              width: 320, // Adjust the width as needed
              height: 110, // Adjust the height as needed
            ),
              ),
             
                Container(
                  margin: const EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                    ReButton(
                      isDisabled: disable,
                    color: "green", 
                    text: 'PRIHLÁSIŤ SA',
                    onTap: handleLogin,
                  ),
                  SizedBox(height: 10,),
                Text.rich(
                  TextSpan(
                    text: 'Obnoviť heslo',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    // You can also add onTap to make it clickable
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle the tap event here, e.g., open a URL
                        // You can use packages like url_launcher to launch URLs.
                        setState(() {
                          isPassword = true;
                        });
                      },
                  ),
                ),
              ]
            )
              )
            ],
          ),
        ),
      ),
    );
  }
}
