import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:infomat/controllers/SchoolController.dart';
import 'package:infomat/models/UserModel.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/controllers/convert.dart';
import 'package:infomat/widgets/Widgets.dart';
import 'package:flutter/widgets.dart';

Future<UserData> fetchUser(String userId) async {
  try {
    // Retrieve the Firebase Auth user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String id = userId;
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        // Extracting the fields
        String email = userSnapshot.get('email') as String? ?? '';
        String name = userSnapshot.get('name') as String? ?? '';
        bool active = userSnapshot.get('active') as bool? ?? false;
        List<String> classes = List<String>.from(userSnapshot.get('classes') as List<dynamic>? ?? []);
        String school = userSnapshot.get('school') as String? ?? '';
        String schoolClass = userSnapshot.get('schoolClass') as String? ?? '';
        int points = userSnapshot.get('points') as int? ?? 0;
        int discussionPoints = userSnapshot.get('discussionPoints') as int? ?? 0;
        int weeklyDiscussionPoints = userSnapshot.get('weeklyDiscussionPoints') as int? ?? 0;
        List<Map<String, dynamic>> capitols = List<Map<String, dynamic>>.from(userSnapshot.get('capitols') as List<dynamic>? ?? []);
        List<String> materials = List<String>.from(userSnapshot.get('materials') as List<dynamic>? ?? []);
        bool teacher = userSnapshot.get('teacher') as bool? ?? false;
        bool admin = userSnapshot.get('admin') as bool? ?? false;

        // Extracting notifications data
        List<Map<String, dynamic>> rawNotifications = List<Map<String, dynamic>>.from(userSnapshot.get('notifications') as List<dynamic>? ?? []);
        List<UserNotificationsData> notificationsList = [];
        for (var notificationData in rawNotifications) {
          String notificationId = notificationData['id'] as String? ?? '';
          bool notificationSeen = notificationData['seen'] as bool? ?? false;

          UserNotificationsData notification = UserNotificationsData(
            id: notificationId,
            seen: notificationSeen,
          );

          notificationsList.add(notification);
        }

        UserData userData = UserData(
          admin: admin,
          discussionPoints: discussionPoints,
          weeklyDiscussionPoints: weeklyDiscussionPoints,
          id: id,
          email: email,
          name: name,
          active: active,
          school: school,
          classes: classes,
          schoolClass: schoolClass,
          teacher: teacher,
          points: points,
          capitols: [],
          materials: materials,
          notifications: notificationsList,
        );

        // Iterate over the capitols data
        for (var capitolData in capitols) {
          // Extract the values from the capitolData
          String capitolId = capitolData['id'] as String? ?? '';
          String capitolName = capitolData['name'] as String? ?? '';
          String capitolImage = capitolData['image'] as String? ?? '';
          bool capitolCompleted = capitolData['completed'] as bool? ?? false;

          // Access the "tests" list within the capitolData
          List<dynamic>? tests = capitolData['tests'] as List<dynamic>?;

          if (tests != null) {
            // Create a list to hold the UserCapitolsTestData instances
            List<UserCapitolsTestData> testsDataList = [];

            // Iterate over the tests data
            for (var testData in tests) {
              // Extract the test name, completion status, points, and questions
              String testName = testData['name'] as String? ?? '';
              bool testCompleted = testData['completed'] as bool? ?? false;
              int testPoints = testData['points'] as int? ?? 0;
              List<dynamic>? questions = testData['questions'] as List<dynamic>?;

              if (questions != null) {
                // Create a list to hold the UserQuestionsData instances
                List<UserQuestionsData> questionsDataList = [];

                // Iterate over the questions data
               for (var questionData in questions) {
              // Extract the question answer and completion status
                  bool questionCompleted = questionData['completed'] as bool? ?? false;
                  List<bool> questionCorrect = List<bool>.from(
                        questionData['correct'] as List<dynamic>? ?? []);

                  List<UserAnswerData> answersDataList = [];  // Initialized outside the if block

                  List<dynamic>? answers = questionData['answer'] as List<dynamic>?;

                  if (answers != null) {
                    for (var answerData in answers) {
                      int answer = answerData['answer'] as int? ?? 0;
                      int index = answerData['index'] as int? ?? 0;

                      UserAnswerData answerItem = UserAnswerData(
                        answer: answer,
                        index: index,
                      );
                      answersDataList.add(answerItem);
                    }
                  }

                  UserQuestionsData question = UserQuestionsData(
                    answer: answersDataList,
                    completed: questionCompleted,
                    correct: questionCorrect,
                  );

                  // Add the UserQuestionsData instance to the list
                  questionsDataList.add(question);
                }


                // Create a UserCapitolsTestData instance with the test name, completion status, points, and questions
                UserCapitolsTestData testData = UserCapitolsTestData(
                  name: testName,
                  completed: testCompleted,
                  points: testPoints,
                  questions: questionsDataList,  // Updated from questionsDataList
                );

                // Add the UserCapitolsTestData instance to the list
                testsDataList.add(testData);
              }
            }

            // Create a UserCapitolsData instance with the capitol id, name, image, completion status, and the list of tests
            UserCapitolsData capitolData = UserCapitolsData(
              id: capitolId,
              name: capitolName,
              image: capitolImage,
              completed: capitolCompleted,
              tests: testsDataList,
            );

            // Add the UserCapitolsData instance to the list
            userData.capitols.add(capitolData);
          }
        }

        return userData;
      } else {
        throw Exception('User document does not exist.');
      }
    } else {
      throw Exception('User is not logged in.');
    }
  } catch (e) {
    print('Error fetching user data: $e');
    rethrow;
  }
}

Future<void> updateClasses(String userId, String classId) async {
  try {
    // Get a reference to the user's document in Firestore
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update the classes array by adding the new classId
    await userRef.update({
      'classes': FieldValue.arrayUnion([classId]),
      'schoolClass': classId
    });

    print('Class ID $classId added to user $userId successfully.');
  } catch (error) {
    print('Error updating classes: $error');
    throw error;
  }
}


Future<void> deleteUser(String userId) async {
  try {
    // Next, delete the user document from Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    // You may also want to clean up any other related data or documents here

    print('User with ID $userId has been deleted successfully.');
  } catch (error) {
    print('Error deleting user: $error');
    throw error;
  }
}

Future<void> registerUser(String schoolId, String classId, String name, String email, String password, bool teacher, BuildContext context, ClassDataWithId? currentClass) async {
  String? userId;
  try {
    final functions = FirebaseFunctions.instance;
    final result = await functions.httpsCallable('createAccount').call({
      'email': email,
      'password': password,
    });

    userId = result.data['uid'];

    // Set the user's ID from Firebase
    userData.id = userId!;

    await FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentReference classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

      // Set user data
      transaction.set(userRef, {
        'id': userId,
        'admin': userData.admin,
        'discussionPoints': userData.discussionPoints,
        'weeklyDiscussionPoints': userData.weeklyDiscussionPoints,
        'teacher': teacher,
        'email': email, // Update the email in Firestore to the new email
        'name': name,
        'active': userData.active,
        'classes': [classId],
        'notifications': userData.notifications,
        'materials': userData.materials,
        'school': schoolId,
        'schoolClass': classId,
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
                        'index': userAnswerData.index,
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
      });

      // Update class data
      Map<String, dynamic> updateData = teacher
        ? {'teachers': FieldValue.arrayUnion([userId])}
        : {'students': FieldValue.arrayUnion([userId])};

      transaction.update(classRef, updateData);

      if(teacher) {
        currentClass!.data.teachers.add(userId!);
        addTeacherToSchool(userId, schoolId);
      } else {
         currentClass!.data.students.add(userId!);
      }
    });

    // Success toast
    reShowToast(teacher ? 'Učiteľ úspešne pridaný' : 'Žiak úspešne pridaný', false, context);
  } catch (e) {
    // Error handling
    reShowToast(teacher ? 'Učiteľa sa nepodarilo pridať' : 'Žiaka sa nepodarilo pridať', true, context);
  }
}

Future<void> registerMultipleUsers(
    List<ConvertTable> users,
    String schoolId,
    ClassDataWithId currentClass,
    BuildContext context
) async {
    final functions = FirebaseFunctions.instance;
    final firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();

    try {
        // Prepare user data for bulk account creation
        var bulkUserData = users.map((user) => {
            'email': user.email,
            'password': 'test1234', // Consider using unique passwords or a secure method to generate them
        }).toList();

        // Call the modified Firebase function for bulk account creation
        var bulkCreationResult = await functions.httpsCallable('createBulkAccounts').call({
            'users': bulkUserData
        });

        var results = bulkCreationResult.data['results'];

        for (var data in results) {
            var userEmail = data['email'];
            var user = users.firstWhere((u) => u.email == userEmail);

            if (data.containsKey('uid')) {
                String userId = data['uid'];
                DocumentReference userRef = firestore.collection('users').doc(userId);
                DocumentReference classRef = firestore.collection('classes').doc(user.classId);

                 // Add user data to batch
                batch.set(userRef, {
                  'admin': false,
                  'discussionPoints': 0,
                  'weeklyDiscussionPoints': 0,
                  'teacher': false,
                  'email': user.email, // Update the email in Firestore to the new email
                  'name': user.name,
                  'active': userData.active,
                  'classes': [user.classId],
                  'notifications': [],
                  'materials': [],
                  'school': schoolId,
                  'schoolClass': user.classId,
                  'points': 0,
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
                                  'index': userAnswerData.index,
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
                });

                // Prepare class data update
                Map<String, dynamic> updateData = {
                    'students': FieldValue.arrayUnion([userId])
                };

                currentClass!.data.students.add(userId);

                batch.update(classRef, updateData);
            } else {
                // Handle user creation failure
                // Log error or inform the user
            }
        }

        // Commit the batch
        await batch.commit();

        reShowToast('Všetci žiaci úspešne registrovaní', false, context);
    } catch (e) {
        // Error handling
        reShowToast('Nepodarilo sa zaregistrovať používateľov ', true, context);
    }
}






Future<void> incrementDiscussionPoints(String userId, int incrementAmount, bool check) async {
  try {
    // Get a reference to the user's document in Firestore
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update the discussionPoints field by incrementAmount
    if (check) {
      await userRef.update({
        'discussionPoints': FieldValue.increment(1),
      });
    } else {
      await userRef.update({
        'discussionPoints': FieldValue.increment(-1),
      });
    }
    

    print('DiscussionPoints incremented successfully.');
  } catch (error) {
    print('Error incrementing discussionPoints: $error');
    throw error;
  }
}

Future<void> deleteUserFunction(List<String> userIds, UserData currentUser, BuildContext context, ClassDataWithId? currentClass) async {
  try {

    
    for (String userId in userIds) {
      // Find the class document that contains the userId
      final classQuery = await FirebaseFirestore.instance
          .collection('classes')
          .where('students', arrayContains: userId)
          .get();

      // Check if the userId is also in the 'teachers' array
      final teacherQuery = await FirebaseFirestore.instance
          .collection('classes')
          .where('teachers', arrayContains: userId)
          .get();

      // Combine the class and teacher queries to ensure we remove the userId from both arrays
      final combinedQuery = classQuery.docs + teacherQuery.docs;

      for (final classDoc in combinedQuery) {
        // Remove the userId from the 'students' and 'teachers' arrays in the class document
        await classDoc.reference.update({
          'students': FieldValue.arrayRemove([userId]),
          'teachers': FieldValue.arrayRemove([userId]),
        });
      }

        currentClass!.data.teachers.removeWhere((id) => id == userId);
        currentClass.data.students.removeWhere((id) => id == userId);

      // Call deleteUser(userId) to delete the user document
      await deleteUser(userId);
    }

    // Step 3: Call the deleteAccount cloud function
    // Replace 'your-cloud-function-url' with the actual URL of your deleteAccount function
    final deleteAccountCallable =
        FirebaseFunctions.instance.httpsCallable('deleteAccount');
    await deleteAccountCallable(userIds);

    

  } catch (error) {
    reShowToast(currentUser.teacher ? 'Učiteľa sa nepodarilo vymazať' : 'Žiaka sa nepodarilo vymazať', true, context);
    throw error;
  }
}