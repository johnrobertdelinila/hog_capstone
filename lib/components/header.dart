import 'package:flutter_customer/components/loader.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_customer/services/shoppingBagService.dart';
import 'package:flutter_customer/services/productService.dart';
import 'package:flutter_customer/components/item/customTransition.dart';
import 'package:flutter_customer/pages/products/particularItem.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

capitalizeHeading(String text){
  if(text == null){
    return text = "";
  }
  else{
    text = "${text[0].toUpperCase()}${text.substring(1)}";
    return text;
  }
}

Widget header(String headerText,GlobalKey<ScaffoldState> scaffoldKey,bool  showIcon, BuildContext context){
  final GlobalKey<State> keyLoader = new GlobalKey<State>();

  ShoppingBagService _shoppingBagService = new ShoppingBagService();
  ProductService _productService = new ProductService();

  void showParticularItem(String pigId) async{
    Map itemDetails = await _productService.particularItem(pigId);
    Navigator.push(
        context,
        CustomTransition(
            type: CustomTransitionType.downToUp,
            child: ParticularItem(
              itemDetails: itemDetails,
              edit: false,
            )
        )
    );
  }

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {Navigator.pop(context);},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("QR Scan"),
      content: Text("This feature is only available in Android or iOS."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  return AppBar(
    centerTitle: true,
    title: Text(
      capitalizeHeading(headerText),
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
        fontFamily: 'NovaSquare'
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 1.0,
    automaticallyImplyLeading: false,
    leading: IconButton(
      icon: Icon(
        Icons.menu,
        size: 35.0,
        color: Colors.black
      ),
      onPressed: (){
        if(scaffoldKey.currentState.isDrawerOpen == false){
          scaffoldKey.currentState.openDrawer();
        } else{
          scaffoldKey.currentState.openEndDrawer();
        }
      },
    ),
    actions: <Widget>[
      Visibility(
        visible: showIcon,
        child: IconButton(
          icon: Icon(
            Icons.qr_code_scanner_rounded,
            size: 35.0,
            color: Colors.black,
          ),
          onPressed: () async{
            /*Map<String,dynamic> args = new Map();
            Loader.showLoadingScreen(context, keyLoader);
            List bagItems = await _shoppingBagService.list();
            args['bagItems'] = bagItems;
            Navigator.of(keyLoader.currentContext, rootNavigator: true).pop();
            Navigator.pushNamed(context, '/bag', arguments: args);*/

            if(kIsWeb) {
              showAlertDialog(context);
            }else {
              String pigId = await BarcodeScanner.scan();
              showParticularItem(pigId);
            }

          },
        ),
      )
    ],
  );
}