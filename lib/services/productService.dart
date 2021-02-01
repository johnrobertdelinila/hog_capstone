import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_customer/services/userService.dart';

class ProductService{
  Firestore _firestore = Firestore.instance;
  CollectionReference _productReference = Firestore.instance.collection('pigs');
  CollectionReference _categoryReference = Firestore.instance.collection('breeds');
  UserService _userService = new UserService();
  List subCategoryList = List();

  Future<Map> listSubCategories(String category) async {
    QuerySnapshot categoryRef = await _categoryReference.where('breedName',isEqualTo: category).getDocuments();
    Map<String,String> subCategory = new Map();
    for(Map ref in categoryRef.documents[0].data['subBreed']){
      subCategory[ref['subBreedName']] = ref['image'];
    }
    print(subCategory);
    return subCategory;
  }

  Future<List> newItemArrivals() async{
    Random rdn = new Random();
    List<Map<String,String>> itemList = new List();
    int randomNumber = 1 + rdn.nextInt(20);
    QuerySnapshot itemsRef = await _productReference.orderBy('name').startAt([randomNumber]).limit(5).getDocuments();
    for(DocumentSnapshot docRef in itemsRef.documents){
      Map<String,String> items = new Map();
      items['image'] = docRef.data['image'];
      items['name'] = docRef.data['name'];
      items['productId'] = docRef.documentID;
      itemList.add(items);
    }
    return itemList;
  }
  
  Future <List> featuredItems() async{
    List<Map<String,String>> itemList = new List();
    QuerySnapshot itemsRef = await _productReference.limit(15).getDocuments();
    for(DocumentSnapshot docRef in itemsRef.documents){
      Map<String,String> items = new Map();
      items['image'] = docRef.data['image'];
      items['name'] = docRef.data['name'];
      items['price'] = docRef.data['price'].toString();
      items['productId'] = docRef.documentID;
      itemList.add(items);
    }
    return itemList;
  }
  
  Future <List> listSubCategoryItems(String subCategory) async{

    List<Map<String,String>> itemsList = new List();
    QuerySnapshot productRef = await _productReference.where("subBreed", isEqualTo: subCategory.toUpperCase()).getDocuments();
    for(DocumentSnapshot docRef in productRef.documents){
      Map<String,String> items  = new Map();
      items['image'] = docRef.data['image'];
      items['name'] = docRef.data['name'];
      items['price'] = docRef.data['price'].toString();
      items['productId'] = docRef.documentID;
      itemsList.add(items);
    }
    return itemsList;
  }
  
  Future <List> listCategories() async{
    QuerySnapshot _categoryRef = await _categoryReference.getDocuments();
    List <Map<String,String>> categoryList = new List();
    for(DocumentSnapshot dataRef in _categoryRef.documents){
      Map<String,String> category = new Map();
      category['categoryName'] = dataRef.data['categoryName'];
      category['categoryImage'] = dataRef.data['categoryImage'];
      categoryList.add(category);
    }
    return categoryList;
  }

  // ignore: missing_return
  Future <String> addItemToWishlist(String productId) async{
    String msg;
    String uid = await _userService.getUserId();
    List<dynamic> wishlist = new List<dynamic>();
    QuerySnapshot userRef = await _firestore.collection('users').where('userId',isEqualTo: uid).getDocuments();
    Map userData = userRef.documents[0].data;
    String documentId = userRef.documents[0].documentID;
    if(userData.containsKey('wishlist')){
      wishlist = userData['wishlist'];
      if(wishlist.indexOf(productId) == -1){
        wishlist.add(productId);
      }
      else{
        msg = 'Pig existed in Wishlist';
        return msg;
      }
    }
    else{
      wishlist.add(productId);
    }
    await _firestore.collection('users').document(documentId).updateData({
      'wishlist': wishlist
    }).then((value){
      msg = 'Pig added to wishlist';
      return msg;
    });
  }

  Future<Map> particularItem(String productId) async{
    DocumentSnapshot prodRef = await _productReference.document(productId).get();
    Map<String, dynamic> itemDetail = new Map();
    itemDetail['image'] = prodRef.data['image'];
    itemDetail['color'] = prodRef.data['color'];
    itemDetail['size'] = prodRef.data['size'];
    itemDetail['price'] = prodRef.data['price'];
    itemDetail['name'] = prodRef.data['name'];
    itemDetail['weight'] = prodRef.data['weight'];
    itemDetail['age'] = prodRef.data['age'];
    itemDetail['gender'] = prodRef.data['gender'];
    itemDetail['vaccinatedDate'] = prodRef.data['vaccinatedDate'];
    itemDetail['vaccineType'] = prodRef.data['vaccineType'];
    itemDetail['vaccineName'] = prodRef.data['vaccineName'];
    itemDetail['pigColor'] = prodRef.data["pigColor"];
    itemDetail['dateBirth'] = prodRef.data["dateBirth"];
    itemDetail['placeOrigin'] = prodRef.data["placeOrigin"];
    itemDetail['range'] = prodRef.data["range"];
    itemDetail['timestamp'] = prodRef.data["timestamp"];
    itemDetail['productId'] = productId;
    return itemDetail;
  }
}

class NewArrival{
  final String name;
  final String image;

  NewArrival({this.name, this.image});
}