import 'package:civideoconnectapp/data_models/PatientRegDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:civideoconnectapp/globals.dart' as globals;
import 'dart:convert';

class MyProfile extends StatefulWidget {
  MyProfile({Key key}) : super(key: key);

  @override
  myProfileState createState() => new myProfileState();
}

class myProfileState extends State<MyProfile> {
  var patientDet;

  @override
  void initState() {
    super.initState();
    patientDet = globals.user;
  }

  TextStyle _style() {
    return TextStyle(fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Email",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(_getUserData("EmailID")),
            SizedBox(
              height: 16,
            ),
            Text(
              "Mobile",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(_getUserData("MobileNumber")),
            SizedBox(
              height: 16,
            ),
            Text(
              "Address",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text("${_getUserData("Address1")} ${_getUserData("Address2")}"),
            SizedBox(
              height: 16,
            ),
            Text(
              "State",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(_getUserData("StateName")),
            SizedBox(
              height: 16,
            ),
            Text(
              "City",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(_getUserData("CityName")),
            SizedBox(
              height: 16,
            ),
            Text(
              "PinCode",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(_getUserData("PinCode")),
            SizedBox(
              height: 16,
            ),
            Divider(
              color: Colors.grey,
            ),
            RaisedButton(
              elevation: 16.0,
              //onPressed: startPhoneAuth,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Back to Home',
                  style: TextStyle(color: globals.appTextColor, fontSize: 18.0),
                ),
              ),
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            )
          ],
        ),
      ),
    );
  }
}

String _getUserData(type) {
  if (globals.user != null) {
    return globals.user[0][type];
  } else
    return '';
}

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => Size(double.infinity, 320);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(color: Colors.red, blurRadius: 20, offset: Offset(0, 0))
            ]),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Text(
                  "My Profile",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: <Widget>[
                    getUserPhoto(),
                    //SizedBox(height: 16,),
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 200),
                    Text(
                      "${_getUserData("FirstName")} ${_getUserData("LastName")}",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ],
                ),

                //     Column(
                //       children: <Widget>[
                //         Text("Routines", style: TextStyle(
                //             color: Colors.white
                //         ),),
                //         Text("4", style: TextStyle(
                //             fontSize: 26,
                //             color: Colors.white
                //         ),)
                //       ],
                //     ),
                //   ],
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: <Widget>[

                //     Column(
                //       children: <Widget>[
                //         Text("Savings", style: TextStyle(
                //           color: Colors.white
                //         ),),
                //         Text("20K", style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 24
                //         ),)
                //       ],
                //     ),

                //     SizedBox(width: 32,),

                //     Column(
                //       children: <Widget>[
                //         Text("July Goals",
                //         style: TextStyle(
                //           color: Colors.white
                //         ),),
                //         Text("50K", style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 24
                //         ))
                //       ],
                //     ),

                SizedBox(
                  width: 10,
                ),
              ],
            ),

            //SizedBox(height: 8,),

            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: GestureDetector(
            //     onTap: (){
            //       print("//TODO: button clicked");
            //     },
            //     child: Padding(
            //       padding: const EdgeInsets.fromLTRB(0, 24, 16, 0),
            //       child: Transform.rotate(
            //         angle: (math.pi * 0.05),
            //         child: Container(
            //           width: 110,
            //           height: 32,
            //           child: Center(child: Text("Edit Profile"),),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius: BorderRadius.all(Radius.circular(16)),
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.black12,
            //                 blurRadius: 20
            //               )
            //             ]
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            //)
          ],
        ),
      ),
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
            image: AssetImage("assets/patient_defaultpic.png"),
            fit: BoxFit.fill),
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

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();

    p.lineTo(0, size.height - 70);
    p.lineTo(size.width, size.height);

    p.lineTo(size.width, 0);

    p.close();

    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
