// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:civideoconnectapp/src/pages/ConsultationRoom.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:civideoconnectapp/globals.dart' as globals;
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:civideoconnectapp/src/pages/ViewDocuments.dart';
// import 'package:civideoconnectapp/src/pages/ChatPage.dart';
// import 'package:date_picker_timeline/date_picker_timeline.dart';
// import 'package:civideoconnectapp/utils/widgets.dart';

// class ViewAppointments extends StatefulWidget {
//   @override
//   _ViewAppointmentsState createState() => _ViewAppointmentsState();
// }

// class _ViewAppointmentsState extends State<ViewAppointments> {
//   List<AppointmentDetails> apptList = List<AppointmentDetails>();
//   DateTime _selectedValue;
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       new GlobalKey<RefreshIndicatorState>();

//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = DateTime.now();
//     getAppointments1(_selectedValue);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "My Appointments",
//           style: Theme.of(context).textTheme.headline5.apply(
//                 color: globals.appTextColor,
//                 //fontWeightDelta: 2,
//               ),
//         ),
//         actions: <Widget>[],
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Column(
//         children: <Widget>[
//           SizedBox(
//             height: 20,
//           ),
//           Container(
//             child: DatePicker(
//               DateTime.now().add(new Duration(days: -3)),
//               width: 60,
//               height: 100,
//               //controller: _controller,
//               initialSelectedDate: DateTime.now(),
//               selectionColor: Theme.of(context).accentColor,
//               selectedTextColor: Colors.white,

//               onDateChange: (date) {
//                 // New date selected
//                 getAppointments1(date);
//                 setState(() {
//                   _selectedValue = date;
//                 });
//               },
//             ),
//           ),
//           SizedBox(
//             height: 30,
//           ),
//           Expanded(
//             //Expanded is used so that all the widget get fit into the available screen
//             child: ListView.builder(
//                 itemCount: apptList?.length,
//                 itemBuilder: (BuildContext context, int i) => GestureDetector(
//                       onTap: () {
//                         _settingModalBottomSheet(i, context);
//                       },
//                       child: Container(
//                         margin: EdgeInsets.only(
//                             top: 10, bottom: 10, left: 10, right: 10),
//                         width: MediaQuery.of(context).size.width,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.all(Radius.circular(20)),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5),
//                                 spreadRadius: 5,
//                                 blurRadius: 7,
//                                 offset:
//                                     Offset(0, 3), // changes position of shadow
//                               ),
//                             ],
//                             color: Colors.white),
//                         child: Container(
//                           padding: EdgeInsets.all(5),
//                           child: Column(
//                             children: <Widget>[
//                               Row(
//                                 children: <Widget>[
//                                   Container(
//                                     width: 70,
//                                     height: 70,
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(10)),
//                                         color: Theme.of(context).accentColor),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: <Widget>[
//                                         Text(
//                                           getApptDateFormat(i, "dd"),
//                                           style: TextStyle(
//                                               //color: dateColor,
//                                               fontSize: 30,
//                                               fontWeight: FontWeight.w800),
//                                         ),
//                                         Text(
//                                           getApptDateFormat(i, "MMM"),
//                                           style: TextStyle(
//                                               //color: dateColor,
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.w800),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Container(
//                                         width: 250,
//                                         child: Text(
//                                           "${getApptTitle(i)}",
//                                           style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                           softWrap: false,
//                                         ),
//                                       ),
//                                       Text(
//                                         "${getApptTitle2(i)}",
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.w200,
//                                         ),
//                                       ),
//                                       Text(
//                                         "${getApptTime(i)}",
//                                         style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                       // Align(
//                                       //   alignment: Alignment.centerRight +
//                                       //       Alignment(0, .8),
//                                       //   child: Container(
//                                       //     decoration: BoxDecoration(
//                                       //       border: Border.all(
//                                       //           color: Theme.of(context).primaryColor),
//                                       //       borderRadius:
//                                       //           BorderRadius.circular(15.0),
//                                       //     ),
//                                       //     child: Padding(
//                                       //       padding: EdgeInsets.all(5.0),
//                                       //       child: Text(
//                                       //         "Expired",
//                                       //         style: TextStyle(
//                                       //             color: Theme.of(context).primaryColor),
//                                       //       ),
//                                       //     ),
//                                       //   ),
//                                       // )
//                                     ],
//                                   ),
//                                   MyCircleAvatar(
//                                       imgUrl: "", personType: "PATIENT"),
//                                 ],
//                               ),
//                               // Container(
//                               //     height: 50,
//                               //     child: Row(
//                               //       //mainAxisSize: MainAxisSize.min,
//                               //       mainAxisAlignment:
//                               //           MainAxisAlignment.spaceBetween,
//                               //       children: <Widget>[
//                               //         RaisedButton.icon(
//                               //           onPressed: () {
//                               //             //print('Button Clicked.');
//                               //             _settingModalBottomSheet(context);
//                               //           },
//                               //           shape: RoundedRectangleBorder(
//                               //               borderRadius: BorderRadius.all(
//                               //                   Radius.circular(10.0))),
//                               //           label: Text(
//                               //             'Video Call',
//                               //             style: TextStyle(
//                               //                 color: Colors.white),
//                               //           ),
//                               //           icon: Icon(
//                               //             Icons.video_call,
//                               //             color: Colors.white,
//                               //           ),
//                               //           textColor: Colors.white,
//                               //           splashColor: Colors.red,
//                               //           color: Colors.green,
//                               //         ),
//                               //         RaisedButton.icon(
//                               //           onPressed: () {
//                               //             print('Button Clicked.');
//                               //           },
//                               //           shape: RoundedRectangleBorder(
//                               //               borderRadius: BorderRadius.all(
//                               //                   Radius.circular(10.0))),
//                               //           label: Text(
//                               //             'Chat',
//                               //             style: TextStyle(
//                               //                 color: Colors.white),
//                               //           ),
//                               //           icon: Icon(
//                               //             Icons.chat,
//                               //             color: Colors.white,
//                               //           ),
//                               //           textColor: Colors.white,
//                               //           splashColor: Colors.red,
//                               //           color: Colors.green,
//                               //         ),
//                               //         RaisedButton.icon(
//                               //           onPressed: () {
//                               //             print('Button Clicked.');
//                               //           },
//                               //           shape: RoundedRectangleBorder(
//                               //               borderRadius: BorderRadius.all(
//                               //                   Radius.circular(10.0))),
//                               //           label: Text(
//                               //             'Documents',
//                               //             style: TextStyle(
//                               //                 color: Colors.white),
//                               //           ),
//                               //           icon: Icon(
//                               //             Icons.attachment,
//                               //             color: Colors.white,
//                               //           ),
//                               //           textColor: Colors.white,
//                               //           splashColor: Colors.red,
//                               //           color: Colors.green,
//                               //         ),
//                               //       ],
//                               //     ))
//                             ],
//                           ),
//                         ),
//                       ),
//                     )),
//           ),
//           Expanded(
//             child:
//                 Text(globals.msgRTM == null ? "" : globals.msgRTM.split("|")[0],
//                     style: Theme.of(context).textTheme.headline5.apply(
//                           color: Color(0xff0b1666),
//                           fontWeightDelta: 2,
//                         )),
//           )
//         ],
//       ),
//     );
//   }

//   void _settingModalBottomSheet(i, context) {
//     //(tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext bc) {
//           return new Container(
//             color: Colors.transparent,
//             //could change this to Color(0xFF737373),
//             //so you don't have to change MaterialApp canvasColor
//             child: new Container(
//               decoration: new BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: new BorderRadius.only(
//                       topLeft: const Radius.circular(20.0),
//                       topRight: const Radius.circular(20.0))),
//               child: new Wrap(
//                 children: <Widget>[
//                   new ListTile(
//                     onTap: () {
//                       Navigator.pop(context);
//                       joinCall(apptList[i]);
//                     },
//                     leading: new Icon(
//                       Icons.video_call,
//                     ),
//                     title: Text("Start Video call"),
//                   ),
//                   new ListTile(
//                     onTap: () {
//                       Navigator.pop(context);
//                       joinChat(apptList[i]);
//                     },
//                     leading: new Icon(
//                       Icons.chat,
//                     ),
//                     title: Text("Chat with Patient"),
//                   ),
//                   new ListTile(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     leading: new Icon(Icons.attachment),
//                     title: Text("Attach Documents"),
//                   )
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   String getApptDateFormat(i, type) {
//     return DateFormat(type).format(apptList[i].PortalAppointmentDateTime);
//   }

//   String getApptTitle(i) {
//     if (globals.loginUserType == "DOCTOR") {
//       return apptList[i].PatientName;
//     } else {
//       return apptList[i].DoctorName;
//     }
//   }

//   String getApptTitle2(i) {
//     return "${apptList[i].PatientAge} ${apptList[i].PatientGender}";
//   }

//   String getApptTime(i) {
//     return DateFormat('dd MMM yyyy')
//             .format(apptList[i].PortalAppointmentDateTime) +
//         ' ' +
//         apptList[i].SlotName;
//   }

//   Image getDoctorPhoto(i) {
//     if (apptList[i].DoctorPhoto == "") {
//       return Image.asset("assets/doctor_defaultpic.png");
//     } else {
//       return Image.memory(base64Decode(apptList[i].DoctorPhoto));
//     }
//   }

//   Image getPatientPhoto(i) {
//     if (apptList[i].DoctorPhoto == "") {
//       return Image.asset("assets/patient_defaultpic.png");
//     } else {
//       return Image.memory(base64Decode(apptList[i].DoctorPhoto));
//     }
//   }

//   getAppointments1(date) async {
//     print(apptList);
//     await getAppointments(date).then((value) => apptList = value);

//     setState(() {
//       apptList = apptList;
//     });
//   }

//   String _getUserData(type) {
//     if (globals.user != null) {
//       return globals.user[0][type];
//     } else
//       return '';
//   }

//   Future<List<AppointmentDetails>> getAppointments(date) async {
//     List<AppointmentDetails> a = List<AppointmentDetails>();
//     var phoneNumber = _getUserData("MobileNumber");

//     print("getAppointments()");
//     String url;

//     url = "${globals.apiHostingURL}/Doctors/mapp_ViewAppointment";

//     return await http.post(Uri.encodeFull(url), body: {
//       "token": "$phoneNumber",
//       "DataType": "SUMMARY1",
//       "AppointmentDate": "$date",
//       "ReferenceNumber": "1"
//     }, headers: {
//       "Accept": "application/json"
//     }).then((http.Response response) {
//       //      print(response.body);
//       final int statusCode = response.statusCode;
//       if (statusCode == 200) {
//         var notesJson = json.decode(response.body);
//         //  ImageData = base64.encode(response.bodyBytes);
//         for (var notejson in notesJson) {
//           a.add(AppointmentDetails.fromJson(notejson));
//         }
//         return a;
//         // if (p.status == 1) {
//         //   gloabals.loginUser=p;
//         // } else {
//         //   return null;
//         // }
//       } else {
//         return null;
//       }
//     });
//   }

//   String _loginUserType() {
//     if (globals.loginUserType != null) {
//       return globals.loginUserType;
//     } else
//       return '';
//   }

//   joinCall(appList) async {
//     onJoin(appList).then((value) => null);
//   }

//   joinChat(AppointmentDetails appList) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatPage(
//           peerCode: appList.PatientCode,
//           peerName: appList.PatientName,
//         ),
//       ),
//     );
//   }

//   Future<void> onJoin(appList) async {
//     // update input validation
//     setState(() {});

//     // await for camera and mic permissions before pushing video page
//     await _handleCameraAndMic();
//     // push video page with given channel name
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ConsultationRoom(
//           appt: appList,
//         ),
//       ),
//     );
//   }

//   Future<void> _handleCameraAndMic() async {
//     await PermissionHandler().requestPermissions(
//       [PermissionGroup.camera, PermissionGroup.microphone],
//     );
//   }
// }
