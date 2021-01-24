
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customer/objects/cage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'brand.dart';

class CageTable extends StatefulWidget {
  @override
  CageTableState createState() => CageTableState();
}

class CageTableState extends State<CageTable> {

  TextEditingController brandController = TextEditingController();
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  BrandService _brandService = BrandService();

  void _brandAlert(String id) {
    var alert = new AlertDialog(
      content: Form(
        key: _brandFormKey,
        child: TextFormField(
          controller: brandController,
          validator: (value){
            if(value.isEmpty){
              return 'Cage cannot be empty';
            }else {
              return '';
            }
          },
          decoration: InputDecoration(
              hintText: "Add cage"
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('CANCEL')),
        FlatButton(onPressed: (){
          if(brandController.text != null && brandController.text.length > 0){
            if(id != null) {
              _brandService.updateBrand(brandController.text, id);
              Fluttertoast.showToast(msg: "Cage Updated");
            }else {
              _brandService.createBrand(brandController.text);
              Fluttertoast.showToast(msg: 'Cage Added');
            }
          }else {
            Fluttertoast.showToast(msg: 'Cage name must not be empty.', backgroundColor: Colors.red, timeInSecForIosWeb: 2,);
          }
          Navigator.pop(context);
        }, child: Text('ADD')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  bool cageOrder = false;

  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> newList = snapshot.documents.map((DocumentSnapshot documentSnapshot) {
      var cage = Cage.fromSnapshot(documentSnapshot);
      return new DataRow(
          cells: [
            DataCell(Text(cage.cageName)),
            DataCell(Center(
              child: IconButton(
                icon: Icon(Icons.edit,),
                color: Colors.green,
                onPressed: () {
                  _brandAlert(cage.reference.documentID);
                  brandController.text = cage.cageName;
                  brandController.selection = TextSelection.fromPosition(
                    TextPosition(offset: brandController.text.length),
                  );
                  setState(() {});
                },
              ),
            ),)
          ]
      );
    }).toList();
    return newList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Cage Name")),
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
                      'Add Cage',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () {
                      brandController.text = "";
                      _brandAlert(null);
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 10,),
                StreamBuilder(
                  stream: Firestore.instance.collection("cages").orderBy("cageName", descending: this.cageOrder).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    return Container(
                      constraints: BoxConstraints(maxWidth: 550),
                      child: DataTable(
                        sortColumnIndex: 0,
                        sortAscending: this.cageOrder,
                        rows: _createRows(snapshot.data),
                        columns: <DataColumn>[
                          DataColumn(
                              label: Text(
                                'Cage Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              tooltip: "Cage of pig",
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  this.cageOrder = ascending;
                                });
                              }
                          ),
                          DataColumn(
                              label: Text(
                                'Edit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              tooltip: "Edit",
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  this.cageOrder = ascending;
                                });
                              }
                          ),
                        ],
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