import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_customer/components/item/customTransition.dart';
import 'package:flutter_customer/pages/products/particularItem.dart';
import 'package:flutter_customer/services/productService.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SnapEffectCarousel extends StatefulWidget {
  @override
  _SnapEffectCarouselState createState() => _SnapEffectCarouselState();
}

class _SnapEffectCarouselState extends State<SnapEffectCarousel> {
  int _index = 0;
  List newArrivals = new List();
  ProductService _productService = new ProductService();

  _SnapEffectCarouselState(){
    listNewArrivals();
  }

  void listNewArrivals() async{
    List<Map<String,String>> newArrivalList = await _productService.newItemArrivals();
    setState(() {
      newArrivals = newArrivalList;
    });
  }

  void showParticularItem(Map item) async{
    String productId = item['productId'];
    Map itemDetails = await _productService.particularItem(productId);
    Navigator.push(
      context,
      CustomTransition(
        type: CustomTransitionType.downToUp,
        child: ParticularItem(
          itemDetails: itemDetails,
          edit: false,
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: newArrivals.length,
      controller: PageController(
        viewportFraction: 0.7,
      ),
      onPageChanged: (int index) => setState(()=> _index = index),
      itemBuilder: (context,index){
        var item = newArrivals[index];
        return Transform.scale(
          scale: index == _index ? 1 : 0.8,
          child: Column(
            children: <Widget>[
              FlatButton(
                onPressed: () {},
                child: Container(
                  height: kIsWeb ? 200 : 300,
                  width: kIsWeb ? 200 : 600,
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        showParticularItem(item);
                      },
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAlias,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:  BorderRadius.all(Radius.circular(8.0)),
                            image: DecorationImage(
                                image: NetworkImage(item['image']),
                                fit: BoxFit.cover
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0,left: 20.0, right: 20.0),
                child: index == _index ? Text(
                  StringUtils.capitalize(item['name']),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0
                  ),
                ): Text(''),
              )
            ],
          ),
        );
      },
    );
  }
}