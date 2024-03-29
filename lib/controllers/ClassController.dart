import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/models/ClassModel.dart';
import 'package:infomat/models/NotificationModel.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';

import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/controllers/ResultsController.dart';
import 'package:infomat/controllers/SchoolController.dart';
import 'package:infomat/controllers/NotificationController.dart';
import 'package:infomat/widgets/Widgets.dart';

Future<ClassData> fetchClass(String classId) async {
  try {
    print('class');
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the data from the class document
      final data = classSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        final posts = data['posts'] as List<dynamic>;

        // Create PostsData instances from the posts data
        List<PostsData> postsDataList = posts.map((postItem) {
          List<Map<String, dynamic>> comments =
              List<Map<String, dynamic>>.from(
                  postItem['comments'] as List<dynamic>? ?? []);

          // Create CommentsData instances from the comments data
          List<CommentsData> commentsDataList = comments.map((commentItem) {
            List<Map<String, dynamic>> answers =
                List<Map<String, dynamic>>.from(
                    commentItem['answers'] as List<dynamic>? ?? []);

            // Create CommentsAnswersData instances from the answers data
            List<CommentsAnswersData> answersDataList = answers.map((answerItem) {
              return CommentsAnswersData(
                award: answerItem['award'] as bool? ?? false,
                teacher: answerItem['teacher'] as bool? ?? false,
                date: answerItem['date'] as Timestamp? ?? Timestamp.now(),
                userId: answerItem['userId'] as String? ?? '',
                user: answerItem['user'] as String? ?? '',
                edited: answerItem['edited'] as bool? ?? false,
                value: answerItem['value'] as String? ?? '',
              );
            }).toList();

            return CommentsData(
              teacher: commentItem['teacher'] as bool? ?? false,
              award: commentItem['award'] as bool? ?? false,
              edited: commentItem['edited'] as bool? ?? false,
              answers: answersDataList,
              userId: commentItem['userId'] as String? ?? '',
              date: commentItem['date'] as Timestamp? ?? Timestamp.now(),
              user: commentItem['user'] as String? ?? '',
              value: commentItem['value'] as String? ?? '',
            );
          }).toList();

          return PostsData(
            comments: commentsDataList,
            date: postItem['date'] as Timestamp? ?? Timestamp.now(),
            id: postItem['id'] as String? ?? '',
            userId: postItem['userId'] as String? ?? '',
            user: postItem['user'] as String? ?? '',
            value: postItem['value'] as String? ?? '',
            edited: postItem['edited'] as bool? ?? false,
          );
        }).toList();

        return ClassData(
          name: data['name'] as String? ?? '',
          school: data['school'] as String? ?? '',
          results: data['results'] as String? ?? '',
          challenge: data['challenge'] as int? ?? 0,
          students: List<String>.from(data['students'] as List<dynamic>? ?? []),
          teachers: List<String>.from(data['teachers'] as List<dynamic>? ?? []),
          posts: postsDataList,
          materials: List<String>.from(data['materials'] as List<dynamic>? ?? []),
          capitolOrder: List<int>.from(data['capitolOrder'] as List<dynamic>? ?? []),
        );
      } else {
        throw Exception('Retrieved document data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error fetching classes: $e');
    throw Exception('Failed to fetch classes');
  }
}

Future<List<ClassData>> fetchClasses(List<String> classIds) async {
  List<ClassData> classes = [];
  for (String id in classIds) {
    try {
      ClassData classData = await fetchClass(id);
      classes.add(classData);
    } catch (e) {
      print('Error fetching class data for id $id: $e');
    }
  }
  return classes;
}

Future<void> editClass(String classId, ClassData newClassData, BuildContext context,) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Convert the newClassData object to a Map
    Map<String, dynamic> classDataMap = {
      'name': newClassData.name,
      'school': newClassData.school,
      'students': newClassData.students,
      'teachers': newClassData.teachers,
      'materials': newClassData.materials,
      'capitolOrder': newClassData.capitolOrder,
      'challenge': newClassData.challenge,
      'posts': newClassData.posts.map((post) {
        return {
          'date': post.date,
          'id': post.id,
          'userId': post.userId,
          'user': post.user,
          'value': post.value,
          'edited': post.edited,
          'comments': post.comments.map((comment) {
            return {
              'award': comment.award,
              'date': comment.date,
              'edited': comment.edited,
              'userId': comment.userId,
              'user': comment.user,
              'value': comment.value,
              'answers': comment.answers.map((answer) {
                return {
                  'award': answer.award,
                  'date': answer.date,
                  'edited': answer.edited,
                  'userId': answer.userId,
                  'user': answer.user,
                  'value': answer.value,
                };
              }).toList(),
            };
          }).toList(),
        };
      }).toList(),
    };

    // Update the class document with the new data
    reShowToast('Zmeny uložené', false, context);
    await classRef.update(classDataMap);
  } catch (e) {
    print('Error editing class: $e');
    throw Exception('Failed to edit class');
  }
}

Future<void> deleteClass(String classId, String school, void Function(String)? removeSchoolData, List<String> tmp) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // First, make the API call to delete user accounts
    


    // Proceed with Firestore operations only if the above API call succeeds
    await firestore.runTransaction((Transaction transaction) async {
      DocumentReference classRef = firestore.collection('classes').doc(classId);
      DocumentSnapshot classSnapshot = await transaction.get(classRef);

      if (tmp.isNotEmpty) {
        final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
        final deleteBulkAccountsCallable = functions.httpsCallable('deleteBulkAccounts');
        await deleteBulkAccountsCallable({'userIds': tmp});
        await deleteUsers(tmp);
      }

      await deleteResults(classSnapshot.get('results'));

      if (!classSnapshot.exists) {
        throw Exception('Class document does not exist.');
      }

      // Delete the class document
      transaction.delete(classRef);

      // Additional operations to remove the class from the school's classes list
      // Add appropriate transaction operations here
    });

    // If there's a callback to remove school data, call it
    if (removeSchoolData != null) {
      removeSchoolData(classId);
    }

    print('Class deleted successfully with ID: $classId');
  } catch (e) {
    print('Error deleting class: $e');
    throw Exception('Failed to delete class');
  }
}


Future<void> removeClassFromSchool(String classId, String school) async {
  try {
    // Reference to the school document in Firestore
    DocumentReference schoolRef =
        FirebaseFirestore.instance.collection('schools').doc(school);

    // Retrieve the school document
    DocumentSnapshot schoolSnapshot = await schoolRef.get();

    if (schoolSnapshot.exists) {
      // Extract the school data from the school document
      final schoolData = schoolSnapshot.data() as Map<String, dynamic>?;

      if (schoolData != null) {
        // Extract the classes field from the school data
        List<String> classes =
            List<String>.from(schoolData['classes'] as List<dynamic>? ?? []);

        // Remove the classId from the classes list
        classes.remove(classId);

        // Update the classes field within the school data
        schoolData['classes'] = classes;

        // Update the school document in Firestore
        await schoolRef.update(schoolData);

      } else {
        throw Exception('Retrieved school data is null.');
      }
    } else {
      throw Exception('School document does not exist.');
    }
  } catch (e) {
    print('Error removing class from school: $e');
    throw Exception('Failed to remove class from school');
  }
}



Future<void> addComment(String classId, String postId, CommentsData comment,String userId , String currentId) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the class data from the class document
      final classData = classSnapshot.data() as Map<String, dynamic>?;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(
                classData['posts'] as List<dynamic>? ?? []);

        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Add the comment to the post
          if (posts[postIndex]['comments'] == null) {
            posts[postIndex]['comments'] = [];
          }

          List<Map<String, dynamic>> comments =
              List<Map<String, dynamic>>.from(posts[postIndex]['comments'] as List<dynamic>? ?? []);

          comments.add({
            'award': false,
            'teacher': comment.teacher,
            'date': comment.date,
            'user': comment.user,
            'userId': comment.userId,
            'edited': comment.edited,
            'value': comment.value,
            'answers': <Map<String, dynamic>>[],
          });

          // Update the comments field within the post data
          posts[postIndex]['comments'] = comments;

          // Update the posts field within the class data
          classData['posts'] = posts;

          // Update the class document in Firestore
          await classRef.update(classData);

          if (userId != currentId) {
            sendNotification([userId] , 'Na váš príspevok niekto odpovedal.', 'Diskusia', TypeData(
            id: postId,
              commentIndex: (posts[postIndex]['comments'].length-1).toString(),
              answerIndex: '',
              type: 'comment'
            ));
          }

          return;
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error adding comment: $e');
    throw Exception('Failed to add comment');
  }
}

Future<void> addAnswer(String classId, String postId, int commentIndex, CommentsAnswersData answer, String currentId) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      final classData = classSnapshot.data() as Map<String, dynamic>?;

      if (classData != null) {
        List<Map<String, dynamic>> posts = List<Map<String, dynamic>>.from(classData['posts'] ?? []);

        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          List<dynamic> comments = posts[postIndex]['comments'];

          if (commentIndex >= 0 && commentIndex < comments.length) {
            // Initialize answers list if it doesn't exist
            if (comments[commentIndex]['answers'] == null) {
              comments[commentIndex]['answers'] = [];
            }

            // Add the answer
            Map<String, dynamic> answerData = {
              'date': answer.date,
              'user': answer.user,
              'userId': answer.userId,
              'value': answer.value,
              'award': answer.award,
              'edited': answer.edited,
              'teacher': answer.teacher,
            };
            comments[commentIndex]['answers'].add(answerData);

            // Get the index of the new answer
            int newAnswerIndex = comments[commentIndex]['answers'].length - 1;

            // Update the comments field within the post data
            posts[postIndex]['comments'] = comments;

            // Update the posts field within the class data
            classData['posts'] = posts;

            // Update the class document in Firestore
            await classRef.update(classData);

            // Send the notification with the correct answerIndex
            if (comments[commentIndex]['userId'] != currentId) {
              sendNotification(
                [comments[commentIndex]['userId']],
                'Na váš komentár niekto odpovedal.',
                'Diskusia',
                TypeData(
                  id: postId,
                  commentIndex: commentIndex.toString(),
                  answerIndex: newAnswerIndex.toString(), // Correct index
                  type: 'answer'
                )
              );
            }

            return;
          } else {
            throw Exception('Invalid comment index.');
          }
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error adding answer: $e');
    throw Exception('Failed to add answer');
  }
}






Future<void> addPost(String classId, PostsData post) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the data from the class document
      Map<String, dynamic> classData = classSnapshot.data() as Map<String, dynamic>;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(classData['posts'] as List<dynamic>? ?? []);

        // Add the new post to the posts list
        posts.add({
          'comments': post.comments.map((comment) => {
            'date': comment.date,
            'user': comment.user,
            'userId': comment.userId,
            'edited': comment.edited,
            'value': comment.value
          }).toList(),
          'userId': post.userId,
          'date': post.date,
          'edited': post.edited,
          'id': post.id,
          'user': post.user,
          'value': post.value,
        });

        // Update the posts field within the class data
        classData['posts'] = posts;

        // Update the class document in Firestore
        await classRef.update(classData);

        List<String> studentIds = List<String>.from(classData['students'] as List<dynamic>);

        sendNotification(studentIds , 'Nový príspevok od učiteľa', 'Diskusia', TypeData(
          id: (posts.length - 1).toString(),
          commentIndex: '',
          answerIndex: '',
          type: 'post'
        ));

        return;
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error adding post: $e');
    throw Exception('Failed to add post');
  }
}

Future<void> updateCommentValue(String classId, String postId, int commentIndex, String updatedValue) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the class data from the class document
      final classData = classSnapshot.data() as Map<String, dynamic>?;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(
                classData['posts'] as List<dynamic>? ?? []);

        // Find the post with the matching postId
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Find the comment with the matching commentIndex
          List<Map<String, dynamic>> comments =
              List<Map<String, dynamic>>.from(
                  posts[postIndex]['comments'] as List<dynamic>? ?? []);
          if (commentIndex >= 0 && commentIndex < comments.length) {
            // Update the 'value' field of the comment at the found index
            comments[commentIndex]['value'] = updatedValue;
            comments[commentIndex]['edited'] = true;

            // Update the posts field within the class data
            classData['posts'] = posts;

            // Update the class document in Firestore
            await classRef.update(classData);

            return;
          } else {
            throw Exception('Invalid comment index.');
          }
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error updating comment value: $e');
    throw Exception('Failed to update comment value');
  }
}

Future<void> updateAnswerValue(String classId, String postId, int commentIndex, int answerIndex, String updatedValue) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the class data from the class document
      final classData = classSnapshot.data() as Map<String, dynamic>?;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(
                classData['posts'] as List<dynamic>? ?? []);

        // Find the post with the matching postId
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Find the comment with the matching commentIndex
          List<dynamic> comments =
              List<dynamic>.from(
                  posts[postIndex]['comments'] as List<dynamic>? ?? []);
          if (commentIndex >= 0 && commentIndex < comments.length) {
            // Find the answer with the matching answerIndex
            List<Map<String, dynamic>> answers = List<Map<String, dynamic>>.from(
              comments[commentIndex]['answers'] as List<dynamic>? ?? [],
            );
            if (answerIndex >= 0 && answerIndex < answers.length) {
              // Update the 'value' field of the answer at the found index
              answers[answerIndex]['value'] = updatedValue;
              answers[answerIndex]['edited'] = true;

              // Update the posts field within the class data
              classData['posts'] = posts;

              // Update the class document in Firestore
              await classRef.update(classData);

              return;
            } else {
              throw Exception('Invalid answer index.');
            }
          } else {
            throw Exception('Invalid comment index.');
          }
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error updating answer value: $e');
    throw Exception('Failed to update answer value');
  }
}


Future<void> updatePostValue(String classId, String postId, String updatedValue) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the data from the class document
      Map<String, dynamic> classData = classSnapshot.data() as Map<String, dynamic>;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(classData['posts'] as List<dynamic>? ?? []);

        // Find the index of the post to be updated
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Update the 'value' field of the post at the found index
          posts[postIndex]['value'] = updatedValue;
          posts[postIndex]['edited'] = true;

          // Update the posts field within the class data
          classData['posts'] = posts;

          // Update the class document in Firestore
          await classRef.update(classData);

          return;
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error updating post value: $e');
    throw Exception('Failed to update post value');
  }
}


Future<void> deletePost(String classId, String postId) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the data from the class document
      Map<String, dynamic> classData = classSnapshot.data() as Map<String, dynamic>;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(classData['posts'] as List<dynamic>? ?? []);

        // Find the index of the post to be deleted
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Remove the post from the list
          posts.removeAt(postIndex);

          // Update the posts field within the class data
          classData['posts'] = posts;

          // Update the class document in Firestore
          await classRef.update(classData);

          return;
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error deleting post: $e');
    throw Exception('Failed to delete post');
  }
}

Future<void> deleteComment(String classId, String postId, int commentIndex) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef =
        FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the data from the class document
      Map<String, dynamic> classData = classSnapshot.data() as Map<String, dynamic>;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(classData['posts'] as List<dynamic>? ?? []);

        // Find the index of the post to be deleted
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Find the comment with the matching commentIndex
          List<Map<String, dynamic>> comments =
              List<Map<String, dynamic>>.from(
                  posts[postIndex]['comments'] as List<dynamic>? ?? []);

          if (commentIndex >= 0 && commentIndex < comments.length) {
            // Remove the comment from the list
            comments.removeAt(commentIndex);

            // Update the comments field within the post data
            posts[postIndex]['comments'] = comments;

            // Update the posts field within the class data
            classData['posts'] = posts;

            // Update the class document in Firestore
            await classRef.update(classData);

            return;
          } else {
            throw Exception('Invalid comment index.');
          }
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error deleting comment: $e');
    throw Exception('Failed to delete comment');
  }
}

Future<void> deleteAnswer(String classId, String postId, int commentIndex, int answerIndex) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the class data from the class document
      final classData = classSnapshot.data() as Map<String, dynamic>?;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(
                classData['posts'] as List<dynamic>? ?? []);

        // Find the post with the matching postId
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Find the comment with the matching commentIndex
          List<dynamic> comments =
              List<dynamic>.from(
                  posts[postIndex]['comments'] as List<dynamic>? ?? []);
          if (commentIndex >= 0 && commentIndex < comments.length) {
            // Find the answer with the matching answerIndex
            List<Map<String, dynamic>> answers = List<Map<String, dynamic>>.from(
              comments[commentIndex]['answers'] as List<dynamic>? ?? [],
            );
            if (answerIndex >= 0 && answerIndex < answers.length) {
              // Remove the answer from the list
              answers.removeAt(answerIndex);

              // Update the answers field within the comment data
              comments[commentIndex]['answers'] = answers;

              // Update the comments field within the post data
              posts[postIndex]['comments'] = comments;

              // Update the posts field within the class data
              classData['posts'] = posts;

              // Update the class document in Firestore
              await classRef.update(classData);

              return;
            } else {
              throw Exception('Invalid answer index.');
            }
          } else {
            throw Exception('Invalid comment index.');
          }
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error deleting answer: $e');
    throw Exception('Failed to delete answer');
  }
}

Future<void> toggleCommentAward(String classId, String postId, int commentIndex, String userId, CommentsData comment, String currentId) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the class data from the class document
      final classData = classSnapshot.data() as Map<String, dynamic>?;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts = List<Map<String, dynamic>>.from(
          classData['posts'] as List<dynamic>? ?? [],
        );

        // Find the post with the matching postId
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Find the comment with the matching commentIndex
          List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(
            posts[postIndex]['comments'] as List<dynamic>? ?? [],
          );

          if (commentIndex >= 0 && commentIndex < comments.length) {
            // Toggle the 'award' field of the comment at the found index
            comments[commentIndex]['award'] = !(comments[commentIndex]['award'] ?? false);

            // Get the index of the new answer

            // Update the posts field within the class data
            classData['posts'] = posts;

            // Update the class document in Firestore
            await classRef.update(classData);
            await incrementDiscussionPoints(userId, 1, comments[commentIndex]['award']);
            
            if (userId != currentId) {
            sendNotification([comment.userId] , 'Tvoj komentár bol ocenený učiteľom.', 'Diskusia', TypeData(
              id: postId,
                commentIndex: (posts[postIndex]['comments'].length-1).toString(),
                answerIndex: '',
                type: 'post'
              ));
            }
            return;
          } else {
            throw Exception('Invalid comment index.');
          }
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error toggling comment award: $e');
    throw Exception('Failed to toggle comment award');
  }
}

Future<void> toggleAnswerAward(String classId, String postId, int commentIndex, int answerIndex, String userId, String currentId) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the class data from the class document
      final classData = classSnapshot.data() as Map<String, dynamic>?;

      if (classData != null) {
        // Extract the posts field from the class data
        List<Map<String, dynamic>> posts = List<Map<String, dynamic>>.from(
          classData['posts'] as List<dynamic>? ?? [],
        );

        // Find the post with the matching postId
        int postIndex = posts.indexWhere((postItem) => postItem['id'] == postId);

        if (postIndex != -1) {
          // Find the comment with the matching commentIndex
          List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(
            posts[postIndex]['comments'] as List<dynamic>? ?? [],
          );

          if (commentIndex >= 0 && commentIndex < comments.length) {
            // Find the answer with the matching answerIndex
            List<Map<String, dynamic>> answers = List<Map<String, dynamic>>.from(
              comments[commentIndex]['answers'] as List<dynamic>? ?? [],
            );

            if (answerIndex >= 0 && answerIndex < answers.length) {
              // Toggle the 'award' field of the answer at the found index
              answers[answerIndex]['award'] = !(answers[answerIndex]['award'] ?? false);

              // Update the posts field within the class data
              classData['posts'] = posts;
            int newAnswerIndex = comments[commentIndex]['answers'].length - 1;
              

                await incrementDiscussionPoints(userId, -1, answers[answerIndex]['award']);
              

              if (userId != currentId) {
                sendNotification(
                  [userId],
                  'Tvoj komentár bol ocenený učiteľom.',
                  'Diskusia',
                  TypeData(
                    id: postId,
                    commentIndex: commentIndex.toString(),
                    answerIndex: newAnswerIndex.toString(), // Correct index
                    type: 'answer'
                  )
                );
              }

              // Update the class document in Firestore
              await classRef.update(classData);

              return;
            } else {
              throw Exception('Invalid answer index.');
            }
          } else {
            throw Exception('Invalid comment index.');
          }
        } else {
          throw Exception('Invalid post ID.');
        }
      } else {
        throw Exception('Retrieved class data is null.');
      }
    } else {
      throw Exception('Class document does not exist.');
    }
  } catch (e) {
    print('Error toggling answer award: $e');
    throw Exception('Failed to toggle answer award');
  }
}

Future<void> addClass(String className, String school, void Function(ClassDataWithId)? addSchoolData, void Function(String) addToList) async {
  try {
    // Reference to the Firestore collection where classes are stored
    CollectionReference classCollection = FirebaseFirestore.instance.collection('classes');

    // Create results first and get the ID
    String resultsId = await createResults(); // Assuming createResults() returns the ID of the created results

    // Create a new document with a generated ID
    DocumentReference newClassRef = classCollection.doc();

    // Create a ClassData instance with the provided name and results ID
    ClassData newClass = ClassData(
      name: className,
      challenge: 0,
      capitolOrder: [0,1,2,3,4],
      materials: [],
      posts: [],
      school: school,
      students: [],
      teachers: [],
      results: resultsId // Use the results ID
    );

    // Convert the ClassData instance to a Map
    Map<String, dynamic> classData = {
      'name': newClass.name,
      'capitolOrder': newClass.capitolOrder,
      'materials': newClass.materials,
      'posts': newClass.posts,
      'school': newClass.school,
      'students': newClass.students,
      'teachers': newClass.teachers,
      'challenge': newClass.challenge,
      'results': newClass.results // Include the results ID
    };

    // Add the class data to Firestore
    await newClassRef.set(classData);

    addClassToSchool(newClassRef.id, school);
    addToList(newClassRef.id);
    if (addSchoolData != null) addSchoolData(ClassDataWithId(newClassRef.id, newClass));
    
    print('Class added successfully with ID: ${newClassRef.id}');
  } catch (e) {
    print('Error adding class: $e');
    throw Exception('Failed to add class');
  }
}


Future<bool> doesClassNameExist(String className, List<String> classIds) async {
  for (String classId in classIds) {
    try {
      ClassData classData = await fetchClass(classId);
      if (classData.name == className) {
        return true;
      }
    } catch (e) {
      print('Error fetching class data for ID $classId: $e');
      // Optionally, you can decide how to handle this error.
      // For now, it will continue to the next class ID.
    }
  }
  return false;
}

Future<void> incrementClassChallenge(String classId, int increment) async {
  try {
    // Reference to the class document in Firestore
    DocumentReference classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    // Retrieve the class document
    DocumentSnapshot classSnapshot = await classRef.get();

    if (classSnapshot.exists) {
      // Extract the data from the class document
      Map<String, dynamic> classData = classSnapshot.data() as Map<String, dynamic>;

      // Current challenge value
      int currentChallenge = classData['challenge'] as int? ?? 0;

      // Calculate the new challenge value
      int newChallenge = currentChallenge + increment;

      // Update the challenge value in the Firestore document
      await classRef.update({'challenge': newChallenge});

      print('Challenge incremented successfully for class ID: $classId');
    } else {
      print('Class document does not exist for ID: $classId');
    }
  } catch (e) {
    print('Error incrementing challenge for class ID $classId: $e');
    throw Exception('Failed to increment challenge for class');
  }
}







