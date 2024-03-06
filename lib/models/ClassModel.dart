import 'package:cloud_firestore/cloud_firestore.dart';


class OptionsData {
  String id;
  ClassData data;

  OptionsData({
    required this.id,
    required this.data,
  });
}

class ClassDataWithId {
  final String id;
  final ClassData data;

  ClassDataWithId(this.id, this.data);
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
    required this.userId,
    required this.award,
    required this.date,
    required this.user,
    required this.value,
    required this.edited,
    required this.teacher
  });
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
    required this.award,
    required this.userId,
    required this.edited,
    required this.answers,
    required this.date,
    required this.user,
    required this.value,
    required this.teacher
  });
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
    required this.userId,
    required this.edited,
    required this.date,
    required this.id,
    required this.user,
    required this.value,
  });
}

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
    required this.challenge
  });
}