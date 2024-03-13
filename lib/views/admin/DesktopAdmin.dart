import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/models/SchoolModel.dart';
import 'package:infomat/controllers/convert.dart';
import 'package:infomat/controllers/SchoolController.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:infomat/views/admin/DesktopClasses.dart';
import 'package:infomat/views/admin/AddUser.dart';
import 'package:infomat/views/admin/AddExistingUser.dart';
import 'package:infomat/views/admin/UpdateUser.dart';
import 'package:infomat/providers/AddClassProvider.dart';
import 'package:infomat/views/admin/UpdateClass.dart';
import 'package:infomat/views/admin/Xlsx.dart';
import 'package:infomat/providers/ContactProvider.dart';




class DesktopAdmin extends StatefulWidget {
  final UserData? currentUserData;
  final void Function() logOut;
  const DesktopAdmin({Key? key, required this.currentUserData, required this.logOut});

  @override
  State<DesktopAdmin> createState() => _DesktopAdminState();
}

class _DesktopAdminState extends State<DesktopAdmin> {
  
  List<String> classes = [];
  List<String>? teachers;
  String? schoolName;
  UserData? admin;
  String? adminId;
  bool _teacher = false;
  bool _admin = false;
  int _selectedIndex = 0;
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _userPasswordController = TextEditingController();
  TextEditingController _editUserNameController = TextEditingController();
  TextEditingController _editUserEmailController = TextEditingController();
  TextEditingController _editUserPasswordController = TextEditingController();
  TextEditingController _editClassNameController = TextEditingController();
  bool _loading = true;
  ClassDataWithId? currentClass;
  UserDataWithId? currentUser;
  String? _selectedClass;
  FileProcessingResult? table;

  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      // User canceled the picker
      return null;
    }
  }

  // Create a list to store class data
  List<ClassDataWithId> classDataList = [];

  Future<void> sendMessage(String message, String type) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance; // Create an instance of FirebaseFirestore

    await firestore.collection('mail').add(
      {
        'to': ['support@info-mat.sk'],
        'message': {
          'subject': type,
          'text': message
        },
      },
    ).then(
      (value) {
        print('Queued email for delivery!');
      },
    );
    
    reShowToast( 'Správa odoslaná', false, context);
  }

  Future<void> fetchSchoolData() async {
    try {
      SchoolData school = await fetchSchool(widget.currentUserData!.school);
      admin = await fetchUser(school.admin);
      List<ClassDataWithId> tmp = [];



      setState(() {
        if (mounted) {
          if (widget.currentUserData!.admin) {
            classes = school.classes;
          } else {
            classes = widget.currentUserData!.classes;
          }
          teachers = school.teachers;
          adminId = school.admin;
          schoolName = school.name;
        }
      });

      // Fetch class data once and store it in classDataList with IDs
      for (String classId in classes) {
        ClassData classData = await fetchClass(classId);
        tmp.add(ClassDataWithId(classId, classData));
      }

       tmp.sort((a, b) => a.data.name.compareTo(b.data.name));

      setState(() {
       classDataList = tmp;
      });

          _loading = false;

    } catch (e) {
      print('Error fetching school data: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchSchoolData(); // Fetch the user data when the app starts
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());
    return _buildScreen(_selectedIndex);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return Align(
          alignment: Alignment.center,
          child: Container(
            alignment: Alignment.center,
            width: 950,
            height: 1080,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30,),
                Container(
                  width: 950,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).primaryColor
                  ),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schoolName!,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        '${widget.currentUserData!.name}  (meno učiteľa prihlaseného v účte)',
                        style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      
                    ],
                  ),
                ),
                SizedBox(height: 30,),
                MouseRegion(
                  cursor: widget.currentUserData!.admin ? SystemMouseCursors.click : SystemMouseCursors.basic,
                  child: GestureDetector(
                    child: admin != null ?Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: AppColors.getColor('mono').lightGrey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                admin!.name,
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                      color: AppColors.getColor('mono').black,
                                    ),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                'Správa účtu',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: AppColors.getColor('mono').grey,
                                    ),
                              ),
                            ],
                          ),
                          Spacer(),
                          if(widget.currentUserData!.admin)SvgPicture.asset('assets/icons/rightIcon.svg', color: AppColors.getColor('mono').grey, height: 12)
                        ],
                      ),
                    ) : Container(),
                    onTap:  () async {
                      if(widget.currentUserData!.admin) {
                        setState(() {
                        currentUser = UserDataWithId(adminId!, admin!);
                        _teacher = true;
                        _admin = true;
                        _editUserEmailController.text = admin!.email;
                        _editUserNameController.text = admin!.name;
                        _onNavigationItemSelected(4);
                      });
                      }
                      
                    }
                  ),
                ),
                SizedBox(height: 30,),
                Row(
                  children: [
                    Text(
                      'Triedy',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            color: AppColors.getColor('mono').darkGrey,
                          ),
                    ),
                    Spacer(),
                    if(widget.currentUserData!.admin)Container(
                      child:  ReButton(
                        color: "grey", 
                        text: '+ Pridať triedu', 
                        onTap: () {
                          _onNavigationItemSelected(5);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
               SizedBox(
                  width: 950,
                  height: 300, // Set a fixed height for your Wrap
                  child: Wrap(
                    spacing: 20, // Adjust spacing between items horizontally
                    runSpacing: 20, // Adjust spacing between items vertically
                    children: classDataList.map((classData) {
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child:GestureDetector(
                          onTap: () {
                            fetchSchoolData();
                            setState(() {
                              // Update the currentClass when a class is tapped
                              currentClass = classData;
                              _selectedClass = classData.id;
                              _onNavigationItemSelected(1);
                            });
                          },
                          child: Container(
                            height: 72,
                            width: 174,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.getColor('mono').lightGrey, width: 2),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Text(
                                classData.data.name,
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: AppColors.getColor('mono').black,
                                ),
                              ),
                            ),
                          ),
                        )
                      );
                    }).toList(),
                  ),
                ),
                Spacer(),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Contact(),       
                  SizedBox(width: 5,),
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
                                        widget.logOut();
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
              ),
              SizedBox(height: 30,)
            ],
          ),
        ),
      );
      case 1:
        return DesktopClasses(currentUserData: widget.currentUserData,
        onNavigationItemSelected: _onNavigationItemSelected, 
        selectedClass: _selectedClass, 
        teacher: (bool value) {
          setState(() {
            _teacher = value;
          });
        }, 
        editClassNameController:
        _editClassNameController, 
        currentClass: currentClass, 
        classes: classes, 
        editUserNameController: 
        _editUserNameController, 
        editUserEmailController: _editUserEmailController, 
        admin: _admin,
        currentUser: (String userId, UserData userData) {
          setState(() {
            currentUser = UserDataWithId(userId, userData);
          });
        }
      );
      case 2:
        return AddUser(
          classes: classes,
          currentClass: currentClass,
          currentUserData: widget.currentUserData,
          onNavigationItemSelected: _onNavigationItemSelected,
          selectedClass: _selectedClass,
          teacher: _teacher,
          userEmailController: _userEmailController,
          userNameController: _userNameController,
          userPasswordController: _userPasswordController,
        );
      case 3:
        return AddExistingUser(
          classes: classes,
          currentClass: currentClass,
          currentUserData: widget.currentUserData,
          onNavigationItemSelected: _onNavigationItemSelected,
          selectedClass: _selectedClass,
          teachers: teachers,
        );
      case 4:
        return UpdateUser(
          currentUserData: widget.currentUserData,
          admin: _admin,
          setAdmin: () {
            setState(() {
              _admin = false;
            });
          },
          currentClass: currentClass,
          currentUser: currentUser,
          editUserEmailController: _editUserEmailController,
          editUserNameController: _editUserNameController,
          editUserPasswordController: _editUserPasswordController,
          onNavigationItemSelected: _onNavigationItemSelected,
          teacher: _teacher,
          changeEmail: (String email) {
            setState(() {
              currentUser!.data.email = email;
            });
          },
          changeName: (String name) {
            setState(() {
              currentUser!.data.name = name;
            });
          },
        );
      case 5:
        return AddClass(
          classes: classes,
          currentUserData: widget.currentUserData,
          onNavigationItemSelected: _onNavigationItemSelected,
          teacher: _teacher,
          addSchoolData: (ClassDataWithId classData) {
            classDataList.add(classData);
          },
          addToList: (String value) {
            classes.add(value);
          },
        );
      case 6:
        return UpdateClass(
        classes: classes,
        currentUserData: widget.currentUserData, 
        onNavigationItemSelected: _onNavigationItemSelected, 
        selectedClass: _selectedClass, 
        teacher: _teacher, 
        editClassNameController: _editClassNameController, 
        currentClass: currentClass!, 
        currentUser: currentUser,
        removeSchoolData: (String classId) {
          classDataList.removeWhere((element) => element.id == classId);
        },
        update: fetchSchoolData,
      );
      case 7:
        return Xlsx(
        currentUserData: widget.currentUserData, 
        onNavigationItemSelected: _onNavigationItemSelected, 
        selectedClass: _selectedClass, 
        currentClass: currentClass!,
        classes: classes!,
      );
      default:
        return Container();
    }
  }

   void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

Future<Map<String, String>> fetchClassNames(List<String> classIds) async {
  final Map<String, String> classNames = {};

  for (final classId in classIds) {
    final classData = await fetchClass(classId); // Replace with your fetchClass implementation
    classNames[classId] = classData.name;
  }

  return classNames;
}









