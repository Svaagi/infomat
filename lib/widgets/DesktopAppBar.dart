import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/DropDown.dart';
import 'package:infomat/widgets/NotificationsDropDown.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/models/UserModel.dart';

class DesktopAppBar extends StatefulWidget implements PreferredSizeWidget {
  final UserData? currentUserData;
  final Function(int) onNavigationItemSelected;
  int selectedIndex;
  final VoidCallback? onUserDataChanged;
  final void Function() tutorial;
  void Function() fetch;


  DesktopAppBar({
    Key? key,
    required this.currentUserData,
    required this.onNavigationItemSelected,
    required this.selectedIndex,
    this.onUserDataChanged,
    required this.tutorial,
    required this.fetch
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10);

  @override
  _DesktopAppBarState createState() => _DesktopAppBarState();
}

class _DesktopAppBarState extends State<DesktopAppBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero, // Remove the padding
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,
        flexibleSpace: widget.currentUserData != null
            ? SafeArea(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 20),
                      SvgPicture.asset(
                        'assets/logoFilled.svg',
                        height: 30,
                      ),
                      const SizedBox(width: 20),
                      buildNavItem(0, "assets/icons/homeIcon.svg","Domov", context),
                      buildNavItem(1, "assets/icons/starIcon.svg", "Výzvy", context),
                      buildNavItem(2, "assets/icons/textBubblesIcon.svg", "Diskusia", context),
                      buildNavItem(3, "assets/icons/bookIcon.svg",  "Vzdelávanie", context),
                      if(widget.currentUserData!.teacher)buildNavItem(4, "assets/icons/resultsIcon.svg",  "Výsledky", context),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(!widget.currentUserData!.teacher) Text(
                            '${widget.currentUserData!.points}/168',
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: AppColors.getColor('yellow').light,
                                ),
                          ),
                          const SizedBox(width: 8),
                          if(!widget.currentUserData!.teacher) SvgPicture.asset('assets/icons/starYellowIcon.svg'),
                          if(widget.currentUserData!.teacher && widget.currentUserData!.classes.length > 0)DropDown(currentUserData: widget.currentUserData, onUserDataChanged: widget.onUserDataChanged, fetch: widget.fetch, onNavigationItemSelected: widget.onNavigationItemSelected, selectedIndex: widget.selectedIndex),
                          const SizedBox(width: 16),
                          NotificationsDropDown(
                            currentUserData: widget.currentUserData, // Pass your user data
                            onNavigationItemSelected: widget.onNavigationItemSelected,
                            selectedIndex: widget.selectedIndex,
                          ),
                          if(!widget.currentUserData!.teacher)const SizedBox(width: 16),
                          IconButton(
                            icon: SvgPicture.asset('assets/icons/infoIcon.svg'),
                            onPressed: () {
                              widget.tutorial();
                            },
                          ),
                          if(!widget.currentUserData!.teacher)const SizedBox(width: 16),
                          if(!widget.currentUserData!.teacher)MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                widget.onNavigationItemSelected(5);
                                widget.selectedIndex = -1;
                              },
                              child: CircularAvatar(name: widget.currentUserData!.name, width: 16, fontSize: 16,),
                            ),
                          ),
                          if(widget.currentUserData!.teacher)const SizedBox(width: 16),
                          if(widget.currentUserData!.teacher)IconButton(
                            icon: SvgPicture.asset('assets/icons/adminIcon.svg'),
                            onPressed: () {
                              widget.onNavigationItemSelected(6);
                              widget.selectedIndex = -1;
                            }
                          ),
                          
                          const SizedBox(width: 30),
                        ],
                      )
                    ],
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  Widget buildNavItem(int index, String icon, String text, BuildContext context) {
  final bool isSelected = index == widget.selectedIndex;

  return Container(
    width: 150,
    height: 200,
    decoration: isSelected
        ? BoxDecoration(
            color: Theme.of(context).primaryColor,
          )
        : null,
    child: InkWell(
      onTap: () {
        setState(() {
          widget.selectedIndex = index;
        });
        widget.onNavigationItemSelected(index);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isSelected ? SvgPicture.asset(icon, color: isSelected ? Theme.of(context).colorScheme.onPrimary : AppColors.getColor('mono').black) : SvgPicture.asset(  icon, color: isSelected ? Theme.of(context).colorScheme.onPrimary : AppColors.getColor('mono').black,),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: isSelected ? Theme.of(context).colorScheme.onPrimary : AppColors.getColor('mono').black,
            ),
          ),
        ],
      ),
    ),
  );
}

}