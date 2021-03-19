import 'dart:convert';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/src/pages/appointment/Selectatimeslot.dart';
import 'package:flutter/material.dart';

import 'package:civideoconnectapp/globals.dart' as globals;

class Selectaservice extends StatelessWidget {
  final DoctorData doctordata;
  Selectaservice(this.doctordata);
  //  const Appointmenttype({Key key, this.doctordata}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).primaryColor,
        title: Text("SELECT A SERVICE"),
      ),
      body: new Column(children: <Widget>[
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
                        Text(doctordata.doctorName,
                            style: Theme.of(context).textTheme.subtitle2),
                        Text(
                          doctordata.qualification,
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
                SizedBox(
                  height: 10,
                ),
                Text(doctordata.designation,
                    style: Theme.of(context).textTheme.subtitle2)
              ])),
        ),

        SizedBox.fromSize(),
        // new Card(
        //   child:
        new Container(
          padding: new EdgeInsets.all(8.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  child: Text('Schedule Personal Visit'),
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Selectatimeslot(
                              doctorDet: doctordata,
                              appointmenttType: "VISITCONSULT")),
                    );
                  }),
              Text("OR"),
              RaisedButton(
                  child: Text('SCHEDULE Teleconsultation'),
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Selectatimeslot(
                              doctorDet: doctordata,
                              appointmenttType: "VIDEOCONSULT")),
                    );
                  }),
            ],
          ),
        ),
        // ),
      ]),
    );
  }

  Image getDoctorPhoto(i) {
    if (doctordata.doctorPhoto == "") {
      return Image.asset("assets/doctor_defaultpic.png");
    } else {
      return Image.memory(base64Decode(doctordata.doctorPhoto));
    }
  }
}
/*class DetailsScreen extends StatefulWidget {
  final int id;

  const DetailsScreen({Key key, @required this.id}) : super(key: key);
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _showMoreAbout = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, _) => Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: MediaQuery.of(context).size.height / 3,
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(doctorInfo[widget.id].image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.5),
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DraggableScrollableSheet(
                  initialChildSize: 2 / 3,
                  minChildSize: 2 / 3,
                  maxChildSize: 1,
                  builder: (context, scrollController) => Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15.0),
                        topLeft: Radius.circular(15.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          offset: Offset(0, -3),
                          blurRadius: 5.0,
                        )
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${doctorInfo[widget.id].name}",
                                    style: Theme.of(context).textTheme.subtitle,
                                  ),
                                  Text(
                                    "${doctorInfo[widget.id].type}",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: MyColors.orange,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              decoration: BoxDecoration(
                                color: MyColors.darkGreen,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            SmoothStarRating(
                              rating: doctorInfo[widget.id].reviews,
                              size: 15,
                              color: MyColors.orange,
                            ),
                            Text("(${doctorInfo[0].reviewCount} Reviews)"),
                            Expanded(
                              child: FlatButton(
                                child: FittedBox(
                                  child: Text(
                                    "See all reviews",
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(color: MyColors.blue),
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                        Text(
                          "About",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        Wrap(
                          children: <Widget>[
                            Text(
                              "${doctorInfo[widget.id].about}",
                              maxLines: _showMoreAbout ? null : 1,
                            ),
                            FlatButton(
                              child: Text(
                                _showMoreAbout ? "See Less" : "See More",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: MyColors.blue),
                              ),
                              onPressed: () {
                                setState(() {
                                  _showMoreAbout = !_showMoreAbout;
                                });
                              },
                            )
                          ],
                        ),
                        Text(
                          "Working Hours",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        Row(
                          children: <Widget>[
                            Text("${doctorInfo[widget.id].workingHours}"),
                            SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(9.0),
                                child: Text(
                                  "Open",
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(color: MyColors.darkGreen),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Color(0xffdbf3e8),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Stats",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        SizedBox(height: 11),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text("${doctorInfo[widget.id].patientsCount}",
                                    style: Theme.of(context).textTheme.title),
                                Text(
                                  "Patients",
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                    "${doctorInfo[widget.id].experience} Years",
                                    style: Theme.of(context).textTheme.title),
                                Text(
                                  "Experience",
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text("${doctorInfo[widget.id].certifications}",
                                    style: Theme.of(context).textTheme.title),
                                Text(
                                  "Certifications",
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            
                            color: MyColors.blue,
                            child: Text(
                              "Make An Appointement",
                              style: Theme.of(context).textTheme.button,
                            ),
                            onPressed: () {
                               Navigator.push(
                                   context,
                                     MaterialPageRoute(builder: (context) => DateTimePickerWidget2()),
                                );

                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
