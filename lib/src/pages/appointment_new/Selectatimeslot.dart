import 'dart:convert';
//import 'package:civideoconnectapp/data_models/Doctors.dart';
import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/Conformappointment.dart';

import 'package:civideoconnectapp/src/pages/appointment_new/doctor_card_mini.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/rounded_shadow.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/syles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:civideoconnectapp/utils/Database.dart';

class Selectatimeslot extends StatefulWidget {
  final DoctorData doctorDet;
  final String appointmentType;
  final String organizationCode;
  @override
  _SelectatimeslotState createState() => _SelectatimeslotState();

  const Selectatimeslot({Key key, this.doctorDet, this.appointmentType,this.organizationCode})
      : super(key: key);
}

class _SelectatimeslotState extends State<Selectatimeslot> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  DateTime selectedDate = DateTime.now();

  //final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); //added line
  List<PatientAppointment> _appointment = List<PatientAppointment>();
  DatePickerController _controller = DatePickerController();
  final TextEditingController _datecontroller = new TextEditingController(); // added by vrushali
  DateTime selectedAppointmentDate = DateTime.now();
  PatientAppointmentdetails apptDet;
  int consultationFee;
  List<DoctorSessions> sessionDet = List<DoctorSessions>();
  Iterable<TimeOfDay> slots;
  bool isDisabled = true;
  PatientAppointment selectedSlot;

  Future<List<PatientAppointment>> apiData(selectedAppointmentDate) async {
//     var url = "${globals.apiHostingURL}/Patient/GetDoctorsSlot";
    var apiDate = DateFormat('yyyy-MM-dd').format(selectedAppointmentDate);
    var isVideoConsult = widget.appointmentType == "VIDEOCONSULT" ? 1 : 0;
    var url = "${globals
        .apiHostingURLBVH}/appointment/GetSlots?DoctorCode=${widget.doctorDet
        .doctorCode}&DeptCode=${widget.doctorDet.deptCode}"
        "&OrganizationCode=${widget
        .organizationCode}&ApptDate=$apiDate&Source=M&video=$isVideoConsult";
    var response = await http.get(url,
        headers: {"Authorization": 'Bearer ${globals.tokenKey}'}
//         body: {
//       "DoctorCode": "${widget.doctorDet.doctorCode}",
//       "ApptRqstDate": "$selectedAppointmentDate",
//       "AppointmentType": "All",
//       "OrgnCode": "ABCH"
//     }
    );

//     var extractdata = jsonDecode(response.body)['ApptSlotDate'];
//     print(extractdata);
    var doc = List<PatientAppointment>();
    if (response.statusCode == 200) {
      List patientJson = json.decode(
          response.body)['ApptSlotDate'][0]['ApptSlotDateDetail'];
      if (patientJson != null) {
        for (var notejson in patientJson) {
          doc.add(PatientAppointment.fromJsonnew(notejson));
        }
      }
    }
    return doc;
    //var extractdata = jsonDecode(response.body);
    //print(extractdata);
  }

  // added by vrushali
  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  // added by vrushali
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = DateFormat('dd-MM-yyyy').parse(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? now
        : initialDate);

    //var result
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime.now(),
        lastDate: new DateTime(2022)
    ); //new DateTime.now());


    //if (result == null) return;

//    setState(() {
//      _datecontroller.text = new DateFormat.yMd().format(result);
//    });

    if (picked != null && picked != initialDate)
      setState(() {
        _datecontroller.text = new DateFormat('dd-MM-yyyy').format(picked);
        //initialDate = picked;
        selectedAppointmentDate = picked;
        _appointment.removeRange(0, _appointment.length);

        apiData(selectedAppointmentDate).then((value1) {
          setState(() {
            _appointment.addAll(value1);
          });
        });
      });
  }

  @override
  void initState() {
    super.initState();

//    apptDet

    _datecontroller.text = new DateFormat('dd-MM-yyyy').format(
        DateTime.now()); // added by vrushali
    apiData(DateTime.now()).then((value) {
      setState(() {
        _appointment.addAll(value);
      });
    });

//    getSlots(DateTime.now());
  }

  getSlots(DateTime date) async {
    await DatabaseMethods()
        .getDoctorSessions(widget.doctorDet.doctorCode,
        widget.appointmentType == "VIDEOCONSULT" ? 1 : 0)
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
            widget.appointmentType,
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
        "${DateFormat('yyyy-MM-dd').format(date)} ${timeOfDayToString(
            currSlot)}");

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

  Iterable<TimeOfDay> getTimes(TimeOfDay startTime, TimeOfDay endTime,
      Duration step) sync* {
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
        backgroundColor: _backgroundColor,
        //  floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.replay),
        //   onPressed: () {
        //     _controller.animateToSelection();
        //   },
        // ),
        appBar: _buildAppBar(),
        body: Stack(

          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: 40,
                      width: double.infinity,
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Select Slots",
                              style: TextStyle(fontSize: 16)),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: DoctorCardMini(doctorData: widget.doctorDet),
                  ),
//                  Padding(
//                    padding:
//                        const EdgeInsets.only(left: 15, right: 15, bottom: 60),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //child :
                        Expanded(
                          child: Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: RoundedShadow.fromRadius(
                                      12,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 30,
                                            color: Colors.white,
                                            child: _buildLogoHeader(),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5.0),
                                            color: Colors.white,
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[

                                                new Row(children: <Widget>[
                                                  //added by vrushali
                                                  SizedBox(width: 40.0),
                                                  Container(
                                                    width: 100,
                                                    child:
                                                    Text("Appointment Date",
                                                        style: TextStyle( //fontWeight: FontWeight.bold,
                                                            color: Color(
                                                                0xFF083e64))),),
                                                  SizedBox(width: 10.0),
                                                  new Container(
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width - 300,
                                                      child:
                                                      new TextField(
                                                        decoration: new InputDecoration(
//                                                  icon: const Icon(Icons.calendar_today),
//                                                  //hintText: 'Enter your date of birth',
                                                          // labelText: 'Appointment Date',
                                                        ),
                                                        //textInputAction :TextInputAction.none,
                                                        controller: _datecontroller,
                                                        readOnly: true,
//                                                onTap: _chooseDate(context, _datecontroller.text),
                                                        //keyboardType: TextInputType.datetime,
//                                                onChanged: (content) {
//                                                  setState(() {
//                                                    selectedAppointmentDate = content as DateTime;//date as DateTime ;
//                                                    print("date: $content");
//                                                    _appointment.removeRange(0, _appointment.length);
//                                                  });
//                                                  apiData(selectedAppointmentDate).then((value1) {
//                                                    setState(() {
//                                                      _appointment.addAll(value1);
//                                                    });
//                                                  });
//                                                },

                                                        //onSaved: (val) =>


                                                        //newContact.DateOfBirth = convertToDate(val),
                                                      )),
                                                  new IconButton(
                                                    icon: new Icon(
                                                        Icons.calendar_today),
                                                    tooltip: 'Choose date',
                                                    onPressed: (() {
                                                      _chooseDate(context,
                                                          _datecontroller.text);
                                                    }),
                                                  )
                                                ]),

//                                        DatePicker( // commented by vrushali
//                                          DateTime.now().add(Duration(days: 0)),
//                                          width: 60,
//                                          height: 100,
//                                          controller: _controller,
//                                          initialSelectedDate: DateTime.now(),
//                                          selectionColor:
//                                              Theme.of(context).accentColor,
//                                          selectedTextColor:
//                                              globals.appTextColor,
//                                          onDateChange: (date) {
//                                            // New date selected
//                                            setState(() {
//                                              selectedAppointmentDate = date;
//                                              _appointment.removeRange(0, _appointment.length);
//                                            });
////                                            apiData(
////                                                selectedAppointmentDate);
//                                            apiData(selectedAppointmentDate).then((value1) {
//                                              setState(() {
//                                                _appointment.addAll(value1);
//                                              });
//                                            });
//                                          },
//                                        ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              color: Colors.white,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                        10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: showSlots(),
                                                    ),
                                                  )
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ]
                  ),

                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              //padding: const EdgeInsets.only(bottom: 18.0),
              //width: 300,
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
                            // Changed by Abhi for BVH API
//                              "${selectedSlot == null ? consultationFee == null ? "" : consultationFee : selectedSlot.ConsultationFee.toString()}",
                              widget.appointmentType == "VIDEOCONSULT"
                                  ? "${widget.doctorDet.VideoConsultCharge}"
                                  : "${widget.doctorDet.VisitConsultCharge}",
                              // End Changed by Abhi for BVH API
                              style: Styles.text(16, Colors.black, true)),
                        ],
                      ),
                    ),
                    ButtonTheme(
                      //minWidth: 250,
                      //height: 40,
                      child: Opacity(
                        opacity: isDisabled ? .5 : 1,
                        child: FlatButton(
                          //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
                          onPressed: isDisabled
                              ? null
                              : () {
                            confirmAppointment(selectedSlot);
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
                                  widget.appointmentType == "VIDEOCONSULT"
                                      ? "assets/images/Video.png"
                                      : "assets/images/InPerson.png",
                                  height: 20,
                                  width: 20),
                              SizedBox(width: 10),
                              Text(
                                  widget.appointmentType == "VIDEOCONSULT"
                                      ? "Book Video Consultation"
                                      : "Book Personal Visit",
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
          ],
        ));
  }

  _buildLogoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Image.asset(
            widget.appointmentType == "VIDEOCONSULT"
                ? 'assets/images/Video.png'
                : 'assets/images/InPerson.png',
            width: 10,
          ),
        ),
        Text(
            widget.appointmentType == "VIDEOCONSULT"
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

    if (isHoliday() == true) {
      sessions.add(Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("No slots available (Holiday)"))));

      return sessions;
    }

    if (_appointment != null) {
      if (_appointment.length > 0) {
        // sessions.add(SizedBox(
        //   height: 10,
        // ));

        sessions.add(Container(
            child: Center(
                child:
                Text('Pick Time Slot', style: TextStyle(fontSize: 15)))));

        sessions.addAll(generateSlot(0));
        // Changed by Abhi for firebase to API
//        sessions.addAll(generateSlot(1));
//        sessions.addAll(generateSlot(2));
        // End Changed by Abhi for firebase to API

        return sessions;
      } else {
        sessions.add(Container(
            width: double.infinity,
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("No slots available"))));

        return sessions;
      }
    } else {
      sessions.add(Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(8.0), child: Text("Loading ..."))));

      return sessions;
    }
  }

  generateSlot(session) {
    List<PatientAppointment> _sessionfilter = List<PatientAppointment>();
    List<Widget> sessionSlot = [];
    var size = MediaQuery
        .of(context)
        .size;
    print(size);
    final double itemHeight = (size.height - kToolbarHeight - 24) / 10;
    print(itemHeight);
    final double itemWidth = size.width / 2;
    print(itemWidth);
// Changed by Abhi for firebase to API
//    _sessionfilter.addAll(
//        _appointment.where((element) => element.SlotNumberID == session));
    _sessionfilter.addAll(_appointment);
    // End Changed by Abhi for firebase to API
    if (_sessionfilter.length > 0) {
      sessionSlot.add(SizedBox(
        height: 10,
      ));
//      sessionSlot.add(
//          Container(child: Text("${_sessionfilter[0].SlotNumber} session")));

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
                  if (_sessionfilter[index].SlotAvailable == "AVL")
                    setState(() {
                      if (selectedSlot == _sessionfilter[index]) {
                        selectedSlot = null;
                        isDisabled = true;
                      } else {
                        selectedSlot = _sessionfilter[index];
                        isDisabled = false;
                      }
                    });
                  //confirmAppointment(_sessionfilter[index]);
                },
                //  child: Card(
                // elevation: 2.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedSlot != null
                        ? selectedSlot == _sessionfilter[index]
                        ? Theme
                        .of(context)
                        .primaryColor
                        : Colors.white
                        : Colors.white,
                    border: Border.all(
                        color: _sessionfilter[index].SlotAvailable == "AVL"
                            ? Theme
                            .of(context)
                            .primaryColor
                            : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  margin: new EdgeInsets.all(4.0),
                  child: new Center(
                    //child: new Text(_sessionfilter[index].SlotTimeLabel.split('-')[0]),
                    child: new Text(_sessionfilter[index].SlotTimeLabel,
                        style: TextStyle(
                          color: _sessionfilter[index].SlotAvailable == "AVL"
                              ? selectedSlot != null
                              ? selectedSlot == _sessionfilter[index]
                              ? Colors.white
                              : Colors.black
                              : Colors.black
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

  confirmAppointment(PatientAppointment selectedSlot) async {
    apptDet = new PatientAppointmentdetails(
        globals.personCode,
        "${_getUserData("FirstName")} ${_getUserData("LastName")}",
        globals.personGender,
        globals.mobileNumber,
        globals.personEmailID,
        widget.doctorDet.doctorCode,
        widget.doctorDet.doctorName,
        widget.doctorDet.designation,
        selectedAppointmentDate,
        selectedSlot.SlotTimeLabel,
        selectedSlot.SlotNumber,
        "${DateFormat('yyyy-MM-dd').format(
            selectedAppointmentDate)} ${selectedSlot.DoctorSlotFromTime}",
//        "${DateFormat('yyyy-MM-dd').format(selectedAppointmentDate)} ${selectedSlot.DoctorSlotToTime}",
        "${DateFormat('yyyy-MM-dd').format(
            selectedAppointmentDate)} ${selectedSlot.DoctorSlotToTime}",
        selectedSlot.DoctorSlotFromTime,
        selectedSlot.DoctorSlotToTime,
        selectedSlot.SlotTimeLabel,
        widget.appointmentType,
        selectedSlot.SlotDuration,
//        selectedSlot.ConsultationFee == null?500:selectedSlot.ConsultationFee
        widget.appointmentType == "VIDEOCONSULT" ? widget.doctorDet
            .VideoConsultCharge.toInt() : widget.doctorDet.VisitConsultCharge
            .toInt(),
        "","",
        widget.organizationCode

    );
    var url1 = "${globals
        .apiHostingURLBVH}/Patient/GetServiceList?DoctorCode=${widget.doctorDet
        .doctorCode}";
    var response1 = await http.get(url1,
        headers: {"Authorization": 'Bearer ${globals.tokenKey}'}
    );

    if (response1.statusCode == 200) {
      List serviceList = json.decode(response1.body);
      print(serviceList.length);
      if (serviceList.isNotEmpty) {
        apptDet.ServiceCode = serviceList[0]['ServiceCode'];
    String aaptDate = DateFormat('yyyy-MM-dd').format(apptDet.ApptDate);
    var url = "${globals.apiHostingURLBVH}/Patient/GetPatApptType?patientcode=${apptDet.PatientCode}&DoctorCode=${widget.doctorDet.doctorCode}&RqstServiceCode=${apptDet.ServiceCode}&apptRqstDate=${aaptDate}";
//    var url = "http://devp.21ci.com:81/BVHPortalapitemp/api/Patient/GetPatApptType?patientcode=${apptDet.PatientCode}&DoctorCode=${widget.doctorDet.doctorCode}&apptRqstDate=${aaptDate}";

    var response = await http.get(url,
        headers: {"Authorization": 'Bearer ${globals.tokenKey}'}
    );


    if (response.statusCode == 200) {
      int drFee = json.decode(response.body)['DrFee'];
      if (drFee != null) {
//          doc.add(PatientAppointment.fromJsonnew(notejson));
        apptDet.ConsultationFee = drFee;
        apptDet.VisitType = json.decode(response.body)['VisitType'];
        apptDet.BillServiceCode = json.decode(response.body)['ServiceCode'];
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Conformappointment(
                    appDetail: apptDet,
                    doctorDet: widget.doctorDet,
                    serviceList:serviceList,
                  ),
            ));
      }
    }
  }
}
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
