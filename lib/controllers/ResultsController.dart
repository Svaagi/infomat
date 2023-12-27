import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/models/ResultsModel.dart';

Future<List<ResultCapitolsData>> fetchResults() async {
  try {
    CollectionReference resultsCollection =
        FirebaseFirestore.instance.collection('results');

    QuerySnapshot resultsSnapshot = await resultsCollection.get();

    return resultsSnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return ResultCapitolsData(
        name: data['name'],
        points: data['points'],
        tests: (data['tests'] as List).map((test) => ResultTestData(
          name: test['name'],
          points: test['points'],
          questions: (test['questions'] as List).map((question) => ResultQuestionsData(
            answers: List<int>.from(question['answers']),
            points: question['points'],
          )).toList(),
        )).toList(),
      );
    }).toList();
  } catch (e) {
    print('Error fetching results: $e');
    throw Exception('Failed to fetch results');
  }
}

Future<void> createResults(String id) async {
  try {
    DocumentReference resultRef =
        FirebaseFirestore.instance.collection('results').doc(id);

    // Assuming 'data' is your predefined list of ResultCapitolsData
    for (var result in data) {
      await resultRef.set({
        'name': result.name,
        'points': result.points,
        'tests': result.tests.map((test) => {
          'name': test.name,
          'points': test.points,
          'questions': test.questions.map((question) => {
            'answers': question.answers,
            'points': question.points,
          }).toList(),
        }).toList(),
      });
    }
  } catch (e) {
    print('Error creating result: $e');
    throw Exception('Failed to create result');
  }
}




Future<void> updateResults(String documentId, ResultCapitolsData updatedResult) async {
  try {
    DocumentReference resultRef =
        FirebaseFirestore.instance.collection('results').doc(documentId);

    await resultRef.update({
      'name': updatedResult.name,
      'points': updatedResult.points,
      'tests': updatedResult.tests.map((test) => {
        'name': test.name,
        'points': test.points,
        'questions': test.questions.map((question) => {
          'answers': question.answers,
          'points': question.points,
        }).toList(),
      }).toList(),
    });
  } catch (e) {
    print('Error updating results: $e');
    throw Exception('Failed to update results');
  }
}
