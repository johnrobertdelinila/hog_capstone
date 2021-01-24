import 'package:flutter_customer/services/checkoutService.dart';
import 'package:flutter/material.dart';

import 'package:flutter_customer/components/loader.dart';
import 'package:flutter_customer/services/shoppingBagService.dart';
import 'package:flutter_customer/services/userService.dart';
import 'package:flutter_customer/services/profileService.dart';
import 'package:flutter_customer/services/productService.dart';

Widget sidebar(BuildContext context){
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  UserService _userService = new UserService();
  ShoppingBagService _shoppingBagService = new ShoppingBagService();
  ProfileService _profileService = new ProfileService();
  ProductService _productService = new ProductService();
  CheckoutService _checkoutService = new CheckoutService();

  return SafeArea(
    child: Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.home),
                title:Text(
                  'HOME',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
                onTap: () {
                  Navigator.popAndPushNamed(context, '/home');
                },
              ),
              /*ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text(
                  'SHOP',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
                onTap: () async{
                  Map<String,dynamic> args = new Map();
                  Loader.showLoadingScreen(context, _keyLoader);
                  List<Map<String,String>> categoryList = await _productService.listCategories();
                  args['category'] = categoryList;
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  Navigator.pushReplacementNamed(context, '/shop',arguments: args);
                },
              ),*/
              ListTile(
                leading: Icon(Icons.star),
                title: Text(
                  'RESERVE PIGS',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
                onTap: () async{
                  Map<String,dynamic> args = new Map();
                  Loader.showLoadingScreen(context, _keyLoader);
                  List bagItems = await _shoppingBagService.list();
                  args['bagItems'] = bagItems;
                  args['route'] = '/home';
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  Navigator.pushReplacementNamed(context, '/bag', arguments: args);
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text(
                  'SEARCH',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.local_shipping),
                title: Text(
                  'ORDERS',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
                onTap: () async {
                 Loader.showLoadingScreen(context, _keyLoader);
                  List orderData = await _checkoutService.listPlacedOrder();
                 Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  Navigator.popAndPushNamed(context, '/placedOrder',arguments: {'data': orderData});
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.favorite_border),
              //   title: Text(
              //     'WISHLIST',
              //     style: TextStyle(
              //         fontSize: 20.0,
              //         fontWeight: FontWeight.bold,
              //         letterSpacing: 1.0
              //     ),
              //   ),
              //   onTap: () async{
              //     Loader.showLoadingScreen(context, _keyLoader);
              //     List userList = await _userService.userWishlist();
              //     Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
              //     Navigator.popAndPushNamed(context, '/wishlist',arguments: {'userList':userList});
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'PROFILE',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
                onTap: () async{
                  Loader.showLoadingScreen(context, _keyLoader);
                  Map userProfile = await _profileService.getUserProfile();
                  Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  Navigator.popAndPushNamed(context, '/profile',arguments: userProfile);
                },
              ),
              ListTile(
                leading: new Icon(Icons.exit_to_app),
                title: Text(
                  'LOGOUT',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
                onTap: (){
                  _userService.logOut(context);
                },
              )
            ],
          )
        ],
      ),
    ),
  );
}