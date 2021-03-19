import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'demo_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDetails extends StatelessWidget {
  final DocumentSnapshot appt;
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
    fontSize: 15,
    height: 1.8,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );

  AppointmentDetails(this.appt);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pateint Code'.toUpperCase(), style: titleTextStyle),
                  Text(appt.data["patientCode"], style: contentTextStyle),
                  SizedBox(height: 20),
                  Text('Appointment Date'.toUpperCase(), style: titleTextStyle),
                  Text(
                      DateFormat('EEE, MMM d yyyy')
                          .format(appt.data["apptDate"].toDate())
                          .toUpperCase(),
                      style: contentTextStyle),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient Name'.toUpperCase(), style: titleTextStyle),
                  Container(
                    width: 160,
                    child: Text(
                      appt.data["patientName"],
                      style: contentTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Appointment Time'.toUpperCase(), style: titleTextStyle),
                  Text(
                      DateFormat.jm()
                          .format(appt.data["doctorSlotFromTime"].toDate())
                          .toUpperCase(),
                      style: contentTextStyle),
                ],
              ),
            ),
          ],
        ),
      );
}