import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/Colors.dart';
import 'dart:math';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/models/NotificationModel.dart';
import 'package:infomat/models/MaterialModel.dart';
import 'package:infomat/controllers/NotificationController.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/controllers/MaterialController.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
// Import other necessary packages and controllers

class CompleteNotification {
  final NotificationsData notification;
  final PostsData? postData;
  final CommentsData? commentData;
  final CommentsAnswersData? answerData;
  final MaterialData? materialData;
  final String avatar;

  CompleteNotification({
    required this.avatar,
    required this.notification,
    this.postData,
    this.commentData,
    this.answerData,
    this.materialData,
  });
}

class NotificationsDropDown extends StatefulWidget {
  UserData? currentUserData;
  final Function(int) onNavigationItemSelected;
  int selectedIndex;
  Function(UserData) setUser;

  NotificationsDropDown({
    required this.currentUserData,
    required this.onNavigationItemSelected,
    required this.selectedIndex,
    required this.setUser
  });

  @override
  _NotificationsDropDownState createState() => _NotificationsDropDownState();
}

class _NotificationsDropDownState extends State<NotificationsDropDown> {
  late Stream<List<CompleteNotification>> _notificationsDataStream;
  bool seen = true;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    fetchSeen();
    _notificationsDataStream = _fetchCompleteNotificationsStream();
    _setupPeriodicCheck();
  }

  void _setupPeriodicCheck() {
    _timer = Timer.periodic(Duration(seconds: 60), (Timer t) => fetchSeen());
    // Adjust the duration as needed. This example checks every 5 seconds.
  }

  void fetchSeen () async {
    User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        UserData userData = await fetchUser(user.uid); // Assuming fetchUser is defined

        for (var notif in userData.notifications) {
          if(notif.seen == false) {
            setState(() {
            seen = false;
              
            });
            widget.setUser(userData);
          
          };
      }
    }
  }

  Stream<List<CompleteNotification>> _fetchCompleteNotificationsStream() async* {
    // First, fetch user data
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserData userData = await fetchUser(user.uid); // Assuming fetchUser is defined
      widget.setUser(userData);

      // Now, fetch notifications based on user data
      while (true) {
        List<NotificationsData> notifications = await fetchNotifications(userData);
        List<CompleteNotification> completeNotifications = [];


      for (var notif in notifications) {
        switch (notif.type.type) {
          case 'post':
            {
              PostsData? postData = await _fetchPostById(userData.schoolClass, notif.type.id);
              completeNotifications.add(CompleteNotification(notification: notif, postData: postData, avatar: 'assets/avatars/DiscussionAvatar.svg'));
            }
            break;
          case 'comment':
            {
              String postId = notif.type.id;
              String commentIndex = notif.type.commentIndex;
              CommentsData? commentData = await _fetchCommentById(userData.schoolClass, postId, commentIndex);
              completeNotifications.add(CompleteNotification(notification: notif, commentData: commentData, avatar: 'assets/avatars/DiscussionAvatar.svg'));
            }
            break;

          case 'answer':
            {
              String postId = notif.type.id;
              String commentIndex = notif.type.commentIndex;
              String answerIndex = notif.type.answerIndex;
              CommentsAnswersData? answerData = await _fetchAnswerById(userData.schoolClass, postId, commentIndex, answerIndex);
              completeNotifications.add(CompleteNotification(notification: notif, answerData: answerData, avatar: 'assets/avatars/DiscussionAvatar.svg'));
            } 
            break;
          case 'learning':
            {
              MaterialData? materialData = await _fetchMaterialById(userData.schoolClass, notif.type.id);
              completeNotifications.add(CompleteNotification(notification: notif, materialData: materialData, avatar: 'assets/avatars/LearningAvatar.svg'));
            }
            break;
          default:
            {
              completeNotifications.add(CompleteNotification(notification: notif, avatar: 'assets/avatars/ChallengesAvatar.svg'));
            }
        }
      }

        completeNotifications..sort((a, b) => b.notification.date.compareTo(a.notification.date));
        yield completeNotifications.reversed.toList();
        await Future.delayed(Duration(seconds: 90)); 

      }
    } else {
      print('User is not logged in.');
      yield []; // Return an empty list if the user is not logged in
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}.${date.month}.${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: seen ?  SvgPicture.asset('assets/icons/bellIcon.svg') : SvgPicture.asset('assets/icons/notificationBell.svg'),
          onPressed: () async {
            _notificationsDataStream = await _fetchCompleteNotificationsStream();

            setAllNotificationsAsSeen(widget.currentUserData!);

            setState(() {
              seen = true;
            });

            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset(0.0, button.size.height), ancestor: overlay),
                button.localToGlobal(button.size.bottomRight(Offset(0.0, 0.0)), ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );

            showMenu(
              context: context,
              position: position,
              constraints: BoxConstraints(maxWidth: 500, minWidth: 390),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              items: [
                MyCustomPopupMenuItem(
                  child: StreamBuilder<List<CompleteNotification>>(
                    stream: _notificationsDataStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return  Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upozornenia',
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: AppColors.getColor('mono').black,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Text('Žiadne dostupné upozornenia'),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upozornenia',
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: AppColors.getColor('mono').black,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Column(
                                children: snapshot.data!
                                  .sublist(max(0, snapshot.data!.length - 3))
                                  .reversed
                                  .map((notification) {
                                    return _buildNotificationItem(notification);
                                  }).toList(),
                              ),
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 40,
                                  child: ReButton(
                                    color: "grey", 
                                    text: 'Zobraziť všetko',
                                    rightIcon: 'assets/icons/arrowRightIcon.svg',
                                    onTap: () {
                                      if (widget.currentUserData!.teacher) {
                                        widget.onNavigationItemSelected(5);
                                      } else {
                                        widget.onNavigationItemSelected(4);
                                      }
                                      setState(() {
                                        seen = true;
                                      });
                                      widget.selectedIndex = -1;
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}


Widget _buildNotificationItem(CompleteNotification completeNotification) {
  return Container(
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.getColor('mono').lighterGrey)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(completeNotification.avatar),
            ),
            SizedBox(width: 10),
            Container(
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(completeNotification.notification.title),
                  Text(formatTimestamp(completeNotification.notification.date)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(completeNotification.notification.content),
        SizedBox(height: 5),
        _getTypeContainer(completeNotification),
      ],
    ),
  );
}

Widget _getTypeContainer(CompleteNotification completeNotification) {
  if (completeNotification.notification.type.type == 'post' && completeNotification.postData != null) {
    return  GestureDetector(
      onTap: () {
        widget.onNavigationItemSelected(2);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child:_getPostOrCommentContainer(
          completeNotification.postData!.user,
          completeNotification.postData!.date,
          completeNotification.postData!.value,
        )
      )
    );
  }

  if (completeNotification.notification.type.type == 'comment' && completeNotification.commentData != null) {
    return  GestureDetector(
        onTap: () {
          widget.onNavigationItemSelected(2);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child:_getPostOrCommentContainer(
        completeNotification.commentData!.user,
        completeNotification.commentData!.date,
        completeNotification.commentData!.value,
          )
      )
    );
  }

  if (completeNotification.notification.type.type == 'answer' && completeNotification.answerData != null) {
    return GestureDetector(
      onTap: () {
        widget.onNavigationItemSelected(2);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _getPostOrCommentContainer(
          completeNotification.answerData!.user,
          completeNotification.answerData!.date,
          completeNotification.answerData!.value,
        ),
      ),
    );
  }

  if (completeNotification.notification.type.type == 'learning' && completeNotification.materialData != null) {
    return  Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 400,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: AppColors.getColor('primary').main,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.getColor('red').lighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          completeNotification.materialData!.type,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.getColor('red').main,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        completeNotification.materialData!.subject,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(height: 5), // Adjust spacing from the top for the text
                      Text(
                        completeNotification.materialData!.title,
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
    );
  }

  switch (completeNotification.notification.type.type) {
    case 'challenge':
      return Container(
      );
    default:
      return Container();
  }
}

Future<MaterialData?> _fetchMaterialById(String classId, String materialId) async {
  try {
    ClassData classData = await fetchClass(classId);
    List<MaterialData> materials = await fetchMaterials(classData.materials);
    for (MaterialData material in materials) {

      if (material.materialId == materialId) {
        return material;
      }
    }
    return null;
  } catch (e) {
    print('Error fetching material by ID: $e');
    throw Exception('Failed to fetch material');
  }
}

Widget _getPostOrCommentContainer(String user, Timestamp date, String value) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.getColor('primary').lighter,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: CircularAvatar(name: user, width: 16, fontSize: 16,),
            ),
            SizedBox(width: 10),
            Container(
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user),
                  Text(formatTimestamp(date)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(value),
        Row(children: [
          Expanded(child: Container(),),
          Row(
          children:[
             Text('Odpovedať',
              style: TextStyle(color: AppColors.getColor('primary').main),
             ),
             SvgPicture.asset('assets/icons/primaryArrowRightIcon.svg'),
          ]
          )
        ],)
      ],
    ),
  );
}

Future<PostsData?> _fetchPostById(String classId, String postId) async {
    try {
      ClassData classData = await fetchClass(classId);
      for (PostsData post in classData.posts) {
        if (post.id == postId) {
          return post;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching post by ID: $e');
      throw Exception('Failed to fetch post');
    }
  }

  Future<CommentsData?> _fetchCommentById(String classId, String postId, String commentIndex) async {
    try {
      ClassData classData = await fetchClass(classId);
      for (PostsData post in classData.posts) {
        if (post.id == postId) {
          int idx = int.parse(commentIndex);
          if (idx < post.comments.length) {
            return post.comments[idx];
          }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching comment by ID: $e');
      throw Exception('Failed to fetch comment');
    }
  }
}


  Future<CommentsAnswersData?> _fetchAnswerById(String classId, String postId, String commentIndex, String answerIndex) async {
    try {
      ClassData classData = await fetchClass(classId);
      for (PostsData post in classData.posts) {
        if (post.id == postId) {
          for (int i = 0; i < post.comments.length; i++) {
            int idc = int.parse(commentIndex);
            if (i == idc) {
              int ida = int.parse(answerIndex);
              if (ida < post.comments[idc].answers.length) {
                return post.comments[idc].answers[ida];
              }
            }
          };
        }
      }
      return null;
    } catch (e) {
      print('Error fetching answer by ID: $e');
      throw Exception('Failed to fetch answer');
    }
  }

class MyCustomPopupMenuItem extends PopupMenuEntry<void> {
  final Widget child;

  MyCustomPopupMenuItem({required this.child});

  @override
  _MyCustomPopupMenuItemState createState() => _MyCustomPopupMenuItemState();

  @override
  double get height => 500; // Set your height

  @override
  bool represents(void value) => false;
}

class _MyCustomPopupMenuItemState extends State<MyCustomPopupMenuItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: widget.child,
    );
  }
}


