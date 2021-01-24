import 'package:flutter/material.dart';

import 'package:flutter_customer/services/productService.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Category{
  final String name;
  final String url;

  Category({this.name, this.url});
}

class CategoryCarousal extends StatefulWidget {
  @override
  _HorizontalListState createState() => _HorizontalListState();
}

class _HorizontalListState extends State<CategoryCarousal> {
  ProductService _productService = ProductService();

  final category = <Category>[
    Category(
        name: 'LARGE WHITE',
        url: 'assets/breeds/large-white.jpg'
    ),
    Category(
        name: 'LANDRACE',
        url: 'assets/breeds/landrace.jpg'
    ),
    Category(
      name: 'DUROC',
      url: 'assets/breeds/duroc.jpg'
    ),
    Category(
      name: 'HAMPSHIRE',
      url: 'assets/breeds/hampshire.jpg'
    )
  ];

  void listSubCategories(String category) async{
    category = category.toLowerCase();
    Map subCategory = await _productService.listSubCategories(category);
    Map args = {'subCategory': subCategory, 'category': category};
    Navigator.pushNamed(context, '/subPigs', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: category.length,
      itemBuilder: (context, index){
        var item = category[index];
        return FlatButton(
          onPressed: () {},
          child: Container(
            width: kIsWeb ? 450.0 : 200.0,
            height: null,
            child: GestureDetector(
              onTap: (){
                listSubCategories(item.name);
              },
              child: Card(
                color: Color(0xffFAFAFA),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    image: DecorationImage(
                      image: AssetImage(item.url),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Color.fromRGBO(90,90,90,0.8),
                        BlendMode.modulate
                      )
                    )
                  ),
                  child: Center(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0,
                        color: Colors.white,
                        letterSpacing: 1.0,
                        fontFamily: 'NovaSquare'
                      ),
                    ),
                  ),
                )
              ),
            ),
          ),
        );
      }
    );
  }
}

