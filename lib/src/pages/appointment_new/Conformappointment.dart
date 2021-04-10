import 'dart:convert';
import 'package:civideoconnectapp/src/pages/appointment/RazorPay/SuccessPage.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/PatientRegDet_card.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/Reg_PatientDetails.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/Selectatimeslot.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/doctor_card_mini.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/rounded_shadow.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/serviceList.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/syles.dart';
import 'package:civideoconnectapp/src/pages/index/index_new.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

class Conformappointment extends StatefulWidget {
  final PatientAppointmentdetails appDetail;
  final DoctorData doctorDet;
  final List serviceList;

  //final String selectedValue;
  // Conformpage(this.time);
  const Conformappointment({Key key, this.appDetail, this.doctorDet,this.serviceList})
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
  ScrollController _scrollController = ScrollController();
  double _listPadding = 20;
  bool isClicked = false;

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

  String regDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    getregistrationDetails();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, ios);
    var SelectNotification;

    // flutterLocalNotificationsPlugin.initialize(initSettings,SelectNotification: onSelectNotification);

    flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(android, ios),
        onSelectNotification: onSelectNotification);

    widget.appDetail.AppointmentType=="VIDEOCONSULT"? consentAccepted=false:consentAccepted=true;
  }

//  Widget _buildListItem(int index) {
//    return Container(
//      margin: EdgeInsets.symmetric(
//          vertical: _listPadding / 2, horizontal: _listPadding),
//      child: DoctorCard(
//          doctorData: _filterdoctor[index],
//          isOpen: _filterdoctor[index] == _selectedDoctor,
//          onTap: _handleDoctorTapped,
//          onOptionSelected: _handleOptionSelected),
//    );
//  }

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
//                      child: ApptDetailCard(
//                          appDetail: widget.appDetail,
//                          isOpen: isClicked == true,
//                          onTap: _handleDoctorTapped,
////                          onOptionSelected: _handleOptionSelected
//                      ),

//                    ), // Abhi for listing members

                  ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.appDetail.AppointmentType=="VIDEOCONSULT"?
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
                  ):Container(),
                  widget.appDetail.AppointmentType=="VIDEOCONSULT"?

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
                      )):Container(),
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
                          onPressed:
                          consentAccepted == false
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
  void _handleDoctorTapped(PatientAppointmentdetails data) {
    setState(() {
      //If the same drink was tapped twice, un-select it
      if (isClicked == true) {
        isClicked = false;
      }
      //Open tapped drink card and scroll to it
      else {
        isClicked = true;
        var selectedIndex = 1;
        var closedHeight = ApptDetailCard.nominalHeightClosed;
        //Calculate scrollTo offset, subtract a bit so we don't end up perfectly at the top
        var offset =
            selectedIndex * (closedHeight + _listPadding) - closedHeight * .35;

//        _scrollController.animateTo(offset,
//            duration: Duration(milliseconds: 700), curve: Curves.easeOutQuad);
      }
    });
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
        //underDevp
        if(widget.appDetail.ConsultationFee==0)
          {
            createContact(widget.appDetail,widget.doctorDet);
          }
        else if(widget.appDetail.ConsultationFee>0){
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  CheckRazor(
                    appDetail: widget.appDetail,
                    doctorDet: widget.doctorDet,
                  ),
            ),
                (Route<dynamic> route) => false,
          );
        }
//        else{
//          showtoast();
//        }
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
//                Navigator.of(context).pushAndRemoveUntil(
//                  MaterialPageRoute(
//                    builder: (context) => Selectatimeslot(
//                        doctorDet: widget.doctorDet,
//                        appointmentType: widget.appDetail.AppointmentType == 1 ? "VIDEOCONSULT"  : "VISITCONSULT",
//                        organizationCode:widget.appDetail.OrganizationCode
//                    ),
//                  ),
//                      (Route<dynamic> route) => false,
//                );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  createContact(PatientAppointmentdetails appDet,DoctorData docDet) async {
    var mapData = new Map();
    mapData["ApptDate"] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    mapData["PatientCode"] = appDet.PatientCode;
    mapData["PatientName"] = appDet.PatientName;
    mapData["GenderACode"] = appDet.GenderCode;
    mapData["PatientMobileNo"] = appDet.PatientMobile;
    mapData["PatientEmailID"] = appDet.PatientEmail;
//        mapData["PatientDOB"] = savedetail.;
    mapData["DoctorCode"] = appDet.DoctorCode;
    mapData["ApptRqstDate"]= DateFormat('yyyy-MM-dd').format(appDet.ApptDate);
    mapData["ApptRqstFromTime"] = appDet.DoctorSlotFromTime1;
//        mapData["ApptRqstToTime"] = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateFormat('yyyy-MM-dd hh:mm:ss').parse(savedetail.DoctorSlotFromTime).add(Duration(minutes: savedetail.SlotDuration)));
    mapData["ApptRqstToTime"] = appDet.DoctorSlotToTime1;
    mapData["DeptCode"] = docDet.deptCode;
    mapData["ApptSource"] = "M";
    mapData["ApptMethod"] = "0";
    mapData["ApptUserCode"] = appDet.PatientCode;
    mapData["OrganizationCode"] = appDet.OrganizationCode;
    mapData["ActiveStatus"] = "1";
    mapData["ApptType"] = appDet.AppointmentType=="VIDEOCONSULT"?"2":"1";
    mapData["PaidAmt"]=appDet.ConsultationFee;
    mapData["ServiceCode"]=appDet.ServiceCode;
    mapData["BillServiceCode"]=appDet.BillServiceCode;

    String json = jsonEncode(mapData);
    String _serviceUrl = '${globals.apiHostingURLBVH}/patient/SaveApptHeader';

    var _headers = {'Content-Type': 'application/json',"Authorization": 'Bearer ${globals.tokenKey}'};
    final response =
        await http.post(_serviceUrl, headers: _headers, body: json);
    var extractdata = jsonDecode(response.body)['status'];
    print(extractdata);
    if (extractdata == 2)
    {
      failedmsg();
    }
    else if (extractdata == 1) {
      String appointmentNumber = jsonDecode(response.body)['ApptNumber'];
      Map<String, dynamic> appDetail = {
        "appointmentNumber": appointmentNumber,
        "patientCode": appDet.PatientCode,
        "doctorCode": appDet.DoctorCode,
        "apptDate": DateTime.parse(DateFormat('yyyy-MM-dd').format(appDet.ApptDate)),
        "slotName": appDet.SlotName,
        "slotNumber": appDet.SlotNumber,
//        "doctorSlotFromTime": DateFormat('yyyy-MM-dd hh:mm a')
//            .parse(savedetail.DoctorSlotFromTime),
        "doctorSlotFromTime": Timestamp.fromDate(
            DateFormat('yyyy-MM-dd hh:mm').parse(
                appDet.DoctorSlotFromTime)),
//        "doctorSlotToTime": DateFormat('yyyy-MM-dd hh:mm a')
//            .parse(savedetail.DoctorSlotToTime)
//            .add(Duration(minutes: savedetail.SlotDuration)),
        "doctorSlotToTime": Timestamp.fromDate(
            DateFormat('yyyy-MM-dd hh:mm').parse(
              DateFormat("yyyy-MM-dd HH:mm:ss").format(DateFormat('yyyy-MM-dd hh:mm:ss').parse(appDet.DoctorSlotFromTime).add(Duration(minutes: appDet.SlotDuration))))),
        "organizationCode": appDet.OrganizationCode,
        "paymentModeCode": "HCALLPAYONLINE",
        "appointmentType": appDet.AppointmentType,
        "patientName": appDet.PatientName,
        "doctorName": appDet.DoctorName,
        "departmentName": docDet.designation,
        "doctorQualification": docDet.qualification,
        "patientAge": "",
        "patientGender": appDet.GenderCode,
        "slotDuration": appDet.SlotDuration,
        "paymentId": "",
        "paymentAmount": appDet.ConsultationFee,
        "signature": "",
      };
      DatabaseMethods().addAppointment(appDetail, appointmentNumber);


      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              SuccessPage(
                  response: null, appDetail: widget.appDetail,appointmentNumber:appointmentNumber),
        ),
            (Route<dynamic> route) => false,
      );
    }
  }
  Future<bool> failedmsg() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Time Slot unavailable"),
        content: Text("The time you selected is already been booked by someone else. Please select another slot"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => //exit(0),
            //Navigator.of(context).pop(true),
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IndexNew())
            ),
            child: Text('Ok'),
          ),
        ],
      ),
    ) ??
        false;
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

                      SizedBox(height: 20),
                      Text('Visit Type'.toUpperCase(),
                          style: titleTextStyle),
                      Text(widget.appDetail.VisitType,
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
                      SizedBox(height: 20),
                      Text('Consultation Fee'.toUpperCase(),
                          style: titleTextStyle),
                      Text("${widget.appDetail.ConsultationFee == null ? "" : widget.appDetail.ConsultationFee}",
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
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 Column(
            children: [
              Container(
            color: Colors.grey[400],
            height:30,
            width: 150,
            child:
                GestureDetector(
                  onTap: () {
                    //Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationDetails(
                            appDetail: widget.appDetail,
                            doctorDet: widget.doctorDet,
                          ),
                        ));
                  },
                 // child:  Alignment(

                  child: Text("Change Patient",textAlign: TextAlign.center, style: //contentTextStyle
                  TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    height: 1.5,
                    letterSpacing: .5,
                    fontWeight: FontWeight.bold,
                    color:Color(0xFF083e64) //Color(0xff083e64),
                  )
                  )), //),
              )
                ] ),
               // SizedBox(width: 10,),
                Column(
                children: [
                  Container(
                      color: Colors.grey[400],
                    height:30,
                    width: 150,
                    child:
                GestureDetector(
                    onTap: () {
                      //Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceList(
                              appDetail: widget.appDetail,
                              doctorDet: widget.doctorDet,
                            ),
                          ));
                    },
                    child: Text("Change Service",textAlign: TextAlign.center, style: //contentTextStyle
                    TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: .5,
                        fontWeight: FontWeight.bold,
                        color:Color(0xFF083e64) //Color(0xff083e64),
                    )
                    )),
                  )
    ]),
    ]
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

  createContactold(Appointmentsavedetails savedetail) async {
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
