import 'package:flutter/material.dart';
import 'package:infomat/views/DesktopDiscussions.dart';
import 'package:infomat/views/MobileDiscussions.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';



class Discussions extends StatefulWidget {
  final UserData? currentUserData;


  Discussions({
    Key? key,
    required this.currentUserData,
  }) : super(key: key);

  @override
  _DiscussionsState createState() => _DiscussionsState();
}

class _DiscussionsState extends State<Discussions> {
  
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> sendDiscussionsEvent() async {
    await analytics.logEvent(
      name: 'diskusia',
      parameters: {
        'page': 'diskusia', // replace with your actual page/screen name
      },
    );
  }
  
  @override
  void initState() {
    super.initState();

    sendDiscussionsEvent();
  }


  

  @override
  void dispose() {
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
    return Container(
      child: 
        MediaQuery.of(context).size.width < 1000 ? MobileDiscussions(currentUserData: widget.currentUserData,) : DesktopDiscussions(currentUserData: widget.currentUserData)
    );
  }
}
