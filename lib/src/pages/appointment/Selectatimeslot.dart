import 'dart:convert';
//import 'package:civideoconnectapp/data_models/Doctors.dart';
import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/appointment/Conformappointment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:civideoconnectapp/utils/Database.dart';

class Selectatimeslot extends StatefulWidget {
  final DoctorData doctorDet;
  final String appointmenttType;

  const Selectatimeslot({Key key, this.doctorDet, this.appointmenttType})
      : super(key: key);

  @override
  _SelectatimeslotState createState() => _SelectatimeslotState();
}

class _SelectatimeslotState extends State<Selectatimeslot> {
  DateTime selectedDate = DateTime.now();
  //final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); //added line
  List<PatientAppointment> _appointment = List<PatientAppointment>();
  DatePickerController _controller = DatePickerController();
  DateTime selectedAppointmentDate = DateTime.now();
  PatientAppointmentdetails apptDet;
  int consultationFee;
  List<DoctorSessions> sessionDet = List<DoctorSessions>();
  Iterable<TimeOfDay> slots;
  // Future<List<PatientAppointment>> apiData(selectedAppointmentDate) async {
  //   var url = "${globals.apiHostingURL}/Patient/GetDoctorsSlot";
  //   var response = await http.post(url, body: {
  //     "DoctorCode": "${widget.doctorDet.doctorCode}",
  //     "ApptRqstDate": "$selectedAppointmentDate",
  //     "AppointmentType": "All",
  //     "OrgnCode": "ABCH"
  //   });

  //   var extractdata = jsonDecode(response.body)['doctorSlots'];
  //   print(extractdata);
  //   var doc = List<PatientAppointment>();
  //   if (response.statusCode == 200) {
  //     var patientJson = json.decode(response.body)['doctorSlots'];
  //     if (patientJson != null) {
  //       for (var notejson in patientJson) {
  //         doc.add(PatientAppointment.fromJson(notejson));
  //       }
  //     }
  //   }
  //   return doc;
  //   //var extractdata = jsonDecode(response.body);
  //   //print(extractdata);
  // }

  @override
  void initState() {
    super.initState();

    //apptDet

    // apiData(DateTime.now()).then((value) {
    //   setState(() {
    //     _appointment.addAll(value);
    //   });
    // });

    getSlots(DateTime.now());
  }

  getSlots(DateTime date) async {
    await DatabaseMethods()
        .getDoctorSessions(widget.doctorDet.doctorCode,
            widget.appointmenttType == "VIDEOCONSULT" ? 1 : 0)
        .then((value) => {sessionDet = value});

    generateSlots(date);
  }

  generateSlots(DateTime date) async {
    List<PatientAppointment> _appt = List<PatientAppointment>();
    List<DoctorSessions> sessionsForDay = List<DoctorSessions>();
    List<AppointmentSlots> aSlots = List<AppointmentSlots>();

    String sDay = DateFormat('EEE').format(date).toUpperCase();

    await DatabaseMethods()
        .getDoctorAppointmentSlots(
            widget.doctorDet.doctorCode,
            DateFormat('yyyy-MM-dd')
                .parse(DateFormat('yyyy-MM-dd').format(date)))
        .then((value) => {aSlots.addAll(value)});

    sessionsForDay
        .addAll(sessionDet.where((element) => element.sessionDay == sDay));

    for (int i = 0; i < sessionsForDay.length; i++) {
      slots = getTimes(
          stringToTimeOfDay(sessionsForDay[i].startTime),
          stringToTimeOfDay(sessionsForDay[i].endTime),
          new Duration(minutes: sessionsForDay[i].slotDuration));

      slots.forEach((element) {
        PatientAppointment s = PatientAppointment(
            isSlotBooked(date, aSlots, element) == false ? "1" : "0",
            sessionsForDay[i].sessionTiming,
            timeOfDayToString(element),
            timeOfDayToString(element),
            timeOfDayToString(element),
            widget.appointmenttType,
            sessionsForDay[i].slotDuration,
            sessionsForDay[i].sessionTiming,
            sessionsForDay[i].sessionTimingID,
            sessionsForDay[i].consultationFee);

        _appt.add(s);
      });
    }
    setState(() {
      _appointment = _appt;
      if (sessionsForDay != null) if (sessionsForDay.length > 0)
        consultationFee = sessionsForDay[0].consultationFee;
    });
  }

  bool isSlotBooked(date, List<AppointmentSlots> aSlots, currSlot) {
    List<AppointmentSlots> sList = List<AppointmentSlots>();

    DateTime t1 = DateFormat('yyyy-MM-dd hh:mm a').parse(
        "${DateFormat('yyyy-MM-dd').format(date)} ${timeOfDayToString(currSlot)}");

    if (t1.isBefore(DateTime.now()))
      return true;
    else {
      sList.addAll(aSlots.where((element) =>
          DateFormat('hh:mm a').parse(
              DateFormat('hh:mm a').format(element.doctorSlotFromTime)) ==
          DateFormat('hh:mm a').parse(timeOfDayToString(currSlot))));

      if (sList == null)
        return false;
      else if (sList.length > 0) {
        return true;
      } else
        return false;
    }
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"

    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  String timeOfDayToString(TimeOfDay tod) {
    if (tod == null) return "";

    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  Iterable<TimeOfDay> getTimes(
      TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;

    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour ||
        (hour == endTime.hour && minute <= endTime.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //  floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.replay),
        //   onPressed: () {
        //     _controller.animateToSelection();
        //   },
        // ),
        appBar: AppBar(
          //backgroundColor: Theme.of(context).primaryColor,
          title: Text("Select a time slot"),
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Column(
          children: <Widget>[
            // Container(
            Align(
              alignment: Alignment.centerLeft + Alignment(0, .8),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                      (widget.appointmenttType == "VIDEOCONSULT")
                          ? "Schedule Video Consultation"
                          : "Schedule Personal Visit",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      )),
                ),
              ),
            ),

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
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Row(children: <Widget>[
                        Container(
                          height: 60,
                          width: 60,
                          child: CircleAvatar(
                              child: ClipOval(child: getDoctorPhoto(0))),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 270,
                              child: Text(widget.doctorDet.doctorName,
                                  style: Theme.of(context).textTheme.subtitle2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              widget.doctorDet.qualification,
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              consultationFee == null
                                  ? ""
                                  : "Consultation Fee: Rs. ${consultationFee.toString()}",
                              //style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    // Divider(
                    //   height: 10.0,
                    //   indent: 5.0,
                    //   color: Colors.black87,
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Text(widget.doctorDet.designation,
                    //     style: Theme.of(context).textTheme.subtitle2)
                  ])),
            ),

            SizedBox(
              width: 10,
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Text("You Selected:"),
                  // Padding(
                  //   padding: EdgeInsets.all(10),
                  // ),
                  // Text(selectedAppointmentDate.toString()),
                  // Padding(
                  //   padding: EdgeInsets.all(20),
                  // ),
                  Container(
                    child: DatePicker(
                      DateTime.now().add(Duration(days: 0)),
                      width: 50,
                      height: 90,
                      controller: _controller,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: Theme.of(context).accentColor,
                      selectedTextColor: globals.appTextColor,
                      onDateChange: (date) {
                        // New date selected
                        setState(() {
                          selectedAppointmentDate = date;
                          _appointment = null;
                        });

                        generateSlots(selectedAppointmentDate);
                        // apiData(date).then((value) {
                        //   setState(() {
                        //     _appointment.clear();
                        //     _appointment.addAll(value);
                        //   });
                        // });
                      },
                    ),
                  ),
                ],
              ),
            ),
            (isHoliday() == false)
                ? Column(
                    children: <Widget>[
                      new Text('Pick Time Slot',
                          style: TextStyle(fontSize: 15)),
                      (_appointment != null)
                          ? (_appointment.length > 0)
                              ? Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: showSlots(),
                                  ),
                                )
                              : Container(child: Text("No slots available"))
                          : Container(child: Text("Loading slots...")),
                    ],
                  )
                : Container(child: Text("No slots available (Holiday)")),
          ],
        ))));
  }

  bool isHoliday() {
    List<HolidayData> hList = List<HolidayData>();

    hList.addAll(globals.holidayList
        .where((element) => element.holidayDate == selectedAppointmentDate));

    if (hList == null)
      return false;
    else if (hList.length > 0)
      return true;
    else
      return false;
  }

  showSlots() {
    List<Widget> sessions = [];

    sessions.addAll(generateSlot(0));
    sessions.addAll(generateSlot(1));
    sessions.addAll(generateSlot(2));
    return sessions;
  }

  generateSlot(session) {
    List<PatientAppointment> _sessionfilter = List<PatientAppointment>();
    List<Widget> sessionSlot = [];
    var size = MediaQuery.of(context).size;
    print(size);
    final double itemHeight = (size.height - kToolbarHeight - 24) / 10;
    print(itemHeight);
    final double itemWidth = size.width / 2;
    print(itemWidth);

    _sessionfilter.addAll(
        _appointment.where((element) => element.SlotNumberID == session));
    if (_sessionfilter.length > 0) {
      sessionSlot.add(SizedBox(
        height: 10,
      ));
      sessionSlot.add(
          Container(child: Text("${_sessionfilter[0].SlotNumber} session")));

      sessionSlot.add(SizedBox(
        height: 10,
      ));

      sessionSlot.add(Container(
          child: GridView.count(
        // crossAxisCount is the number of columns
        crossAxisCount: 3,
        childAspectRatio: (itemWidth / itemHeight),
        controller: new ScrollController(keepScrollOffset: false),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        // This creates two columns with two items in each column
        children: List.generate(_sessionfilter.length, (index) {
          return GestureDetector(
            onTap: () {
              if (_sessionfilter[index].SlotAvailable == "1")
                confirmAppointment(_sessionfilter[index]);
            },
            //  child: Card(
            // elevation: 2.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: _sessionfilter[index].SlotAvailable == "1"
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200]),
                borderRadius: BorderRadius.circular(5.0),
              ),
              margin: new EdgeInsets.all(4.0),
              child: new Center(
                //child: new Text(_sessionfilter[index].SlotTimeLabel.split('-')[0]),
                child: new Text(_sessionfilter[index].SlotTimeLabel,
                    style: TextStyle(
                      color: _sessionfilter[index].SlotAvailable == "1"
                          ? Colors.black
                          : Colors.grey[400],
                    )),
              ),
            ),
            // ),
          );
        }),
      )));
    } else
      sessionSlot.add(Container());

    return sessionSlot;
  }

  confirmAppointment(PatientAppointment selectedSlot) {
    apptDet = new PatientAppointmentdetails(
        globals.personCode,
        "${_getUserData("FirstName")} ${_getUserData("LastName")}",
        globals.personGender,
        globals.mobileNumber,
        globals.personEmailID,
        widget.doctorDet.doctorCode,
        widget.doctorDet.doctorName,
        widget.doctorDet.qualification,
        selectedAppointmentDate,
        selectedSlot.SlotTimeLabel,
        selectedSlot.SlotNumber,
        "${DateFormat('yyyy-MM-dd').format(selectedAppointmentDate)} ${selectedSlot.DoctorSlotFromTime}",
        "${DateFormat('yyyy-MM-dd').format(selectedAppointmentDate)} ${selectedSlot.DoctorSlotToTime}",
        selectedSlot.DoctorSlotFromTime,
        selectedSlot.DoctorSlotToTime,
        selectedSlot.SlotTimeLabel,
        widget.appointmenttType,
        selectedSlot.SlotDuration,
        selectedSlot.ConsultationFee,'','','');

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Conformappointment(
            appDetail: apptDet,
            doctorDet: widget.doctorDet,
          ),
        ));
  }

  Image getDoctorPhoto(i) {
    if (widget.doctorDet.doctorPhoto == "") {
      return Image.asset("assets/doctor_defaultpic.png");
    } else {
      return Image.memory(base64Decode(widget.doctorDet.doctorPhoto));
    }
  }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }
}
