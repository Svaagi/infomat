import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/models/ClassModel.dart';

class AddClassView extends StatelessWidget {
  final UserData? currentUserData;
  final void Function(int) onNavigationItemSelected;
  final bool teacher;
  final TextEditingController classNameController;
  final void Function(ClassDataWithId) addSchoolData;
  final List<String> classes;
  final void Function(String) errorEdit;
  String errorText;
  final Function(String) addToList;
  

  AddClassView(
    {
      Key? key, required this.currentUserData,
      required this.onNavigationItemSelected,
      required this.teacher,
      required this.classNameController,
      required this.addSchoolData,
      required this.classes,
      required this.errorEdit,
      required this.errorText,
      required this.addToList
    }
  );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 900,
        height: 1080,
        padding: const EdgeInsets.all(8),
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
                    onNavigationItemSelected(0);
                  }
                ),
                Text(
                  'Späť',
                  style: TextStyle(color: AppColors.getColor('mono').darkGrey),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Pridať triedu',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 100,)
              ],
            ),
            const SizedBox(height: 40,),
            Text(
              'Napíšte názov triedy',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: AppColors.getColor('mono').black,
                  ),
            ),
            const SizedBox(height: 10,),
            Text(
              'Po kliknutí na “ULOŽIŤ” sa vytvorí nová trieda',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.getColor('mono').grey,
                  ),
            ),
            const SizedBox(height: 30,),
            Text(
              'Názov triedy',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.getColor('mono').grey,
                  ),
            ),
            const SizedBox(height: 10,),
            reTextField(
              '1.A',
              false,
              classNameController,
              AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
              errorText: errorText,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                      ReButton(
                        color: "green", 
                        text: 'ULOŽIŤ', 
                        onTap: () async {
                          bool exists = await doesClassNameExist(classNameController.text, classes);
                          if(classNameController.text != '' && !exists) {
                            errorEdit('');

                            addClass(classNameController.text, currentUserData!.school, addSchoolData, null, addToList);
                            
                            classNameController.text = '';
                            onNavigationItemSelected(0);
                            reShowToast('Trieda úspešne pridaná', false, context);
                          } else {
                              if(exists)errorEdit('Meno už existuje');
                              if(classNameController.text == '') errorEdit('Pole je povinné') ;

                              print(errorText);
                          }
                        },
                      ),
                ],
              )
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}