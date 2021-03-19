library my_prj.globals;

import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/utils/Database.dart';
//import 'package:flutter_callkeep/flutter_callkeep.dart';

List user;
String loginUserType;
String personCode;
String personName;
String personGender;
String tokenKey;
bool isOnline = false;
String msgRTM;

bool isLogin = false;
AgoraRtmClient clientRTM;
//AgoraRtmChannel channelRTM;
Color appMainColor = Color(0xFF128C7E);
Color appTextColor = Colors.white;
Color appSecondColor = Color(0xff4bb17b);
List<HolidayData> holidayList = List<HolidayData>();

final apiHostingURL = "http://devp.21ci.com:81/MobileAppEx";
final apiHostingURLBVH = "http://devp.21ci.com:81/BVHApptPortalAPI/api";
//final apiHostingURL = "http://patient.bhaktivedantahospital.com/MobileAppEx";

getProfilePic(userType) {
  if (userType == "DOCTOR")
    return Image.asset("assets/images/male_doctor.png");
  else if (userType == "PATIENT")
    return Image.asset("assets/images/male_patient.png");

  // if (userType == "DOCTOR" && gender == "GENDERMALE")
  //   return Image.asset("assets/images/male_doctor.png");
  // else if (userType == "DOCTOR" && gender == "GENDERFEMALE")
  //   return Image.asset("assets/images/female_doctor.png");
  // else if (userType == "PATIENT" && gender == "GENDERMALE")
  //   return Image.asset("assets/images/male_patient.png");
  // else if (userType == "PATIENT" && gender == "GENDERFEMALE")
  //   return Image.asset("assets/images/female_patient.png");
}
