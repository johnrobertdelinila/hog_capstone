import 'package:flutter/material.dart';
import 'package:flutter_customer/admin_pages/admin.dart';
import 'package:flutter_customer/admin_pages/admin_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:device_preview/device_preview.dart';

import 'package:flutter_customer/pages/signup.dart';
import 'package:flutter_customer/pages/login.dart';
import 'package:flutter_customer/pages/start.dart';
import 'package:flutter_customer/pages/home.dart';
import 'package:flutter_customer/components/shop.dart';
import 'package:flutter_customer/pages/products/items.dart';
import 'package:flutter_customer/pages/products/subCategory.dart';
import 'package:flutter_customer/pages/reservePigs.dart';
import 'package:flutter_customer/pages/checkout/addCreditCard.dart';
import 'package:flutter_customer/pages/checkout/paymentMethod.dart';
import 'package:flutter_customer/pages/checkout/shippingAddress.dart';
import 'package:flutter_customer/pages/checkout/shippingMethod.dart';
import 'package:flutter_customer/pages/products/particularPig.dart';
import 'package:flutter_customer/pages/checkout/placeOrder.dart';
import 'package:flutter_customer/pages/profile/userProfile.dart';
import 'package:flutter_customer/pages/profile/editProfile.dart';
import 'package:flutter_customer/pages/profile/setting.dart';
import 'package:flutter_customer/pages/profile/contactUs.dart';
import 'package:flutter_customer/pages/products/wishlist.dart';
import 'package:flutter_customer/components/orders/orderHistory.dart';
import 'package:flutter_customer/pages/onBoardingScreen/onboardingScreen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'admin_pages/add_pig.dart';

bool firstTime;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  firstTime = (prefs.getBool('initScreen') ?? false);
  if(!firstTime){
    prefs.setBool('initScreen', true);
  }
  // runApp(
  //   DevicePreview(
  //     enabled: kIsWeb ? false : true,
  //     builder: (context) => Main(),
  //   )
  // );
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: /*firstTime ? '/': '/onBoarding'*/'/onBoarding',
      routes: {
        '/': (context) => Start(),
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/home': (context) => Home(),
        '/shop': (context) => Shop(),
        '/subPigs': (context) => SubCategory(),
        '/pigs': (context) => Items(),
        '/particularPig': (context) => ParticularItem(),
        '/bag': (context) => ShoppingBag(),
        '/wishlist': (context) => WishList(),
        '/checkout/addCreditCard': (context) => AddCreditCard(),
        '/checkout/address': (context) => ShippingAddress(),
        '/checkout/shippingMethod': (context) => ShippingMethod(),
        '/checkout/paymentMethod': (context) => PaymentMethod(),
        '/checkout/placeOrder': (context) => PlaceOrder(),
        '/profile': (context) => UserProfile(),
        '/profile/settings': (context) => ProfileSetting(),
        '/profile/edit': (context) => EditProfile(),
        '/profile/contactUs': (context) => ContactUs(),
        '/placedOrder': (context) => OrderHistory(),
        "/onBoarding": (context) => OnBoardingScreen(),
        "/adminLogin": (context) => AdminLogin(),
        "/dashboard": (context) => AdminDashboard(),
        "/addPig": (context) => AddProduct(),
      },
      theme: ThemeData(
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white
        )
      ),
    );
  }
}
