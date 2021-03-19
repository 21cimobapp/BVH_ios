import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'demo_data.dart';
import 'appointment_action.dart';
import 'appointment_details.dart';
import 'appointment_summary.dart';
import 'folding_appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment extends StatefulWidget {
  static const double nominalOpenHeight = 400;
  static const double nominalClosedHeight = 160;
  final DocumentSnapshot appt;
  final Function onClick;
  final Function onViewClick;

  const Appointment(
      {Key key,
      @required this.appt,
      @required this.onClick,
      @required this.onViewClick})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  AppointmentSummary frontCard;
  AppointmentSummary topCard;
  AppointmentDetails middleCard;
  AppointmentAction bottomCard;
  bool _isOpen;

  Widget get backCard => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0), color: Color(0xffdce6ef)));

  @override
  void initState() {
    super.initState();
    _isOpen = false;

    frontCard = AppointmentSummary(appt: widget.appt);
    middleCard = AppointmentDetails(widget.appt);
    bottomCard =
        AppointmentAction(appt: widget.appt, onViewClick: widget.onViewClick);
  }

  @override
  Widget build(BuildContext context) {
    return FoldingAppointment(
        entries: _getEntries(), isOpen: _isOpen, onClick: _handleOnTap);
  }

  List<FoldEntry> _getEntries() {
    return [
      FoldEntry(height: 160.0, front: topCard),
      FoldEntry(height: 160.0, front: middleCard, back: frontCard),
      FoldEntry(height: 60.0, front: bottomCard, back: backCard)
    ];
  }

  void _handleOnTap() {
    widget.onClick();
    setState(() {
      _isOpen = !_isOpen;
      topCard = AppointmentSummary(
          appt: widget.appt, theme: SummaryTheme.dark, isOpen: _isOpen);
    });
  }
}
