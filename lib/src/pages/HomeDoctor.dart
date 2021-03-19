import 'dart:async';
import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/doctorInfo.dart';
import 'package:civideoconnectapp/src/pages/ViewDocuments.dart';
import 'package:civideoconnectapp/src/pages/ViewAppointments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civideoconnectapp/src/pages/ConsultationRoom.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:civideoconnectapp/src/pages/doctorInfo.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:civideoconnectapp/src/pages/ChatMain.dart';
import 'package:civideoconnectapp/utils/Database.dart';

//import 'package:civideoconnectapp/firebase/auth/phone_auth/authservice.dart';

// final List<String> imgList = [
//   'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
//   'https://images.unsplash.com/photo-1578496480240-32d3e0c04525?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1950&q=80',
//   'https://images.pexels.com/photos/127873/pexels-photo-127873.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
//   'https://images.pexels.com/photos/139398/thermometer-headache-pain-pills-139398.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
//   'https://images.pexels.com/photos/4386513/pexels-photo-4386513.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
// ];

List<String> imgList = [];
List<String> imgListTitle = [];

class HomePageDoctor extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageDoctor> {
  int _current = 0;

  var isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<SliderImages> sliderImages = [];

  loadSliderImages() async {
    imgList.clear();
    imgListTitle.clear();

    sliderImages = [];

    await DatabaseMethods().getSliderImages("doctor").then((val) {
      sliderImages = val;
    });

    if (sliderImages.length > 0) {
      for (int i = 0; i < sliderImages.length; i++) {
        imgList.add(sliderImages[i].documentURL);
        imgListTitle.add(sliderImages[i].documentTitle);
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSliderImages();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item, fit: BoxFit.cover, width: 1000.0),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${imgList.indexOf(item) + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${imgListTitle[imgList.indexOf(item)]}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();

    return SafeArea(
      child: Scaffold(
        //backgroundColor: Theme.of(context).primaryColor,

        floatingActionButton: FloatingActionButton(
          foregroundColor: globals.appTextColor,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          child: Icon(Icons.chat),
          onPressed: () {
            return Navigator.push(
                context, MaterialPageRoute(builder: (context) => ChatMain()));
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Column(children: [
                CarouselSlider(
                  items: imageSliders,
                  options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imgList.map((url) {
                    int index = imgList.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                ),
              ]),
              DoctorsTile(),
            ],
          ),
        ),
      ),
    );
  }
}

String _loginUserType() {
  if (globals.loginUserType != null) {
    return globals.loginUserType;
  } else
    return '';
}

String _getUserData(type) {
  if (globals.user != null) {
    return globals.user[0][type];
  } else
    return '';
}

class DoctorsTile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DoctorsTileState();
}

class DoctorsTileState extends State<DoctorsTile> {
  /// create a channelController to retrieve text value

  var doctorTodaySummary = Map();

  final _channelController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadSummary();
  }

  void loadSummary() async {
    // await DatabaseMethods()
    //     .getDoctorTodaySummary(globals.personCode)
    //     .then((value) => () {
    //           String s;
    //           doctorTodaySummary = value;
    //         });

    String appointmentStatus = "";
    doctorTodaySummary["Total"] = 0;
    doctorTodaySummary["Done"] = 0;
    await Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: globals.personCode)
        .where("apptDate",
            isEqualTo:
                DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()))
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.map((element) {
        appointmentStatus = element.data['name'];

        if (appointmentStatus == null)
          appointmentStatus = "PENDING";
        else if (appointmentStatus == "CANCELLED")
          appointmentStatus = "";
        else if (appointmentStatus == "DONE")
          appointmentStatus = "DONE";
        else
          appointmentStatus = "DONE";

        if (appointmentStatus == "PENDING") {
          doctorTodaySummary["Total"] += 1;
        } else if (appointmentStatus == "DONE") {
          doctorTodaySummary["Total"] += 1;
          doctorTodaySummary["Done"] += 1;
        }
      }).toList();
    });
    // if (doctorTodaySummary == null) {
    //   doctorTodaySummary = Map();
    //   doctorTodaySummary["Total"] = 0;
    //   doctorTodaySummary["Done"] = 0;
    // }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
          color: Colors.white),
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Appointment Summary",
                style: Theme.of(context).textTheme.headline6.apply(
                      color: Color(0xff0b1666),
                      fontWeightDelta: 2,
                    ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.refresh),
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        loadSummary();
                      }),
                  FlatButton(
                    child: Text(
                      "View All", //
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewAppointments(),
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Today\'s Patients"),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: doctorTodaySummary.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key =
                                doctorTodaySummary.keys.elementAt(index);
                            return new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    alignment: Alignment.center,
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: key == "Total"
                                            ? Theme.of(context).accentColor
                                            : Colors.orangeAccent),
                                    child: Text(
                                      "${doctorTodaySummary[key]}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Text("$key")
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String _loginUserType() {
    if (globals.loginUserType != null) {
      return globals.loginUserType;
    } else
      return '';
  }
}
