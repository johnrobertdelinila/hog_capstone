import 'package:flutter/material.dart';
import 'package:flutter_customer/admin_pages/breed_table.dart';
import 'package:flutter_customer/admin_pages/cage_table.dart';
import 'package:flutter_customer/admin_pages/dashboard.dart';
import 'package:flutter_customer/admin_pages/pig_table.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'brand.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum Page { dashboard, manage }

class AdminDashboard extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<AdminDashboard> {
  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor notActive = Colors.grey;
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  BrandService _brandService = BrandService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          toolbarHeight: 110,
          title: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hog Administrator', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 30.0)),
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'pigIcon.png',
                      width: 45.0,
                    )),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: FlatButton.icon(
                          onPressed: () {
                            setState(() => _selectedPage = Page.dashboard);
                          },
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          icon: Icon(
                            Icons.dashboard,
                            color: _selectedPage == Page.dashboard
                                ? active
                                : notActive,
                          ),
                          label: Text('Dashboard', style: TextStyle(fontSize: 15),))),
                  Expanded(
                      child: FlatButton.icon(
                          onPressed: () {
                            setState(() => _selectedPage = Page.manage);
                          },
                          padding: EdgeInsets.symmetric(vertical: 25.0),
                          icon: Icon(
                            Icons.sort,
                            color:
                            _selectedPage == Page.manage ? active : notActive,
                          ),
                          label: Text('Manage', style: TextStyle(fontSize: 15),))),
                ],
              )
            ],
          ),
          backgroundColor: Colors.white,
        ),
        body: _loadScreen());
  }

  Widget _loadScreen() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Dashboard();
        break;
      case Page.manage:
        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720),
            child: ListView(
              children: <Widget>[
                SizedBox(height: kIsWeb ? 70 : 0,),
                Divider(),
                ListTile(
                  leading: Icon(Icons.change_history),
                  title: Text("HOGS"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PigTable()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.add_circle),
                  title: Text("BREEDS"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => BreedTable()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text("CAGES"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CageTable()));
                  },
                ),
                Divider(),
              ],
            ),
          ),
        );
        break;
      default:
        return Container();
    }
  }


  void _brandAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _brandFormKey,
        child: TextFormField(
          controller: brandController,
          validator: (value){
            if(value.isEmpty){
              return 'Breed cannot be empty';
            }else {
              return '';
            }
          },
          decoration: InputDecoration(
              hintText: "Add Cage"
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(onPressed: (){
          if(brandController.text != null && brandController.text.length > 2){
            _brandService.createBrand(brandController.text);
            Fluttertoast.showToast(msg: 'Cage added');
          }else {
            Fluttertoast.showToast(msg: 'Cage name must not be empty.', backgroundColor: Colors.red, timeInSecForIosWeb: 2,);
          }
          Navigator.pop(context);
        }, child: Text('ADD')),
        FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('CANCEL')),

      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }
}