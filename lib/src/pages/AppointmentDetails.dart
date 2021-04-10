import 'dart:async';
import 'package:civideoconnectapp/data_models/ViewAppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/AppointmentDetailsSubmit.dart';
import 'package:civideoconnectapp/src/pages/home_patient/patient_feeback.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
//import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/ChatPage.dart';
import 'package:civideoconnectapp/src/pages/VirtualOPDArea.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/utils/mycircleavatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:civideoconnectapp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'ViewAppointment_Patient/appointment_summary.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server


//import 'package:carousel_slider/carousel_slider.dart';

class AppointmentScreen extends StatefulWidget {
  /// non-modifiable channel name of the page
  //final int userID;
  final String appointmentNumber;
  final ViewAppointmentDetails appt1;
  final int isCurrent;
  final DateTime apptTime;
  /// Creates a call page with given channel name.
  const AppointmentScreen({Key key, this.appointmentNumber,this.appt1,this.isCurrent,this.apptTime}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool _isLogin = false;
  bool _isConsDone = false;
  int _current = 0;
  bool _isCheckInAllowed = false;
  bool _isDetailsSubmitted = false;
  bool _isShowInfoScreen = false;
  int _showInfoIndex = 0;
  String _selectedChoice = "";
  List<PreConsultationMasterList> preConsultationMaster;
  int qIndex = 0;
  TextEditingController numberFieldController = new TextEditingController();
  TextEditingController textFieldController = new TextEditingController();
//  Stream apptStream;
  // DocumentSnapshot appt;//underapi
   ViewAppointmentDetails appt;
  bool downloading = false;
  String progressString = '0';
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
    fontSize: 16,
    height: 1.8,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );


  List listOfAppointmentNumber=[];
  //added by vrushali to check multiple feedback
  getData(String appointmentNumber) async {
    await Firestore.instance//.document(widget.appointmentNumber)
        //.collection('Appointments')
        //.document(appointmentNumber)
        .collection("SubmitFeedback")
        .where("AppointmentNumber", isEqualTo: widget.appointmentNumber)
        .getDocuments()
        .then((QuerySnapshot snapshot) //{
    => snapshot.documents.forEach(
            (f) => listOfAppointmentNumber.add(f.data["AppointmentNumber"])
      // print(f.data["AppointmentNumber"])
    ),

    );print("List of FeedbackSubmitted Appointment Number: $listOfAppointmentNumber");
    return listOfAppointmentNumber;
  }
  @override
  void dispose() {
    // clear users

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData(widget.appointmentNumber);

    // DatabaseMethods()
    //     .getAppointmentDetails(widget.appointmentNumber)
    //     .then((val) {
    //   setState(() {
    //     apptStream = val;
    //   });

    //
    //});

//    apptStream =
//        DatabaseMethods().getAppointmentDetails(widget.appointmentNumber);
    appt=widget.appt1;

    setPreConsultationData(widget.appointmentNumber);
  }

  setPreConsultationData(appointmentNumber) async {
    await DatabaseMethods()
        .getPreConsultationMaster(appointmentNumber)
        .then((val) {
      setState(() {
        preConsultationMaster = val;
      });
    });

    bool setMaster = false;

    if (preConsultationMaster != null) {
      if (preConsultationMaster.length == 0) {
        setMaster = true;
      }
    } else {
      setMaster = true;
    }

    if (setMaster == true) {
      await DatabaseMethods().setPreConsultationMaster(appointmentNumber);

      await DatabaseMethods()
          .getPreConsultationMaster(appointmentNumber)
          .then((val) {
        setState(() {
          preConsultationMaster = val;
        });
      });
    }
  }

  /// Video layout wrapper
  Widget _viewRows() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                height: 160,
                child: Hero(
//                  tag: '${appt.data["appointmentNumber"]}',//underapi
                  tag: '${appt.ApptNumber}',
                  child: AppointmentSummary(
                      appt: appt, theme: SummaryTheme.dark, isOpen: true),
                )),
            SizedBox(
              height: 26,
            ),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            appointmentStatus(),
            downloading
                ? Center(
                    child: Container(
                    height: 120.0,
                    width: 300.0,
                    alignment: Alignment.center,
                    child: Card(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            " Downloading File: $progressString ",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ))
                : Container()
          ],
        ),
      ),
    );
  }

  Widget appointmentStatus() {
    DateTime currentDate =
        DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());

//    DateTime doctorSlotToTime = DateFormat('yyyy-MM-dd').parse(appt.data["doctorSlotToTime"].toDate().toString());//underapi
    DateTime doctorSlotToTime = appt.ApptRqstDate;
//    String appointmentStatus = appt.data["appointmentStatus"];//underapi
    String appointmentStatus = appt.AppointmentStatus;
    int apptStatus = 0;

    if (doctorSlotToTime.difference(currentDate).inDays >= 0) {
      if (appointmentStatus == "DONE" || appointmentStatus == "CANCELLED")
        apptStatus = 2;
      else
        apptStatus = 1;
    } else {
      apptStatus = 2;
    }

    if (apptStatus == 1) {
      return viewPendingAppointment();
    }
    else {
//      if (appt.data["appointmentStatus"] == "DONE") {//underapi
        if (appt.AppointmentStatus.toUpperCase() == "DONE") {
        return viewCompletedAppointment();
      } else
//        if (appt.data["appointmentStatus"] == "CANCELLED") {//underapi
          if (appt.AppointmentStatus.toUpperCase() == "CANCELLED") {
        return viewCancelledAppointment();
      }
        else {
        return viewNoShowAppointment();
      }
    }
  }

  Widget viewPendingAppointment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
//            "Appointment starts in ${calculateTime(convertToDate(appt.data["doctorSlotFromTime"]))}",//underapi
            "Appointment starts in ${calculateTime(appt.FromTime1)}",//underapi
            style: titleTextStyle,
          ),
          SizedBox(
            height: 20,
          ),
          /*(_isShowInfoScreen == true)  //// commented by vrushali
              ? Container(
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.blueGrey[200]),
                  child: Column(
                    children: <Widget>[
                      Text("Please answer some simple questions",
                          style: Theme.of(context).textTheme.subtitle1.apply(
                                fontWeightDelta: 2,
                              )),
                      SizedBox(height: 20),updateAnswer1
                      questions(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          (_showInfoIndex > 0)
                              ? Container(
                                  width: 60,
                                  child: RawMaterialButton(
                                    onPressed: () => {
                                      setState(() {
                                        updateAnswer1();
                                        _showInfoIndex = _showInfoIndex - 1;
                                      })
                                    },
                                    child: Icon(Icons.arrow_back),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    elevation: 2.0,
                                    fillColor: Theme.of(context).accentColor,
                                    padding: const EdgeInsets.all(15.0),
                                  ))
                              : Container(),
                          (_showInfoIndex < preConsultationMaster.length - 1)
                              ? Container(
                                  width: 60,
                                  child: RawMaterialButton(
                                    onPressed: () => {
                                      setState(() {
                                        updateAnswer1();
                                        _showInfoIndex = _showInfoIndex + 1;
                                      })
                                    },
                                    child: Icon(Icons.arrow_forward),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    elevation: 2.0,
                                    fillColor: Theme.of(context).accentColor,
                                    padding: const EdgeInsets.all(15.0),
                                  ))
                              : Container(
                                  width: 60,
                                  child: RawMaterialButton(
                                    onPressed: () => {
                                      setState(() {
                                        updateAnswer1();
                                        _isCheckInAllowed = true;
                                        _isShowInfoScreen = false;
                                        _showInfoIndex = 0;

                                        DatabaseMethods()
                                            .updateAppointmentDetails(
                                                appt.data["appointmentNumber"],
                                                "appointmentDetailsSubmitted",
                                                "1");

                                        _isDetailsSubmitted = true;
                                      })
                                    },
                                    child: Icon(Icons.exit_to_app),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    elevation: 2.0,
                                    fillColor: Theme.of(context).accentColor,
                                    padding: const EdgeInsets.all(15.0),
                                  ))
                        ],
                      )
                    ],
                  ),
                )
              :*/
          Column(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            //border: Border.all(width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(
                                    10.0) //                 <--- border radius here
                                )),
                        //width: 100,
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
//                            Row(
//                              children: <Widget>[
//                                RaisedButton.icon(
//                                  onPressed: () {
//                                    setState(() {
//                                     // _isShowInfoScreen = true;
//                                      _showInfoIndex = 0;
//                                      /// added by vrushali
//                                      Navigator.push(
//                                        context,
//                                        MaterialPageRoute(
//                                          builder: (context) =>
//                                              AppointmentSubmitDetails(appointmentNumber: appt.data["appointmentNumber"],),
//                                        ),
//                                      );
//                                      /// end by vrushali
//                                    });
//                                  },
//                                  shape: RoundedRectangleBorder(
//                                      borderRadius: BorderRadius.all(
//                                          Radius.circular(10.0))),
//                                  label: Text(
//                                    'Fill Medical details',
//                                    style: titleTextStyle,
//                                  ),
//                                  icon: Icon(
//                                    Icons.looks_one,
//                                    color: Colors.white,
//                                  ),
//                                  textColor: Colors.white,
//                                  splashColor: Theme.of(context).accentColor,
//                                  color: Theme.of(context).primaryColor,
//                                ),
//                                _isDetailsSubmitted
//                                    ? Icon(Icons.done)
//                                    : Center(),
//                              ],
//                            ),
//                            (_isDetailsSubmitted == false)
//                                ? Text(
//                                    "Hello ${globals.personName}, Please enter some details about your health which will help ${appt.data["doctorName"]} understand you better.",
//                                    style: contentTextStyle)
//                                : Text(
//                                    "Thank you for providing the details. You can review you your details",
//                                    style: contentTextStyle),
//                            SizedBox(
//                              height: 10,
//                            ),
                          ],
                        )),
//                    SizedBox(
//                      height: 10,
//                    ),
//                    Container(
//                        decoration: BoxDecoration(
//                            color: Colors.white,
//                            borderRadius: BorderRadius.all(Radius.circular(
//                                    10.0) //                 <--- border radius here
//                                )),
//                        alignment: Alignment.centerLeft,
//                        padding:
//                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                        //width: 100,
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            Row(
//                              children: <Widget>[
//                                RaisedButton.icon(
//                                onPressed: //_isDetailsSubmitted
////                                      ? () {
////                                          onJoin(appt);
////                                        }
////                                      : null,
//                                      () => {  onJoin(appt),}, /// added by vrushali
//                                  shape: RoundedRectangleBorder(
//                                      borderRadius: BorderRadius.all(
//                                          Radius.circular(10.0))),
//                                  label: Text(
//                                    'Proceed to check-in',
//                                    style: titleTextStyle,
//                                  ),
//                                  icon: Icon(
//                                    Icons.looks_two,
//                                    color: Colors.white,
//                                  ),
//                                  textColor: Colors.white,
//                                  splashColor: Theme.of(context).accentColor,
//                                  color: Theme.of(context).primaryColor,
//                                ),
//                              ],
//                            ),
//                            Text(
//                                "Check-in to Virtual OPD Waiting Area. Kindly fill the required details before check-in. You can check-In before 15 min of your appointment.",
//                                style: contentTextStyle),
//                            SizedBox(
//                              height: 10,
//                            ),
//                          ],
//                        )
//                    ),
//                    listOfAppointmentNumber.isEmpty?checkin():Container(),//added by anjali  to show check-in option only if the appointment type is Video.
                    checkin(),//added by anjali  to show check-in option only if the appointment type is Video.
                    listOfAppointmentNumber.isEmpty?aptstatus():Container(), //added by vrushali to prevent multiple feeedback
                   // aptstatus(),
                  ],
                ),
        ],
      ),
    );
  }
  Widget checkin(){
//    if(appt.data["appointmentType"] == "VIDEOCONSULT" //&& appt.data["appointmentStatus"] == "PENDING"// underapi
    if(appt.ApptType == "VIDEOCONSULT" //&& appt.data["appointmentStatus"] == "PENDING"
    ){
      return proceed();
    }else{
      return Container();
    }
  }
  Widget proceed(){
    return
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(
                  10.0) //                 <--- border radius here
              )),
          alignment: Alignment.centerLeft,
          padding:
          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  RaisedButton.icon(
                    onPressed: //_isDetailsSubmitted
//                                      ? () {
//                                          onJoin(appt);
//                                        }
//                                      : null,
                        () => {  onJoin(appt),}, /// added by vrushali
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0))),
                    label: Text(
                      'Proceed to check-in',
                      style: titleTextStyle,
                    ),
                    icon: Icon(
                      Icons.looks_one,
                      color: Colors.white,
                    ),
                    textColor: Colors.white,
                    splashColor: Theme.of(context).accentColor,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              Text(
                  "Enter the virtual opd waiting area. Check in 15 mins prior to your appointment time.",
                  style: contentTextStyle),
              SizedBox(
                height: 10,
              ),
            ],
          )
      );
  }
  // Added by Anjali for appointmentwise Feedback.
  Widget aptstatus() {

//    DateTime currentDate =
//    DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());
//
//    print("The current date is: $currentDate");
//    DateTime doctorSlotToTime = DateFormat('yyyy-MM-dd')
//        .parse(appt.data["doctorSlotToTime"].toDate().toString());
//    print("The current date is: $currentDate");
//
//    int minutes=DateTime.now().minute;
//    print("Hours=$minutes");
//
//    print("doctorSlotToTime is: $doctorSlotToTime");
//    String appointmentStatus = appt.data["appointmentStatus"];
//    print("Appointment Status is: $appointmentStatus");
//    int apptStatus = 0;
//    print("difference");
//    print(doctorSlotToTime.difference(currentDate).inDays);

    if (widget.isCurrent == 0 ) {
      if( DateTime.now().difference(widget.apptTime).inMinutes > 30) {
        return feedback();

      }
      else{ //added by vrushali to prevent null value wwithin 30 min
        return Container();
      }

    }else {
      return Container();
    }

  }

  Widget feedback() {

      return
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(
                    10.0) //                 <--- border radius here
                )),
            alignment: Alignment.centerLeft,
            padding:
            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            //width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RaisedButton.icon(
                      onPressed:
                          () =>
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
//                                PatientFeedback(appointmentNumber: appt.data["appointmentNumber"], Doctorname:appt.data["doctorName"],), // underapi
                            PatientFeedback(appointmentNumber: appt.ApptNumber, Doctorname:appt.DoctorName,),
                          ),
                        )
                      },

                      /// added by vrushali
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(10.0))),
                      label: Text(
                        'Submit Feedback',
                        style: titleTextStyle,
                      ),
                      icon: Icon(
                        Icons.looks_two,
                        color: Colors.white,
                      ),
                      textColor: Colors.white,
                      splashColor: Theme
                          .of(context)
                          .accentColor,
                      color: Theme
                          .of(context)
                          .primaryColor,
                    ),
                  ],
                ),
                Text(
                    "How was your last appointment experience? Kindly submit feedback.",
                    style: contentTextStyle),
                SizedBox(
                  height: 10,
                ),

              ],
            )
        );
  }

  // End Added by Anjali for appointmentwise Feedback.

  Widget viewCancelledAppointment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
            "Appointment Cancelled",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget viewNoShowAppointment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
            "You have not attended this consultation.",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget viewCompletedAppointment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Text(
            "Appointment Completed",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              //width: 100,
              child: RaisedButton.icon(
            onPressed: () async {
              String documentURL;
              await DatabaseMethods()
                  .getePrescription(
                      globals.personCode, widget.appointmentNumber)
                  .then((value) => documentURL = value);
              downloadFile(documentURL);
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            label: Text(
              'View your e-Precription',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            icon: Icon(
              Icons.attachment,
              color: Colors.white,
            ),
            textColor: Colors.white,
            splashColor: Theme.of(context).accentColor,
            color: Theme.of(context).primaryColor,
          )),
          SizedBox(height: 10),
          Container(
              //width: 100,
              child: RaisedButton.icon(
            onPressed: () {
              joinChat();
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            label: Text(
              'Chat with the Doctor',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            icon: Icon(
              Icons.chat,
              color: Colors.white,
            ),
            textColor: Colors.white,
            splashColor: Theme.of(context).accentColor,
            color: Theme.of(context).primaryColor,
          )),
        ],
      ),
    );
  }

  Future<void> downloadFile(url) async {
    Dio dio = Dio();
    String filename;
    try {
      var dir = await getApplicationDocumentsDirectory();
      filename = "${dir.path}/" + url.substring(url.lastIndexOf("/") + 1);

      await dio.download(url, filename, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progressString = "Completed";
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFScreen(path: filename),
      ),
    );
    print("Download completed");
  }

//  updateAnswer1() {    ///// commented by vrushali
//    if (preConsultationMaster[_showInfoIndex].answerType == "NUMBER") {
//      preConsultationMaster[_showInfoIndex].answer1 =
//          numberFieldController.text;
//    } else if (preConsultationMaster[_showInfoIndex].answerType == "TEXT") {
//      preConsultationMaster[_showInfoIndex].answer1 = textFieldController.text;
//    } else if (preConsultationMaster[_showInfoIndex].answerType == "CHOICE") {
//      preConsultationMaster[_showInfoIndex].answer1 = _selectedChoice;
//    }
//
//    DatabaseMethods().updatePreConsultationInfo1(
//        appt.data["appointmentNumber"],
//        preConsultationMaster[_showInfoIndex].id,
//        preConsultationMaster[_showInfoIndex].question,
//        preConsultationMaster[_showInfoIndex].answerType,
//        preConsultationMaster[_showInfoIndex].answerField1,
//        preConsultationMaster[_showInfoIndex].sequence,
//        preConsultationMaster[_showInfoIndex].answer1);
//  }
//
//  questions() {
//    return Container(
//        padding: EdgeInsets.all(5),
//        width: MediaQuery.of(context).size.width,
//        height: 150,
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.all(Radius.circular(20)),
//            color: Colors.white),
//        child: Column(
//          children: <Widget>[
//            Text("${preConsultationMaster[_showInfoIndex].question}",
//                style: Theme.of(context).textTheme.subtitle2.apply(
//                      fontWeightDelta: 2,
//                    )),
//            getAnswerEntry(),
//          ],
//        ));
//  }
//
//  getAnswerEntry() {
//    if (preConsultationMaster[_showInfoIndex].answerType == "NUMBER") {
//      numberFieldController.text =
//          preConsultationMaster[_showInfoIndex].answer1 == null
//              ? ""
//              : preConsultationMaster[_showInfoIndex].answer1;
//
//      return Container(
//          width: 200,
//          child: TextField(
//              controller: numberFieldController,
//              keyboardType: TextInputType.number,
//              decoration: InputDecoration(hintText: ""),
//              inputFormatters: <TextInputFormatter>[
//                WhitelistingTextInputFormatter.digitsOnly
//              ]));
//    } else if (preConsultationMaster[_showInfoIndex].answerType == "TEXT") {
//      textFieldController.text =
//          preConsultationMaster[_showInfoIndex].answer1 == null
//              ? ""
//              : preConsultationMaster[_showInfoIndex].answer1;
//
//      return Container(
//          width: 200,
//          child: TextField(
//            controller: textFieldController,
//            decoration: InputDecoration(hintText: ""),
//          ));
//    } else if (preConsultationMaster[_showInfoIndex].answerType == "CHOICE") {
//      _selectedChoice = preConsultationMaster[_showInfoIndex].answer1 == null
//          ? ""
//          : preConsultationMaster[_showInfoIndex].answer1;
//      List<String> choice =
//          preConsultationMaster[_showInfoIndex].answerField1.split(",");
//      return Wrap(
//        children: _buildChoiceList(choice),
//      );
//    } else {
//      return Center();
//    }
//  }
//
//  _buildChoiceList(reportList) {
//    List<Widget> choices = List();
//    reportList.forEach((item) {
//      choices.add(Container(
//        padding: const EdgeInsets.all(2.0),
//        child: ChoiceChip(
//          label: Text(item),
//          backgroundColor: (_selectedChoice == item)
//              ? Theme.of(context).accentColor
//              : Colors.grey[300],
//          selected: _selectedChoice == item,
//          onSelected: (selected) {
//            setState(() {
//              _selectedChoice = item;
//              updateAnswer1();
//            });
//          },
//        ),
//      ));
//    });
//
//    return choices;
//  }

  DateTime convertToDate(Timestamp timestamp) {
    var date = timestamp.toDate();

    return date;
  }

  String convertToDateString(Timestamp timestamp) {
    DateTime date = timestamp.toDate();

    return DateFormat("dd MMM yyyy").format(date);
  }

  joinChat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          //peerCode: appt.data["doctorCode"],//underapi
          //peerName: appt.data["doctorName"],//underapi
          peerCode: appt.DoctorCode,
          peerName: appt.DoctorName,
        ),
      ),
    );
  }

  Future<void> onJoin(appList) async {
    // update input validation
    setState(() {});

    //DateTime apptDate = appt.data["apptDate"].toDate();//underapi
    DateTime apptDate = appt.ApptRqstDate;
    DateTime currentDate = DateTime.now();

    if (currentDate.difference(apptDate).inMinutes <= 1440) {
      showConsConfirmation();
    } else {
      showAlert(context, "You can CheckIn 15 min Before Consultation.");
    }
  }

  showAlert(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        height: 120,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(margin: EdgeInsets.only(left: 5), child: Text(message)),
            SizedBox(
              height: 30,
            ),
            Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(15.0),
                ),
              ],
            )
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showConsConfirmation() {
    return (showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: new Text(
              "Check-In",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new Text(
                "Are you ready for consultation?"
                //leftTime(convertToDate(appt.data["doctorSlotFromTime"]))
            ),
            // "Are you ready for consultation?\n\nPlease confirm if you have updated the necessory details before you proceed to CheckIn."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
               FlatButton(
                 shape: StadiumBorder(),
                 color: Colors.white,
                 child: new Text(
                   "No",
                   style: TextStyle(color: Colors.blue),
                 ),
                 onPressed: () {
                   Navigator.of(context).pop();
                 },
               ),
              FlatButton(
                shape: StadiumBorder(),
                color: Colors.white,
                child: new Text(
                  //leftMin <= 15 ? 'Yes ' : 'Ok ',
                  "Yes",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
//                  leftMin <= 15
//                      ? startVirtualOPDArea()
//                      : Navigator.pop(context);
                  Navigator.of(context).pop();
                  startVirtualOPDArea();
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  showConsConfirmation1(BuildContext context) async {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        //height: 100,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(
                    "Are you ready for consultation?\n\nPlease confirm if you have updated the necessory details before you proceed to CheckIn")),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //_sendPeerMessage("CONSDONE");
                    startVirtualOPDArea();
                  },
                  child: Text("Yes"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(15.0),
                ),
                SizedBox(
                  width: 20,
                ),
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //_sendPeerMessage("CONSPENDING");
                    // DatabaseMethods().updateAppointmentDetails(
                    //     widget.appointmentNumber,
                    //     "appointmentStatus",
                    //     "PENDING");
                  },
                  child: Text("No"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(15.0),
                ),
              ],
            )
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  startVirtualOPDArea() async {
    await DatabaseMethods().updateAppointmentDetails(
        widget.appointmentNumber, "appointmentStatus", "WAITING");

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VirtualOPDArea(
          appointmentNumber: widget.appointmentNumber,
        ),
      ),
    );
  }

  String checkDate(DateTime checkedTime) {
    //  example, dateString = "2020-01-26";

    //DateTime checkedTime = DateTime.parse(dateString);
    DateTime currentTime = DateTime.now();

    if ((currentTime.year == checkedTime.year) &&
        (currentTime.month == checkedTime.month) &&
        (currentTime.day == checkedTime.day)) {
      return "Today, ${DateFormat("d MMM yyyy").format(checkedTime)}";
    } else if ((currentTime.year == checkedTime.year) &&
        (currentTime.month == checkedTime.month)) {
      if ((currentTime.day - checkedTime.day) == 1) {
        return "Yesterday, ${DateFormat("d MMM yyyy").format(checkedTime)}";
        ;
      } else if ((currentTime.day - checkedTime.day) == -1) {
        return "Tomorrow, ${DateFormat("d MMM yyyy").format(checkedTime)}";
      } else {
        return DateFormat("d MMM yyyy").format(checkedTime);
      }
    } else {
      return DateFormat("d MMM yyyy").format(checkedTime);
    }
  }

  String getApptDate(apptDate) {
    String strDate;

    strDate = checkDate(apptDate);

    return strDate;
  }

  String calculateTime(apptDateTime) {
    String diff = "";
    int leftDays = 0;
    int leftHr = 0;
    int leftMin = 0;
    int leftSec = 0;
    DateTime currentDate = DateTime.now();

    leftDays = apptDateTime.difference(currentDate).inDays;
    leftHr = apptDateTime.difference(currentDate).inHours;
    leftMin = apptDateTime.difference(currentDate).inMinutes;
    leftSec = apptDateTime.difference(currentDate).inSeconds;
    if (leftDays > 0)
      diff = "$leftDays day${leftDays > 1 ? 's' : ''}";
    else if (leftHr > 0)
      diff = "$leftHr hour${leftHr > 1 ? 's' : ''}";
    else if (leftMin > 0) diff = "$leftMin Minute${leftMin > 1 ? 's' : ''}";

    return diff;
  }

  // Added by Vrushali for 15 mins allowed check.
  String diff = "";
//String "15";
  int leftMin = 0;
  String leftTime(apptDateTime) {
    //String diff = "";
    int leftDays = 0;
    int leftHr = 0;
    //int leftMin = 0;
    int leftSec = 0;
    DateTime currentDate = DateTime.now();

    leftDays = apptDateTime.difference(currentDate).inDays;
    leftHr = apptDateTime.difference(currentDate).inHours;
    leftMin = apptDateTime.difference(currentDate).inMinutes;
    leftSec = apptDateTime.difference(currentDate).inSeconds;
    if (leftDays > 0)
      diff =
          "$leftDays day${leftDays > 1 ? 's' : ''} Remaining,You can not be enter into Virtual Area ";
    else if (leftHr > 0)
      diff =
          "$leftHr hour${leftHr > 1 ? 's' : ''} Remaining,You can not be enter into Virtual Area";
    else if (leftMin >= 0)
      diff =
          "$leftMin Minute${leftMin > 1 ? 's' : ''} ${leftMin > 16 ? 'Remaining,You can not be enter into Virtual Area' : 'Remaining, please enter into vitual area'}";

    return diff;
  }
  // End Added by Vrushali for 15 mins allowed check.

  /// Toolbar layout
  Widget _toolbar() {
    //final views = _getRenderViews();

    return Container(
      alignment: Alignment.bottomLeft,

      //padding: const EdgeInsets.symmetric(vertical: 48),
      //margin: const EdgeInsets.only(bottom: 10),

      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 80,
                child: RawMaterialButton(
                  onPressed: () => {
                    if (_isShowInfoScreen == true)
                      {
                        setState(() {
                          _isShowInfoScreen = false;
                          _showInfoIndex = 0;
                        })
                      }
                    else
                      {_onExit(context)}
                  },
                  child: Text("Back"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.orangeAccent)),
                  elevation: 2.0,
                  fillColor: Colors.orangeAccent,
                  padding: const EdgeInsets.all(15.0),
                )),
          ],
        ),
      ),
    );
  }

  void _onExit(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//      StreamBuilder<DocumentSnapshot>(
//        stream: apptStream,
        // Firestore.instance
        //     .collection("Appointments")
        //     .document(widget.appointmentNumber)
        //     .snapshots(),
//        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//          if (!snapshot.hasData) {
//            return Text("Loading");
//          }
    child: appt == null? Container(child : Text("Loading")):
//          appt = snapshot.data;//underapi
//          appt=widget.appt1;
//          _isDetailsSubmitted =
//              appt.data["appointmentDetailsSubmitted"] == "1" ? true : false;

          //setPreConsultationData();

          Scaffold(
            backgroundColor: _backgroundColor,
            appBar: _buildAppBar(),
            body: Stack(
              children: <Widget>[
                _viewRows(),
                _toolbar(),
              ],
            ),
           )
        );
  }

  Future<bool> _onBackPressed() {
    return 1 ?? false;
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
        child: Text('Your Appointment'.toUpperCase(),
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

class PDFScreen extends StatefulWidget {
  final String path;

  PDFScreen({Key key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final Color _backgroundColor = Color(0xFFf0f0f0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.BOTH,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onPageChanged: (int page, int total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              label: Text("Page $currentPage of $pages)"),
              onPressed: () async {
                await snapshot.data.setPage(pages ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
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
        child: Text('e-Prescription'.toUpperCase(),
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
