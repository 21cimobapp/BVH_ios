import 'dart:convert';
import 'package:civideoconnectapp/src/pages/appointment_new/Selectatimeslot.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/doctor_card_mini.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/rounded_shadow.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/syles.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:civideoconnectapp/data_models/Appointmentsavedetails.dart';
//import 'package:civideoconnectapp/data_models/Doctors.dart';
import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/appointment/Razorpay/FailedApptBookPagePayAtHospital.dart';
import 'package:civideoconnectapp/src/pages/appointment/PayAtHospital.dart';
import 'package:civideoconnectapp/src/pages/appointment/RazorPay/CheckRazor.dart';
//import 'package:civideoconnectapp/src/pages/appointment/RazorPay/FailedApptBookPagePayAtHospital.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:intl/intl.dart';

import 'package:flutter/services.dart' show rootBundle;

class Conformappointment extends StatefulWidget {
  final PatientAppointmentdetails appDetail;
  final DoctorData doctorDet;
  //final String selectedValue;
  // Conformpage(this.time);
  const Conformappointment({Key key, this.appDetail, this.doctorDet})
      : super(key: key);

  @override
  _ConformappointmentState createState() => _ConformappointmentState();
}

class _ConformappointmentState extends State<Conformappointment> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Future onSelectNotification(String payload) {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    //FlutterRingtonePlayer.stop();
  }

  final Color _backgroundColor = Color(0xFFf0f0f0);
  bool consentAccepted = false;

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

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
    fontSize: 14,
    height: 1,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );

  showNotification() async {
    var android = new AndroidNotificationDetails(
      'channelId',
      'channelName',
      'channelDescription',
    );
    var ios = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, ios);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Appointment Booked',
      ' With ${widget.appDetail.DoctorName ?? ""} ',
      platform,
      payload: ' ',
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, ios);
    var SelectNotification;

    // flutterLocalNotificationsPlugin.initialize(initSettings,SelectNotification: onSelectNotification);

    flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(android, ios),
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                      height: 40,
                      width: double.infinity,
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Check and Pay",
                              style: TextStyle(fontSize: 16)),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: DoctorCardMini(doctorData: widget.doctorDet),
                  ),
                  Container(
                    child: Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 10),
                        child: appointmentDetailsBox()),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: CheckboxListTile(
                      secondary: const Icon(Icons.warning),
                      title: const Text(
                          'Yes, I consent to avail consultation via telemedicine'),
                      //subtitle: Text('Ringing after 12 hours'),
                      value: consentAccepted,
                      onChanged: (bool value) {
                        setState(() {
                          consentAccepted = value;
                        });
                      },
                    ),
                  ),
                  Container(
                      //padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.transparent,
                      child: RawMaterialButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewConsent(onClick: _updateConsent),
                            ),
                          )
                        },
                        child: Text("View consent", style: bodyTextStyle),
                        //   shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(25.0),
                        //       side: BorderSide(color: Colors.orangeAccent)),
                        //   elevation: 2.0,
                        //   fillColor: Colors.orangeAccent,
                        //   padding: const EdgeInsets.all(15.0),
                        // )
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  // Expanded(
                  //   child: Column(
                  //     children: [
                  //       Container(
                  //         height: 200,
                  //         child: Padding(
                  //             padding: const EdgeInsets.only(
                  //                 left: 15, right: 15, top: 10, bottom: 20),
                  //             child: _showConsentText()),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // Container(
                  //   child: Padding(
                  //       padding:
                  //           const EdgeInsets.only(left: 15, right: 15, top: 50),
                  //       child: Column(
                  //         children: [
                  //           Text("Notes",
                  //               style: Styles.text(16, Colors.black, true)),
                  //         ],
                  //       )),
                  // ),

                  // Container(
                  //   alignment: Alignment.bottomCenter,
                  //   child: Card(
                  //     child: new Container(
                  //       padding: new EdgeInsets.all(8.0),
                  //       child: new Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: <Widget>[
                  //           Column(
                  //             children: <Widget>[
                  //               RaisedButton(
                  //                 onPressed: () =>
                  //                     Navigator.of(context).pushAndRemoveUntil(
                  //                   MaterialPageRoute(
                  //                     builder: (context) => CheckRazor(
                  //                       appDetail: widget.appDetail,
                  //                       doctorDet: widget.doctorDet,
                  //                     ),
                  //                   ),
                  //                   (Route<dynamic> route) => false,
                  //                 ),
                  //                 child: Text('PAY NOW'),
                  //                 textColor: globals.appTextColor,
                  //                 color: Theme.of(context).accentColor,
                  //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  //               ),
                  //             ],
                  //           ),
                  //           SizedBox(
                  //             width: 60,
                  //           ),
                  //           Column(
                  //             children: <Widget>[
                  //               RaisedButton(
                  //                 onPressed: () {
                  //                   Appointmentsavedetails apptSaveDet =
                  //                       new Appointmentsavedetails(
                  //                           widget.appDetail.PatientCode,
                  //                           widget.appDetail.PatientCode,
                  //                           widget.appDetail.DoctorCode,
                  //                           DateFormat('yyyy-MM-dd')
                  //                               .format(widget.appDetail.ApptDate),
                  //                           widget.appDetail.SlotName,
                  //                           widget.appDetail.SlotNumber,
                  //                           widget.appDetail.DoctorSlotFromTime,
                  //                           widget.appDetail.DoctorSlotToTime,
                  //                           "HCALLPAYCOD",
                  //                           'H01',
                  //                           widget.appDetail.AppointmentType,
                  //                           widget.appDetail.SlotTimeLabel,
                  //                           widget.appDetail.PatientName,
                  //                           widget.appDetail.DoctorName,
                  //                           widget.doctorDet.doctorPhoto,
                  //                           widget.doctorDet.designation,
                  //                           widget.doctorDet.qualification,
                  //                           _getUserData("Age"),
                  //                           _getUserData("Gender"),
                  //                           widget.appDetail.SlotDuration,
                  //                           "",
                  //                           0,
                  //                           "");

                  //                   createContact(apptSaveDet);
                  //                 },
                  //                 child: Text('PAY AT HOSPITAL'),
                  //                 textColor: globals.appTextColor,
                  //                 color: Theme.of(context).accentColor,
                  //                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  //               ),
                  //             ],
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            //padding: const EdgeInsets.only(bottom: 18.0),
            //width: 300,
            child: Container(
              child: Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 10, top: 5, bottom: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      //width: 80,
                      height: 40,
                      child: Row(
                        children: [
                          Image.asset("assets/images/Rs.png",
                              height: 30, width: 30),
                          SizedBox(width: 10),
                          Text(
                              "${widget.appDetail.ConsultationFee == null ? "" : widget.appDetail.ConsultationFee}",
                              style: Styles.text(16, Colors.black, true)),
                        ],
                      ),
                    ),
                    ButtonTheme(
                      //minWidth: 250,
                      //height: 40,
                      child: Opacity(
                        opacity: consentAccepted == false ? .5 : 1,
                        child: FlatButton(
                          //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
                          onPressed: consentAccepted == false
                              ? null
                          : () {
                            print("I am in");
                            verifyandLockSlot();
//                            Navigator.of(context).pushAndRemoveUntil(
//                            MaterialPageRoute(
//                              builder: (context) => CheckRazor(
//                                appDetail: widget.appDetail,
//                                doctorDet: widget.doctorDet,
//                              ),
//                            ),
//                                (Route<dynamic> route) => false,
//                          );
                          },
                          color: Colors.orangeAccent,
                          disabledColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                  widget.appDetail.AppointmentType ==
                                          "VIDEOCONSULT"
                                      ? "assets/images/Video.png"
                                      : "assets/images/InPerson.png",
                                  height: 20,
                                  width: 20),
                              SizedBox(width: 10),
                              Text(
                                  widget.appDetail.AppointmentType ==
                                          "VIDEOCONSULT"
                                      ? "Pay for Video Consultation"
                                      : "Pay for Personal Visit",
                                  style: Styles.text(14, Colors.white, true)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  verifyandLockSlot() async {
    //Added by Abhi for verify and lock the slot.
    var url = "${globals.apiHostingURLBVH}/Patient/ApptVerifyAndLockSlot?DoctorCode=${widget.doctorDet.doctorCode}&DeptCode=${widget.doctorDet.deptCode}"
        "&OrganizationCode=${widget.appDetail.OrganizationCode}&ApptRqstDate=${widget.appDetail.ApptDate}&ApptRqstFromTime=${widget.appDetail.DoctorSlotFromTime1}&DirectCheckIn=0&WaitList=0&ApptMethod=0&Source=M";
    var response = await http.get(url,
        headers: {"Authorization": 'Bearer ${globals.tokenKey}'}
    );
//    print (response);
    if (response.statusCode == 200) {
      int slotstatus = json.decode(response.body)['status'];
      print(slotstatus);
      if (slotstatus==1) {
        print("I am in new method");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => CheckRazor(
              appDetail: widget.appDetail,
              doctorDet: widget.doctorDet,
            ),
          ),
              (Route<dynamic> route) => false,
        );
      }
      else if ( slotstatus==2){

        _alertAboutSlots();
//        Navigator.pop(context);
//        Navigator.of(context).pushAndRemoveUntil(
//          MaterialPageRoute(
//            builder: (context) => Selectatimeslot(
//              doctorDet: widget.doctorDet,
//              appointmentType: widget.appDetail.AppointmentType == 1 ? "VIDEOCONSULT"  : "VISITCONSULT",
//                organizationCode:widget.appDetail.OrganizationCode
//            ),
//          ),
//              (Route<dynamic> route) => false,
//        );
      }
    }
    // End Added by Abhi for verify and lock the slot.

    }

  Future<void> _alertAboutSlots() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert....'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('The slot has already been booked by someone else. Please select a different slot.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Selectatimeslot(
                        doctorDet: widget.doctorDet,
                        appointmentType: widget.appDetail.AppointmentType == 1 ? "VIDEOCONSULT"  : "VISITCONSULT",
                        organizationCode:widget.appDetail.OrganizationCode
                    ),
                  ),
                      (Route<dynamic> route) => false,
                );
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _updateConsent() {
    setState(() {
      consentAccepted = true;
    });
  }

  _buildLogoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Image.asset(
            widget.appDetail.AppointmentType == "VIDEOCONSULT"
                ? 'assets/images/Video.png'
                : 'assets/images/InPerson.png',
            width: 10,
          ),
        ),
        Text(
            widget.appDetail.AppointmentType == "VIDEOCONSULT"
                ? 'Video Consultation'.toUpperCase()
                : 'Personal Visit'.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ))
      ],
    );
  }

  appointmentDetailsBox() {
    return RoundedShadow.fromRadius(
      12,
      child: Column(
        children: [
          Container(
            height: 30,
            color: Colors.white,
            child: _buildLogoHeader(),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            width: double.infinity,
            //height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pateint Code'.toUpperCase(), style: titleTextStyle),
                      Text(widget.appDetail.PatientCode ?? "",
                          style: contentTextStyle),
                      SizedBox(height: 20),
                      Text('Appointment Date'.toUpperCase(),
                          style: titleTextStyle),
                      Text(
                          DateFormat('EEE, MMM d yyyy')
                              .format(widget.appDetail.ApptDate)
                              .toUpperCase(),
                          style: contentTextStyle),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Name'.toUpperCase(), style: titleTextStyle),
                      Container(
                        width: 160,
                        child: Text(
                          widget.appDetail.PatientName ?? "",
                          style: contentTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Appointment Time'.toUpperCase(),
                          style: titleTextStyle),
                      Text(
                        // Changed by Abhi for firebase to API
//                          DateFormat.jm()
//                              .format(DateFormat('yyyy-MM-dd hh:mm a')
//                                  .parse(widget.appDetail.DoctorSlotFromTime))
                         // widget.appDetail.DoctorSlotFromTime.substring(0, 10) + 'T' +
                               widget.appDetail.DoctorSlotFromTime.substring(10),
                          // End Changed by Abhi for firebase to API
                             // .toUpperCase(),
                          style: contentTextStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5.0),
            color: Colors.grey[400],
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Change Date and Time", style: contentTextStyle)),
            ),
          )
        ],
      ),
    );
  }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }

  Image getDoctorPhoto(i) {
    if (widget.doctorDet.doctorPhoto == "") {
      return Image.asset("assets/doctor_defaultpic.png");
    } else {
      return Image.memory(base64Decode(widget.doctorDet.doctorPhoto));
    }
  }

  createContact(Appointmentsavedetails savedetail) async {
    try {
      String toJson(Appointmentsavedetails savedetail) {
        var mapData = new Map();
        mapData["Token"] = savedetail.Token;
        mapData["PatientCode"] = savedetail.PatientCode;
        mapData["DoctorCode"] = savedetail.DoctorCode;
        mapData["ApptDate"] = savedetail.ApptDate;
        mapData["SlotName"] = savedetail.SlotName;
        mapData["SlotNumber"] = savedetail.SlotNumber;
        mapData["DoctorSlotFromTime"] = savedetail.DoctorSlotFromTime;
        mapData["DoctorSlotToTime"] = DateFormat('yyyy-MM-dd hh:mm a').format(
            DateFormat('yyyy-MM-dd hh:mm a')
                .parse(savedetail.DoctorSlotFromTime)
                .add(Duration(minutes: savedetail.SlotDuration)));
        mapData["OrganizationCode"] = savedetail.OrganizationCode;
        mapData["PaymentModeCode"] = savedetail.PaymentModeCode;
        mapData["AppointmentType"] = savedetail.AppointmentType;

        String json = jsonEncode(mapData); //JSON.encode(mapData);

        return json;
      }

      String _serviceUrl = '${globals.apiHostingURL}/Patient/SaveAppointment';
      //String _headers = 'Content-Type': 'application/json';
      final _headers = {'Content-Type': 'application/json'};

      String json = toJson(savedetail);
      final response =
          await http.post(_serviceUrl, headers: _headers, body: json);
      var extractdata = jsonDecode(response.body)['msg'];
      //"{"status":1,"msg":"Saved Appointment successfully","err_code":"No Error","AppointmentNumber":"APP000000000173"}"
      print(extractdata);
      String appointmentNumber = jsonDecode(response.body)['AppointmentNumber'];

      Map<String, dynamic> appDetail = {
        "appointmentNumber": appointmentNumber,
        "patientCode": savedetail.PatientCode,
        "doctorCode": savedetail.DoctorCode,
        "apptDate": DateTime.parse(savedetail.ApptDate),
        "slotName": savedetail.SlotName,
        "slotNumber": savedetail.SlotNumber,
        "doctorSlotFromTime": DateFormat('yyyy-MM-dd hh:mm a')
            .parse(savedetail.DoctorSlotFromTime),
        "doctorSlotToTime": DateFormat('yyyy-MM-dd hh:mm a')
            .parse(savedetail.DoctorSlotToTime)
            .add(Duration(minutes: savedetail.SlotDuration)),
        "organizationCode": savedetail.OrganizationCode,
        "paymentModeCode": savedetail.PaymentModeCode,
        "appointmentType": savedetail.AppointmentType,
        "patientName": savedetail.PatientName,
        "doctorName": savedetail.DoctorName,
        "departmentName": savedetail.DepartmentName,
        "doctorQualification": savedetail.DoctorQualification,
        "patientAge": savedetail.PatientAge,
        "patientGender": savedetail.PatientGender,
        "slotDuration": savedetail.SlotDuration,
      };
      DatabaseMethods().addAppointment(appDetail, appointmentNumber);

      showNotification();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              Payathospital(appDetail: widget.appDetail),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Server Exception!!!');
      print(e);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => FailedApptBookPagePayAtHospital(),
        ),
        (Route<dynamic> route) => false,
      );
    }
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
        child: Text('Book An Appointment'.toUpperCase(),
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

class ViewConsent extends StatefulWidget {
  final Function() onClick;
  //final String selectedValue;
  // Conformpage(this.time);
  const ViewConsent({Key key, this.onClick}) : super(key: key);

  @override
  _ViewConsentState createState() => _ViewConsentState();
}

class _ViewConsentState extends State<ViewConsent> {
  final Color _backgroundColor = Color(0xFFf0f0f0);

  String consentText;
  bool isDisabled;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConsentFromAssets();
    isDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: _showConsentText())),
            Container(
              color: Colors.orangeAccent,
              width: double.infinity,
              child: ButtonTheme(
                //minWidth: 250,
                //height: 40,
                child: Opacity(
                  opacity: isDisabled ? .5 : 1,
                  child: FlatButton(
                    //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
                    onPressed: isDisabled
                        ? null
                        : () {
                            //confirmAppointment(selectedSlot);
                            widget.onClick();
                            Navigator.pop(context);
                          },
                    color: Colors.orangeAccent,
                    disabledColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Yes, I consent to avail consultation via telemedicine",
                            style: Styles.text(12, Colors.white, true)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  _showConsentText() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Text("${consentText == null ? "" : consentText}"));
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
        child: Text('consent'.toUpperCase(),
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

  getConsentFromAssets() async {
    consentText = await getFileData("assets/consent.txt");

    setState(() {});
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }
}
