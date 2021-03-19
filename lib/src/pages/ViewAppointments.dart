import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:civideoconnectapp/src/pages/ConsultationRoom.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:civideoconnectapp/src/pages/ChatPage.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:civideoconnectapp/utils/widgets.dart';

class ViewAppointments extends StatefulWidget {
  @override
  _ViewAppointmentsState createState() => _ViewAppointmentsState();
}

class _ViewAppointmentsState extends State<ViewAppointments> {
  Stream<QuerySnapshot> appointments;
  bool isOnlyWaiting = false;
  DateTime _selectedValue;
  List<bool> isSelected;

  DatePickerController _controllerDate = new DatePickerController();
  String currentDisplayMode = "TODAY";
  @override
  void initState() {
    super.initState();
    isSelected = [true, false, false];
    isOnlyWaiting = true;
    _selectedValue =
        DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.now()));
    getAppointments1(_selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Appointments",
          style: Theme.of(context).textTheme.headline5.apply(
                color: globals.appTextColor,
                //fontWeightDelta: 2,
              ),
        ),
        actions: <Widget>[],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
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
                            'Today',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Pending prescriptions',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Custom',
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
                          setState(() {
                            _selectedValue = DateTime.parse(
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()));
                            // _controllerDate.animateToDate(_selectedValue);
                            currentDisplayMode = "TODAY";
                          });
                          getAppointments1(_selectedValue);
                        } else if (index == 1) {
                          setState(() {
                            currentDisplayMode = "PENDING";
                          });
                          getAppointmentsPending();
                        } else {
                          setState(() {
                            currentDisplayMode = "CUSTOM";
                          });
                          getAppointments1(_selectedValue);
                        }
                      },
                      isSelected: isSelected,
                    ),
                  ]))),
          (currentDisplayMode == "CUSTOM")
              ? Container(
                  child: getDatePicker(),
                )
              : Container(),
          (currentDisplayMode == "TODAY")
              ? Column(
                  children: <Widget>[
                    Text(
                      'Today\'s Appointments (${DateFormat('EEEE, dd MMM yyyy').format(DateTime.now())})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: <Widget>[
                        Switch(
                          value: isOnlyWaiting,
                          onChanged: (value) {
                            setState(() {
                              isOnlyWaiting = value;
                            });
                            getAppointments1(_selectedValue);
                          },
                          activeTrackColor: Colors.grey[200],
                          activeColor: Theme.of(context).accentColor,
                        ),
                        Text(
                          "Show only from Virtual OPD Waiting Area",
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                  ],
                )
              : (currentDisplayMode == "PENDING")
                  ? Column(
                      children: <Widget>[
                        Text(
                          'Appointments having Pending Prescription)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Container(),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConsultationRoom(
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
                                      top: 10, bottom: 10, left: 10, right: 10),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
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
                                                          Radius.circular(10)),
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
                                                        //color: dateColor,
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
                                                        //color: dateColor,
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
                                                  width: 100,
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
                                                        .data["patientName"],
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
                                                  "${snapshot.data.documents[i].data["patientAge"]} ${snapshot.data.documents[i].data["patientGender"]}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w200,
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
                                                // Align(
                                                //   alignment: Alignment.centerRight +
                                                //       Alignment(0, .8),
                                                //   child: Container(
                                                //     decoration: BoxDecoration(
                                                //       border: Border.all(
                                                //           color: Theme.of(context).primaryColor),
                                                //       borderRadius:
                                                //           BorderRadius.circular(15.0),
                                                //     ),
                                                //     child: Padding(
                                                //       padding: EdgeInsets.all(5.0),
                                                //       child: Text(
                                                //         "Expired",
                                                //         style: TextStyle(
                                                //             color: Theme.of(context).primaryColor),
                                                //       ),
                                                //     ),
                                                //   ),
                                                // )
                                              ],
                                            ),
                                            MyCircleAvatar(
                                                imgUrl: "",
                                                personType: "PATIENT"),
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
                                          width:
                                              MediaQuery.of(context).size.width,
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
                      : Container(child: Text("Loading..."));
                }),
          ),
        ],
      ),
    );
  }

  Widget getDatePicker() {
    return DatePicker(
      DateTime.now().add(new Duration(days: -3)),
      width: 60,
      height: 100,
      controller: _controllerDate,
      initialSelectedDate: _selectedValue,
      selectionColor: Theme.of(context).accentColor,
      selectedTextColor: Colors.white,
      onDateChange: (date) {
        // New date selected

        setState(() {
          _selectedValue = date;
        });

        getAppointments1(date);
      },
    );
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

  getAppointments1(DateTime date) async {
    if (currentDisplayMode == "TODAY" &&
        isOnlyWaiting == true &&
        (_selectedValue.difference(DateTime.now()).inDays == 0)) {
      DatabaseMethods()
          .getDoctorAppointmentsWaitingOnly(globals.personCode, date)
          .then((val) {
        setState(() {
          appointments = val;
        });
      });
    } else {
      DatabaseMethods()
          .getDoctorAppointments(globals.personCode, date)
          .then((val) {
        setState(() {
          appointments = val;
        });
      });
    }
  }

  getAppointmentsPending() async {
    if (currentDisplayMode == "TODAY" &&
        isOnlyWaiting == true &&
        (_selectedValue.difference(DateTime.now()).inDays == 0)) {
      DatabaseMethods()
          .getDoctorAppointmentsPending(
        globals.personCode,
      )
          .then((val) {
        setState(() {
          appointments = val;
        });
      });
    }
  }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }

  // Future<List<AppointmentDetails>> getAppointments(date) async {
  //   List<AppointmentDetails> a = List<AppointmentDetails>();
  //   var phoneNumber = _getUserData("MobileNumber");

  //   print("getAppointments()");
  //   String url;

  //   url = "${globals.apiHostingURL}/Doctors/mapp_ViewAppointment";

  //   return await http.post(Uri.encodeFull(url), body: {
  //     "token": "$phoneNumber",
  //     "DataType": "SUMMARY1",
  //     "AppointmentDate": "$date",
  //     "ReferenceNumber": "1"
  //   }, headers: {
  //     "Accept": "application/json"
  //   }).then((http.Response response) {
  //     //      print(response.body);
  //     final int statusCode = response.statusCode;
  //     if (statusCode == 200) {
  //       var notesJson = json.decode(response.body);
  //       //  ImageData = base64.encode(response.bodyBytes);
  //       for (var notejson in notesJson) {
  //         a.add(AppointmentDetails.fromJson(notejson));
  //       }
  //       return a;
  //       // if (p.status == 1) {
  //       //   gloabals.loginUser=p;
  //       // } else {
  //       //   return null;
  //       // }
  //     } else {
  //       return null;
  //     }
  //   });
  // }

  // String _loginUserType() {
  //   if (globals.loginUserType != null) {
  //     return globals.loginUserType;
  //   } else
  //     return '';
  // }

  // joinCall(appList) async {
  //   onJoin(appList).then((value) => null);
  // }

  // joinChat(AppointmentDetails appList) async {
  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ChatPage(
  //         peerCode: appList.PatientCode,
  //         peerName: appList.PatientName,
  //       ),
  //     ),
  //   );
  // }

  // Future<void> onJoin(appList) async {
  //   // update input validation
  //   setState(() {});

  //   // await for camera and mic permissions before pushing video page
  //   await _handleCameraAndMic();
  //   // push video page with given channel name
  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ConsultationRoom(
  //         appt: appList,
  //       ),
  //     ),
  //   );
  // }

  // Future<void> _handleCameraAndMic() async {
  //   await PermissionHandler().requestPermissions(
  //     [PermissionGroup.camera, PermissionGroup.microphone],
  //   );
  //}
}
