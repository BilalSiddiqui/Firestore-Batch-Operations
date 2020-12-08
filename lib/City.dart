import 'package:cloud_firestore/cloud_firestore.dart';

class City {
  String id;
  String name;

  City({this.name}) :id=null;


  City.fromSnapshot(DocumentSnapshot doc)  : assert(doc != null),
        id = doc.id,
        name = doc.data()['name'];
}