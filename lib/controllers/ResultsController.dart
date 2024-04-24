import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/models/ResultsModel.dart';
import 'package:infomat/models/UserModel.dart';

Future<List<ResultCapitolsData>> fetchResults(String id) async {
  try {
    print('results');
    DocumentReference resultsRef = FirebaseFirestore.instance.collection('results').doc(id);

    // Retrieve the document from Firestore
    DocumentSnapshot resultsSnapshot = await resultsRef.get();

    if (resultsSnapshot.exists) {
      var data = resultsSnapshot.data() as Map<String, dynamic>;
      var resultsList = data['data'] as List; // Accessing the 'data' field which contains result items

      // Map each item in the list to a ResultCapitolsData object
      return resultsList.map((resultData) {
        return ResultCapitolsData(
          name: resultData['name'],
          points: resultData['points'],
          completed: resultData['completed'],
          tests: (resultData['tests'] as List).map((test) => ResultTestData(
            name: test['name'],
            points: test['points'],
            completed: test['completed'],
            questions: (test['questions'] as List).map((question) => ResultQuestionsData(
              answers: List<int>.from(question['answers']),
              points: question['points'],
            )).toList(),
          )).toList(),
        );
      }).toList();
    } else {
      throw Exception('Results document does not exist.');
    }
  } catch (e) {
    print('Error fetching results: $e');
    throw Exception('Failed to fetch results');
  }
}



Future<String> createResults() async {
  try {
    CollectionReference resultsCollection =
        FirebaseFirestore.instance.collection('results');

    // Assuming 'data' is your predefined list of ResultCapitolsData
    DocumentReference newResultRef = await resultsCollection.add({
      // Convert your predefined data to the format expected by Firestore
      'data': data.map((result) => {
        'name': result.name,
        'points': result.points,
        'completed': result.completed,
        'tests': result.tests.map((test) => {
          'name': test.name,
          'points': test.points,
          'completed': test.completed,
          'questions': test.questions.map((question) => {
            'answers': question.answers,
            'points': question.points,
          }).toList(),
        }).toList(),
      }).toList(),
    });

    print('Results created successfully with ID: ${newResultRef.id}');
    return newResultRef.id;
  } catch (e) {
    print('Error creating results: $e');
    throw Exception('Failed to create results');
  }
}


Future<void> deleteResults(String id) async {
  try {
    DocumentReference resultsRef = FirebaseFirestore.instance.collection('results').doc(id);

    // Delete the document from Firestore
    await resultsRef.delete();

    print('Results deleted successfully with ID: $id');
  } catch (e) {
    print('Error deleting results: $e');
    throw Exception('Failed to delete results');
  }
}



Future<void> updateResults(String id, int capitolIndex, int testIndex, int questionIndex, List<UserAnswerData> answerData, int points) async {
  try {
    DocumentReference resultsRef = FirebaseFirestore.instance.collection('results').doc(id);

    print('capitolIndex: $capitolIndex testIndex: $testIndex questionIndex: $questionIndex');

    // Retrieve the current document
    DocumentSnapshot snapshot = await resultsRef.get();
    if (!snapshot.exists) {
      throw Exception('Results document does not exist.');
    }

    var data = snapshot.data() as Map<String, dynamic>;
    var resultsList = data['data'] as List;
    var capitolData = resultsList[capitolIndex];
    var testData = capitolData['tests'][testIndex];
    var questionData = testData['questions'][questionIndex];

    // Update points based on answers
    for (var userAnswer in answerData) {
      if (userAnswer.index != null && userAnswer.answer != null) {
        int currentPoints = questionData['answers'][userAnswer.index];
        questionData['answers'][userAnswer.index] = currentPoints + 1;
      }
    }

    // Update test and capitol points
    capitolData['points'] += points;
    testData['points'] += points;
    questionData['points'] += points;

    // Update the document in Firestore
    await resultsRef.set(data);

  } catch (e) {
    print('Error updating results: $e Capitol Index: $capitolIndex Test Index: $testIndex Question Index: $questionIndex');
    throw Exception('Failed to update results');
  }
}

Future<void> updateResultsCapitol(String id, int capitolIndex) async {
  try {
    DocumentReference resultsRef = FirebaseFirestore.instance.collection('results').doc(id);

    // Retrieve the current document
    DocumentSnapshot snapshot = await resultsRef.get();
    if (!snapshot.exists) {
      throw Exception('Results document does not exist.');
    }

    var data = snapshot.data() as Map<String, dynamic>;
    var resultsList = data['data'] as List;
    var capitolData = resultsList[capitolIndex];


    capitolData['completed'] += 1;

    // Update the document in Firestore
    await resultsRef.set(data);

    print('Results updated successfully for document ID: $id');
  } catch (e) {
    print('Error updating results: $e');
    throw Exception('Failed to update results');
  }
}

Future<void> updateResultsTest(String id, int capitolIndex, int testIndex) async {
  try {
    DocumentReference resultsRef = FirebaseFirestore.instance.collection('results').doc(id);

    // Retrieve the current document
    DocumentSnapshot snapshot = await resultsRef.get();
    if (!snapshot.exists) {
      throw Exception('Results document does not exist.');
    }

    var data = snapshot.data() as Map<String, dynamic>;
    var resultsList = data['data'] as List;
    var capitolData = resultsList[capitolIndex];
    var testData = capitolData['tests'][testIndex];


    testData['completed'] += 1;

    // Update the document in Firestore
    await resultsRef.set(data);

    print('Results updated successfully for document ID: $id');
  } catch (e) {
    print('Error updating results: $e');
    throw Exception('Failed to update results');
  }
}

