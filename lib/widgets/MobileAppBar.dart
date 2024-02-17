
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
import 'package:infomat/widgets/Widgets.dart';
import 'dart:async';

class MobileAppBar extends StatefulWidget {
    final int selectedIndex;
  final UserData? currentUserData;
  final ValueChanged<int> onItemTapped;
  final void Function() tutorial;
  final void Function(int) onNavigationItemSelected;
  void Function() fetch;



  MobileAppBar({
    Key? key,
    required this.currentUserData,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.tutorial,
    required this.onNavigationItemSelected,
    required this.fetch
  }) : super(key: key);

  @override
  State<MobileAppBar> createState() => _MobileAppBarState();
}

class _MobileAppBarState extends State<MobileAppBar> {
    bool seen = true;
  Timer? _timer;

  void fetchSeen () async {
    User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        UserData userData = await fetchUser(user.uid); // Assuming fetchUser is defined

        for (var notif in userData.notifications) {
          if(notif.seen == false) {
            setState(() {
            seen = false;
              
            });
          
          };
      }
    }
  }

  void _setupPeriodicCheck() {
    _timer = Timer.periodic(Duration(seconds: 90), (Timer t) => fetchSeen());
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
         widget.currentUserData!.teacher ? DropDown(currentUserData: widget.currentUserData,fetch: widget.fetch, onNavigationItemSelected: widget.onNavigationItemSelected, selectedIndex: widget.selectedIndex) : 
         Row(
          children: [
            Text(
              '${widget.currentUserData!.points}/168',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          SizedBox(width: 4),
          SvgPicture.asset('assets/icons/starYellowIcon.svg'),
          SizedBox(width: 8),
          ],
         ),
        if(widget.currentUserData!.teacher) const Spacer(),
        IconButton(
        icon: SvgPicture.asset('assets/icons/infoIcon.svg', color: Colors.white,),
        onPressed: () {
          widget.tutorial();
        },
      ),
      const SizedBox(width: 8),
        IconButton(
        icon: seen ?  SvgPicture.asset('assets/icons/bellWhiteIcon.svg') : SvgPicture.asset('assets/icons/notificationBellWhite.svg'),
        onPressed: () {
          if(widget.currentUserData!.teacher) {
           widget.onNavigationItemSelected(5);
            setState(() {
              seen = true;
            });
          } else {
            widget.onNavigationItemSelected(4);
            setState(() {
              seen = true;
            });
          }
        }
      ),
      if(!widget.currentUserData!.teacher)SizedBox(width: 8),
       if(!widget.currentUserData!.teacher)MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
          onTap: () {
            // Open profile overlay
            widget.onNavigationItemSelected(5);
          },
            child: CircularAvatar(name: widget.currentUserData!.name, width: 16, fontSize: 16,), // Use user's image
        ),
      ),
      const SizedBox(width: 10,)
      ],
    );
  }
}
