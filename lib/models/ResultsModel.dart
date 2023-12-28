class ResultCapitolsData {
  String name;
  int points;
  int completed;
  List<ResultTestData> tests;

  ResultCapitolsData({
    required this.completed,
    required this.name,
    required this.points,
    required this.tests
  });
}

class ResultTestData {
  String name;
  int points;
  int completed;
  List<ResultQuestionsData>questions;

  ResultTestData({
    required this.name,
    required this.points,
    required this.completed,
    required this.questions,
  });
}

class ResultQuestionsData {
  int points;
  List<int> answers;

  ResultQuestionsData({
    required this.answers,
    required this.points,
  });
}

List<ResultCapitolsData> data = [
 ResultCapitolsData(
    name: 'Kritické Myslenie',
    points: 0,
    completed: 0,
    tests: [
      ResultTestData(
        name: 'Úvod do kritického myslenia',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0,0,0,0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0,0,0,0], points: 0),
        ],
      ),
      ResultTestData(
        name: 'Kognitívne skreslenia',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ],
      ),
    ],
  ),
 ResultCapitolsData(
    name: 'Argumentácia',
    points: 0,
    completed: 0,
    tests: [
      ResultTestData(
        name: 'Čo je argument (úvod do argumentu)',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0], points: 0),
        ],
      ),
      ResultTestData(
        name: 'Výrokova logika - závery',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
        ],
      ),
      ResultTestData(
        name: 'Výrokova logika - predpoklady',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0,0], points:0),
          ResultQuestionsData(answers: [0,0,0], points:0),
          ResultQuestionsData(answers: [0,0,0], points:0),
          ResultQuestionsData(answers: [0,0,0], points:0),
          ResultQuestionsData(answers: [0,0,0], points:0),
        ],
      ),
      ResultTestData(
        name: 'Časti debatného argumentu',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0], points: 0),
        ],
      ),
      ResultTestData(
        name: 'Analýza a Tvrdenie',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0], points: 0),
          ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ],
      ),
      ResultTestData(
        name: 'Dôkazy v argumentoch',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0,0,0,0], points:0),
          ResultQuestionsData(answers: [0], points:0),
          ResultQuestionsData(answers: [0], points:0),
          ResultQuestionsData(answers: [0], points:0),
          ResultQuestionsData(answers: [0], points:0),
        ],
      ),
      ResultTestData(
        name: 'Silné a slabé argumenty 1',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
        ],
      ),
      ResultTestData(
      
        name: 'Silné a slabé argumenty 2',
        points: 0,
        completed: 0,
        questions: [
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
          ResultQuestionsData(answers: [0,0], points:0),
        ],
      ),

    ],
  ),
 ResultCapitolsData(
  points: 0,
  completed: 0,
  name: 'Argumentačné chyby',
  tests: [
    ResultTestData(
      name: 'Úvod do argumentačných chýb',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Argumentačné úskoky',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Logické chyby',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Falošné kritériá',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Argumentačné chyby v praxi',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Konštruktívny dialóg',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
      ],
    ),

    
    
  ]
),

 ResultCapitolsData(
  points: 0,
  completed: 0,
  name: 'Mediálna gramotnosť',
  tests: [
    ResultTestData(
      name: 'Typológia médií',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Formálne znaky médií',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Znaky nedôveryhodných médií v praxi',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Pojmový aparát',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
      ],
    ),
    ResultTestData(
    
      name: 'Hoaxy a dezinformácie v praxi',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Zavádzajúce nadpisy',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Komentár a Správa',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Sociálne siete - overovanie statusov',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
      ],
    ),
    ResultTestData(
    
      name: 'Overovanie obrázkov',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Konšpiračné teórie',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0),
      ],
    ),
    
  ]
),
 ResultCapitolsData(
  points: 0,
  completed: 0,
  name: 'Práca s dátami',
  tests: [
    ResultTestData(
      name: 'Vhodná vizualizácia',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0),
      ],
    ),
    ResultTestData(
      name: 'Zavádzajúce grafy 1',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0 ),
      ],
    ),
    ResultTestData(
      name: 'Zavádzajúce grafy 2',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0 ),
        ResultQuestionsData(answers: [0,0,0], points:0),
      ],
    ),
        ResultTestData(
      name: 'Korelácia  vs Kauzalita',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
        ResultQuestionsData(answers: [0,0], points: 0),
        ResultQuestionsData(answers: [0,0,0], points: 0),
      ],
    ),
    ResultTestData(
      name: 'Interpretácia dát v texte',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
      ],
    ),
    ResultTestData(
      name: 'Interpretácia tabuliek',
      points: 0,
      completed: 0,
      questions: [
        ResultQuestionsData(answers: [0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0,0,0,0,0,0], points:0),
        ResultQuestionsData(answers: [0,0,0,0,0,0,0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0], points:0),
        ResultQuestionsData(answers: [0,0,0], points:0),
      ],
    ),
  ]
),
];

