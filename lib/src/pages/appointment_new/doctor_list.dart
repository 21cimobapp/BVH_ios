import 'dart:ui';
import 'package:civideoconnectapp/src/pages/appointment_new/Selectatimeslot.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/rounded_shadow.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter/material.dart';
import 'doctor_card.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

final Color _backgroundColor = Color(0xFFf0f0f0);

class DoctorList extends StatefulWidget {
  final DoctorSpeciality specialization;
  final String organizationCode;
  const DoctorList({Key key, this.specialization,this.organizationCode}) : super(key: key);

  @override
  _DoctorListState createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  double _listPadding = 20;
  DoctorData _selectedDoctor;
  ScrollController _scrollController = ScrollController();

  List<DoctorData> _doctor = List<DoctorData>();
  List<DoctorData> _filterdoctor = List<DoctorData>();
  Icon cusIcon;
  bool issearching = false;
  Color appBarIconsColor = Color(0xFF212121);
  Widget cusSearchBar;
  Widget cusSearchBarDefault;

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  @override
  void initState() {
    // Changed by Abhi for Firebase to API.
    setState(() {
      loadDoctors();
    });
//    DatabaseMethods()
//        .getDoctors(widget.specialization == null
//            ? "ALL"
//            : widget.specialization.specialityId)
//        .then((value) => {
//              setState(() {
//                _doctor.addAll(value);
//                _filterdoctor.addAll(value);
//              })
//            });
    // End Changed by Abhi for Firebase to API.
    cusIcon = Icon(Icons.search, color: appBarIconsColor);
    cusSearchBarDefault = Text('Book an Appointment'.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          letterSpacing: 0.5,
          color: appBarIconsColor,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.bold,
        ));
    cusSearchBar = cusSearchBarDefault;
    super.initState();
  }

  loadDoctors() async {
    return await http.post(
        Uri.encodeFull(
            '${globals.apiHostingURLBVH}/MobileAppPatient/GetSpecialityWiseDoctors'),
        body: {"SpecialityCode": widget.specialization == null ? "ALL" : widget.specialization.specialityId,
          "OrganizationCode": widget.organizationCode},
        headers: {"Accept": "application/json"}).then((http.Response response) {
      // setState(() {
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        var extractdata = jsonDecode(response.body)['specialityWiseDoctors'];
        print (extractdata);

        List data = extractdata as List;
        if (data != null) {
          for (int i = 0; i < data.length; i++) {
            setState(() {
            _doctor.add(DoctorData.fromJsonnew(data[i]));
            _filterdoctor.add(DoctorData.fromJsonnew(data[i]));
            });
          }
        }
      }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).size.aspectRatio > 1;

    //MediaQuery.of(context).size.height  * (isLandscape ? .25 : .2);
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children:<Widget> [
          Container(
              height: 50,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  //child: Text("Find Doctors", style: TextStyle(fontSize: 16)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Find Doctors", style: TextStyle(fontSize: 18)),
                        MaterialButton(
                            height: 50,
                            color: Colors.indigo,
                            child: Text("Select by category",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/CategoryList');
                            }
                        ),
                      ]
                  ),

                ),
              )),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: RoundedShadow.fromRadius(
              12,
              child: Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                color: Colors.white,
                child: widget.specialization != null
                    ? Row(
                        children: [
                          Hero(
                              tag: '${widget.specialization.specialityId}',
                              child: Image.network(
                                widget.specialization.imageURL == null
                                    ? "http://www.21ci.com/21online/Specialties/Default.png"
                                    : widget.specialization.imageURL ?? "",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              )),
                          SizedBox(width: 20),
                          Container(
                            width: MediaQuery.of(context).size.width - 150,
                            child: Text(
                              "${widget.specialization.speciality}",
                              style: bodyTextStyle.copyWith(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Hero(
                              tag: 'ALL',
                              child: Image.network(
                                "http://www.21ci.com/21online/Specialties/Default.png",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              )),
                          SizedBox(width: 20),
                          Container(
                            width: MediaQuery.of(context).size.width - 150,
                            child: Text(
                              "All Specialties",
                              style: bodyTextStyle.copyWith(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return new GestureDetector(
                  child: _buildListItem(index),
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
              controller: _scrollController,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: _listPadding / 2, horizontal: _listPadding),
      child: DoctorCard(
          //earnedPoints: _earnedPoints,
          doctorData: _filterdoctor[index],
          isOpen: _filterdoctor[index] == _selectedDoctor,
          onTap: _handleDoctorTapped,
          onOptionSelected: _handleOptionSelected),
    );
  }

  void _handleOptionSelected(DoctorData data, int option) {
    if (option == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Selectatimeslot(
                doctorDet: data, appointmentType: "VIDEOCONSULT",organizationCode:widget.organizationCode)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Selectatimeslot(
                doctorDet: data, appointmentType: "VISITCONSULT",organizationCode:widget.organizationCode)),
      );
    }
  }

  void _handleDoctorTapped(DoctorData data) {
    setState(() {
      //If the same drink was tapped twice, un-select it
      if (_selectedDoctor == data) {
        _selectedDoctor = null;
      }
      //Open tapped drink card and scroll to it
      else {
        _selectedDoctor = data;
        var selectedIndex = _doctor.indexOf(_selectedDoctor);
        var closedHeight = DoctorCard.nominalHeightClosed;
        //Calculate scrollTo offset, subtract a bit so we don't end up perfectly at the top
        var offset =
            selectedIndex * (closedHeight + _listPadding) - closedHeight * .35;

        _scrollController.animateTo(offset,
            duration: Duration(milliseconds: 700), curve: Curves.easeOutQuad);
      }
    });
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
        new IconButton(
          onPressed: () {
            setState(() {
              if (this.cusIcon.icon == Icons.search) {
                this.issearching = true;
                _filterdoctor = _doctor;
                this.cusIcon = Icon(
                  Icons.cancel,
                  color: Colors.black,
                );
                this.cusSearchBar = TextField(
                  textInputAction: TextInputAction.go,
                  autofocus: true,
                  decoration: new InputDecoration(
                    hintText: 'Search here...',
                  ),
                  onChanged: (string) {
                    setState(() {
                      _filterdoctor = _doctor
                          .where((n) => (n.doctorName
                              .toLowerCase()
                          .contains(string.toLowerCase())) || n.designation.toLowerCase().contains(string.toLowerCase()))
                          .toList();
                    });
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                );
              } else {
                this.issearching = false;
                _filterdoctor = _doctor;
                this.cusIcon = Icon(Icons.search, color: Colors.black);
                this.cusSearchBar = cusSearchBarDefault;
              }
            });
          },
          icon: cusIcon,
        ),
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
        child: this.cusSearchBar,
      ),
    );
  }
}
