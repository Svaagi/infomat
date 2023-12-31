import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Add this import statement
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';

class Comments extends StatefulWidget {
  final Stream<List<CommentsData>> fetchCommentsStream;
  final void Function(int, [CommentsData?, int?]) onNavigationItemSelected;
  final UserData currentUserData;
  final PostsData? post;
  final String postId;
  final void Function(bool, int, String) setEdit;
  Comments({
    Key? key,
    required this.setEdit,
    required this.onNavigationItemSelected,
    required this.fetchCommentsStream,
    required this.currentUserData,
    required this.post,
    required this.postId
  }) : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
   String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}.${date.month}.${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

  }

  String sklon(int length) {
    if (length == 1) {
      return 'odpoveď';
    } else if (length > 1 && length < 5 ) {
      return 'odpovede';
    }
    return 'odpovedí';
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommentsData>>(
      stream: widget.fetchCommentsStream, // Replace with your stream to fetch comments for the selected post
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CommentsData> comments = snapshot.data!;
          return Container(
            width: 900, // set the maximum width to 900
            height: 550,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: MediaQuery.of(context).size.width < 1000 ?null :Border.all(
                color: AppColors.getColor('mono').lightGrey,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 10,),
                Container(
                  width: 900, // set the maximum width to 900
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: AppColors.getColor('mono').lightGrey)),
                    ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          SizedBox(height: 4.0),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 16.0),
                            child: CircularAvatar(name: widget.post!.user, width: 16, fontSize: 16,)
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              Text(
                                widget.post!.user,
                                style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                              ),
                              Text(
                                widget.post!.edited ? '${formatTimestamp(widget.post!.date)} (upravené)' : formatTimestamp(widget.post!.date),
                                style: TextStyle(
                                  color: AppColors.getColor('mono').grey,
                                ),
                              ),
                            
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(widget.post!.value),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Spacer(),
                          SvgPicture.asset('assets/icons/smallTextBubbleIcon.svg', color: AppColors.getColor('mono').grey,),
                          SizedBox(width: 4.0),
                          Text(widget.post!.comments.length.toString(),
                            style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: AppColors.getColor('mono').grey,
                              ),
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            sklon(widget.post!.comments.length),
                            style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: AppColors.getColor('mono').grey,
                              ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                Container(
                  width: 900,
                  height: 400,
                  child: ListView.builder(
                      itemCount: comments.length + 1,
                      itemBuilder: (context, index) {
                        if (index == comments.length ) {
                        return SizedBox(height: 100,);

                        } else {
                        CommentsData comment = comments[index];

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                        onTap: () {
                            if (MediaQuery.of(context).size.width < 1000) {
                              widget.onNavigationItemSelected(4,comment,index);
                            } else  {
                              widget.onNavigationItemSelected(2,comment,index);
                            }
                          },
                        child:Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(bottom: BorderSide(color: AppColors.getColor('mono').lightGrey)),
                          ),
                        padding: EdgeInsets.only(right: 32, left: 32, top: 16, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                SizedBox(height: 4.0),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 16.0),
                                  child: CircularAvatar(name: comment.user, width: 16, fontSize: 16,)
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    
                                    Text(
                                      comment.user,
                                      style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                    ),
                                    Text(
                                      comment.edited ? '${formatTimestamp(comment.date)} (upravené)' : formatTimestamp(comment.date),
                                      style: TextStyle(
                                        color: AppColors.getColor('mono').grey,
                                      ),
                                    ),
                                  
                                  ],
                                ),
                                Spacer(),
                                if(comment.userId == FirebaseAuth.instance.currentUser!.uid || widget.currentUserData.teacher)SvgDropdownPopupMenuButton(
                                      onUpdateSelected: () {
                                        // Call your updateCommentValue function here
                                        widget.setEdit(true, index, comment.value);
                                      },
                                      onDeleteSelected: () {
                                        // Call your deleteComment function here
                                       MediaQuery.of(context).size.width > 1000 ? showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              content: Container(
                                                height: 250,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        'Vymazať príspevok',
                                                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                          color: AppColors.getColor('mono').black,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        'Chystáte sa vymazať váš príspevok z diskusného fóra. Zároveň tým vymažete všetky odpovede žiakov. Táto akcia je nevratná.',
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                      ),
                                                    ),
                                                    SizedBox(height: 35,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center, // Center-align the buttons horizontally
                                                      children: [
                                                        Container(
                                                          width: 270,
                                                          height: 48,
                                                          child: ReButton(
                                                            color: "white",  
                                                            text: 'POKRAČOVAŤ V ÚPRAVÁCH',  
                                                            onTap: () {
                                                              Navigator.of(context).pop();
                                                            }
                                                          ),
                                                        ),
                                                        SizedBox(width: 20,), // Add spacing between buttons
                                                        Container(
                                                          width: 150,
                                                          height: 48,
                                                          child: ReButton(
                                                            color: "red",  
                                                            text: 'VYMAZAŤ',  
                                                            onTap: () {
                                                              deleteComment(widget.currentUserData.schoolClass, widget.postId ,index);
                                                              comments.removeAt(index);
                                                              Navigator.of(context).pop();
                                                            }
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ) : showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              content: Container(
                                                height: 250,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                // Add content for the AlertDialog here
                                                // For example, you can add form fields to input teacher data
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Spacer(),
                                                        MouseRegion(
                                                          cursor: SystemMouseCursors.click,
                                                          child: GestureDetector(
                                                            child: SvgPicture.asset('assets/icons/xIcon.svg', height: 10,),
                                                            onTap: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                      'Vymazať príspevok',
                                                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                          color: AppColors.getColor('mono').black,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                      'Chystáte sa vymazať váš príspevok z diskusného fóra. Zároveň tým vymažete všetky odpovede žiakov. Táto akcia je nevratná. ',
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child:  Container(
                                                        width: 150,
                                                        height: 48,
                                                        child:  ReButton(
                                                          color: "red", 
                                                          text: 'VYMAZAŤ',  
                                                          onTap: () {
                                                            deleteComment(widget.currentUserData.schoolClass, widget.postId ,index);
                                                              comments.removeAt(index);
                                                              Navigator.of(context).pop();
                                                          }
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      showEditOption: (!widget.currentUserData.teacher || comment.userId == FirebaseAuth.instance.currentUser!.uid),
                                    ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Text(comment.value),
                            SizedBox(height: 10.0),
                            ((comment.award || widget.currentUserData.teacher)&& !comment.teacher) ? Row(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/icons/commentIcon.svg'),
                                    Text('Odpovedať',
                                      style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        color: AppColors.getColor('mono').darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                               
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                       if(widget.currentUserData.teacher) {
                                          toggleCommentAward(widget.currentUserData.schoolClass, widget.postId, index, comment.userId, comment,widget.currentUserData.id);
                                       }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: comment.award ? AppColors.getColor('yellow').main : AppColors.getColor('mono').grey),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          height: 15,
                                          comment.award ?  'assets/icons/starYellowIcon.svg' : 'assets/icons/smallStarIcon.svg',
                                          color: comment.award ? AppColors.getColor('yellow').main : AppColors.getColor('mono').grey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          comment.award ? 'Ocenené' : 'Oceniť',
                                          style: TextStyle(
                                            color: comment.award ? AppColors.getColor('yellow').main : AppColors.getColor('mono').grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),

                                 if(MediaQuery.of(context).size.width > 1000) Row(
                                  children: [
                                    SvgPicture.asset('assets/icons/smallTextBubbleIcon.svg', color: AppColors.getColor('mono').grey,),
                                    SizedBox(width: 4.0),
                                    Text(comment.answers.length.toString(),
                                      style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: AppColors.getColor('mono').grey,
                                        ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      sklon(comment.answers.length),
                                      style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: AppColors.getColor('mono').grey,
                                        ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 4.0),
                              ],
                            ) : Row(
                              children: [
                                Row(
                                children: [
                                  SvgPicture.asset('assets/icons/commentIcon.svg'),
                                  Text('Odpovedať',
                                    style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: AppColors.getColor('mono').darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                                 Spacer(),
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/icons/smallTextBubbleIcon.svg', color: AppColors.getColor('mono').grey,),
                                    SizedBox(width: 4.0),
                                    Text(comment.answers.length.toString(),
                                      style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: AppColors.getColor('mono').grey,
                                        ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      sklon(comment.answers.length),
                                      style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: AppColors.getColor('mono').grey,
                                        ),
                                    ),
                                  ],
                                ),
                              ],
                            ) 
                            
                          ],
                        ),
                        )
                        )
                      );
                        }
                    },
                  ),
                )
              ]
            )
          );
        } else if (snapshot.hasError) {
          return Text('Error loading comments');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
