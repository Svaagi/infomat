import 'package:cloud_firestore/cloud_firestore.dart';



class UserDataWithId {
  final String id;
  final UserData data;

  UserDataWithId(this.id, this.data);
}

class UserNotificationsData {
  String id;
  bool seen;
  Timestamp? date;

  UserNotificationsData({
    required this.id,
    required this.seen,
    this.date,
  });

  factory UserNotificationsData.fromMap(Map<String, dynamic> map) {
    return UserNotificationsData(
      id: map['id'] ?? '', // Assuming 'id' is always expected
      seen: map['seen'] ?? false, // Defaulting to false if null
      date: map['date'], // 'date' can be null, no change needed here
    );
  }

}


class UserAnswerData {
  int? answer;
  int? index;

  UserAnswerData({
    required this.answer,
    required this.index,
  });

  factory UserAnswerData.fromMap(Map<String, dynamic> map) {
    return UserAnswerData(
      answer: map['answer'],
      index: map['index'],
    );
  }
}


class UserQuestionsData {
  List<UserAnswerData> answer;
  bool completed;
  List<bool> correct;

  UserQuestionsData({
    required this.answer,
    required this.completed,
    required this.correct,
  });

  factory UserQuestionsData.fromMap(Map<String, dynamic> map) {
    return UserQuestionsData(
      answer: map['answer'] != null
        ? List<UserAnswerData>.from(map['answer'].map((x) => UserAnswerData.fromMap(x)))
        : [],
      completed: map['completed'] ?? false,
      correct: map['correct'] != null ? List<bool>.from(map['correct']) : [],
    );
  }

}


class UserCapitolsData {
  String id;
  String name;
  String image;
  bool completed;
  List<UserCapitolsTestData> tests;

  UserCapitolsData({
    required this.id,
    required this.name,
    required this.image,
    required this.completed,
    required this.tests,
  });

  factory UserCapitolsData.fromMap(Map<String, dynamic> map) {
    return UserCapitolsData(
      id: map['id'] ?? '', // Assuming 'id' should have a default empty string if null
      name: map['name'] ?? '', // Defaulting to an empty string if null
      image: map['image'] ?? '', // Defaulting to an empty string if null
      completed: map['completed'] ?? false,
      tests: map['tests'] != null
        ? (map['tests'] as List<dynamic>).map((testMap) => UserCapitolsTestData.fromMap(testMap)).toList()
        : [],
    );
  }

}


class UserCapitolsTestData {
  String name;
  bool completed;
  int points;
  List<UserQuestionsData> questions;

  UserCapitolsTestData({
    required this.name,
    required this.completed,
    required this.points,
    required this.questions,
  });

  factory UserCapitolsTestData.fromMap(Map<String, dynamic> map) {
    return UserCapitolsTestData(
      name: map['name'] ?? '',
      completed: map['completed'] ?? false,
      points: map['points'] ?? 0,
      questions: map['questions'] != null
        ? (map['questions'] as List<dynamic>).map((questionMap) => UserQuestionsData.fromMap(questionMap)).toList()
        : [],
    );
  }

}


class UserData {
  int discussionPoints;
  int weeklyDiscussionPoints;
  bool admin;
  String id;
  String email;
  String name;
  bool active;
  String school;
  List<String> classes;
  String schoolClass;
  bool teacher;
  bool signed;
  int points;
  List<UserCapitolsData> capitols;
  List<String> materials;
  List<UserNotificationsData> notifications;

  UserData({
    required this.admin,
    required this.discussionPoints,
    required this.weeklyDiscussionPoints,
    required this.id,
    required this.email,
    required this.name,
    required this.active,
    required this.signed,
    required this.school,
    required this.classes,
    required this.schoolClass,
    required this.teacher,
    required this.points,
    required this.capitols,
    required this.materials,
    required this.notifications
  });

  factory UserData.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>? ?? {};

    // Use the same approach for extracting and handling fields as in fetchUser
    List<UserCapitolsData> capitolList = [];
    if (data['capitols'] != null) {
      List<Map<String, dynamic>> capitols = List<Map<String, dynamic>>.from(data['capitols'] as List<dynamic>? ?? []);
      for (var capitolData in capitols) {
        capitolList.add(UserCapitolsData.fromMap(capitolData));
      }
    }

    List<UserNotificationsData> notificationList = [];
    if (data['notifications'] != null) {
      List<Map<String, dynamic>> notifications = List<Map<String, dynamic>>.from(data['notifications'] as List<dynamic>? ?? []);
      for (var notificationData in notifications) {
        notificationList.add(UserNotificationsData.fromMap(notificationData));
      }
    }

    // Repeat the approach for other fields as necessary

    return UserData(
      admin: data['admin'] ?? false,
      discussionPoints: data['discussionPoints'] ?? 0,
      weeklyDiscussionPoints: data['weeklyDiscussionPoints'] ?? 0,
      id: snapshot.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      active: data['active'] ?? false,
      school: data['school'] ?? '',
      classes: List<String>.from(data['classes'] ?? []),
      schoolClass: data['schoolClass'] ?? '',
      teacher: data['teacher'] ?? false,
      signed: data['signed'] ?? false,
      points: data['points'] ?? 0,
      capitols: capitolList,
      materials: List<String>.from(data['materials'] ?? []),
      notifications: notificationList,
    );
  }
}


UserData userData = UserData(
      admin: false,
      discussionPoints: 0,
      weeklyDiscussionPoints: 0,
      id: '',
      email: '',
      name: '',
      school: '',
      active: false,
      signed: false,
      classes: [
      ],
      schoolClass: '',
      teacher: false,
      points: 0,
      capitols: [
        UserCapitolsData(
            completed: false,
            id: '0',
            image: '',
            name: 'Kritické myslenie',
            tests: [
              UserCapitolsTestData(
                completed: false,
                name: 'Úvod do kritického myslenia',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false, false, false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Kognitívne skreslenia',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                ],
              ),
            ],
          ),
          UserCapitolsData(
            completed: false,
            id: '1',
            image: '',
            name: 'Argumentácia',
            tests: [
              UserCapitolsTestData(
                completed: false,
                name: 'Čo je argument (úvod do argumentu)',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Výrokova logika - závery',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Výrokova logika - predpoklady',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Časti debatného argumentu',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Analýza a Tvrdenie',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Dôkazy v argumentoch',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Silné a slabé argumenty 1',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Silné a slabé argumenty 2',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
            ],
          ),
          UserCapitolsData(
            completed: false,
            id: '2',
            image: '',
            name: 'Argumentačné chyby',
            tests: [
              UserCapitolsTestData(
                completed: false,
                name: 'Úvod do argumentačných chýb',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Argumentačné úskoky',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Logické chyby',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false,]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false,]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Falošné kritériá',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Argumentačné chyby v praxi',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Konštruktívny dialóg',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
            ]
          ),
          UserCapitolsData(
            completed: false,
            id: '3',
            image: '',
            name: 'Mediálna gramotnosť',
            tests: [
              UserCapitolsTestData(
                completed: false,
                name: 'Typológia médií',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Formálne znaky médií',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false,false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Znaky nedôveryhodných médií v praxi',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Pojmový aparát',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Hoaxy a dezinformácie v praxi',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Zavádzajúce nadpisy',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Komentár a Správa',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Sociálne siete - overovanie statusov',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Overovanie obrázkov',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Konšpiračné teórie',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false,false,false,false,false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              
            ]
          ),
          UserCapitolsData(
            completed: false,
            id: '4',
            image: '',
            name: 'Práca s dátami',
            tests: [
              UserCapitolsTestData(
                completed: false,
                name: 'Vhodná vizualizácia',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Zavádzajúce grafy 1',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Zavádzajúce grafy 2',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Korelácia  vs Kauzalita',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false, false, false, false, false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false, false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Interpretácia dát v texte',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
              UserCapitolsTestData(
                completed: false,
                name: 'Interpretácia tabuliek',
                points: 0,
                questions: [
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                  UserQuestionsData(answer: [], completed: false, correct: [false]),
                ],
              ),
            ]
          ),
      ],
      materials: [],
      notifications: [],
    );