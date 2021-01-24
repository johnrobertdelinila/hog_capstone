
import 'package:cloud_firestore/cloud_firestore.dart';

class Cage {
  String cageName;
  DocumentReference reference;

  Cage.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['cageName'] != null),
        cageName = map['cageName'];

  Cage.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

}