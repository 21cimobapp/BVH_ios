// import 'package:civideoconnectapp/src/pages/AppointmentDetails.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:civideoconnectapp/src/pages/VirtualOPDArea.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:civideoconnectapp/globals.dart' as globals;
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:civideoconnectapp/src/pages/ViewDocuments.dart';
// import 'package:civideoconnectapp/src/pages/ChatPage.dart';
// import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
// import 'package:flutter/foundation.dart';
// import 'package:civideoconnectapp/utils/widgets.dart';

// //import 'package:date_picker_timeline/date_picker_timeline.dart';

// class ViewAppointmentsPatient extends StatefulWidget {
//   @override
//   _ViewAppointmentsPatientState createState() =>
//       _ViewAppointmentsPatientState();
// }

// class _ViewAppointmentsPatientState extends State<ViewAppointmentsPatient>
//     with SingleTickerProviderStateMixin {
//   List<AppointmentDetails> apptList1 = List<AppointmentDetails>();
//   List<AppointmentDetails> apptList2 = List<AppointmentDetails>();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       new GlobalKey<RefreshIndicatorState>();
//   TabController _tabController;

//   final List<Tab> tabs = <Tab>[
//     new Tab(
//       text: "Upcomming",
//     ),
//     new Tab(text: "Completed")
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = new TabController(vsync: this, length: tabs.length);
//     getAppointments1("UPCOMMING");
//     getAppointments1("COMPLETED");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             "My Appointments",
//           ),
//           bottom: new TabBar(
//             isScrollable: true,
//             unselectedLabelColor: Colors.white54,
//             labelColor: Colors.white,
//             indicatorSize: TabBarIndicatorSize.tab,
//             indicator: new BubbleTabIndicator(
//               indicatorHeight: 25.0,
//               indicatorColor: Theme.of(context).accentColor,
//               tabBarIndicatorSize: TabBarIndicatorSize.tab,
//             ),
//             tabs: tabs,
//             controller: _tabController,
//           ),
//           actions: <Widget>[],
//           backgroundColor: Theme.of(context).primaryColor,
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: tabs.map((Tab tab) {
//             return new Column(
//               children: <Widget>[
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                     alignment: Alignment.topLeft,
//                     child: Text("   ${tab.text} Appointments",
//                         style: TextStyle(
//                             //color: dateColor,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800))),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Expanded(
//                   //Expanded is used so that all the widget get fit into the available screen
//                   child: ListView.builder(
//                       itemCount: (tab.text.toUpperCase() == "UPCOMMING")
//                           ? apptList1?.length
//                           : apptList2?.length,
//                       itemBuilder: (BuildContext context, int i) =>
//                           GestureDetector(
//                             onTap: () {
//                               // if (tab.text.toUpperCase() == "UPCOMMING") {
//                               //   _settingModalBottomSheet(i, context);
//                               // }
//                               AppointmentDetails appList;

//                               appList = (tab.text.toUpperCase() == "UPCOMMING")
//                                   ? apptList1[i]
//                                   : apptList2[i];

//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => AppointmentScreen(
//                                     appt: appList,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               margin: EdgeInsets.only(
//                                   top: 10, bottom: 10, left: 10, right: 10),
//                               width: MediaQuery.of(context).size.width,
//                               decoration: BoxDecoration(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(20)),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.5),
//                                       spreadRadius: 5,
//                                       blurRadius: 7,
//                                       offset: Offset(
//                                           0, 3), // changes position of shadow
//                                     ),
//                                   ],
//                                   color: Colors.white),
//                               child: Container(
//                                 padding: EdgeInsets.all(5),
//                                 child: Column(
//                                   children: <Widget>[
//                                     Row(
//                                       children: <Widget>[
//                                         Container(
//                                           width: 70,
//                                           height: 70,
//                                           decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(10)),
//                                               color: Theme.of(context)
//                                                   .accentColor),
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               Text(
//                                                 getApptDateFormat(
//                                                     tab.text.toUpperCase(),
//                                                     i,
//                                                     "dd"),
//                                                 style: TextStyle(
//                                                     color: globals.appTextColor,
//                                                     fontSize: 30,
//                                                     fontWeight:
//                                                         FontWeight.w800),
//                                               ),
//                                               Text(
//                                                 getApptDateFormat(
//                                                     tab.text.toUpperCase(),
//                                                     i,
//                                                     "MMM"),
//                                                 style: TextStyle(
//                                                     color: globals.appTextColor,
//                                                     fontSize: 20,
//                                                     fontWeight:
//                                                         FontWeight.w800),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Container(
//                                               width: 250,
//                                               child: Text(
//                                                 "${getApptTitle(tab.text.toUpperCase(), i)}",
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.w800,
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                                 softWrap: false,
//                                               ),
//                                             ),
//                                             Text(
//                                               "${getApptTitle2(tab.text.toUpperCase(), i)}",
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.w200,
//                                               ),
//                                             ),
//                                             Text(
//                                               "${getApptTime(tab.text.toUpperCase(), i)}",
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                             // Align(
//                                             //   alignment: Alignment.centerRight +
//                                             //       Alignment(0, .8),
//                                             //   child: Container(
//                                             //     decoration: BoxDecoration(
//                                             //       border: Border.all(
//                                             //           color: Theme.of(context).primaryColor),
//                                             //       borderRadius:
//                                             //           BorderRadius.circular(15.0),
//                                             //     ),
//                                             //     child: Padding(
//                                             //       padding: EdgeInsets.all(5.0),
//                                             //       child: Text(
//                                             //         "Expired",
//                                             //         style: TextStyle(
//                                             //             color: Theme.of(context).primaryColor),
//                                             //       ),
//                                             //     ),
//                                             //   ),
//                                             // )
//                                           ],
//                                         ),
//                                         MyCircleAvatar(
//                                             imgUrl: "", personType: "DOCTOR"),
//                                       ],
//                                     ),
//                                     // Container(
//                                     //     height: 50,
//                                     //     child: Row(
//                                     //       //mainAxisSize: MainAxisSize.min,
//                                     //       mainAxisAlignment:
//                                     //           MainAxisAlignment.spaceBetween,
//                                     //       children: <Widget>[
//                                     //         RaisedButton.icon(
//                                     //           onPressed: () {
//                                     //             //print('Button Clicked.');
//                                     //             _settingModalBottomSheet(context);
//                                     //           },
//                                     //           shape: RoundedRectangleBorder(
//                                     //               borderRadius: BorderRadius.all(
//                                     //                   Radius.circular(10.0))),
//                                     //           label: Text(
//                                     //             'Video Call',
//                                     //             style: TextStyle(
//                                     //                 color: Colors.white),
//                                     //           ),
//                                     //           icon: Icon(
//                                     //             Icons.video_call,
//                                     //             color: Colors.white,
//                                     //           ),
//                                     //           textColor: Colors.white,
//                                     //           splashColor: Colors.red,
//                                     //           color: Colors.green,
//                                     //         ),
//                                     //         RaisedButton.icon(
//                                     //           onPressed: () {
//                                     //             print('Button Clicked.');
//                                     //           },
//                                     //           shape: RoundedRectangleBorder(
//                                     //               borderRadius: BorderRadius.all(
//                                     //                   Radius.circular(10.0))),
//                                     //           label: Text(
//                                     //             'Chat',
//                                     //             style: TextStyle(
//                                     //                 color: Colors.white),
//                                     //           ),
//                                     //           icon: Icon(
//                                     //             Icons.chat,
//                                     //             color: Colors.white,
//                                     //           ),
//                                     //           textColor: Colors.white,
//                                     //           splashColor: Colors.red,
//                                     //           color: Colors.green,
//                                     //         ),
//                                     //         RaisedButton.icon(
//                                     //           onPressed: () {
//                                     //             print('Button Clicked.');
//                                     //           },
//                                     //           shape: RoundedRectangleBorder(
//                                     //               borderRadius: BorderRadius.all(
//                                     //                   Radius.circular(10.0))),
//                                     //           label: Text(
//                                     //             'Documents',
//                                     //             style: TextStyle(
//                                     //                 color: Colors.white),
//                                     //           ),
//                                     //           icon: Icon(
//                                     //             Icons.attachment,
//                                     //             color: Colors.white,
//                                     //           ),
//                                     //           textColor: Colors.white,
//                                     //           splashColor: Colors.red,
//                                     //           color: Colors.green,
//                                     //         ),
//                                     //       ],
//                                     //     ))
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )),
//                 )
//               ],
//             );
//           }).toList(),
//         ));
//   }

//   void _settingModalBottomSheet(i, context) {
//     List<AppointmentDetails> apptList = List<AppointmentDetails>();

//     //(tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;
//     apptList = apptList1;
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
//                     title: Text("Start call"),
//                   ),
//                   new ListTile(
//                     onTap: () {
//                       Navigator.pop(context);
//                       joinChat(apptList[i]);
//                     },
//                     leading: new Icon(
//                       Icons.chat,
//                     ),
//                     title: Text("Chat with Doctor"),
//                   ),
//                   new ListTile(
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 ViewDocuments(patientCode: globals.personCode),
//                           ));
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

//   String getApptTitle(tab, i) {
//     List<AppointmentDetails> apptList = List<AppointmentDetails>();

//     (tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;

//     if (globals.loginUserType == "DOCTOR") {
//       return apptList[i].PatientName;
//     } else {
//       return apptList[i].DoctorName;
//     }
//   }

//   String getApptTitle2(tab, i) {
//     List<AppointmentDetails> apptList = List<AppointmentDetails>();

//     (tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;

//     if (globals.loginUserType == "PATIENT") {
//       return apptList[i].DepartmentName;
//     } else {
//       return "";
//     }
//   }

//   String getApptDateFormat(tab, i, type) {
//     List<AppointmentDetails> apptList = List<AppointmentDetails>();

//     (tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;

//     return DateFormat(type).format(apptList[i].PortalAppointmentDateTime);
//   }

//   String getApptTime(tab, i) {
//     List<AppointmentDetails> apptList = List<AppointmentDetails>();

//     (tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;

//     return apptList[i].SlotName;
//   }

//   Image getDoctorPhoto(tab, i) {
//     List<AppointmentDetails> apptList = List<AppointmentDetails>();

//     (tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;

//     if (apptList[i].DoctorPhoto == "") {
//       return Image.asset("assets/doctor_defaultpic.png");
//     } else {
//       return Image.memory(base64Decode(apptList[i].DoctorPhoto));
//     }
//   }

//   Image getPatientPhoto(tab, i) {
//     List<AppointmentDetails> apptList = List<AppointmentDetails>();

//     (tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;

//     if (apptList[i].DoctorPhoto == "") {
//       return Image.asset("assets/patient_defaultpic.png");
//     } else {
//       return Image.memory(base64Decode(apptList[i].DoctorPhoto));
//     }
//   }

//   getAppointments1(appointmentType) async {
//     if (appointmentType.toString().toUpperCase() == "UPCOMMING") {
//       await getAppointments(appointmentType).then((value) => apptList1 = value);

//       setState(() {
//         apptList1 = apptList1;
//       });
//     } else {
//       await getAppointments(appointmentType).then((value) => apptList2 = value);

//       setState(() {
//         apptList2 = apptList2;
//       });
//     }
//   }

//   String _getUserData(type) {
//     if (globals.user != null) {
//       return globals.user[0][type];
//     } else
//       return '';
//   }

//   Future<List<AppointmentDetails>> getAppointments(appointmentType) async {
//     List<AppointmentDetails> a = List<AppointmentDetails>();
//     var phoneNumber = _getUserData("MobileNumber");

//     print("getAppointments()");
//     String url;
//     var body;

//     url = "${globals.apiHostingURL}/Patient/mapp_ViewAppointment";
//     body = {
//       "token": "$phoneNumber",
//       "DataType": "SUMMARY1",
//       "AppointmentsToShow": "${appointmentType.toString().toUpperCase()}",
//       "ReferenceNumber": "1"
//     };

//     return await http.post(Uri.encodeFull(url),
//         body: body,
//         headers: {"Accept": "application/json"}).then((http.Response response) {
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
//           peerCode: appList.DoctorCode,
//           peerName: appList.DoctorName,
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
//         builder: (context) => VirtualOPDArea(
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
