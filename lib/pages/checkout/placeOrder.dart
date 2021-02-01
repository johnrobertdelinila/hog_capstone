import 'package:flutter/material.dart';

import 'package:flutter_customer/components/checkout/checkoutAppBar.dart';
import 'package:flutter_customer/services/checkoutService.dart';
import 'package:intl/intl.dart';

class PlaceOrder extends StatefulWidget {
  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  void thirdFunction(){}
  Map<String,dynamic> orderDetails;
  CheckoutService _checkoutService = new CheckoutService();
  var f = new NumberFormat("#,###.00", "en_US");

  setOrderData(){
    Map<String,dynamic> args = ModalRoute.of(context).settings.arguments;
    setState(() {
      orderDetails = args;
    });
  }

  placeNewOrder() async{
    await _checkoutService.placeNewOrder(orderDetails);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    setOrderData();
    return Scaffold(
      appBar: CheckoutAppBar('Pigs','Place Order',this.thirdFunction),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xffF4F4F4)
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Check out',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0
                  ),
                ),
                SizedBox(height: 30.0),
                Card(
                  color: Colors.white,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.zero
                  ),
                  borderOnForeground: true,
                  elevation: 0,
                  child: ListTile(
                    title: Text('Payment'),
                    trailing: Text(/*'Visa ${orderDetails['selectedCard']}'*/ "CASH"),

                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.zero
                  ),
                  borderOnForeground: true,
                  elevation: 0,
                  child: ListTile(
                    title: Text('Shipping'),
                    trailing: Text(orderDetails['shippingMethod']),
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.zero
                  ),
                  borderOnForeground: true,
                  elevation: 0,
                  child: ListTile(
                    title: Text('Total'),
                    trailing: Text('\₱ ${f.format(orderDetails['price'])}'),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width/1.5,
                      height: 50.0,
                      child: FlatButton(
                        onPressed: () {

                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0)
                                ),
                                title: Text('Are you sure ?'),
                                content: Text('Do you want to checkout this Hog?'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(
                                        'No',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black
                                        )
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () => placeNewOrder(),
                                    child: Text(
                                        'Yes',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red
                                        )
                                    ),
                                  )
                                ],
                              ),
                          );
                        },
                        child: const Text(
                            'Place order',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0
                            )
                        ),
                        color: Color(0xff616161),
                        textColor: Colors.white
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
