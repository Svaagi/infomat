
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/DropDown.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/models/NotificationModel.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/controllers/NotificationController.dart';
import 'dart:async';

class TeacherMobileAppBar extends StatefulWidget {
    final int selectedIndex;
  final UserData? currentUserData;
  final ValueChanged<int> onItemTapped;
  final void Function() logOut;
  final VoidCallback? onUserDataChanged;
  final void Function() tutorial;
  final void Function(int) onNavigationItemSelected;
  void Function() fetch;



  TeacherMobileAppBar({
    Key? key,
    required this.currentUserData,
    required this.logOut,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onUserDataChanged,
    required this.tutorial,
    required this.onNavigationItemSelected,
    required this.fetch
  }) : super(key: key);

  @override
  State<TeacherMobileAppBar> createState() => _TeacherMobileAppBarState();
}

class _TeacherMobileAppBarState extends State<TeacherMobileAppBar> {
    bool seen = true;
  Timer? _timer;

  void fetchSeen () async {
    User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        UserData userData = await fetchUser(user.uid); // Assuming fetchUser is defined
          List<NotificationsData> notifications = await fetchNotifications(userData);

        for (var notif in notifications) {
          if(notif.seen == false) {
            setState(() {
            seen = false;
              
            });
          
          };
      }
    }
  }

  void _setupPeriodicCheck() {
    _timer = Timer.periodic(Duration(seconds: 60), (Timer t) => fetchSeen());
    // Adjust the duration as needed. This example checks every 5 seconds.
  }

  @override
  void initState() {
    super.initState();
    fetchSeen();
    _setupPeriodicCheck();
  }

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
         DropDown(currentUserData: widget.currentUserData, onUserDataChanged: widget.onUserDataChanged, fetch: widget.fetch, onNavigationItemSelected: widget.onNavigationItemSelected, selectedIndex: widget.selectedIndex),
        const Spacer(),
        IconButton(
        icon: SvgPicture.asset('assets/icons/infoIcon.svg', color: Colors.white,),
        onPressed: () {
          widget.tutorial();
        },
      ),
      const SizedBox(width: 8),
        IconButton(
        icon: seen ?  SvgPicture.asset('assets/icons/bellWhiteIcon.svg') : SvgPicture.asset('assets/icons/notificationBellWhite.svg'),
        onPressed: () => 
          widget.onNavigationItemSelected(5),
      ),
      const SizedBox(width: 10,)
      ],
    );
  }
}
