import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:infomat/models/ResultsModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/controllers/UserController.dart';



class MobileTeacherFeed extends StatefulWidget {
  final Function(int) onNavigationItemSelected;
  int? capitolLength;
  int weeklyChallenge;
  int weeklyCapitolIndex;
  int weeklyTestIndex;
  void Function(void Function() start, void Function() end) init;
  List<dynamic> orderedData;
  List<ResultCapitolsData>? results;
  int studentsSum;
  List<PostsData> posts;
    List<String> students;

  MobileTeacherFeed({
    Key? key,
    required this.onNavigationItemSelected,
    this.capitolLength,
    required this.weeklyChallenge,
    required this.init,
    required this.weeklyCapitolIndex,
    required this.weeklyTestIndex,
    required this.orderedData,
    this.results,
    required this.studentsSum,
    required this.posts,
    required this.students,
  }) : super(key: key);

  @override
  State<MobileTeacherFeed> createState() => _MobileTeacherFeedState();
}

class _MobileTeacherFeedState extends State<MobileTeacherFeed> {
  bool _loading = false;

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> sendFeedEvent() async {
    await analytics.logEvent(
      name: 'domov',
      parameters: {
        'page': 'domov', // replace with your actual page/screen name
      },
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}.${date.month}., ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

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
  void initState() {
     widget.init(() {
        setState(() {
        _loading = true;
      });
      }, () {
      setState(() {
        _loading = false;
      });
    });

    sendFeedEvent();

    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_loading) return Center(child: CircularProgressIndicator(),);
    return  SingleChildScrollView(
      child: Container(
            width: 900,
            child:  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, // Align items vertically to center
                              crossAxisAlignment: CrossAxisAlignment.center, // Align items horizontally to center
                              children: [
                                SizedBox(height: 30,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center, // Align items horizontally to center
                                  children: [
                                    SvgPicture.asset('assets/icons/smallStarIcon.svg', color: AppColors.getColor('primary').lighter),
                                    SizedBox(width: 8,),
                                    Text(
                                      "Týždenná výzva #${widget.weeklyChallenge + 1}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                        color: AppColors.getColor('primary').lighter,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Container(
                                      width: 400, // Set your desired maximum width here
                                      child: Text(
                                        widget.orderedData[widget.weeklyCapitolIndex]['tests'][widget.weeklyTestIndex]['name'] ?? '',
                                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center, // Align items vertically to center
                                  crossAxisAlignment: CrossAxisAlignment.center, 
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                          color: AppColors.getColor('primary').light,
                                          ),
                                          child: Row(
                                          children: [
                                            Text("${(widget.results![widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].completed != 0 ? widget.results![widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].points/widget.results![widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].completed : 0).round()}/${widget.results?[widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].questions.length}", style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            ),),
                                            SizedBox(width: 4,),
                                            Padding(padding: EdgeInsets.only(bottom: 5), child: SvgPicture.asset('assets/icons/starYellowIcon.svg'),)
                                            
                                          ],
                                        )
                                        ),
                                          Text('priemerné skóre',
                                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                                          ),
                                      ],
                                    ),
                                    SizedBox(width: 16,),
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          width: 60,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                          color: AppColors.getColor('primary').light,
                                          ),
                                          child: Text("${widget.results![widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].completed}/${widget.studentsSum}",style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),),
                                        ),
                                        Text('študentov dokončilo',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                                        )
                                      ],
                                    )
                                      
                                  ],
                                ),
                                SizedBox(height: 16,),
                                SizedBox(
                                      width: 170,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          widget.onNavigationItemSelected(1);
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
              // Replace with your desired icon
                                            Text(
                                              'Zobraziť test',
                                              style: TextStyle(
                                                color:  AppColors.getColor("mono").white,
                                                fontFamily: GoogleFonts.inter(fontWeight: FontWeight.w500).fontFamily
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(width: 5,),
                                            SvgPicture.asset('assets/icons/arrowRightIcon.svg', color: AppColors.getColor("mono").white)
                                          ],
                                        ),
                                        style: ButtonStyle(
                                          elevation: MaterialStateProperty.all(0), // Set elevation to 0 for a flat appearance
                                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                                            if (states.contains(MaterialState.disabled)) {
                                              return AppColors.getColor("mono").lightGrey;
                                            } else if (states.contains(MaterialState.pressed)) {
                                              return  Color(0xff7579d2);
                                            } else if (states.contains(MaterialState.hovered)) {
                                              return Color(0xff7579d2);
                                            } else {
                                              return Color(0xff7579d2);
                                            }
                                          }),
                                          side: MaterialStateProperty.resolveWith((states) {
                                            if (states.contains(MaterialState.pressed)) {
                                              AppColors.getColor('blue').lighter;
                                            } else {
                                              return BorderSide.none;
                                            }
                                          }),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                              ],
                            )
                          ),
                        ),
                      ),
                       Transform.translate(
                          offset: Offset(0, -1),  // This might help to snap the SVG directly against the container above
                          child: SvgPicture.asset(
                            'assets/bottomBackground.svg',
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                            color: AppColors.getColor('primary').light,
                          ),
                        ),
                        
                  Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        'Výsledky',
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                        (widget.results![0].points > 0) ? Container(
                              constraints: BoxConstraints(
                                minHeight: 142
                              ),
                              width: 804,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.getColor('mono').lightGrey,
                                  width: 2,
                                ),
                              ),
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                Container(
                                    alignment: Alignment.center,
                                    child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.students.length > 6 ? 6 + 1 : widget.students.length + 1,
                                    itemBuilder: (context, index) {
                                     if (index == 0) {
                                        // Return a special container for the first item
                                        return Container(
                                            padding: const EdgeInsets.all(10),
                                            height: 60,
                                            decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(color: AppColors.getColor('mono').lightGrey)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Meno žiaka',
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                        color: AppColors.getColor('mono').grey,
                                                      ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Posledný test ',
                                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                        color: AppColors.getColor('mono').grey,
                                                      ),
                                                  ),
                                              ],
                                            ),
                                      );
                                      } else {
                                        // Your existing code for other items
                                        final userId = widget.students[index - 1];  // Adjust index since we added a special first item
                                        return FutureBuilder<UserData>(
                                          future: fetchUser(userId),
                                          builder: (context, userSnapshot) {
                                          if (userSnapshot.hasError) {
                                            print('Error fetching user data: ${userSnapshot.error}');
                                            return Container();
                                          } else if (!userSnapshot.hasData) {
                                            return const Center(child: CircularProgressIndicator());
                                          } else {
                                            UserData userData = userSnapshot.data!;
                                            return Container(
                                                  padding: const EdgeInsets.all(10),
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border(bottom: BorderSide(color: AppColors.getColor('mono').lightGrey)),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          '${userData.name}',
                                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                                color: AppColors.getColor('mono').black,
                                                              ),
                                                        ),
                                                        Spacer(),
                                                       Text(
                                                          '${userData.capitols[widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].points}/${userData.capitols[widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].questions.length}',
                                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                                color: AppColors.getColor('mono').black,
                                                              ),
                                                        ),
                                                        SizedBox(width: 20,)
                                                    ],
                                                  ),
                                            );
                                          }
                                        },
                                      );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Center(
                                  child: SizedBox(
                                    width: 280,
                                    height: 40,
                                    child: ReButton(
                                      color: "grey", 
                                      text: 'Zobraziť známkovanie',
                                      rightIcon: 'assets/icons/arrowRightIcon.svg',
                                      onTap: () {
                                          widget.onNavigationItemSelected(4);
                                      }
                                    ),
                                  ),
                                )
                            ],
                          )
                          ) : Container(
                                height: 142,
                                width: 804,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.getColor('mono').lightGrey,
                                    width: 2,
                                  ),
                                ),
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                  Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(12),
                                      height: 100,
                                      color: AppColors.getColor('mono').lighterGrey,
                                      child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Tu uvidíte výsledky vašich študentov. Celý prehľad je k dispozícií v sekcii ', style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                        ),),
                                          Text.rich(
                                            TextSpan(
                                              text: 'Výsledky.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                  decoration: TextDecoration.underline,
                                              ),
                                              // You can also add onTap to make it clickable
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  // Handle the tap event here, e.g., open a URL
                                                  // You can use packages like url_launcher to launch URLs.
                                                  widget.onNavigationItemSelected(4);
                                                },
                                            ),
                                          ),
                                        ],
                                      )
                                      
                                  )
                              ],
                            )
                          ),
                        ],
                      ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diskusia',
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                        Container(
                              constraints: BoxConstraints(
                                minHeight: 142
                              ),
                              width: 804,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.getColor('mono').lightGrey,
                                  width: 2,
                                ),
                              ),
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(12),
                                    color: widget.posts.length == 0 ? AppColors.getColor('mono').lighterGrey : null,
                                    child:  widget.posts.length == 0 ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Ešte nebol pridaný žiaden príspevok. Nové príspevky môžete pridávať prostredníctvom sekcie ', style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                      ),),
                                        Text.rich(
                                          TextSpan(
                                            text: 'Diskusia.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                decoration: TextDecoration.underline,
                                            ),
                                            // You can also add onTap to make it clickable
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Handle the tap event here, e.g., open a URL
                                                // You can use packages like url_launcher to launch URLs.
                                                widget.onNavigationItemSelected(2);
                                              },
                                          ),
                                        ),
                                      ],
                                    ):  ListView.builder(
                            shrinkWrap: true,
                               itemCount: widget.posts.length > 2 ? 2 : widget.posts.length,  // Specify the number of items in the list
                                itemBuilder: (context, index) {
                                    // This builder is called for each item of the list
                                    return 
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        padding: EdgeInsets.all(8),
                                        width: 300,                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.getColor('mono').lightGrey,
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(right: 16.0),
                                            child: CircularAvatar(name: widget.posts[index].user, width: 16, fontSize: 16,),
                                          ),
                                          Column(
                                            
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.posts[index].user,
                                                style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    color: Theme.of(context).colorScheme.onBackground,
                                                  ),
                                              ),
                                              
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                        Text(widget.posts[index].value),
                                      const SizedBox(height: 10.0),
                                      Row(
                                          children: [
                                            SvgPicture.asset('assets/icons/smallTextBubbleIcon.svg', color: AppColors.getColor('mono').grey,),
                                            const SizedBox(width: 4.0),
                                            Text(widget.posts[index].comments.length.toString(),
                                              style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                  color: AppColors.getColor('mono').grey,
                                                ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              sklon(widget.posts[index].comments.length),
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
                                      );
                                     
                                  }
                              )
                                ),
                                Center(
                                  child: SizedBox(
                                    width: 180,
                                    height: 40,
                                    child: ReButton(
                                      color: "grey", 
                                      text: 'Zobraziť viac',
                                      rightIcon: 'assets/icons/arrowRightIcon.svg',
                                      onTap: () {
                                          widget.onNavigationItemSelected(2);
                                      }
                                    ),
                                  ),
                                )
                            ],
                          )
                        ),
                        
                        ],
                      )
                  ),
                ],
              ),
            ),
      )
        );
  }
}