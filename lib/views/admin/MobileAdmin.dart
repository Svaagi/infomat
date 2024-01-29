import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/controllers/userController.dart';
import 'package:infomat/controllers/convert.dart';
import 'package:infomat/controllers/SchoolController.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/models/SchoolModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:infomat/views/admin/MobileClasses.dart';
import 'package:infomat/views/admin/AddUser.dart';
import 'package:infomat/views/admin/AddExistingUser.dart';
import 'package:infomat/views/admin/UpdateUser.dart';
import 'package:infomat/providers/AddClassProvider.dart';
import 'package:infomat/views/admin/UpdateClass.dart';
import 'package:infomat/views/admin/Xlsx.dart';
import 'package:infomat/providers/ContactProvider.dart';



class MobileAdmin extends StatefulWidget {
  final UserData? currentUserData;
  final void Function() logOut;
  final void Function() onUserChanged;
  const MobileAdmin({Key? key, required this.currentUserData, required this.logOut, required this.onUserChanged});

  @override
  State<MobileAdmin> createState() => _MobileAdminState();
}

class _MobileAdminState extends State<MobileAdmin> {
  
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    return _buildScreen(_selectedIndex);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return SingleChildScrollView(
          child: SizedBox(
              width: 900,
              height: MediaQuery.of(context).size.height - 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30,),
                  Container(
                    width: 900,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(20),
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
                        const SizedBox(height: 10,),
                        Text(
                          '${widget.currentUserData!.name}  (meno učiteľa prihlaseného v účte)',
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                   MouseRegion(
                    cursor: widget.currentUserData!.admin ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: GestureDetector(
                      child: Container(
                            margin: const EdgeInsets.all(12),
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
                                    const SizedBox(height: 10,),
                                    Text(
                                      'Správa účtu',
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            color: AppColors.getColor('mono').grey,
                                          ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if(widget.currentUserData!.admin) SvgPicture.asset('assets/icons/rightIcon.svg', color: AppColors.getColor('mono').grey, height: 12)
                              ],
                            ),
                          ),
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
                  const SizedBox(height: 5,),
                  Container(
                    child: Row(
                      children: [
                        Text(
                          'Triedy',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: AppColors.getColor('mono').darkGrey,
                              ),
                        ),
                        const Spacer(),
                        if(widget.currentUserData!.admin)SizedBox(
                          width: 53,
                          height: 36,
                          child:  ReButton(
                            color: "grey", 
                            text: '', 
                            rightIcon: 'assets/icons/plusIcon.svg',
                            onTap: () {
                              _onNavigationItemSelected(5);
                            },
                          ),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(12),
                  ),
                  const SizedBox(height: 5,),
                  Expanded(
                  child: Column(
                    children: [
                      Expanded(
                   child: ListView.builder(
                      itemCount: classDataList.length,
                      itemBuilder: (context, index) {
                        final classData = classDataList[index];

                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // Update the currentClass when a class is tapped
                                currentClass = classData;
                                _selectedClass = classData.id;
                                _onNavigationItemSelected(1);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.getColor('mono').lightGrey,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    classData.data.name,
                                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                          color: AppColors.getColor('mono').black,
                                        ),
                                  ),
                                  SvgPicture.asset('assets/icons/rightIcon.svg', color: AppColors.getColor('mono').grey, height: 12),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                    ],
                  )
                  ),
                ],
              ),
            ),
        );
      case 1:
        return MobileClasses(currentUserData: widget.currentUserData,
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
          admin: _admin,
          currentUserData: widget.currentUserData,
          currentClass: currentClass,
          setAdmin: () {
            setState(() {
              _admin = false;
            });
          },
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
          classes: classes!,
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
        classes: classes!,  
        currentUserData:  widget.currentUserData, 
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
        classes: classes,
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









