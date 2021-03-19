import 'dart:async';
import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/AppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/ViewAppointmentsPatient.dart';
import 'package:civideoconnectapp/src/pages/appointment/DoctorList.dart';
import 'package:civideoconnectapp/src/pages/doctorInfo.dart';
import 'package:civideoconnectapp/src/pages/ViewDocuments.dart';
import 'package:civideoconnectapp/src/pages/ViewAppointments.dart';
import 'package:civideoconnectapp/src/pages/PatientReports.dart';
import 'package:civideoconnectapp/src/pages/myProfile.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civideoconnectapp/src/pages/call.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:civideoconnectapp/src/pages/ChatMain.dart';

//import 'package:civideoconnectapp/firebase/auth/phone_auth/authservice.dart';
Color myGreen = Color(0xff4bb17b);
// final List<String> imgList = [
//   'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
//   'https://images.unsplash.com/photo-1578496480240-32d3e0c04525?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1950&q=80',
//   'https://images.pexels.com/photos/127873/pexels-photo-127873.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
//   'https://images.pexels.com/photos/139398/thermometer-headache-pain-pills-139398.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
//   'https://images.pexels.com/photos/4386513/pexels-photo-4386513.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
// ];

List<String> imgList = [];
List<String> imgListTitle = [];

class HomePagePatient extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePagePatient> {
  int _current = 0;
  Stream<QuerySnapshot> appointments;
  List<SliderImages> sliderImages = [];

  var isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSliderImages();
    // DatabaseMethods()
    //     .getPatientAppointmentsRecent(globals.personCode)
    //     .then((val) {
    //   setState(() {
    //     appointments = val;
    //   });
    // });
    // DatabaseMethods()
    //     .getPatientAppointmentsRecent(globals.personCode)
    //     .then((val) {
    //   setState(() {
    //     appointments = val;
    //   });
    // });
  }

  loadSliderImages() async {
    imgList.clear();
    imgListTitle.clear();

    sliderImages = [];

    await DatabaseMethods().getSliderImages("patient").then((val) {
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
          //foregroundColor: globals.appTextColor,
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
              SizedBox(
                height: 10,
              ),
              // SizedBox(
              //   height: 200,
              //   child: StreamBuilder(
              //       stream: appointments,
              //       builder: (context, snapshot) {
              //         return snapshot.hasData
              //             ? ListView.builder(
              //                 itemCount: snapshot.data.documents.length,
              //                 itemBuilder: (BuildContext context, int i) =>
              //                     GestureDetector(
              //                       onTap: () {
              //                         // if (tab.text.toUpperCase() == "UPCOMMING") {
              //                         //   _settingModalBottomSheet(i, context);
              //                         // }
              //                         //AppointmentDetails appList;

              //                         Navigator.push(
              //                           context,
              //                           MaterialPageRoute(
              //                             builder: (context) =>
              //                                 AppointmentScreen(
              //                               appointmentNumber: snapshot
              //                                   .data
              //                                   .documents[i]
              //                                   .data["appointmentNumber"],
              //                             ),
              //                           ),
              //                         );
              //                       },
              //                       child: Container(
              //                         height: 200,
              //                         child: Column(
              //                           children: <Widget>[
              //                             Text("Next Appointment"),
              //                             Container(
              //                               height: 120,
              //                               width: (MediaQuery.of(context)
              //                                           .size
              //                                           .width /
              //                                       2) -
              //                                   15,
              //                               margin: EdgeInsets.only(
              //                                   left: 5,
              //                                   right: 5,
              //                                   bottom: 10,
              //                                   top: 10),
              //                               decoration: BoxDecoration(
              //                                 color:
              //                                     Theme.of(context).accentColor,
              //                                 borderRadius: BorderRadius.all(
              //                                     Radius.circular(10)),
              //                                 boxShadow: <BoxShadow>[
              //                                   BoxShadow(
              //                                     offset: Offset(4, 4),
              //                                     blurRadius: 10,
              //                                     color: Colors.black
              //                                         .withOpacity(.8),
              //                                   )
              //                                 ],
              //                               ),
              //                               child: Column(
              //                                 children: <Widget>[
              //                                   Row(
              //                                     mainAxisAlignment:
              //                                         MainAxisAlignment
              //                                             .spaceBetween,
              //                                     children: <Widget>[
              //                                       Column(
              //                                         children: <Widget>[
              //                                           Text(appointmentDay(
              //                                               snapshot
              //                                                       .data
              //                                                       .document[i]
              //                                                       .data[
              //                                                   "apptDate"])),
              //                                           Text(
              //                                               "${convertToDateString(snapshot.data.document[i].data["apptDate"])} - ${snapshot.data.document[i].data["slotName"]}"),
              //                                         ],
              //                                       )
              //                                     ],
              //                                   )
              //                                 ],
              //                               ),
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     ))
              //             : Container(
              //                 child: Text("Loading data..."),
              //               );
              //       }),
              // ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Padding(padding: EdgeInsets.all(20),),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            loadMenuPage(context, "APPT");
                          },
                          child: MenuCard(
                              title: "My Appointments",
                              subtitle: "Your Appointments",
                              icon: Icons.view_list,
                              color: Theme.of(context).primaryColor,
                              lightColor: Theme.of(context).accentColor),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            loadMenuPage(context, "BOOKAPPT");
                          },
                          child: MenuCard(
                              title: "Search Doctor",
                              subtitle: "Request Appointment",
                              icon: Icons.search,
                              color: Theme.of(context).primaryColor,
                              lightColor: Theme.of(context).accentColor),
                        ),
                      ],
                    ),
                  ],
                ),

                // ],),
              ),
              Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  // color: Colors.grey,
                  // padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              loadMenuPage(context, "REPORTS");
                            },
                            child: MenuCard(
                                title: "My Reports",
                                subtitle: "View Lab Reports",
                                icon: Icons.report,
                                color: Theme.of(context).primaryColor,
                                lightColor: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              loadMenuPage(context, "DOCUMENTS");
                            },
                            child: MenuCard(
                                title: "My Documents",
                                subtitle: "View your Documents",
                                icon: Icons.attach_file,
                                color: Theme.of(context).primaryColor,
                                lightColor: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                    ],
                  )),
              Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  // color: Colors.grey,
                  // padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              loadMenuPage(context, "PROFILE");
                            },
                            child: MenuCard(
                                title: "Health News",
                                subtitle: "Get Health News",
                                icon: Icons.person,
                                color: Theme.of(context).primaryColor,
                                lightColor: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              loadMenuPage(context, "PROFILE");
                            },
                            child: MenuCard(
                                title: "My Profile",
                                subtitle: "View your Profile",
                                icon: Icons.person,
                                color: Theme.of(context).primaryColor,
                                lightColor: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

String convertToDateString(Timestamp timestamp) {
  DateTime date = timestamp.toDate();

  return DateFormat("dd MMM yyyy").format(date);
}

String appointmentDay(DateTime d) {
  Duration diff = DateTime.now().difference(d);

  if (diff.inDays == 0)
    return "Today";
  else if (diff.inDays == 1)
    return "Tomorrow";
  else
    return "in ${diff.inDays} ${diff.inDays == 1 ? "day" : "days"}";
}

loadMenuPage(context, menu) {
  switch (menu) {
    case "APPT":
      return Navigator.push(context,
          MaterialPageRoute(builder: (context) => ViewAppointmentsPatient()));
    case "PROFILE":
      return Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyProfile()));
    // globals.displayIncomingCall(context);
    //return true;
    case "REPORTS":
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PatientReports(
                    patientCode: globals.personCode,
                  )));
    case "DOCUMENTS":
      return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ViewDocuments(patientCode: globals.personCode),
          ));

    case "BOOKAPPT":
      return Navigator.push(
          context, MaterialPageRoute(builder: (context) => DoctorList()));

    // return Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => SelectDoctor()));
  }
}

class MenuCard extends StatelessWidget {
  const MenuCard(
      {Key key,
      @required this.title,
      @required this.subtitle,
      @required this.icon,
      @required this.color,
      @required this.lightColor})
      : super(key: key);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color lightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        width: (MediaQuery.of(context).size.width / 2) - 15,
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 10,
              color: Colors.black.withOpacity(.8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -20,
                  left: -20,
                  child: CircleAvatar(
                    backgroundColor: lightColor,
                    radius: 50,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 10),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            icon,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(title,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text(subtitle,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white))
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
