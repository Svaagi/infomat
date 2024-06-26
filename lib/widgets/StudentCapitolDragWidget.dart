import 'package:flutter/material.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';

// Child widget pre Challenges. Slúži ako drag and drop jednotlivých kapitol pre zmenu poradia učiteľom

class StudentCapitolDragWidget extends StatefulWidget {
  final UserData? currentUserData;
  final List<int> numbers;
  final Future<void> Function()  refreshData;
  int weeklyCapitolIndex;
  int weeklyTestIndex;

  StudentCapitolDragWidget({
    Key? key,
    required this.numbers,
    required this.currentUserData,
    required this.refreshData,
    required this.weeklyCapitolIndex,
    required this.weeklyTestIndex
  }) : super(key: key);

  @override
  _StudentCapitolDragWidgetState createState() => _StudentCapitolDragWidgetState();
}

class _StudentCapitolDragWidgetState extends State<StudentCapitolDragWidget> {
  int? expandedTileIndex;
  ClassData? currentClassData;
  List<dynamic> localResults = [];
  List<dynamic> localResultsDrag = [];
  bool _loadingCurrentClass = true;
  bool _loadingQuestionData = true;
  int currentCapitol = 0;


  int countTrueValues(List<UserQuestionsData> questionList) {
    int count = 0;
    for (UserQuestionsData question in questionList) {
      if (question.completed == true) {
        count++;
      }
    }
    return count;
}

  bool isBehind(int capitol, int test) {

    if (currentCapitol > capitol) {
      return true;
    } else if (currentCapitol == capitol && widget.weeklyTestIndex > test) {

      return true;
    } else {

      return false;
      
    }
  }

  fetchCurrentClass() async {
    try {
      ClassData classData = await fetchClass(widget.currentUserData!.schoolClass);
        if (mounted) {
          setState(() {
            currentClassData = classData;
            _loadingCurrentClass = false;
          });
        }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  fetchQuestionData() async {
    try {

      String jsonData = await rootBundle.loadString('assets/CapitolsData.json');
      List<dynamic> data = json.decode(jsonData);
      for (int order in widget.numbers) {
        localResults.add(data[order]);
      }

      for (int order = 0; order < widget.numbers.length; order++) {
        localResultsDrag.add(data[order]);
      }

      for (int i = 0; i < localResults.length; i++) {

        if (widget.numbers[i] == widget.weeklyCapitolIndex) {
          setState(() {
          currentCapitol = i;
            
          });

        }
      }


      setState(() {
        _loadingQuestionData = false;
      });
    } catch (e) {
      print('Error fetching question data: $e');
    }

  return localResults;
}


  @override
  void initState() {
    super.initState();
    fetchCurrentClass();
    fetchQuestionData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCurrentClass || _loadingQuestionData) {
        return const Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
    }
    return SingleChildScrollView(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            SizedBox(
              width: 600,
              child: 
                Text(
                  'Všetky kapitoly',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 600,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: localResults.length,
                itemBuilder: (ctx, index) {
                  bool isExpanded = index == expandedTileIndex;
                  dynamic capitol = localResults[index];

                


                  if (capitol == null) {
                    // If capitol data is null, return an empty Container or another widget indicating no data
                    return Container();
                  }

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(0),
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isExpanded
                              ? Theme.of(context).primaryColor
                              : AppColors.getColor('mono').lighterGrey,
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                expandedTileIndex = null;
                              } else {
                                expandedTileIndex = index;
                              }
                            });
                          },
                          hoverColor: Colors.transparent,
                          leading: CircleAvatar(
                            radius: 8,
                            backgroundColor: isExpanded
                                ? AppColors.getColor('mono').white
                                : AppColors.getColor(capitol["color"]).light,  // Update this to avoid out-of-bounds
                          ),
                          title: Text(
                            capitol["name"],
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: isExpanded
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).primaryColor,
                                ),
                          ),
                          trailing: isExpanded
                              ? SvgPicture.asset('assets/icons/upWhiteIcon.svg')
                              : SvgPicture.asset('assets/icons/downPrimaryIcon.svg'),
                        ),
                      ),
                      if (isExpanded)
                        ...List.generate(
                          capitol["tests"].length,
                          (subIndex) => Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.getColor('mono').lighterGrey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                capitol["tests"][subIndex]["name"],
                                style: TextStyle(fontSize: 14, decoration: subIndex == widget.weeklyTestIndex && widget.numbers[index] == widget.weeklyCapitolIndex  ? TextDecoration.underline : null, ),
                              ),
                              trailing: ((countTrueValues(widget.currentUserData!.capitols[widget.numbers[index]].tests[subIndex].questions) /
                                  widget.currentUserData!.capitols[widget.numbers[index]].tests[subIndex].questions.length)*100) != 0 ? Row(
                                mainAxisSize: MainAxisSize.min,  // To shrink-wrap the Row
                                children: [
                                  Text('${((widget.currentUserData!.capitols[widget.numbers[index]].tests[subIndex].points /
                                  widget.currentUserData!.capitols[widget.numbers[index]].tests[subIndex].questions.length)*100).toStringAsFixed(0)}%',
                                    style: TextStyle(color: AppColors.getColor('mono').darkGrey)
                                  ),  // Showing upto 2 decimal places
                                  const SizedBox(width: 5),  // Optional: To give some space between the Text and the Icon
                                  SvgPicture.asset('assets/icons/correctIcon.svg')  // Replace with the icon you want
                                ],
                              ) : isBehind(index, subIndex) ? 
                                Row(
                                   mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Výzvu si nestihol urobiť',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.getColor('red').main ),
                                    ),
                                    SizedBox(width: 10,),
                                    SvgPicture.asset('assets/icons/smallErrorIcon.svg', color: AppColors.getColor('red').main, width: 20,),
                                  ],
                                )
                              
                               : null ,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              dense: true,
                            ),
                          ),
                        )
                    ],
                  );
                },
              )
            )
          ],
        ),
      )
    );
  }
 
}

// ReorderListOverlay remains unchanged.




