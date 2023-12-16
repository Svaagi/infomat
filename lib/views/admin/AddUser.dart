import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/controllers/auth.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:flutter/gestures.dart';

class AddUser extends StatefulWidget {
  final UserData? currentUserData;
  void Function(int) onNavigationItemSelected;
  String? selectedClass;
  final bool teacher;
  final TextEditingController userNameController;
  final TextEditingController userEmailController;
  final TextEditingController userPasswordController;
  final ClassDataWithId? currentClass;
  final List<String>? classes;

  AddUser(
    {
      Key? key, required this.currentUserData,
      required this.onNavigationItemSelected,
      required this.selectedClass,
      required this.teacher,
      required this.userEmailController, 
      required this.userNameController, 
      required this.userPasswordController,
      required this.currentClass,
      required this.classes
    }
  );

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  String _nameErrorText = '';
  String _emailErrorText = '';
  String _passwordErrorText = '';

  // Existing isValidEmail function
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    );
    return emailRegex.hasMatch(email);
  }
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
                    widget.selectedClass = null;
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
                      widget.teacher ? 'Pridať učiteľa' : 'Pridať žiaka',
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
              'Napíšte triedu, meno a email ${widget.teacher ? 'učiteľa' : 'žiaka'}',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: AppColors.getColor('mono').black,
                  ),
            ),
            const SizedBox(height: 10,),
            Text(
              'Po kliknutí na “ULOŽIŤ” sa učiteľovi odošle email s prihlasovacími údajmi',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.getColor('mono').grey,
                ),
            ),
            const SizedBox(height: 30,),
            Text(
              'Vybrať triedu',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.getColor('mono').grey,
                  ),
            ),
            const SizedBox(height: 10,),
            DropdownButton<String>(
              value: widget.selectedClass,
              hint: const Text('Select a class'),
              items: widget.classes!.map<DropdownMenuItem<String>>((String classId) {
                return DropdownMenuItem<String>(
                  value: classId,
                  child: FutureBuilder<ClassData>(
                    future: fetchClass(classId),
                    builder: (BuildContext context, AsyncSnapshot<ClassData> snapshot) {
                        return Text(snapshot.data?.name ?? 'Unknown Class');
                    },
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.selectedClass = newValue ?? '';
                });
              },
            ),
            const SizedBox(height: 10,),
            Text(
              'Meno a priezvisko ${widget.teacher ? 'učiteľa' : 'žiaka'}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.getColor('mono').grey,
                  ),
            ),
            const SizedBox(height: 10,),
            reTextField(
              'Jožko Mrkvička',
              false,
              widget.userNameController,
              AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
              errorText: _nameErrorText
            ),
            const SizedBox(height: 10,),
            Text(
              'Email ${widget.teacher ? 'učiteľa' : 'žiaka'}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.getColor('mono').grey,
                  ),
            ),
            reTextField(
              'jozko.mrkvicka@gmail.com',
              false,
              widget.userEmailController,
              AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
              errorText: _emailErrorText
            ),
            const SizedBox(height: 10,),
            Text(
              'Heslo ${widget.teacher ? 'učiteľa' : 'žiaka'}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.getColor('mono').grey,
                  ),
            ),
            reTextField(
              'Heslo',
              false,
              widget.userPasswordController,
              AppColors.getColor('mono').lightGrey, // assuming white is the default border color you want
              errorText: _passwordErrorText
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                    ReButton(
                    color: "green" , 
                    text: 'ULOŽIŤ', 
                    onTap: () async {
                      bool isUsed = await isEmailAlreadyUsed(widget.userEmailController.text);
                      bool validEmail = isValidEmail(widget.userEmailController.text);
                      setState(() {
                        if(validEmail) _emailErrorText = '';
                        if(!isUsed) _emailErrorText = '';
                      });
                      if(widget.userNameController.text != '' && widget.userEmailController.text != '' &&widget.userPasswordController.text != '' && widget.selectedClass != null) {
                        registerUser(widget.currentUserData!.school, widget.selectedClass!, widget.userNameController.text, widget.userEmailController.text, widget.userPasswordController.text, widget.teacher,context, widget.currentClass);
                        widget.userNameController.text = '';
                        widget.userEmailController.text = '';
                        widget.userPasswordController.text = '';
                      }
                      if(widget.userNameController.text == '') _nameErrorText = 'Pole je povinné';
                        if(widget.userEmailController.text == '') _emailErrorText = 'Pole je povinné';
                        if(widget.userPasswordController.text == '') _passwordErrorText = 'Pole je povinné';
                        if(isUsed) _emailErrorText = 'Účet s daným E-mailom už existuje';
                        if(!validEmail) _emailErrorText = 'Nesprávny formát E-mailu';
                      }
                  ),
                  const SizedBox(height: 30,),
                  if (widget.teacher) Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        'Ak učiteľ, ktorého chcete pridať, už má účet v aplikácií, ',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.getColor('mono').grey,
                          ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'pridáte ho tu.',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: AppColors.getColor('mono').grey,
                              decoration: TextDecoration.underline,
                          ),
                          // You can also add onTap to make it clickable
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Handle the tap event here, e.g., open a URL
                              // You can use packages like url_launcher to launch URLs.
                              widget.onNavigationItemSelected(3);
                            },
                        ),
                      ),
                    ],
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