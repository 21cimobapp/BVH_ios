import 'dart:io';
import 'dart:math';

import 'package:civideoconnectapp/src/pages/viewAppointment_doctor/View_appointment_doctor.dart';
import 'package:civideoconnectapp/src/pages/ViewDocuments.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/categoryList.dart';
import 'package:civideoconnectapp/src/pages/appointment_new/doctor_appointment_home.dart';
import 'package:civideoconnectapp/src/pages/home_doctor/home_doctor_new.dart';
import 'package:flutter/material.dart';
import 'navbar.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

Color myGreen = Color(0xff4bb17b);

class IndexNewDoctor extends StatefulWidget {
  @override
  _IndexNewDoctorState createState() => _IndexNewDoctorState();
}

class _IndexNewDoctorState extends State<IndexNewDoctor> {
  var isLoading = false;
  List<NavBarItemData> _navBarItems;
  int _selectedNavIndex = 0;

  List<Widget> _viewsByIndex;

  @override
  void initState() {
    super.initState();
    _navBarItems = [
      NavBarItemData("Dashboard", OMIcons.dashboard, 150, Colors.orange[300]),
      NavBarItemData("Appointments", OMIcons.bookmarks, 160, Color(0xff594ccf)),
      //NavBarItemData("My Schedule", OMIcons.schedule, 155, Color(0xff09a8d9)),
      //NavBarItemData("Settings", OMIcons.settings, 120, Color(0xfff2873f)),
    ];

    _viewsByIndex = <Widget>[
      HomePageDoctorNew(),
      ViewAppointmentDoctor(),
      //DoctorAppointmentHome(),
      //HomePageDoctorNew(),
    ];
  }

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  @override
  Widget build(BuildContext context) {
    var accentColor = _navBarItems[_selectedNavIndex].selectedColor;

//Create custom navBar, pass in a list of buttons, and listen for tap event
    var navBar = NavBar(
      items: _navBarItems,
      itemTapped: _handleNavBtnTapped,
      currentIndex: _selectedNavIndex,
    );
    //Display the correct child view for the current index
    var contentView =
        _viewsByIndex[min(_selectedNavIndex, _viewsByIndex.length - 1)];

    Future<bool> _onWillPop() async {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: new Text(
                "Exit Application",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: new Text("Are You Sure?"),
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
                    "Yes",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            ),
          )) ??
          false;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          //Wrap the current page in an AnimatedSwitcher for an easy cross-fade effect
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 350),
            //Pass the current accent color down as a theme, so our overscroll indicator matches the btn color
            child: Theme(
              data: ThemeData(accentColor: accentColor),
              child: contentView,
            ),
          ),
        ),
        bottomNavigationBar: navBar,
      ),
    );
  }

  void _handleNavBtnTapped(int index) {
    //Save the new index and trigger a rebuild
    setState(() {
      //This will be passed into the NavBar and change it's selected state, also controls the active content page
      _selectedNavIndex = index;
    });
  }
}
