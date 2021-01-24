import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_customer/components/checkout/checkoutAppBar.dart';

class ShippingMethod extends StatefulWidget {
  @override
  _ShippingMethodState createState() => _ShippingMethodState();
}

class _ShippingMethodState extends State<ShippingMethod> {

  String selectedShippingMethod = '2-3 Days';
  String selectedPaymentCard = "dummy";

  checkoutShippingMethod(){
    Map<String,dynamic> args = ModalRoute.of(context).settings.arguments;
    args['shippingMethod'] = selectedShippingMethod;
    args['selectedCard'] = selectedPaymentCard;
    // Navigator.of(context).pushNamed('/checkout/paymentMethod', arguments: args);
    Navigator.pushNamed(context, '/checkout/placeOrder',arguments: args);
  }

  Widget _getShippingFee() {
    return FutureBuilder<DocumentSnapshot>(
      future: Firestore.instance.collection("shippingFee").document("123").get(),
      builder: (context, snapshot) {
        if(snapshot != null && snapshot.hasData) {
          return Text(
            "\₱" + snapshot.data['fee'].toString(),
            style: TextStyle(
                fontSize: 16.0
            ),
          );
        }else {
          return Text(
            '\₱50.00',
            style: TextStyle(
                fontSize: 16.0
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CheckoutAppBar('Back', 'Done', checkoutShippingMethod),
      body: Container(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Shipping',
                  style: TextStyle(
                    fontFamily: 'NovaSquare',
                    fontSize: 40.0,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
                  child: Center(
                    child: Image.asset(
                      'assets/pigShipping.png',
                      width: 250.0,
                      height: 250.0,
                    ),
                  ),
                ),
                Text(
                  'Shipping Method',
                  style: TextStyle(
                    fontSize: 20.0,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold
                  )
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  leading: Icon(Icons.local_shipping),
                  title: Text(
                    '3-5 Days',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 3.0),
                      Text(
                        'Arrives in 3-5 days',
                        style: TextStyle(
                          fontSize: 16.0
                        ),
                      ),
                      Text(
                        'free',
                        style: TextStyle(
                          fontSize: 16.0
                        ),
                      )
                    ],
                  ),
                  trailing: Radio(
                    value: '2-3 Days',
                    groupValue: selectedShippingMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedShippingMethod = '2-3 Days';
                      });
                    },
                  )
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  leading: Icon(Icons.local_shipping),
                  title: Text(
                    '1 Day',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Arriving tomorrow',
                        style: TextStyle(
                            fontSize: 16.0
                        ),
                      ),
                      _getShippingFee(),
                    ],
                  ),
                    trailing: Radio(
                      value: '1 Day',
                      groupValue: selectedShippingMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedShippingMethod = '1 Day';
                        });
                      },
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
