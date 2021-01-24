import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CategoryService {
  Firestore _firestore = Firestore.instance;
  String ref = 'breeds';

  void createCategory(String name) {
    var id = Uuid();
    String categoryId = id.v1();
    _firestore.collection(ref).document(categoryId).setData({'breedName': name.toLowerCase()});
  }

  void updateCategory(String newName, String id) {
    _firestore.collection(ref).document(id).updateData({'breedName': newName.toLowerCase()});
  }

  Future<List<DocumentSnapshot>> getCategories() =>
    _firestore.collection(ref).getDocuments().then((snaps) {
      return snaps.documents;
    });

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) =>
    _firestore.collection(ref).where('breedName', isEqualTo: suggestion).getDocuments().then((snap){
      return snap.documents;
    });

}