import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/models/UserModel.dart';


class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function() logOut;
  final UserData? currentUserData;
  final Function(int) onNavigationItemSelected;
   final void Function() tutorial;

  const MobileAppBar({
    Key? key,
    required this.onNavigationItemSelected,
    required this.logOut,
    required this.currentUserData,
    required this.tutorial
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);


  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Theme.of(context).primaryColor, // Set the appbar background color
        elevation: 0,
        flexibleSpace:  currentUserData != null ? SafeArea(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Spacer(),
                    Text(
                        '${currentUserData!.points}/165',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    SizedBox(width: 4),
                    SvgPicture.asset('assets/icons/starYellowIcon.svg'),
                    SizedBox(width: 8),
                     IconButton(
                      icon: SvgPicture.asset('assets/icons/bellWhiteIcon.svg'),
                      onPressed: () => 
                        onNavigationItemSelected(4),
                    ),
                    SizedBox(width: 8),
                     IconButton(
                            icon: SvgPicture.asset('assets/icons/infoIcon.svg', color: Colors.white,),
                            onPressed: () {
                              tutorial();
                            },
                          ),
                    SizedBox(width: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                      onTap: () {
                        // Open profile overlay
                        onNavigationItemSelected(5);
                      },
                        child: CircularAvatar(name: currentUserData!.name, width: 16, fontSize: 16,), // Use user's image
                    ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              )
        ) : Container(),
      );
  }
}
  