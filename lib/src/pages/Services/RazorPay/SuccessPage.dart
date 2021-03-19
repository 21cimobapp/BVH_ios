import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/Services/RazorPay/Razorpay.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/doctor_card_appt.dart';

import 'package:civideoconnectapp/src/pages/appointment_new/rounded_shadow.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/syles.dart';
import 'package:civideoconnectapp/src/pages/index/index_new.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/data_models/BookingDetails.dart';

class SuccessPage extends StatefulWidget {
  final PaymentSuccessResponse response;
  final BookingSaveDetails bookingSaveDetails;
  final List<String> services;

  const SuccessPage(
      {Key key, this.response, this.bookingSaveDetails, this.services})
      : super(key: key);

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
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
    fontSize: 14,
    height: 1,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: _buildAppBar(),
        //  backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          //color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    "assets/images/AppointmentSuccess.png",
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Booking Confirmed",
                      style: Styles.text(16, Colors.black, true)),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Your Booking has been successful",
                      style: Styles.text(16, Colors.black, true)),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 10),
                        child: appointmentDetailsBox()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ButtonTheme(
                        //minWidth: 250,
                        height: 40,
                        child: FlatButton(
                          //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => IndexNew()));
                          },
                          color: Colors.orangeAccent,
                          disabledColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Text("back to home".toUpperCase(),
                              style: Styles.text(16, Colors.white, true)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  _buildOrderItems() {
    List<Widget> servicesWidget = [];

    for (int i = 0; i < widget.services.length; i++) {
      servicesWidget.add(Container(
          child: Text('${i + 1} - ${_destructureName(widget.services[i])}')));
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: servicesWidget,
      ),
    );
  }

  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('##'));
  }

  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('##') + 2);
  }

  _buildLogoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
        //   child: Image.asset(
        //     order.serviceType == "LABTEST"
        //         ? 'assets/images/Pickup.png'
        //         : 'assets/images/Hospital.png',
        //     width: 20,
        //   ),
        // ),
        Text(
            widget.bookingSaveDetails.ServiceType == "LABTEST"
                ? 'Lab Test/Health Checkup Package'.toUpperCase()
                : widget.bookingSaveDetails.ServiceType == "COUNSELLING"
                    ? "counselling"
                    : widget.bookingSaveDetails.ServiceType == "KIRTAN"
                        ? "kirtan booking"
                        : widget.bookingSaveDetails.ServiceType ==
                                "HOMESERVICES"
                            ? "Home services"
                            : 'Others'.toUpperCase(),
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

  _buildLogoSamplePickup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Image.asset(
            widget.bookingSaveDetails.BookingType == "HCOLL"
                ? 'assets/images/InPerson.png'
                : 'assets/images/InPerson.png',
            width: 10,
          ),
        ),
        Text(
            widget.bookingSaveDetails.BookingType == "HCOLL"
                ? 'HOME COLLECTION'.toUpperCase()
                : 'WALK-IN'.toUpperCase(),
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
            //color: Colors.white,
            child: _buildLogoHeader(),
          ),
          Container(
            height: 30,
            color: Colors.white,
            child: _buildLogoSamplePickup(),
          ),
          Container(
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              width: double.infinity,
              //height: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID'.toUpperCase(), style: titleTextStyle),
                      Text(
                          //widget.bookingDetails.book,
                          "7b29f2ba-67e5-4667-8032-82419fd21330",
                          style: contentTextStyle),
                    ],
                  ),
                ],
              )),
          Container(
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              width: double.infinity,
              //height: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Date'.toUpperCase(), style: titleTextStyle),
                      Text(
                          DateFormat('EEE, MMM d yyyy')
                              .format(widget.bookingSaveDetails.BookingDate)
                              .toUpperCase(),
                          style: contentTextStyle),
                    ],
                  ),
                ],
              )),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            width: double.infinity,
            //height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pateint Code'.toUpperCase(), style: titleTextStyle),
                      Text(widget.bookingSaveDetails.PatientCode,
                          style: contentTextStyle),
                      SizedBox(height: 20),
                      Text('Charges'.toUpperCase(), style: titleTextStyle),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/Rs.png',
                            width: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${widget.bookingSaveDetails.paymentAmount.toString()}",
                            style: contentTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
                        width: 200,
                        child: Text(
                          widget.bookingSaveDetails.PatientName,
                          style: contentTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Payment ID'.toUpperCase(), style: titleTextStyle),
                      Text("${widget.response.paymentId}",
                          style: contentTextStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
          widget.bookingSaveDetails.BookingType == "HCOLL"
              ? Container(
                  padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  //height: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sample Pickup Date and Time'.toUpperCase(),
                              style: titleTextStyle),
                          Text(
                              "${DateFormat('EEE, MMM d yyyy').format(widget.bookingSaveDetails.BookingDate).toUpperCase()} (${widget.bookingSaveDetails.SlotTimeLabel})",
                              style: contentTextStyle),
                        ],
                      ),
                    ],
                  ))
              : Container(
                  padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  //height: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Appointment Date'.toUpperCase(),
                              style: titleTextStyle),
                          Text(
                              "${DateFormat('EEE, MMM d yyyy').format(widget.bookingSaveDetails.BookingDate).toUpperCase()})",
                              style: contentTextStyle),
                        ],
                      ),
                    ],
                  )),
          _buildOrderItems(),
        ],
      ),
    );
  }

  Image getDoctorPhoto(i) {
    //if (appDetail.DoctorPhoto == "") {
    return Image.asset("assets/doctor_defaultpic.png");
    //} else {
    //  return Image.memory(base64Decode(appDetail.DoctorPhoto));
    //}
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
        child: Text('Success'.toUpperCase(),
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
