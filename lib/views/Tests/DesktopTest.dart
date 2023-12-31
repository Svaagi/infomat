import 'package:flutter/material.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:html' as html;
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/controllers/ResultsController.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


class DesktopTest extends StatefulWidget {
  final int testIndex;
  final Function overlay;
  final String capitolsId;
  final UserData? userData;
  final List<dynamic> data;
  final String resultsId;

  const DesktopTest(
      {Key? key,
      required this.testIndex,
      required this.overlay,
      required this.capitolsId,
      required this.userData,
      required this.data,
      required this.resultsId
      })
      : super(key: key);

  @override
  State<DesktopTest> createState() => _DesktopTestState();
}

class _DesktopTestState extends State<DesktopTest> {
  List<UserAnswerData> _answer = [];
  bool? isCorrect;
  bool screen = true;
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
  bool _disposed = false;
  bool pressed = false;
  List<dynamic>? percentages;
  double? percentagesAll;
  bool _loading = true; // Add this line
  int? openDropdownIndex;
  String? allCorrects;
  bool usersCompleted = false;
  bool firstScreen = true;
  String? introduction;
  bool checkTitle = false;

  final userAgent = html.window.navigator.userAgent.toLowerCase();

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> sendStartEvent() async {
    await analytics.logEvent(
      name: 'test',
      parameters: {
        'event': 'start', // replace with your actual page/screen name
      },
    );
  }

  Future<void> sendCompleteEvent() async {
    await analytics.logEvent(
      name: 'test',
      parameters: {
        'event': 'complete', // replace with your actual page/screen name
      },
    );
  }


  Future<void> fetchQuestionData(int index) async {
      setState(() {
        conclusion = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["conclusion"] ?? '';
        division = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["division"] ?? [];
        answers = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["answers"] ?? [];
        answersImage = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["answersImage"] ?? [];
        matchmaking = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["matchmaking"] ?? [];
        matches = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["matches"] ?? [];
        correct = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["correct"] ?? [];
        definition = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["definition"] ?? '';
        explanation = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["explanation"] ?? [];
        images = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["images"] ?? [];
        question = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["question"] ?? '';
        subQuestion = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["subQuestion"] ?? '';
        title = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["questions"][questionIndex]["title"] ?? '';
        questionsPoint = widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["points"] ?? 0;
        introduction =  widget.data[int.parse(widget.capitolsId)]["tests"][widget.testIndex]["introduction"] ?? '';
        if (widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions[questionIndex].completed == true) {
            _answer = widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions[questionIndex].answer;
            pressed = true;

        }

        if (matchmaking.length > 1) {
            allCorrects = correct!.map((e) {
                String letter = String.fromCharCode(97 + int.parse(e["correct"]));
                return 'pri otázke ${int.parse(e["index"]) + 1}. je odpoveď $letter)';
            }).join(', ');
        } else {
            allCorrects = correct!.map((e) => String.fromCharCode(97 + int.parse(e["correct"].toString())) + ')').join(', ');
        }

        checkTitle = false;

        if(title != '' && definition == '' && images.length == 0 && division.length == 0) checkTitle = true;


      });
        _loading = false;
  }


  @override
  void initState() {
    super.initState();

    sendStartEvent();

        
    if (countTrueValues(widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions) == widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions.length) {
      questionIndex = 0;
    } else {
      questionIndex = countTrueValues(widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions);
    } 

    fetchQuestionData(questionIndex);




    
  }

  @override
  void didUpdateWidget(DesktopTest oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.testIndex != oldWidget.testIndex) {
      // Test ID has changed, reset the state and fetch new data
      setState(() {
        questionIndex = 0;
        _answer = [];
      });
      fetchQuestionData(questionIndex);
    }
     _loading = false;
  }
  

  @override
  void dispose() {
    _disposed = true; // Set the disposed flag to true
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
        return Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
    }
    return Stack(
      children: [
        screen ? Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor
            ),
          ),) : Container(),

        screen ? Positioned.fill(
          child:  SvgPicture.asset(
            'assets/lastScreenBackground.svg',
            fit: BoxFit.cover,
          ),
         ) : Container(),
        
      Scaffold(
      appBar: AppBar(
        backgroundColor: 
            screen
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.background,
        elevation: 0,
        flexibleSpace: Container(
          padding: EdgeInsets.symmetric(horizontal: 50),
          height: 120, // adjust this to make the AppBar taller
          child: !screen
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        questionsPoint ?? 0,
                        (index) {
                          final maxCellWidth = 50.0; // Specify the maximum cell width
                          final minWidth = 40.0; // Specify the minimum cell width
                          final totalWidth =
                              maxCellWidth * (questionsPoint ?? 1);
                          final availableWidth =
                              MediaQuery.of(context).size.width -
                                  (questionsPoint ?? 0 - 1) * 2.0 * 2.0;

                          final width = (availableWidth / totalWidth * maxCellWidth)
                              .clamp(minWidth, maxCellWidth);

                          return Flexible(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2.0),
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
              screen
                ? AppColors.getColor('mono').white
                : AppColors.getColor('mono').black,
          ),
          onPressed: () =>
              /*questionIndex > 0
                  ? setState(() {
                      questionIndex--;
                      fetchQuestionData(questionIndex);
                    })
                  : widget.overlay(), */
              widget.overlay()
        ),
      ),




      backgroundColor: screen ?  Colors.transparent : Theme.of(context).colorScheme.background,
      body: !screen ? SingleChildScrollView(
         child:
         Container(
          child: Column(
          children: [
          Container(
            width: double.infinity,
            child:
            Align( 
              alignment:  Alignment.topCenter,
              child: Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.spaceEvenly,

              children: [
              if (!checkTitle && (title != '' || definition != '' || images.length > 0 || division.length > 0)) Container(
                width: 670,
                constraints: BoxConstraints(minHeight: 640),
                margin:  EdgeInsets.only(bottom: 12, left: 12, right: 30, top: 50),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius:  BorderRadius.circular(10),
                      border: Border.all(color: AppColors.getColor('mono').grey),
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(4),
                        child: Text(
                          title ?? '',
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
                            if (division != null && division!.isNotEmpty)
                              ...division!.map((dvs) => Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                          padding: EdgeInsets.all(16),
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
                                          padding: EdgeInsets.all(16),
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
                              Container(), // Plac
                            if (images != null && images!.isNotEmpty)
                              ...images!.map((img) => Container(
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.getColor('mono').grey),
                                      color: Theme.of(context).colorScheme.background,
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.asset(img!,
                                      ),
                                    ),
                                  )).toList()
                            else 
                              Container(), // Placeholder for empty image field
                              
                            definition != '' ? Container(
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.getColor('mono').grey),
                                color: Theme.of(context).colorScheme.background
                                ),
                              padding: EdgeInsets.all(12),
                              child: Text(
                                definition ?? '',
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
                width: ((title != '' || definition != '' || images.length > 0) && !checkTitle) ? 600 : 800,
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(12),
                child: 
                  Container(
                    constraints: BoxConstraints(minHeight: 576,),
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           if(checkTitle)Container(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              title ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                            ),
                          ),
                          if(question != '') SizedBox(height: 30,) ,
                          question != '' ? Container(
                              padding: EdgeInsets.all(4),
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
                            if (!(title != '' || definition != '' || images.length > 0)) SizedBox(height: 20,),
                            subQuestion != '' ? Container(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                subQuestion,
                                style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                              ),
                            ) : Container(),
                            if (!(title != '' || definition != '' || images.length > 0)) SizedBox(height: 20,),
                            ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: (answersImage?.length ?? 0) + (answers?.length ?? 0) + (matchmaking?.length ?? 0),
                            itemBuilder: (BuildContext context, index) {
                              Widget? tile;
                              String? itemText;

                              if (pressed) {
                                if (correct!.any((item) => item["index"] == index)) {
                                  // Show the tile in green if index matches correct
                                  if (answersImage.length > 0 && index < answersImage!.length) {
                                    String? item = answersImage?[index];
                                    tile = reTileImage(AppColors.getColor('green').lighter, AppColors.getColor('green').main, index, item, context, correct: true);
                                    itemText = explanation!.length > 1 && explanation![index].isNotEmpty  ? explanation![index] : null;;
                                  } else if ((answers?.length ?? 0) > 1 && index - (answersImage?.length ?? 0) < (answers?.length ?? 0)) {
                                    String? item = answers?[(index - (answersImage?.length ?? 0))];
                                    tile = reTile(AppColors.getColor('green').lighter, AppColors.getColor('green').main, index, item, context, correct: true);
                                    itemText = explanation!.length > 1 && explanation![index - answersImage.length].isNotEmpty  ? explanation![index - answersImage.length] : null;
                                  } else  {
                                    String? item = matchmaking?[(index - (answersImage?.length ?? 0) + (answers?.length ?? 0))];
                                    List<dynamic> item2 = matches ?? [];

                                    if (_answer.any((answerItem) => answerItem.index == index) && correct!.any((correctItem) => _answer.any((answerItem) => answerItem.answer == correctItem["correct"] && answerItem.index == correctItem["index"] && answerItem.index == index))) {
                                      tile = reTileMatchmaking(AppColors.getColor('green').lighter, AppColors.getColor('green').main, correct!.firstWhere((item) => item["index"] == index)["correct"], index, item, context, item2, true);
                                    } else {
                                      tile = reTileMatchmaking(AppColors.getColor('red').lighter, AppColors.getColor('red').main, correct!.firstWhere((item) => item["index"] == index)["correct"], index, item, context, item2, false);
                                    }
                                    itemText = explanation!.length > 1 && explanation![index - answersImage.length].isNotEmpty  ? explanation![index - answersImage.length] : null;
                                  } 
                                  if (tile != null) {
                                    return Column(
                                      children: [
                                        tile,
                                        if(itemText != null) Container(
                                            margin: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: AppColors.getColor('primary').lighter,
                                            ),
                                            padding: EdgeInsets.all(12),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,  // aligns items to the top
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/lightbulbIcon.svg',  // Make sure to replace this with your SVG asset path
                                                  width: 30,  // Optional: You can adjust width & height as per your requirement
                                                  height: 30,
                                                ),
                                                SizedBox(width: 12),  // Give some spacing between the SVG and the text
                                                Expanded(  // To make sure the text takes the remaining available space and wraps if needed
                                                  child: Text(
                                                    itemText ?? '',
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
                                  }
                                } else if (correct!.any((item) => item["index"] != index) && _answer!.any((item) => item.index == index)) {
                                    if (answersImage.isNotEmpty && index < answersImage!.length) {
                                      String? item = answersImage?[index];
                                      tile = reTileImage(AppColors.getColor('mono').white, AppColors.getColor('red').main, index, item, context, correct: false);
                                      itemText = explanation!.length > 1 && explanation![index].isNotEmpty  ? explanation![index] : null;;
                                    } else if ((answers?.length ?? 0) > 1 && index - (answersImage?.length ?? 0) < (answers?.length ?? 0)) {
                                      String? item = answers?[(index - (answersImage?.length ?? 0))];
                                      tile =  reTile(AppColors.getColor('red').lighter, AppColors.getColor('red').main, index, item, context,correct: false);
                                      itemText = explanation!.length > 1 && explanation![index - answersImage.length].isNotEmpty  ? explanation![index - answersImage.length] : null;
                                    }
                                    if (tile != null) {
                                    return Column(
                                      children: [
                                        tile,
                                        if(itemText != null) Container(
                                            margin: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: AppColors.getColor('primary').lighter,
                                            ),
                                            padding: EdgeInsets.all(12),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,  // aligns items to the top
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/lightbulbIcon.svg',  // Make sure to replace this with your SVG asset path
                                                  width: 30,  // Optional: You can adjust width & height as per your requirement
                                                  height: 30,
                                                ),
                                                SizedBox(width: 12),  // Give some spacing between the SVG and the text
                                                Expanded(  // To make sure the text takes the remaining available space and wraps if needed
                                                  child: Text(
                                                    itemText ?? '',
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
                                  }
                                  } else {
                                    if (answersImage.isNotEmpty && index < answersImage!.length) {
                                      String? item = answersImage?[index];
                                      tile = reTileImage(AppColors.getColor('mono').white, AppColors.getColor('mono').lightGrey, index, item, context);
                                      itemText = explanation!.length > 1 && explanation![index - answersImage.length].isNotEmpty  ? explanation![index] : null;;
                                    } else if ((answers?.length ?? 0) > 1 && index - (answersImage?.length ?? 0) < (answers?.length ?? 0)) {
                                      String? item = answers?[(index - (answersImage?.length ?? 0))];
                                      tile =   reTile(AppColors.getColor('mono').white, AppColors.getColor('mono').lightGrey, index, item, context); 
                                      itemText = explanation!.length > 1 && explanation![index - answersImage.length].isNotEmpty  ? explanation![index - answersImage.length] : null;
                                    }
                                    if (tile != null) {
                                    return Column(
                                      children: [
                                        tile,
                                        if(itemText != null) Container(
                                            margin: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: AppColors.getColor('primary').lighter,
                                            ),
                                            padding: EdgeInsets.all(12),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,  // aligns items to the top
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/lightbulbIcon.svg',  // Make sure to replace this with your SVG asset path
                                                  width: 30,  // Optional: You can adjust width & height as per your requirement
                                                  height: 30,
                                                ),
                                                SizedBox(width: 12),  // Give some spacing between the SVG and the text
                                                Expanded(  // To make sure the text takes the remaining available space and wraps if needed
                                                  child: Text(
                                                    itemText ?? '',
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
                                  }
                                  }
                              } else {
                          // Show all items when boolPressed is false
                          if (answersImage.isNotEmpty && index < answersImage!.length) {
                            String? item = answersImage?[index];
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                            onTap: () {
                                setState(() {
                                  bool isSelected = _answer.any((e) => e.answer == index);
                                  if (!isSelected) {
                                    // If selected items are less than the limit, allow adding
                                      _answer.add(UserAnswerData(answer: index, index: index));
                                      print(_answer[0].answer);
                                      print(_answer[0].index);
                                  } else {
                                    // Always allow unchecking
                                    _answer.removeWhere((element) => element.answer == index);
                                  }
                                });
                              },
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: _answer.any((e) => e.answer == index)
                                        ? Border.all(color: Theme.of(context).primaryColor)
                                        : Border.all(color: AppColors.getColor('mono').lightGrey),
                                    color: _answer.any((e) => e.answer == index)
                                        ? AppColors.getColor('primary').lighter
                                        : AppColors.getColor('mono').white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      if (item != null && item.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: Image.asset(item, fit: BoxFit.cover),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            Text('${String.fromCharCode('a'.codeUnitAt(0) + index)})',
                                            style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: _answer.any((e) => e.index == index)
                                                    ? Theme.of(context).primaryColor
                                                    : Theme.of(context).colorScheme.onBackground,
                                              ),
                                          ),
                                            SizedBox(width: 32),
                                            Expanded(child: Text('Obrázok ${index + 1}.',
                                              style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: _answer.any((e) => e.index == index) == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground,
                                            ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )

                            );
                          } else if (answers.isNotEmpty && (index - answersImage.length) < answers!.length) {
                            String? item = answers[(index - answersImage.length)];
                          return  MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    bool isSelected = _answer.any((e) => e.answer == index);
                                    if (!isSelected) {
                                      // If selected items are less than the limit, allow adding
                                          _answer.add(UserAnswerData(answer: index, index: index));
                                    } else {
                                      // Allow toggling off
                                      _answer.removeWhere((element) => element.answer == index);
                                    }
                                  });
                                },
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Container(
                                    constraints: BoxConstraints(minHeight: 48),
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: _answer.any((e) => e.index == index)
                                          ? Border.all(color: Theme.of(context).primaryColor)
                                          : Border.all(color: AppColors.getColor('mono').lightGrey),
                                      color: _answer.any((e) => e.index == index)
                                          ? AppColors.getColor('primary').lighter
                                          : AppColors.getColor('mono').white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Text('${String.fromCharCode('a'.codeUnitAt(0) + index)})',
                                            style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: _answer.any((e) => e.index == index)
                                                    ? Theme.of(context).primaryColor
                                                    : Theme.of(context).colorScheme.onBackground,
                                              ),
                                          ),
                                          SizedBox(width: 32),
                                          Expanded(
                                            child: Text(
                                              item!,
                                              style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: _answer.any((e) => e.index == index)
                                                      ? Theme.of(context).primaryColor
                                                      : Theme.of(context).colorScheme.onBackground,
                                                ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );

                          } else if (matchmaking.isNotEmpty && matches.isNotEmpty && index - (answersImage.length) + ((answers.length)) < matchmaking.length) {
                            String? item = matchmaking[(index - (answersImage.length) - (answers.length))];
                            return Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.getColor('mono').lightGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(item!,
                                  style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                      InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (openDropdownIndex == index) {
                                            openDropdownIndex = null;
                                          } else {
                                            openDropdownIndex = index;
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(8),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: openDropdownIndex == index ? AppColors.getColor('primary').main : Colors.grey),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              _answer.any((e) => e.index == index)
                                                  ? matches[_answer.firstWhere((e) => e.index == index).answer!]
                                                  : 'Vybrať definíciu',
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: _answer.any((e) => e.index == index) == true
                                                    ? AppColors.getColor('primary').main
                                                    : Theme.of(context).colorScheme.onBackground,
                                              ),
                                            ),
                                            openDropdownIndex == index ? SvgPicture.asset(
                                                'assets/icons/upIcon.svg',  // Make sure to replace this with your SVG asset path
                                              ) :  SvgPicture.asset(
                                                'assets/icons/downIcon.svg',  // Make sure to replace this with your SVG asset path
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (openDropdownIndex == index) _buildDropdown(index, matches),
                                ],
                              ),
                            );
                        }
                        }
                        return Container(); // Placeholder for empty answer fields or non-matching tiles
                      }
                    ),
                    if(conclusion != '') Container(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
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
                        if(explanation!.length < 2 && pressed && explanation!.length > 0 )Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.getColor('primary').lighter,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,  // aligns items to the top
                            children: [
                              SvgPicture.asset(
                                'assets/icons/lightbulbIcon.svg',  // Make sure to replace this with your SVG asset path
                                width: 30,  // Optional: You can adjust width & height as per your requirement
                                height: 30,
                              ),
                              SizedBox(width: 12),  // Give some spacing between the SVG and the text
                              Expanded(  // To make sure the text takes the remaining available space and wraps if needed
                                child: Text(
                                  'Správna je odpoveď ${allCorrects ?? ''}: ${explanation?[0] ?? ''}',
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
                      )
                  ),
            ],
          ),
            )
              ),
              SizedBox(height: 50,),
              pressed ? ReButton(color: "green",  text: 'ĎALEJ',onTap:
                onNextButtonPressed,
              ) : ReButton(color: "green", isDisabled: _answer.length < 1 + (matchmaking.length > 0 ? matchmaking.length - 1 : 0) , text: 'HOTOVO', onTap:
                onAnswerPressed,
              ),
              SizedBox(height: 50,)
            ]
          )
      )
       ) : firstScreen ?
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
                  color: AppColors.getColor('primary').light
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
                  SizedBox(height: 20),
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
                  SizedBox(height: 10),
                  Container(width: 800 ,padding: EdgeInsets.all(8),
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
            Spacer(),
            ReButton(color: "green", text: 'POKRAČOVAŤ', onTap:
              () {
                setState(() {
                  screen = false;
                  firstScreen = false;
                });
              }
            ),
            SizedBox(height: 60),
          ],
        ))) :  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].name,
              style:  Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
            ),
            SizedBox(height: 30),
            Image.asset('assets/star.png', height: 100,),
            SizedBox(height: 10),
            Text(
              getResultBasedOnPercentage(widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].points, questionsPoint ?? 0),
              style:  Theme.of(context)
                .textTheme
                .headlineLarge!
                .copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
            ),
            
            SizedBox(height: 10),
            Text(
              "${widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].points}/${questionsPoint} správnych odpovedí | ${((widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].points / questionsPoint!) * 100).round()}%",
              style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "+${widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].points}",
                  style:  Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                ),
                SizedBox(width: 5),
                SvgPicture.asset('assets/icons/starYellowIcon.svg'),
              ],
            ),
            SizedBox(height: 20),
            ReButton(color: "white",  text: 'ZAVRIEŤ', onTap:
              () => widget.overlay(),
            ),
          ],
        )
      ),
      ]
    );
  }

  String getResultBasedOnPercentage(int value, int total) {
    double? percentage;
    
    if (total == 0 || value == 0) {
      percentage = 0;
    } else {
      percentage = (value / total) * 100;
    }


    if (percentage >= 90 && percentage <= 100) {
      return 'Výborný výsledok!';
    } else if (percentage >= 75 && percentage < 90) {
      return 'Chválitebný výsledok!';
    } else if (percentage >= 50 && percentage < 75) {
      return 'Dobrý výsledok!';
    } else if (percentage >= 30 && percentage < 50) {
      return 'Dostatočný výsledok!';
    } else if (percentage >= 0 && percentage < 30) {
      return 'Nedostatočný výsledok!';
    } else {
      return '';
    }
  }


  Widget _buildDropdown(int index, List<dynamic> matches) {
    return Material(
      elevation: 5,
        borderRadius: BorderRadius.circular(10),
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        itemCount: matches.length,
        shrinkWrap: true,
        itemBuilder: (context, idx) {
          return ListTile(
            title: Text(matches[idx],
            style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(
                color: _answer.any((e) => e.index == index) == true ? AppColors.getColor('primary').main : Theme.of(context).colorScheme.onBackground,
              ),
            ),
            onTap: () {
              // Handle selection here
              setState(() {
                openDropdownIndex = null;

                if (_answer.length > 0) {
                  bool exists = _answer.any((element) => element.index == index);
                  if (!exists) {
                    _answer.add(UserAnswerData(answer: idx, index: index));
                  } else {
                    _answer.removeWhere((element) => element.index == index);
                    _answer.add(UserAnswerData(answer: idx, index: index));
                  }
                } else {
                  _answer.add(UserAnswerData(answer: idx, index: index));
                }

              });
            },
          );
        },
      ),
    )
    );
  }

  int countTrueValues(List<UserQuestionsData>? questionList) {
    int count = 0;
    if (questionList != null) {
      for (UserQuestionsData question in questionList) {
        if (question.completed == true) {
          count++;
        }
      }
    }
    return count;
}



// Define a utility function for firstWhereOrNull behavior
dynamic firstWhereOrNull(List<dynamic> list, bool Function(dynamic) test) {
    for (dynamic element in list) {
        if (test(element)) return element;
    }
    return null;
}

  void onAnswerPressed() {
    if (_answer.length > 0) {
      setState(() {
       double partialPoints = 1.00 / widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions[questionIndex].correct.length;

    // Initialize points to 0 for this specific run
    double points = 0.0;

   List<bool> correctnessList = List<bool>.filled(correct.length, false);

      for (var userAnswer in _answer) {
        // Try to find a matching correct answer based on index
        dynamic matchingCorrectItem;

          try {
              matchingCorrectItem = correct.firstWhere((c) => c["index"] == userAnswer.index);
          } catch (e) {
              matchingCorrectItem = null;
          }


        // If found and answers match, update points and correctnessList
        if (matchingCorrectItem != null && userAnswer.answer == matchingCorrectItem["correct"]) {
          int correctListIndex = correct.indexOf(matchingCorrectItem);
          if (correctListIndex != -1 && correctListIndex < correctnessList.length) {
            correctnessList[correctListIndex] = true;
          }
          points += partialPoints;
        } else {
          points -= partialPoints;
        }
      }


    for (int i = 0; i < correct.length; i++) {
        if (!_answer.any((item) => item.index == correct[i]["index"])) {
            points -= partialPoints; // Decrement points by partialPoints for every missing answer
        }
    }

    // Update the user's data
    widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions[questionIndex].correct = correctnessList;

    // Check if points are negative and if so, reset them to 0
    if (points < 0) {
        points = 0.0;
    }
      updateResults(widget.resultsId, int.parse(widget.capitolsId), widget.testIndex, questionIndex, _answer, points.round());


    // Update points, round it as per your instructions
    widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].points += points.round();
    widget.userData!.points += points.round();
        if (widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions.length - 1 == countTrueValues(widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions)) {
          updateResultsTest(widget.resultsId, int.parse(widget.capitolsId), widget.testIndex);
          widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].completed = true;
          sendCompleteEvent();
        } 

        widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions[questionIndex].completed = true;
        widget.userData!.capitols[int.parse(widget.capitolsId)].tests[widget.testIndex].questions[questionIndex].answer = _answer;

        if (areAllCompleted(widget.userData!)) {
          widget.userData!.capitols[int.parse(widget.capitolsId)].completed = true;
          updateResultsCapitol(widget.resultsId, int.parse(widget.capitolsId));
        }
        
        _answer = _answer;
        pressed = true;

      });
      saveUserDataToFirestore(widget.userData!);
    }
  }

  void onNextButtonPressed() {
    if (questionIndex + 1 < (questionsPoint ?? 0)) {
      setState(() {
        questionIndex++;
        pressed = false;
        _answer = [];
        checkTitle = false;
      });
    saveUserDataToFirestore(widget.userData!);

      fetchQuestionData(questionIndex);
    } else {

 
      setState(() {
        questionIndex = 0;
        _answer = [];
        pressed = false;
        checkTitle = false;
      });
      saveUserDataToFirestore(widget.userData!);
    
      _showscreen();
    }
  }


  void _showscreen() {
    setState(() {
      // Update the state to show the last screen
      screen = true;
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

  Future<void> saveUserDataToFirestore(UserData userData) async {
    try {
      // Reference to the user document in Firestore
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

      // Convert userData object to a Map
      Map<String, dynamic> userDataMap = {
        'discussionPoints': userData.discussionPoints,
        'weeklyDiscussionPoints': userData.weeklyDiscussionPoints,
        'admin': userData.admin,
        'teacher': userData.teacher,
        'signed': userData.signed,
        'email': userData.email,
        'name': userData.name,
        'active': userData.active,
        'schoolClass': userData.schoolClass,
        'points': userData.points,
        'capitols': userData.capitols.map((userCapitolsData) {
          return {
            'id': userCapitolsData.id,
            'name': userCapitolsData.name,
            'image': userCapitolsData.image,
            'completed': userCapitolsData.completed,
            'tests': userCapitolsData.tests.map((userCapitolsTestData) {
              return {
                'name': userCapitolsTestData.name,
                'completed': userCapitolsTestData.completed,
                'points': userCapitolsTestData.points,
                'questions': userCapitolsTestData.questions.map((userQuestionsData) {
                  return {
                    'answer': userQuestionsData.answer.map((userAnswerData) {
                      return {
                        'answer': userAnswerData.answer,
                        'index': userAnswerData.index
                        };
                    }).toList(),
                    'completed': userQuestionsData.completed,
                    'correct': userQuestionsData.correct,
                  };
                }).toList(),
              };
            }).toList(),
          };
        }).toList(),
      };

      // Update the user document in Firestore with the new userDataMap
      await userRef.update(userDataMap);
    } catch (e) {
      print('Error saving user data to Firestore: $e');
      rethrow;
    }
  }
}
