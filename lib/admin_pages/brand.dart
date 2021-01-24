import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
class BrandService{
  Firestore _firestore = Firestore.instance;
  String ref = 'cages';

  void createBrand(String name){
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection(ref).document(brandId).setData({'cageName': name});
  }

  void updateBrand(String newName, String id) {
    _firestore.collection(ref).document(id).updateData({"cageName": newName});
  }

  Future<List<DocumentSnapshot>> getBrands() => _firestore.collection(ref).getDocuments().then((snaps){
    print(snaps.documents.length);
    return snaps.documents;
  });

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) =>
      _firestore.collection(ref).where('cageName', isEqualTo: suggestion).getDocuments().then((snap){
        return snap.documents;
      });
}