import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';


class UpdateClass extends StatefulWidget {
  final UserData? currentUserData;
  final void Function(int) onNavigationItemSelected;
  final String? selectedClass;
  final bool teacher;
  final TextEditingController editClassNameController;
  final ClassDataWithId? currentClass;
  final UserDataWithId? currentUser;
  final void Function(String) removeSchoolData;
  final List<String> classes;
  
  

  UpdateClass(
    {
      Key? key, required this.currentUserData,
      required this.onNavigationItemSelected,
      required this.selectedClass,
      required this.teacher,
      required this.editClassNameController, 
      required this.currentClass,
      required this.currentUser,
      required this.removeSchoolData,
      required this.classes
    }
  );

  @override
  State<UpdateClass> createState() => _UpdateClassState();
}

class _UpdateClassState extends State<UpdateClass> {
  String _textError = '';
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 900,
        height: 1080,
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.getColor('mono').darkGrey,
                  ),
                  onPressed: () {
                    widget.onNavigationItemSelected(1);
                  },
                ),
                Text(
                  'Späť',
                  style: TextStyle(color: AppColors.getColor('mono').darkGrey),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        '${widget.currentClass!.data.name}/ Upraviť triedu',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 100,)
              ],
            ),
            SizedBox(height: 30,),
            reTextField(
              '1.A',
              false,
              widget.editClassNameController,
              AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
              errorText:  _textError
            ),
            Spacer(),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                alignment: WrapAlignment.center,
              children: [
                ReButton(
                  color: "white", 
                  leftIcon: 'assets/icons/binIcon.svg',
                  text: 'Vymazať triedu', 
                  onTap: () {
                      widget.onNavigationItemSelected(0);
                      deleteClass(widget.currentClass!.id, widget.currentUserData!.school, widget.removeSchoolData);
                      removeClassFromSchool(widget.currentClass!.id, widget.currentUserData!.school);
                      reShowToast('Trieda úspešne vymazaná', false, context);
                      deleteUserFunction(widget.currentClass!.data.students, widget.currentUser!.data, context, widget.currentClass);
                    }
                ),
              ReButton(
                color: "green", 
                text: 'ULOŽIŤ', 
                onTap: () async {
                  bool exists = await doesClassNameExist(widget.editClassNameController.text, widget.classes);
                  if(widget.editClassNameController.text != '' && !exists) {
                    widget.currentClass!.data.name = widget.editClassNameController.text;
                  editClass(widget.currentClass!.id,
                  ClassData(
                    name: widget.editClassNameController.text,
                    school: widget.currentClass!.data.school,
                    students: List<String>.from(widget.currentClass!.data.students),
                    teachers: List<String>.from(widget.currentClass!.data.teachers),
                    materials: List<String>.from(widget.currentClass!.data.materials),
                    capitolOrder: List<int>.from(widget.currentClass!.data.capitolOrder),
                    posts: widget.currentClass!.data.posts.map((post) {
                      return PostsData(
                        date: post.date,
                        id: post.id,
                        userId: post.userId,
                        edited: post.edited,
                        user: post.user,
                        value: post.value,
                        comments: post.comments.map((comment) {
                          return CommentsData(
                            teacher: comment.teacher,
                            award: comment.award,
                            edited: comment.edited,
                            userId: comment.userId,
                            answers: comment.answers.map((answer) {
                              return CommentsAnswersData(
                                award: answer.award,
                                teacher: answer.teacher,
                                date: answer.date,
                                edited: answer.edited,
                                userId: answer.userId,
                                user: answer.user,
                                value: answer.value,
                              );
                            }).toList(),
                            date: comment.date,
                            user: comment.user,
                            value: comment.value,
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ));
                  widget.editClassNameController.text = '';
                  reShowToast('Trieda úspešne upravená', false, context);
                  } else {
                    if(widget.editClassNameController.text == '') _textError = 'Pole je povinné';
                    if(exists) _textError = 'Meno už existuje';
                  }
                  
                },
              ),
              ]
              )
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}