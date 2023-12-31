import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:flutter/gestures.dart'; 
import 'package:infomat/models/ResultsModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/models/ClassModel.dart';


import 'dart:html' as html;


class DesktopTeacherFeed extends StatefulWidget {
  final Function(int) onNavigationItemSelected;
  int? capitolLength;
  int weeklyChallenge;
  int weeklyCapitolIndex;
  int weeklyTestIndex;
  void Function(void Function() start, void Function() end) init;
  List<dynamic> orderedData;
  void Function() addWeek;
  void Function() removeWeek;
  List<ResultCapitolsData>? results;
  int studentsSum;
  List<PostsData> posts;


  DesktopTeacherFeed({
    Key? key,
    required this.onNavigationItemSelected,
    this.capitolLength,
    required this.weeklyChallenge,
    required this.init,
    required this.weeklyCapitolIndex,
    required this.weeklyTestIndex,
    required this.orderedData,
    required this.addWeek,
    required this.removeWeek,
    this.results,
    required this.studentsSum,
    required this.posts
  }) : super(key: key);

  @override
  State<DesktopTeacherFeed> createState() => _DesktopTeacherFeedState();
}

class _DesktopTeacherFeedState extends State<DesktopTeacherFeed> {
  bool _loading = true;

  final userAgent = html.window.navigator.userAgent.toLowerCase();

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
    return "${date.day}.${date.month}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

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
    super.initState();

    sendFeedEvent();

    widget.init(() {
      setState(() {
      _loading = true;
    });
    }, () {
    setState(() {
      _loading = false;
    });
    });

  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
        return Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
    }
    return   SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 836,
                      height: 329,
                      decoration: BoxDecoration(
                        color: AppColors.getColor('primary').light,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child:  Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30,),
                            Row(
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: 153,
                                  child: ReButton(color: 'grey',text: 'pridať týždeň', onTap: () {
                                    widget.addWeek();
                                    widget.init(() {
                                      setState(() {
                                      _loading = true;
                                    });
                                    }, () {
                                    setState(() {
                                      _loading = false;
                                    });
                                    });
                                  }),
                                ),
                                
                                SizedBox(
                                  height: 40,
                                  width: 168,
                                  child: ReButton(color: 'grey',text: 'odobrať týždeň', onTap: () {
                                    widget.removeWeek();
                                    widget.init(() {
                                        setState(() {
                                        _loading = true;
                                      });
                                      }, () {
                                      setState(() {
                                        _loading = false;
                                      });
                                      });
                                  }),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 40,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                                
                                Column(
                                mainAxisAlignment: MainAxisAlignment.center, // Align items vertically to center
                                crossAxisAlignment: CrossAxisAlignment.start, // Align items horizontally to center
                                children: [
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
                                  SizedBox(height: 16), // Add some spacing between the items
                                  Container(
                                      width: 400, // Set your desired maximum width here
                                      child: Text(
                                        widget.orderedData[widget.weeklyCapitolIndex]['tests'][widget.weeklyTestIndex]['name'] ?? '',
                                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 5,),
                                    Text(
                                        "Kapitola: ${widget.orderedData[widget.weeklyCapitolIndex]['name']}",
                                        style: TextStyle(color: AppColors.getColor('primary').lighter,),
                                    ),
                                    SizedBox(height: 5,),
                                    Text(
                                        "Čas na dokončenie",
                                        style: TextStyle(color: AppColors.getColor('primary').lighter,),
                                      ),
                                  SizedBox(height: 16), // Add some spacing between the items
                                  Container(
                                    height: 40,
                                    width:  170,
                                    child:  ReButton(
                                      color: "primary", 
                                      text: 'Zobraziť test',
                                      rightIcon: 'assets/icons/arrowRightIcon.svg',
                                      onTap: () {
                                        widget.onNavigationItemSelected(1);
                                      },
                                    ),
                                  ),
                                  
                                ],
                              ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center, // Align items vertically to center
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [
                                    (widget.results == null || widget.studentsSum == 0) ? Container(
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                      color: AppColors.getColor('primary').lighter,
                                      ),
                                    ) : Row(
                                      children: [
                                        Text(
                                          "${(widget.results![widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].points/widget.studentsSum).round()}/${widget.results?[widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].questions.length}",
                                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: SvgPicture.asset('assets/icons/starYellowIcon.svg', width: 30,),
                                        )
                                      ],
                                    ),
                                    
                                    
                                      Text('priemerné skóre',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                                      ),
                                      SizedBox(height: 20,),
                                      (widget.results == null || widget.studentsSum == 0) ? Container(
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                      color: AppColors.getColor('primary').lighter,
                                      ),
                                    ) : Text(
                                        "${widget.results![widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].completed}/${widget.studentsSum}",
                                       style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                      Text('študentov dokončilo',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                                      )
                                  ],
                                )
                              ]
                            ),
                          ]
                        )
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  Align(
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
                        Container(
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
                              margin: EdgeInsets.all(16),
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
                  Align(
                    alignment: Alignment.center,
                    child:  Column(
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
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.all(16),
                              child: widget.posts.length == 0 ? Column(
                                children: [
                                Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(12),
                                    height: 100,
                                    color: AppColors.getColor('mono').lighterGrey,
                                    child: Column(
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
                                    )
                                    
                                )
                            ],
                          ) : ListView.builder(
                            shrinkWrap: true,
                               itemCount: widget.posts.length > 2 ? 2 : widget.posts.length,  // Specify the number of items in the list
                                itemBuilder: (context, index) {
                                    // This builder is called for each item of the list
                                    return Row(
                                      
                                    children: [
                                      Container(
                                      width: 100,

                                        child: Column(
                                        children: [
                                          Row(
                                          children: [
                                            const Spacer(),
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
                                        SizedBox(height: 5,),
                                        Text(
                                                widget.posts[index].edited ? '${formatTimestamp(widget.posts[index].date)} (upravené)' : formatTimestamp(widget.posts[index].date),
                                                style: TextStyle(
                                                  color: AppColors.getColor('mono').grey,
                                                ),
                                              ),
                                        ]
                                        )
                                      ),
                                      SizedBox(width: 10,),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        padding: EdgeInsets.all(8),
                                        width: 600,
                                        decoration: BoxDecoration(
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
                                          ],
                                        ),
                                      ),
                                      
                                        
                                      ],
                                    );
                                  }
                              )
                                ),
                            ],
                          )
                  
                  ),
                ],
              ),
            ),
        );
  }
}