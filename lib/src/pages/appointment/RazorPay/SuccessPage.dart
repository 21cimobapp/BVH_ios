import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/appointment/RazorPay/Razorpay.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/doctor_card_appt.dart';

import 'package:civideoconnectapp/src/pages/appointment_new/rounded_shadow.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/syles.dart';
import 'package:civideoconnectapp/src/pages/index/index_new.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

class SuccessPage extends StatefulWidget {
  final PaymentSuccessResponse response;
  final PatientAppointmentdetails appDetail;
  final String appointmentNumber;

  const SuccessPage({Key key, this.response, this.appDetail,this.appointmentNumber}) : super(key: key);

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
    height: 1.5,
    letterSpacing: .2,
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
                  Text("Appointment Confirmed",
                      style: Styles.text(16, Colors.black, true)),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Your Booking has been successful",
                      style: Styles.text(16, Colors.black, true)),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: DoctorCardAppt(apptData: widget.appDetail),
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
            width: 20,
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
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appointment Number ', style: titleTextStyle),
                      Text(widget.appointmentNumber, //snapshot.data.documents[appointments],
                          style: contentTextStyle),
                      SizedBox(height: 20),
                      Text('Patient Code'.toUpperCase(), style: titleTextStyle),
                      Text(widget.appDetail.PatientCode,
                          style: contentTextStyle),
                      SizedBox(height: 20),
//                      Text('Appointment Date'.toUpperCase(),
//                          style: titleTextStyle),
//                      Text(
//                        // Changed by Abhi for firebase to API
////                          DateFormat('EEE, MMM d yyyy')
////                              .format(widget.appDetail.ApptDate)
////                          .toUpperCase(),
//                          widget.appDetail.ApptDate.toString(),
//                          // End Changed by Abhi for firebase to API
//                          style: contentTextStyle),
//                      SizedBox(height: 20),
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
                            "${widget.appDetail.ConsultationFee.toString()}",
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
                        //color: Colors.blue,
                        width: 150,
                        child: Text(
                          widget.appDetail.PatientName,
                          style: contentTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Appointment DateTime'.toUpperCase(),
                          style: titleTextStyle),
                      Text(
                        // Changed by Abhi for firebase to API
//                          DateFormat.jm()
//                              .format(DateFormat('yyyy-MM-dd hh:mm a')
//                                  .parse(widget.appDetail.DoctorSlotFromTime))
                        // End Changed by Abhi for firebase to API

                          widget.appDetail.DoctorSlotFromTime
                              .toUpperCase(),
                          style: contentTextStyle),
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
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(5.0),
          //   color: Colors.grey[400],
          //   child: Center(
          //     child: GestureDetector(
          //         onTap: () {
          //           Navigator.pop(context);
          //         },
          //         child: Text("Change Date and Time", style: contentTextStyle)),
          //   ),
          // )
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
