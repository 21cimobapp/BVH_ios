import 'dart:convert';

import 'package:civideoconnectapp/data_models/OrganizationDetails.dart';
import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/Conformappointment.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/categoryList.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'doctor_list.dart';

final Color _backgroundColor = Color(0xFFf0f0f0);

class ServiceList extends StatefulWidget {
  final PatientAppointmentdetails appDetail;
  final DoctorData doctorDet;

  const ServiceList({Key key, this.appDetail, this.doctorDet})
      : super(key: key);

  @override
  ServiceListState createState() => ServiceListState();
}

class ServiceListState extends State<ServiceList>{

  ScrollController _scrollController = ScrollController();
//  Icon cusIcon;
//  bool issearching = false;
//  Widget cusSearchBar;
//  Widget cusSearchBarDefault;
//  Color appBarIconsColor = Color(0xFF212121);


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
    setState(() {
      getregistrationDetails();
    });

//    getregistrationDetails().then((value) {
//      setState(() {
//        _regdetails.addAll(value);
//       // _filterorganization.addAll(value);
//      });
//
////    apiData().then((value) {
////      setState(() {
////        _organization.addAll(value);
////        _filterorganization.addAll(value);
////      });
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


//  Future<List<OrganizationDetails>> apiData() async {
//    String url = "${globals.apiHostingURLBVH}/MobileMaster/GetMaster";
//    var response = await http.post(url,body: {"masterDataType":"ORGANIZATION"});
//    var organizations = List<OrganizationDetails>();
//    if (response.statusCode == 200) {
//      var notesJson = json.decode(response.body)['organizations'];
//      for (var notejson in notesJson) {
//        organizations.add(OrganizationDetails.fromJson(notejson));
//      }
//    }
//    return organizations;
//    //var extractdata = jsonDecode(response.body);
//    //print(extractdata);
//  }
//  PatienRegistrationDetails apptDet;
//  List<PatienRegistrationDetails> _regdetails = List<PatienRegistrationDetails>();
  List <DoctorServiceDetails> data = List<DoctorServiceDetails>();
  getregistrationDetails() async {

    return await http.get(
        Uri.encodeFull(
            "${globals.apiHostingURLBVH}/Patient/GetServiceList?DoctorCode=${widget.doctorDet.doctorCode}"),
//        body: {
//          "MobileNumber": "${globals.mobileNumber}",
//        },
        headers: {"Accept": "application/json"}).then((http.Response response) {
      // setState(() {
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        var extractdata =  jsonDecode(response.body);
        List data1 = extractdata as List;
        if (data1.isNotEmpty) {
//                      setState(() {
//          data = data1;
//                                    });
          for (int i = 0; i < data1.length; i++) {
            setState(() {
              data.add(DoctorServiceDetails.fromJsonnew(data1[i]));
            });
          }

        }
      }
      // });
    });
  }

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
                                  data[index].ServiceName,
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

//              widget.appDetail.PatientCode = _regdetails[index].patientCode;
//              widget.appDetail.PatientName = _regdetails[index].FullName;
//              widget.appDetail.GenderCode = _regdetails[index].genderACode;
//              widget.appDetail.PatientMobile = _regdetails[index].mobileNumber;
//              widget.appDetail.PatientEmail = _regdetails[index].emailID;
              widget.appDetail.ServiceCode = data[index].ServiceCode;
              String aaptDate = DateFormat('yyyy-MM-dd').format(widget.appDetail.ApptDate);
              var url = "${globals.apiHostingURLBVH}/Patient/GetPatApptType?patientcode=${widget.appDetail.PatientCode}&DoctorCode=${widget.doctorDet.doctorCode}&RqstServiceCode=${widget.appDetail.ServiceCode}&apptRqstDate=${aaptDate}";


              var response = await http.get(url,
                  headers: {"Authorization": 'Bearer ${globals.tokenKey}'}
              );


              if (response.statusCode == 200) {
                int drFee = json.decode(response.body)['DrFee'];
                if (drFee!=null) {
//          doc.add(PatientAppointment.fromJsonnew(notejson));
                  widget.appDetail.ConsultationFee=drFee;
                  widget.appDetail.VisitType = json.decode(response.body)['VisitType'];
                  widget.appDetail.BillServiceCode = json.decode(response.body)['ServiceCode'];
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Conformappointment(
                          appDetail: widget.appDetail,
                          doctorDet: widget.doctorDet,
                        ),
                      ));
                }
              }

//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => Conformappointment(appDetail:widget.appDetail,doctorDet: widget.doctorDet,)),
//              );

            },
          );
        },
        itemCount: data.length,
      ),
])
//]
//    ),
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
        child: Text('Select the service'.toUpperCase(),
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

//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//
//    bool isLandscape = MediaQuery.of(context).size.aspectRatio > 1;
//    var size = MediaQuery.of(context).size;
//    print(size);
//    final double itemHeight = 100;
//    print(itemHeight);
//    final double itemWidth = size.width / 4;
//    print(itemWidth);
//
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Organization"),
//      ),
//      body:Container(
//     child: GridView.count(
//          padding: EdgeInsets.all(5.0),
//          crossAxisCount: isLandscape ? 4 : 3,
//          childAspectRatio: 1,
//          controller: new ScrollController(keepScrollOffset: false),
//          shrinkWrap: true,
//          scrollDirection: Axis.vertical,
//          children: List.generate(_organization.length, (index) {
//            return _buildListItem(index);
//          })
//      ),
//
//      ),
//
//    );
//  }
//  Widget _buildListItem(int index) {
//    return  GestureDetector(
//      onTap: (){
//         Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => CategoryList()),
//        );
//      },
//      child: Container(
//      decoration: BoxDecoration(
//        color: Colors.blue
//      ),
//
//        child:Card(
////          color: Colors.blue,
//          elevation: 10.0,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(15.0),
//          ),
//child:Center(
//          child:Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Text(
//                  _organization[index].organization_name,
//                  style: TextStyle(
//                      fontSize: 14.0, fontWeight: FontWeight.bold),
//                ),
//
//              ]
//          ),
//        )
//        ),
//
//      ),
//    );
//
//  }
