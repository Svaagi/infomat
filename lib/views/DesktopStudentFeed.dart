import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'dart:html' as html;
import 'package:infomat/models/UserModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


class DesktopStudentFeed extends StatefulWidget {
  final Function(int) onNavigationItemSelected;
  final int? capitolLength;
  final int capitolsId;
  final int weeklyChallenge;
  final String? weeklyTitle;
  final String? futureWeeklyTitle;
  final bool weeklyBool;
  final int weeklyCapitolLength ;
  final int completedCount;
  final String? capitolTitle;
  final UserCapitolsData? capitolData;
  final String? capitolColor;
  void Function(void Function() start, void Function() end) init;
  List<dynamic> orderedData;
  void Function() addWeek;
  void Function() removeWeek;
      int weeklyCapitolIndex;
  int weeklyTestIndex;

  DesktopStudentFeed({
    Key? key,
    required this.capitolColor,
    required this.onNavigationItemSelected,
    required this.capitolData,
    required this.capitolLength,
    required this.capitolTitle,
    required this.capitolsId,
    required this.completedCount,
    required this.futureWeeklyTitle,
    required this.weeklyBool,
    required this.weeklyCapitolLength,
    required this.weeklyChallenge,
    required this.weeklyTitle,
    required this.orderedData,
    required this.init,
    required this.addWeek,
    required this.removeWeek,
    required this.weeklyCapitolIndex,
    required this.weeklyTestIndex,
  }) : super(key: key);

  @override
  State<DesktopStudentFeed> createState() => _DesktopStudentFeedState();
}

class _DesktopStudentFeedState extends State<DesktopStudentFeed> {
  bool isMobile = false;
  bool isDesktop = false;
  bool _loading = false;

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

  @override
  void initState()
    {
      super.initState();
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      isMobile = userAgent.contains('mobile');
      isDesktop = userAgent.contains('macintosh') ||
          userAgent.contains('windows') ||
          userAgent.contains('linux');

      sendFeedEvent();

    }
   
  @override
  Widget build(BuildContext context) {
    if (_loading) {
        return const Center(child: CircularProgressIndicator()); // Show loading circle when data is being fetched
    }
    return  SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50,),
                    Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 836,
                      height: 329,
                      decoration: BoxDecoration(
                        color: isMobile ?  null : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      child: Center(
                        child: !widget.weeklyBool ? Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Align items vertically to center
                          crossAxisAlignment: CrossAxisAlignment.center, // Align items horizontally to center
                          children: [
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Align items horizontally to center
                              children: [
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
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: SizedBox(
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
                            const SizedBox(height: 5,),
                            Text(
                                "Kapitola: ${widget.orderedData[widget.weeklyCapitolIndex]['name']}",
                                style: TextStyle(color: AppColors.getColor('primary').lighter,),
                              ),
                              const SizedBox(height: 5,),
                            Text(
                                "Čas na dokončenie: 1 týždeň",
                                style: TextStyle(color: AppColors.getColor('primary').lighter,),
                              ),
                            const SizedBox(height: 20,),
                            ReButton(color: "white" , text: 'ZAČAŤ', onTap:
                              () {
                                  widget.onNavigationItemSelected(1);
                              },
                            ),
                          ],
                        ) : Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Align items vertically to center
                          crossAxisAlignment: CrossAxisAlignment.center, // Align items horizontally to center
                          children: [
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Align items horizontally to center
                              children: [
                                SvgPicture.asset('assets/icons/greenCheckIcon.svg'),
                                Text(
                                  "Týždenná výzva splnená",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                    color: AppColors.getColor('primary').lighter,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Text(
                              "budúci týždeň ťa čaká",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                color: AppColors.getColor('primary').lighter,
                              ),
                            ),
                              Text(
                                textAlign: TextAlign.center,
                              widget.futureWeeklyTitle ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                                "Kapitola: ${widget.capitolTitle}",
                                style: TextStyle(color: AppColors.getColor('primary').lighter,),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  !widget.weeklyBool ? Container(
                    height: 320,
                    width: 804,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.getColor('mono').lightGrey,
                        width: 2,
                      ),
                    ),
                    margin: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Align items vertically to center
                        crossAxisAlignment: CrossAxisAlignment.center, // Align items horizontally to center
                        children: [
                          Image.asset(widget.orderedData[widget.weeklyCapitolIndex]['badge'],
                              height: 100,),

                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: SizedBox(
                                  width: 400, // Set your desired maximum width here
                                  child: Text(
                                    widget.weeklyTitle ?? '',
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      color: AppColors.getColor('mono').grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Splň týždennú výzvu pre',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                color: AppColors.getColor('mono').black,
                              ),
                            ),
                            Text(
                              'zobrazenie skóre',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                color: AppColors.getColor('mono').black,
                              ),
                            ),
                          ],
                        )
                  ) :  ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 350),
                        child:Container(
                          width: 804,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.getColor('mono').lightGrey,
                              width: 2,
                            ),
                          ),
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Doterajšie výsledky',
                                    style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!.copyWith(
                                        color: AppColors.getColor('mono').black,
                                      ),
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                  SizedBox(
                                    width:  630,
                                    height: 18,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: (widget.weeklyCapitolLength != 0) ? widget.completedCount / 10 : 0.0,
                                        backgroundColor: AppColors.getColor('blue').lighter,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.getColor('green').main),
                                      ),
                                    )
                                  ),
                                  SizedBox(width: isMobile ? 5 : 10),
                                  Text(
                                    "${widget.completedCount}/10 výziev hotových",
                                    style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          color: AppColors.getColor('mono').black,
                                        ),
                                    ),
                                  ]
                                ,) 
                                ],
                              ),
                            const SizedBox(height: 20),
                           SingleChildScrollView(
                                child: Column(
                                  children: (widget.capitolData?.tests ?? []).where((test) => test.completed == true).map((test) {
                                    return Container(
                                      height: 56,
                                      margin: const EdgeInsets.symmetric(vertical: 2),
                                      decoration: BoxDecoration(
                                        color: widget.capitolData?.tests[widget.weeklyChallenge] == test ?  AppColors.getColor(widget.capitolColor!).main : AppColors.getColor('mono').lighterGrey, // Grey background color
                                        borderRadius: BorderRadius.circular(10.0), // Rounded borders
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child:  Row(
                                        children: [
                                          Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              test.name,
                                              style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                      color: widget.capitolData?.tests[widget.weeklyChallenge] == test ? AppColors.getColor('mono').white : AppColors.getColor('mono').darkGrey ,
                                                  ),
                                              ),
                                              const SizedBox(height: 5,),
                                                Text(
                                                  '${test.points}/${test.questions.length} správných odpovedí',
                                                  style: TextStyle(color:  widget.capitolData?.tests[widget.weeklyChallenge] == test ? AppColors.getColor('mono').white : AppColors.getColor('mono').grey , fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                Text('+ ${test.points}',
                                                style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                          color: widget.capitolData?.tests[widget.weeklyChallenge] == test ? AppColors.getColor('mono').white : AppColors.getColor('mono').grey ,
                                                      ),
                                                  ),
                                                  const SizedBox(width: 8,),
                                                SvgPicture.asset('assets/icons/starYellowIcon.svg', height: 20,)
                                              ],
                                            )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  
                                ),
                              ),
                            const SizedBox(height: 10,),
                            SizedBox(
                              width: 280,
                              height: 40,
                              child: ReButton(
                                color: "grey", 
                                text: 'Zobraziť všetky výsledky',
                                rightIcon: 'assets/icons/arrowRightIcon.svg',
                                onTap: () {
                                    widget.onNavigationItemSelected(1);
                                }
                              ),
                            )
                        ],
                      )
                    ),
                  ),
                  
                ],
              ),
            ),
        );
  }
}