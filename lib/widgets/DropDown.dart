import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'dart:html' as html;
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';

class OptionsData {
  String id;
  ClassData data;

  OptionsData({
    required this.id,
    required this.data,
  });
}

class DropDown extends StatefulWidget {
  final UserData? currentUserData;
  final VoidCallback? onUserDataChanged;
  void Function() fetch;
  final Function(int) onNavigationItemSelected;
  int selectedIndex;


  DropDown({
    Key? key,
    required this.currentUserData,
    this.onUserDataChanged,
    required this.fetch,
    required this.onNavigationItemSelected,
    required this.selectedIndex
  }) : super(key: key);

  @override
  _DropDownState createState() => _DropDownState();
}

// Create a global variable for 'No Class' option
final OptionsData noClassOption = OptionsData(
  id: 'Žiadna',
  data: ClassData(
    name: 'Žiadna',
    capitolOrder: [0,1,2,3,4],
    materials: [],
    posts: [],
    school: '',
    students: [],
    teachers: [],
    results: ''
  ),
);

class _DropDownState extends State<DropDown> {
  String? dropdownValue;
  List<OptionsData>? options;
  bool isMobile = false;
  bool isDesktop = false;
  bool _loading = true;

  final userAgent = html.window.navigator.userAgent.toLowerCase();

  @override
  void initState() {
    super.initState();
    isMobile = userAgent.contains('mobile');
    isDesktop = userAgent.contains('macintosh') ||
        userAgent.contains('windows') ||
        userAgent.contains('linux');
    fetchOptions();
  }

  Future<void> fetchOptions() async {
  try {
    if (widget.currentUserData != null) {
      List<OptionsData> fetchedOptions = [];

      // Fetch the classes and add them to the options
      for (var classId in widget.currentUserData!.classes) {
        try {
          ClassData classData = await fetchClass(classId);
          fetchedOptions.add(OptionsData(id: classId, data: classData));
        } catch (e) {
          print('Invalid classId $classId: $e');
        }
      }

      // Sort the fetched options in alphabetical and numerical order based on the class name
      fetchedOptions.sort((a, b) => a.data.name.compareTo(b.data.name));

      // Check if current schoolClass is in the fetched classes
      bool schoolClassExists = fetchedOptions.any((option) => option.id == widget.currentUserData!.schoolClass);

      setState(() {
        options = fetchedOptions;
        dropdownValue = (widget.currentUserData!.schoolClass != null &&
                widget.currentUserData!.schoolClass!.isNotEmpty &&
                schoolClassExists)
            ? widget.currentUserData!.schoolClass
            : 'Žiadna'; // Default to 'Žiadna' if schoolClass is invalid, null, or empty
        _loading = false;
      });
    } else {
      print('Error: Current user data is null');
    }
  } catch (e) {
    print('Error while fetching options: $e');
  }
}



  void handleSelection(String selectedId) {
    setState(() {
      dropdownValue = selectedId;
    });
    myFunction(selectedId);
  }

  void myFunction(String parameter) async {
    widget.currentUserData!.schoolClass = parameter;
    await saveUserDataToFirestore(widget.currentUserData!).then((_) {
      if (widget.onUserDataChanged != null) {
        widget.onUserDataChanged!();
      }
    });
    widget.fetch;
    setState(() {
      widget.selectedIndex = 0;
    });
    widget.onNavigationItemSelected(0);
  }

  @override
  void didUpdateWidget(DropDown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if currentUserData has changed
    if (widget.currentUserData != oldWidget.currentUserData) {
      fetchOptions(); // Call fetchOptions to update the dropdown

      // If there is a callback defined, call it
      if (widget.onUserDataChanged != null) {
        widget.onUserDataChanged!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDropdownOpen = false;
    if (_loading) return Center(child: CircularProgressIndicator(),);
    return   Container(
              width: 138,
              margin: EdgeInsets.symmetric(vertical: 8),
              
              decoration: BoxDecoration(
                color: isMobile ? Color(0xff989BDD) : AppColors.getColor('mono').lighterGrey,
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
                        'Trieda: ${options!.firstWhere((option) => option.id == dropdownValue, orElse: () => noClassOption).data.name}',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: isMobile ? AppColors.getColor('mono').white : AppColors.getColor('primary').main,
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset('assets/icons/downIcon.svg', color: isMobile ? AppColors.getColor('mono').white : AppColors.getColor('primary').main),
                    ],
                  ),
                ),
                onSelected: (String? newValue) {
                  handleSelection(newValue!);
                  setState(() {
                    isDropdownOpen = !isDropdownOpen;
                  });
                },
                onCanceled: () {
                  setState(() {
                    isDropdownOpen = !isDropdownOpen;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return options!
                      .where((OptionsData value) => value.id != "Žiadna") // Exclude "Žiadna" from the list
                      .map<PopupMenuItem<String>>((OptionsData value) {
                        return PopupMenuItem<String>(
                          value: value.id,
                          child: Text(value.data.name),
                        );
                      }).toList();
                },
              ),
            );
  }

  Future<void> saveUserDataToFirestore(UserData userData) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      Map<String, dynamic> userDataMap = {
        'email': userData.email,
        'discussionPoints': userData.discussionPoints,
        'weeklyDiscussionPoints': userData.weeklyDiscussionPoints,
        'name': userData.name,
        'active': userData.active,
        'school': userData.school,
        'schoolClass': userData.schoolClass,
        'teacher': userData.teacher,
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
                    'answer': userQuestionsData.answer,
                    'completed': userQuestionsData.completed
                  };
                }).toList(),
              };
            }).toList(),
          };
        }).toList(),
        'materials': userData.materials,
      };
      await userRef.update(userDataMap);
    } catch (e) {
      print('Error saving user data to Firestore: $e');
      rethrow;
    }
  }
}
