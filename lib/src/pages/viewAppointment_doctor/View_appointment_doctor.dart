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

class ViewAppointmentDoctor extends StatefulWidget {
  @override
  _ViewAppointmentDoctorState createState() => _ViewAppointmentDoctorState();
}

class _ViewAppointmentDoctorState extends State<ViewAppointmentDoctor> {
  Stream<QuerySnapshot> appointments;
  bool isOnlyWaiting = false;
  DateTime _selectedValue;
  List<bool> isSelected;

  DatePickerController _controllerDate = new DatePickerController();
  String currentDisplayMode = "TODAY";

  final Color _backgroundColor = Color(0xFFf0f0f0);

  final TextStyle titleTextStyle = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 11,
    height: 1,
    letterSpacing: .2,
    fontWeight: FontWeight.w600,
    color: Color(0xffafafaf),
  );
  final TextStyle contentTextStyle = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 16,
    height: 1.8,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

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
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          SizedBox(
              //height: 60,
              child: Center(
                  child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                ToggleButtons(
                  borderColor: Colors.grey[300],
                  disabledColor: Colors.grey[300],
                  fillColor: Colors.orangeAccent,
                  borderWidth: 2,
                  selectedBorderColor: Colors.grey[300],
                  selectedColor: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  children: <Widget>[
                    Container(
                      width: (MediaQuery.of(context).size.width / 3) - 10 - 30,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Today',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width / 3) -
                          10 +
                          30 +
                          30,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Pending prescriptions',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width / 3) - 10 - 30,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Custom',
                          style: TextStyle(fontSize: 16),
                        ),
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
                            DateFormat('yyyy-MM-dd').format(DateTime.now()));
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey[300],
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        (currentDisplayMode == "TODAY")
                            ? 'Today\'s Appointments (${DateFormat('EEEE, dd MMM yyyy').format(DateTime.now())})'
                            : (currentDisplayMode == "PENDING")
                                ? 'Appointments having Pending Prescription'
                                : "View appointment for selected date",
                        style: titleTextStyle.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                )
              ]))),
          (currentDisplayMode == "CUSTOM")
              ? Container(
                  child: getDatePicker(),
                )
              : Container(),
          (currentDisplayMode == "TODAY")
              ? Column(
                  children: <Widget>[
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
                          activeTrackColor: Colors.grey[300],
                          activeColor: Theme.of(context).accentColor,
                        ),
                        Text(
                          "Show only from Virtual OPD Waiting Area",
                          style: titleTextStyle,
                        )
                      ],
                    ),
                  ],
                )
              : Container(),
          Expanded(
            //Expanded is used so that all the widget get fit into the available screen
            child: Container(
              width: double.infinity,
              color: Colors.white,
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
                                          builder: (context) =>
                                              ConsultationRoom(
                                            appointmentNumber: snapshot
                                                .data
                                                .documents[i]
                                                .data["appointmentNumber"],
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildTopContent(
                                        snapshot.data.documents[i])))
                        : Container(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(child: Text("Loading...")),
                            ));
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildTopContent(DocumentSnapshot appt) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[100]),
                      height: 50,
                      width: 50,
                      child: globals.getProfilePic("PATIENT")),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 220,
                              child: Text(
                                appt.data["patientName"].toUpperCase(),
                                style: bodyTextStyle.copyWith(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              child: Text(
                                "${appt.data["patientAge"].toUpperCase()} ${appt.data["patientGender"].toUpperCase()}",
                                style: bodyTextStyle.copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        Text(
                            DateFormat.jm()
                                .format(
                                    appt.data["doctorSlotFromTime"].toDate())
                                .toUpperCase(),
                            style: bodyTextStyle.copyWith(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: getTags(appt),
            ),
            Divider(
              thickness: 2,
            ),
          ],
        ));
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back, color: appBarIconsColor),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
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
        child: Text('Your Appointment'.toUpperCase(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Chip(
          label: new Text(
            chipText,
            style: bodyTextStyle.copyWith(fontSize: 10),
          ),
          backgroundColor: chipColor),
    );
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
    if (currentDisplayMode == "PENDING") {
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
