import 'dart:convert';
import 'dart:math';
import 'package:civideoconnectapp/data_models/ViewAppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/viewAppointment_Patient/view_appointmentPast.dart';
import 'package:flutter/material.dart';
import 'demo_data.dart';
import 'appointment.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civideoconnectapp/src/pages/AppointmentDetails.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;

class ViewAppointment extends StatefulWidget {
  @override
  _ViewAppointmentState createState() => _ViewAppointmentState();
}

class _ViewAppointmentState extends State<ViewAppointment> {
  final Color _backgroundColor = Color(0xFFf0f0f0);

  final ScrollController _scrollController = ScrollController();
  // Stream<QuerySnapshot> appointments1;
  // Stream<QuerySnapshot> appointments2;
  List<ViewAppointmentDetails> _appointment = List<ViewAppointmentDetails>();
//  Stream<QuerySnapshot> appointments;
  final List<int> _openTickets = [];

  List<bool> isSelected;
  int selectedIndex = 0;

  //underapi
  //Stream<ViewAppointmentDetails> appointments1_New;
  var doc = List<ViewAppointmentDetails>();

  Future<List<ViewAppointmentDetails>> apiData() async {

    var url = "${globals.apiHostingURLBVH}/MobileAppPatient/ViewAppointmentList";
//    url="http://devp.21ci.com:81/BVHApptPortalAPI/api/MobileAppPatient/ViewAppointmentList";
    var response = await http.post(url,
        headers: {"Authorization": 'Bearer ${globals.tokenKey}'},
        body: {
       "PatientCode": "${globals.personCode}"
     }
    );
//    var doc = List<ViewAppointmentDetails>();
//    final Stream<List<int>> _posts = Stream<List<int>>.fromIterable(
//      <List<int>>[
//        List<int>.generate(10, (int i) => i),
//      ],
//    );
    print("Hello 2${response.statusCode}");
    if (response.statusCode == 200) {
      List patientJson = json.decode(response.body)['PatientAppointList'];
      if (patientJson.isNotEmpty) {
        for (var notejson in patientJson) {

          String a1 = notejson["ApptPeriod"];
          if (a1 == "1")
          {
            doc.add(ViewAppointmentDetails.fromJson(notejson));
          }
          //appointments1_New=notejson;
  }
        return doc;
      }
    }
  }

//  Stream<ViewAppointmentDetails> getNumbers(Duration refreshTime) async* {
//    while (true) {
//      await Future.delayed(refreshTime);
//      yield await apiData();
//    }
//  }

  @override
  void initState() {
    super.initState();

    isSelected = [true, false];

//    getStream(0);

    apiData().then((value) {
      setState(() {
        _appointment.addAll(value);
      });
    }); //underapi

//    // DatabaseMethods().getPatientAppointments(globals.personCode).then((val) {
//    //   setState(() {
//    //     appointments1 = val;
//    //   });
//    // });
//
//    // DatabaseMethods()
//    //     .getPatientAppointmentsPast(globals.personCode)
//    //     .then((val) {
//    //   setState(() {
//    //     appointments2 = val;
//    //   });
//    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        child: Flex(direction: Axis.vertical, children: <Widget>[
          Container(
              height: 40,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Text("All appointments",
                    style: TextStyle(fontSize: 16)),
              )),
          SizedBox(height: 5),
          // ToggleButtons(
          //   borderColor: Colors.grey[300],
          //   disabledColor: Colors.grey[300],
          //   fillColor: Colors.orangeAccent,
          //   borderWidth: 2,
          //   selectedBorderColor: Colors.grey[300],
          //   selectedColor: Colors.white,
          //   borderRadius: BorderRadius.circular(5),
          //   children: <Widget>[
          //     Container(
          //       width: (MediaQuery.of(context).size.width / 2) - 10,
          //       padding: const EdgeInsets.all(8.0),
          //       child: Text(
          //         'Current Appointments',
          //         style: TextStyle(fontSize: 16),
          //       ),
          //     ),
          //     Container(
          //       width: (MediaQuery.of(context).size.width / 2) - 10,
          //       padding: const EdgeInsets.all(8.0),
          //       child: Text(
          //         'Past Appointments',
          //         style: TextStyle(fontSize: 16),
          //       ),
          //     ),
          //   ],
          //   onPressed: (int index) async {
          //     setState(() {
          //       for (int i = 0; i < isSelected.length; i++) {
          //         isSelected[i] = i == index;
          //       }
          //       selectedIndex = index;
          //       getStream(selectedIndex);
          //     });

          //     // if (index == 0) {
          //     //   await DatabaseMethods()
          //     //       .getPatientAppointments(globals.personCode)
          //     //       .then((val) {
          //     //     setState(() {
          //     //       appointments = val;
          //     //     });
          //     //   });
          //     // } else {
          //     //   await DatabaseMethods()
          //     //       .getPatientAppointmentsPast(globals.personCode)
          //     //       .then((val) {
          //     //     setState(() {
          //     //       appointments = val;
          //     //     });
          //     //   });
          //     // }
          //   },
          //   isSelected: isSelected,
          // ),

          Row(
            children: [
              Container(
                color: Colors.orangeAccent,
                width: (MediaQuery.of(context).size.width / 2),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Pending',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewAppointmentPast(),
                    ),
                  );
                },
                child: Container(
                  color: Colors.grey[300],
                  width: (MediaQuery.of(context).size.width / 2),
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Past',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
//            child: StreamBuilder(
//                stream: //appointments1_New,
//                    appointments, //selectedIndex == 0 ? appointments1 : appointments2,
//                builder: (context, snapshot) {
//                  return snapshot.hasData
//                      ? snapshot.data.documents.length == 0
          child: _appointment!=null ?
          _appointment.length==0
          ? Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("You don't have any appointments!"),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: BouncingScrollPhysics(),
                              itemCount: _appointment.length,//snapshot.data.documents.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  child: Hero(
                                    tag:'${_appointment[index].ApptNumber}',
                                        //'${snapshot.data.documents[index].data["appointmentNumber"]}',
                                    child: getAppointmentCard( _appointment[index],index),
                                        //snapshot.data.documents[index], index),
                                  ),
                                );
                              },
                            )
                      : Container(
                          child: Text("Loading data..."), )
                       // );
               // }),
          ),
        ]),
      ),
    );
  }

//  getStream(index) {
//    if (index == 0) {
//      DatabaseMethods().getPatientAppointments(globals.personCode).then((val) {
//        setState(() {
//          appointments = val;
//        });
//      });
//    } else {
//      DatabaseMethods()
//          .getPatientAppointmentsPast(globals.personCode)
//          .then((val) {
//        setState(() {
//          appointments = val;
//        });
//      });
//    }
//
//    // if (index == 0)
//    //   return appointments1;
//    // else
//    //   return appointments2;
//  }

  Widget getAppointmentCard(appt, index) {
    Widget apptCard;
    apptCard = Text("...");

    apptCard = Appointment(
      appt: appt,
      onClick: () => _handleClickedAppointment(index),
      onViewClick: () => _handleViewAppointment(appt),
    );
    return apptCard;
  }

  bool _handleViewAppointment(ViewAppointmentDetails appt) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return AppointmentScreen(
//            appointmentNumber: appt.data["appointmentNumber"],//underapi
            appointmentNumber: appt.ApptNumber,
            appt1: appt,
            isCurrent:1
          );
        },
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return Align(
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
    return true;
  }

  bool _handleClickedAppointment(int clickedAppointment) {
    // Scroll to ticket position
    // Add or remove the item of the list of open tickets
    _openTickets.contains(clickedAppointment)
        ? _openTickets.remove(clickedAppointment)
        : _openTickets.add(clickedAppointment);

    // Calculate heights of the open and closed elements before the clicked item
    double openTicketsOffset = Appointment.nominalOpenHeight *
        _getOpenTicketsBefore(clickedAppointment);
    double closedTicketsOffset = Appointment.nominalClosedHeight *
        (clickedAppointment - _getOpenTicketsBefore(clickedAppointment));

    double offset = openTicketsOffset +
        closedTicketsOffset -
        (Appointment.nominalClosedHeight * .5);

    // Scroll to the clicked element
    _scrollController.animateTo(max(0, offset),
        duration: Duration(seconds: 1),
        curve: Interval(.25, 1, curve: Curves.easeOutQuad));
    // Return true to stop the notification propagation
    return true;
  }

  _getOpenTicketsBefore(int ticketIndex) {
    // Search all indexes that are smaller to the current index in the list of indexes of open tickets
    return _openTickets.where((int index) => index < ticketIndex).length;
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      //leading: Icon(Icons.home, color: appBarIconsColor),
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
        child: Text('Your Appointments'.toUpperCase(),
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
