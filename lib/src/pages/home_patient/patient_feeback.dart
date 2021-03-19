import 'package:civideoconnectapp/src/pages/home_patient/patient_feedback_submitted.dart';
import 'package:file_picker/file_picker.dart';
import 'package:civideoconnectapp/src/pages/home_patient/slider_widget.dart';
import 'package:civideoconnectapp/src/pages/home_patient/syles.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server

class PatientFeedback extends StatefulWidget {
  final String appointmentNumber; //added by vrushali
  final String Doctorname; //added by vrushali
  const PatientFeedback({Key key,this.appointmentNumber,this.Doctorname,}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<PatientFeedback> {
  final Color _backgroundColor = Color(0xFFf0f0f0);
  double _value1,_value2,_value3 = 0; //modified by vrushali
  bool canContact = false;
  String valueString;
  String _filePath;
  String fileName;
  String canContact1="No";
  final commentTextController = TextEditingController(); //added by vrushali

  // addded by vrushali to submit FeedbackData firestore
  Future<void> submitData(String appointmentNumber) async{
    Firestore.instance
        //.collection('Appointments')
        //.document(appointmentNumber)
        .collection("SubmitFeedback")
        .document(appointmentNumber).setData(
        // .add(
        // Firestore.instance.collection("users").add(
        {
          "AppointmentNumber" : widget.appointmentNumber,
          "DoctorName" :widget.Doctorname,//appt.data["doctorName"],
          "EXPERIENCE WITH THE CONSULTANT/DOCTOR" : _value1,
          "waiting time to see the doctor" : _value2,
          "CONSIDER US FOR FUTURE MEDICAL NEEDS" : _value3,
//          "come to know about our service" : valueString,
          "AttachedFileName" : fileName,
          "contacting me for further feedback" :canContact1,
          "Comments/Suggestions" :commentTextController.text,
        }).then((value){
      //print(value.id);
    });
  }


  @override
  void initState() {
    super.initState();
  }

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  // added by vrushali to send email while submitting feedback details
  emailSending() async {
    String username = 'bvhmobileapp@gmail.com'; //Your Email;
    String password = 'bvh@Admin123'; //Your Email's password;

    final smtpServer = gmail(username, password);
    // Creating the Gmail server

    // Create our email message.
    final message = Message()
    ..from = Address(username)
    ..recipients.add('vrushali624@gmail.com') //recipent email
    // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com']) //cc Recipents emails
    //..bccRecipients.add(Address('bccAddress@example.com')) //bcc Recipents emails
    ..subject = 'Feedback submitted by Appointment number :: 😀 :: ${widget.appointmentNumber}' //subject of the email
    ..text = 'contacting me for further feedback: $canContact1. \nComments/Suggestions :${commentTextController.text}';
    //'This is the plain text.\nThis is line 2 of the text part.'; //body of the email

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString()); //print if the email is sent
    } on MailerException catch (e) {
      print('Message not sent. \n'+ e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      //appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 30, bottom: 50),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Stack(
                      children: [
                        Container(
                            height: 140,
                            width: double.infinity,
                            child: Image.asset(
                              "assets/images/PatientFeedback.jpg",
                              fit: BoxFit.fill,
                            )),
                        Container(
                          padding: const EdgeInsets.all(15.0),
                          height: 140,
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15.0),
                                color: Colors.white,
                                child: Text(
                                  "Feedback",
                                  style: bodyTextStyle.copyWith(fontSize: 20),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        //color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "We are grateful to you for giving us the opportunity to serve you. To help us in our endeavour to serve you better we sincerely request you to share your opinion and suggestions. We appreciate your feedback and assure you of our best services always.",
                              style: bodyTextStyle,
                              overflow: TextOverflow.clip,
                            ),
                          ],
                        )),
                  ),
                  showFeedbackRating(
                      "PLEASE RATE YOUR EXPERIENCE WITH THE CONSULTANT/DOCTOR."
                          .toUpperCase(),
                      5.0,
                      "1-Strongly Disagree             2-Disagree            3-OK             4-Agree            5-Strongly Agree"  .toUpperCase()),
                  showFeedbackRating2(
                      "The waiting time to see the doctor".toUpperCase(),
                      5.0,
                      "1 (> 60 Minutes) 2 (45-60 Minutes) 3 (30-45 Minutes) 4 (15-30 Minutes) 5 (< 15 Minutes)"),
                  showFeedbackRating3(
                      "WOULD YOU CONSIDER US FOR FUTURE MEDICAL NEEDS?",
                      5.0,
                      "1-Strongly Disagree             2-Disagree            3-OK             4-Agree            5-Strongly Agree"  .toUpperCase()),
//                  showFeedbackOption(
//                      "How did you come to know about our service?"
//                          .toUpperCase(),
//                      {
//                        "1": "Friend/ Relative",
//                        "2": "WhatsApp",
//                        "3": "Facebook/ Twitter/ Website",
//                        "4": "SMS",
//                        "5": "Other"
//                      },
//                      "5"),
                  showFeedbackAttachment("Attachment".toUpperCase()),
                  showFeedbackText("COMMENTS/SUGGESTIONS".toUpperCase()),
                  Container(
                    color: Colors.white,
                    child: CheckboxListTile(
                      secondary: const Icon(Icons.call),
                      title: const Text(
                        'I am ok with authorised representative from Hospital contacting me for further feedback.',
                      ),
                      //subtitle: Text('Ringing after 12 hours'),
                      value: canContact,
                      onChanged: (bool value) {
                        setState(() {
                          canContact = value;
                          canContact==true?canContact1="Yes":canContact1="No"; // added by vrushali
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            //padding: const EdgeInsets.only(bottom: 18.0),
            //width: 300,
            child: Container(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ButtonTheme(
                    //minWidth: 250,
                    //height: 40,
                    child: FlatButton(
                      //Enable the button if we have enough points. Can do this by assigning a onPressed listener, or not.
                      onPressed: () {
                        setState(() {
                          emailSending();
                          submitData(widget.appointmentNumber); // added by vrushali
                        });
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PatientFeedbackSubmitted(appointmentNumber:widget.appointmentNumber),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      color: Colors.orangeAccent,
                      disabledColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Submit",
                              style: Styles.text(16, Colors.white, true)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showFeedbackRating(String question, defaultRating, String helpText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.toUpperCase(),
                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 10),
              SliderWidget(
                min: 0,
                max: 5,
                defaultValue: defaultRating,
                divisions: 5,
                fullWidth: true,
                onChanged: (value) {
                  setState(() {
                    _value1 = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                "$helpText",
                style: bodyTextStyle,
                overflow: TextOverflow.clip,
              ),
            ],
          )),
    );
  }
  //2 added by vrushali
  Widget showFeedbackRating2(String question, defaultRating, String helpText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.toUpperCase(),
                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 10),
              SliderWidget(
                min: 0,
                max: 5,
                defaultValue: defaultRating,
                divisions: 5,
                fullWidth: true,
                onChanged: (value) {
                  setState(() {
                    _value2 = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                "$helpText",
                style: bodyTextStyle,
                overflow: TextOverflow.clip,
              ),
            ],
          )),
    );
  }
  /// 3rd added by vrushali
  Widget showFeedbackRating3(String question, defaultRating, String helpText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.toUpperCase(),
                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 10),
              SliderWidget(
                min: 0,
                max: 5,
                defaultValue: defaultRating,
                divisions: 5,
                fullWidth: true,
                onChanged: (value) {
                  setState(() {
                    _value3 = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                "$helpText",
                style: bodyTextStyle,
                overflow: TextOverflow.clip,
              ),
            ],
          )),
    );
  }

  Widget showFeedbackText(String question) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.toUpperCase(),
                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 10),
              new TextField(
                controller: commentTextController, //added by vrushali
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  hintText: '',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 4,
              ),
              SizedBox(height: 10),
            ],
          )),
    );
  }
  List gender=["Friend/Relative","WhatsApp","Facebook/Twitter/Website","Other"];
  String select;
  Row addRadioButton(int btnValue, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Radio(
          activeColor: Theme.of(context).primaryColor,
          value: gender[btnValue],
          groupValue: select,
          onChanged: (value){
            setState(() {
              // print(value);

//              valueString = value;
              //  _statecode = newValue;
              valueString=value;
              // state.didChange(newValue);

            });
          },
        ),
        Text(title)
      ],
    );
  }
  Widget showFeedbackOption(String question, options, String defaultSelection) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.toUpperCase(),
                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 10),
//              Row(
//                children: <Widget>[
//                  addRadioButton(0, 'Friend/ Relative'),
//                  addRadioButton(1, 'WhatsApp'),
//
//                ],
//              ),
//              Row(
//                children: <Widget>[
//                  addRadioButton(2, 'Facebook/ Twitter/ Website'),
////                  addRadioButton(3, 'SMS'),
//                  addRadioButton(3, 'Other'),
//                ],
//              ),
//              CupertinoRadioChoice(
//                  selectedColor: Colors.orange,
//                  notSelectedColor: Colors.grey[300],
//                  choices: options,
//                  onChange: (selectedGender) {
//                    setState(() {
//                      valueString = selectedGender;
//                    });
//                  },
//                  initialKeyValue: defaultSelection),
              SizedBox(height: 10),
            ],
          )),
    );
  }

  Widget showFeedbackAttachment(String question) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.toUpperCase(),
                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 10),
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300],
                      width: 1, //                   <--- border width here
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                              "${fileName == null ? "Select file" : fileName}")),
                      Container(
                          //padding: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.grey[300],
                          child: RawMaterialButton(
                            onPressed: () => {openFileExplorer()},
                            child: Text("...",
                                style: bodyTextStyle.copyWith(fontSize: 25)),
                          )),
                    ],
                  )),
              SizedBox(height: 10),
            ],
          )),
    );
  }

  void openFileExplorer() async {
    try {
      _filePath = null;
      _filePath = await FilePicker.getFilePath(
          type: FileType.custom, allowedExtensions: ['pdf']);
      if (_filePath != null) {
        setState(() {
          fileName = _filePath.split('/').last;
        });
      }
    } catch (e) {
      print("Unsupported operation" + e.toString());
    }
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      //leading: Icon(Icons.home, color: appBarIconsColor),
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
