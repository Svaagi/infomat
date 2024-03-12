import 'package:flutter/material.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/ResultsModel.dart';
import 'package:infomat/models/UserModel.dart';

class TeacherCapitolDragWidget extends StatefulWidget {
  final UserData? currentUserData;
  List<int> numbers;
  final Future<void> Function()  refreshData;
  double Function(int, int) percentage;
  int weeklyCapitolIndex;
  int weeklyTestIndex;
  int futureWeeklyCapitolIndex;
  int futureWeeklyTestIndex;
  List<ResultCapitolsData>? results;
  int studentsSum;
  void Function() addWeek;
  void Function(void Function(), void Function()) init;
 

  TeacherCapitolDragWidget({
    Key? key,
    required this.numbers,
    required this.currentUserData,
    required this.refreshData,
    required this.percentage,
    required this.weeklyCapitolIndex,
    required this.weeklyTestIndex,
    required this.results,
    required this.studentsSum,
    required this.addWeek,
    required this.futureWeeklyCapitolIndex,
    required this.futureWeeklyTestIndex,
    required this.init
  }) : super(key: key);

  @override
  _TeacherCapitolDragWidgetState createState() => _TeacherCapitolDragWidgetState();
}

class _TeacherCapitolDragWidgetState extends State<TeacherCapitolDragWidget> {
  int? expandedTileIndex;
  List<int> numbers = [];
  ClassData? currentClassData;
  List<dynamic> localResults = [];
  List<dynamic> localResultsDrag = [];
  bool _loadingCurrentClass = true;
   bool _loadingQuestionData = true;
     int currentCapitol = 0;

  fetchCurrentClass() async {
    try {
      ClassData classData = await fetchClass(widget.currentUserData!.schoolClass);
        if (mounted) {
          setState(() {
            currentClassData = classData;
            _loadingCurrentClass = false;
          });
        }
      }
    catch (e) {
      print('Error fetching user data: $e');
    }
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

  fetchQuestionData(List<int> num) async {
    try {
      setState(() {
        localResults = [];
      });
      String jsonData = await rootBundle.loadString('assets/CapitolsData.json');
      List<dynamic> data = json.decode(jsonData);
      for (int order in num) {
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
    fetchQuestionData(widget.numbers);
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
            child: Row(
              children: [
                Text(
                  'Všetky kapitoly',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                 ReButton(
                  color: "grey",
                  rightIcon: 'assets/icons/editIcon.svg',
                  text: 'Upraviť poradie', 
                  onTap: () async {
                    final result = await reorderListOverlay(context, currentClassData!);
                      if (result != null) {
                        setState(() {
                          widget.numbers = result;
                        });
                      }
                  },
                ),
              ],
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
                  // If capitol data is null, return an empty SizedBox or another widget indicating no data
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
                              style: TextStyle(fontSize: 14, decoration: subIndex == widget.weeklyTestIndex && widget.numbers[index] == widget.weeklyCapitolIndex  ? TextDecoration.underline : null,),
                            ),
                            trailing:  isBehind(index, subIndex) ? Row(
                              mainAxisSize: MainAxisSize.min,  // To shrink-wrap the Row
                              children: [
                                Text('Úspešnosť: ${(widget.percentage(widget.numbers[index], subIndex)*100).toStringAsFixed(0)}%',
                                  style: TextStyle(color: AppColors.getColor('mono').darkGrey)
                                ),  // Showing upto 2 decimal places
                                const SizedBox(width: 10),
                                SvgPicture.asset('assets/icons/adminIcon.svg', color: widget.results![index].tests[subIndex].completed/widget.studentsSum == 1.0 ? AppColors.getColor('green').main : AppColors.getColor('red').main, width: 18,),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.results![index].tests[subIndex].completed}/${widget.studentsSum}',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                     color: widget.results![index].tests[subIndex].completed/widget.studentsSum == 1.0 ? AppColors.getColor('green').main : AppColors.getColor('red').main,
                                  ),
                                ),
                                const SizedBox(width: 10),  // Optional: To give some space between the Text and the Icon
                                SvgPicture.asset('assets/icons/correctIcon.svg')  // Replace with the icon you want
                              ],
                            ) : Row(
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                if (subIndex == widget.futureWeeklyTestIndex && widget.numbers[index] == widget.futureWeeklyCapitolIndex)
                                Container(
                                  height: 60,
                                  width: 150,
                                  child: ReButton(color: 'green', text: 'Spustiť test', onTap: widget.addWeek),
                                )
                                
                              ],
                            ),
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

    
 Future<List<int>?> reorderListOverlay(BuildContext context, ClassData currentClass) async {
  List<int> reorderedNumbers = List.from(widget.numbers); // Create a deep copy
  List<int> normalOrder = [0, 1, 2, 3, 4];

  return await showDialog<List<int>>(
    context: context,
    builder: (ctx) => StatefulBuilder( // Using StatefulBuilder for local state management
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(  // Add this line
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 1300,
          height: 900,
          padding: const EdgeInsets.all(30),

          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Zmena poradia kapitol',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 20,),
                Text(
                  'Presuňte poradie nezačatých kapitol. Túto zmenu uvidia študenti okamžite.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 16
                  ),
                ),
                const SizedBox(height: 50,),
                Expanded(
                  child: SizedBox(
                    width: 600,
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        if (newIndex > currentCapitol) { // Check if it's not the first item
                          final item = reorderedNumbers.removeAt(oldIndex);
                          reorderedNumbers.insert(newIndex, item);
                          setState(() {});
                        }
                      },
                      buildDefaultDragHandles: false, // Remove default drag handles
                      children: normalOrder.map((number) {
                      dynamic capitol = localResultsDrag[reorderedNumbers[number]];
                      if (capitol == null) {
                        return Container();
                      }
                      List<Widget> rowChildren = [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(0),
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.getColor('mono').lighterGrey,
                            ),
                            child: ListTile(
                              enabled: false,
                              leading: CircleAvatar(
                                radius: 8,
                                backgroundColor: AppColors.getColor(capitol["color"]).light,
                              ),
                              title: Text(
                                capitol["name"],
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ];
                      if (number > currentCapitol) {
                        rowChildren.add(ReorderableDragStartListener(
                          index: number,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: SvgPicture.asset('assets/icons/dragIcon.svg'),
                          ),
                        ));
                      }
                      return Row(
                        key: ValueKey(number),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: rowChildren,
                      );
                    }).toList(),

                    ),
                  ),
                ),
                MediaQuery.of(context).size.width < 1000 ? 
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ReButton(
                      color: "green", 
                      text: 'ULOŽIŤ ZMENY', 
                      onTap: () async {
                        await updateClassToFirestore(reorderedNumbers);
                        await fetchQuestionData(reorderedNumbers); 
                        fetchCurrentClass(); 
                        Navigator.pop(context, reorderedNumbers);

                      },
                    ),
                    const SizedBox(width: 20,),
                    ReButton(
                      color: "white",  
                      text: 'ZRUŠIŤ ZMENY', 
                      onTap: () async {
                        Navigator.pop(context, reorderedNumbers);
                      },
                    ),
                  ],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ReButton(
                      color: "white",  
                      text: 'ZRUŠIŤ ZMENY', 
                      onTap: () async {
                        Navigator.pop(context, reorderedNumbers);
                      },
                    ),
                    const SizedBox(width: 20,),
                    ReButton(
                      color: "green",
                      text: 'ULOŽIŤ ZMENY', 
                      onTap: () async {
                        await fetchQuestionData(reorderedNumbers); 
                        await updateClassToFirestore(reorderedNumbers);
                        fetchCurrentClass(); 

                        widget.init(() {}, () {});

                        Navigator.pop(context, reorderedNumbers);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}



  Future<void> updateClassToFirestore(List<int> capitolOrder) async {
  try {
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(widget.currentUserData!.schoolClass);

    // Add the material data to Firestore and get the DocumentReference of the new document
    await classRef.update({
      'capitolOrder': capitolOrder
    });



    widget.refreshData();

    } catch (e) {
      print('Error adding material to class: $e');
      throw Exception('Failed to add capitolOrder');
    }
  }
}

// ReorderListOverlay remains unchanged.




