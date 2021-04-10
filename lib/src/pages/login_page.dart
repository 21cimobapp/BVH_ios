import 'dart:convert';

import 'package:civideoconnectapp/data_models/PatientRegDetails.dart';
import 'package:civideoconnectapp/firebase/auth/phone_auth/select_country.dart';
import 'package:civideoconnectapp/firebase/auth/phone_auth/verify.dart';
import 'package:civideoconnectapp/providers/countries.dart';
import 'package:civideoconnectapp/providers/phone_auth.dart';
import 'package:civideoconnectapp/utils/animations/bottomAnimation.dart';
import 'package:civideoconnectapp/utils/backBtnAndImage.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

final _controllerName = TextEditingController();
final _controllerPhone = TextEditingController();
final _controllerCNIC = TextEditingController();

class _LoginPageState extends State<LoginPage> {
  //bool validatePhoneVar = false;
  bool validateCNICVar = false;
  bool validateName = false;
  bool validateMobile = false;

  controllerClear() {
    _controllerName.clear();
    _controllerPhone.clear();
    _controllerCNIC.clear();
  }

  validatePhone(String phone) {
    if (!(phone.length == 11) && phone.isNotEmpty) {
      return "Invalid Phone Number length";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final countriesProvider = Provider.of<CountryProvider>(context);

    startPhoneAuth() async {
      final phoneAuthDataProvider =
      Provider.of<PhoneAuthDataProvider>(context, listen: false);
      phoneAuthDataProvider.loading = true;
      var countryProvider =
      Provider.of<CountryProvider>(context, listen: false);
      bool validPhone = await phoneAuthDataProvider.instantiate(
          dialCode: countryProvider.selectedCountry.dialCode,
          onCodeSent: () {
            Navigator.of(context).pushReplacement(CupertinoPageRoute(
                builder: (BuildContext context) => PhoneAuthVerify()));
          },
          onFailed: () {
            Toast.show(phoneAuthDataProvider.message, context,
                backgroundColor: Colors.red,
                backgroundRadius: 5,
                duration: Toast.LENGTH_LONG);
          },
          onError: () {
            Toast.show(phoneAuthDataProvider.message, context,
                backgroundColor: Colors.red,
                backgroundRadius: 5,
                duration: Toast.LENGTH_LONG);
          });
      if (!validPhone) {
        phoneAuthDataProvider.loading = false;
        Toast.show("Oops! Number seems invaild", context,
            backgroundColor: Colors.red,
            backgroundRadius: 5,
            duration: Toast.LENGTH_LONG);

        return;
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          // resizeToAvoidBottomPadding: false,
          body: SafeArea(
            child: Container(
              width: width,
              height: height,
              child: Stack(
                children: <Widget>[
                  BackBtn(),
                  Image.asset("assets/images/Hospitalogo.png",
                      fit: BoxFit.scaleDown),
                  ImageAvatar(
                    assetImage: globals.loginUserType == "PATIENT"
                        ? 'assets/images/bigPat.png'
                        : 'assets/images/bigDoc.png',
                  ),
                  Container(
                    width: width,
                    height: height,
                    margin:
                    EdgeInsets.fromLTRB(width * 0.03, 0, width * 0.03, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          height: height * 0.05,
                        ),
                        WidgetAnimator(Text(
                          globals.loginUserType == "PATIENT"
                              ? "\t\tPatient Login"
                              : "\t\tDoctor Login",
                          style: GoogleFonts.abel(
                              fontSize: height * 0.044,
                              fontWeight: FontWeight.bold),
                        )),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        Column(
                          children: [
                            ShowSelectedCountry(
                              country: countriesProvider.selectedCountry,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => SelectCountry()),
                                );
                              },
                            ),
                            PhoneNumberField(
                              controller: Provider.of<PhoneAuthDataProvider>(
                                  context,
                                  listen: false)
                                  .phoneNumberController,
                              prefix:
                              countriesProvider.selectedCountry.dialCode ??
                                  "+91",
                            ),
                          ],
                        ),
                        //phoneTextField,
                        SizedBox(
                          height: height * 0.02,
                        ),

                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 50,
                              child: Text(
                                'We will send One Time Password to this mobile number',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: height * 0.07,
                        ),
                        SizedBox(
                          width: width,
                          height: height * 0.07,
                          child: RaisedButton(
                            color: Colors.white,
                            shape: StadiumBorder(),
                            onPressed: () {
                              setState(() {
                                Provider.of<PhoneAuthDataProvider>(context,
                                    listen: false)
                                    .phoneNumberController
                                    .text
                                    .isEmpty
                                    ? validateMobile = true
                                    : validateMobile = false;
                              });
                              if (!validateMobile) {
                                checkMobileExists().then((value) {
                                  if (value == 1) {
                                    startPhoneAuth();
                                  } else if (value == 0) {
                                    Toast.show(
                                        "This Mobile number not registered with us. Please Register.",
                                        context,
                                        backgroundColor: Colors.red,
                                        backgroundRadius: 5,
                                        duration: Toast.LENGTH_LONG);
                                  } else if (value == -1) {
                                    Toast.show(
                                        "Network Issue. Please try after some time",
                                        context,
                                        backgroundColor: Colors.red,
                                        backgroundRadius: 5,
                                        duration: Toast.LENGTH_LONG);
                                  }
                                }, onError: (error) {
                                  print(error);
                                });
                              } else {
                                Toast.show(
                                    "Mobile number not entered!", context,
                                    backgroundColor: Colors.red,
                                    backgroundRadius: 5,
                                    duration: Toast.LENGTH_LONG);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: height * 0.022),
                                )
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: height * 0.2,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Future<int> checkMobileExists() async {
    String phoneNumber =
        Provider.of<PhoneAuthDataProvider>(context, listen: false)
            .phoneNumberController
            .text;
    String url;
    if (globals.loginUserType == "DOCTOR") {
      url = "${globals.apiHostingURL}/Doctors/mapp_CheckMobileExists";
    } else {
      // Changed by Abhi for BVH API
//      url = "${globals.apiHostingURL}/Patient/mapp_CheckMobileExists";
      url = "${globals.apiHostingURLBVH}/MobileAppPatient/mapp_GetPatientRegDetails";
      // End Changed by Abhi for BVH API
    }
    return await http.post(Uri.encodeFull(url),
        body: {"MobileNumber": "$phoneNumber"},
        headers: {"Accept": "application/json"}).then((http.Response response) {
      //      print(response.body);
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        PatientRegDet p = PatientRegDet.fromJson(json.decode(response.body));
        if (p.status == 1) {
          return 1;
        } else {
          return 0;
        }
      } else {
        return -1;
      }
    });
  }
}
