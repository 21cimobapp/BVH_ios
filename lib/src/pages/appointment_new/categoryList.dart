import 'dart:ui';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter/material.dart';
import 'doctor_list.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'DrinkData.dart';
import 'doctor_card.dart';

final Color _backgroundColor = Color(0xFFf0f0f0);

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  double _listPadding = 20;

  ScrollController _scrollController = ScrollController();
  List<DoctorSpeciality> _specialization = List<DoctorSpeciality>();

  @override
  void initState() {
    setState(() {
      loadSpeciality();
    });

    // Commented by Abhi API instead of Firebase.
//     DatabaseMethods().getDoctorSpeciality().then((value) => {
//           setState(() {
//             _specialization = value;
//           })
//         });
    // End Commented by Abhi API instead of Firebase.
    super.initState();
  }

  loadSpeciality() async {
    // Added by Abhi API instead of Firebase.
    return await http.post(
        Uri.encodeFull('${globals.apiHostingURLBVH}/MobileAppPatient/GetSpecialityDetail'),
        body: {},
        headers: {"Accept": "application/json"}).then((http.Response response) {
      // setState(() {
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        var extractdata = jsonDecode(response.body)['specialities'];
        print(extractdata);

        List data = extractdata as List;
        if (data != null) {
          for (int i = 0; i < data.length; i++) {
            setState(() {
              _specialization.add(DoctorSpeciality.fromJson(data[i]));
            });
          }
        }
      }
      // });
    });
    // End Added by Abhi API instead of Firebase.
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).size.aspectRatio > 1;
    var size = MediaQuery.of(context).size;
    print(size);
    final double itemHeight = 100;
    print(itemHeight);
    final double itemWidth = size.width / 4;
    print(itemWidth);
    //MediaQuery.of(context).size.height  * (isLandscape ? .25 : .2);
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          Container(
              height: 40,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Select category", style: TextStyle(fontSize: 16)),
//                      MaterialButton(
//                          height: 40,
//                          color: Colors.indigo,
//                          child: Hero(
//                              tag: 'ALL',
//                              child: Text("Show All",
//                                  style: TextStyle(
//                                      fontSize: 16, color: Colors.white))),
//                          onPressed: () {
//                            Navigator.of(context).push(
//                              PageRouteBuilder(
//                                transitionDuration:
//                                    Duration(milliseconds: 1000),
//                                pageBuilder: (BuildContext context,
//                                    Animation<double> animation,
//                                    Animation<double> secondaryAnimation) {
//                                  return DoctorList(specialization: null);
//                                },
//                                transitionsBuilder: (BuildContext context,
//                                    Animation<double> animation,
//                                    Animation<double> secondaryAnimation,
//                                    Widget child) {
//                                  return Align(
//                                    child: FadeTransition(
//                                      opacity: animation,
//                                      child: child,
//                                    ),
//                                  );
//                                },
//                              ),
//                            );
//                          }),
                    ],
                  ),
                ),
              )),
          Expanded(
            child: GridView.count(
                padding: EdgeInsets.all(5.0),
                crossAxisCount: isLandscape ? 4 : 3,
                childAspectRatio: 1,
                controller: new ScrollController(keepScrollOffset: false),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: List.generate(_specialization.length, (index) {
                  return _buildListItem(index);
                })),
          ),
          //_buildTopBg(headerHeight),
          //_buildTopContent(headerHeight),
        ],
      ),
    );
  }

  Widget _buildListItem(int index) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 1000),
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return DoctorList(specialization: _specialization[index],organizationCode:'H05');
              },
              transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) {
                return Align(
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 0),
            color: Colors.grey[200],
            child: Stack(children: <Widget>[
              Hero(
                  tag: '${_specialization[index].specialityId}',
                  child: Image.network(
                    _specialization[index].imageURL == null
                        ? "http://www.21ci.com/21online/Specialties/Default.png"
                        : _specialization[index].imageURL ?? "",
                    fit: BoxFit.fill,
                  )),
              _specialization[index].imageURL != null
                  ? Container()
                  : Container(
                      width: 120,
                      height: 120,
                      padding: EdgeInsets.all(5),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            padding: EdgeInsets.all(5),
                            //color: Colors.blue,
                            width: 100,
                            child: Center(
                                child: Text(
                              "${_specialization[index].speciality}",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                              overflow: TextOverflow.clip,
                            ))),
                      ),
                    ),
            ])));
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
        child: Text('Book an Appointment'.toUpperCase(),
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
