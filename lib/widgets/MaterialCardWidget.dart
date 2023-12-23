import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infomat/controllers/userController.dart'; // Import the UserData class and fetchUser function
import 'package:infomat/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:google_fonts/google_fonts.dart';


class MaterialCardWidget extends StatefulWidget {
  final String materialId;
  final String image;
  final String background;
  final String title;
  final String subject;
  final String type;
  final String description;
  final String association;
  final String link;
  final String video;
  final List<String> favoriteMaterialIds;
  UserData? userData;
 
  MaterialCardWidget({
    required this.materialId,
    required this.image,
    required this.background,
    required this.title,
    required this.subject,
    required this.type,
    required this.description,
    required this.association,
    required this.link,
    required this.video,
    required this.favoriteMaterialIds,
    required this.userData
  });

  @override
  _MaterialCardWidgetState createState() => _MaterialCardWidgetState();
}

class _MaterialCardWidgetState extends State<MaterialCardWidget> {
  bool isHeartFilled = false;
  bool isHeartFilledOverlay = false;
  String? userId;
  late ValueNotifier<bool> isHeartFilledNotifier;
  
  String getPreview (String type) {
    switch (type) {
      case 'Video': {
        return 'assets/learningCards/redPreview.png';
      }
      case 'Projekt': {
        return 'assets/learningCards/greenPreview.png';
      }
      case 'Podujatie': {
        return 'assets/learningCards/primaryPreview.png';
      }
      case 'Textový materiál': {
        return 'assets/learningCards/bluePreview.png';
      }
    }
    return 'assets/learningCards/primaryPreview.png';
  }

  String getBackground (String type) {
    switch (type) {
      case 'Video': {
        return 'assets/learningCards/redBackground.png';
      }
      case 'Projekt': {
        return 'assets/learningCards/greenBackground.png';
      }
      case 'Podujatie': {
        return 'assets/learningCards/primaryBackground.png';
      }
      case 'Textový materiál': {
        return 'assets/learningCards/blueBackground.png';
      }
    }
    return 'assets/learningCards/primaryBackground.png';
  }

  String getColor (String type) {
    switch (type) {
      case 'Video': {
        return 'red';
      }
      case 'Projekt': {
        return 'green';
      }
      case 'Podujatie': {
        return 'primary';
      }
      case 'Textový materiál': {
        return 'blue';
      }
    }
    return 'primary';
  }

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    isHeartFilledNotifier = ValueNotifier(widget.favoriteMaterialIds.contains(widget.materialId));
    if (currentUser != null) {
      userId = currentUser.uid;
      fetchUser(userId!).then((user) {
        setState(() {
          isHeartFilled = widget.favoriteMaterialIds.contains(widget.materialId);
          isHeartFilledOverlay = widget.favoriteMaterialIds.contains(widget.materialId);
          isHeartFilledNotifier = ValueNotifier(widget.favoriteMaterialIds.contains(widget.materialId));
        });
      });
    }
  }

  @override
  void dispose() {
    // Cancel timers or stop animations...
  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
         cursor: SystemMouseCursors.click,
         child: GestureDetector(
        onTap: () {
          _showOverlay(context);
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          constraints: const BoxConstraints(
            minHeight: 150
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(widget.background),
              fit: BoxFit.cover, // BoxFit can be changed based on your needs
            ),
          ),
          child: Wrap(
            children: [
              if(widget.image != '') Container(
                width: 170,
                height: 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Apply rounded corners
                child: Image.network( widget.image),
                )
              ),
              Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: widget.image != '' ? 680 : double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 130,
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: 
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20), // Adjust spacing from the top for the text
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: AppColors.getColor('mono').white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.association,
                              style: TextStyle(
                                color: AppColors.getColor('mono').white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.getColor(getColor(widget.type)).lighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.type,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.getColor(getColor(widget.type)).main,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: (isHeartFilled ? SvgPicture.asset('assets/icons/whiteFilledHeartIcon.svg') : SvgPicture.asset('assets/icons/whiteHeartIcon.svg')),
                        color: AppColors.getColor('mono').white,
                      onPressed: () {
                        toggleFavorite();
                      },
                    ),
                    const SizedBox(width: 4,),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.getColor('mono').lighterGrey
                      ),
                      child: IconButton(
                        icon: SvgPicture.asset('assets/icons/linkIcon.svg', color: Colors.black,),
                        onPressed: () {
                          _launchURL(widget.link);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]
        ),
        )
      )
    );
  }
  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.getColor('mono').white, // Set the overlay background color
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child:  Container(
                      width: 900,
                      padding: MediaQuery.of(context).size.width > 1000 ? EdgeInsets.all(16) : EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(MediaQuery.of(context).size.width > 1000) SizedBox(height: 50,),
                            Container(
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color:  AppColors.getColor('mono').black,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  if(MediaQuery.of(context).size.width > 1000)Text(
                                    'Späť',
                                    style: TextStyle(color: AppColors.getColor('mono').darkGrey),
                                  ),
                                  if(MediaQuery.of(context).size.width > 1000)Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Vzdelávacia aktivita',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                              color: Theme.of(context).colorScheme.onBackground,
                                            ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 80,)
                                ],
                              ),
                            ),
                          if(MediaQuery.of(context).size.width > 1000)SizedBox(height: 30,),
                            Container(
                              padding: EdgeInsets.all(15) ,
                                width: MediaQuery.of(context).size.width > 1000 ? 900 : MediaQuery.of(context).size.width,
                                constraints: BoxConstraints(minHeight: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: MediaQuery.of(context).size.width > 1000 ? BorderRadius.circular(5) : BorderRadius.circular(0),
                                    image: DecorationImage(
                                      image: AssetImage(getPreview(widget.type)),
                                      fit: BoxFit.cover, // BoxFit can be changed based on your needs
                                    ),
                                  ),
                                  child: Wrap(
                                  children: [
                                      if(widget.image != '') Container(
                                        constraints: BoxConstraints(
                                          maxHeight: 200,
                                          maxWidth: 300
                                        ),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10), // Apply rounded corners
                                              child:Image.network( widget.image, fit: BoxFit.cover),
                                            ),
                                      ),
                                      Container(
                                        height: 190,
                                        padding: EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              widget.association,
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              widget.title,
                                              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      )
                                  ]
                                  )
                            ),
                            SizedBox(height:MediaQuery.of(context).size.width > 1000 ?  20 : 10),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.getColor(getColor(widget.type)).lighter,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      widget.type,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: AppColors.getColor(getColor(widget.type)).main,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    widget.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                       SaveButton(
                                      isHeartFilledNotifier: isHeartFilledNotifier,
                                      onToggleHeart: toggleFavorite,
                                    ),
                                      SizedBox(width: 10,),
                                    SizedBox(
                                        height: 40,
                                        child: ReButton(
                                          color: "grey", 
                                          text: 'Navštíviť odkaz',
                                          leftIcon: 'assets/icons/linkIcon.svg',
                                          onTap: () {
                                            _launchURL(widget.link);
                                          }
                                        ),
                                      ),
                                    ],
                                  )
                                  
                                ],
                              ),
                            ),
                          ],
                        ),
                    ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void toggleFavorite() async {

    try {
    final String materialId = widget.materialId;
    

    setState(() {
      if (isHeartFilled) {
        widget.userData!.materials.remove(materialId);
      } else if (!widget.userData!.materials.contains(materialId)) {
        widget.userData!.materials.add(materialId);
      }
       isHeartFilledNotifier.value = !isHeartFilledNotifier.value; // Update ValueNotifier
      isHeartFilled = !isHeartFilled;
      isHeartFilledOverlay = !isHeartFilledOverlay;
    });
    saveUserDataToFirestore(widget.userData!);
    } catch (e) {
      print('Error saving materials data to Firestore: $e');
      rethrow;
    }
    

  }

 Future<void> saveUserDataToFirestore(UserData userData) async {
    try {
      // Reference to the user document in Firestore
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

      // Convert userData object to a Map
      Map<String, dynamic> userDataMap = {
        'discussionPoints': userData.discussionPoints,
        'weeklyDiscussionPoints': userData.weeklyDiscussionPoints,
        'admin': userData.admin,
        'teacher': userData.teacher,
        'email': userData.email,
        'name': userData.name,
        'active': userData.active,
        'school': userData.school,
        'schoolClass': userData.schoolClass,
        'materials': userData.materials,
        'points': userData.points,
        'capitols': userData.capitols.map((userCapitolsData) {
          return {
            'id': userCapitolsData.id,
            'name': userCapitolsData.name,
            'image': userCapitolsData.image,
            'completed': userCapitolsData.completed,
            'tests': userCapitolsData.tests.map((userCapitolsTestData) {
              return {
                'name': userCapitolsTestData.name,
                'completed': userCapitolsTestData.completed,
                'points': userCapitolsTestData.points,
                'questions': userCapitolsTestData.questions.map((userQuestionsData) {
                  return {
                    'answer': userQuestionsData.answer.map((userAnswerData) {
                      return {
                        'answer': userAnswerData.answer,
                        'index': userAnswerData.index
                        };
                    }).toList(),
                    'completed': userQuestionsData.completed,
                    'correct': userQuestionsData.correct,
                  };
                }).toList(),
              };
            }).toList(),
          };
        }).toList(),
      };

      // Update the user document in Firestore with the new userDataMap
      await userRef.update(userDataMap);
    } catch (e) {
      print('Error saving user data to Firestore: $e');
      rethrow;
    }
  }
}

class SaveButton extends StatelessWidget {
  final ValueNotifier<bool> isHeartFilledNotifier;
  final VoidCallback onToggleHeart;

  SaveButton({required this.isHeartFilledNotifier, required this.onToggleHeart});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isHeartFilledNotifier,
      builder: (context, isHeartFilled, child) {
        return SizedBox(
          height: 40,
          width: 150,
          child: ReButton(
            color: isHeartFilled ? "primary" : "grey", 
            text: 'Uložiť',
            leftIcon: isHeartFilled ? 'assets/icons/whiteFilledHeartIcon.svg' : 'assets/icons/primaryHeartIcon.svg',
            onTap: onToggleHeart,
          ),
        );
      },
    );
  }
}