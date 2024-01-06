import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infomat/models/MaterialModel.dart';

Future<List<MaterialData>> fetchMaterials(List<String> materialIds) async {
  try {
    print('material');
    // Reference to the "materials" collection in Firestore
    CollectionReference materialsRef =
        FirebaseFirestore.instance.collection('materials');

    // Only proceed if there are material IDs to look up
    if (materialIds.isEmpty) {
      return [];
    }

    // Construct a query to fetch only the materials whose IDs match those in the schoolClass's materials list
    Query materialsQuery = materialsRef.where(FieldPath.documentId, whereIn: materialIds);

    // Retrieve the materials documents
    QuerySnapshot snapshot = await materialsQuery.get();

    // Extract the data from the documents
    List<MaterialData> materials = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String materialId = doc.id;

      return MaterialData(
        materialId: materialId,
        image: data['image'] as String? ?? '',
        background: data['background'] as String? ?? '',
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        link: data['link'] as String? ?? '',
        subject: data['subject'] as String? ?? '',
        type: data['type'] as String? ?? '',
        association: data['association'] as String? ?? '',
        video: data['video'] as String? ?? '',
      );
    }).toList();

    return materials;
  } catch (e) {
    print('Error fetching materials: $e');
    throw Exception('Failed to fetch materials');
  }
}


