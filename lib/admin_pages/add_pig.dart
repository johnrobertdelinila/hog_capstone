import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_customer/objects/pig.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'products.dart';
import 'category.dart';
import 'brand.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService productService = ProductService();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController productNameController = TextEditingController();
  TextEditingController quatityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController vaccineDateController = TextEditingController();
  TextEditingController vaccineNameController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController placeOriginController = TextEditingController();
  TextEditingController rangeController = TextEditingController();

  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];

  List<DropdownMenuItem<String>> categoriesDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> genderDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> vaccineTypeDropDown = <DropdownMenuItem<String>>[];

  String _currentCategory = "";
  String _currentBrand = "";
  String _currentGender = "";
  String _currentVaccineType = "";

  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  File _image1;
  File _image2;
  File _image3;
  bool isLoading = false;

  DateTime selectedDate = DateTime.now();

  Pig pig;

  @override
  void initState() {
    _getBrands();
    _getGender();
    _getCategories();
    _getVaccineType();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(StringUtils.capitalize(categories[i].data['breedName'])),
                value: categories[i].data['breedName']));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandosDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].data['cageName']),
                value: brands[i].data['cageName'])

            );
      });
    }



    // for (int i = 1; i <= 10; i++) {
    //   // setState(() {
    //   //
    //   // });
    //   items.insert(
    //       0,
    //       DropdownMenuItem(
    //           child: Text("A" + i.toString()),
    //           value: "A" + i.toString())
    //
    //   );
    // }
    return items;
  }

  List<DropdownMenuItem<String>> getGenderDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    setState(() {
      items.insert(
          0,
          DropdownMenuItem(
              child: Text("Male"),
              value: "Male"
          )
      );
      items.insert(
          1,
          DropdownMenuItem(
              child: Text("Female"),
              value: "Female"
          )
      );
    });
    return items;
  }

  List<DropdownMenuItem<String>> _getVaccineTypeDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    setState(() {
      items.insert(
          0,
          DropdownMenuItem(
              child: Text("Autogenous vaccines"),
              value: "Autogenous vaccines"
          )
      );
      items.insert(
          1,
          DropdownMenuItem(
              child: Text("Boar Taint Vaccine"),
              value: "Boar Taint Vaccine"
          )
      );
    });
    return items;
  }

  _selectDate(BuildContext context) async {
    var formatter = new DateFormat('yyyy-MM-dd');
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        vaccineDateController.text = formatter.format(picked);
      });
  }

  @override
  Widget build(BuildContext context) {

    Map<dynamic, dynamic> args = ModalRoute.of(context).settings.arguments;
    if(args != null) {
      pig = args['pig'];

      priceController.text = pig.price.toString();
      weightController.text = pig.weight.toString();
      ageController.text = pig.age.toString();
      vaccineDateController.text = pig.vaccinated;
      vaccineNameController.text = pig.vaccineName;
      colorController.text = pig.color;
      birthDateController.text = pig.birth;
      placeOriginController.text = pig.place;
      rangeController.text = pig.range;
      _currentCategory = pig.name;
      _currentBrand = pig.subBreed;
      _currentGender = pig.gender;
      _currentVaccineType = pig.vaccineType;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: black,
          ),
          onPressed: (){Navigator.of(context).pop(true);},
        ),
        title: Text(
          "Add New Hog",
          style: TextStyle(color: black),
        ),
      ),
      body: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 740),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Visibility(
                        visible: kIsWeb ? false : true,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(
                                    ImagePicker.pickImage(
                                      source: ImageSource.gallery),
                                    1);
                                },
                                child: _displayChild1()),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(
                                      ImagePicker.pickImage(
                                          source: ImageSource.gallery),
                                      2);
                                },
                                child: _displayChild2()),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlineButton(
                              borderSide: BorderSide(
                                  color: grey.withOpacity(0.5), width: 2.5),
                              onPressed: () {
                                _selectImage(
                                    ImagePicker.pickImage(
                                        source: ImageSource.gallery),
                                    3);
                              },
                              child: _displayChild3(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Breed: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                      DropdownButton(
                        items: categoriesDropDown,
                        onChanged: changeSelectedCategory,
                        value: _currentCategory,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Cage: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                      DropdownButton(
                        items: brandsDropDown,
                        onChanged: changeSelectedBrand,
                        value: _currentBrand,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Gender: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                      DropdownButton(
                        items: genderDropDown,
                        onChanged: changeSelectedGender,
                        value: _currentGender,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Vaccine Type: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                      DropdownButton(
                        items: vaccineTypeDropDown,
                        onChanged: changeSelectedVaccineType,
                        value: _currentVaccineType,
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Price',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the price of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Weight (Kg)',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the weight of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Age',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the age of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        onTap: (){
                          _selectDate(context);
                        },
                        controller: vaccineDateController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Vaccination Date',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the date vaccinated of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: vaccineNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Vaccine Name',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the vaccine of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: colorController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Color',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the color of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: birthDateController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Date of birth',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the birth date of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: placeOriginController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Place of origin',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the place of origin of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: TextFormField(
                        controller: rangeController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Range Price',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the range per kilo of the pig.';
                          }else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),

                  FlatButton(
                    color: red,
                    textColor: white,
                    child: Text(pig != null ? 'UPDATE HOG' : 'ADD HOG'),
                    onPressed: () {
                      validateAndUpload();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data['breedName'];
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandosDropDown();
      _currentBrand = brands[0].data['cageName'];
    });
  }

  _getVaccineType() {
    vaccineTypeDropDown = _getVaccineTypeDropDown();
    _currentVaccineType = "Autogenous vaccines";
  }

  _getGender() {
    genderDropDown = getGenderDropDown();
    _currentGender = "Male";
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  changeSelectedGender(String selectedGender) {
    setState(() => _currentGender = selectedGender);
  }

  changeSelectedVaccineType(String selectedVaccineType) {
    setState(() => _currentVaccineType = selectedVaccineType);
  }

  /*void changeSelectedSize(String size) {
    if (selectedSizes.contains(size)) {
      setState(() {
        selectedSizes.remove(size);
      });
    } else {
      setState(() {
        selectedSizes.insert(0, size);
      });
    }
  }*/

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() => _image1 = tempImg);
        break;
      case 2:
        setState(() => _image2 = tempImg);
        break;
      case 3:
        setState(() => _image3 = tempImg);
        break;
    }
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: new Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image1,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: new Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image2,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: new Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image3,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  void validateAndUpload() async {
    if (_formKey.currentState.validate()) {
      setState(() => isLoading = true);
      if (/*_image1 != null && _image2 != null && _image3 != null*/true) {
          String imageUrl1;
          // String imageUrl2;
          // String imageUrl3;

          if(_image1 != null && !kIsWeb) {
            final FirebaseStorage storage = FirebaseStorage.instance;
            final String picture1 = "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
            StorageUploadTask task1 = storage.ref().child(picture1).putFile(_image1);
            StorageTaskSnapshot snapshot1 = await task1.onComplete.then((snapshot) => snapshot);
            imageUrl1 = await snapshot1.ref.getDownloadURL();
          }else {
            imageUrl1 = 'https://images.unsplash.com/photo-1567201080580-bfcc97dae346?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80';
          }

          /*final String picture2 =
              "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task2 =
          storage.ref().child(picture2).putFile(_image2);
          final String picture3 =
              "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task3 =
          storage.ref().child(picture3).putFile(_image3);*/

          // StorageTaskSnapshot snapshot1 =
          // await task1.onComplete.then((snapshot) => snapshot);
          // StorageTaskSnapshot snapshot2 =
          // await task2.onComplete.then((snapshot) => snapshot);

          // task1.onComplete.then((snapshot3) async {
          //   imageUrl1 = await snapshot3.ref.getDownloadURL();
          //   imageUrl2 = await snapshot2.ref.getDownloadURL();
          //   imageUrl3 = await snapshot3.ref.getDownloadURL();
          //   List<String> imageList = [imageUrl1, imageUrl2, imageUrl3];
          //
          //   productService.uploadProduct({
          //     "name":_currentCategory,
          //     "price":double.parse(priceController.text),
          //     "image":imageUrl1,
          //     "quantity":int.parse(quatityController.text),
          //     "cage":_currentBrand,
          //     "breed":_currentCategory
          //   });
          //   _formKey.currentState.reset();
          //   setState(() => isLoading = false);
          //   Fluttertoast.showToast(msg: 'Pig added', timeInSecForIosWeb: 2,);
          //   Navigator.pop(context);
          //
          // });

          var size = ["Size"];
          var color = ["FFFFFF"];

          if(pig == null) {
            productService.uploadProduct({
              "name":_currentCategory,
              "price":double.parse(priceController.text),
              "image":imageUrl1,
              // "quantity":int.parse(quatityController.text),
              "subBreed":_currentBrand,
              "weight":double.parse(weightController.text),
              "age":double.parse(ageController.text),
              "vaccinatedDate":vaccineDateController.text,
              "gender":_currentGender,
              "size": size,
              "color": color,
              "vaccineType": _currentVaccineType,
              "vaccineName": vaccineNameController.text,
              "pigColor": colorController.text,
              "dateBirth": birthDateController.text,
              "placeOrigin": placeOriginController.text,
              "range": rangeController.text,
              "timestamp": FieldValue.serverTimestamp()
              // "breed":_currentCategory
            });
          }else {
            pig.reference.setData({
              "name":_currentCategory,
              "price":double.parse(priceController.text),
              "subBreed":_currentBrand,
              "weight":double.parse(weightController.text),
              "age":double.parse(ageController.text),
              "vaccinatedDate":vaccineDateController.text,
              "gender":_currentGender,
              "vaccineType": _currentVaccineType,
              "vaccineName": vaccineNameController.text,
              "pigColor": colorController.text,
              "dateBirth": birthDateController.text,
              "placeOrigin": placeOriginController.text,
              "range": rangeController.text,
              "timestamp": FieldValue.serverTimestamp()
            }, merge: true);
          }


          _formKey.currentState.reset();
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: 'Hog added', timeInSecForIosWeb: 2,);
          Navigator.pop(context);

      } else {
        setState(() => isLoading = false);
       Fluttertoast.showToast(msg: 'Images must be provided', timeInSecForIosWeb: 2,);
      }
    }
  }
}