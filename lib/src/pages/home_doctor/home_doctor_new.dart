import 'package:civideoconnectapp/src/pages/aboutUs.dart';
import 'package:civideoconnectapp/startscreen.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'syles.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/firebase/auth/phone_auth/authservice.dart';
import 'package:civideoconnectapp/src/pages/ConsultationRoom.dart';

Color myTitleColor;

class HomePageDoctorNew extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageDoctorNew> {
  var doctorTodaySummary = Map();
  var isLoading = false;
  int _current = 0;
  Stream<QuerySnapshot> appointments;
  final ScrollController _scrollController = ScrollController();
  final Color _backgroundColor = Color(0xFFf0f0f0);
  int apptCount = -1;
  @override
  void initState() {
    super.initState();
    loadSummary();
    DatabaseMethods()
        .getDoctorAppointmentsWaitingOnly(globals.personCode,
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))
        .then((val) {
      setState(() {
        appointments = val;
      });
    });
  }

  void loadSummary() async {
    // await DatabaseMethods()
    //     .getDoctorTodaySummary(globals.personCode)
    //     .then((value) => () {
    //           String s;
    //           doctorTodaySummary = value;
    //         });

    String appointmentStatus = "";
    doctorTodaySummary["Total"] = 0;
    doctorTodaySummary["Done"] = 0;
    await Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: globals.personCode)
        .where("apptDate",
            isEqualTo:
                DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()))
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.map((element) {
        appointmentStatus = element.data['appointmentStatus'];

        if (appointmentStatus == null)
          appointmentStatus = "PENDING";
        else if (appointmentStatus == "CANCELLED")
          appointmentStatus = "";
        else if (appointmentStatus == "DONE")
          appointmentStatus = "DONE";
        else
          appointmentStatus = "PENDING";

        if (appointmentStatus == "PENDING") {
          doctorTodaySummary["Total"] += 1;
        } else if (appointmentStatus == "DONE") {
          doctorTodaySummary["Total"] += 1;
          doctorTodaySummary["Done"] += 1;
        }
      }).toList();
    });
    // if (doctorTodaySummary == null) {
    //   doctorTodaySummary = Map();
    //   doctorTodaySummary["Total"] = 0;
    //   doctorTodaySummary["Done"] = 0;
    // }
    setState(() {});
  }

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  @override
  Widget build(BuildContext context) {
    myTitleColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              width: double.infinity,
              //height: 40,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        
                      child:Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        //width: 280,
                        child: Text(
                          "Welcome Dr. ${globals.user[0]["FirstName"]}!",
                          style: bodyTextStyle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      GestureDetector(
                        onTap: () {
                          AuthService().signOut();

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => StartScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: Text("Logout",
                            style: bodyTextStyle.copyWith(
                                fontSize: 15, color: Colors.black)),
                      )
                    ],
                  ),
                  apptCount > 0
                      ? Row(
                          children: [
                            Text(
                                "You have $apptCount patient${apptCount > 0 ? "s" : ""} remaining today!",
                                style: bodyTextStyle.copyWith(
                                    fontSize: 15, color: Colors.black))
                          ],
                        )
                      : Container()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Appointment Summary",
                    style: bodyTextStyle.copyWith(fontSize: 15),
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.refresh),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            loadSummary();
                          }),
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("Today\'s Patients"),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: doctorTodaySummary.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key =
                                  doctorTodaySummary.keys.elementAt(index);
                              return new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      alignment: Alignment.center,
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: key == "Total"
                                              ? Theme.of(context).accentColor
                                              : Colors.orangeAccent),
                                      child: Text(
                                        "${doctorTodaySummary[key]}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Text("$key")
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Currently in the Waiting Room",
                      style: bodyTextStyle.copyWith(fontSize: 15)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: StreamBuilder(
                    stream: appointments,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // setState(() {
                        //             apptCount = snapshot.data.documents.length;
                        //           });
                        return snapshot.data.documents.length == 0
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "There are no patients waiting at this time.!"),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    //height: 80,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Container(
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ConsultationRoom(
                                                        appointmentNumber: snapshot
                                                                .data
                                                                .documents[index]
                                                                .data[
                                                            "appointmentNumber"],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: _buildTopContent(snapshot
                                                    .data.documents[index]))),
                                      ],
                                    ),
                                  );
                                },
                              );
                      } else {
                        return Container(
                          width: double.infinity,
                          child: Text("Loading data..."),
                        );
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildTopContent(DocumentSnapshot appt) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[100]),
                      height: 50,
                      width: 50,
                      child: globals.getProfilePic("PATIENT")),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 220,
                              child: Text(
                                appt.data["patientName"].toUpperCase(),
                                style: bodyTextStyle.copyWith(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              child: Text(
                                "${appt.data["patientAge"].toUpperCase()} ${appt.data["patientGender"].toUpperCase()}",
                                style: bodyTextStyle.copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        Text(
                            DateFormat.jm()
                                .format(
                                    appt.data["doctorSlotFromTime"].toDate())
                                .toUpperCase(),
                            style: bodyTextStyle.copyWith(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              thickness: 2,
            ),
          ],
        ));
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      //leading: Icon(Icons.home, color: appBarIconsColor),
      actions: <Widget>[
        new GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUs()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child:
                  Icon(Icons.info_rounded, color: appBarIconsColor, size: 28),
            )),
      ],
      brightness: Brightness.light,
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text('DashBoard'.toUpperCase(),
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
