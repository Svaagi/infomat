import 'package:flutter/material.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:html' as html;
import 'package:infomat/models/ResultsModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


class TeacherDesktopTest extends StatefulWidget {
  final int testIndex;
  final Function overlay;
  final String capitolsId;
  final UserData? userData;
  final ResultTestData results;
  final int studentsSum;
  final bool usersCompleted;

  const TeacherDesktopTest(
      {Key? key,
      required this.testIndex,
      required this.overlay,
      required this.capitolsId,
      required this.results,
      required this.studentsSum,
      required this.usersCompleted,
      required this.userData})
      : super(key: key);

  @override
  State<TeacherDesktopTest> createState() => _TeacherDesktopTestState();
}

class _TeacherDesktopTestState extends State<TeacherDesktopTest> {
  bool? isCorrect;
  int questionIndex = 0;
  String conclusion = '';
  List<dynamic> division = [];
  List<dynamic> answers = [];
  List<dynamic> answersImage = [];
  List<dynamic> matchmaking = [];
  List<dynamic> matches = [];
  List<dynamic> correct = [];
  String definition = '';
  List<dynamic> explanation = [];
  List<dynamic> images = [];
  String question = '';
  String subQuestion = '';
  String title = '';
  int? questionsPoint;
  bool pressed = false;
  List<dynamic>? percentages;
  double? percentagesAll;
  bool _loading = true; // Add this line
  int? openDropdownIndex;
  String? allCorrects;
  bool firstScreen = true;
  String? introduction;
  bool checkTitle = false;

  final userAgent = html.window.navigator.userAgent.toLowerCase();

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> sendStartEvent() async {
    await analytics.logEvent(
      name: 'test učiteľ',
      parameters: {
        'event': 'zobrazenie', // replace with your actual page/screen name
      },
    );
  }



  Future<void> fetchQuestionData() async {
      String jsonData = await rootBundle.loadString('assets/CapitolsData.json');
      List<dynamic> data = json.decode(jsonData);

      checkTitle = false;

        

        if (title == '' && definition == '' && images.isEmpty && division.isEmpty) {
          checkTitle = false;
        } else if (title != '' && definition == '' && images.isEmpty && division.isEmpty) {
          checkTitle = true;
        } else {
          checkTitle = true;
        }

        _loading = false;

      setState(() {
        conclusion = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["conclusion"] ?? '';
        division = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["division"] ?? [];
        answers = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["answers"] ?? [];
        answersImage = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["answersImage"] ?? [];
        matchmaking = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["matchmaking"] ?? [];
        matches = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["matches"] ?? [];
        correct = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["correct"] ?? [];
        definition = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["definition"] ?? '';
        explanation = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["explanation"] ?? [];
        images = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["images"] ?? [];
        question = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["question"] ?? '';
        subQuestion = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["subQuestion"] ?? '';
        title = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["title"] ?? '';
        questionsPoint = data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["points"] ?? 0;
        introduction =  data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["introduction"] ?? '';
        if (widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions[questionIndex].completed == true) {
            pressed = true;

        }

        if (matchmaking.length > 1) {
            allCorrects = correct.map((e) {
                String letter = String.fromCharCode(97 + int.parse(e["correct"]));
                return 'pri otázke ${int.parse(e["index"]) + 1}. je odpoveď $letter)';
            }).join(', ');
        } else {
            allCorrects = correct.map((e) => String.fromCharCode(97 + int.parse(e["correct"].toString())) + ')').join(', ');
        }
      });

  }
  @override
  void didUpdateWidget(TeacherDesktopTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.testIndex != oldWidget.testIndex) {
      // Test ID has changed, reset the state and fetch new data
      setState(() {
        questionIndex = 0;
      });
      fetchQuestionData();

    }
        _loading = false;

  }

  @override
  void initState() {
    // TODO: implement initState
    fetchQuestionData();

    sendStartEvent();
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
        return const Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
    }
    return Stack(
      children: [
        firstScreen ? Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor
            ),
          ),) : Container(),

        firstScreen ? Positioned.fill(
          child:  SvgPicture.asset(
            'assets/lastScreenBackground.svg',
            fit: BoxFit.cover,
          ),
         ) : Container(),
        
      Scaffold(
      appBar: AppBar(
        backgroundColor: 
            firstScreen
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.background,
        elevation: 0,
        flexibleSpace: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          height: 120, // adjust this to make the AppBar taller
          child: !firstScreen
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        questionsPoint ?? 0,
                        (index) {
                          const  maxCellWidth = 50.0; // Specify the maximum cell width
                          const  minWidth = 40.0; // Specify the minimum cell width
                          final totalWidth =
                              maxCellWidth * (questionsPoint ?? 1);
                          final availableWidth =
                              MediaQuery.of(context).size.width -
                                  (questionsPoint ?? 0 - 1) * 2.0 * 2.0;

                          final width = (availableWidth / totalWidth * maxCellWidth)
                              .clamp(minWidth, maxCellWidth);

                          return Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                              width: width,
                              height: 10,
                              decoration: BoxDecoration(
                                color: questionIndex >= index
                                    ? AppColors.getColor('green').main
                                    : AppColors.getColor('primary').lighter,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : null,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: 
              firstScreen
                ? AppColors.getColor('mono').white
                : AppColors.getColor('mono').black,
          ),
          onPressed: () =>
              widget.overlay(),
        ),
      ),

      backgroundColor: firstScreen ?  Colors.transparent : Theme.of(context).colorScheme.background,
      body: !firstScreen ? SingleChildScrollView(
         child:
          Column(
          children: [
          SizedBox(
            width: double.infinity,
            child:
          Align( 
            alignment:  Alignment.topCenter,
            child: Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.spaceEvenly,

            children: [
            if (checkTitle ) Container(
              width: 670,
              margin:  const EdgeInsets.only(bottom: 12, left: 12, right: 30, top: 50),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius:  BorderRadius.circular(10),
                    border: Border.all(color: AppColors.getColor('mono').grey),
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                      ),
                  Column(
                    children: [
                      if ( division.isNotEmpty)
                        ...division.map((dvs) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.getColor('mono').grey),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: 200,
                                    height: 210,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: AppColors.getColor('mono').grey) ,),
                                    ),
                                    child: Text(
                                      dvs["title"],
                                      style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                              color: Theme.of(context).colorScheme.onBackground,
                                            ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 400,
                                    height: 200,
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      dvs["text"],
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              color: Theme.of(context).colorScheme.onBackground,
                                            ),
                                    ),
                                  )
                                ],
                              ),
                            )).toList()
                      else 
                        Container(), // Pl
                        ...images.map((img) => Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.getColor('mono').grey),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(img!,),
                              ),
                            )).toList(),
                    // Placeholder for empty image field
                        
                      definition != '' ? Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.getColor('mono').grey),
                          color: Theme.of(context).colorScheme.background
                          ),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          definition,
                          style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                        ),
                      ) : Container(),
                    ],
                  ),
                ],
              ),
            ),
            Container(
               width: ((title != '' || definition != '' || images.isNotEmpty) && checkTitle) ? 600 : 800,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
              child: 
                Container(
                  constraints: const BoxConstraints(minHeight: 576,),
                    child:
                     Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(widget.usersCompleted)Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.getColor('primary').main,
                              width: 2
                            ),
                          ),
                            child: Row(
                              children: [
                                Text('Otázka ${questionIndex + 1}: ',
                                  style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      color: AppColors.getColor('primary').main,
                                    ),
                                ),
                                const SizedBox(width: 8,),
                                Text('Úspešnosť: ${ (widget.studentsSum != 0 ? (widget.results.questions[questionIndex].points/widget.studentsSum).round()*100 : 0)}%',
                                  style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                )
                              ],
                            )
                        ),
                        if(!checkTitle)const SizedBox(height: 30,),
                           if(!checkTitle)Container(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                            ),
                          ),
                          if(question != '')const SizedBox(height: 30,),
                          question != '' ? Container(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                question,
                                style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                              ),
                            ) : Container(),
                            if (!(title != '' || definition != '' || images.isNotEmpty)) const SizedBox(height: 20,),
                            subQuestion != '' ?  Container(
                            padding: EdgeInsets.all(4),
                            child: Text(
                                subQuestion,
                                style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                              )
                            ) : Container(),
                            if (!(title != '' || definition != '' || images.isNotEmpty)) const SizedBox(height: 20,),
                         const SizedBox(height: 30,),
                         ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (answersImage.length) + (answers.length) + (matchmaking.length),
                            itemBuilder: (BuildContext context, index) {
                              String? itemText;
                              Color bgColor;
                              Color borderColor;
                              Color percentageColor;
                              bool isCorrect = correct.any((cItem) => cItem["index"] == index);
                              Widget mainWidget;
                              // Handle answersImage
                              if (index < answersImage.length &&  answersImage.isNotEmpty) {
                                String item = answersImage[index];
                                itemText = explanation.length > 1 && explanation[index].isNotEmpty  ? explanation[index] : null;
                                bgColor = isCorrect ? AppColors.getColor('green').lighter : AppColors.getColor('mono').white;
                                borderColor = isCorrect ? AppColors.getColor('green').main : AppColors.getColor('mono').grey;
                                percentageColor = isCorrect ? AppColors.getColor('green').main : AppColors.getColor('red').main;
                                if (widget.usersCompleted) {
                                  mainWidget = reTileImage(bgColor, borderColor, index, item, context, percentage: (widget.studentsSum != 0 ? widget.results.questions[questionIndex].answers[index]/widget.studentsSum : 0.0), correct: isCorrect, percentageColor: percentageColor);
                                } else {
                                  mainWidget = reTileImage(bgColor, borderColor, index, item, context, correct: isCorrect);
                                }
                              }
                              // Handle answers
                              else if ((index - answersImage.length) < answers.length &&  answers.isNotEmpty && answers[index - answersImage.length].isNotEmpty) {
                                String? item = answers[index - answersImage.length].isNotEmpty ? answers[index - answersImage.length] : null;
                                itemText = explanation.length > 1 && explanation[index - answersImage.length].isNotEmpty  ? explanation[index - answersImage.length] : null;
                                bgColor = isCorrect ? AppColors.getColor('green').lighter : AppColors.getColor('mono').white;
                                borderColor = isCorrect ? AppColors.getColor('green').main : AppColors.getColor('mono').lightGrey;
                                percentageColor = isCorrect ? AppColors.getColor('green').main : AppColors.getColor('red').main;
                                if (widget.usersCompleted) {
                                  mainWidget = reTile(bgColor, borderColor, index, item, context, percentage: (widget.results.questions[questionIndex].answers[index]/widget.studentsSum)*100, correct: isCorrect, percentageColor: percentageColor);
                                } else {
                                  mainWidget = reTile(bgColor, borderColor, index, item, context, correct: isCorrect);
                                }
                              }
                              // Handle matchmaking
                              else  {
                                itemText = explanation.length > 1 && explanation[index - answersImage.length - answers.length].isNotEmpty  ? explanation[index - answersImage.length - answers.length ] : null;
                                String? item = matchmaking[index  - answersImage.length  - answers.length];
                                List<dynamic> item2 = matches;
                                itemText = explanation.length > 1 && explanation[index - answersImage.length  - answers.length].isNotEmpty  ? explanation[index - answersImage.length - answers.length ] : null;
                                bgColor = isCorrect ? AppColors.getColor('green').lighter : AppColors.getColor('mono').white;
                                borderColor = isCorrect ? AppColors.getColor('green').main : AppColors.getColor('mono').lightGrey;
                                percentageColor = isCorrect ? AppColors.getColor('green').main : AppColors.getColor('red').main;
                                mainWidget = reTileMatchmaking(bgColor, borderColor, correct.firstWhere((cItem) => cItem["index"] == index)["correct"], index, item, context, item2, true);
                              }
                              // Return the main widget alongside the item text
                              return Column(
                                children: [
                                  mainWidget,
                                  if(itemText != null)Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.getColor('primary').lighter,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,  // aligns items to the top
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/lightbulbIcon.svg',  // Make sure to replace this with your SVG asset path
                                          width: 30,  // Optional: You can adjust width & height as per your requirement
                                          height: 30,
                                        ),
                                        const SizedBox(width: 12),  // Give some spacing between the SVG and the text
                                        Expanded(  // To make sure the text takes the remaining available space and wraps if needed
                                          child: Text(
                                            itemText,
                                            style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    color: Theme.of(context).colorScheme.onBackground,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  
                                ],
                              );
                            },
                            ),
                         if(conclusion != '') Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                              child: Text(
                                "Záver: $conclusion",
                                style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                              ),
                         ),
                      if(explanation.length < 2 && explanation.isNotEmpty)Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.getColor('primary').lighter,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,  // aligns items to the top
                          children: [
                            SvgPicture.asset(
                              'assets/icons/lightbulbIcon.svg',  // Make sure to replace this with your SVG asset path
                              width: 30,  // Optional: You can adjust width & height as per your requirement
                              height: 30,
                            ),
                            const SizedBox(width: 12),  // Give some spacing between the SVG and the text
                            Expanded(  // To make sure the text takes the remaining available space and wraps if needed
                              child: Text(
                                'Správna je odpoveď ${allCorrects ?? ''}: ${explanation[0] ?? ''}',
                                style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                      
                      ]
                      )
                ),
              )
          ],
        ),
          )
          ),
          const SizedBox(height: 50,),
          Container(
            padding: const EdgeInsets.all(8),
            width: 900,
            child:  Row(
              children: [
                 ReButton(
                    color: "grey",
                    text: 'Predchádzajúca', 
                    leftIcon: 'assets/icons/arrowLeftIcon.svg',
                    onTap: () {
                      questionIndex > 0
                    ? setState(() {
                        questionIndex--;
                        fetchQuestionData();
                      })
                    : widget.overlay();
                    },
                  ),
                const Spacer(),
               ReButton(
                    color: "grey",
                    text: 'Následujúca', 
                    rightIcon: 'assets/icons/arrowRightIcon.svg',
                    onTap: () {
                      if (questionIndex + 1 < (questionsPoint ?? 0)) {
                        setState(() {
                        questionIndex++;
                        fetchQuestionData();
                      });
                      } else {
                        setState(() {
                          questionIndex = 0;
                          pressed = false;
                          checkTitle = false;
                        });
                      
                        _showscreen();
                      }
                      
                    },
                  ),
              ],
            ),
          ),
         
          const SizedBox(height: 50,),
         ]
      ),
          ) :
      Container(
        decoration: BoxDecoration(
                  color: AppColors.getColor('mono').white
                ),
      child: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * (1/2),
              decoration: BoxDecoration(
                  color: AppColors.getColor('primary').light,
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].name,
                    style:  Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                    CircularPercentIndicator(
                          radius: 45.0,  // Adjust as needed
                          lineWidth: 8.0,
                          animation: true,
                          percent: 0.05,
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: AppColors.getColor('yellow').light,
                          backgroundColor: AppColors.getColor('mono').lighterGrey,
                      ),
                    SvgPicture.asset('assets/icons/starYellowIcon.svg', height: 30,),
                  ],),
                  const SizedBox(height: 10),
                  Container(width: 800 ,padding: const EdgeInsets.all(8),
                    child: Text(introduction ?? '',
                      textAlign: TextAlign.center,
                      style:  Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    ),
                  ),

                ],
                
              ),
            ),
            Transform.translate(
              offset: Offset(0, -1),  // This might help to snap the SVG directly against the container above
              child: SvgPicture.asset(
                'assets/bottomBackground.svg',
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            const Spacer(),
            ReButton(color: "green", text: 'POKRAČOVAŤ', onTap:
              () {
                setState(() {
                  firstScreen = false;
                });
              }
            ),
            const SizedBox(height: 60),
          ],
        ))))
      ]
    );
  }


// Define a utility function for firstWhereOrNull behavior
dynamic firstWhereOrNull(List<dynamic> list, bool Function(dynamic) test) {
    for (dynamic element in list) {
        if (test(element)) return element;
    }
    return null;
}

  void onNextButtonPressed() {
    if (questionIndex + 1 < (questionsPoint ?? 0)) {
      setState(() {
        questionIndex++;
        pressed = false;
        _loading = true;
        checkTitle = false;
      });
      fetchQuestionData();
    } else {

      setState(() {
        questionIndex = 0;
        pressed = false;
        checkTitle = false;
      });
     
      _showscreen();
    }
  }


  void _showscreen() {
    setState(() {
      // Update the state to show the last screen
      question = '';
      subQuestion = '';
      title = '';
      images = [];
      definition = '';
      answers = [];
      answersImage = [];
      matches = [];
      matchmaking = [];
    });
    widget.overlay();
  }

  bool areAllCompleted(UserData userData) {
    for (var capitol in userData.capitols) {
      for (var test in capitol.tests) {
        if (!test.completed) {
          return false;
        }
      }
    }
    return true;
  }

}
