import 'dart:convert';

import 'package:civideoconnectapp/data_models/OrganizationDetails.dart';
import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/Conformappointment.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/categoryList.dart';
import 'package:civideoconnectapp/src/pages/index/index_new.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../startscreen.dart';
import 'doctor_list.dart';

final Color _backgroundColor = Color(0xFFf0f0f0);

class RegisterPatientList extends StatefulWidget {
 // final PatienRegistrationDetails appDetail_1;
//  final DoctorData doctorDet;
//final phonenumber;
final List data;
final FirebaseUser res;


  const RegisterPatientList({Key key,this.data,this.res})
      : super(key: key);

  @override
  RegisterPatientListState createState() => RegisterPatientListState();
}

class RegisterPatientListState extends State<RegisterPatientList>{

  ScrollController _scrollController = ScrollController();
//  Icon cusIcon;
//  bool issearching = false;
//  Widget cusSearchBar;
//  Widget cusSearchBarDefault;
//  Color appBarIconsColor = Color(0xFF212121);

  List<PatienRegistrationDetails> regdetails1;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  TextStyle get bodyTextStyle => TextStyle(
    color: mainTextColor,
    fontSize: 13,
    fontFamily: 'OpenSans',
  );
  Color get mainTextColor {
    Color textColor;

    textColor = Color(0xFF083e64);
    return textColor;
  }

  Color get secondaryTextColor {
    Color textColor;

    textColor = Color(0xFF838383);
    return textColor;
  }
  int index;
  @override
  void initState() {
//    setState(() {
//      getregistrationDetails();
//    });

//    getregistrationDetails().then((value) {
//      setState(() {
//        _regdetails.addAll(value);
//       // _filterorganization.addAll(value);
//      });

//    apiData().then((value) {
//      setState(() {
//        _organization.addAll(value);
//        _filterorganization.addAll(value);
//      });
//    });

//    cusIcon = Icon(Icons.search, color: appBarIconsColor);
//    cusSearchBarDefault = Text('Organizations'.toUpperCase(),
//        textAlign: TextAlign.center,
//        style: TextStyle(
//          fontSize: 15,
//          letterSpacing: 0.5,
//          color: appBarIconsColor,
//          fontFamily: 'OpenSans',
//          fontWeight: FontWeight.bold,
//        ));
//    cusSearchBar = cusSearchBarDefault;




    super.initState();
  }


  PatienRegistrationDetails apptDet;
  var extractdata1;

//  List<PatienRegistrationDetails> _regdetails = List<PatienRegistrationDetails>();
//  getregistrationDetails() async {
//
//
//    return await http.post(
//        Uri.encodeFull(
//            "${globals.apiHostingURLBVH}/MobileAppPatient/MobileApp_GetPatientRegDetails"),
//        body: {
//          "MobileNumber": "${globals.mobileNumber}",
//        },
//        headers: {"Accept": "application/json"}).then((http.Response response) {
//      // setState(() {
//      final int statusCode = response.statusCode;
//      if (statusCode == 200) {
//         extractdata1 = jsonDecode(response.body)["patientDetails"];
//
//        List data = extractdata1 as List;
//        if (data != null) {
//          for (int i = 0; i < data.length; i++) {
//            setState(() {
//              _regdetails.add(PatienRegistrationDetails.fromJsonnew(data[i]));
//            });
//          }
//        }
//
//      }
//      // });
//    });
//  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: _backgroundColor,
//      appBar: AppBar(
//        title: Text("Organization"),
//      ),
      appBar: _buildAppBar(),
      body:Container(
        //height: 80,
          child:
          Column(
              children: <Widget>[
//        child:
                SizedBox(height: 20,),
                ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context,index){
                    return new GestureDetector(
                      child:Center(
                        child: Container(
                          height: 80,

                          child:Card(
                              elevation: 10.0,
                              //color: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child:Center(
                                child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
//                    SizedBox(height: 20,),
                                      Text(
                                        widget.data[index]["FullName"],
                                        style: bodyTextStyle.copyWith(fontSize: 20),
                                        overflow: TextOverflow.ellipsis,

//                              style: TextStyle(
//                                  fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.white),
                                      ),
                                    ]
                                ),
                              )
                          ),

                        ),
                      ),
                      onTap: () async {
                        globals.user = widget.data;
                        globals.personCode = widget.data[index]["PersonCode"];
                        globals.personName =
                        "${widget.data[index]["Salutation"]} ${widget.data[index]["FirstName"]}";
                        globals.personGender = widget.data[index]["GenderCode"];
                        globals.tokenKey = widget.data[index]["TokenKey"];
                        globals.mobileNumber = widget.data[index]["MobileNumber"];
                        globals.personEmailID = widget.data[index]["EmailID"];
                        updateLocalDatabase();


                        await updateUserToDatabase(widget.res);


                        //widget.appDetail_1.FirstName = _regdetails[index].FirstName;

//                        widget.appDetail.PatientName = _regdetails[index].FullName;
//                        widget.appDetail.GenderCode = _regdetails[index].genderACode;
//                        widget.appDetail.PatientMobile = _regdetails[index].mobileNumber;
//                        widget.appDetail.PatientEmail = _regdetails[index].emailID;
//
//                        String aaptDate = DateFormat('yyyy-MM-dd').format(widget.appDetail.ApptDate);
//                        var url = "${globals.apiHostingURLBVH}/Patient/GetPatApptType?patientcode=${widget.appDetail.PatientCode}&DoctorCode=${widget.doctorDet.doctorCode}&RqstServiceCode=${widget.appDetail.ServiceCode}&apptRqstDate=${aaptDate}";
////    var url = "http://devp.21ci.com:81/BVHPortalapitemp/api/Patient/GetPatApptType?patientcode=${apptDet.PatientCode}&DoctorCode=${widget.doctorDet.doctorCode}&apptRqstDate=${aaptDate}";
//
//                        var response = await http.get(url,
//                            headers: {"Authorization": 'Bearer ${globals.tokenKey}'}
//                        );
//
//
//                        if (response.statusCode == 200) {
//                          int drFee = json.decode(response.body)['DrFee'];
//                          if (drFee!=null) {
////          doc.add(PatientAppointment.fromJsonnew(notejson));
//                            widget.appDetail.ConsultationFee=drFee;
//                            widget.appDetail.VisitType = json.decode(response.body)['VisitType'];
//                            widget.appDetail.BillServiceCode = json.decode(response.body)['ServiceCode'];
//                            Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                  builder: (context) => Conformappointment(
//                                    appDetail: widget.appDetail,
//                                    doctorDet: widget.doctorDet,
//                                  ),
//                                ));
//                          }
//                        }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StartScreen()),
              );

                      },
                    );
                  },
                  itemCount: widget.data.length,
                ),
              ])
//]
//    ),
      ),
    );
  }
  updateLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('loginUserType', "PATIENT");


    prefs.setString('personCode', globals.personCode);
  }
  updateUserToDatabase(FirebaseUser res) async {
    String msgToken;
    await firebaseMessaging.getToken().then((val) {
      msgToken = val;
    });

    try {
      await DatabaseMethods().deleteUserInfo(res.phoneNumber);
    } catch (error) {
      print("deleteUserInfo error");
    }

    Map<String, String> userDataMap = {
      "userName": globals.personName,
      "mobile": res.phoneNumber,
      "userCode": globals.personCode,
      "userType": globals.loginUserType,
      "userToken": msgToken,
    };

    DatabaseMethods().addUserInfo(globals.personCode, userDataMap);
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
        child: Text('Select the patient'.toUpperCase(),
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

