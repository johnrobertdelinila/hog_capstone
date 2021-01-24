import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserService{
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  final storage = new FlutterSecureStorage();
  final String sharedKey = 'sharedKey';
  int statusCode;
  String msg;

  void createAndStoreJWTToken(String uid) async{
    var builder = new JWTBuilder();
    var token = builder
    ..expiresAt = new DateTime.now().add(new Duration(hours: 3))
    ..setClaim('data', {'uid': uid})
    ..getToken();

    var signer = new JWTHmacSha256Signer(sharedKey);
    var signedToken = builder.getSignedToken(signer);
    if(!kIsWeb) {
      await storage.write(key: 'token', value: signedToken.toString());
    }
  }

  String validateToken(String token){
    var signer = new JWTHmacSha256Signer(sharedKey);
    var decodedToken = new JWT.parse(token);
    if(decodedToken.verify(signer)){
      final parts = token.split('.');
      final payload = parts[1];
      final String decoded = B64urlEncRfc7515.decodeUtf8(payload);
      final int expiry = jsonDecode(decoded)['exp']* 1000;
      final currentDate = DateTime.now().millisecondsSinceEpoch;
      if(currentDate > expiry){
        return null;
      }
      return  jsonDecode(decoded)['data']['uid'];
    }
    return null;
  }

  void logOut(context) async{
    if(!kIsWeb) {
      await storage.delete(key: 'token');
    }
    _auth.signOut().then((value) => Navigator.of(context).pushReplacementNamed('/'));
  }

  Future<void> login(userValues) async{

    String email = userValues['email'];
    String password = userValues['password'];

    await _auth.signInWithEmailAndPassword(email: email, password: password).then((dynamic user) async{
      final FirebaseUser currentUser = await _auth.currentUser();
      final uid = currentUser.uid;

      createAndStoreJWTToken(uid);

      statusCode = 200;

    }).catchError((error){
      handleAuthErrors(error);
    });
  }

  Future<String> getUserId() async{
    var uid;
    if(!kIsWeb) {
      var token = await storage.read(key: 'token');
      uid = validateToken(token);
      return uid;
    }else {
      FirebaseUser user = await _auth.currentUser();
      uid = user.uid;
      return uid;
    }
  }

  Future<void> signup(userValues) async{
    String email = userValues['email'];
    String password = userValues['password'];

    await _auth.createUserWithEmailAndPassword(email: email, password: password).then((dynamic user){
      String uid = user.user.uid;
      _firestore.collection('users').add({
        'firstName': capitalizeName(userValues['firstName']),
        'lastName': capitalizeName(userValues['lastName']),
        'mobileNumber': userValues['mobileNumber'],
        'userId': uid
      });

      statusCode = 200;
    }).catchError((error){
      handleAuthErrors(error);
    });
  }

  void handleAuthErrors(error){
    String errorCode = error.code;
    print("Error code: " + error.toString());
    switch(errorCode){
      case "ERROR_EMAIL_ALREADY_IN_USE":
        {
          statusCode = 400;
          msg = "Email ID already existed";
        }
        break;
      case "ERROR_WRONG_PASSWORD":
        {
          statusCode = 400;
          msg = "Password is wrong";
        }
        break;
      case "ERROR_USER_NOT_FOUND":
        {
          statusCode = 400;
          msg = "Account does not exist";
        }
        break;
    }
  }

  String capitalizeName(String name){
    name = name[0].toUpperCase()+ name.substring(1);
    return name;
  }

  Future<String> userEmail() async {
    var user = await _auth.currentUser();
    return user.email;
  }

  Future<List> userWishlist() async{
    String uid = await getUserId();
    QuerySnapshot userRef = await _firestore.collection('users').where('userId',isEqualTo: uid).getDocuments();
    List <dynamic> wishlist = userRef.documents[0].data['wishlist'];
    List userList = new List();
    for(String item in wishlist){
      Map<String, dynamic> temp = new Map();
      DocumentSnapshot productRef = await _firestore.collection('pigs').document(item).get();
      temp['productName'] = productRef.data['name'];
      temp['price'] = productRef.data['price'];
      temp['image'] = productRef.data['image'];
      temp['productId'] = productRef.documentID;
      userList.add(temp);
    }
    return userList;
  }

  Future<void> deleteUserWishlistItems(String productId) async{
    String uid = await getUserId();
    QuerySnapshot userRef = await _firestore.collection('users').where('userId',isEqualTo: uid).getDocuments();
    String documentId = userRef.documents[0].documentID;
    Map<String,dynamic> wishlist = userRef.documents[0].data;
    wishlist['wishlist'].remove(productId);

    await _firestore.collection('users').document(documentId).updateData({
      'wishlist':wishlist['wishlist']
    });
  }
}

