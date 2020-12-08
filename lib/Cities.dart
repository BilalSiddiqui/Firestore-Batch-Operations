import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_batch/City.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MyCities extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CityState();
}

class CityState extends State<StatefulWidget> {
  final COLLECTION_CITIES = 'cities';
  List<City> _cities;
  bool _loadingCities;

  void getAllCities() {
    FirebaseFirestore.instance
        .collection(COLLECTION_CITIES)
        .snapshots()
        .listen((snapshot) {
      _loadingCities = false;
      setState(() {
        _cities = getCitiesFromQuery(snapshot);
      });
    });
  }

  List<City> getCitiesFromQuery(QuerySnapshot snapshot) {
    return snapshot.docs.map((DocumentSnapshot doc) {
      return City.fromSnapshot(doc);
    }).toList();
  }

  void addBatchCities() {
    final CitiesRef = FirebaseFirestore.instance.collection(COLLECTION_CITIES);
    WriteBatch batch = FirebaseFirestore.instance.batch();
    final cities = getCities();
    for (City city in cities) {
      final newCityItem = CitiesRef.doc();
      batch.set(newCityItem, {
        'name': city.name,
        'createdAt': DateTime.now().millisecondsSinceEpoch
      });
    }
    batch.commit();
  }

  Future<void> updateBatchCities() {
    final CitiesRef = FirebaseFirestore.instance.collection(COLLECTION_CITIES);
    WriteBatch batch = FirebaseFirestore.instance.batch();

    return CitiesRef.get().then((querySnapshot) {
      var count = 0;
      querySnapshot.docs.forEach((document) {
        batch.update(document.reference, {'name': 'City${count++}'});
      });

      return batch.commit();
    });
  }

  Future<void> deleteBatchCities() {
    final CitiesRef = FirebaseFirestore.instance.collection(COLLECTION_CITIES);
    WriteBatch batch = FirebaseFirestore.instance.batch();

    return CitiesRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      return batch.commit();
    });
  }

  List<City> getCities() {
    List<City> cities = List<City>();
    cities.add(City(name: "Islamabad"));
    cities.add(City(name: "New York"));
    cities.add(City(name: "London"));
    cities.add(City(name: "Amsterdam"));
    cities.add(City(name: "Lahore"));
    cities.add(City(name: "Karachi"));
    cities.add(City(name: "Peshawar"));
    return cities;
  }

  @override
  void initState() {
    setState(() {
      getAllCities();
      _loadingCities = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding:EdgeInsets.all(50),color:Colors.white,child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              child: Text(
                "Add",
              ),
              onPressed: () {
                addBatchCities();
              },
            ),RaisedButton(
              child: Text(
                "Update",
              ),
              onPressed: () {
                updateBatchCities();
              },
            ),RaisedButton(
              child: Text(
                "Delete",
              ),
              onPressed: () {
                deleteBatchCities();
              },
            ),
          ],
        ),
        _loadingCities
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _cities.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Text(_cities.elementAt(index).name);
                })
      ],
    ));
  }
}
