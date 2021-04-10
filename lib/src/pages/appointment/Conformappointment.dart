import 'dart:convert';
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
import 'package:civideoconnectapp/utils/widgets.dart';

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
      ' With ${widget.appDetail.DoctorName} ',
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
      appBar: AppBar(
        //centerTitle: true,
        //backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "CONFIRM APPOINTMENT",
          style: TextStyle(),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  // color: Colors.lightBlue[50],
                  width: 600,
                  height: 200,
                  child: Column(children: <Widget>[
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      width: 500,
                      height: 60,
                      child: Card(
                        //color: Theme.of(context).primaryColor,
                        elevation: 2.0,
                        child: Text(
                          "You are about to book Appointment",
                          style: TextStyle(
                              //color: globals.appTextColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    MyCircleAvatar(imgUrl: "", size: 60, personType: "PATIENT"),
                    SizedBox(height: 10),
                    Text(
                      widget.appDetail.PatientName, //+" "+"$textHolder",
                      style: TextStyle(fontSize: 20),
                    ),
                    // Text(
                    //   widget.doctorDet.doctor_designation,
                    // ),
                  ])),
              SizedBox(height: 15),
              Container(
                // color: Colors.purple[50],
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 40,
                      width: 500,
                      child: Card(
                        //color: Theme.of(context).primaryColor,
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Appointment Details",
                            style: TextStyle(
                                //color: globals.appTextColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Card(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              elevation: 10.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(children: <Widget>[
                                    MyCircleAvatar(
                                        imgUrl: "",
                                        personType: "DOCTOR",
                                        size: 60),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 270,
                                          child: Text(
                                              widget.doctorDet.doctorName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Text(
                                          widget.doctorDet.qualification,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          widget.appDetail.ConsultationFee ==
                                                  null
                                              ? ""
                                              : "Consultation Fee: Rs. ${widget.appDetail.ConsultationFee.toString()}",
                                          //style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ]),
                                ),
                                Divider(
                                  height: 5.0,
                                  indent: 5.0,
                                  color: Colors.black,
                                ),
                                Text(
                                    (widget.appDetail.AppointmentType ==
                                            "VIDEOCONSULT")
                                        ? "Video Consultation"
                                        : "Personal Visit",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                    )),
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Date",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy').format(
                                                widget.appDetail.ApptDate),

                                            //  +""+

                                            //  "",

                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ]),
                                    SizedBox(
                                      width: 50,
                                    ),
                                    Column(children: <Widget>[
                                      Text(
                                        "Time",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        "" + widget.appDetail.SlotTimeLabel,
                                        //  +""+

                                        //  "",

                                        style: TextStyle(fontSize: 15),
                                      ),
                                      // Text(
                                      //   widget.doctorDet.doctor_designation,
                                      // ),
                                    ])
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ])),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: RaisedButton(
                    child: Text('CHANGE'),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              SizedBox(
                height: 100,
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Card(
                  child: new Container(
                    padding: new EdgeInsets.all(8.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () =>
                                  Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => CheckRazor(
                                    appDetail: widget.appDetail,
                                    doctorDet: widget.doctorDet,
                                  ),
                                ),
                                (Route<dynamic> route) => false,
                              ),
                              child: Text('PAY NOW'),
                              textColor: globals.appTextColor,
                              color: Theme.of(context).accentColor,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 60,
                        ),
                        Column(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                Appointmentsavedetails apptSaveDet =
                                    new Appointmentsavedetails(
                                        widget.appDetail.PatientCode,
                                        widget.appDetail.PatientCode,
                                        widget.appDetail.DoctorCode,
                                        DateFormat('yyyy-MM-dd')
                                            .format(widget.appDetail.ApptDate),
                                        widget.appDetail.SlotName,
                                        widget.appDetail.SlotNumber,
                                        widget.appDetail.DoctorSlotFromTime,
                                        widget.appDetail.DoctorSlotToTime,
                                        "",
                                        "",
                                        "HCALLPAYCOD",
                                        'H01',
                                        widget.appDetail.AppointmentType,
                                        widget.appDetail.SlotTimeLabel,
                                        widget.appDetail.PatientName,
                                        widget.appDetail.DoctorName,
                                        widget.doctorDet.doctorPhoto,
                                        widget.doctorDet.designation,
                                        widget.doctorDet.qualification,
                                        _getUserData("Age"),
                                        _getUserData("Gender"),
                                        widget.appDetail.PatientMobile,
                                        widget.appDetail.PatientEmail,
                                        widget.appDetail.SlotDuration,
                                        "",
                                        0,
                                        "","","","");

                                createContact(apptSaveDet);
                              },
                              child: Text('PAY AT HOSPITAL'),
                              textColor: globals.appTextColor,
                              color: Theme.of(context).accentColor,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
}
