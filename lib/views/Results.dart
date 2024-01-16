import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/controllers/userController.dart'; // Import the UserData class and fetchUser function
import 'package:infomat/controllers/ClassController.dart';
import 'package:async/async.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Results extends StatefulWidget {
  int maxPoints;

  Results({super.key, required this.maxPoints});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
 UserData? currentUserData;
  int capitolOne = 0;
  List<String> badges = [];
  List<UserData>? students;
  CancelableOperation<UserData>? fetchUserDataOperation;
  CancelableOperation<List<UserData>>? fetchStudentsOperation;
  int? studentIndex;
  bool _loading = true;
  String selectedPeriod = 'Celý rok';  // Initial selection


  int indexOfElement(List<UserData> list, String id) {
    for (var i = 0; i < list.length; i++) {
      if (list[i].id == id) {
        return i;
      }
    }
    return -1; // return -1 if the id is not found
  }

  @override
  void initState() {
    super.initState();

    // Fetch the current user data.
    _fetchCurrentUserData().then((_) {
      // After fetching the current user data, fetch students.
      fetchStudents();
    });
  }


  Future<void> _fetchCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserData = await fetchUser(user.uid);
    }
  }
  
  Future<void> fetchStudents() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && currentUserData != null ) {
        final classData = await fetchClass(currentUserData!.schoolClass);
        final studentIds = classData.students;
        List<UserData> fetchedStudents = [];

        for (var id in studentIds) {
          fetchUserDataOperation?.cancel();  // Cancel the previous operation if it exists
          fetchUserDataOperation = CancelableOperation<UserData>.fromFuture(fetchUser(id));

          UserData userData = await fetchUserDataOperation!.value;

          if (mounted) {
            fetchedStudents.add(userData);
          } else {
            return;
          }
        }

        // sort students by score

        if (mounted) {
          setState(() {
            studentIndex = indexOfElement(fetchedStudents, user.uid);
            students = fetchedStudents;
            _loading = false;
          });
        }

      } else {
        print('currentUserData is null');
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  if (_loading) return Center(child: CircularProgressIndicator());

  return SingleChildScrollView(
    child: Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 138,
                margin: EdgeInsets.only(top: 32, left: 16),
                decoration: BoxDecoration(
                  color: AppColors.getColor('mono').lighterGrey,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  offset: const Offset(0, 40),
                  tooltip: '',
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                        SizedBox(width: 5,),
                        Text(
                          selectedPeriod,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: AppColors.getColor('primary').main,
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset('assets/icons/downIcon.svg', color:  AppColors.getColor('primary').main),
                      ],
                    ),
                  ),
                  onSelected: (String? newValue) {
                     setState(() {
                      selectedPeriod = newValue!;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    List<PopupMenuItem<String>> menuItems = [
                      PopupMenuItem<String>(
                            value: 'Celý rok',
                            child: Row(
                              children: [
                                if(selectedPeriod == 'Celý rok') SvgPicture.asset('assets/icons/checkIcon.svg', color:  AppColors.getColor('mono').grey, width: 18,),
                                SizedBox(width: 8,),
                                Text('Celý rok'),
                              ],
                            )
                          ),
                    PopupMenuItem<String>(
                            value: 'Prvý polrok',
                            child:  Row(
                              children: [
                                if(selectedPeriod == 'Prvý polrok') SvgPicture.asset('assets/icons/checkIcon.svg', color:  AppColors.getColor('mono').grey, width: 18,),
                                SizedBox(width: 8,),
                                Text('Prvý polrok'),
                              ],
                            )
                          ),
                    PopupMenuItem<String>(
                            value: 'Druhý polrok',
                            child:  Row(
                              children: [
                                if(selectedPeriod == 'Druhý polrok') SvgPicture.asset('assets/icons/checkIcon.svg', color:  AppColors.getColor('mono').grey, width: 18,),
                                SizedBox(width: 8,),
                                Text('Druhý polrok'),
                              ],
                            )
                          )
                    ];
                    return menuItems;
                  },
                ),
              ),
            if (students != null)
              buildScoreTable(students!)
          ],
        ),
      ),
    ),
  );
}



  List<Map<String, int>> getCapitolScores(UserData userData) {
    List<Map<String, int>> scores = [];

    for (var capitol in userData.capitols) {
      int capitolScore = 0;

      for (var test in capitol.tests) {
        capitolScore += test.points;
      }

      scores.add({
        'score': capitolScore,
      });
    }

    return scores;
  }


int getTotalScore(UserData userData) {
  int total = 0;

  for (var scoreMap in getCapitolScores(userData)) {
    total += scoreMap['score'] ?? 0;
  }

  return total;
}


Widget buildScoreTable(List<UserData> students) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,  // Enable horizontal scrolling
    child: Container(
      width: 1400,  // Set the table width to 1200 pixels
      margin: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Table(
            border: TableBorder(
              right: BorderSide(color: Colors.grey),
            ),
            children: _buildRows(students),
          ),
        ),
      ),
    ),
  );
}



List<TableRow> _buildRows(List<UserData> students) {
  List<TableRow> rows = [];


  // Determine the number of capitols to display based on the selected period
  int numberOfCapitols = (selectedPeriod == 'Celý rok') ? students.first.capitols.length : (selectedPeriod == 'Prvý polrok') ? 3 : 2; // Assuming each period has 4 capitols

  // Add header
  rows.add(
    TableRow(
      children: [
        Container(
          height: 50,
          width: 120,
          decoration: BoxDecoration(
          color: AppColors.getColor('primary').light,

            border: Border(
            right:  BorderSide(color: Colors.white),
          )
          ),
          padding: EdgeInsets.all(8),
          child: Text('Meno', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
        ...List.generate(numberOfCapitols, (index) {
          // Accessing elements in reverse order
          if(selectedPeriod == 'Druhý polrok') index += 3;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.getColor('primary').light,
              border: Border(
                right: BorderSide(color: Colors.white),
              ),
            ),
            height: 50,
            padding: EdgeInsets.all(8),
            // Use reversedIndex to access the capitols in reverse order
            child: Text(students.first.capitols[index].name, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          );
        }),
        Container(
          height: 50,
          width: 80,
          decoration: BoxDecoration(
          color: AppColors.getColor('primary').light,

            border: Border(
            right:  BorderSide(color: Colors.white),
          )
          ),
          padding: EdgeInsets.all(8),
          child: Text('Diskusia', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
        Container(
          height: 50,
          width: 80,
          decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,

            border: Border(
            right:  BorderSide(color: Colors.white),
          )
          ),
          padding: EdgeInsets.all(8),
          child: Text('Priemerná úspešnosť', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
      ],
    ),
  );

  // Add data rows
  for (var student in students) {
    List<Map<String, int>> scores = getCapitolScores(student);

    // Filter scores based on selectedPeriod
    if (selectedPeriod == 'Prvý polrok') {
      scores = scores.take(3).toList();
    } else if (selectedPeriod == 'Druhý polrok') {
      scores = scores.skip(3).toList();
    } else if (selectedPeriod == 'Celý rok') {
      // Keep all scores
    }

    int totalScore = getTotalScore(student);
    double percentage = (totalScore / widget.maxPoints) * 100;
    

   rows.add(
      TableRow(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: AppColors.getColor('mono').lighterGrey
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Text(student.name),
          ),
          ...scores.map((score) => Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: AppColors.getColor('mono').lighterGrey
              ),
            ),
                padding: EdgeInsets.all(8),
                child: Text('${score['score']} / ${widget.maxPoints}'),
          )),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: AppColors.getColor('mono').lighterGrey
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Text(student.discussionPoints.toString()),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: AppColors.getColor('primary').main
              ),
              color: AppColors.getColor('primary').lighter
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${totalScore} / ${widget.maxPoints} = ${percentage.toStringAsFixed(2)}%"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  return rows;
}


}