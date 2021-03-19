import 'dart:convert';
//import 'package:flutter_email_sender/flutter_email_sender.dart';

//import 'package:civideoconnectapp/data_models/Doctors.dart';

import 'package:civideoconnectapp/src/pages/Services/RazorPay/FailedPage.dart';
import 'package:civideoconnectapp/src/pages/Services/RazorPay/FailedApptBookPage.dart';
import 'package:civideoconnectapp/src/pages/Services/RazorPay/Razorpay.dart';
import 'package:civideoconnectapp/src/pages/Services/RazorPay/SuccessPage.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_local_notifications/src/platform_specifics/android/message.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/data_models/BookingDetails.dart';
import '../paramcombine1.dart';
import 'package:uuid/uuid.dart';
import '../class.dart';
//import 'package:mailer/src/entities/message.dart'as Message;

class CheckRazor extends StatefulWidget {
  final BookingDetails bookingDetails;
  final List<String> services;
  const CheckRazor({Key key, this.bookingDetails, this.services})
      : super(key: key);
  @override
  _CheckRazorState createState() => _CheckRazorState();
}

class _CheckRazorState extends State<CheckRazor> {
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
      'Service Booked',
      '',
      platform,
      payload: ' ',
    );
  }

//Future<Appointmentsavedetails> saveappdetail;

  // String _serviceUrl = '${globals.apiHostingURL}/Patient/SaveAppointment';
  // static final _headers = {'Content-Type': 'application/json'};

  Razorpay _razorpay = Razorpay();
  var options;
  Future payData() async {
    try {
      _razorpay.open(options);
    } catch (e) {
      print("errror occured here is ......................./:$e");
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("payment has succedded");

    String orderNumber = Uuid().v4().toString();
    BookingSaveDetails apptSaveDet = new BookingSaveDetails(
        orderNumber,
        DateTime.now(),
        widget.bookingDetails.PatientCode,
        widget.bookingDetails.BookingDate,
        widget.bookingDetails.SlotName,
        widget.bookingDetails.SlotNumber,
        widget.bookingDetails.SlotFromTime,
        widget.bookingDetails.SlotToTime,
        "HCALLPAYONLINE",
        'H01',
        widget.bookingDetails.ServiceType,
        widget.bookingDetails.BookingType,
        widget.bookingDetails.SlotTimeLabel,
        widget.bookingDetails.PatientName,
        _getUserData("Age"),
        _getUserData("Gender"),
        widget.bookingDetails.BookingAddress1,
        widget.bookingDetails.BookingAddress2,
        widget.bookingDetails.BookingAddress3,
        widget.bookingDetails.BookingAddress4,
        widget.bookingDetails.Remarks,
        response.paymentId,
        widget.bookingDetails.TotalAmount,
        response.signature);

    createContact(response, apptSaveDet);

    _razorpay.clear();
  }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }

  createContact(PaymentSuccessResponse paymentResponse,
      BookingSaveDetails savedetail) async {
    try {
      Map<String, dynamic> appDetail = {
        "orderNumber": savedetail.OrderNumber,
        "orderDate": savedetail.OrderDate,
        "ServiceType": savedetail.ServiceType,
        "bookingDate": savedetail.BookingDate,
        "patientCode": savedetail.PatientCode,
        "slotName": savedetail.SlotName,
        "slotNumber": savedetail.SlotNumber,
        "slotFromTime": savedetail.SlotFromTime == null
            ? null
            : DateFormat('yyyy-MM-dd hh:mm a').parse(savedetail.SlotFromTime),
        "slotToTime": savedetail.SlotToTime == null
            ? null
            : DateFormat('yyyy-MM-dd hh:mm a').parse(savedetail.SlotToTime),
        "organizationCode": savedetail.OrganizationCode,
        "paymentModeCode": savedetail.PaymentModeCode,
        "bookingType": savedetail.BookingType,
        "patientName": savedetail.PatientName,
        "patientAge": savedetail.PatientAge,
        "patientGender": savedetail.PatientGender,
        "bookingAddress1": savedetail.BookingAddress1,
        "bookingAddress2": savedetail.BookingAddress2,
        "bookingAddress3": savedetail.BookingAddress3,
        "bookingAddress4": savedetail.BookingAddress4,
        "remark": savedetail.Remarks,
        "paymentId": savedetail.paymentID,
        "paymentAmount": savedetail.paymentAmount,
        "paymentSignature": savedetail.signature,
        "services": widget.services
      };
      DatabaseMethods().addBooking(appDetail, savedetail.OrderNumber);

      bloc.allData1.clear();

      showNotification();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SuccessPage(
              response: paymentResponse,
              bookingSaveDetails: savedetail,
              services: widget.services),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Server Exception!!!');
      print(e);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              FailedApptBookPage(response: paymentResponse),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("payment has error");
    // Do something when payment fails
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => FailedPage(response: response),
      ),
      (Route<dynamic> route) => false,
    );
    _razorpay.clear();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("payment has externalWallet33333333333333333333333333");

    _razorpay.clear();
    // Do something when an external wallet is selected
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

    //appDetail = saveappdetail();

    options = {
      'key':
          "rzp_test_tf9U7AbQx8EyjV", // Enter the Key ID generated from the Dashboard

      'amount': widget.bookingDetails.TotalAmount == null
          ? 0
          : widget.bookingDetails.TotalAmount *
              100, //in the smallest currency sub-unit.
      //'amount': 100,
      'name': 'Bhaktivedanta Hospital',

      'currency': "INR",
      'theme.color': "#F37254",
      'buttontext': "Pay with Razorpay",
      'description': 'Online Payment',
      'prefill': {
        'contact': globals.user[0]['MobileNumber'] ?? '',
        'email': globals.user[0]["EmailID"] ?? "",
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    // print("razor runtime --------: ${_razorpay.runtimeType}");
    return Scaffold(
      body: FutureBuilder(
          future: payData(),
          builder: (context, snapshot) {
            return Container(
              child: Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
