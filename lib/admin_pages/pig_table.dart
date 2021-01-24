
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customer/objects/pig.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'add_product.dart';

class PigTable extends StatefulWidget {
  @override
  PigTableState createState() => PigTableState();
}

class PigTableState extends State<PigTable> {

  @override
  void initState() {
    _getRemarks();
  }

  bool breedOrder = false;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<DropdownMenuItem<String>> remarksDropDown = <DropdownMenuItem<String>>[];
  String _currentRemarks;

  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> newList = snapshot.documents.map((DocumentSnapshot documentSnapshot) {
      var pig = Pig.fromSnapshot(documentSnapshot);
      return new DataRow(
          cells: [
            DataCell(Text(toBeginningOfSentenceCase(pig.name))),
            DataCell(Text(pig.subBreed)),
            DataCell(Text(pig.price.toString())),
            DataCell(Text(pig.weight != null ? pig.weight.toString() : "")),
            DataCell(Text(pig.age != null ? pig.age.toString() : "")),
            DataCell(Text(pig.gender != null ? pig.gender : "")),
            DataCell(Text(pig.vaccinated != null ? pig.vaccinated : "")),
            DataCell(Center(
              child: IconButton(
                icon: Icon(Icons.edit,),
                color: Colors.green,
                onPressed: () {
                  // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  Navigator.popAndPushNamed(context, '/addPig',arguments: {'pig': pig});
                },
              ),
            )),
            DataCell(Center(
              child: IconButton(
                icon: Icon(pig.isArchive == null || pig.isArchive ? Icons.archive : Icons.unarchive),
                color: pig.isArchive == null || pig.isArchive ? Colors.green : Colors.red,
                onPressed: () {
                  var archive = pig.isArchive == null ? true : !pig.isArchive;
                  pig.reference.setData({
                    "isArchive": archive
                  }, merge: true)
                      .then((value) => setState((){}));
                  Fluttertoast.showToast(msg: 'Pig is ' + (archive ? "Archived" : "Unarchived"));
                },
              ),
            ),),
            DataCell(Center(
              child: DropdownButton(
                items: remarksDropDown,
                onChanged: (selected) {
                  changeSelectedBrand(selected, pig);
                },
                value: pig.remarks == null ? "None" : pig.remarks,
              ),
            ),),
          ]
      );
    }).toList();
    return newList;
  }

  _getRemarks() {
    remarksDropDown = getRemarksDropdown();
    _currentRemarks = "None";
  }

  List<DropdownMenuItem<String>> getRemarksDropdown() {
    List<DropdownMenuItem<String>> items = new List();
    setState(() {
      items.insert(
          0,
          DropdownMenuItem(
              child: Text("None"),
              value: "None"
          )
      );
      items.insert(
          1,
          DropdownMenuItem(
              child: Text("Sold"),
              value: "Sold"
          )
      );
      items.insert(
          2,
          DropdownMenuItem(
              child: Text("Dead"),
              value: "Dead"
          )
      );
      items.insert(
          3,
          DropdownMenuItem(
              child: Text("Sick"),
              value: "Sick"
          )
      );
    });
    return items;
  }

  changeSelectedBrand(String selectedRemarks, Pig pig) {
    _currentRemarks = selectedRemarks;
    pig.reference.setData({
      "remarks": selectedRemarks
    }, merge: true)
        .then((value) => setState((){}));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Pigs")),
      body: Container(
        padding: EdgeInsets.all(18),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            ButtonTheme(
              minWidth: 250.0,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.pink)
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                color: Colors.pink,
                textColor: Colors.white,
                child: Text(
                  'Add Pig',
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: () {
                  // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  Navigator.popAndPushNamed(context, '/addPig');
                },
              ),
            ),
            SizedBox(height: 10,),
            StreamBuilder(
              stream: Firestore.instance.collection("pigs").snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();
                return DataTable(
                  sortColumnIndex: 0,
                  sortAscending: this.breedOrder,
                  columns: <DataColumn>[
                    DataColumn(
                        label: Text(
                          'Breed',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Breed of pig",
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            this.breedOrder = ascending;
                          });
                        }
                    ),
                    DataColumn(
                        label: Text(
                          'Cage',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Cage of a pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Price per weight',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),  
                        ),
                        tooltip: "Price of a pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Weight',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Price of a pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Age',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Price of a pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Gender',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Price of a pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Vaccinated Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Price of a pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Edit pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Archive',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Archive pig"
                    ),
                    DataColumn(
                        label: Text(
                          'Remarks',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: "Remarks of Pig"
                    ),
                  ],
                  rows: _createRows(snapshot.data),

                );
              },
            )
          ],
        )
      )
    );
  }

}