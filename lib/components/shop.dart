import 'package:flutter/material.dart';

import 'package:flutter_customer/components/header.dart';
import 'package:flutter_customer/components/sidebar.dart';
import 'package:flutter_customer/services/productService.dart';

class Shop extends StatefulWidget {
  @override
  _ShopState createState() => _ShopState();
}


class _ShopState extends State<Shop> {
  ProductService _productService = new ProductService();
  List<Map<String,String>> categoryList = new List();

  void listCategories(){
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    setState(() {
      categoryList = args['category'];
    });
  }

  void listSubCategories(category) async {
    Map subCategory = await _productService.listSubCategories(category);
    Map args = {'subCategory': subCategory, 'category': category};
    Navigator.pushNamed(context, '/subCategory', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    bool showCartIcon = true;

    listCategories();
    return WillPopScope(
      onWillPop: () async{
        Navigator.pushReplacementNamed(context,'/home');
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: header('Shop', _scaffoldKey, showCartIcon, context),
        drawer: sidebar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: categoryList.length,
              separatorBuilder: (BuildContext context, int index){
                return SizedBox(height: 20.0);
              },
              itemBuilder: (context,index){
                var item = categoryList[index];
                return GestureDetector(
                  onTap: (){
                    listSubCategories(item['categoryName']);
                  },
                  child: Container(
                    constraints: new BoxConstraints.expand(
                        height: 130.0
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        image: DecorationImage(
                          image: AssetImage(item['categoryImage']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Color.fromRGBO(90,90,90, 0.8), BlendMode.modulate)
                        )
                    ),
                    child: Center(
                      child: Text(
                        item['categoryName'].toString().toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'NovaSquare',
                          fontWeight: FontWeight.w600,
                          fontSize: 35.0,
                          color: Colors.white,
                          letterSpacing: 1.0
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ),
    );
  }
}
