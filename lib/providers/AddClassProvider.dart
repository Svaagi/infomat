import 'package:flutter/material.dart';
import 'package:infomat/views/admin/AddClassView.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';



class AddClass extends StatefulWidget {
  final UserData? currentUserData;
  final void Function(int) onNavigationItemSelected;
  final bool teacher;
  final void Function(ClassDataWithId) addSchoolData;
  final List<String> classes;
  

  const AddClass(
    {
      Key? key, required this.currentUserData,
      required this.onNavigationItemSelected,
      required this.teacher,
      required this.addSchoolData,
      required this.classes,
    }
  );

  @override
  State<AddClass> createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  TextEditingController _classNameController = TextEditingController();
  String errorText = '';

  void errorEdit (String error, String value) {
    setState(() {
      error = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AddClassView(
      addSchoolData: widget.addSchoolData,
      classNameController: _classNameController,
      classes: widget.classes,
      currentUserData: widget.currentUserData,
      errorEdit: errorEdit,
      errorText: errorText,
      onNavigationItemSelected: widget.onNavigationItemSelected,
      teacher: widget.teacher,
    );
  }
}