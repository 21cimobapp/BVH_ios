import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:civideoconnectapp/data_models/Specialization.dart';
import 'package:civideoconnectapp/src/pages/appointment/DoctorList.dart';
import 'dart:async';
import 'dart:convert';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/utils/widgets.dart';

class Speciallitylist extends StatefulWidget {
  @override
  _SpeciallitylistState createState() => _SpeciallitylistState();
}

class _SpeciallitylistState extends State<Speciallitylist> {
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text("Category");
  bool issearching = false;

  List<Specialization> _specialization = List<Specialization>();
  List<Specialization> _filterspecialization = List<Specialization>();

  Future<List<Specialization>> apiData() async {
    var url = "${globals.apiHostingURL}/Master/GetSpecialityDetail";
    var response = await http.post(url
        /* ,body: {
      "Enterydate1":"2012-01-23",
      "Enterydate2":"2012-01-23"
   }*/
        );

    var extractdata = jsonDecode(response.body)['specialities'];
    print(extractdata);
    var patients = List<Specialization>();
    if (response.statusCode == 200) {
      var patientJson = json.decode(response.body)['specialities'];
      for (var notejson in patientJson) {
        patients.add(Specialization.fromJson(notejson));
      }
    }
    return patients;
    //var extractdata = jsonDecode(response.body);
    //print(extractdata);
  }

  @override
  void initState() {
    apiData().then((value) {
      setState(() {
        _specialization.addAll(value);
        _filterspecialization.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print(size);
    final double itemHeight = (size.height - kToolbarHeight - 24) / 10;
    print(itemHeight);
    final double itemWidth = size.width / 4;
    print(itemWidth);
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).primaryColor,
        elevation: 20.0,
        title: cusSearchBar,
        // title:  Text("Doctors", style: Theme.of(context).textTheme.title),
        actions: <Widget>[
          new IconButton(
            onPressed: () {
              setState(() {
                if (this.cusIcon.icon == Icons.search) {
                  this.issearching = true;
                  _filterspecialization = _specialization;
                  this.cusIcon = Icon(Icons.cancel);
                  this.cusSearchBar = TextField(
                    textInputAction: TextInputAction.go,
                    decoration: new InputDecoration(
                      hintText: 'Search here...',
                    ),
                    onChanged: (string) {
                      setState(() {
                        _filterspecialization = _specialization
                            .where((n) => (n.speciality_name
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
                  _filterspecialization = _specialization;
                  this.cusIcon = Icon(Icons.search);
                  this.cusSearchBar = Text(
                    "Select Category", //style: Theme.of(context).textTheme.title
                  );
                }
              });
            },
            icon: cusIcon,
          ),
        ],
      ),
      body: Container(
          //height: 150,
          child: GridView.count(
        padding: EdgeInsets.all(8.0),
        // crossAxisCount is the number of columns
        crossAxisCount: 2,
        childAspectRatio: (itemWidth / itemHeight),
        controller: new ScrollController(keepScrollOffset: false),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        // This creates two columns with two items in each column
        children: List.generate(_filterspecialization.length, (index) {
          return GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         DoctorList(catagory: _filterspecialization[index]),
                //   ),
                // );
              },
              child: CategoryCard(
                  specialization: _filterspecialization[index].speciality_name)
              // child: Card(
              //   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              //   elevation: 10.0,
              //   child: Stack(
              //     children: <Widget>[
              //       Align(
              //         alignment: Alignment.topCenter,
              //         child: Container(
              //           decoration: BoxDecoration(
              //               // image: DecorationImage(
              //               //   image: AssetImage("assets/specialityDefault.jpg"),
              //               //   fit: BoxFit.cover,
              //               //   alignment: Alignment.topCenter,
              //               // ),
              //               //borderRadius: BorderRadius.all(Radius.circular(10.0)),
              //               color: Colors.blueGrey),
              //           //child: getSpeciallityPhoto(index),
              //           height: 150,
              //         ),
              //       ),
              //       Positioned(
              //         bottom: 0,
              //         right: 0,
              //         left: 0,
              //         child: Card(
              //           color: Colors.transparent,
              //           child: Text(_specialization[index].speciality_name,
              //               style: TextStyle(
              //                   fontSize: 15, fontWeight: FontWeight.w800)),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // child: Card(
              //   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              //   elevation: 10.0,
              //   color: Colors.blue[200],

              //   child: Container(

              //     ////     color: Colors.white,
              //     margin: new EdgeInsets.all(4.0),
              //     //child: new Center(

              //     child: new Text(_specialization[index].speciality_name,
              //         style: new TextStyle(fontSize: 17.0, color: Colors.black)),
              //     //),
              //   ),
              // ),
              );
        }),
      )),
    );
  }

  Image getSpeciallityPhoto(i) {
    if (_specialization[i].speciality_image == null) {
      return Image.asset("assets/specialityDefault.jpg");
    } else {
      if (_specialization[i].speciality_image == "") {
        return Image.asset("assets/specialityDefault.jpg");
      } else {
        return Image.memory(base64Decode(_specialization[i].speciality_image));
      }
    }
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key key,
    @required this.specialization,
  }) : super(key: key);

  final String specialization;

  @override
  Widget build(BuildContext context) {
    return Container(
        //height: 280,
        //width: AppTheme.fullWidth(context) * .3,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
        decoration: BoxDecoration(
          color: LightColor.skyBlue,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 10,
              color: Colors.black.withOpacity(.8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -20,
                  left: -20,
                  child: CircleAvatar(
                    backgroundColor: LightColor.lightBlue,
                    radius: 50,
                    //backgroundImage: AssetImage("appheader.jpg"),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 10),
                      child: Text(specialization,
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
