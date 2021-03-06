import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:flutter_customer/components/shoppingBag/shoppingBagExpandedList.dart';
import 'package:flutter_customer/components/header.dart';
import 'package:flutter_customer/services/shoppingBagService.dart';
import 'package:flutter_customer/components/item/customTransition.dart';
import 'package:flutter_customer/components/sidebar.dart';
import 'package:flutter_customer/pages/products/particularPig.dart';
import 'package:flutter_customer/components/loader.dart';
import 'package:flutter_customer/services/productService.dart';

class ShoppingBag extends StatefulWidget {
  @override
  _ShoppingBagState createState() => _ShoppingBagState();
}

class _ShoppingBagState extends State<ShoppingBag> {
  List <dynamic>bagItemList = new List<dynamic>();
  String selectedSize, selectedColor, totalPrice;
  ShoppingBagService _shoppingBagService = new ShoppingBagService();
  ProductService _productService = new ProductService();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String route;

  void listBagItems(context) async {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    setState(() {
      bagItemList = args['bagItems'];
      totalPrice = setTotalPrice(args['bagItems']).toString();
      if(args.containsKey('route')){
        route = args['route'];
      }
    });
  }

  int setTotalPrice(List items){
    int totalPrice = 0;
    items.forEach((item){
      totalPrice = totalPrice + (int.parse(item['price']) * item['quantity']);
    });
    return totalPrice;
  }

  String colorList(String colorName){
    Map colorMap = new Map();
    colorMap['000000'] = 'Black';
    colorMap['0000ff'] = 'Blue';
    colorMap[''] = 'None';
    return colorMap[colorName];
  }

  void removeItem(item,context) async{
    bagItemList.removeWhere((items) => items['id'] == item['id']);
    await _shoppingBagService.remove(item['id']);
    setState(() {
      bagItemList = bagItemList;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  void removeItemAlertBox(BuildContext context, Map id) {
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0)
          ),
          title: Text(
            'Remove from cart',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0
            ),
          ),
          content: Text(
              'This Hog will be removed from cart',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0
            ),
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                ButtonTheme(
                  minWidth: (MediaQuery.of(context).size.width - 120) /2,
                  child: FlatButton(
                    onPressed: (){
                      removeItem(id,context);
                    },
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.redAccent
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                ButtonTheme(
                  minWidth: (MediaQuery.of(context).size.width - 120) /2,
                  child: FlatButton(
                    onPressed: (){
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0)
              ],
            )
          ],
        );
      }
    );
  }

  openParticularItem(Map item) async{
    Map<String,dynamic> args = new Map();
    args['itemDetails'] = item;
    Navigator.pushReplacement(
        context,
        CustomTransition(
            type: CustomTransitionType.downToUp,
            child: ParticularItem(
              itemDetails: args,
              edit: true,
            )
        )
    );
  }

  nonExistingBagItems(){
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No pigs existed. Choose for new pigs',
              style: TextStyle(
                fontSize: 20.0
              ),
            ),
            SizedBox(height: 10.0),
            ButtonTheme(
              height: 45.0,
              minWidth: 100.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0))
              ),
              child: RaisedButton(
                color: Color(0xff313134),
                onPressed: () async{
                  /*Map<String,dynamic> args = new Map();
                  Loader.showLoadingScreen(context, _keyLoader);
                  List<Map<String,String>> categoryList = await _productService.listCategories();
                  args['category'] = categoryList;
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  Navigator.pushReplacementNamed(context, '/shop',arguments: args);*/
                  Navigator.popAndPushNamed(context, '/home');
                },
                child: Text(
                  'Pick',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  expandedListBuilder(){
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 700),
      child: ListView.builder(
        itemCount: bagItemList.length,
        itemBuilder: (BuildContext context, int index) {
          var item = bagItemList[index];
          return ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ScrollOnExpand(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: <Widget>[
                        ExpandablePanel(
                            theme: const ExpandableThemeData(
                              headerAlignment: ExpandablePanelHeaderAlignment.center,
                              tapBodyToExpand: true,
                              tapBodyToCollapse: true,
                              hasIcon: false,
                            ),
                            header: Container(
                              color: Colors.indigoAccent,
                              child: Row(
                                children: [
                                  Image(
                                    image: NetworkImage(
                                      item['image'],
                                    ),
                                    height: 100.0,
                                    width: 120.0,
                                    fit: BoxFit.fill,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            item['name'],
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.white,
                                                letterSpacing: 1.0),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            "\₱${item['price']}",
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: ExpandableIcon(
                                      theme: const ExpandableThemeData(
                                        expandIcon: Icons.keyboard_arrow_right,
                                        collapseIcon: Icons.keyboard_arrow_down,
                                        iconColor: Colors.white,
                                        iconSize: 28.0,
                                        iconRotationAngle: math.pi / 2,
                                        iconPadding: EdgeInsets.only(right: 5),
                                        hasIcon: false,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            expanded: null /*ShoppingBagExpandedList(item, colorList, openParticularItem, removeItemAlertBox)*/
                        ),
                      ],
                    ),
                  ),
                ),
              )
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    bool showCartIcon = false;
    listBagItems(context);
    return WillPopScope (
      onWillPop: () async{
        if(this.route != null){
          Navigator.pushReplacementNamed(context, route);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        key: _scaffoldKey,
        appBar: header('Reserve Pigs', _scaffoldKey, showCartIcon, context),
        drawer: sidebar(context),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 0.0),
            child: Container(
              height: 100.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                              '\₱ $totalPrice.00',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                    ButtonTheme(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0))
                      ),
                      minWidth: MediaQuery.of(context).size.width,
                      height: 50.0,
                      child: RaisedButton(
                        color: Color(0xff313134),
                        onPressed: (){
                          if(bagItemList.length != 0){
                            Map<String,dynamic> args = new Map<String, dynamic>();
                            args['price'] = int.parse(totalPrice);
                            Navigator.of(context).pushNamed('/checkout/address',arguments: args);
                          }
                        },
                        child: Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )
                  ],
              ),
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: bagItemList.length == 0 ? nonExistingBagItems() : expandedListBuilder()
        ),
      ),
    );
  }
}
