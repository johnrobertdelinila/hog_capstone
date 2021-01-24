import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_customer/components/loader.dart';
import 'package:flutter_customer/services/userService.dart';
import 'package:flutter_customer/services/validateService.dart';
import 'package:flutter_customer/components/alertBox.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  HashMap userValues = new HashMap<String, String>();
  bool _autoValidate = false;
  double borderWidth = 2.0;

  ValidateService _validateService = ValidateService();
  UserService _userService = UserService();

  login() async{

    if(kIsWeb && await FirebaseAuth.instance.currentUser() != null) {
      Navigator.pushNamed(context, '/home');
    }else {
      if(this._formKey.currentState.validate()){
        _formKey.currentState.save();
        Loader.showLoadingScreen(context, _keyLoader);
        await _userService.login(userValues);
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        int statusCode = _userService.statusCode;
        if(statusCode == 200){
          Navigator.pushNamed(context, '/home');
        }
        else{
          AlertBox alertBox = AlertBox(_userService.msg);
          return showDialog(
              context: context,
              builder: (BuildContext context){
                return alertBox.build(context);
              }
          );
        }
      }
      else{
        setState(() {
          _autoValidate = true;
        });
      }
    }


  }

  setBorder(double width, Color color){
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
        borderSide: BorderSide(
            width: width,
            color: color
        )
    );
  }

  InputDecoration customFormField(String hintText){
    return InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.all(20.0),
        border: InputBorder.none,
        errorBorder: this.setBorder(borderWidth, Colors.red),
        focusedErrorBorder: this.setBorder(borderWidth, Colors.red),
        focusedBorder: this.setBorder(borderWidth, Colors.blue),
        enabledBorder: this.setBorder(borderWidth, Colors.black)
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: !kIsWeb ? AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.popAndPushNamed(context, '/')
        ),
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ) : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 15.0),
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NovaSquare'
                      ),
                    ),
                    SizedBox(height: 50.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: customFormField('E-mail or Mobile number'),
                            validator: (value)=> _validateService.isEmptyField(value),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String val){
                              userValues['email'] = val;
                            },
                            style: TextStyle(
                              fontSize: 17.0
                            ),
                          ),
                          SizedBox(height: 30.0),
                          TextFormField(
                            obscureText: true,
                            decoration: customFormField('Password'),
                            validator: (value) => _validateService.isEmptyField(value),
                            onSaved: (String val){
                              userValues['password'] = val;
                            },
                            style: TextStyle(
                              fontSize: 17.0
                            ),
                          ),
                          SizedBox(height: 30.0),
                          Center(
                            child: Column(
                              children: <Widget>[
                                ButtonTheme(
                                  minWidth: 250.0,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(36),
                                        side: BorderSide(color: Colors.black)
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 28.0),
                                    color: Colors.black,
                                    textColor: Colors.white,
                                    child: Text(
                                      'Log in',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    onPressed: () {
                                      this.login();
                                    },
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Text(
                                    'OR',
                                  style: TextStyle(
                                    fontSize: 20.0
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                ButtonTheme(
                                  minWidth: 250.0,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(36),
                                        side: BorderSide(color: Colors.red)
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 25.0),
                                    color: Colors.redAccent,
                                    textColor: Colors.white,
                                    child: Text(
                                      'Admin Log in',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/adminLogin');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}