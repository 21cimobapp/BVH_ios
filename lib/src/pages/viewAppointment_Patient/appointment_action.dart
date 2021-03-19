import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentAction extends StatefulWidget {
  final DocumentSnapshot appt;
  final Function() onViewClick;
  @override
  _AppointmentActionState createState() => _AppointmentActionState();

  const AppointmentAction(
      {Key key, @required this.appt, @required this.onViewClick})
      : super(key: key);
}

class _AppointmentActionState extends State<AppointmentAction> {
  TextStyle get bodyTextStyle => TextStyle(
        //color: mainTextColor,
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  checkIfConsultationExpired(Timestamp tDate, String appointmentStatus) {
    DateTime currentDate =
        DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());

    if (tDate.toDate().difference(currentDate).inDays < 0) {
      if (appointmentStatus != "DONE" && appointmentStatus != "CANCELLED") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // return (widget.appt.data["appointmentStatus"] == 'WAITING' &&
    //         checkIfConsultationExpired(widget.appt.data["apptDate"],
    //                 widget.appt.data["appointmentStatus"]) ==
    //             false)
    //     ? showAction(1)
    //     : showAction(2);
    return showAction(2);
  }

  showAction(index) {
    if (index == 1) {
      return Container(
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              color: Colors.orangeAccent),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: MaterialButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Waiting.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Enter into Waiting Area".toUpperCase(),
                      style: bodyTextStyle.copyWith(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  print('Button was pressed');
                }),
          ));
    } else if (index == 2) {
      return Container(
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              color: Colors.grey[400]),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: MaterialButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "View details".toUpperCase(),
                      style: bodyTextStyle.copyWith(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  widget.onViewClick();
                }),
          ));
    }
  }
}
