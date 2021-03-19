// import 'dart:async';
// import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
// import 'package:civideoconnectapp/src/pages/ChatPage.dart';
// import 'package:civideoconnectapp/src/pages/VirtualOPDArea.dart';
// import 'package:civideoconnectapp/utils/mycircleavatar.dart';
// //import 'package:civideoconnectapp/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:wakelock/wakelock.dart';
// import 'package:civideoconnectapp/globals.dart' as globals;
// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'dart:convert';

// //import 'package:carousel_slider/carousel_slider.dart';

// class AppointmentScreen extends StatefulWidget {
//   /// non-modifiable channel name of the page
//   //final int userID;
//   final AppointmentDetails appt;

//   /// Creates a call page with given channel name.
//   const AppointmentScreen({Key key, this.appt}) : super(key: key);

//   @override
//   _AppointmentScreenState createState() => _AppointmentScreenState();
// }

// final assetsAudioPlayer = AssetsAudioPlayer();

// class _AppointmentScreenState extends State<AppointmentScreen>
//     with TickerProviderStateMixin {
//   bool _isLogin = false;
//   bool _isConsDone = false;
//   int _current = 0;
//   bool _isCheckInAllowed = false;
//   //AgoraRtmChannel _channel;

//   //static TextStyle textStyle = TextStyle(fontSize: 18, color: Theme.of(context).primaryColor);

//   final scaffoldKey =
//       GlobalKey<ScaffoldState>(debugLabel: "scaffold-Video-call");

//   @override
//   void dispose() {
//     // clear users
//     Wakelock.disable();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();

//     //
//     Wakelock.enable();
//   }

//   /// Video layout wrapper
//   Widget _viewRows() {
//     return SingleChildScrollView(
//       child: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   MyCircleAvatar(
//                     imgUrl: "",
//                     personType: "DOCTOR",
//                     size: 80,
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width - 222,
//                     height: 150,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text(
//                           getApptDate(widget.appt.PortalAppointmentDateTime),
//                           style: TextStyle(fontSize: 18),
//                         ),

//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           widget.appt.DoctorName,
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           widget.appt.DepartmentName,
//                           style: TextStyle(fontSize: 19, color: Colors.grey),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           widget.appt.SlotName,
//                           style: TextStyle(fontSize: 15, color: Colors.grey),
//                         ),

//                         // Row(
//                         //   children: <Widget>[
//                         //     IconTile(
//                         //       backColor: Color(0xffFFECDD),
//                         //       imgAssetPath: "assets/email.png",
//                         //     ),
//                         //     IconTile(
//                         //       backColor: Color(0xffFEF2F0),
//                         //       imgAssetPath: "assets/call.png",
//                         //     ),
//                         //     IconTile(
//                         //       backColor: Color(0xffEBECEF),
//                         //       imgAssetPath: "assets/video_call.png",
//                         //     ),
//                         //   ],
//                         // )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 26,
//               ),
//               Divider(
//                 height: 10.0,
//                 indent: 5.0,
//                 color: Colors.black87,
//               ),
//               appointmentStatus(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget appointmentStatus() {
//     DateTime currentTime = DateTime.now();
//     DateTime checkedTime = widget.appt.PortalAppointmentDateTime;
//     int apptStatus = 0;
//     if ((currentTime.year == checkedTime.year) &&
//         (currentTime.month == checkedTime.month)) {
//       if ((currentTime.day - checkedTime.day) >= 1) {
//         apptStatus = 2;
//       } else {
//         apptStatus = 1;
//       }
//     } else {
//       apptStatus = 2;
//     }

//     if (apptStatus == 1) {
//       return Container(
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           children: <Widget>[
//             Text(
//               "Appointment starts in ${calculateTime(widget.appt.PortalAppointmentDateTime)}",
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Column(
//               children: <Widget>[
//                 Container(
//                     decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         //border: Border.all(width: 1.0),
//                         borderRadius: BorderRadius.all(Radius.circular(
//                                 10.0) //                 <--- border radius here
//                             )),
//                     //width: 100,
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Row(
//                           children: <Widget>[
//                             RaisedButton.icon(
//                               onPressed: () {
//                                 setState(() {
//                                   _isCheckInAllowed = true;
//                                 });
//                               },
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10.0))),
//                               label: Text(
//                                 'Fill the details',
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 15),
//                               ),
//                               icon: Icon(
//                                 Icons.looks_one,
//                                 color: Colors.white,
//                               ),
//                               textColor: Colors.white,
//                               splashColor: Theme.of(context).accentColor,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                             _isCheckInAllowed ? Icon(Icons.done) : Center(),
//                           ],
//                         ),
//                         Text(
//                             "Please fill the details whcih will help ${widget.appt.DoctorName} understand you better way."),
//                         SizedBox(
//                           height: 10,
//                         ),
//                       ],
//                     )),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                     decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.all(Radius.circular(
//                                 10.0) //                 <--- border radius here
//                             )),
//                     alignment: Alignment.centerLeft,
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     //width: 100,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Row(
//                           children: <Widget>[
//                             RaisedButton.icon(
//                               onPressed: _isCheckInAllowed
//                                   ? () {
//                                       onJoin(widget.appt);
//                                     }
//                                   : null,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10.0))),
//                               label: Text(
//                                 'Proceed to check-in',
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 15),
//                               ),
//                               icon: Icon(
//                                 Icons.looks_two,
//                                 color: Colors.white,
//                               ),
//                               textColor: Colors.white,
//                               splashColor: Theme.of(context).accentColor,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ],
//                         ),
//                         Text(
//                             "Check-in to Virtual OPD Waiting Area. Kindly fill the required details before check-in."),
//                         SizedBox(
//                           height: 10,
//                         ),
//                       ],
//                     )),
//               ],
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Container(
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           children: <Widget>[
//             Text(
//               "Appointment Completed",
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Container(
//                 //width: 100,
//                 child: RaisedButton.icon(
//               onPressed: () {
//                 print('Button Clicked.');
//               },
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10.0))),
//               label: Text(
//                 'View your e-Precription',
//                 style: TextStyle(color: Colors.white, fontSize: 20),
//               ),
//               icon: Icon(
//                 Icons.attachment,
//                 color: Colors.white,
//               ),
//               textColor: Colors.white,
//               splashColor: Theme.of(context).accentColor,
//               color: Theme.of(context).primaryColor,
//             )),
//             SizedBox(height: 10),
//             Container(
//                 //width: 100,
//                 child: RaisedButton.icon(
//               onPressed: () {
//                 joinChat(widget.appt);
//               },
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10.0))),
//               label: Text(
//                 'Chat with the Doctor',
//                 style: TextStyle(color: Colors.white, fontSize: 20),
//               ),
//               icon: Icon(
//                 Icons.chat,
//                 color: Colors.white,
//               ),
//               textColor: Colors.white,
//               splashColor: Theme.of(context).accentColor,
//               color: Theme.of(context).primaryColor,
//             )),
//           ],
//         ),
//       );
//     }
//   }

//   joinChat(AppointmentDetails appList) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatPage(
//           peerCode: appList.DoctorCode,
//         ),
//       ),
//     );
//   }

//   Future<void> onJoin(appList) async {
//     // update input validation
//     setState(() {});

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

//   String checkDate(DateTime checkedTime) {
//     //  example, dateString = "2020-01-26";

//     //DateTime checkedTime = DateTime.parse(dateString);
//     DateTime currentTime = DateTime.now();

//     if ((currentTime.year == checkedTime.year) &&
//         (currentTime.month == checkedTime.month) &&
//         (currentTime.day == checkedTime.day)) {
//       return "Today, ${DateFormat("d MMM yyyy").format(checkedTime)}";
//       ;
//     } else if ((currentTime.year == checkedTime.year) &&
//         (currentTime.month == checkedTime.month)) {
//       if ((currentTime.day - checkedTime.day) == 1) {
//         return "Yesterday, ${DateFormat("d MMM yyyy").format(checkedTime)}";
//         ;
//       } else if ((currentTime.day - checkedTime.day) == -1) {
//         return "Tomorrow, ${DateFormat("d MMM yyyy").format(checkedTime)}";
//       } else {
//         return DateFormat("d MMM yyyy").format(checkedTime);
//       }
//     } else {
//       return DateFormat("d MMM yyyy").format(checkedTime);
//     }
//   }

//   String getApptDate(apptDate) {
//     String strDate;

//     strDate = checkDate(apptDate);

//     return strDate;
//   }

//   Image getDoctorPhoto(i) {
//     if (widget.appt.DoctorPhoto == "") {
//       return Image.asset("assets/doctor_defaultpic.png");
//     } else {
//       return Image.memory(base64Decode(widget.appt.DoctorPhoto));
//     }
//   }

//   String calculateTime(apptDate) {
//     String diff = "";
//     int leftDays = 0;
//     int leftHr = 0;
//     int leftMin = 0;

//     DateTime currentDate = DateTime.now();

//     leftDays = apptDate.difference(currentDate).inDays;
//     leftHr = apptDate.difference(currentDate).inHours;
//     leftMin = apptDate.difference(currentDate).inMinutes;

//     if (leftDays > 0)
//       diff = "$leftDays day${leftDays > 1 ? 's' : ''}";
//     else if (leftHr > 0)
//       diff = "$leftHr hour${leftHr > 1 ? 's' : ''}";
//     else if (leftMin > 0) diff = "$leftMin Minute${leftMin > 1 ? 's' : ''}";

//     return diff;
//   }

//   /// Toolbar layout
//   Widget _toolbar() {
//     //final views = _getRenderViews();

//     return Container(
//       alignment: Alignment.bottomLeft,
//       //padding: const EdgeInsets.symmetric(vertical: 48),
//       margin: const EdgeInsets.only(bottom: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//               width: 80,
//               child: RawMaterialButton(
//                 onPressed: () => _onExit(context),
//                 child: Text("Back"),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25.0),
//                     side: BorderSide(color: Theme.of(context).primaryColor)),
//                 elevation: 2.0,
//                 fillColor: Theme.of(context).accentColor,
//                 padding: const EdgeInsets.all(15.0),
//               )),
//         ],
//       ),
//     );
//   }

//   void _onExit(BuildContext context) {
//     Wakelock.disable();
//     // _sendPeerMessage(
//     //     "CALLEND|${globals.loginUserType == "PATIENT" ? widget.appt.DoctorCode : widget.appt.PatientCode}");

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // floatingActionButton: UnicornDialer(
//       //     //backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
//       //     parentButtonBackground: Theme.of(context).accentColor,
//       //     orientation: UnicornOrientation.VERTICAL,
//       //     parentButton: Icon(Icons.more_vert),
//       //     childButtons: childButtons),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//         brightness: Brightness.light,
//         iconTheme: IconThemeData(color: Colors.black87),
//         automaticallyImplyLeading: false,
//         title: Text(
//           "Appointment",
//           style: TextStyle(
//               //fontSize: 15.0,
//               color: Colors.black,
//               fontWeight: FontWeight.bold),
//         ),
//       ),
//       //backgroundColor: Colors.white,
//       body:
//           //SlidingUpPanel(
//           // renderPanelSheet: false,
//           // padding: EdgeInsets.all(0.0),
//           // //maxHeight: 40,
//           // panel: _floatingPanel(),
//           // collapsed: _floatingCollapsed(),
//           //body:
//           Stack(
//         children: <Widget>[
//           _viewRows(),

//           _toolbar(),

//           //_toolbarMsg()
//         ],
//       ),
//       //),
//     );
//   }

//   Future<bool> _onBackPressed() {
//     return 1 ?? false;
//   }
// }

// class FunkyOverlay extends StatefulWidget {
//   final int id;

//   const FunkyOverlay({
//     Key key,
//     @required this.id,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => FunkyOverlayState();
// }

// class FunkyOverlayState extends State<FunkyOverlay>
//     with SingleTickerProviderStateMixin {
//   AnimationController controller;
//   Animation<double> scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     controller =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 450));
//     scaleAnimation =
//         CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

//     controller.addListener(() {
//       setState(() {});
//     });

//     controller.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: ScaleTransition(
//           scale: scaleAnimation,
//           child: Container(
//             height: MediaQuery.of(context).size.height / 2,
//             width: MediaQuery.of(context).size.width - 100,
//             decoration: ShapeDecoration(
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15.0))),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   width: MediaQuery.of(context).size.height / 2,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor,
//                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: widget.id == 1 ? Text("About doctor") : Text("Help"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
