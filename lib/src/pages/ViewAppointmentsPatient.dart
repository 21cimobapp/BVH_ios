import 'package:civideoconnectapp/src/pages/AppointmentDetails.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'dart:async';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toggle_switch/toggle_switch.dart';

//import 'package:date_picker_timeline/date_picker_timeline.dart';

// class Appointments {
//   final appointmentNumber;
//   final patientCode;
//   final doctorCode;
//   final apptDate;
//   final slotName;
//   final slotNumber;
//   final doctorSlotFromTime;
//   final doctorSlotToTime;
//   final organizationCode;
//   final paymentModeCode;
//   final appointmentType;
//   final doctorName;
//   final doctorDepartment;
//   final patientName;

//   const Appointments(this.appointmentNumber, this.patientCode, this.doctorCode, this.apptDate,
//   this.slotName,this.slotNumber,this.doctorSlotFromTime, this.doctorSlotToTime,this.organizationCode,this.paymentModeCode,
//   this.appointmentType,this.doctorName,this.patientName,this.doctorDepartment);
// }

class ViewAppointmentsPatient extends StatefulWidget {
  @override
  _ViewAppointmentsPatientState createState() =>
      _ViewAppointmentsPatientState();
}

class _ViewAppointmentsPatientState extends State<ViewAppointmentsPatient>
    with SingleTickerProviderStateMixin {
  //List<AppointmentDetails> apptList1 = List<AppointmentDetails>();
  //List<AppointmentDetails> apptList2 = List<AppointmentDetails>();
  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  //    new GlobalKey<RefreshIndicatorState>();

  Stream<QuerySnapshot> appointments;

  List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    //getAppointments1("UPCOMMING");
    //getAppointments1("COMPLETED");
    isSelected = [true, false];

    DatabaseMethods().getPatientAppointments(globals.personCode).then((val) {
      setState(() {
        appointments = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "My Appointments",
          ),
          actions: <Widget>[],
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: new Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            SizedBox(
                height: 60,
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                      ToggleButtons(
                        borderColor: Colors.grey[200],
                        fillColor: Theme.of(context).accentColor,
                        borderWidth: 2,
                        selectedBorderColor: Colors.grey[200],
                        selectedColor: Colors.white,
                        borderRadius: BorderRadius.circular(0),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Current Appointments',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Past Appointments',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = i == index;
                            }
                          });
                          if (index == 0) {
                            DatabaseMethods()
                                .getPatientAppointments(globals.personCode)
                                .then((val) {
                              setState(() {
                                appointments = val;
                              });
                            });
                          } else {
                            DatabaseMethods()
                                .getPatientAppointmentsPast(globals.personCode)
                                .then((val) {
                              setState(() {
                                appointments = val;
                              });
                            });
                          }
                        },
                        isSelected: isSelected,
                      ),
                    ]))),
            SizedBox(
              height: 10,
            ),
            Expanded(
              //Expanded is used so that all the widget get fit into the available screen
              child: StreamBuilder(
                  stream: appointments,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (BuildContext context, int i) =>
                                GestureDetector(
                                  onTap: () {
                                    // if (tab.text.toUpperCase() == "UPCOMMING") {
                                    //   _settingModalBottomSheet(i, context);
                                    // }
                                    //AppointmentDetails appList;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AppointmentScreen(
                                          appointmentNumber: snapshot
                                              .data
                                              .documents[i]
                                              .data["appointmentNumber"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    color: Theme.of(context)
                                                        .accentColor),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      getApptDateFormat(
                                                          snapshot
                                                              .data
                                                              .documents[i]
                                                              .data["apptDate"],
                                                          "dd"),
                                                      style: TextStyle(
                                                          color: globals
                                                              .appTextColor,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    Text(
                                                      getApptDateFormat(
                                                          snapshot
                                                              .data
                                                              .documents[i]
                                                              .data["apptDate"],
                                                          "MMM"),
                                                      style: TextStyle(
                                                          color: globals
                                                              .appTextColor,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    width: 200,
                                                    child: Text(
                                                      snapshot.data.documents[i]
                                                              .data[
                                                          "appointmentNumber"],
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 230,
                                                    child: Text(
                                                      snapshot.data.documents[i]
                                                          .data["doctorName"],
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data.documents[i]
                                                        .data["departmentName"],
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200,
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data.documents[i]
                                                        .data["slotName"],
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                              MyCircleAvatar(
                                                  imgUrl: "",
                                                  personType: "DOCTOR"),
                                            ],
                                          ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            child: new Wrap(
                                              spacing: 5.0,
                                              children: getTags(
                                                  snapshot.data.documents[i]),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                color: Colors.blueGrey[100]),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 30,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                    "CheckIn Time: ${getApptDateFormat(snapshot.data.documents[i].data["INCONSULTDateTime"], "HH:mm")}",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black)),
                                                Text(
                                                    "CheckOut Time: ${getApptDateFormat(snapshot.data.documents[i].data["DONEDateTime"], "HH:mm")}",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black)),
                                                Text(
                                                    "Wait Time: ${getApptWaitTime(snapshot.data.documents[i].data["WAITINGDateTime"], snapshot.data.documents[i].data["INCONSULTDateTime"], snapshot.data.documents[i].data["DONEDateTime"])}",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                        : Container(
                            child: Text("Loading data..."),
                          );
                  }),
            )
          ],
        ));
  }

  getTags(DocumentSnapshot appt) {
    List<Widget> tags = [];

    bool apptNoShow = checkIfConsultationExpired(
        appt.data["apptDate"], appt.data["appointmentStatus"]);

    if (appt.data["appointmentType"] == 'VIDEOCONSULT')
      tags.add(getChip("Video Consultation", Colors.indigoAccent));
    else if (appt.data["appointmentType"] == 'VISITCONSULT')
      tags.add(getChip("Personal Visit", Colors.blueAccent));

    if (appt.data["appointmentStatus"] == 'CANCELLED')
      tags.add(getChip("Cancelled", Colors.redAccent));
    else if (appt.data["appointmentStatus"] == 'WAITING' && apptNoShow == false)
      tags.add(getChip("Waiting", Colors.amberAccent));
    else if (appt.data["appointmentStatus"] == 'INCONSULT')
      tags.add(getChip("In Consultation", Colors.greenAccent));
    else if (appt.data["appointmentStatus"] == 'DONE')
      tags.add(getChip("Completed", Colors.green));

    if (apptNoShow == true) tags.add(getChip("No Show", Colors.redAccent));

    if (appt.data["paymentModeCode"] == "HCALLPAYCOD")
      tags.add(getChip("Cash Payment", Colors.pinkAccent));
    else
      tags.add(getChip("Online Payment", Colors.pinkAccent));
    return tags;
  }

  getChip(String chipText, Color chipColor) {
    return Chip(
        label: new Text(
          chipText,
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: chipColor);
  }

  checkIfConsultationExpired(Timestamp tDate, String appointmentStatus) {
    DateTime currentDate =
        DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());

    if (tDate.toDate().difference(currentDate).inDays < 0) {
      if (appointmentStatus != "DONE" && appointmentStatus != "CANCELLED") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  String getApptDateFormat(apptDate, type) {
    if (apptDate == null)
      return "-";
    else
      return DateFormat(type).format(apptDate.toDate());
  }

  String getApptWaitTime(WAITINGDateTime, INCONSULTDateTime, DONEDateTime) {
    if (DONEDateTime != null &&
        INCONSULTDateTime != null &&
        DONEDateTime != null) {
      var format = DateFormat("HH:mm");
      var date1 = format.parse("10:40");
      var date2 = format.parse("18:20");
      Duration diff = date2.difference(date1);

      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(diff.inMinutes.remainder(60));

      return "${twoDigits(diff.inHours)}:$twoDigitMinutes";
    } else {
      return "-";
    }
  }
}
