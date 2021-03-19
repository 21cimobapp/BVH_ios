import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/call.dart';
import 'package:civideoconnectapp/src/pages/index/index_new.dart';
import 'package:civideoconnectapp/src/pages/index/index_new_doctor.dart';
import 'package:civideoconnectapp/src/pages/welcome/welcome_screen.dart';
import 'package:civideoconnectapp/src/utils/settings.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:civideoconnectapp/src/pages/UserSelection.dart';
import 'package:civideoconnectapp/utils/constants.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
//import 'package:civideoconnectapp/intro_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civideoconnectapp/src/utils/UserDatabaseUtil.dart';
import 'package:civideoconnectapp/data_models/userdata.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:civideoconnectapp/utils/Database.dart';

class StartScreen extends StatefulWidget {
  final bool firstTimeLogin;

  const StartScreen({Key key, this.firstTimeLogin}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  FirebaseUser mCurrentUser;
  UserDatabaseUtil userDatabase;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');

  @override
  void initState() {
    super.initState();
    // userDatabase = UserDatabaseUtil();
    // userDatabase.initState();
    globals.loginUserType='PATIENT'; // Added by Abhi to skip Doctor login.
    FirebaseAuth.instance.currentUser().then((res) {
      print(res);

      if (res != null) {
        loadIndexPage(res);
      } else {
        loadLogin(context);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => PhoneAuthGetPhone()),
        // );
      }
    });
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.ci.civideoconnectapp'
          : 'com.ciiso.civideoconnectapp',
      'Notification',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  updateLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    if (_loginUserType() != "") {
      prefs.setString('loginUserType', globals.loginUserType);
    } else {
      final key = 'loginUserType';
      final value = prefs.getString(key) ?? "";
      globals.loginUserType = value;
    }

    if (_loginUserType() != "") {
      prefs.setString('personCode', globals.personCode);
    } else {
      final key = 'personCode';
      final value = prefs.getString(key) ?? "";
      globals.personCode = value;
    }
  }

  updateUserToDatabase(FirebaseUser res) async {
    String msgToken;
    await firebaseMessaging.getToken().then((val) {
      msgToken = val;
    });

    try {
      await DatabaseMethods().deleteUserInfo(res.phoneNumber);
    } catch (error) {
      print("deleteUserInfo error");
    }

    Map<String, String> userDataMap = {
      "userName": globals.personName,
      "mobile": res.phoneNumber,
      "userCode": globals.personCode,
      "userType": globals.loginUserType,
      "userToken": msgToken,
    };

    DatabaseMethods().addUserInfo(globals.personCode, userDataMap);
  }

  loadLogin(context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('loginUserType', "");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  loadIndexPage(res) async {
    loadHolidays();
    await updateLocalDatabase();

    if (_loginUserType() == "DOCTOR") {
      await getDcotorDetails(res.phoneNumber);
    } else {
      await getPatientDetails(res.phoneNumber);
    }

    if (widget.firstTimeLogin == true) {
      await updateUserToDatabase(res);
    }
    //await _createClient();
    //await _loginToChatService();

    await DatabaseMethods().getUserInfoByID(globals.personCode).then(
        (snapshot) => snapshot.documents
            .forEach((f) => globals.isOnline = f.data['onlineStatus']));
    if (globals.isOnline == null) globals.isOnline = false;

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => IndexPage()),
    // );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            _loginUserType() == "DOCTOR" ? IndexNewDoctor() : IndexNew(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  loadHolidays() {
    DatabaseMethods().getHolidays().then((val) {
      setState(() {
        globals.holidayList = val;
      });
    });
  }

  // void _loginToChatService() async {
  //   String userId = globals.personCode;

  //   try {
  //     await globals.clientRTM.login(null, userId);
  //     //_log('Connected : ' + userId);
  //     setState(() {
  //       globals.isLogin = true;
  //     });
  //   } catch (errorCode) {
  //     //_log('Connetion error: ' + errorCode.toString());
  //     setState(() {
  //       globals.isLogin = false;
  //     });
  //   }
  // }

  // void _createClient() async {
  //   globals.clientRTM = await AgoraRtmClient.createInstance(APP_ID);
  //   globals.clientRTM.onMessageReceived =
  //       (AgoraRtmMessage message, String peerId) {
  //     //setState(() {
  //     //globals.infoStrings.insert(0, message.text);
  //     //});

  //     //_log("Peer msg:" + message.text);
  //     //showNotification(message.text);
  //     _showSoundUriNotification(message.text);
  //     // globals.msgRTM=message.text;
  //     //   setState(() {
  //     //     globals.msgRTM=message.text;
  //     //   });
  //   };
  //   globals.clientRTM.onConnectionStateChanged = (int state, int reason) {
  //     // _log('Connection state changed: ' +
  //     //     state.toString() +
  //     //     ', reason: ' +
  //     //     reason.toString());
  //     if (state == 5) {
  //       globals.clientRTM.logout();
  //       //_log('Logout.');
  //       setState(() {
  //         globals.isLogin = false;
  //       });
  //     }
  //   };
  // }

  String _loginUserType() {
    if (globals.loginUserType != null) {
      return globals.loginUserType;
    } else
      return '';
  }

  String _getUserData(type) {
    if (globals.user != null) {
      return globals.user[0][type];
    } else
      return '';
  }

  Future<bool> getPatientDetails(phoneNumber) async {
    return await http.post(
        Uri.encodeFull(
          // Changed by Abhi for BVH API
//            '${globals.apiHostingURL}/Patient/mapp_GetPatientRegDetails'),
        '${globals.apiHostingURLBVH}/MobileAppPatient/mapp_GetPatientRegDetails'),
        // End Changed by Abhi for BVH API
        body: {"MobileNumber": "$phoneNumber"},
        headers: {"Accept": "application/json"}).then((http.Response response) {
            print(response.body);
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        var extractdata = jsonDecode(response.body)['patientDetails'];
        List data = extractdata as List;
        globals.user = data;

        if (data != null) {
          globals.personCode = data[0]["PersonCode"];
          globals.personName =
              "${data[0]["Salutation"]} ${data[0]["FirstName"]}";
          globals.personGender = data[0]["GenderCode"];
          globals.tokenKey = data[0]["TokenKey"];
        }

        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> getDcotorDetails(phoneNumber) async {
    return await http.post(
        Uri.encodeFull(
            '${globals.apiHostingURL}/Doctors/mapp_GetDoctorDetails'),
        body: {"MobileNumber": "$phoneNumber"},
        headers: {"Accept": "application/json"}).then((http.Response response) {
      //      print(response.body);
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        var extractdata = jsonDecode(response.body)['DcotorDetails'];
        List data = extractdata as List;
        globals.user = data;

        if (data != null) {
          globals.personCode = data[0]["PersonCode"];

          globals.personName =
              "${data[0]["Salutation"]} ${data[0]["FirstName"]}";
        }

        return true;
      } else {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 1,
        title: new Text(
          'Please wait...',
          style: new TextStyle(
              //color: globals.w,
              fontWeight: FontWeight.bold,
              fontSize: 20.0),
        ),
        image:
            Image.asset("assets/images/Hospitalogo.png", fit: BoxFit.scaleDown),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("21CI"),
        loaderColor: Colors.red);
  }
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
        //...top circlular image part,
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: Consts.avatarRadius,
          ),
        ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
