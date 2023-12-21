import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/DropDown.dart';
import 'package:infomat/models/UserModel.dart';

class TeacherMobileAppBar extends StatelessWidget {
  final int selectedIndex;
  final UserData? currentUserData;
  final ValueChanged<int> onItemTapped;
  final void Function() logOut;
  final VoidCallback? onUserDataChanged;
  final void Function() tutorial;
  final void Function(int) onNavigationItemSelected;


  const TeacherMobileAppBar({
    Key? key,
    required this.currentUserData,
    required this.logOut,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onUserDataChanged,
    required this.tutorial,
    required this.onNavigationItemSelected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,

      backgroundColor: AppColors.getColor('primary').light,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        SizedBox(width: 50,), // Pushes the following widgets to the middle

        const Spacer(),
         DropDown(currentUserData: currentUserData, onUserDataChanged: onUserDataChanged,),
        const Spacer(),
        IconButton(
        icon: SvgPicture.asset('assets/icons/infoIcon.svg', color: Colors.white,),
        onPressed: () {
          tutorial();
        },
      ),
      const SizedBox(width: 8),
        IconButton(
        icon: SvgPicture.asset('assets/icons/bellWhiteIcon.svg'),
        onPressed: () => 
          onNavigationItemSelected(5),
      ),
      const SizedBox(width: 10,)
      ],
    );
  }

}
