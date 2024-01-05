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
    this.date
  });
}

class UserAnswerData {
  int? answer;
  int? index;

  UserAnswerData({
    required this.answer,
    required this.index
  });
}

class UserQuestionsData {
  List<UserAnswerData> answer;
  bool completed;
  List<bool> correct;

  UserQuestionsData({
    required this.answer,
    required this.completed,
    required this.correct
  });
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