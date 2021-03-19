import 'dart:async';
import 'dart:io';
//import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/ChatPage.dart';
import 'package:civideoconnectapp/src/pages/GeneratePrescription.dart';
import 'package:civideoconnectapp/src/pages/PatientReports.dart';
import 'package:civideoconnectapp/src/pages/PrescriptionPage.dart';
import 'package:civideoconnectapp/src/pages/callForDoctor.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/settings.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/src/pages/ViewDocuments.dart';
import 'package:civideoconnectapp/src/pages/ViewEPrescription.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:sliding_up_panel/sliding_up_panel.dart';
//import 'package:civideoconnectapp/src/pages/popup.dart';
//import 'package:civideoconnectapp/src/pages/popup_content.dart';
//import 'package:civideoconnectapp/src/pages/InfoPopup.dart';

class ConsultationRoom extends StatefulWidget {
  /// non-modifiable channel name of the page
  //final int userID;

  final String appointmentNumber;

  /// Creates a call page with given channel name.
  const ConsultationRoom({Key key, this.appointmentNumber}) : super(key: key);

  @override
  _ConsultationRoomState createState() => _ConsultationRoomState();
}

class _ConsultationRoomState extends State<ConsultationRoom> {
  AgoraRtmClient clientRTM;
  AnimationController controller;
  Stream<QuerySnapshot> preConsultationDetails;
  Stream apptStream;
  DocumentSnapshot appt;
  String appTitle = "Consultation Room";

  bool _isLogin = false;
  bool _isPrecriptionSubmitted = false;

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
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    //initializeRTC();
    _handleCameraAndMic();
    initMsgService();

    apptStream =
        DatabaseMethods().getAppointmentDetails(widget.appointmentNumber);

    DatabaseMethods()
        .getPreConsultationDetails(widget.appointmentNumber)
        .then((val) {
      setState(() {
        preConsultationDetails = val;
      });
    });
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  void initMsgService() async {
    await _createClient();
    await _loginToChatService();
  }

  void startConsultation() async {
    Navigator.pop(context);
    DatabaseMethods().updateAppointmentDetails(
        appt.data["appointmentNumber"], "appointmentStatus", "INCONSULT");
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPageDoctor(appt: appt),
        ));
    showConsConfirmation(context);
  }

  showConsConfirmation(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        height: 100,
        child: new Column(
          children: [
            Container(
                margin: EdgeInsets.only(left: 5),
                child: Text("Consultation Completed?")),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendPeerMessage("CONSDONE");
                    DatabaseMethods().updateAppointmentDetails(
                        appt.data["appointmentNumber"],
                        "appointmentStatus",
                        "DONE");
                  },
                  child: Text("Yes"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(15.0),
                ),
                SizedBox(
                  width: 20,
                ),
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendPeerMessage("CONSPENDING");
                    DatabaseMethods().updateAppointmentDetails(
                        appt.data["appointmentNumber"],
                        "appointmentStatus",
                        "PENDING");
                  },
                  child: Text("No"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(15.0),
                ),
              ],
            )
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _createClient() async {
    clientRTM = await AgoraRtmClient.createInstance(APP_ID);
    clientRTM.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      if (message.text == "CONSOK") {
        startConsultation();
      }
      if (message.text == "CONSCANCEL") {
        Navigator.pop(context);
      }

      if (message.text == "MSG") {}
    };

    clientRTM.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        clientRTM.logout();
        //_log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
  }

  void _loginToChatService() async {
    String userId = globals.personCode;

    try {
      await clientRTM.login(null, userId);
      //_log('Connected : ' + userId);
      setState(() {
        _isLogin = true;
      });
    } catch (errorCode) {
      //_log('Connetion error: ' + errorCode.toString());
      setState(() {
        _isLogin = false;
      });
    }
  }

  void _sendPeerMessage(msg) async {
    String peerUid = appt.data["patientCode"];

    if (peerUid.isEmpty) {
      //_log('Please input peer user id to send message.');
      return;
    }

    String text = msg;
    if (text.isEmpty) {
      //_log('Please input text to send.');
      return;
    }

    try {
      AgoraRtmMessage message = AgoraRtmMessage.fromText(text);
      await clientRTM.sendMessageToPeer(peerUid, message, false);
      //_log('Send peer message success.');
    } catch (errorCode) {
      //_log('Send peer message error: ' + errorCode.toString());
    }
  }

  /// Video layout wrapper
  Widget _viewRows() {
    return Stack(
      children: <Widget>[
        // Center(
        //   child: new Image.asset(
        //     'assets/ConsultationRoom.jpg',
        //     width: MediaQuery.of(context).size.width,
        //     height: MediaQuery.of(context).size.height,
        //     fit: BoxFit.fill,
        //   ),
        // ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 10, top: 10),
          //padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(color: Colors.white, child: _buildTopContent(appt)),
              // Container(
              //   //width: 250,
              //   alignment: Alignment.topLeft,
              //   // padding: const EdgeInsets.only(
              //   //     top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: <Widget>[
              //       InkWell(
              //         onTap: () => {
              //           showDialog(
              //             context: context,
              //             builder: (_) => FunkyOverlay(
              //                 preConsultationDetails: preConsultationDetails),
              //           )
              //         },
              //         child: Container(
              //           width: 200,
              //           child: Card(
              //               margin: const EdgeInsets.only(left: 10, top: 10),
              //               //margin: EdgeInsets.symmetric(vertical: 10),
              //               //elevation: 10.0,
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(15.0),
              //               ),
              //               child: Column(children: <Widget>[
              //                 Padding(
              //                   padding: const EdgeInsets.only(
              //                       top: 10.0,
              //                       bottom: 10.0,
              //                       left: 10.0,
              //                       right: 10.0),
              //                   child: Row(children: <Widget>[
              //                     Column(
              //                       crossAxisAlignment:
              //                           CrossAxisAlignment.start,
              //                       children: <Widget>[
              //                         Container(
              //                           width: 150,
              //                           child: Text("Medical Details",
              //                               style: Theme.of(context)
              //                                   .textTheme
              //                                   .subtitle,
              //                               overflow: TextOverflow.fade),
              //                         ),
              //                       ],
              //                     ),
              //                   ]),
              //                 ),
              //               ])),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 20,
              ),
              appointmentStatus()
            ],
          ),
        )
      ],
    );
  }

  Widget appointmentStatus() {
    DateTime currentDate =
        DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());

    DateTime doctorSlotToTime = appt.data["doctorSlotToTime"].toDate();
    String appointmentStatus = appt.data["appointmentStatus"];
    int apptStatus = 0;

    if (doctorSlotToTime.difference(currentDate).inDays >= 0) {
      if (appointmentStatus == "DONE" || appointmentStatus == "CANCELLED")
        apptStatus = 2;
      else
        apptStatus = 1;
    } else {
      apptStatus = 2;
    }

    if (apptStatus == 1) {
      return viewPendingAppointment();
    } else {
      if (appt.data["appointmentStatus"] == "DONE") {
        return viewCompletedAppointment();
      } else if (appt.data["appointmentStatus"] == "CANCELLED") {
        return viewCancelledAppointment();
      } else {
        return Container();
      }
    }
  }

  Widget viewPendingAppointment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
            "Appointment starts in ${calculateTime(convertToDate(appt.data["doctorSlotFromTime"]))}",
            style: titleTextStyle,
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      //border: Border.all(width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(
                              10.0) //                 <--- border radius here
                          )),
                  //width: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            child: RaisedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _sendPeerMessage("CALL");

                                  showAlertDialog(context);
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              label: Text(
                                'Start Call',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                              icon: Icon(
                                Icons.call,
                                color: Colors.black,
                              ),
                              textColor: Colors.black,
                              splashColor: Colors.white,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: <Widget>[
                      //     Container(
                      //       width: MediaQuery.of(context).size.width - 50,
                      //       height: 50,
                      //       child: RaisedButton.icon(
                      //         onPressed: () {
                      //           Navigator.of(context).push(MaterialPageRoute(
                      //               builder: (BuildContext context) => ChatPage(
                      //                     peerCode: appt.data["patientCode"],
                      //                     peerName: appt.data["patientName"],
                      //                   )));
                      //         },
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(10.0))),
                      //         label: Text(
                      //           'Chat with the Patient',
                      //           style: TextStyle(
                      //               color: Colors.black, fontSize: 15),
                      //         ),
                      //         icon: Icon(
                      //           Icons.chat,
                      //           color: Colors.black,
                      //         ),
                      //         textColor: Colors.black,
                      //         splashColor: Colors.white,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            child: RaisedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewDocuments(
                                          patientCode: appt["patientCode"]),
                                    ));
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              label: Text(
                                'View Documents',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                              icon: Icon(
                                Icons.attachment,
                                color: Colors.black,
                              ),
                              textColor: Colors.black,
                              splashColor: Colors.white,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            child: RaisedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientReports(
                                          patientCode: appt["patientCode"]),
                                    ));
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              label: Text(
                                'View Lab Reports',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                              icon: Icon(
                                Icons.file_download,
                                color: Colors.black,
                              ),
                              textColor: Colors.black,
                              splashColor: Colors.white,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        height: 150,
        child: new Column(
          children: [
            Row(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text("Patient Call")),
                InkWell(
                  onTap: () => {startConsultation()},
                  child: Container(
                      margin: EdgeInsets.only(left: 5), child: Text(".")),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            RawMaterialButton(
              onPressed: () => (Navigator.pop(context)),
              child: Text("Cancel"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Theme.of(context).primaryColor)),
              elevation: 2.0,
              fillColor: Theme.of(context).accentColor,
              padding: const EdgeInsets.all(15.0),
            )
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  DateTime convertToDate(Timestamp timestamp) {
    var date = timestamp.toDate();

    return date;
  }

  String calculateTime(apptDateTime) {
    String diff = "";
    int leftDays = 0;
    int leftHr = 0;
    int leftMin = 0;
    int leftSec = 0;
    DateTime currentDate = DateTime.now();

    leftDays = apptDateTime.difference(currentDate).inDays;
    leftHr = apptDateTime.difference(currentDate).inHours;
    leftMin = apptDateTime.difference(currentDate).inMinutes;
    leftSec = apptDateTime.difference(currentDate).inSeconds;
    if (leftDays > 0)
      diff = "$leftDays day${leftDays > 1 ? 's' : ''}";
    else if (leftHr > 0)
      diff = "$leftHr hour${leftHr > 1 ? 's' : ''}";
    else if (leftMin > 0)
      diff = "$leftMin Minute${leftMin > 1 ? 's' : ''}";
    else if (leftDays <= 0) diff = "0 Minute";

    return diff;
  }

  Widget viewCancelledAppointment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
            "Appointment Cancelled",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget viewCompletedAppointment() {
    String peerCode = "";
    String peerName = "";

    peerCode = appt.data["patientCode"];
    peerName = appt.data["patientName"];

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
            "Appointment Completed",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  //width: 100,
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  appt.data["prescriptionStatus"] == "GENERATED" ||
                          appt.data["prescriptionStatus"] == "PUBLISHED"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              //width: MediaQuery.of(context).size.width - 50,
                              child: RaisedButton.icon(
                                onPressed: () {
                                  generatePDF();
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                label: Text(
                                  'View e-Prescription',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                                icon: Icon(
                                  Icons.attachment,
                                  color: Colors.black,
                                ),
                                textColor: Colors.black,
                                splashColor: Colors.white,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            appt.data["prescriptionStatus"] == "GENERATED"
                                ? RaisedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  PrescriptionPage(
                                                    appt: appt,
                                                  )));
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    label: Text(
                                      'Edit',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    ),
                                    textColor: Colors.black,
                                    splashColor: Colors.white,
                                    color: Colors.white,
                                  )
                                : Container(),
                          ],
                        )
                      : Container(
                          child: RaisedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      PrescriptionPage(
                                        appt: appt,
                                      )));
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            label: Text(
                              'Generate e-Prescription',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            icon: Icon(
                              Icons.attachment,
                              color: Colors.black,
                            ),
                            textColor: Colors.black,
                            splashColor: Colors.white,
                            color: Colors.white,
                          ),
                        ),
                  appt.data["prescriptionStatus"] == "GENERATED" ||
                          appt.data["prescriptionStatus"] == "PUBLISHED"
                      ? Icon(Icons.done)
                      : Center(),
                ],
              )),
              SizedBox(height: 10),
              (appt.data["prescriptionStatus"] == "GENERATED")
                  ? Text(
                      "Hello ${globals.personName}, Precription is generated. You can Review it before Publish it for Patient.")
                  : (appt.data["prescriptionStatus"] == "PUBLISHED")
                      ? Text(
                          "Hello ${globals.personName}, Precription is Published for Patient.")
                      : Text(
                          "Hello ${globals.personName}, Please provide Appointment summary and a precription"),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      child: RaisedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ChatPage(
                                peerCode: peerCode,
                                peerName: peerName,
                              )));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    label: Text(
                      'Chat with the Patient',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    icon: Icon(
                      Icons.chat,
                      color: Colors.black,
                    ),
                    textColor: Colors.black,
                    splashColor: Colors.white,
                    color: Colors.white,
                  )),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      child: RaisedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewDocuments(patientCode: appt["patientCode"]),
                          ));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    label: Text(
                      'View Documents',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    icon: Icon(
                      Icons.attachment,
                      color: Colors.black,
                    ),
                    textColor: Colors.black,
                    splashColor: Colors.white,
                    color: Colors.white,
                  )),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      //width: MediaQuery.of(context).size.width - 50,
                      child: RaisedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientReports(
                                patientCode: appt["patientCode"]),
                          ));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    label: Text(
                      'View Lab Reports',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    icon: Icon(
                      Icons.attachment,
                      color: Colors.black,
                    ),
                    textColor: Colors.black,
                    splashColor: Colors.white,
                    color: Colors.white,
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomLeft,
      //padding: const EdgeInsets.symmetric(vertical: 48),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 100,
              child: RawMaterialButton(
                onPressed: () => _onExit(context),
                child: Text("Exit"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  //side: BorderSide(color: Theme.of(context).primaryColor)
                ),
                elevation: 2.0,
                fillColor: Colors.red,
                padding: const EdgeInsets.all(15.0),
              )),
        ],
      ),
    );
  }

  generatePDF() async {
    File file;
    await reportView(context, appt).then((value) => file = value);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewEPrescription(
            appt: appt, pageTitle: "e-Prescription", path: file.path),
      ),
    );
  }

  String _loginUserType() {
    if (globals.loginUserType != null) {
      return globals.loginUserType;
    } else
      return '';
  }

  void _onExit(BuildContext context) {
    Navigator.pop(context);
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
                    child:globals.getProfilePic("PATIENT"),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 230,
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
                        Column(
                          children: [
                            Text(
                                DateFormat("dd MMM")
                                    .format(appt.data["apptDate"].toDate()),
                                style: bodyTextStyle.copyWith(fontSize: 15)),
                            Text(
                                DateFormat.jm()
                                    .format(appt.data["doctorSlotFromTime"]
                                        .toDate())
                                    .toUpperCase(),
                                style: bodyTextStyle.copyWith(fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: apptStream,
        // Firestore.instance
        //     .collection("Appointments")
        //     .document(widget.appointmentNumber)
        //     .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading");
          }
          appt = snapshot.data;

          // setState(() {
          //   _isPrecriptionSubmitted =
          //       appt.data["PrecriptionSubmitted"] == "1" ? true : false;
          // });

          return WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              backgroundColor: _backgroundColor,
              appBar: _buildAppBar(),
              body: Center(
                child: Stack(
                  children: <Widget>[
                    _viewRows(),

                    _toolbar(),

                    //_toolbarMsg()
                  ],
                ),
              ),
              //),
            ),
          );
        });
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appBarIconsColor),
        onPressed: () {
          Navigator.pop(context);
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
        child: Text('Consultation Room'.toUpperCase(),
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

  Future<bool> _onBackPressed() {
    return 1 ?? false;
  }
}

class FunkyOverlay extends StatefulWidget {
  final Stream<QuerySnapshot> preConsultationDetails;

  const FunkyOverlay({
    Key key,
    @required this.preConsultationDetails,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width - 100,
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.height / 2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Text("Patient's Details",
                              style: TextStyle(
                                  //fontSize: 15.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                        ],
                      )),
                ),
                Expanded(
                  child: Container(
                      height: 300,
                      child: StreamBuilder(
                          stream: widget.preConsultationDetails,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder:
                                        (BuildContext context, int i) =>
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              child: Column(
                                                children: <Widget>[
                                                  Divider(
                                                    height: 10.0,
                                                    indent: 5.0,
                                                    color: Colors.black87,
                                                  ),
                                                  Text(
                                                      "${snapshot.data.documents[i].data["id"]}",
                                                      style: TextStyle(
                                                          //fontSize: 15.0,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15)),
                                                  Divider(
                                                    height: 10.0,
                                                    indent: 5.0,
                                                    color: Colors.black87,
                                                  ),
                                                  SizedBox(width: 20),
                                                  Text(
                                                      "${snapshot.data.documents[i].data["answer1"]}",
                                                      style: TextStyle(
                                                          //fontSize: 15.0,
                                                          color: Colors.black,
                                                          fontSize: 15)),
                                                  SizedBox(width: 20),
                                                ],
                                              ),
                                            ))
                                : Container();
                          })),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
