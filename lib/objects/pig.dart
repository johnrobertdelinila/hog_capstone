
import 'package:cloud_firestore/cloud_firestore.dart';

class Pig {
  String name;
  String subBreed;
  int price;
  int weight;
  int age;
  String gender;
  String vaccinated;
  bool isArchive;
  String remarks;
  DocumentReference reference;

  Pig.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['subBreed'] != null),
        assert(map['price'] != null),
        name = map['name'],
        subBreed = map['subBreed'],
        weight = map['weight'],
        age = map['age'],
        gender = map['gender'],
        vaccinated = map['vaccinatedDate'],
        isArchive = map['isArchive'],
        price = map['price'],
        remarks = map['remarks'];

  Pig.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

}