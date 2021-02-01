
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_customer/objects/pig.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';


class PigTable extends StatefulWidget {
  @override
  PigTableState createState() => PigTableState();
}

class PigTableState extends State<PigTable> {

  GlobalKey globalKey = new GlobalKey();

  @override
  void initState() {
    _getRemarks();
  }

  Future<Uint8List> toQrImageData(String text) async {
    try {
      final image = await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: false,
        color: Color(0xff000000),
        emptyColor: Color(0xffffffff0),
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);
      return a.buffer.asUint8List();
    } catch (e) {
      throw e;
    }
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
            DataCell(Center(
              child: IconButton(
                icon: Icon(Icons.qr_code,),
                color: Colors.blue,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0)
                      ),
                      title: Text('QR Code of ' + toBeginningOfSentenceCase(pig.name)),
                      content: Container(
                        height: 300,
                        width: 300,
                        child: QrImage(
                          data: pig.id,
                          version: QrVersions.auto,
                          size: 20,
                          gapless: false,
                          embeddedImage: AssetImage('assets/pigIcon.png'),
                          embeddedImageStyle: QrEmbeddedImageStyle(
                            size: Size(60, 60),
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () => toQrImageData(pig.id),
                          child: Text(
                              'Download',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red
                              )
                          ),
                        ),
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              )
                          ),
                        ),
                      ],
                  ));
                },
              ),
            )),
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

    Size size = MediaQuery.of(context).size;

    double itemHeight = 20;
    double itemWidth = 20;

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
                  'Add Hog',
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
            ButtonTheme(
              minWidth: 250.0,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.pink)
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                color: Colors.blue,
                textColor: Colors.white,
                child: Text(
                  'Generate QRS',
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0)
                        ),
                        title: Text('QR Code'),
                        content: Container(
                          height: 1000,
                          width: 1000,
                          child: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: (itemWidth / itemHeight),
                                crossAxisCount: 3,
                                mainAxisSpacing: 10.0,
                                crossAxisSpacing: 10.0,

                              ),
                              delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                                return Container(
                                  width: 50,
                                  height: 50,
                                  child: QrImage(
                                    data: "asdadsf",
                                    version: QrVersions.auto,
                                    size: 20,
                                    gapless: false,
                                    embeddedImage: AssetImage('assets/pigIcon.png'),
                                    embeddedImageStyle: QrEmbeddedImageStyle(
                                      size: Size(10, 10),
                                    ),
                                  ),
                                );
                              },
                                  childCount: 8
                              )
                          ),
                        )
                      )
                  );
                },
              ),
            ),
            SizedBox(height: 10,),
            StreamBuilder(
              stream: Firestore.instance.collection("pigs").snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();
                return Expanded(
                  child: DataTable(
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
                            'Price weight',
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
                            'Vaccine Date',
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
                      DataColumn(
                          label: Text(
                            'QR',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          tooltip: "QR Code of Pig"
                      ),
                    ],
                    rows: _createRows(snapshot.data),

                  ),
                );
              },
            )
          ],
        )
      )
    );
  }

}