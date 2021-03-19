
import 'dart:async';
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




class AppointmentSubmitDetails extends StatefulWidget {

  final String appointmentNumber;
  const AppointmentSubmitDetails({Key key,this.appointmentNumber}) : super(key: key);

  @override
  _AppointmentSubmitDetailsState createState() => _AppointmentSubmitDetailsState();
}

class _AppointmentSubmitDetailsState extends State<AppointmentSubmitDetails> {


  int _showInfoIndex; //= 0;
  String _selectedChoice = "";
  List<PreConsultationMasterList> preConsultationMaster;
  int qIndex = 0;
  List<TextEditingController> numberFieldControllers=[]; /// added vrushali
  TextEditingController textFieldController = new TextEditingController();
  TextEditingController numberFieldController = TextEditingController();
  Stream apptStream;
  DocumentSnapshot appt;
  bool downloading = false;
  String progressString = '0';
  final Color _backgroundColor = Color(0xFFf0f0f0);


  @override
  void initState() {
    super.initState();

    submitData(widget.appointmentNumber);
//DocumentSnapshot appt;
    apptStream =
        DatabaseMethods().getAppointmentDetails(widget.appointmentNumber);

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
        child: Text('Details'.toUpperCase(),
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

//Added by anjali
  Future<void> submitData(String appointmentNumber) async{
    Firestore.instance
    //.collection('Appointments')
    //.document(appointmentNumber)
        .collection("FillMedicalDetail")
        .document(appointmentNumber).setData(
      // .add(
      // Firestore.instance.collection("users").add(
        {
          "AppointmentNumber" : widget.appointmentNumber,
//          "DoctorName" :widget.Doctorname,//appt.data["doctorName"],
//          "EXPERIENCE WITH THE CONSULTANT/DOCTOR" : _value1,
//          "waiting time to see the doctor" : _value2,
//          "CONSIDER US FOR FUTURE MEDICAL NEEDS" : _value3,
//          "come to know about our service" : valueString,
//          "AttachedFileName" : fileName,
//          "contacting me for further feedback" :canContact1,
//          "Comments/Suggestions" :commentTextController.text,
          "what is your Weight (Kg) ?" :123,//numberFieldController.text,
          "what is your Height (Cm) ?" :23,//numberFieldController.text,
          "Do you smoke ?" :'No',//_selectedChoice,
          "What Allergies Do You Have?" :'xyz',//textFieldController.text,
        }).then((value){
      //print(value.id);
    });
  }

  //ended by anjali
  updateAnswer1(_showInfoIndex) {
//    TextEditingController numberFieldController = TextEditingController(); /// addedd vrushali
//    numberFieldControllers.add(numberFieldController);  //// added vrushali
//     for(int i =0;i<numberFieldControllers.length;i++) {
    if (preConsultationMaster[_showInfoIndex].answerType == "NUMBER") {
      preConsultationMaster[_showInfoIndex].answer1 =
          numberFieldController.text;
      print(numberFieldController.text);
    } else if (preConsultationMaster[_showInfoIndex].answerType == "TEXT") {
      preConsultationMaster[_showInfoIndex].answer1 =
          textFieldController.text;
      print(textFieldController.text);
    } else if (preConsultationMaster[_showInfoIndex].answerType == "CHOICE") {
      preConsultationMaster[_showInfoIndex].answer1 = _selectedChoice;
    }
    // }
    DatabaseMethods().updatePreConsultationInfo1(
        appt.data["appointmentNumber"],
        preConsultationMaster[_showInfoIndex].id,
        preConsultationMaster[_showInfoIndex].question,
        preConsultationMaster[_showInfoIndex].answerType,
        preConsultationMaster[_showInfoIndex].answerField1,
        preConsultationMaster[_showInfoIndex].sequence,
        preConsultationMaster[_showInfoIndex].answer1);
  }

  questions() {
    return Container(
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        height: 310,//MediaQuery.of(context).size.height, //150
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white),
        child: Column(
            children: <Widget>[
              // preConsultationMaster.length==0?Text("Loading"):
              preConsultationMaster == null
                  ? Center(child: CircularProgressIndicator()):
              Expanded(

                child: new ListView.builder(
                    itemCount: preConsultationMaster.length,
                    itemBuilder: (_, _showInfoIndex) {
                      return Column(
                          children: <Widget>[
                            Text("${preConsultationMaster[_showInfoIndex].question}",
                                style: Theme.of(context).textTheme.subtitle2.apply(
                                  fontWeightDelta: 2,
                                )),
                            getAnswerEntry(_showInfoIndex),
                            SizedBox(height: 10),
                          ]);
                    }
                ),
              )]));
  }

  getAnswerEntry(_showInfoIndex) {
    TextEditingController numberFieldController = TextEditingController(); ///added vrushali
    numberFieldControllers.add(numberFieldController); //added vrushali
    TextEditingController textFieldController = new TextEditingController();

    if (preConsultationMaster[_showInfoIndex].answerType == "NUMBER") {
      numberFieldController.text =
      preConsultationMaster[_showInfoIndex].answer1 == null
          ? ""
          : preConsultationMaster[_showInfoIndex].answer1;
      return NTField();

//      return Container(
//          width: 200,
//          child: TextField(
//              controller: numberFieldController,
//              keyboardType: TextInputType.number,
//              decoration: InputDecoration(hintText: ""),
//              inputFormatters: <TextInputFormatter>[
//                WhitelistingTextInputFormatter.digitsOnly
//              ]));
    } else if (preConsultationMaster[_showInfoIndex].answerType == "TEXT") {
      textFieldController.text =
      preConsultationMaster[_showInfoIndex].answer1 == null
          ? ""
          : preConsultationMaster[_showInfoIndex].answer1;
return TField();
//      return Container(
//          width: 200,
//          child: TextField(
//            controller: textFieldController,
//            decoration: InputDecoration(hintText: ""),
//          ));
    } else if (preConsultationMaster[_showInfoIndex].answerType == "CHOICE") {
      _selectedChoice = preConsultationMaster[_showInfoIndex].answer1 == null
          ? ""
          : preConsultationMaster[_showInfoIndex].answer1;
      List<String> choice =
      preConsultationMaster[_showInfoIndex].answerField1.split(",");
      return Wrap(
        children: _buildChoiceList(choice),
      );
    } else {
      return Center();
    }

  }


  Widget NTField(){
    return Container(
        width: 200,
        child: TextField(
            controller: numberFieldController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: ""),
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ]));
  }
  Widget TField(){
    return Container(
        width: 200,
        child: TextField(
          controller: textFieldController,
          decoration: InputDecoration(hintText: ""),
        ));
  }
  _buildChoiceList(reportList) {
    List<Widget> choices = List();
    reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item),
          backgroundColor: (_selectedChoice == item)
              ? Theme.of(context).accentColor
              : Colors.grey[300],
          selected: _selectedChoice == item,
          onSelected: (selected) {
            setState(() {
              _selectedChoice = item;
              updateAnswer1(_showInfoIndex);
            });
          },
        ),
      ));
    });

    return choices;
  }


  void _onExit(BuildContext context) {
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: <Widget>[

          // questions(),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width,
            height: 450,//MediaQuery.of(context).size.height,//500,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.blueGrey[200]),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Text("Please answer some simple questions",
                    style: Theme.of(context).textTheme.subtitle1.apply(
                      fontWeightDelta: 2,
                    )),
                SizedBox(height: 30),
                questions(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        width: 100,
                        child: RawMaterialButton(
                          onPressed: () => {
                            Navigator.pop(context),
                            setState(() {
                              updateAnswer1(_showInfoIndex);
                              // _isCheckInAllowed = true;
                              // _isShowInfoScreen = false;
                              // _showInfoIndex = 0;

                              DatabaseMethods()
                                  .updateAppointmentDetails(
                                  appt.data["appointmentNumber"],
                                  "appointmentDetailsSubmitted",
                                  "1");
                             // submitData(widget.appointmentNumber);
                              //_isDetailsSubmitted = true;

                            })
                          },
                          child: Text("Submit"),//Icon(Icons.exit_to_app),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(25.0),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .primaryColor)),
                          elevation: 2.0,
                          fillColor: Theme.of(context).accentColor,
                          padding: const EdgeInsets.all(15.0),
                        )),


                  ],
                )
              ],
            ),
          )
          // _viewRows(),
          //_toolbar(),



        ],
      ),
    );

  }


}
