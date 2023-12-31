import 'package:cloud_firestore/cloud_firestore.dart';

class TypeData {
  String id;
  String commentIndex;
  String answerIndex;
  String type;

  TypeData({
    required this.id,
    required this.commentIndex,
    required this.answerIndex,
    required this.type,
  });
}

class NotificationsData {
  String content;
  Timestamp date;
  String title;
  TypeData type;
  String user;
  bool seen;

  NotificationsData({
    required this.content,
    required this.date,
    required this.title,
    required this.type,
    required this.user,
    required this.seen
  });
}