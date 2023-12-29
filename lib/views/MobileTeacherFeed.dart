import 'package:flutter/material.dart';
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:infomat/models/ResultsModel.dart';

import 'dart:html' as html;


class MobileTeacherFeed extends StatefulWidget {
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

  MobileTeacherFeed({
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
    required this.studentsSum
  }) : super(key: key);

  @override
  State<MobileTeacherFeed> createState() => _MobileTeacherFeedState();
}

class _MobileTeacherFeedState extends State<MobileTeacherFeed> {
  bool _loading = true;


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

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    if(_loading) return Center(child: CircularProgressIndicator(),);
    return  Container(
            width: 900,
            child: SingleChildScrollView(
              child: Center(
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
                                Text(
                                    "Čas na dokončenie: 1 týždeň",
                                    style: TextStyle(color: AppColors.getColor('primary').lighter,),
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
                                            Text("${widget.studentsSum != 0 ? (widget.results![widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].points/widget.studentsSum).round() : 0}/${widget.results?[widget.weeklyCapitolIndex].tests[widget.weeklyTestIndex].questions.length}", style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
              ),
            ),
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
                          )
                        ),
                        ],
                      ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}