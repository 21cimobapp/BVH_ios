import 'dart:async';

import 'package:flutter/material.dart';

import 'class.dart';
import 'select_pickup.dart';

class Checkout extends StatefulWidget {
  final String serviceType;
  //final Function() onRemove;
  //const Checkout({Key key, this.serviceType, this.onRemove}) : super(key: key);
  const Checkout({Key key, this.serviceType}) : super(key: key);
  @override
  Showpagee createState() => Showpagee();
}

class Showpagee extends State<Checkout> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  getsum() {
    bloc.total = 0;
    for (int i = 0; i < bloc.allData1.length; i++) {
      bloc.total = bloc.total + bloc.allData1[i].Price;
      print(bloc.total);
    }
  }

  bool _disposed = false;
  @override
  void initState() {
    getsum();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: new Container(
        child: bloc.allData1.length == 0
            ? Center(child: new Text(' Cart is empty!'))
            : Column(
                children: <Widget>[
                  Expanded(
                      child: //checkoutListBuilder()
                          ListView.builder(
                    itemCount: bloc.allData1.length,
                    itemBuilder: (_, index) {
                      return Container(
                        margin: const EdgeInsets.all(10.0),
                        child: Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0,
                                bottom: 16.0,
                                left: 16.0,
                                right: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(children: <Widget>[
                                      Container(
                                        width: 220,
                                        child: Text(
                                          bloc.allData1[index].TestName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            //color: Colors.black54,
                                            //height: 2
                                          ),
                                        ),
                                      ),
                                    ]),
                                    Column(
                                      children: <Widget>[
                                        //Text(bloc.allData1[index].Price,
                                        Text(
                                          "\Rs. ${bloc.allData1[index].Price}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            bloc.pressFavorite(
                                                bloc.allData1[index]);
                                            //widget.onRemove();
                                          });
                                        },
                                      ),
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 200,
                          // children: <Widget>[
                          child: Column(
                            children: <Widget>[
                              Text(
                                "\Total Amount:  ${bloc.total} /-",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SelectPickup(
                                          serviceType: widget.serviceType)),
                                );
                              },
                              child: Text(
                                "Check Out",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appBarIconsColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.only(right: 18.0),
        //   child: Icon(Icons.more_horiz, color: appBarIconsColor, size: 28),
        // )
      ],
      brightness: Brightness.light,
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text('Cart'.toUpperCase(),
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
}
