import 'dart:html' as html;
import 'dart:convert';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/widgets/MobileAppBar.dart';
import 'package:infomat/widgets/DesktopAppBar.dart';
import 'package:infomat/widgets/MobileBottomNavigation.dart';
import 'package:infomat/widgets/TeacherMobileAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/widgets/Widgets.dart';

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
  int capitolsId = 1;
  dynamic capitol;
  int weeklyChallenge = 0;
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
  List<dynamic> data = [];

  final userAgent = html.window.navigator.userAgent.toLowerCase();



  @override
  void initState() {
    super.initState();
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    isMobile = userAgent.contains('mobile');
    isDesktop = userAgent.contains('macintosh') ||
        userAgent.contains('windows') ||
        userAgent.contains('linux');
    fetchUserData(); // Fetch the user data when the app starts
        fetchCapitolsData();

    
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


  Future<void> fetchUserData() async {
    try {
      // Retrieve the Firebase Auth user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user data using the fetchUser function
        UserData userData = await fetchUser(user.uid);
        setState(() {
          currentUserData = userData;
          _loadingUser = false;
        });
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

   Future<void> fetchCapitolsData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/CapitolsData.json');
      data = json.decode(jsonData);

      setState(() {
          capitol = data[capitolsId];
          capitolLength = data[0]["points"] + data[1]["points"] ?? 0;
          weeklyChallenge = data[capitolsId]["weeklyChallenge"] ?? '';
          weeklyTitle = data[capitolsId]["tests"][weeklyChallenge]["name"] ?? '';
          futureWeeklyTitle =
              data[capitolsId]["tests"][weeklyChallenge + 1]["name"] ?? '';
          
          weeklyCapitolLength = data[capitolsId]["tests"].length ?? 0;
          
          capitolTitle = data[capitolsId]["name"] ?? '';
          capitolColor = data[0]["color"] ?? 'blue';

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
    if (_loadingUser || _loadingCapitols) {
        return const Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
    }
    return 
      Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: isMobile
      ? currentUserData!.teacher
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TeacherMobileAppBar(
                tutorial: () {
                  setState(() {
                      _tutorial = true;
                    });
                },
                onItemTapped: _onNavigationItemSelected,
                selectedIndex: _selectedIndex,
                currentUserData: currentUserData,
                onUserDataChanged: _onUserDataChanged,
                logOut: logOut,
                onNavigationItemSelected: _onNavigationItemSelected,
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: MobileAppBar(
                tutorial: () {
                  setState(() {
                      _tutorial = true;
                    });
                },
                currentUserData: currentUserData,
                logOut: logOut,
                onNavigationItemSelected: _onNavigationItemSelected,
              ),
            )
      : PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: DesktopAppBar(
            tutorial: () {
                  setState(() {
                      _tutorial = true;
                    });
                },
            currentUserData: currentUserData,
            onNavigationItemSelected: _onNavigationItemSelected,
            onUserDataChanged: _onUserDataChanged,
            selectedIndex: _selectedIndex,
          ),
        ),
      drawer: (currentUserData!.teacher && isMobile) ? Drawer(
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
                      child: SvgPicture.asset('assets/icons/xIcon.svg', height: 10,),
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
            buildNavItem(4, "assets/icons/resultsIcon.svg", "Výsledky", context),
            buildNavItem(6, "assets/icons/adminIcon.svg", "Moja škola", context),
            buildNavItem(7, "assets/icons/messageIcon.svg", "Kontaktuje nás", context),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
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
      bottomNavigationBar:  (isMobile && !currentUserData!.teacher) ? MobileBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavigationItemSelected,
      ) : null,
      body: !currentUserData!.teacher ? _buildStduentScreen(_selectedIndex) : _buildTeacherScreen(_selectedIndex),
    );
  }

   Widget _buildStduentScreen(int index) {
    switch (index) {
      case 0:
        return isMobile ? MobileStudentFeed(
            capitolColor: capitolColor,
            capitolData: currentUserData!.capitols[capitolsId],
            onNavigationItemSelected: _onNavigationItemSelected,
            capitolLength: capitolLength,
            capitolTitle: capitolTitle,
            capitolsId: capitolsId,
            completedCount: completedCount,
            futureWeeklyTitle: futureWeeklyTitle,
            weeklyBool: weeklyBool,
            weeklyCapitolLength: weeklyCapitolLength,
            weeklyChallenge: weeklyChallenge,
            weeklyTitle: weeklyTitle,
          ) : DesktopStudentFeed(
            capitolColor: capitolColor,
            capitolData: currentUserData!.capitols[capitolsId],
            onNavigationItemSelected: _onNavigationItemSelected,
            capitolLength: capitolLength,
            capitolTitle: capitolTitle,
            capitolsId: capitolsId,
            completedCount: completedCount,
            futureWeeklyTitle: futureWeeklyTitle,
            weeklyBool: weeklyBool,
            weeklyCapitolLength: weeklyCapitolLength,
            weeklyChallenge: weeklyChallenge,
            weeklyTitle: weeklyTitle,
          );
      case 1:
        return Challenges(
          fetch: fetchUserData(),
          currentUserData: currentUserData,
        );
      case 2:
        return Discussions(
          currentUserData: currentUserData,
        );
      case 3:
        return Learning(
          currentUserData: currentUserData,
          fetch: fetchUserData(),
        );
      case 4:
        return Notifications(currentUserData: currentUserData, onNavigationItemSelected: _onNavigationItemSelected);
      case 5:
        return Profile(logOut: () {
          FirebaseAuth.instance.signOut();
          setState(() {
            fetchUserData();
          });
        });
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
            capitolTitle: capitolTitle,
            capitolsId: capitolsId,
            completedCount: completedCount,
            futureWeeklyTitle: futureWeeklyTitle,
            weeklyBool: weeklyBool,
            weeklyCapitolLength: weeklyCapitolLength,
            weeklyChallenge: weeklyChallenge,
            weeklyTitle: weeklyTitle,
          ) : DesktopTeacherFeed(
            onNavigationItemSelected: _onNavigationItemSelected,
            capitolLength: capitolLength,
            capitolTitle: capitolTitle,
            capitolsId: capitolsId,
            completedCount: completedCount,
            futureWeeklyTitle: futureWeeklyTitle,
            weeklyBool: weeklyBool,
            weeklyCapitolLength: weeklyCapitolLength,
            weeklyChallenge: weeklyChallenge,
            weeklyTitle: weeklyTitle,
          );
      case 1:
        return Challenges(
          fetch: fetchUserData(),
          currentUserData: currentUserData,
        );
      case 2:
        return Discussions(
          currentUserData: currentUserData,
        );
      case 3:
        return Learning(
          currentUserData: currentUserData,
          fetch: fetchUserData(),
        );
      case 4:
        return  const Results(); // Handle other cases
      case 5:
        return Notifications(currentUserData: currentUserData, onNavigationItemSelected: _onNavigationItemSelected);
      case 6:
        return isMobile
          ? MobileAdmin(
              fetch: fetchUserData(),
              currentUserData: currentUserData,
              logOut: () {
                FirebaseAuth.instance.signOut();
                setState(() {
                  fetchUserData();
                });
              },
            )
          : DesktopAdmin(
              fetch: fetchUserData(),
              currentUserData: currentUserData,
              logOut: () {
                FirebaseAuth.instance.signOut();
                setState(() {
                  fetchUserData();
                });
              },
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

