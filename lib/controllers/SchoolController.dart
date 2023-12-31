import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/models/SchoolModel.dart';

Future<SchoolData> fetchSchool(String schoolId) async {
  try {
    print('school');
    // Reference to the school document in Firestore
    DocumentReference schoolRef =
        FirebaseFirestore.instance.collection('schools').doc(schoolId);

    // Retrieve the school document
    DocumentSnapshot schoolSnapshot = await schoolRef.get();

    if (schoolSnapshot.exists) {
      // Extract the data from the school document
      final data = schoolSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        final classes = data['classes'] as List<dynamic>;
        final teachers = data['teachers'] as List<dynamic>;

        return SchoolData(
          name: data['name'] as String? ?? '',
          admin: data['admin'] as String? ?? '',
          classes: classes.map((classId) => classId as String).toList(),
          teachers: teachers.map((teacherId) => teacherId as String).toList(),
        );
      } else {
        throw Exception('Retrieved document data is null.');
      }
    } else {
      throw Exception('School document does not exist.');
    }
  } catch (e) {
    print('Error fetching school: $e');
    throw Exception('Failed to fetch school');
  }
}

Future<void> addClassToSchool(String newClass, String schoolId) async {
  try {
    // Reference to the school document in Firestore
    DocumentReference schoolRef =
        FirebaseFirestore.instance.collection('schools').doc(schoolId);

    // Retrieve the school document
    DocumentSnapshot schoolSnapshot = await schoolRef.get();

    if (schoolSnapshot.exists) {
      // Update the classes field in Firestore
      await schoolRef.update({
        'classes': FieldValue.arrayUnion([newClass]),
      });
    } else {
      throw Exception('School document does not exist.');
    }
  } catch (e) {
    print('Error adding class: $e');
    throw Exception('Failed to add class');
  }
}

Future<void> addTeacherToSchool(String newTeacher, String schoolId) async {
  try {
    // Reference to the school document in Firestore
    DocumentReference schoolRef =
        FirebaseFirestore.instance.collection('schools').doc(schoolId);

    // Retrieve the school document
    DocumentSnapshot schoolSnapshot = await schoolRef.get();

    if (schoolSnapshot.exists) {
      // Update the teachers field in Firestore
      await schoolRef.update({
        'teachers': FieldValue.arrayUnion([newTeacher]),
      });
    } else {
      throw Exception('School document does not exist.');
    }
  } catch (e) {
    print('Error adding class: $e');
    throw Exception('Failed to add class');
  }
}

Future<void> addSchool(String schoolId, String name, String admin, List<String> classes, bool setTeacher) async {
  try {
    // Reference to the schools collection in Firestore
    CollectionReference schoolsCollection = FirebaseFirestore.instance.collection('schools');

    // Add the school data to Firestore with the specified schoolId
    await schoolsCollection.doc(schoolId).set({
      'name': name,
      'admin': admin,
      'classes': classes,
      'teachers': setTeacher ? [admin] : []
    });
  } catch (e) {
    print('Error adding school: $e');
    throw Exception('Failed to add school');
  }
}

Future<bool> doesSchoolExist(String schoolId) async {
  try {
    // Fetch the school data using the provided school ID
    await fetchSchool(schoolId);
    // If fetchSchool is successful and doesn't throw an exception,
    // it means the school exists
    return true;
  } catch (e) {
    // If an exception is thrown, it means the school does not exist
    // or there was an error in fetching the data
    print('Error checking if school exists: $e');
    return false;
  }
}