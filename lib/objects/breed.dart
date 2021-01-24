
import 'package:cloud_firestore/cloud_firestore.dart';

class Breed {
  String breedName;
  DocumentReference reference;

  Breed.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['breedName'] != null),
        breedName = map['breedName'];

  Breed.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

}