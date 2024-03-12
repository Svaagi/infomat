import 'package:cloud_firestore/cloud_firestore.dart';

class ClassData {
  String name;
  List<PostsData> posts;
  String school;
  List<String> students;
  List<String> teachers;
  List<String> materials;
  List<int> capitolOrder;
  String results;
  int challenge;

  ClassData({
    required this.name,
    required this.posts,
    required this.school,
    required this.students,
    required this.teachers,
    required this.materials,
    required this.capitolOrder,
    required this.results,
    required this.challenge,
  });

  factory ClassData.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return ClassData(
      name: data['name'] ?? '',
      posts: List<PostsData>.from(data['posts'].map((x) => PostsData.fromMap(x))),
      school: data['school'] ?? '',
      students: List<String>.from(data['students']),
      teachers: List<String>.from(data['teachers']),
      materials: List<String>.from(data['materials']),
      capitolOrder: List<int>.from(data['capitolOrder']),
      results: data['results'] ?? '',
      challenge: data['challenge'] ?? 0,
    );
  }
}

class PostsData {
  List<CommentsData> comments;
  Timestamp date;
  String id;
  String user;
  String userId;
  String value;
  bool edited;

  PostsData({
    required this.comments,
    required this.date,
    required this.id,
    required this.user,
    required this.userId,
    required this.value,
    required this.edited,
  });

  factory PostsData.fromMap(Map<String, dynamic> map) {
    return PostsData(
      comments: List<CommentsData>.from(map['comments'].map((x) => CommentsData.fromMap(x))),
      date: map['date'],
      id: map['id'],
      user: map['user'],
      userId: map['userId'],
      value: map['value'],
      edited: map['edited'] ?? false,
    );
  }
}

class CommentsData {
  List<CommentsAnswersData> answers;
  Timestamp date;
  String user;
  String userId;
  String value;
  bool award;
  bool teacher;
  bool edited;

  CommentsData({
    required this.answers,
    required this.date,
    required this.user,
    required this.userId,
    required this.value,
    required this.award,
    required this.teacher,
    required this.edited,
  });

  factory CommentsData.fromMap(Map<String, dynamic> map) {
    return CommentsData(
      answers: List<CommentsAnswersData>.from(map['answers'].map((x) => CommentsAnswersData.fromMap(x))),
      date: map['date'],
      user: map['user'],
      userId: map['userId'],
      value: map['value'],
      award: map['award'] ?? false,
      teacher: map['teacher'] ?? false,
      edited: map['edited'] ?? false,
    );
  }
}

class CommentsAnswersData {
  Timestamp date;
  String user;
  String userId;
  String value;
  bool award;
  bool teacher;
  bool edited;

  CommentsAnswersData({
    required this.date,
    required this.user,
    required this.userId,
    required this.value,
    required this.award,
    required this.teacher,
    required this.edited,
  });

  factory CommentsAnswersData.fromMap(Map<String, dynamic> map) {
    return CommentsAnswersData(
      date: map['date'],
      user: map['user'],
      userId: map['userId'],
      value: map['value'],
      award: map['award'] ?? false,
      teacher: map['teacher'] ?? false,
      edited: map['edited'] ?? false,
    );
  }
}

class ClassDataWithId {
  final String id;
  final ClassData data;

  ClassDataWithId(this.id, this.data);
}
