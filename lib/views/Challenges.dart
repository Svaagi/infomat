
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/controllers/ResultsController.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/views/tests/DesktopTest.dart';
import 'package:infomat/views/tests/TeacherDesktopTest.dart';
import 'package:infomat/views/tests/MobileTest.dart';
import 'package:infomat/views/tests/TeacherMobileTest.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/widgets/TeacherCapitolDragWidget.dart';
import 'package:infomat/widgets/StudentCapitolDragWidget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:html' as html;
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/ResultsModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';

class Challenges extends StatefulWidget {
  final UserData? currentUserData;
  final int weeklyCapitolIndex;
  final int weeklyTestIndex;
  final int weeklyChallenge;

  const Challenges({Key? key, required this.currentUserData, required this.weeklyCapitolIndex, required this.weeklyTestIndex, required this.weeklyChallenge});

  @override
  State<Challenges> createState() => _ChallengesState();
}





class _ChallengesState extends State<Challenges> {
  bool _loading = true;
  bool isOverlayVisible = false;
  late OverlayEntry overlayEntry;
  int _visibleContainerTest = -1;
  int _visibleContainerCapitol = -1;
  Future<List<dynamic>>? _dataFuture;
  List<int> capitolsIds = [];
  bool isMobile = false;
  bool isDesktop = false;
  List<dynamic> data = [];
  final PageController _pageController = PageController();
  List<ResultCapitolsData>? currentResults;
  int studentsSum = 0;
  String resultsId = '';
  final ScrollController _scrollController = ScrollController();

  double percentage(int capitolIndex, int testIndex) {
    if (currentResults![capitolIndex].tests[testIndex].points == 0 || studentsSum == 0) return 0;
    return  currentResults![capitolIndex].tests[testIndex].points/(studentsSum*widget.currentUserData!.capitols[capitolIndex].tests[testIndex].questions.length);
  }

  bool isBehind(int globalIndex, int weeklyChallenge) {
    if (globalIndex <= weeklyChallenge) {
      return true;
    } else {
      return false;
    }
  }

  void scrollUp() {
    final currentScroll = _scrollController.offset;
    final scrollPosition = (currentScroll - 150).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      scrollPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> sendChallengeEvent() async {
    await analytics.logEvent(
      name: 'výzvy',
      parameters: {
        'page': 'výzvy', // replace with your actual page/screen name
      },
    );
  }

  @override
  void initState() {
    super.initState();

    sendChallengeEvent();

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    isMobile = userAgent.contains('mobile');
    isDesktop = userAgent.contains('macintosh') ||
        userAgent.contains('windows') ||
        userAgent.contains('linux');

     _dataFuture = fetchQuestionData();
  }

Future<void> refreshList() async {
  setState(() {
    _dataFuture = fetchQuestionData();
  });

  await _dataFuture;
}


  Future<void> refreshData() async {
    await _dataFuture;
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  void toggleIndex(int index, int capitolIndex) {
    setState(() {
       _visibleContainerTest = index;
       _visibleContainerCapitol = capitolIndex;
    });
}

  void toggleOverlayVisibility(int index, int capitolId, bool isPressed) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
    });

    if (isOverlayVisible) {
      overlayEntry = createOverlayEntry(context, index, capitolId, isPressed);
      Overlay.of(context).insert(overlayEntry);
    } else {
      overlayEntry.remove();
    }
  }

  int countTrueTests(List<UserCapitolsTestData>? boolList) {
    int count = 0;
    if (boolList != null) {
      for (UserCapitolsTestData testData in boolList) {
        if (testData.completed) {
          count++;
        }
      }
    }
    return count;
  }

  void toggle() {
    refreshData();
    overlayEntry.remove();
    isOverlayVisible = false;
  }


Future<ClassData> fetchCurrentUserClass() async {
  // Assuming you know how to retrieve the currentUser's classId
  String currentUserClassId = widget.currentUserData!.schoolClass;
  return await fetchClass(currentUserClassId);
  
}

Future<List<dynamic>> fetchQuestionData() async {
  List<dynamic> localResults = [];
  List<UserData> userDataList = [];

  try {
    ClassData currentUserClass = await fetchCurrentUserClass();
    currentResults = await fetchResults(currentUserClass.results);

    for (String userId in currentUserClass.students) {
      UserData userData = await fetchUser(userId);
      userDataList.add(userData);
    }

    setState(() {
      resultsId = currentUserClass.results;
      studentsSum = currentUserClass.students.length;
    });

    capitolsIds = currentUserClass.capitolOrder;

    String jsonData = await rootBundle.loadString('assets/CapitolsData.json');
    data = json.decode(jsonData);
    

    for (int order in [0,1,2,3,4]) {
      localResults.add(data[order]);
    }

    setState(() {
      _loading = false;
    });

  } catch (e) {
    print('Error fetching question data: $e');
  }

  return localResults;
}

  double computeOffset(double width) {
    return (0.09 * 500) / width;
  }

  OverlayEntry createOverlayEntry(BuildContext context, int testIndex, int capitolId, bool isPressed) {
    return OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            alignment: Alignment.center,
            child: isMobile ? widget.currentUserData!.teacher ?  TeacherMobileTest(testIndex: testIndex, overlay: toggle, capitolsId: capitolId.toString(), usersCompleted: percentage(capitolId, testIndex) != 0, studentsSum: studentsSum,  results: currentResults![capitolId].tests[testIndex], userData: widget.currentUserData) :  MobileTest(resultsId: resultsId,testIndex: testIndex,data: data , overlay: toggle, capitolsId: capitolId.toString(), userData: widget.currentUserData) : widget.currentUserData!.teacher ?
              TeacherDesktopTest(testIndex: testIndex, overlay: toggle, capitolsId: capitolId.toString(), usersCompleted: percentage(capitolId, testIndex) != 0, studentsSum: studentsSum,  results: currentResults![capitolId].tests[testIndex], userData: widget.currentUserData)
               : DesktopTest(resultsId:  resultsId,testIndex: testIndex, overlay: toggle, capitolsId: capitolId.toString(), userData: widget.currentUserData, data: data, isPressed: isPressed,),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  if (_loading) {
      return Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
  }
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.background,
    body: Column(
            children: <Widget>[
              
              // Your FractionallySizedBox here (not modified for brevity)
              MediaQuery.of(context).size.width < 1000 ?
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      // First page - ListView
                      Column(
                        children: [
                          FractionallySizedBox(
                            widthFactor: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 30,),
                                      const Spacer(),
                                      Text(
                                        data[0]["name"],
                                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () => _onNavigationItemSelected(1), 
                                        icon: SvgPicture.asset('assets/icons/arrowRightIcon.svg', color: Colors.white,
                                      ))
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 10,
                                    child: LinearProgressIndicator(
                                      value: countTrueTests(
                                                  widget.currentUserData!.capitols[capitolsIds[0]].tests) /
                                              widget.currentUserData!.capitols[capitolsIds[0]].tests.length,
                                      backgroundColor: AppColors.getColor('blue').lighter,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.getColor('green').main),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                            itemCount: 32 + 5, // Add 1 for the dummy item
                            itemBuilder: (BuildContext context, int globalIndex) {
                              if (globalIndex == 0) {
                                // This is the dummy item, you can control its height
                                return SizedBox(height: 150.0); // Adjust the height as needed
                              } else if (globalIndex == 34) {
                                return SizedBox(height: 100.0);
                              }
                            int? capitolIndex;
                            int? testIndex;

                            int prevTestsSum = 0;
                            for (int i = 0; i < capitolsIds.length; i++) {
                              int currentCapitolId = capitolsIds[i]; // make sure to get the id correctly
                              int currentCapitolTestCount = data[currentCapitolId]["tests"].length;

                              if (globalIndex - 1 < (prevTestsSum + currentCapitolTestCount)) {
                                capitolIndex = currentCapitolId;
                                testIndex = globalIndex - 1 - prevTestsSum;
                                break;
                              } else {
                                prevTestsSum += currentCapitolTestCount;
                              }
                            }

                            if (capitolIndex == null || testIndex == null) return Container();  // Handle error

                            EdgeInsets padding = EdgeInsets.only(
                              left: (testIndex + prevTestsSum) % 2 == 0 || (testIndex + prevTestsSum) == 0 ? 0.0 : 85.0,
                              right: (testIndex + prevTestsSum) % 2 == 0 || (testIndex + prevTestsSum) == 0 ? 85.0 : 0.0,
                            );
                            return Column(
                              children: [
                                Container(
                                  padding: padding,
                                  height: 118,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      OverflowBox(
                                        maxHeight: double.infinity,
                                        child: (testIndex + prevTestsSum) % 2 == 0 || (testIndex + prevTestsSum) == 0
                                            ? (!widget.currentUserData!.teacher ? !(widget.currentUserData?.capitols[capitolIndex].tests[testIndex].completed ?? false) : !(percentage(capitolIndex, testIndex) == 1.0))
                                                ? (!isBehind(globalIndex, widget.weeklyChallenge)) ? SvgPicture.asset('assets/roadmap/leftRoad.svg') : SvgPicture.asset('assets/roadmap/leftRoad.svg', color: AppColors.getColor('red').lighter)
                                                : SvgPicture.asset('assets/roadmap/leftRoadFilled.svg')
                                            : (!widget.currentUserData!.teacher ? !(widget.currentUserData?.capitols[capitolIndex].tests[testIndex].completed ?? false) : !(percentage(capitolIndex, testIndex) == 1.0))
                                                ? (!isBehind(globalIndex, widget.weeklyChallenge)) ? SvgPicture.asset('assets/roadmap/rightRoad.svg') :SvgPicture.asset('assets/roadmap/rightRoad.svg', color: AppColors.getColor('red').lighter)
                                                : SvgPicture.asset('assets/roadmap/rightRoadFilled.svg'),
                                      ),
                                      OverflowBox(
                                        alignment: Alignment.center,
                                        maxHeight: double.infinity,
                                        child: Container(
                                          height: 170,
                                          padding: EdgeInsets.only(
                                            bottom: 30,
                                            right: (testIndex + prevTestsSum) % 2 == 0 ? 18 : 0,
                                            left: (testIndex + prevTestsSum) % 2 == 0 ? 0 : 18,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              testIndex == _visibleContainerTest && capitolIndex == _visibleContainerCapitol
                                                  ? Container(
                                                      width: 170.0,
                                                      height: 170.0,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: (!widget.currentUserData!.teacher ? !(widget.currentUserData?.capitols[capitolIndex].tests[testIndex].completed ?? false) : !(percentage(capitolIndex, testIndex) == 1.0))
                                                            ? AppColors.getColor( 'blue').lighter
                                                            : AppColors.getColor('yellow').lighter,
                                                      ),
                                                    )
                                                  : Container(),
                                              StarButton(
                                                globalIndex: globalIndex,
                                                weeklyChallenge: widget.weeklyChallenge,
                                                number: testIndex,
                                                userData: widget.currentUserData,
                                                onPressed: (int number, bool pressed) => toggleOverlayVisibility(number, capitolIndex ?? 0, pressed),
                                                capitolsId: capitolIndex.toString(),
                                                visibleContainerIndex: (int number) => toggleIndex(number, capitolIndex ?? 0),
                                                percentage: percentage,
                                                weeklyCapitolIndex: widget.weeklyCapitolIndex,
                                                weeklyTestIndex: widget.weeklyTestIndex,
                                                isBehind: isBehind,
                                                scrollUp: scrollUp,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                          )
                        
                        ],
                      ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: widget.currentUserData!.teacher ? TeacherCapitolDragWidget(results: currentResults,studentsSum: studentsSum ,currentUserData: widget.currentUserData, numbers: capitolsIds, refreshData: refreshList, percentage: percentage, weeklyCapitolIndex: widget.weeklyCapitolIndex, weeklyTestIndex: widget.weeklyTestIndex,) : StudentCapitolDragWidget(currentUserData: widget.currentUserData, numbers: capitolsIds, refreshData: refreshList, weeklyCapitolIndex: widget.weeklyCapitolIndex, weeklyTestIndex: widget.weeklyTestIndex,),
                        ),
                    ],
                  ),
                ) : Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                            itemCount: 32 + 5, // Add 1 for the dummy item
                            itemBuilder: (BuildContext context, int globalIndex) {
                              if (globalIndex == 0) {
                                // This is the dummy item, you can control its height
                                return SizedBox(height: 150.0); // Adjust the height as needed
                              } else if (globalIndex == 34) {
                                return SizedBox(height: 100.0);
                              }
                            int? capitolIndex;
                            int? testIndex;

                            int prevTestsSum = 0;
                            for (int i = 0; i < capitolsIds.length; i++) {
                              int currentCapitolId = capitolsIds[i]; // make sure to get the id correctly
                              int currentCapitolTestCount = data[currentCapitolId]["tests"].length;

                              if (globalIndex - 1 < (prevTestsSum + currentCapitolTestCount)) {
                                capitolIndex = currentCapitolId;
                                testIndex = globalIndex - 1 - prevTestsSum;
                                break;
                              } else {
                                prevTestsSum += currentCapitolTestCount;
                              }
                            }

                            if (capitolIndex == null || testIndex == null) return Container();  // Handle error

                            EdgeInsets padding = EdgeInsets.only(
                              left: (testIndex + prevTestsSum) % 2 == 0 || (testIndex + prevTestsSum) == 0 ? 0.0 : 85.0,
                              right: (testIndex + prevTestsSum) % 2 == 0 || (testIndex + prevTestsSum) == 0 ? 85.0 : 0.0,
                            );
                            return Column(
                              children: [
                                Container(
                                  padding: padding,
                                  height: 118,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      OverflowBox(
                                        maxHeight: double.infinity,
                                        child: (testIndex + prevTestsSum) % 2 == 0 || (testIndex + prevTestsSum) == 0
                                            ? (!widget.currentUserData!.teacher ? !(widget.currentUserData?.capitols[capitolIndex].tests[testIndex].completed ?? false) : !(percentage(capitolIndex, testIndex) == 1.0))
                                                ? (!isBehind(globalIndex, widget.weeklyChallenge)) ? SvgPicture.asset('assets/roadmap/leftRoad.svg') : SvgPicture.asset('assets/roadmap/leftRoad.svg', color: AppColors.getColor('red').lighter)
                                                : SvgPicture.asset('assets/roadmap/leftRoadFilled.svg')
                                            : (!widget.currentUserData!.teacher ? !(widget.currentUserData?.capitols[capitolIndex].tests[testIndex].completed ?? false) : !(percentage(capitolIndex, testIndex) == 1.0))
                                                ? (!isBehind(globalIndex, widget.weeklyChallenge)) ? SvgPicture.asset('assets/roadmap/rightRoad.svg') :SvgPicture.asset('assets/roadmap/rightRoad.svg', color: AppColors.getColor('red').lighter)
                                                : SvgPicture.asset('assets/roadmap/rightRoadFilled.svg'),
                                      ),
                                      OverflowBox(
                                        alignment: Alignment.center,
                                        maxHeight: double.infinity,
                                        child: Container(
                                          height: 170,
                                          padding: EdgeInsets.only(
                                            bottom: 30,
                                            right: (testIndex + prevTestsSum) % 2 == 0 ? 18 : 0,
                                            left: (testIndex + prevTestsSum) % 2 == 0 ? 0 : 18,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              testIndex == _visibleContainerTest && capitolIndex == _visibleContainerCapitol
                                                  ? Container(
                                                      width: 170.0,
                                                      height: 170.0,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: (!widget.currentUserData!.teacher ? !(widget.currentUserData?.capitols[capitolIndex].tests[testIndex].completed ?? false) : !(percentage(capitolIndex, testIndex) == 1.0))
                                                            ? AppColors.getColor( 'blue').lighter
                                                            : AppColors.getColor('yellow').lighter,
                                                      ),
                                                    )
                                                  : Container(),
                                              StarButton(
                                                globalIndex: globalIndex,
                                                weeklyChallenge: widget.weeklyChallenge,
                                                number: testIndex,
                                                userData: widget.currentUserData,
                                                onPressed: (int number, bool pressed) => toggleOverlayVisibility(number, capitolIndex ?? 0, pressed),
                                                capitolsId: capitolIndex.toString(),
                                                visibleContainerIndex: (int number) => toggleIndex(number, capitolIndex ?? 0),
                                                percentage: percentage,
                                                weeklyCapitolIndex: widget.weeklyCapitolIndex,
                                                weeklyTestIndex: widget.weeklyTestIndex,
                                                isBehind: isBehind,
                                                scrollUp: scrollUp,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      
                      if(MediaQuery.of(context).size.width > 1000) SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width / 2,
                        child: widget.currentUserData!.teacher ? TeacherCapitolDragWidget(results:currentResults,studentsSum: studentsSum ,currentUserData:  widget.currentUserData, numbers: capitolsIds, refreshData: refreshList, percentage: percentage, weeklyCapitolIndex: widget.weeklyCapitolIndex, weeklyTestIndex: widget.weeklyTestIndex,) : StudentCapitolDragWidget(currentUserData: widget.currentUserData, numbers: capitolsIds, refreshData: refreshList, weeklyCapitolIndex: widget.weeklyCapitolIndex, weeklyTestIndex: widget.weeklyTestIndex,),
                      ),
                    ],
                  ),
                ),
            ],
          )
          );
      }
}



class StarButton extends StatelessWidget {
  final int globalIndex;
  final int weeklyChallenge;
  final int number;
  final UserData? userData;
  final void Function(int, bool) onPressed;
  final String capitolsId;
  final void Function(int) visibleContainerIndex;
  double Function(int, int) percentage;
  int weeklyCapitolIndex; 
  int weeklyTestIndex;
  bool Function(int, int) isBehind;
  void Function() scrollUp;

  StarButton({
    required this.globalIndex,
    required this.weeklyChallenge,
    required this.number,
    required this.onPressed,
    required this.capitolsId,
    this.userData,
    required this.visibleContainerIndex,
    required this.percentage,
    required this.weeklyCapitolIndex,
    required this.weeklyTestIndex,
    required this.isBehind,
    required this.scrollUp
  });

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


  @override
Widget build(BuildContext context) {
  return SizedBox(
    child: 
    userData != null &&
      (userData!.teacher ? percentage(int.parse(capitolsId) , number) != 1.0 : !userData!.capitols[int.parse(capitolsId)].tests[number].completed)
        ? 
      (!isBehind(globalIndex, weeklyChallenge)) ?

         Stack(
          alignment: Alignment.center,
            children: [
              OverflowBox(
                  child:Container(
                width: double.infinity,
                height: 98.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              ),
              OverflowBox(
                  child:Container(
                width: double.infinity,
                height: 87.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.getColor('mono').lightGrey,
                ),
              ),
              ),
              OverflowBox(
                  child: CircularPercentIndicator(
                    radius: 45.0,  // Adjust as needed
                    lineWidth: 8.0,
                    animation: true,
                    percent: userData!.teacher ? percentage(int.parse(capitolsId) , number) : countTrueValues(userData!.capitols[int.parse(capitolsId)].tests[number].questions) /
                            userData!.capitols[int.parse(capitolsId)].tests[number].questions.length,
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: AppColors.getColor('yellow').light,
                    backgroundColor: Colors.transparent,
                )
               ),
               
              Container(
                width: 76.0,
                height: 76.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.getColor('mono').white,
                ),
                child: GestureDetector(
                 onTap: () {
                    final RenderBox button = context.findRenderObject() as RenderBox;
                    if (userData!.teacher) {
                      showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 6, scrollUp);
                    } else if (int.parse(capitolsId)  == weeklyCapitolIndex && number == weeklyTestIndex && countTrueValues(userData!.capitols[int.parse(capitolsId)].tests[number].questions) == 0) {
                      showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 1, scrollUp);
                    } 
                    else if (int.parse(capitolsId)  == weeklyCapitolIndex && number == weeklyTestIndex && countTrueValues(userData!.capitols[int.parse(capitolsId)].tests[number].questions) > 0) {
                      showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 2, scrollUp);
                    }  else {
                      showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 0, scrollUp);
                    }
                    visibleContainerIndex(number);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Center(
                      child: (userData!.teacher ? (percentage(int.parse(capitolsId) , number) > 0.0) : (countTrueValues(userData!.capitols[int.parse(capitolsId)].tests[number].questions) > 0)) ? SvgPicture.asset('assets/icons/starYellowIcon.svg', height: 30,) : SvgPicture.asset('assets/icons/starGreyIcon.svg', height: 30,),
                    ),
                  ),
                ),
              ),
            ],
          )
        : Stack(
          alignment: Alignment.center,
          children: [
            OverflowBox(
              child:Container(
                width: double.infinity, 
                  height: 98.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ), 
              Container(
                child: GestureDetector(
                onTap: () {
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  if (userData!.teacher) {
                    showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 6, scrollUp);
                  } else {
                    showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 5, scrollUp);
                  }
                  visibleContainerIndex(number);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Image.asset(
                    'assets/failedStar.png',
                    width: 90.0,
                    height: 90.0,
                  ),
                ),
              ),
          ),
        ]
      ) :
        Stack(
          alignment: Alignment.center,
          children: [
            OverflowBox(
              child:Container(
                width: double.infinity, 
                  height: 98.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ), 
              Container(
                child: GestureDetector(
                onTap: () {
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  if (userData!.teacher) {
                    showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 6, scrollUp);
                  } else if (userData!.capitols[int.parse(capitolsId)].completed) {
                    showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 4, scrollUp);
                  } else {
                    showPopupMenu(context, number % 2 == 0 ? 0 : 1, button, 4, scrollUp);
                  }
                  visibleContainerIndex(number);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Image.asset(
                    'assets/star.png',
                    width: 90.0,
                    height: 90.0,
                  ),
                ),
              ),
          ),
        ]
      )
  );
}



void showPopupMenu(BuildContext context, int direction, RenderBox button, int columnId, Function() scrollUp) {
  final double menuWidth = 400.0; // Set your desired menu width
  final double menuHeight = 200.0; // Set your desired menu height

  // Calculate the position of the button on the screen
  final Offset buttonPosition = button.localToGlobal(Offset.zero);

  double offsetX = buttonPosition.dx + button.size.width / 2 - menuWidth / 2;
  double offsetY = buttonPosition.dy + button.size.height + 10; // Adjust vertical position as needed


  // Check if Y-coordinate of the button is lower than 200 and call scrollUp if it is

  if (buttonPosition.dy > 600) {
    scrollUp();
  }

  final RelativeRect position = RelativeRect.fromLTRB(
    offsetX,
    offsetY,
    offsetX + menuWidth,
    offsetY + menuHeight,
  );
         Widget _buildSwitchableColumn(int index) {
        switch (index) {
          case 0:
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/lockIcon.svg', color: Colors.white,),
                      SizedBox(width: 4,),
                      Text(
                        userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                        overflow: TextOverflow.ellipsis, // Add this
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                  
                    const SizedBox(height: 10),
                   Text(
                      'Táto výzva je nateraz zamknutá',
                      overflow: TextOverflow.ellipsis, // Add this
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                ],
              );
          case 1:
            return  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Týždenná výzva',
                        overflow: TextOverflow.ellipsis, // Add this
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const Spacer(),
                      if(userData!.teacher)SvgPicture.asset('assets/icons/correctIcon.svg', color: Colors.white,)
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                    overflow: TextOverflow.ellipsis, // Add this
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                    const SizedBox(height: 10),
                  Center(
                      child: SizedBox(
                        width: 300,
                        child: ReButton( color: 'white', text: 'ZAČAŤ' , onTap: () {
                          onPressed(number, false);
                          Navigator.of(context).pop();
                        }),
                      )
                  ),
                ],
              );
              case 2:
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Týždenná výzva',
                        overflow: TextOverflow.ellipsis, // Add this
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const Spacer(),
                      if(userData!.teacher)SvgPicture.asset('assets/icons/correctIcon.svg', color: Colors.white,)
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                    overflow: TextOverflow.ellipsis, // Add this
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                    const SizedBox(height: 10),
                  Center(
                      child: SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            onPressed(number, false);
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
 // Replace with your desired icon
                              Text(
                                'POKRAČOVAŤ',
                                style: TextStyle(
                                  color:  AppColors.getColor("mono").white,
                                  fontFamily: GoogleFonts.inter(fontWeight: FontWeight.w500).fontFamily
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0), // Set elevation to 0 for a flat appearance
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.disabled)) {
                                return AppColors.getColor("mono").lightGrey;
                              } else if (states.contains(MaterialState.pressed)) {
                                return  Color(0xff4689d6);
                              } else if (states.contains(MaterialState.hovered)) {
                                return Color(0xff4689d6);
                              } else {
                                return Color(0xff4689d6);
                              }
                            }),
                            side: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                AppColors.getColor('blue').lighter;
                              } else {
                                return BorderSide.none;
                              }
                            }),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              );
          case 3:
            return  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Týždenná výzva',
                        overflow: TextOverflow.ellipsis, // Add this
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const Spacer(),
                      if(userData!.teacher)SvgPicture.asset('assets/icons/correctIcon.svg', color: Colors.white,)
                    ],
                  ),
                  
                  const SizedBox(height: 5),
                  Text(
                    userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                    overflow: TextOverflow.ellipsis, // Add this
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: 400,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.getColor( 'blue').main,
                      ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hotovo!",
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ), // Set text color to white
                        ),
                        Text(
                          "${userData!.capitols[int.parse(capitolsId)].tests[number].points}/${userData!.capitols[int.parse(capitolsId)].tests[number].questions.length} správnych odpovedí",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ), // Set text color to white
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "+ ${userData!.capitols[int.parse(capitolsId)].tests[number].points}",
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
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Center(
                    child: Text(
                      "Test si môžeš znovu otvoriť po skončení kapitoly",
                      style:  Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                   ),
                  ),
                  
                ],
              );
          case 4:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                          overflow: TextOverflow.ellipsis, // Add this
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${userData!.capitols[int.parse(capitolsId)].tests[number].points}/${userData!.capitols[int.parse(capitolsId)].tests[number].questions.length} správnych odpovedí',
                          overflow: TextOverflow.ellipsis, // Add this
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "+ ${userData!.capitols[int.parse(capitolsId)].tests[number].points}",
                          style:  Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        ),
                        SizedBox(width: 5),
                        SvgPicture.asset('assets/icons/starYellowIcon.svg'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                 Center(
                      child: SizedBox(
                        width: 300,
                        child: ReButton( color: 'blue', text: 'ZOBRAZIŤ TEST' , onTap: () {
                          onPressed(number, false);
                          Navigator.of(context).pop();
                        }),
                      )
                  ),
                
              ],
            );
          case 5:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                          overflow: TextOverflow.ellipsis, // Add this
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset('assets/icons/smallErrorIcon.svg', color: Colors.white),
                            SizedBox(width: 2,),
                            Text(
                              'Túto výzvu si nestihol urobiť.',
                              overflow: TextOverflow.ellipsis, // Add this
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${userData!.capitols[int.parse(capitolsId)].tests[number].points}/${userData!.capitols[int.parse(capitolsId)].tests[number].questions.length}",
                          style:  Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        ),
                        SizedBox(width: 5),
                        SvgPicture.asset('assets/icons/starYellowIcon.svg'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                 Center(
                      child: SizedBox(
                        width: 300,
                        child: ReButton( color: 'blue', text: 'ZOBRAZIŤ TEST' , onTap: () {
                          onPressed(number, true);
                          Navigator.of(context).pop();
                        }),
                      )
                  ),
                
              ],
            );
            case 6:
            return  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Týždenná výzva',
                        overflow: TextOverflow.ellipsis, // Add this
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const Spacer(),
                      if(userData!.teacher)SvgPicture.asset('assets/icons/correctIcon.svg', color: Colors.white,)
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                    overflow: TextOverflow.ellipsis, // Add this
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                    const SizedBox(height: 10),
                  Center(
                      child: SizedBox(
                        width: 300,
                        child: ReButton( color: 'white', text: 'ZOBRAZIŤ' , onTap: () {
                          onPressed(number, false);
                          Navigator.of(context).pop();
                        }),
                      )
                  ),
                ],
              );
          default:
            return  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Týždenná výzva',
                      overflow: TextOverflow.ellipsis, // Add this
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const Spacer(),
                    if(userData!.teacher)SvgPicture.asset('assets/icons/correctIcon.svg', color: Colors.white,)
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  userData?.capitols[int.parse(capitolsId)].tests[number].name ?? '',
                  overflow: TextOverflow.ellipsis, // Add this
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimary),
                ),
               Center(
                  child: ReButton(color: "white",  text:  'ZOBRAZIŤ', onTap: () {
                    onPressed(number, false);
                    Navigator.of(context).pop();
                  }),
                ),
              ],
            );
        }
      }

  showMenu<int>(
    context: context,
    position: position,
    constraints: BoxConstraints(maxWidth: 400, minWidth: 0),

    color: AppColors.getColor('blue').light,
    shape: TooltipShape(context: context, direction: direction % 2 == 0 ? 0 : 1),
    items: <PopupMenuEntry<int>>[
      PopupMenuItem<int>(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 450), // Using constraints instead of a fixed width
              child: Column(
                children: [
                  _buildSwitchableColumn(columnId)
                ],
              ) 
              
            ),
          ),
        ]
      ).then((_) => visibleContainerIndex(-1));
    }
}




class TooltipShape extends ShapeBorder {
  final int direction;
  final BuildContext context;

  const TooltipShape({required this.direction, required this.context});

  final BorderSide _side = BorderSide.none;
  final double _borderRadius = 8.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(_side.width);

  @override
  Path getInnerPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(_borderRadius)),
    );
    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(_borderRadius));

    const  double triangleWidth = 20.0;
    const  double triangleHeight = 20.0;

    double triangleTopCenterX = rrect.width / 2;

    if (MediaQuery.of(context).size.width < 1000) {
      if (direction == 0) {
        triangleTopCenterX -= 50;  // Shift triangle to the left by 40 pixels
      } else if (direction == 1) {
        triangleTopCenterX += 50;  // Shift triangle to the right by 40 pixels
      }
    }

    final double triangleTopCenterY = rrect.top - triangleHeight;

    path.moveTo(triangleTopCenterX, triangleTopCenterY);
    path.lineTo(triangleTopCenterX - (triangleWidth / 2), triangleTopCenterY + triangleHeight);
    path.lineTo(triangleTopCenterX + (triangleWidth / 2), triangleTopCenterY + triangleHeight);
    path.close();

    path.addRRect(rrect);

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RoundedRectangleBorder(
    side: _side.scale(t),
    borderRadius: BorderRadius.circular(_borderRadius * t),
  );

  
}


