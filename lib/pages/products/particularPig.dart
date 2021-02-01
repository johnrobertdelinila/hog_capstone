import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_customer/components/loader.dart';
import 'package:flutter_customer/services/shoppingBagService.dart';
import 'package:flutter_customer/components/item/productImage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import 'package:timeago/timeago.dart' as timeago;

class ParticularItem extends StatefulWidget {
  final Map <String,dynamic> itemDetails;
  final bool edit;

  ParticularItem({var key, this.itemDetails, this.edit}):super(key: key);

  @override
  _ParticularItemState createState() => _ParticularItemState();
}

class _ParticularItemState extends State<ParticularItem> {
  final GlobalKey<State> keyLoader = new GlobalKey<State>();
  var itemDetails;
  List<dynamic> size;
  List<dynamic> colors;
  String sizeValue = "";
  String colorValue = "";
  int quantity = 1;
  bool editProduct;
  String image,name;
  var f = new NumberFormat("#,###.00", "en_US");

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showInSnackBar(String msg, Color color) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: new Text(msg),
          action: SnackBarAction(
            label:'Close',
            textColor: Colors.white,
            onPressed: (){
              _scaffoldKey.currentState.removeCurrentSnackBar();
            },
          ),
        ),
    );
  }

  editItemDetails(){
    Map<String,dynamic> args = widget.itemDetails;
    print(args);
    setState(() {
      editProduct = true;
      sizeValue = args['itemDetails']['selectedSize'];
      colorValue = args['itemDetails']['selectedColor'];
      itemDetails = args['itemDetails'];
      size = args['itemDetails']['size'];
      colors = setColorList(args['itemDetails']['color']);
      quantity = args['itemDetails']['quantity'];
      int index = args['itemDetails']['color'].indexOf("0xFF$colorValue");
      selectColor(index);
    });

  }

  setItemDetails(){
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black)
    );
    Map<String,dynamic> args = widget.itemDetails;
    setState(() {
      if(!widget.edit){
        editProduct = false;
        itemDetails = args;
        size = args['size'];
        colors = setColorList(args['color']);
      }
      else{
        editItemDetails();
      }
    });
  }

  setSizeOptions(String size){
    setState(() {
      sizeValue = size;
    });
  }

  addToShoppingBag() async{
    if(/*sizeValue == '' && size.length != 0) showInSnackBar('Select size',Colors.red*/false);
    else if(/*colorValue == '' && colors.length != 0) showInSnackBar('Select color', Colors.red*/false);
    else{
      Loader.showLoadingScreen(context, keyLoader);
      ShoppingBagService _shoppingBagService = new ShoppingBagService();
      String msg = await _shoppingBagService.add(itemDetails['productId'],/*sizeValue*/null,/*colorValue*/null,quantity);
      Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
      showInSnackBar(msg,Colors.black);
    }
  }

  checkoutProduct(){
    if(/*sizeValue == '' && size.length != 0) showInSnackBar('Select size',Colors.red*/false);
    else if(/*colorValue == '' && colors.length != 0) showInSnackBar('Select color', Colors.red*/false);
    else{
      Map<String,dynamic> args = new Map<String, dynamic>();
      args['price'] = itemDetails['price'];
      args['productId'] = itemDetails['productId'];
      args['quantity'] = quantity;
      args['size'] = /*sizeValue*/null;
      args['color'] = /*colorValue*/null;
      args['weight'] = itemDetails['weight'];
      args['age'] = itemDetails['age'];
      args['gender'] = itemDetails['gender'];
      args['vaccinatedDate'] = itemDetails['vaccinatedDate'];
      args['timestamp'] = itemDetails['timestamp'];
      Navigator.of(context).pushNamed('/checkout/address', arguments: args);
    }
  }

  setQuantity(String type){
    setState(() {
      if(type == 'inc'){
        if(quantity != 5){
          quantity = quantity + 1;
        }
      }
      else{
        if(quantity != 1){
          quantity = quantity - 1;
        }
      }
    });
  }

  setColorList(List colors){
    List <Map<Color,bool>> colorList = new List();
    colors.forEach((value){
      Map<Color,bool> colorMap = new Map();
      colorMap[/*Color(int.parse(value))*/Colors.red] = false;
      colorList.add(colorMap);
    });
    return colorList;
  }

  selectColor(index){
    Color particularKey = colors[index].keys.toList()[0];
    var boolValues = colors.map((color) => color.values.toList()[0]);
    setState(() {
      if(boolValues.contains(true)){
        colors.forEach((color){
          Color key = color.keys.toList()[0];
          if(color[key] == true) color[key] = false;
          else{
            Color particularKey = colors[index].keys.toList()[0];
            if(particularKey == key){
              color[key] = true;
            }
          }
        });
      }
      else{
        colors[index][particularKey] = true;
      }
      colorValue = particularKey.value.toRadixString(16).substring(2);
    });
  }

  @override
  void initState() {
    super.initState();
    setItemDetails();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Container(
          color: Color(0xfffafafa),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 9,
              ),
              child: Column(
                crossAxisAlignment: kIsWeb ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 800),
                    child: Container(
                      // flex: kIsWeb ? 8 : 5,
                      child: CustomProductImage(
                        itemDetails['image'],
                        buildContext,
                        size,
                        sizeValue,
                        editProduct,
                        itemDetails['productId'],
                        setSizeOptions,
                        showInSnackBar
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: kIsWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            toBeginningOfSentenceCase(itemDetails['name']),
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 7.0),
                          Text(
                            "Price: \₱ ${f.format(itemDetails['price'])}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "${itemDetails['weight']} kg",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 7.0),
                          Text(
                            "\₱ ${f.format(itemDetails['price'] / itemDetails['weight'])} per Kilo",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "${itemDetails['age']} years old",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "${itemDetails['gender']}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Last Vaccinated: ${itemDetails['vaccinatedDate']}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "${itemDetails['vaccineType']}: ${itemDetails['vaccineName']}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Pig Color: ${itemDetails['pigColor']}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Date Birth: ${itemDetails['dateBirth']}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Origin: ${itemDetails['placeOrigin']}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Range price per kilo: ${itemDetails['range']}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Visibility(
                            visible: false,
                            child: Center(
                              child: Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontFamily: 'NovaSquare'
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                MaterialButton(
                                  onPressed: (){
                                    setQuantity('inc');
                                  },
                                  color: Colors.white,
                                  child: Icon(
                                    Icons.add,
                                    size: 30.0,
                                  ),
                                  padding: EdgeInsets.all(12.0),
                                  shape: CircleBorder(),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: (){
                                    setQuantity('dec');
                                  },
                                  textColor: Colors.white,
                                  color: Colors.black,
                                  child: Icon(
                                      Icons.remove,
                                      size: 30.0
                                  ),
                                  padding: EdgeInsets.all(12.0),
                                  shape: CircleBorder(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Divider(
                              color: Colors.black
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ButtonTheme(
                                minWidth: (MediaQuery.of(context).size.width - 30.0 - 10.0) /3,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  color: Colors.black,
                                  child: Text(
                                    'RESERVE',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white
                                    ),
                                  ),
                                  onPressed: (){
                                    addToShoppingBag();
                                  },
                                ),
                              ),
                              SizedBox(width: 10.0),
                              ButtonTheme(
                                minWidth: (MediaQuery.of(context).size.width - 30.0 - 10.0) /3,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  color: Colors.white,
                                  child: Text(
                                    'Pay',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.black
                                    ),
                                  ),
                                  onPressed: (){
                                    checkoutProduct();
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            "Date updated: ${timeago.format(itemDetails['timestamp'].toDate(),locale: 'fr')}",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0
                            ),
                          ),
                        ],
                      ),
                    )
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
   }
}