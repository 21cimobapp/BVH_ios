import 'package:civideoconnectapp/data_models/PatientAppointmentdetails.dart';
import 'package:civideoconnectapp/src/pages/Index.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

class Payathospital extends StatelessWidget {
  final PatientAppointmentdetails appDetail;

  Payathospital({this.appDetail});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).primaryColor,
          title: Text("Appointment Booking"),
        ),
        //  backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          //color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 80,
                  width: 500,
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 10.0,
                  ),
                  child: Card(
                    //color: Theme.of(context).primaryColor,
                    elevation: 2.0,

                    child: Text(
                      "Hello ${appDetail.PatientName}\nYour Appointment is booked!",
                      //"your payment is successful!!!!!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        //color: globals.appTextColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.circle
                    // ),
                    //color: Theme.of(context).primaryColor,
                    //height: 230,
                    child: Column(children: <Widget>[
                  Container(
                    height: 40,
                    width: 500,
                    //color: Theme.of(context).primaryColor,
                    child: Card(
                      //c olor: Theme.of(context).primaryColor,
                      elevation: 2.0,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Appointment Details",
                          //"your payment is successful!!!!!",
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            //color: globals.appTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 20,
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
                                    top: 10.0,
                                    bottom: 10.0,
                                    left: 10.0,
                                    right: 10.0),
                                child: Row(children: <Widget>[
                                  MyCircleAvatar(
                                      imgUrl: "",
                                      personType: "DOCTOR",
                                      size: 60),
                                  SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 250,
                                        child: Text(appDetail.DoctorName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .title),
                                      ),
                                      Text(
                                        appDetail.DoctorDesignation,
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
                                height: 5.0,
                                indent: 5.0,
                                color: Colors.black,
                              ),
                              Text(
                                  (appDetail.AppointmentType == "VIDEOCONSULT")
                                      ? "Video Consultation"
                                      : "Personal Visit",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  )),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Date",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(appDetail.ApptDate),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ]),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Column(children: <Widget>[
                                    Text(
                                      "Time",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "" + appDetail.SlotTimeLabel,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ])
                                ],
                              ),
                            ])),
                      )
                    ],
                  )
                ])),
                SizedBox(
                  height: 100,
                ),
                new RaisedButton(
                    child: Text('Back To Home'),
                    textColor: globals.appTextColor,
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => IndexPage()),
                      );
                    }),
              ],
            ),
          ),
        ));
  }

  Image getDoctorPhoto(i) {
    //if (appDetail.DoctorPhoto == "") {
    return Image.asset("assets/doctor_defaultpic.png");
    //} else {
    //  return Image.memory(base64Decode(appDetail.DoctorPhoto));
    //}
  }
}
