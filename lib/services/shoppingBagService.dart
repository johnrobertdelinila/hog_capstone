import 'package:flutter_customer/services/userService.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingBagService{
  UserService userService = new UserService();
  Firestore _firestore = Firestore.instance;

  Future<String> update(String productId, String size, String color, int quantity, QuerySnapshot bagItems) async{
    String documentId;
    String msg;
    List productItems = bagItems.documents.map((doc){
      documentId = doc.documentID;
      return doc['products'];
    }).toList()[0];
    List product = productItems.where((test)=> test['id'] == productId).toList();
    if(product.length != 0){
      productItems.forEach((items){
        if(items['id'] == productId){
          items['size'] = size;
          items['color'] = color;
          items['quantity'] = quantity;
        }
      });
      msg =  "Pig updated for later";
    }
    else{
      productItems.add({'id':productId,'size':size,'color':color,'quantity':quantity});
      msg = 'Pig added for later';
    }
    await _firestore.collection('bags').document(documentId).setData({'products':productItems},merge: true);
    return msg;
  }

  Future<String> add(String productId,String size,String color,int quantity) async{
    String uid = await userService.getUserId();
    String msg;
    QuerySnapshot data = await _firestore.collection('bags').where("userId", isEqualTo: uid).getDocuments();
    if(data.documents.length == 0){
      await _firestore.collection('bags').add({
        'userId': uid,
        'products':[{
          'id': productId,
          'size': size,
          'color': color,
          'quantity': quantity
        }]
      });
      msg =  "Pig added to reserve";
    }
    else{
      msg = await update(productId, size, color, quantity, data);
    }
    return msg;
  }

  Future<List> list() async{
    List bagItemsList = new List();
    List itemDetails ;
    List productIdList =  new List(0);
    String uid = await userService.getUserId();

    QuerySnapshot docRef = await _firestore.collection('bags').where("userId",isEqualTo: uid).getDocuments();
    int itemLength = docRef.documents.length;
    if(itemLength != 0){
      itemDetails = docRef.documents.map((doc){
        return doc.data['products'];
      }).toList()[0];
      productIdList = itemDetails.map((value) => value['id']).toList();
    }

    for(int i=0;i< productIdList.length;i++){
      Map mapProduct = new Map();
      DocumentSnapshot productRef = await _firestore.collection('pigs').document(productIdList[i]).get();
      if(productRef.exists) {
        mapProduct['id'] = productRef.documentID;
        mapProduct['name'] = productRef.data['name'];
        mapProduct['image'] = productRef.data['image'];
        mapProduct['price']  = productRef.data['price'].toString();
        mapProduct['color'] = productRef.data['color'].cast<String>().toList();
        mapProduct['size'] = productRef.data['size'].cast<String>().toList();
        mapProduct['selectedSize'] = itemDetails[i]['size'];
        mapProduct['selectedColor'] = itemDetails[i]['color'];
        mapProduct['quantity'] = itemDetails[i]['quantity'];
        bagItemsList.add(mapProduct);
      }
    }
    return bagItemsList;
  }

  Future<void> remove(String id) async{
    String uid = await userService.getUserId();

    await _firestore.collection('bags').where('userId',isEqualTo: uid).getDocuments().then((QuerySnapshot doc){
      doc.documents.forEach((docRef) async{
        List products = docRef['products'];
        if(products.length == 1){
          await _firestore.collection('bags').document(docRef.documentID).delete();
        }
        else{
          products.removeWhere((productData) => productData['id'] == id);
          await _firestore.collection('bags').document(docRef.documentID).setData({'products':products},merge:true);
        }
      });
    });
  }

  Future<void> delete() async{
    String uid = await userService.getUserId();

    QuerySnapshot bagItems = await _firestore.collection('bags').where('userId',isEqualTo: uid).getDocuments();
    String shoppingBagItemId = bagItems.documents[0].documentID;

    final TransactionHandler deleteTransaction = (Transaction tx) async{
      final DocumentSnapshot ds = await tx.get(_firestore.collection('bags').document(shoppingBagItemId));
      await tx.delete(ds.reference);
    };

    await _firestore.runTransaction(deleteTransaction);
  }
}