import 'package:flutter/material.dart';
import 'package:infomat/widgets/MaterialCardWidget.dart';
import 'package:infomat/widgets/MaterialForm.dart';
import 'package:infomat/controllers/MaterialController.dart';
import 'package:infomat/controllers/ClassController.dart';
import 'package:infomat/Colors.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'dart:html' as html;
import 'dart:async';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/models/MaterialModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';



class Learning extends StatefulWidget {
  final UserData? currentUserData;


  Learning({
    Key? key,
    required this.currentUserData,
  }) : super(key: key);

  @override
  _LearningState createState() => _LearningState();
}

class _LearningState extends State<Learning> {
  bool showAll = true;
   ClassData? currentClassData ;
   final PageController _pageController = PageController();
   bool _loading = true;
   bool isMobile = false;
  bool isDesktop = false;
  bool _add = false;
  List<String> favouriteMaterials = [];
  UserData? userData;

  final userAgent = html.window.navigator.userAgent.toLowerCase();

  fetchCurrentClass() async {
    try {
        ClassData classData = await fetchClass(widget.currentUserData!.schoolClass);
        // Fetch the user data using the fetchUser function
        if (mounted) {
          setState(() {
            userData = widget.currentUserData;
            currentClassData = classData;
            _loading = false;
            favouriteMaterials = widget.currentUserData!.materials;
          });
        }
      
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> sendDiscussionsEvent() async {
    await analytics.logEvent(
      name: 'vzdelávanie',
      parameters: {
        'page': 'vzdelávanie', // replace with your actual page/screen name
      },
    );
  }



  @override
  void initState() {
    super.initState();
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    isMobile = userAgent.contains('mobile');
    isDesktop = userAgent.contains('macintosh') ||
        userAgent.contains('windows') ||
        userAgent.contains('linux');
    fetchCurrentClass();
  }

  @override
  void dispose() {
    // Cancel timers or stop animations...

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_loading) return Center(child: CircularProgressIndicator());
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
        children: [
        Center( 
          child: Container(
          alignment: Alignment.center,
          width: 900,
          child: Column(
            children: [
              SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showAll = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: showAll ? AppColors.getColor('mono').lighterGrey : Colors.white,
                        ),
                        width: 150,
                        height: 30,
                        alignment: Alignment.center,
                        child: Text('Všetky'),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showAll = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: showAll ? Colors.white : AppColors.getColor('mono').lighterGrey,
                        ),
                        width: 150,
                        height: 30,
                        alignment: Alignment.center,
                        child: Text('Uložené'),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
              if (widget.currentUserData!.teacher && !isMobile)Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 260,
                    child: widget.currentUserData!.teacher ? ReButton(
                      color: "primary", 
                      text: '+ PRIDAŤ OBSAH',
                      onTap: () {
                        _onNavigationItemSelected(1);
                        _add = true;
                      },
                    ) : null,
                  ),
                )
              ),
                ]
              ),
              Expanded(
                child: FutureBuilder<List<MaterialData>>(
                  future: showAll ? fetchMaterials(currentClassData!.materials) : fetchMaterials(favouriteMaterials),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<MaterialData> materials = snapshot.data!;

                      return ListView.builder(
                        itemCount: materials.length,
                        itemBuilder: (context, index) {
                          MaterialData material = materials[index];
                            return MaterialCardWidget(
                                image: material.image,
                                title: material.title,
                                background: material.background,
                                description: material.description,
                                link: material.link,
                                subject: material.subject,
                                type: material.type,
                                association: material.association,
                                video: material.video,
                                materialId: material.materialId!,
                                favoriteMaterialIds: favouriteMaterials,
                                userData: userData,
                              );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error fetching materials'),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              if (widget.currentUserData!.teacher && isMobile)Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 260,
                    child: widget.currentUserData!.teacher ? ReButton(
                      color: "primary", 
                      text: '+ PRIDAŤ OBSAH',  
                      onTap: () {
                        _onNavigationItemSelected(1);
                        _add = true;
                      },
                    ) : null,
                  ),
                )
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
      if (widget.currentUserData!.teacher && _add)Center(
        child: Column(
          children: [
            Container(
              width: 900,
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.getColor('mono').darkGrey,
                    ),
                    onPressed: back,
                  ),
                  Text(
                    'Späť',
                    style: TextStyle(color: AppColors.getColor('mono').darkGrey),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Pridať obsah',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: 100,)
                ],
              ),
            ),
            MaterialForm(currentUserData: widget.currentUserData, materials: currentClassData!.materials, back: back),
          ]
        )
      ),
        ]
      )
    );
  }

  void back () {
    _onNavigationItemSelected(0);
    setState(() {
      _add = false;
    });  
  }
   void _onPageChanged(int index) {
    setState(() {
    });
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }
}