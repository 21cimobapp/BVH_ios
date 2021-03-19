import 'dart:async';

import 'package:civideoconnectapp/src/pages/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:civideoconnectapp/data_models/DrawerItem.dart';
import 'package:civideoconnectapp/src/pages/HomeDoctor.dart';
import 'package:civideoconnectapp/src/pages/HomePatient.dart';

import 'package:civideoconnectapp/firebase/auth/phone_auth/authservice.dart';
import 'package:civideoconnectapp/startscreen.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/data_models/PatientRegDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:civideoconnectapp/utils/widgets.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 0;

  final drawerItems = [
    new DrawerItem("Home", Icons.home),
    new DrawerItem("Contact Us", Icons.contacts),
    new DrawerItem("Logout", Icons.exit_to_app)
  ];

  _getDrawerItemScreen(int pos) {
    switch (pos) {
      case 0:
        var page;
        if (_loginUserType() == "DOCTOR") {
          page = new HomePageDoctor();
        } else {
          page = new HomePagePatient();
        }
        return page;

      case 2:
        AuthService().signOut();
        return new StartScreen();
    }
  }

  _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
      _getDrawerItemScreen(_selectedIndex);
    });
    Navigator.of(context).pop(); // close the drawer
  }

  DateTime currentBackPressTime;

  String currentMobileNo = '';
  String userID = '';

  // FirebaseUser mCurrentUser;
  // FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    // _auth = FirebaseAuth.instance;
    //  _getCurrentUser();
  }

  // _getCurrentUser() async {
  //   mCurrentUser = await _auth.currentUser();

  //   setState(() {
  //     if (mCurrentUser != null) {
  //       getPatientDetails(mCurrentUser.phoneNumber).then((value) {
  //         print('1');
  //       });

  //     }

  //   });
  // }

  // Future<PatientRegDet> getPatientDetails(phoneNumber) async {
  //   return await http.post(
  //       Uri.encodeFull(
  //           '${globals.apiHostingURL}/Patient/mapp_GetPatientRegDetails'),
  //       body: {"MobileNumber": "$phoneNumber"},
  //       headers: {"Accept": "application/json"}).then((http.Response response) {
  //     //      print(response.body);
  //     final int statusCode = response.statusCode;
  //     if (statusCode == 200) {
  //       var extractdata = jsonDecode(response.body)['patientDetails'];
  //       List data = extractdata as List;
  //       globals.user = data;
  //       // if (p.status == 1) {
  //       //   globals.loginUser=p;
  //       // } else {
  //       //   return null;
  //       // }
  //       return null;
  //     } else {
  //       return null;
  //     }
  //   });
  // }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }

// FirebaseUser user = await _auth.currentUser();

// UserUpdateInfo userUpdateInfo = UserUpdateInfo();

// userUpdateInfo.displayName = 'Ayush';
// userUpdateInfo.photoUrl = '<my photo url>';

// await user.updateProfile(userUpdateInfo);

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(
          d.title,
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        ),
        selected: i == _selectedIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).primaryColor,
          //iconTheme: IconThemeData(color: globals.appTextColor),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MyCircleAvatar(
                imgUrl: "",
                personType: globals.loginUserType,
              ),
              SizedBox(width: 15),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 180,
                    child: Text(
                        (_loginUserType() == "DOCTOR")
                            ? "${_getUserData('FullName')}"
                            : "${_getUserData('Salutation')} ${_getUserData('FirstName')}",
                        //style: TextStyle(color: globals.appTextColor),
                        overflow: TextOverflow.fade),
                  )
                ],
              )
            ],
          ),
          titleSpacing: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                return Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
          //backgroundColor: Theme.of(context).primaryColor,
        ),
        // drawer: Drawer(
        //   child: new ListView(
        //     children: <Widget>[
        //       DrawerHeader(
        //         decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: <Widget>[
        //             Flexible(
        //               child: getUserPhoto(),
        //             ),
        //             Text(
        //               //"",
        //               (_loginUserType() == "DOCTOR")
        //                   ? _getUserData('FullName')
        //                   : _getUserData('FirstName'),
        //               //globals.user[0]['FirstName'],
        //               style: TextStyle(
        //                   fontSize: 15.0,
        //                   fontWeight: FontWeight.w500,
        //                   color: Colors.white),
        //             ),
        //             Text(
        //               _getUserData('MobileNumber'),
        //               //globals.user[0]['MobileNumber'],
        //               style: TextStyle(
        //                   fontSize: 12.0,
        //                   fontWeight: FontWeight.w500,
        //                   color: Colors.white70),
        //             ),
        //             Container(
        //               alignment: Alignment.center,
        //               width: 100,
        //               child: Text(
        //                 globals.isLogin ? "Online" : "Offline",
        //                 style: TextStyle(color: Colors.white),
        //               ),
        //               padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        //               //width: 200.0,
        //               decoration: BoxDecoration(
        //                   color: globals.isLogin ? Colors.green : Colors.red,
        //                   borderRadius: BorderRadius.circular(8.0)),
        //               margin: EdgeInsets.only(right: 5.0),
        //             )
        //           ],
        //         ),
        //       ),
        //       new Column(children: drawerOptions)
        //     ],
        //   ),
        // ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: MyCircleAvatar(
                          imgUrl: "",
                          personType: globals.loginUserType,
                          size: 80),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 180,
                        child: Text(
                          (_loginUserType() == "DOCTOR")
                              ? "${_getUserData('FullName')}"
                              : "${_getUserData('Salutation')} ${_getUserData('FirstName')}",
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight + Alignment(0, .4),
                      child: Text(
                        (_loginUserType() == "DOCTOR") ? "Doctor" : "Patient",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    globals.loginUserType == "DOCTOR" &&
                            globals.isOnline == true
                        ? Align(
                            alignment: Alignment.centerRight + Alignment(0, 1),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  globals.isOnline ? "Online" : "",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              new Column(children: drawerOptions)
            ],
          ),
        ),
        body: _getDrawerItemScreen(_selectedIndex),
      ),
    );
  }

  String _loginUserType() {
    if (globals.loginUserType != null) {
      return globals.loginUserType;
    } else
      return '';
  }

  Widget getUserProfileImage() {
    if (_getUserData("ProfileImage") == "") {
      return CircleAvatar(
        backgroundImage: (_loginUserType() == "DOCTOR")
            ? AssetImage("assets/doctor_defaultpic.png")
            : AssetImage("assets/patient_defaultpic.png"),
        radius: 50.0,
      );
    } else {
      return CircleAvatar(
        backgroundImage:
            MemoryImage(base64Decode(_getUserData("ProfileImage"))),
        radius: 50.0,
      );
    }
  }

  Widget getUserPhoto() {
    if (_getUserData("ProfileImage") == "") {
      return Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: (_loginUserType() == "DOCTOR")
                  ? AssetImage("assets/doctor_defaultpic.png")
                  : AssetImage("assets/patient_defaultpic.png"),
              fit: BoxFit.cover),
        ),
      );
    } else {
      Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: MemoryImage(base64Decode(_getUserData("ProfileImage"))),
              fit: BoxFit.fill),
        ),
      );
    }
  }

  Future<bool> _onBackPressed() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press back again to exit");
      return Future.value(false);
    }
    Fluttertoast.showToast(msg: "Thank you");
    return Future.value(true);
  }
}

// class MyPopupItem {
//   MyPopupItem({this.title, this.icon});
//   String title;
//   IconData icon;
// }

// List<MyPopupItem> choices = <MyPopupItem>[
//   MyPopupItem(title: "Online", icon: Icons.offline_pin),
//   MyPopupItem(title: "Settings", icon: Icons.settings)
// ];
