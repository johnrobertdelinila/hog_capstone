import 'dart:math';

import 'package:flutter_customer/components/alertBox.dart';

import 'style.dart';
import 'user.dart';
import 'loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_customer/components/loader.dart';

class AdminLogin extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // var user = Provider.of<UserProvider>(context);
    return Scaffold(
      key: _key,
      body: /*user.status == Status.Authenticating ? Loading() : */ Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Stack(
            children: <Widget>[
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[350],
                          blurRadius:
                          20.0, // has the effect of softening the shadow
                        )
                      ],
                    ),
                    child: Form(
                        key: _formKey,
                        child: ListView(
                          children: <Widget>[
                            SizedBox(height: 40,),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  child: Image.asset(
                                    'pigIcon.png',
                                    width: 150.0,
                                  )),
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey.withOpacity(0.3),
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: TextFormField(
                                    controller: _email,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Username",
                                      icon: Icon(Icons.admin_panel_settings_outlined),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        Pattern pattern =
                                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                        RegExp regex = new RegExp(pattern);
                                        if (!regex.hasMatch(value))
                                          return 'Please make sure your username is valid';
                                        else
                                          return null;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey.withOpacity(0.3),
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: TextFormField(
                                    obscureText: true,
                                    controller: _password,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      icon: Icon(Icons.lock_outline),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "The password field cannot be empty";
                                      } else if (value.length < 6) {
                                        return "the password has to be at least 6 characters long";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                              child: Material(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.black,
                                  elevation: 0.0,
                                  child: MaterialButton(
                                    onPressed: () async{
                                      if(_formKey.currentState.validate()){
                                        // if(!await user.signIn(_email.text, _password.text))
                                        //   _key.currentState.showSnackBar(SnackBar(content: Text("Sign in failed")));

                                        Loader.showLoadingScreen(context, _key);

                                        Random rnd;
                                        int min = 820;
                                        int max = 1100;
                                        rnd = new Random();
                                        int r = min + rnd.nextInt(max - min);

                                        new Future.delayed(Duration(milliseconds: r), (){
                                          Navigator.of(_key.currentContext, rootNavigator: true).pop();
                                          if(_email.text == "admin" && _password.text == "admin123") {
                                            Navigator.pushNamed(context, '/dashboard');
                                          }else {
                                            AlertBox alertBox = AlertBox("Sign in failed.");
                                            return showDialog(
                                                context: context,
                                                builder: (BuildContext context){
                                                  return alertBox.build(context);
                                                }
                                            );
                                          }
                                        });

                                      }
                                    },
                                    minWidth: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20.0),
                                      child: Text(
                                        "Admin Sign In",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0
                                        ),
                                      ),
                                    ),
                                  )),
                            ),

//                        Padding(
//                          padding: const EdgeInsets.all(16.0),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: <Widget>[
//
//                              Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Text("or sign in with", style: TextStyle(fontSize: 18,color: Colors.grey),),
//                              ),
//                              Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: MaterialButton(
//                                    onPressed: () {},
//                                    child: Image.asset("images/ggg.png", width: 30,)
//                                ),
//                              ),
//
//                            ],
//                          ),
//                        ),

                          ],
                        )),

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}