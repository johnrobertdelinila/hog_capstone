import 'package:flutter/material.dart';

import 'package:flutter_customer/components/header.dart';
import 'package:flutter_customer/components/sidebar.dart';
import 'package:flutter_customer/services/productService.dart';
import 'package:flutter_customer/components/loader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SubCategory extends StatefulWidget {
  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  ProductService _productService = new ProductService();
  String heading;
  bool showIcon = false;
  List<String> subCategoryList = new List();
  List <String> imageList = new List();

  setSubCategory(context){
    Map<dynamic,dynamic> args = ModalRoute.of(context).settings.arguments;
    this.setState(() {
      heading = args['category'];
      subCategoryList = args['subCategory'].keys.toList();
      imageList = args['subCategory'].values.toList();
    });
  }

  listSubCategoryItems(String subCategory, BuildContext context) async{
    subCategory = subCategory.toLowerCase();
    Loader.showLoadingScreen(context, _keyLoader);
    List <Map<String,String>> items = await _productService.listSubCategoryItems(subCategory);
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    Navigator.pushNamed(context, '/pigs', arguments: {'items': items, 'heading': subCategory});
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    setSubCategory(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(heading, _scaffoldKey, showIcon, context),
      drawer: sidebar(context),
      body: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1400),
          child: GridView.builder(
            itemCount: subCategoryList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 8.0 / 10.0,
              crossAxisCount: kIsWeb ? 5 : 2,
            ),
            itemBuilder: (BuildContext context, int index){
              String name = subCategoryList[index];
              name = ((name[0].toUpperCase()+name.substring(1)).length < 8 ? name[0].toUpperCase()+name.substring(1) : name[0].toUpperCase()+name.substring(1).substring(0, 7) + "..");
              String imagePath = imageList[index];
              return Padding(
                padding: EdgeInsets.all(5.0),
                child: Card(
                  semanticContainer: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          child: InkWell(
                            onTap: (){
                              listSubCategoryItems(name,context);
                            },
                            child: GridTile(
                              footer: Container(
                                color: Colors.white70,
                                child: ListTile(
                                  leading: Text(
                                    name,
                                    style: TextStyle(
                                      fontFamily: 'NovaSquare',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0
                                    ),
                                  ),
                                ),
                              ),
                              child: Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
