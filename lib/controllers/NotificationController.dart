import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/models/NotificationModel.dart';
import 'package:infomat/controllers/UserController.dart';
import 'package:infomat/models/UserModel.dart';

Future<List<NotificationsData>> fetchNotifications(UserData userData) async {
  try {
    print('notification');
    CollectionReference notificationsRef =
        FirebaseFirestore.instance.collection('notifications');

    // Filter notifications based on the user's notifications list
    List<String> userNotificationIds = userData.notifications.map((n) => n.id).toList();

    if (userNotificationIds.isEmpty) {
      return [];
    }

    Query notificationsQuery = notificationsRef.where(FieldPath.documentId, whereIn: userNotificationIds);

    QuerySnapshot snapshot = await notificationsQuery.get();

    List<NotificationsData> notifications = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Extracting the type data
      Map<String, dynamic> typeDataMap = data['type'] as Map<String, dynamic>;
      TypeData typeData = TypeData(
        id: typeDataMap['id'] ?? '',
        commentIndex: typeDataMap['commentIndex'] ?? '',
        answerIndex: typeDataMap['answerIndex'] ?? '',
        type: typeDataMap['type'] ?? '',
      );

      return NotificationsData(
        content: data['content'] ?? '',
        date: data['date'] ?? '',
        title: data['title'] ?? '',
        type: typeData,
        user: data['user'] ?? '',
        seen: data['seen'] ?? false
      );
    }).toList();

    return notifications;
  } catch (e) {
    print('Error fetching notifications: $e');
    throw Exception('Failed to fetch notifications');
  }
}

Future<void> sendNotification(List<String> userIds, String content, String title, TypeData type) async {
  try {
    final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
    CollectionReference notificationsRef = FirebaseFirestore.instance.collection('notifications');
    
    DocumentReference notificationDocRef = await notificationsRef.add({
      'content': content,
      'date': Timestamp.now(),
      'title': title,
      'type': {
        'id': type.id,
        'commentIndex': type.commentIndex,
        'answerIndex': type.answerIndex,
        'type': type.type,
      },
    });

    String notificationId = notificationDocRef.id;

    for (String userId in userIds) {
      UserData userData = await fetchUser(userId);
      
      // Convert notifications to list of maps
      List<Map<String, Object?>> notificationsList = userData.notifications.map((notification) {
        return {
          'id': notification.id,
          'seen': notification.seen,
          'date': notification.date, // Assuming each notification has a date field
        };
      }).toList();

      // Add the new notification
      notificationsList.add({
        'id': notificationId,
        'seen': false,
        'date': Timestamp.now(),
      });

      // If the list size exceeds 20, remove the oldest notification
      if (notificationsList.length > 20) {
        // Sort the list by date, oldest first
        notificationsList.sort((a, b) {
          Timestamp? dateA = a['date'] as Timestamp?;
          Timestamp? dateB = b['date'] as Timestamp?;
          if (dateA != null && dateB != null) {
            return dateA.compareTo(dateB);
          } else if (dateA != null) {
            return -1; // Keep A if B is null
          } else if (dateB != null) {
            return 1; // Keep B if A is null
          }
          return 0; // Both are null
        });
        notificationsList.removeAt(0); // Remove the oldest notification
      }

      // Update the user's notifications list in the database
      await usersRef.doc(userId).update({
        'notifications': notificationsList
      });
    }
  } catch (e) {
    print('Error sending notifications: $e');
    throw Exception('Failed to send notifications');
  }
}

Future<void> setAllNotificationsAsSeen(UserData userData) async {
  try {
    final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

    // Update user's notifications in the user document as well
    // This step is needed if you're also keeping a reference of seen/unseen status in the user document
    List<Map<String, Object?>> updatedNotificationsList = userData.notifications.map((notification) {
      return {
        'id': notification.id,
        'seen': true, // Set seen to true
        'date': notification.date, // Assuming each notification has a date field
      };
    }).toList();

    await usersRef.doc(userData.id).update({
      'notifications': updatedNotificationsList
    });

  } catch (e) {
    print('Error setting notifications as seen: $e');
    throw Exception('Failed to set notifications as seen');
  }
}

