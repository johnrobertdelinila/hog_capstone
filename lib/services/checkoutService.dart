import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_customer/services/shoppingBagService.dart';
import 'package:flutter_customer/services/userService.dart';

class CheckoutService {
  Firestore _firestore = Firestore.instance;
  UserService _userService = new UserService();
  ShoppingBagService _shoppingBagService = new ShoppingBagService();
  CollectionReference _shippingAddressReference = Firestore.instance.collection('shippingAddress');
  CollectionReference _creditCardReference = Firestore.instance.collection('creditCard');
  CollectionReference _shoppingBagReference = Firestore.instance.collection('bags');
  CollectionReference _orderReference = Firestore.instance.collection('orders');
  CollectionReference _productReference = Firestore.instance.collection('pigs');

  Map mapAddressValues(Map values){
    Map addressValues = new Map();
    addressValues['area'] = values['area'];
    addressValues['city'] = values['city'];
    addressValues['landmark'] = values['landMark'];
    addressValues['state'] = values['state'];
    addressValues['address'] = values['address'];
    addressValues['name'] = values['fullName'];
    addressValues['mobileNumber'] = values['mobileNumber'];
    addressValues['pinCode'] = values['pinCode'];
    return addressValues;
  }

  Future<void>updateAddressData(QuerySnapshot addressData, Map newAddress) async{
    String documentId = addressData.documents[0].documentID;
    List savedAddress = addressData.documents[0].data['address'];
    savedAddress.add(newAddress);
    await _shippingAddressReference.document(documentId).updateData({'address': savedAddress});
  }

  Future<void> newShippingAddress(Map address) async{
    String uid = await  _userService.getUserId();
    QuerySnapshot data = await _shippingAddressReference.where("userId", isEqualTo: uid).getDocuments();
    if(data.documents.length == 0){
      await _firestore.collection('shippingAddress').add({
        'userId': uid,
        'address': [mapAddressValues(address)]
      });
    }
    else{
      await updateAddressData(data,address);
    }
  }

  Future<List> listShippingAddress() async{
    String uid = await _userService.getUserId();
    List addressList = new List();
    String id;

    QuerySnapshot docRef = await _shippingAddressReference.where('userId',isEqualTo: uid).getDocuments();
    if(docRef.documents.length != 0){
      addressList = docRef.documents[0].data['address'];
      id = docRef.documents[0].documentID;
    }

    return [addressList, id];

  }

  Future<void> newCreditCardDetails(String cardNumber, String expiryDate, String cardHolderName) async{
    String uid = await _userService.getUserId();
    QuerySnapshot creditCardData = await _creditCardReference.where("cardNumber", isEqualTo: cardNumber).getDocuments();

    if(creditCardData.documents.length == 0){
      await _creditCardReference.add({
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
        'userId': uid
      });
    }
  }

  Future<List> listCreditCardDetails() async{
    String uid = await _userService.getUserId();
    List<String> cardNumberList = new List<String>();
    QuerySnapshot cardData = await _creditCardReference.where('userId',isEqualTo: uid).getDocuments();
    String cardNumber;
    cardData.documents.forEach((docRef){
      cardNumber = docRef.data['cardNumber'].toString().replaceAll(new RegExp(r"\s+\b|\b\s"),'');
      cardNumberList.add(cardNumber.substring(cardNumber.length - 4));
    });
    return cardNumberList;
  }

  Future<void> placeNewOrder(Map orderDetails) async{
    String uid = await _userService.getUserId();
    print(orderDetails);

    var pigs;

    if(orderDetails['productId'] != null) {
      var pig = {
        "color": orderDetails['color'],
        "size": orderDetails['size'],
        "quantity": orderDetails['quantity'],
        "id": orderDetails['productId']
      };
      pigs = [pig];
    }else {
      QuerySnapshot items = await _shoppingBagReference.where('userId',isEqualTo: uid).getDocuments();
      pigs = items.documents[0].data['products'];
    }

    await _orderReference.add({
      'userId': uid,
      'items': pigs,
      'shippingAddress': orderDetails['shippingAddress'],
      'shippingMethod': orderDetails['shippingMethod'],
      'price': int.parse("${orderDetails['price']}"),
      'paymentCard': orderDetails['selectedCard'],
      'placedDate': DateTime.now()
    });
    
    if(orderDetails['productId'] == null) {
      await _shoppingBagService.delete();
    }
  }
  
  Future<List> listPlacedOrder() async {
    List orderList = new List();
    String uid = await _userService.getUserId();
    QuerySnapshot orders = await _orderReference.orderBy('placedDate',descending: true).where('userId', isEqualTo: uid).getDocuments();
    if(orders != null && orders.documents.isNotEmpty) {
      for(DocumentSnapshot order in orders.documents) {
        Map orderMap = new Map();
        orderMap['orderDate'] = order.data['placedDate'];
        orderMap['id'] = order.documentID;
        orderMap['isCancelled'] = order.data['isCancelled'] == null ? false : order.data['isCancelled'];
        List orderData = new List();
        for (int i = 0; i < order.data['items'].length; i++) {
          Map tempOrderData = new Map();
          tempOrderData['quantity'] = order.data['items'][i]['quantity'];
          DocumentSnapshot docRef = await _productReference.document(order.data['items'][i]['id']).get();
          if(docRef != null && docRef.exists) {
            tempOrderData['productImage'] = docRef.data['image'];
            tempOrderData['productName'] = docRef.data['name'];
            tempOrderData['price'] = docRef.data['price'];
            orderData.add(tempOrderData);
          }
        }
        orderMap['orderDetails'] = orderData;
        orderList.add(orderMap);
      }
    }

    return orderList;
  }

}