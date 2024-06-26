import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/controllers/SchoolController.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math';
import 'package:infomat/auth/auth.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/App.dart';

// Tento kód definuje formulár pre pridanie školy do aplikácie.

class SchoolForm extends StatefulWidget {
  final void Function() isSchool;

  const SchoolForm({
    Key? key,
    required this.isSchool,
  }) : super(key: key);
  
  @override
  _SchoolFormState createState() => _SchoolFormState();
}

class _SchoolFormState extends State<SchoolForm> {

  // Kontroléry pre manipuláciu s navigáciou stránok
  final NonSwipeablePageController _pageController = NonSwipeablePageController();
  final PageController _pageClassesController = PageController();
  
  // Aktuálny krok vo formulári
  int currentStep = 1;
  
  // Správa o výsledku
  String? resultMessage;
  
  // Príznaky pre rozlíšenie medzi mobilným a desktopovým zobrazením
  bool isMobile = false;
  bool isDesktop = false;
  
  // Premenné pre spracovanie chýb
  String _schoolIdError = '';
  Color _schoolIdBorderColor = AppColors.getColor('mono').lightGrey;
  String _schoolNameError = '';
  String _adminNameError = '';
  String _adminEmailError = '';
  
  // Kontroléry pre textové polia vo formulári
  TextEditingController _schoolIdController = TextEditingController();
  TextEditingController _schoolNameController = TextEditingController();
  TextEditingController _adminNameController = TextEditingController();
  TextEditingController _adminEmailController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  
  // Indexy pre sledovanie vybraných položiek
  int _selectedIndex = 0;
  int _selectedIndexClasses = 0;
  
  // Príznak pre zaškrtnutie
  bool check = false;
  
  // Generovaný kód
  String? generatedCode;
  
  // Zoznamy pre výber čísiel a rokov
  List<int> selectedNumbers = [-1, -1, -1, -1, -1, -1, -1, -1];
  List<int> selectedYears = [];
  
  // Príznaky pre triedu, učiteľa a načítavanie
  bool _class = false;
  bool setTeacher = false;
  bool _loading = false;
  
  // Kontroléry pre ďalšie textové polia
  TextEditingController _one = TextEditingController();
  TextEditingController _two = TextEditingController();
  TextEditingController _three = TextEditingController();
  TextEditingController _four = TextEditingController();
  TextEditingController _five = TextEditingController();
  TextEditingController _six = TextEditingController();
  TextEditingController _seven = TextEditingController();
  TextEditingController _eight = TextEditingController();
  
  // Chybové správy pre jednotlivé textové polia
  String _oneError = '';
  String _twoError = '';
  String _threeError = '';
  String _fourError = '';
  String _fiveError = '';
  String _sixError = '';
  String _sevenError = '';
  String _eightError = '';
  
  // Zoznamy pre jednotlivé textové polia
  List<String> one = [];
  List<String> two = [];
  List<String> three = [];
  List<String> four = [];
  List<String> five = [];
  List<String> six = [];
  List<String> seven = [];
  List<String> eight = [];
  
  // Kombinovaný zoznam
  List<String> combinedList = [];
  
  // Funkcia na získanie správneho kontroléra podľa indexu
  TextEditingController getController(int index) {
    switch (index) {
      case 1: return _one;
      case 2: return _two;
      case 3: return _three;
      case 4: return _four;
      case 5: return _five;
      case 6: return _six;
      case 7: return _seven;
      case 8: return _eight;
    }
    return _one;
  }

  // Funkcia na nastavenie chybovej správy podľa indexu
  void setError(int index, String message) {
    switch (index) {
      case 1:
        setState(() {
          _oneError = message;
        });
        break;
      case 2:
        setState(() {
          _twoError = message;
        });
        break;
      case 3:
        setState(() {
          _threeError = message;
        });
        break;
      case 4:
        setState(() {
          _fourError = message;
        });
        break;
      case 5:
        setState(() {
          _fiveError = message;
        });
        break;
      case 6:
        setState(() {
          _sixError = message;
        });
        break;
      case 7:
        setState(() {
          _sevenError = message;
        });
        break;
      case 8:
        setState(() {
          _eightError = message;
        });
        break;
      default:
        setState(() {
          _oneError = message;
        });
    }
  }

  // Funkcia na získanie chybovej správy podľa indexu
  String getError(int index) {
    switch (index) {
      case 1: return _oneError;
      case 2: return _twoError;
      case 3: return _threeError;
      case 4: return _fourError;
      case 5: return _fiveError;
      case 6: return _sixError;
      case 7: return _sevenError;
      case 8: return _eightError;
    }
    return _oneError;
  }

  // Funkcia na získanie zoznamu podľa indexu
  List<String> getList(int index) {
    switch (index) {
      case 1: return one;
      case 2: return two;
      case 3: return three;
      case 4: return four;
      case 5: return five;
      case 6: return six;
      case 7: return seven;
      case 8: return eight;
    }
    return one;
  }

  // Funkcia na kontrolu zoznamov podľa indexov
  bool checkLists(List<int> indexes) {
    for (int index in indexes) {
      List<String> list = getList(index + 1);
      if (list.isEmpty) {
        return false; // Ak je zoznam prázdny, vráti false
      }
    }
    return true; // Všetky zoznamy majú aspoň jeden prvok
  }

  // Funkcia na generovanie náhodného čísla
  int generateRandomInt({int length = 6}) {
    final Random random = Random();
    final int min = pow(10, length - 1).toInt(); // Prevod na int
    final int max = pow(10, length).toInt() - 1; // Prevod na int
    return min + random.nextInt(max - min + 1);
  }
  
  // Funkcia na odoslanie overovacieho kódu e-mailom
  Future<void> sendVerificationCode(String recipientEmail, String name, String verificationCode) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance; // Vytvorenie inštancie FirebaseFirestore

    await firestore.collection('mail').add({
      'to': [recipientEmail],
      'message': {
        'from': 'Infomat', // Zadajte meno odosielateľa
        'subject': 'Verifikácia',
        'html': 'Dobrý deň, $name,<br>váš overovací kód je <b>$verificationCode</b>.<br><br>Na túto správu neodpovedajte, bola odoslaná automaticky.'
      },
    }).then((value) {
      print('Queued email for delivery!');
    });
    
    print('done');
  }

  // Funkcia na kontrolu, či číslo existuje v súbore assetov
  Future<bool> numberExistsInAssetFile(String number) async {
    // Načítanie textového súboru z assetov
    final String data = await rootBundle.loadString('assets/skoly.txt');

    // Rozdelenie obsahu súboru na riadky
    final List<String> lines = data.split('\n');

    // Kontrola, či číslo existuje v niektorom z riadkov
    for (String line in lines) {
      if (line.trim() == number) {
        return true;
      }
    }

    // Ak číslo nebolo nájdené, vráti false
    return false;
  }


  
  // Iniciačná funkcia
  @override
  void initState() {
    super.initState();

    // Určenie, či je zariadenie mobilné alebo desktopové
    isMobile = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    isDesktop = !isMobile;
  }


  @override
  
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: check ? Theme.of(context).colorScheme.background : Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height <= 700
          ? 700
          : MediaQuery.of(context).size.height >= 900
              ?  MediaQuery.of(context).size.width > 1000 ? MediaQuery.of(context).size.height : 900
              : MediaQuery.of(context).size.height,
          width: double.infinity,
          child: check ? PageView(
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
                          width:  isMobile ? 132 : 172,
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
                                Text(
                                  'Nadpis',
                                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                        color: AppColors.getColor('mono').black,
                                      ),
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  'Názov školy',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor('mono').grey,
                                      ),
                                ),
                                SizedBox(height: 10,),
                                reTextField(
                                  'Názov školy',
                                  false,
                                  _schoolNameController,
                                  AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
                                  errorText: _schoolNameError
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  'Meno správcu / správkyne',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor('mono').grey,
                                      ),
                                ),
                                reTextField(
                                  'Meno správcu / správkyne',
                                  false,
                                  _adminNameController,
                                  AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
                                  errorText: _adminNameError
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  'Email správcu / správkyne',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor('mono').grey,
                                      ),
                                ),
                                reTextField(
                                  'Email správcu / správkyne',
                                  false,
                                  _adminEmailController,
                                  AppColors.getColor('mono').lightGrey,
                                  errorText: _adminEmailError
                                ),
                                Text(
                                  'Na tento email vám bude zaslaný verifikačný kód',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor('mono').grey,
                                      ),
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Checkbox(value: setTeacher, onChanged: (bool? newValue) {
                                    setState(() {
                                      setTeacher = newValue!;
                                    });
                                  },),
                                    Text('Použiť profil správcu školy zároveň ako učiteľský profil.', style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor('mono').grey,
                                  ),),
                                  ],
                                ),
                              ],
                            ),
                        )
                      ),
                      ReButton(
                        color: "green", 
                        text: 'ĎALEJ',
                        onTap: () async {

                          bool isUsed = await isEmailAlreadyUsed(_adminEmailController.text);
                          if(_schoolNameController.text != '') _schoolNameError = '';
                          if(_adminEmailController.text != '') _adminEmailError = '';
                          if(_adminNameController.text != '') _adminNameError = '';
                          if(!isUsed) _adminEmailError = '';
                          if (_schoolNameController.text != '' && _adminEmailController.text != '' && _adminNameController.text != '' && !isUsed) {
                            _onNavigationItemSelected(_selectedIndex + 1);
                            
                            setState(() {
                              generatedCode = generateRandomInt().toString();
                            });
                            sendVerificationCode( _adminEmailController.text, _adminNameController.text, generatedCode!);
                          } else {

                            setState(() {
                              if(_schoolNameController.text == '') _schoolNameError = 'Názov školy je poviné pole';
                              if(_adminEmailController.text == '') _adminEmailError = 'E-mail je poviné pole';
                              if(_adminNameController.text == '') _adminNameError = 'Meno správcu je poviné pole';
                              if(isUsed) _adminEmailError = 'Účet s daným E-mailom už existuje';
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
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.getColor('mono').darkGrey,
                              ),
                              onPressed: () {
                                _onNavigationItemSelected(_selectedIndex - 1); 
                              },
                            ),
                            Spacer(),
                              Container(
                            child: SvgPicture.asset(
                              'assets/logoFilled.svg',
                              width:  isMobile ? 132 : 172,
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
                        text: 'ĎALEJ',
                        onTap: () {
                          if (generatedCode == _codeController.text) {

            
                            _onNavigationItemSelected(_selectedIndex + 1);

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
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.getColor('mono').darkGrey,
                              ),
                              onPressed: () {
                                _onNavigationItemSelected(_selectedIndex - 1); 
                              },
                            ),
                            Spacer(),
                              Container(
                            child: SvgPicture.asset(
                              'assets/logoFilled.svg',
                              width:  isMobile ? 132 : 172,
                            ),
                            padding: EdgeInsets.all(16),
                          ),
                            Spacer(),
                            Container(width: 2.5,)
                          ],
                        ),
                      ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 900),
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vyberte ročníky, ktoré budú aplikáciu používať:',
                                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                          color: AppColors.getColor('mono').black,
                                        ),
                                  ),
                                  Text(
                                    'K ročníkom budete môcť priradiť triedy (napríklad 1.A a 1.B pre 1. ročník SŠ)',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: AppColors.getColor('mono').grey,
                                        ),
                                  ),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(0),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(1),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(2),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(3),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(4),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(5),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(6),
                                  SizedBox(height: 10,),
                                  _buildClassesCheckbox(7),
                                ],
                              ),
                          ),
                        ReButton(
                          color: "green", 
                          text: 'ĎALEJ',
                          onTap: () {
                             bool containsNonNegativeOne = false;

                            // Check if there's at least one number different from -1 in the list
                            for (int number in selectedNumbers) {
                              if (number != -1) {
                                containsNonNegativeOne = true;
                                selectedYears.add(number);
                              }
                            }

                            // If there's at least one non-negative one, remove all occurrences of -1
                            if (containsNonNegativeOne) {
                              _onNavigationItemSelected(_selectedIndex + 1);
                              setState(() {
                                _class = true;
                              });
                            }
                          },
                        ),
                      ],
                  ),
                  if (_class) _loading ?Center(child: CircularProgressIndicator(),) : 
                  Column(
                    children: <Widget>[
                      SizedBox(height: 60),
                       Container(
                        width: 900,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.getColor('mono').darkGrey,
                              ),
                              onPressed: () {
                                _onNavigationItemSelected(_selectedIndex - 1);
                                selectedYears = []; 
                              },
                            ),
                            Spacer(),
                              Container(
                            child: SvgPicture.asset(
                              'assets/logoFilled.svg',
                              width:  isMobile ? 132 : 172,
                            ),
                            padding: EdgeInsets.all(16),
                          ),
                            Spacer(),
                            Container(width: 2.5,)
                          ],
                        ),
                      ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 900),
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'K vybraným ročníkom priraďte triedy, ktoré budú aplikáciu používať.',
                                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                          color: AppColors.getColor('mono').black,
                                        ),
                                  ),
                                  Text(
                                    'Toto pomenovanie sa bude následne používať pri označovaní tried v aplikácii.',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: AppColors.getColor('mono').grey,
                                        ),
                                  ),
                                  SizedBox(height: 20,),
                                  Container(
                                    height: 300,
                                    child: PageView.builder(
                                    itemCount: selectedYears.length,
                                    controller: _pageClassesController,
                                    onPageChanged: _onPageClassChanged,
                                    itemBuilder:(context, index) {
                                      return 
                                         Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Text(
                                            '${selectedYears[index] + 1}. ročník ${ (selectedYears[index]) < 5 ? 'SŠ' : 'ZŠ'}',
                                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                color: AppColors.getColor('mono').black,
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            reTextField(
                                              'Názov triedy - napr. ${selectedYears[index] + 1}.A',
                                              false,
                                              getController(selectedYears[index] + 1),
                                              AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
                                              errorText: getError(selectedYears[index] + 1)
                                            ),
                                           SizedBox(height: 10,),
                                            Container(
                                              width: 314,
                                              height: 50,
                                              child: ReButton(
                                                color: "grey", 
                                                text: 'Pridať triedu pre ${selectedYears[index] + 1}. ročník ', 
                                                leftIcon: 'assets/icons/plusIcon.svg',
                                                onTap: () {
                                                  setState(() {
                                                    if(!getList(selectedYears[index] + 1).contains(getController(selectedYears[index] + 1).text) && getController(selectedYears[index] + 1).text != '') {
                                                      setError(selectedYears[index] + 1, '');
                                                      getList(selectedYears[index] + 1).add(getController(selectedYears[index] + 1).text);
                                                      combinedList.add(getController(selectedYears[index] + 1).text);
                                                    } else {
                                                      setError(selectedYears[index] + 1, 'Pole je prázdne');
                                                    }
                                                  });
                                                }
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                             Text(getList(selectedYears[index] + 1).join(', '),
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                  color: AppColors.getColor('mono').grey,
                                                ),
                                              ),
                                          ]
                                      );
                                      }
                                  ),
                                  ),
                                  Row(
                                    children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: ReButton(
                                            color: "grey", 
                                            text: '', 
                                            leftIcon: 'assets/icons/arrowLeftIcon.svg',
                                            isDisabled: _selectedIndexClasses - 1 < 0,
                                            
                                            onTap: () {
                                              _onNavigationClassesSelected(_selectedIndexClasses - 1);
                                            }
                                          ),
                                        ),

                                        Spacer(),
                                        Text('${_selectedIndexClasses + 1}/${selectedYears.length}'),
                                        Spacer(),
                                        Container(
                                          width: 61,
                                          height: 61,
                                          child: ReButton(
                                            color: "grey",  
                                            text: '', 
                                            leftIcon: 'assets/icons/arrowRightIcon.svg',
                                            isDisabled: _selectedIndexClasses + 1 == selectedYears.length,
                                            onTap: () {
                                              _onNavigationClassesSelected(_selectedIndexClasses + 1);
                                            }
                                          ),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                          ),
                        ReButton(
                          color: "green", 
                          text: 'ĎALEJ',
                          onTap: () async {
                            for(int i = 0; i < selectedYears.length; i++) {
                              if(!getList(i).isEmpty) setError(selectedYears[i] + 1, '');
                            }
                             if(checkLists(selectedYears)) {
                                registerAdmin(_adminNameController.text, _adminEmailController.text, context);
                             };
                             for(int i = 0; i < selectedYears.length; i++) {
                              if(getList(i).isEmpty) setError(selectedYears[i] + 1, 'Pole je povinné');
                            }
                         

                          },
                        ),
                        
                      ],
                  ),
                  Column(
                  children: <Widget>[
                    SizedBox(height: 50),
                    Container(
                        child: SvgPicture.asset(
                          'assets/logoFilled.svg',
                          width:  isMobile ? 132 : 172,
                        ),
                        padding: EdgeInsets.all(16),
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min, // Ensure the dialog takes up minimum height
                            children: [
                              SvgPicture.asset('assets/icons/correctIcon.svg', width: 72, color: AppColors.getColor('green').main),
                              SizedBox(height: 25,),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Účet školy bol vytvorený',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                        color: AppColors.getColor('mono').black,
                                      ),
                                ),
                              ),
                              SizedBox(height: 15,),
                              Container(
                                width: 300,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Údaje o vašej škole boli uložené. V ďalšom kroku pridáte do aplikácie učiteľov a študentov.',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                      Container(
                        width: 300,
                        child: ReButton(
                          color: "green", 
                          text: 'POKRAČOVAŤ DO APLIKÁCIE',
                          onTap: () {
                            widget.isSchool();
                          }
                        ),
                      ),
                      
                      SizedBox(height: 60),
                    ],
                ),
                  
              ],
            ) : Container(
               padding: EdgeInsets.all(16),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 60),
                    Container(
                        child: SvgPicture.asset(
                          'assets/logo.svg',
                          width:  isMobile ? 132 : 172,
                        ),
                        padding: EdgeInsets.all(16),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zadajte kód svojej školy',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 40,),
                            Container(
                              width: 300,
                              child: reTextField(
                                "Zadajte oficiálny kód školy",
                                false,
                                _schoolIdController,
                                _schoolIdBorderColor,
                                errorText: _schoolIdError
                              ),
                            ),
                            SizedBox(height: 40,),
                            Text(
                              'Kód školy môžete získať na sekretariáte školy.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      ReButton(
                        color: "green", 
                        text: 'VYTVORIŤ ÚČET',
                        onTap: () async {
                          bool appExist = await doesSchoolExist(_schoolIdController.text);
                          bool exists = await numberExistsInAssetFile(_schoolIdController.text);
                          if (exists && !appExist) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  content: 
                                  Container(
                                    width: 328,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min, // Ensure the dialog takes up minimum height
                                      children: [
                                        SvgPicture.asset('assets/icons/correctIcon.svg', width: 72, color: AppColors.getColor('green').main),
                                        SizedBox(height: 25,),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Kód overený',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                  color: AppColors.getColor('mono').black,
                                                ),
                                          ),
                                        ),
                                        SizedBox(height: 15,),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Kód školy bol overený. Teraz môžete vašej škole založiť účet.',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 30,),
                                        Container(
                                          child: Container(
                                            width: 270,
                                            height: 48,
                                            child: ReButton(
                                              color: "green", 
                                              text: 'POKRAČOVAŤ',  
                                              onTap: () {
                                                setState(() {
                                                    check = exists;
                                                  });
                                                Navigator.of(context).pop();
                                              }
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                );
                              },
                            );
                          } else if (appExist) {
                            setState(() {
                              _schoolIdError = 'Daná škola už existuje';
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  content: Container(
                                    width: 328,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min, // Ensure the dialog takes up minimum height
                                      children: [
                                        Row(
                                          children: [
                                            Spacer(),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                child: SvgPicture.asset('assets/icons/xIcon.svg', height: 10,),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        SvgPicture.asset('assets/icons/smallErrorIcon.svg', width: 64, color: Theme.of(context).colorScheme.error,),
                                        SizedBox(height: 30,),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Nesprávny kód',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                  color: AppColors.getColor('mono').black,
                                                ),
                                          ),
                                        ),
                                        SizedBox(height: 30,),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Kód školy je neplatný. Skontrolujte jeho správnosť, alebo sa obráťte na support@info-mat.sk.',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 30,),
                                      ],
                                    ),
                                  )
                                );
                              },
                            );
                          }
                            
                        },
                      ),
                      SizedBox(height: 60),

                    ],
                  ),
          ),
        )
      )
    );
  }

  // Funkcia na vytvorenie zaškrtávacieho políčka pre triedy
  Widget _buildClassesCheckbox(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.getColor('mono').lightGrey), // Grey border
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      margin: EdgeInsets.symmetric(vertical: 5.0), // Add margin for spacing
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          '${index + 1}. ročník',
          style: TextStyle(
            color: Colors.black, // Purple when checked
          ),
        ),
        value: selectedNumbers[index] == index,
        onChanged: (value) {
          setState(() {
            if (value!) {
              selectedNumbers[index] = index; // Use assignment operator = here
            } else {
              selectedNumbers[index] = -1; // You might want to set a different value when unchecked
            }
          });
        },
        controlAffinity: ListTileControlAffinity.leading, // Place the checkbox to the left
        activeColor: AppColors.getColor('primary').main, // Custom active color
      ),
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

  void _onNavigationClassesSelected(int index) {
    setState(() {
      _selectedIndexClasses = index;
      _pageClassesController.animateToPage(
        index,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  void _onPageClassChanged(int index) {
    setState(() {
      _selectedIndexClasses = index;
    });
  }

  String generateRandomPassword({int length = 12}) {
    // Define character sets for different types of characters
    final String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    final String numericChars = '0123456789';

    // Combine all character sets
    final String allChars =
        uppercaseChars + lowercaseChars + numericChars;

    final Random random = Random();

    // Initialize an empty password string
    String password = '';

    // Ensure the password contains at least one character from each character set
    password += uppercaseChars[random.nextInt(uppercaseChars.length)];
    password += lowercaseChars[random.nextInt(lowercaseChars.length)];
    password += numericChars[random.nextInt(numericChars.length)];

    // Generate the remaining characters randomly
    for (int i = 4; i < length; i++) {
      password += allChars[random.nextInt(allChars.length)];
    }

    // Shuffle the password to make it more random
    List<String> passwordCharacters = password.split('');
    passwordCharacters.shuffle();
    password = passwordCharacters.join('');

    return password;
  }

   Future<void> registerAdmin(String name, String email, BuildContext context) async {
      try {
        setState(() {
          _loading = true;
        });
        final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

        String generatePassword = generateRandomPassword();
        final result = await functions.httpsCallable('createAccount').call({
          'email': email,
          'password': generatePassword,
        });


        // updateClassToFirestore(data.schoolClass, result.data['uid']);

        // Set the user's ID from Firebase
        userData.id = result.data['uid'];

        // Once the user is created in Firebase Auth, add their data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userData.id).set({
          'admin': true,
          'email': email,
          'name': name,
          'discussionPoints': userData.discussionPoints,
          'weeklyDiscussionPoints': userData.weeklyDiscussionPoints,
          'active': userData.active,
          'classes': [],
          'school': _schoolIdController.text,
          'schoolClass': '',
          'signed': userData.signed,
          'teacher': true,
          'points': userData.points,
          'capitols': userData.capitols.map((capitol) => {
            'id': capitol.id,
            'name': capitol.name,
            'image': capitol.image,
            'completed': capitol.completed,
            'tests': capitol.tests.map((test) => {
              'name': test.name,
              'completed': test.completed,
              'points': test.points,
              'questions': test.questions.map((question) => {
                'answer': question.answer,
                'completed': question.completed,
                'correct': question.correct
              }).toList(),
            }).toList(),
          }).toList(),
          'notifications': userData.notifications,
          'materials': userData.materials,
        });

        FirebaseFirestore firestore = FirebaseFirestore.instance; // Create an instance of FirebaseFirestore
          await firestore.collection('mail').add(
            {
              'to': [email],
              'message': {
                'subject': 'Heslo',
                'html': 'Dobrý deň, $name,<br>vaše heslo je <b>$generatePassword</b>.<br><br>Na túto správu neodpovedajte, bola odoslaná automaticky.'
              },
            },
          ).then(
            (value) {
              print('Queued email for delivery!');
            },
          );

        addSchool(_schoolIdController.text,_schoolNameController.text, userData.id , [], setTeacher);

        for (String name in combinedList) {
            addClass(name, _schoolIdController.text, null, (String) {});
          }

           _onNavigationItemSelected(_selectedIndex + 1);

          setState(() {
            _loading = false;
          });

        
      } catch (e) {
        reShowToast('Správcu sa nepodarilo pridať', true, context);
         setState(() {
          _loading = false;
        });
      }
    }
}
