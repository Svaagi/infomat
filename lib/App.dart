import 'dart:html' as html;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/views/ContactView.dart';
import 'package:infomat/views/Learning.dart';
import 'package:infomat/views/Challenges.dart';
import 'package:infomat/views/Results.dart';
import 'package:infomat/views/Notifications.dart';
import 'package:infomat/views/Profile.dart';
import 'package:infomat/views/DesktopStudentFeed.dart';
import 'package:infomat/views/Tutorial.dart';
import 'package:infomat/views/MobileStudentFeed.dart';
import 'package:infomat/views/DesktopTeacherFeed.dart';
import 'package:infomat/views/MobileTeacherFeed.dart';
import 'package:infomat/views/Discussions.dart';
import 'package:infomat/views/admin/DesktopAdmin.dart';
import 'package:infomat/views/admin/MobileAdmin.dart';
import 'package:infomat/controllers/UserController.dart'; // Import the UserData class and fetchUser function
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/controllers/ResultsController.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/widgets/DesktopAppBar.dart';
import 'package:infomat/widgets/MobileAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/ResultsModel.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'dart:async';



class NonSwipeablePageController extends PageController {
  @override
  bool get canScroll => false;
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  UserData? currentUserData;
  int? capitolLength;
  dynamic capitol;
  String? weeklyTitle;
  String? futureWeeklyTitle;
  bool weeklyBool = false;
  int weeklyCapitolLength = 0;
  int completedCount = 0;
  String? capitolTitle;
  bool _loadingCapitols = true;
  bool _loadingUser = true;
  String? capitolColor;
  bool isMobile = false;
  bool isDesktop = false;
  bool _tutorial = false;
  List<PostsData> _posts = [];
  bool _loadingChallenge = true;
  List<dynamic> data = [];
  List<dynamic> orderedData = [];
  int weeklyChallenge = 0;
  int weeklyCapitolIndex = 0;
  int weeklyTestIndex = 0;
  List<int> order = [0,1,2,3,4];
  List<ResultCapitolsData>? currentResults;
  int studentsSum = 0;
  List<String> students = [];
  int maxPoints = 0;
  bool load = false;

  List<DateTime> _activeWeeks = [

  ];

  final userAgent = html.window.navigator.userAgent.toLowerCase();

  void addWeek () {
    _activeWeeks.add(DateTime(2023, 12, 27));
    maxPoints = 0;
  }

  void removeWeek () {
    _activeWeeks.removeLast();
     maxPoints = 0;
  }

  Future<void> fetchPosts() async {
    try {
      ClassData classes = await fetchClass(currentUserData!.schoolClass);
      List<PostsData> posts = [];

      posts.addAll(classes.posts);

      posts.sort((a, b) => b.date.compareTo(a.date));
      if(mounted) {
        setState(() {
          _posts = posts;
        });
      }


    } catch (e) {
      print('Error fetching posts: $e');
    }
  }



 int getTests (int i) {
    switch (i) {
      case 0:
        return 2;
      case 1:
        return 8;
      case 2:
        return 6;
      case 3:
        return 10;
      case 4:
        return 6;
      default:
        return 0;
    }
 }

  int getPoints (int i) {
    switch (i) {
      case 0:
        return 14;
      case 1:
        return 43;
      case 2:
        return 24;
      case 3:
        return 56;
      case 4:
        return 31;
      default:
        return 0;
    }
 }

 void getWeeklyIndexes (int i) {
     if (i < getTests(order[0])) {
        setState(() {
          weeklyCapitolIndex = order[0];
          weeklyTestIndex = i;

          for (int j = 0; j <= i; j++) {
            maxPoints += orderedData[0]["tests"][j]["questions"].length as int;
          }

        });
      } else if ( i >= getTests(order[0]) && i <  getTests(order[0]) + getTests(order[1])) {
        setState(() {
          weeklyCapitolIndex = order[1];
          weeklyTestIndex = i-getTests(order[0]);
          maxPoints = (getPoints(order[0]));
          for (int j = 0; j <=  weeklyTestIndex; j++) {

            maxPoints += data![weeklyCapitolIndex]["tests"][j]["questions"].length as int;

          }
        });
      } else if ( i >= getTests(order[0])+getTests(order[1]) && i < getTests(order[0]) + getTests(order[1]) + getTests(order[2])) {
        setState(() {
          weeklyCapitolIndex = order[2];
          weeklyTestIndex = i-(getTests(order[0])+getTests(order[1]));
          maxPoints = (getPoints(order[0]) + getPoints(order[1]));
          for (int j = 0; j <= weeklyTestIndex; j++) {
            maxPoints += data![weeklyCapitolIndex]["tests"][j]["questions"].length as int;
          }
        });
      } else if ( i >= getTests(order[0]) + getTests(order[1]) + getTests(order[2]) && i < getTests(order[0]) + getTests(order[1]) + getTests(order[2]) + getTests(order[3])) {
        setState(() {
          weeklyCapitolIndex = order[3];
          weeklyTestIndex = i-(getTests(order[0]) + getTests(order[1]) + getTests(order[2]));
          maxPoints = (getPoints(order[0]) + getPoints(order[1]) + getPoints(order[2]));
          for (int j = 0; j <= weeklyTestIndex; j++) {
            maxPoints += data![weeklyCapitolIndex]["tests"][j]["questions"].length as int;
          }
        });
      } else if ( i >= getTests(order[0]) + getTests(order[1]) + getTests(order[2]) + getTests(order[3]) && i < getTests(order[0]) + getTests(order[1]) + getTests(order[2]) + getTests(order[3]) + getTests(order[4])) {
        setState(() {
          weeklyCapitolIndex = order[4];
          weeklyTestIndex = i- (getTests(order[0]) + getTests(order[1]) + getTests(order[2]) + getTests(order[3]));
          maxPoints = (getPoints(order[0]) + getPoints(order[1]) + getPoints(order[2]) + getPoints(order[3]));
          for (int j = 0; j <=  weeklyTestIndex; j++) {
            maxPoints += data![weeklyCapitolIndex]["tests"][j]["questions"].length as int;
          }
        });
      }
 }

  void init (void Function() start, void Function() end ) async {
    start();

      // Initialize the weekly challenge count based on the active weeks
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    isMobile = userAgent.contains('mobile');
    isDesktop = userAgent.contains('macintosh') ||
        userAgent.contains('windows') ||
        userAgent.contains('linux');
       // Calculate the time until the next midnight
      DateTime now = DateTime.now();
      DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
      Duration initialDelay = nextMidnight.difference(now);

      // Set up a timer to first trigger at the next midnight
      Timer(initialDelay, () {
        // Update the weekly challenge at midnight
        updateWeeklyChallenge();

        // Then set up a periodic timer to trigger every 24 hours after the first execution
        Timer.periodic(Duration(days: 1), (Timer timer) {
          updateWeeklyChallenge();
        });
      });

    await fetchUserData();

    
    await fetchPosts();


    end();
  }


  @override
  void initState() {
    super.initState();
    


    // Fetch the user data when the app starts
    init(() {}, () {});


  }

void updateWeeklyChallenge() {
  // Calculate the new weekly challenge count
    int newWeeklyChallenge = calculatePassedActiveWeeks(DateTime.now(), _activeWeeks);

    // Check if the weekly challenge count has changed
    if (weeklyChallenge != newWeeklyChallenge) {
      setState(() {
        weeklyChallenge = newWeeklyChallenge;
      });
  }

  _loadingChallenge = false;

  getWeeklyIndexes(weeklyChallenge);
}

void fetch() async {

  init(() { }, () { });
  setState(() {
    _selectedIndex = 0;
  });
}


int calculatePassedActiveWeeks(DateTime currentDate, List<DateTime> activeWeekDates) {
  // Normalize the current date to remove hours, minutes, and seconds
  currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

  // Count the number of active weeks that have already passed
  int passedWeeksCount = activeWeekDates.where((activeDate) =>
    activeDate.isBefore(currentDate)).length;

  return passedWeeksCount;
}

   void _onUserDataChanged() {
    fetchUserData();
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

  void logOut() {
    FirebaseAuth.instance.signOut();
      setState(() {
        fetchUserData();
      });
  }

  Future<void> fetchFake() async {
  try {
      print('fake');
  }catch (e) {
    print('Error fetching fake data: $e');
    setState(() {
      _loadingUser = false;
    });
  }
  }

  Future<void> fetchUserData() async {
  try {
      print('here');

    // Retrieve the Firebase Auth user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch the user data using the fetchUser function
      UserData userData = await fetchUser(user.uid);
      
      // Attempt to fetch class data
      ClassData? classData;
      try {
        classData = await fetchClass(userData.schoolClass);
      } catch (e) {
        print('Error fetching class data: $e');
      }

      if (userData.classes.isEmpty) {
        setState(() {
          _selectedIndex = 6;
          load = true;
        });
      }

      // Proceed with fetching results if class data is available
      if (classData != null) {
        try {
          currentResults = await fetchResults(classData.results);
        } catch (e) {
          print('Error fetching results data: $e');
        }
      }

      if (!userData.signed) {
        setUserSigned(user.uid);
      }

      int count = 0;

      for(int i = 0; i < userData.capitols.length; i++) {
        for (UserCapitolsTestData tmp in userData.capitols[i].tests) {
          if (tmp.completed) {
            count++;
          }
        }
      }

            // Update state with user data, and class data if available
      setState(() {
        currentUserData = userData;
        if (classData != null) {
          order = classData.capitolOrder;
          studentsSum = classData.students.length;
          if (userData.capitols[weeklyCapitolIndex].tests[weeklyTestIndex].completed) weeklyBool = true;
          students = classData.students;
          
          completedCount = count;
        }
        _loadingUser = false;
      });


      

      await fetchCapitolsData();






    } else {
      print('User is not logged in.');
    }
  } catch (e) {
    print('Error fetching user data: $e');
    setState(() {
      _loadingUser = false;
    });
  }
}


   Future<void> fetchCapitolsData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/CapitolsData.json');
      data = json.decode(jsonData);


      for (int num in order) {
        orderedData.add(data[num]);
      }

      updateWeeklyChallenge();

      setState(() {
          capitol = orderedData[weeklyCapitolIndex];
          capitolLength = 32;
          weeklyTitle = orderedData[weeklyCapitolIndex]["tests"][weeklyTestIndex]["name"] ?? '';
          futureWeeklyTitle =
              orderedData[weeklyCapitolIndex]["tests"][weeklyTestIndex]["name"] ?? '';
          
          weeklyCapitolLength = orderedData[weeklyCapitolIndex]["tests"].length ?? 0;
          
          capitolTitle = orderedData[weeklyCapitolIndex]["name"] ?? '';
          capitolColor = orderedData[0]["color"] ?? 'blue';

    });
          _loadingCapitols = false;

  } catch (e) {
    print('Error with loading capitols: $e');
    _loadingCapitols = false;
  }
  }

  @override
  Widget build(BuildContext context) {
    if(_tutorial) {
        return Tutorial(check: () {
        setState(() {
          _tutorial = false;
        });
      });
    }
    if (_loadingUser || _loadingCapitols || _loadingChallenge) {
        return const Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
    }
    return 
      Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: isMobile
      ? 
          PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: MobileAppBar(
                tutorial: () {
                  setState(() {
                      _tutorial = true;
                    });
                },
                fetch: fetch,
                onItemTapped: _onNavigationItemSelected,
                selectedIndex: _selectedIndex,
                currentUserData: currentUserData,
                onNavigationItemSelected: _onNavigationItemSelected,
              ),
            )
      : PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: DesktopAppBar(
            fetch: fetch,
            setUser: (UserData user) {
              setState(() {
                currentUserData = user;
              });
            },
            tutorial: () {
                  setState(() {
                      _tutorial = true;
                    });
                },
            currentUserData: currentUserData,
            onNavigationItemSelected: _onNavigationItemSelected,
            selectedIndex: _selectedIndex,
          ),
        ),
      drawer: ( isMobile) ? Drawer(
        backgroundColor:  AppColors.getColor('mono').white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/logoFilled.svg',),
                  const Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: SvgPicture.asset('assets/icons/xIcon.svg', height: 15,),
                      onTap: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            buildNavItem(0, "assets/icons/homeIcon.svg", "Domov", context),
            buildNavItem(1, "assets/icons/starIcon.svg", "Výzva", context),
            buildNavItem(2, "assets/icons/textBubblesIcon.svg", "Diskusia", context),
            buildNavItem(3, "assets/icons/bookIcon.svg", "Vzdelávanie", context),
            if(currentUserData!.teacher) buildNavItem(4, "assets/icons/resultsIcon.svg", "Výsledky", context),
            if(currentUserData!.teacher) buildNavItem(6, "assets/icons/adminIcon.svg", "Spravovať triedy", context),
            buildNavItem(7, "assets/icons/messageIcon.svg", "Kontaktuje nás", context),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 14),
                width: 160,
                height: 40,
                child: ReButton(
                  color: "red",  
                  text: 'Odhlásiť sa',
                  rightIcon: 'assets/icons/logoutIcon.svg',
                  onTap: () {
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
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Odhlásiť sa',
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
                                    'Po odhlásení sa z aplikácie budeš musieť znovu zadať svoje používeteľské meno a heslo.',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 30,),
                                  ReButton(
                                  color: "red", 
                                  text: 'ODHLÁSIŤ SA',
                                  onTap: () {
                                    FirebaseAuth.instance.signOut();
                                    setState(() {
                                      fetchUserData();
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                SizedBox(height: 30,),
                              ],
                            ),
                          )
                        );
                      },
                    );
                  }
                ),
              )
            ],
          ),
            // Add more ListTile widgets for additional menu items
          ],
        ),
      ) : null,
      body: !currentUserData!.teacher ? _buildStudentScreen(_selectedIndex) : _buildTeacherScreen(_selectedIndex),
    );
  }

   Widget _buildStudentScreen(int index) {
    switch (index) {
      case 0:
        return isMobile ? MobileStudentFeed(
            capitolColor: capitolColor,
            capitolData: currentUserData!.capitols[weeklyCapitolIndex],
            onNavigationItemSelected: _onNavigationItemSelected,
            capitolLength: capitolLength,
            capitolTitle: capitolTitle,
            capitolsId: weeklyCapitolIndex,
            completedCount: completedCount,
            futureWeeklyTitle: futureWeeklyTitle,
            weeklyBool: weeklyBool,
            weeklyCapitolLength: weeklyCapitolLength,
            weeklyChallenge: weeklyChallenge,
            weeklyTitle: weeklyTitle,
            orderedData: orderedData,
            weeklyCapitolIndex: weeklyCapitolIndex,
            weeklyTestIndex: weeklyTestIndex,
            init: init,
          ) : DesktopStudentFeed(
            capitolColor: capitolColor,
            capitolData: currentUserData!.capitols[weeklyCapitolIndex],
            onNavigationItemSelected: _onNavigationItemSelected,
            capitolLength: capitolLength,
            capitolTitle: capitolTitle,
            capitolsId: weeklyCapitolIndex,
            completedCount: completedCount,
            futureWeeklyTitle: futureWeeklyTitle,
            weeklyBool: weeklyBool,
            weeklyCapitolLength: weeklyCapitolLength,
            weeklyChallenge: weeklyChallenge,
            weeklyTitle: weeklyTitle,
            weeklyTestIndex: weeklyTestIndex,
            addWeek: addWeek,
            removeWeek: removeWeek,
            init: init,
            orderedData: orderedData,
            weeklyCapitolIndex: weeklyCapitolIndex,
          );
      case 1:
        return Challenges(
          weeklyChallenge: weeklyChallenge,
          currentUserData: currentUserData,
          weeklyCapitolIndex: weeklyCapitolIndex,
          weeklyTestIndex: weeklyTestIndex,
          
        );
      case 2:
        return Discussions(
          currentUserData: currentUserData,
        );
      case 3:
        return Learning(
          currentUserData: currentUserData,
        );
      case 4:
        return Notifications(currentUserData: currentUserData, onNavigationItemSelected: _onNavigationItemSelected);
      case 5:
        return Profile(logOut: () {
          FirebaseAuth.instance.signOut();
          setState(() {
            fetchUserData();
          });
        },
        weeklyCapitolIndex: weeklyCapitolIndex,
        weeklyTestIndex: weeklyTestIndex,
        );
      case 7:
        return ContactView();
      default:
        return Container(); // Handle other cases
    }
  }

  Widget _buildTeacherScreen(int index) {
    switch (index) {
      case 0:
        return isMobile ? MobileTeacherFeed(
             onNavigationItemSelected: _onNavigationItemSelected,
            capitolLength: capitolLength,
            orderedData: orderedData,
            weeklyCapitolIndex: weeklyCapitolIndex,
            weeklyTestIndex: weeklyTestIndex,
            weeklyChallenge: weeklyChallenge,
            addWeek: addWeek,
            removeWeek: removeWeek,
            init: init,
            results: currentResults,
            studentsSum: studentsSum,
            posts: _posts,
            students: students,
          ) : DesktopTeacherFeed(
            onNavigationItemSelected: _onNavigationItemSelected,
            capitolLength: capitolLength,
            orderedData: orderedData,
            weeklyCapitolIndex: weeklyCapitolIndex,
            weeklyTestIndex: weeklyTestIndex,
            weeklyChallenge: weeklyChallenge,
            addWeek: addWeek,
            removeWeek: removeWeek,
            load: load,
            init: init,
            students: students,
            results: currentResults,
            studentsSum: studentsSum,
            posts: _posts,
            maxPoints: maxPoints,
          );
      case 1:
        return Challenges(
          weeklyChallenge: weeklyChallenge,
          currentUserData: currentUserData,
          weeklyCapitolIndex: weeklyCapitolIndex,
          weeklyTestIndex: weeklyTestIndex,
        );
      case 2:
        return Discussions(
          currentUserData: currentUserData,
        );
      case 3:
        return Learning(
          currentUserData: currentUserData,
        );
      case 4:
        return  Results(maxPoints: maxPoints,); // Handle other cases
      case 5:
        return Notifications(currentUserData: currentUserData, onNavigationItemSelected: _onNavigationItemSelected);
      case 6:
        return isMobile
          ? MobileAdmin(
              currentUserData: currentUserData,
              logOut: () {
                FirebaseAuth.instance.signOut();
                setState(() {
                  fetchUserData();
                });
              },
              onUserChanged: _onUserDataChanged,
            )
          : DesktopAdmin(
              currentUserData: currentUserData,
              logOut: () {
                FirebaseAuth.instance.signOut();
                setState(() {
                  fetchUserData();
                });
              },
              onUserChanged: _onUserDataChanged,
            );
      case 7:
        return ContactView();
      default:
        return Container(); // Handle other cases
    }
  }

   void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildNavItem(int index, String icon, String text, BuildContext context) {
    final bool isSelected = index == _selectedIndex;
    return Container(
      width: 260,
      height: 57,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color:  isSelected ? AppColors.getColor('mono').lighterGrey : AppColors.getColor('mono').white,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _onNavigationItemSelected(index);
          _scaffoldKey.currentState?.openEndDrawer();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(icon, color: isSelected ? AppColors.getColor('primary').main : AppColors.getColor('mono').black),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: isSelected ? AppColors.getColor('primary').main : AppColors.getColor('mono').black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

