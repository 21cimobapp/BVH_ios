import 'dart:ui';
import 'package:civideoconnectapp/src/pages/index/index_new.dart';
import 'package:flutter/material.dart';
import 'doctor_list.dart';

import 'DrinkData.dart';
import 'doctor_card.dart';
import 'organization_list.dart';

final Color _backgroundColor = Color(0xFFf0f0f0);

class DoctorAppointmentHome extends StatefulWidget {
  @override
  _DoctorAppointmentHomeState createState() => _DoctorAppointmentHomeState();
}

class _DoctorAppointmentHomeState extends State<DoctorAppointmentHome> {
  double _listPadding = 20;
  DrinkData _selectedDrink;
  ScrollController _scrollController = ScrollController();
  List<DrinkData> _drinks;
  int _earnedPoints;
  Color myTitleColor;

  @override
  void initState() {
    var demoData = DemoData();
    _drinks = demoData.drinks;
    _earnedPoints = demoData.earnedPoints;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).size.aspectRatio > 1;
    myTitleColor = Theme.of(context).primaryColor;
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: double.infinity,
                //color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          "assets/images/Hospitalogo.png",
                        ),
                        Image.asset(
                          "assets/images/bigDoc.png",
                          height: 200,
                        ),
                        SizedBox(height: 20),
                        Text("Search for your doctor ",
                            style: TextStyle(fontSize: 20)),
                        SizedBox(height: 10),
                        Text("and book an appointment",
                            style: TextStyle(fontSize: 20)),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Icon(Icons.video_call),
                                Text("Video call")
                              ],
                            ),
                            Column(
                              children: [Icon(Icons.chat), Text("Chat")],
                            ),
                            Column(
                              children: [
                                Icon(Icons.attach_file),
                                Text("e-Prescription")
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 30),
                        RaisedButton(
                          elevation: 16.0,
                          //onPressed: startPhoneAuth,
                          onPressed: () {
                            Navigator.push(
                                context,
                            MaterialPageRoute(builder: (context) => DoctorList(specialization: null,organizationCode:"H05")),
//                              MaterialPageRoute(builder: (context) => OrganizationList()),
                           // Navigator.pushNamed(context, '/CategoryList');
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 150,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Book Now',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
                                ),
                              ),
                            ),
                          ),
                          color: myTitleColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
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
                return DoctorList();
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
          // final route = MaterialPageRoute(
          //   builder: (context) => DrinkRewardsListDemo(),
          // );
          // Navigator.push(context, route);
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 0),
            //color: Colors.green,
            child: Stack(children: <Widget>[
              Hero(
                  tag: 'Cardiology${index}',
                  child: Image.network(
                    "http://www.21ci.com/21online/Specialties/Cardiology.png",
                    fit: BoxFit.fill,
                  )),
            ])));
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: appBarIconsColor),
         onPressed: () {
           //Navigator.pop(context);
           Navigator.push(
             context,
//                            MaterialPageRoute(builder: (context) => DoctorList(specialization: null)),
             MaterialPageRoute(builder: (context) => IndexNew()),
             // Navigator.pushNamed(context, '/CategoryList');
           );
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
        child: Text('Doctors'.toUpperCase(),
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
