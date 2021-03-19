import 'dart:async';
import 'dart:developer';
import 'package:civideoconnectapp/src/pages/Services/select_Order_COUNSELLING.dart';
import 'package:civideoconnectapp/src/pages/Services/select_Order_HOMESERVICES.dart';
import 'package:civideoconnectapp/src/pages/Services/select_Order_Kirtan.dart';
import 'package:flutter/material.dart';
import 'paramcombine1.dart';
import 'class.dart';
import 'checkout.dart';
import 'package:toast/toast.dart';

class NextPage extends StatefulWidget {
  final ParametFirestore note;
  final String serviceTypeName;

  NextPage(this.note, this.serviceTypeName);

  @override
  _ShowDataPageState createState() => _ShowDataPageState();
}

class _ShowDataPageState extends State<NextPage> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  var totalCount;
  @override
  void initState() {
    super.initState();
  }

  bool selectingmode = false; //// 1
  @override
  Widget build(BuildContext context) {
    final item = bloc.allData1
        .firstWhere((element) => element.id == widget.note.id, orElse: () {
      return null;
    });

    if (item != null) {
      widget.note.selected = true;
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: new Container(
        child: Column(children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (_, int index) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        // width: 140,
                        width: double.infinity,
                        height: 270,
                        decoration: BoxDecoration(
                          //shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(
                                widget.note.ImagePath,
                              ),
                              fit: BoxFit.cover),
                          //borderRadius: BorderRadius.circular(12),
                          /*  border: Border.all(
                              color: Colors.purple[200],
                              width: 1.0,
                            ), */
                        ),
                      ),
                      ListTile(
                        subtitle: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: 30,
                            width: 130,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.pink[200],
                              // border: Border.all(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "\Rs. ${widget.note.Price}",
                              // bloc.allData[index].Price,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        //title :Text(bloc.allData[index].TestName,),
                        title: Text(
                          widget.note.TestName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            // color: Colors.black54,
                          ),
                        ),
                      ),
                      ListTile(
                        // leading:Icon( Icons.sort,),
                        //title :Text(bloc.allData[index].TestName,),
                        title: Text(
                          widget.note.Package_included ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            // color: Colors.black54,
                          ),
                        ),

                        subtitle: Text(
                          widget.note.Test_included ?? "",
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 15,
                            // color: Colors.black54,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          widget.note.Question1 ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            // color: Colors.black54,
                          ),
                        ),
                        subtitle: Text(
                          widget.note.Answer1 ?? "",
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 15,
                            // color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          widget.note.ServiceType == "LABTEST" ||
                  widget.note.ServiceType == "HEALTHCHECKUP"
              ? ListTile(
                  subtitle: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      //subtitle: new Container(
                      height: 40,
                      width: 150,

                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.purple[300],
                        // border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        widget.note.selected == true
                            ? "Remove from cart"
                            : "Add to Cart",
                        // widget.note.Price,
                        // bloc.allData[index].Price,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onLongPress: () {
                    setState(() {
                      //selectingmode = true;
                      //bloc.addToCart(bloc.allData[index].selected);
                    });
                  },
                  onTap: () {
                    setState(() {
                      selectingmode = true;
                      if (selectingmode) {
                        log(widget.note.selected.toString());
                        bloc.pressFavorite(widget.note);
                        widget.note.selected = !widget.note.selected;
                        if (widget.note.selected)
                          Toast.show(
                              "${widget.note.TestName} added to cart!", context,
                              backgroundColor: Colors.red,
                              backgroundRadius: 5,
                              duration: Toast.LENGTH_LONG);
                        else
                          Toast.show("${widget.note.TestName} removed to cart!",
                              context,
                              backgroundColor: Colors.red,
                              backgroundRadius: 5,
                              duration: Toast.LENGTH_LONG);

                        Navigator.pop(context);
                      }
                    });
                  },
                  selected: widget.note.selected,
                  trailing:

                      // (selectingmode) ?
                      ((widget.note.selected)
                          ? Icon(Icons.offline_pin)
                          : Icon(Icons.shopping_cart))
                  // : null,

                  )
              : ListTile(
                  subtitle: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      //subtitle: new Container(
                      height: 40,
                      width: 150,

                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.purple[300],
                        // border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        "Book Now",
                        // widget.note.Price,
                        // bloc.allData[index].Price,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onLongPress: () {
                    setState(() {
                      //selectingmode = true;
                      //bloc.addToCart(bloc.allData[index].selected);
                    });
                  },
                  onTap: () {
                    if (widget.note.ServiceType == "COUNSELLING") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectOrderCOUNSELLING(note: widget.note)),
                      );
                    } else if (widget.note.ServiceType == "KIRTAN") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectOrderKirtan(note: widget.note)),
                      );
                    } else if (widget.note.ServiceType == "HOMESERVICES") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectOrderHOMESERVICES(note: widget.note)),
                      );
                    }
                  },

                  // : null,
                ),

          //  SizedBox(height: 20)

          //),
          //  ),
        ]),
      ),
    );
  }

  Widget _buildAppBar() {
    totalCount = bloc.allData1.length;
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appBarIconsColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        // widget.note.ServiceType == "LABTEST" ||
        //         widget.note.ServiceType == "HEALTHCHECKUP"
        //     ? new Padding(
        //         padding: const EdgeInsets.all(10.0),
        //         child: new Container(
        //             height: 150.0,
        //             width: 30.0,
        //             child: new GestureDetector(
        //               onTap: () {
        //                 Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                     builder: (context) => Checkout(
        //                       serviceType: widget.note.ServiceType,
        //                       //onRemove: removeFromCart())
        //                     ),
        //                     // builder: (context) => Checkout(
        //                     //     serviceType: widget.note.ServiceType,
        //                     //     onRemove: removeFromCart())
        //                   ),
        //                 );
        //               },
        //               child: new Stack(
        //                 children: <Widget>[
        //                   new IconButton(
        //                     icon: new Icon(
        //                       Icons.shopping_cart,
        //                       color: Colors.black,
        //                     ),
        //                     onPressed: null,
        //                   ),
        //                   new Positioned(
        //                       child: new Stack(
        //                     children: <Widget>[
        //                       new Icon(Icons.brightness_1,
        //                           size: 20.0, color: Colors.red[700]),
        //                       new Positioned(
        //                           top: 3.0,
        //                           right: 7,
        //                           child: new Center(
        //                             child: new Text(
        //                               '$totalCount',
        //                               style: new TextStyle(
        //                                   color: Colors.white,
        //                                   fontSize: 12.0,
        //                                   fontWeight: FontWeight.w500),
        //                             ),
        //                           )),
        //                     ],
        //                   )),
        //                 ],
        //               ),
        //             )),
        //       )
        //     : Container()
      ],
      brightness: Brightness.light,
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text('${widget.serviceTypeName}'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.5,
              color: appBarIconsColor,
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  // removeFromCart() {
  //   setState(() {
  //     widget.note.selected = false;
  //   });
  // }
}
