
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customer/objects/breed.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'category.dart';

class BreedTable extends StatefulWidget {
  @override
  BreedTableState createState() => BreedTableState();
}

class BreedTableState extends State<BreedTable> {

  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  TextEditingController categoryController = TextEditingController();
  CategoryService _categoryService = CategoryService();

  void _categoryAlert(String categoryId) {
    var alert = new AlertDialog(
      content: Form(
        key: _categoryFormKey,
        child: TextFormField(
          controller: categoryController,
          validator: (value){
            if(value.isEmpty){
              return 'Breed cannot be empty';
            }else {
              return '';
            }
          },
          decoration: InputDecoration(
              hintText: "Add breed"
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('CANCEL')),
        FlatButton(onPressed: (){
          if(categoryController.text != null && categoryController.text.length > 2){
            if(categoryId == null) {
              _categoryService.createCategory(categoryController.text);
              Fluttertoast.showToast(msg: 'Breed Added');
            }else {
              _categoryService.updateCategory(categoryController.text, categoryId);
              Fluttertoast.showToast(msg: 'Breed Updated');
            }
          }else {
            Fluttertoast.showToast(msg: 'Breed name must not be empty.', backgroundColor: Colors.red, timeInSecForIosWeb: 2,);
          }
          Navigator.pop(context);
        }, child: Text(categoryId != null ? "UPDATE" : "ADD")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  bool breedOrder = false;

  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> newList = snapshot.documents.map((DocumentSnapshot documentSnapshot) {
      var breed = Breed.fromSnapshot(documentSnapshot);
      return new DataRow(
          cells: [
            DataCell(Text(breed.breedName)),
            DataCell(Center(
              child: IconButton(
                icon: Icon(Icons.edit,),
                color: Colors.green,
                onPressed: () {
                  _categoryAlert(breed.reference.documentID);
                  categoryController.text = breed.breedName;
                  categoryController.selection = TextSelection.fromPosition(
                    TextPosition(offset: categoryController.text.length),
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
        appBar: AppBar(title: Text("Breed")),
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
                      'Add Breed',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () {
                      categoryController.text = "";
                      _categoryAlert(null);
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 10,),
                StreamBuilder(
                  stream: Firestore.instance.collection("breeds").orderBy("breedName", descending: this.breedOrder).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    return Container(
                      constraints: BoxConstraints(maxWidth: 550),
                      child: DataTable(
                        sortColumnIndex: 0,
                        sortAscending: this.breedOrder,
                        rows: _createRows(snapshot.data),
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Breed Name',
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
                                'Edit',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              tooltip: "Edit",
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