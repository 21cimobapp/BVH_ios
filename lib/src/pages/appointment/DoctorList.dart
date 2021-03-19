import 'package:cached_network_image/cached_network_image.dart';
//import 'package:civideoconnectapp/data_models/Doctors.dart';
import 'package:civideoconnectapp/src/pages/appointment/Selectaservice.dart';
import 'package:civideoconnectapp/src/pages/appointment/Selectatimeslot.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:civideoconnectapp/globals.dart' as globals;
//import 'package:civideoconnectapp/data_models/Specialization.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:civideoconnectapp/utils/Database.dart';

class DoctorList extends StatefulWidget {
  //final Specialization catagory;
  //const DoctorList({Key key}) : super(key: key);

  @override
  _DoctorListState createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  String selectedSpecialization;
  String selectedSpecializationText = "";
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text("Select a Doctor or Category");
  bool issearching = false;
  //List<Specialization> _specialization = List<Specialization>();

  List<DoctorSpeciality> _specialization = List<DoctorSpeciality>();

  List<DoctorData> _doctor = List<DoctorData>();
  List<DoctorData> _filterdoctor = List<DoctorData>();

  // Future<List<Doctors>> apiData(spec) async {
  //   var url = "${globals.apiHostingURL}/Patient/GetSpecialityWiseDoctors";
  //   var response = await http
  //       .post(url, body: {"SpecialityCode": spec, "OrganizationCode": "ABCH"});

  //   var doc = List<Doctors>();
  //   if (response.statusCode == 200) {
  //     var patientJson = json.decode(response.body)['specialityWiseDoctors'];
  //     if (patientJson != null) {
  //       for (var notejson in patientJson) {
  //         doc.add(Doctors.fromJson(notejson));
  //       }
  //     }
  //   }
  //   return doc;
  //   //var extractdata = jsonDecode(response.body);
  //   //print(extractdata);
  // }

  // Future<List<Specialization>> apiDataSpecialization() async {
  //   var url = "${globals.apiHostingURL}/Master/GetSpecialityDetail";
  //   var response = await http.post(url
  //       /* ,body: {
  //     "Enterydate1":"2012-01-23",
  //     "Enterydate2":"2012-01-23"
  //  }*/
  //       );

  //   var extractdata = jsonDecode(response.body)['specialities'];
  //   print(extractdata);
  //   var patients = List<Specialization>();
  //   if (response.statusCode == 200) {
  //     var patientJson = json.decode(response.body)['specialities'];
  //     for (var notejson in patientJson) {
  //       patients.add(Specialization.fromJson(notejson));
  //     }
  //   }
  //   return patients;
  //   //var extractdata = jsonDecode(response.body);
  //   //print(extractdata);
  // }

  @override
  void initState() {
    // apiDataSpecialization().then((value) {
    //   setState(() {
    //     _specialization.addAll(value);
    //   });
    // });

    DatabaseMethods().getDoctorSpeciality().then((value) => {
          setState(() {
            _specialization = value;
          })
        });

    setState(() {
      selectedSpecialization = "ALL";
    });
    List<DoctorSessions> sessionDet = List<DoctorSessions>();

    DatabaseMethods().getDoctors(selectedSpecialization).then((value) => {
          setState(() {
            _doctor.addAll(value);
            _filterdoctor.addAll(value);
          })
        });

    // apiData(selectedSpecialization).then((value) {
    //   setState(() {
    //     _doctor.addAll(value);
    //     _filterdoctor.addAll(value);
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,

        elevation: 20.0,
        title: cusSearchBar,
        // title:  Text("Doctors", style: Theme.of(context).textTheme.title),
        actions: <Widget>[
          new IconButton(
            onPressed: () {
              setState(() {
                if (this.cusIcon.icon == Icons.search) {
                  this.issearching = true;
                  _filterdoctor = _doctor;
                  this.cusIcon = Icon(Icons.cancel);
                  this.cusSearchBar = TextField(
                    textInputAction: TextInputAction.go,
                    decoration: new InputDecoration(
                      hintText: 'Search here...',
                    ),
                    onChanged: (string) {
                      setState(() {
                        _filterdoctor = _doctor
                            .where((n) => (n.doctorName
                                .toLowerCase()
                                .contains(string.toLowerCase())))
                            .toList();
                      });
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  );
                } else {
                  this.issearching = false;
                  _filterdoctor = _doctor;
                  this.cusIcon = Icon(Icons.search);
                  this.cusSearchBar = Text(
                    "Select a Doctor or Category", //style: Theme.of(context).textTheme.title
                  );
                }
              });
            },
            icon: cusIcon,
          ),
        ],
      ),
      body:
          // Container(
          //   child: SingleChildScrollView(
          //  child:
          Column(
        children: <Widget>[
          SizedBox(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _specialization.length,
                itemExtent: 100.0,
                itemBuilder: (context, index) {
                  var item = _specialization[index];
                  return GestureDetector(
                      onTap: () {
                        // apiData(item.speciality_code).then((value) {
                        //   setState(() {
                        //     selectedSpecialization = item.speciality_code;
                        //     selectedSpecializationText = item.speciality_name;
                        //     _doctor.clear();
                        //     _filterdoctor.clear();
                        //     _doctor.addAll(value);
                        //     _filterdoctor.addAll(value);
                        //   });
                        // });

                        DatabaseMethods()
                            .getDoctors(item.specialityId)
                            .then((value) => {
                                  setState(() {
                                    selectedSpecialization = item.specialityId;
                                    selectedSpecializationText =
                                        item.speciality;
                                    _doctor.clear();
                                    _filterdoctor.clear();
                                    _doctor.addAll(value);
                                    _filterdoctor.addAll(value);
                                  })
                                });
                      },
                      child: Container(
                          width: 70,
                          height: 200,
                          //color: Colors.red,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              getSpecialtyImage(
                                  'http://21ci.com/21online/Specialties/' +
                                      item.speciality +
                                      '.png'),
                              Text(item.speciality,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15),
                                  overflow: TextOverflow.ellipsis)
                            ],
                          )));
                }),
          ),
          SizedBox(
            height: 1,
          ),
          selectedSpecializationText == ""
              ? Container()
              : Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Chip(
                        label: Text(selectedSpecializationText == "ALL"
                            ? "Showing All doctors"
                            : "Showing doctors from $selectedSpecializationText"),
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
          new Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return new GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                    child: Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0,
                                left: 10.0,
                                right: 10.0),
                            child: Row(children: <Widget>[
                              MyCircleAvatar(
                                  imgUrl: "", personType: "DOCTOR", size: 50),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 280,
                                    child: Text(_filterdoctor[index].doctorName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(
                                    _filterdoctor[index].qualification,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ]),
                          ),
                          Divider(
                            height: 10.0,
                            indent: 5.0,
                            color: Colors.black87,
                          ),
                          // Container(
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: <Widget>[
                          //       Chip(
                          //         label: Text(_filterdoctor[index].designation),
                          //         backgroundColor: Colors.grey[50],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                          new Center(
                            child: RaisedButton(
                                child: Text('Schedule Appointment'),
                                textColor: Colors.white,
                                color: Theme.of(context).accentColor,
                                onPressed: () {
                                  _settingModalBottomSheet(index, context);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         Selectaservice(_filterdoctor[index]),
                                  //   ),
                                  // );
                                }),
                          ),
                        ])),
                  ),
                  onTap: () {
                    // doctordata= new Doctors(doctordata.doctor_code,doctordata.doctor_name,doctordata.doctor_designation,doctordata.doctor_availabledays);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         Selectaservice(_filterdoctor[index]),
                    //   ),
                    // );
                  },
                );
              },
              itemCount: _filterdoctor.length,
            ),
          )
        ],
      ),
      //   ),
      // ),
    );
  }

  Widget getSpecialtyImage(url) {
    try {
      return SizedBox(
          height: 70,
          width: 70,
          child: CachedNetworkImage(
            useOldImageOnUrlChange: true,
            imageUrl: url,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) {
              return Image(
                image: AssetImage('assets/specialty.png'),
              );
            },
          ));
    } catch (e) {
      return Image(
        image: AssetImage('assets/specialty.png'),
      );
    }
  }

  void _settingModalBottomSheet(i, context) {
    //List<AppointmentDetails> apptList = List<AppointmentDetails>();

    //(tab == "UPCOMMING") ? apptList = apptList1 : apptList = apptList2;
    //apptList = apptList1;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return new Container(
            color: Colors.transparent,
            //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(20.0),
                      topRight: const Radius.circular(20.0))),
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Selectatimeslot(
                                doctorDet: _filterdoctor[i],
                                appointmenttType: "VISITCONSULT")),
                      );
                    },
                    leading: new Icon(
                      Icons.person,
                    ),
                    title: Text("Schedule Personal Visit"),
                  ),
                  new ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Selectatimeslot(
                                doctorDet: _filterdoctor[i],
                                appointmenttType: "VIDEOCONSULT")),
                      );
                    },
                    leading: new Icon(
                      Icons.video_call,
                    ),
                    title: Text("Schedule Video consultation"),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Image getDoctorPhoto(i) {
    if (_filterdoctor[i].doctorPhoto == "") {
      return Image.asset("assets/doctor_defaultpic.png");
    } else {
      return Image.memory(base64Decode(_filterdoctor[i].doctorPhoto));
    }
  }
}
