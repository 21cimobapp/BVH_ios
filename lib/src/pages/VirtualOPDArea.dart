import 'dart:io';
import 'dart:async';
//import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:civideoconnectapp/data_models/PatientRegDetails.dart';
import 'package:civideoconnectapp/src/pages/SlidingCardsView.dart';
//import 'package:civideoconnectapp/src/pages/Tabs.dart';
import 'package:civideoconnectapp/src/pages/call.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:civideoconnectapp/utils/constants.dart';
import 'package:flutter/material.dart';
import '../utils/settings.dart';
import 'package:wakelock/wakelock.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';

//import 'package:carousel_slider/carousel_slider.dart';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle =
      const TextStyle(fontSize: 20.0, fontFamily: "OpenSans");
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class VirtualOPDArea extends StatefulWidget {
  /// non-modifiable channel name of the page
  //final int userID;
  final String appointmentNumber;

  /// Creates a call page with given channel name.
  const VirtualOPDArea({Key key, this.appointmentNumber}) : super(key: key);

  @override
  _VirtualOPDAreaState createState() => _VirtualOPDAreaState();
}

final assetsAudioPlayer = AssetsAudioPlayer();

class _VirtualOPDAreaState extends State<VirtualOPDArea>
    with TickerProviderStateMixin {
  AgoraRtmClient clientRTM;
  bool _isLogin = false;
  bool _isConsDone = false;
  int _current = 0;
  final Color _backgroundColor = Color(0xFFf0f0f0);
  Stream apptStream;
  DocumentSnapshot appt;
  final Dependencies dependencies = new Dependencies();

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  @override
  void dispose() {
    // clear users
    Wakelock.disable();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initMsgService();
    apptStream =
        DatabaseMethods().getAppointmentDetails(widget.appointmentNumber);

    dependencies.stopwatch.start();
    //
    _handleCameraAndMic();
    Wakelock.enable();
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  showAlertDialog(BuildContext context) {
    //assetsAudioPlayer.open(Audio("assets/DoctorCall.mp3"));
    //assetsAudioPlayer.play();
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        height: 150,
        child: new Column(
          children: [
            Container(
                margin: EdgeInsets.only(left: 5), child: Text("Doctor Call")),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //assetsAudioPlayer.stop();

                    _sendPeerMessage("CONSOK");

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallPage(appt: appt),
                        ));

                    // if (!_isRTCStarted) {
                    //   initializeRTC();
                    //   //_isRTCStarted = true;
                    // }
                  },
                  child: Text("Accept"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(15.0),
                ),
                SizedBox(width: 20),
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //assetsAudioPlayer.stop();
                    _sendPeerMessage("CONSCANCEL");
                  },
                  child: Text("Cancel"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(15.0),
                )
              ],
            )
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _createClient() async {
    clientRTM = await AgoraRtmClient.createInstance(APP_ID);
    clientRTM.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      if (message.text == "CALL") {
        showAlertDialog(context);
      }

      if (message.text == "CALLCANCEL") {
        Navigator.pop(context);
      }

      if (message.text == "CONSDONE") {
        setState(() {
          _isConsDone = true;
        });
        Navigator.pop(context);
      }
      if (message.text == "CONSPENDING") {
        setState(() {
          _isConsDone = false;
        });
      }
    };
    clientRTM.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        clientRTM.logout();
        //_log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
  }

  void _loginToChatService() async {
    String userId = globals.personCode;

    try {
      await clientRTM.login(null, userId);
      //_log('Connected : ' + userId);
      setState(() {
        _isLogin = true;
      });
    } catch (errorCode) {
      //_log('Connetion error: ' + errorCode.toString());
      setState(() {
        _isLogin = false;
      });
    }
  }

  void initMsgService() async {
    await _createClient();
    await _loginToChatService();
  }

  void _sendPeerMessage(msg) async {
    String peerUid = appt.data["doctorCode"];

    if (peerUid.isEmpty) {
      //_log('Please input peer user id to send message.');
      return;
    }

    String text = msg;
    if (text.isEmpty) {
      //_log('Please input text to send.');
      return;
    }

    try {
      AgoraRtmMessage message = AgoraRtmMessage.fromText(text);
      await clientRTM.sendMessageToPeer(peerUid, message, false);
      //_log('Send peer message success.');
    } catch (errorCode) {
      //_log('Send peer message error: ' + errorCode.toString());
    }
  }

  /// Video view row wrapper

  /// Video layout wrapper
  Widget _viewRows() {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 10, top: 10),
            //padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    height: 40, child: TimerText(dependencies: dependencies)),
                SizedBox(height: 8),
                Header(),
                SizedBox(height: 20),
                Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _buildTopContent()),
                SizedBox(height: 8),
                SlidingCardsView()
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    //final views = _getRenderViews();

    return Container(
      alignment: Alignment.bottomLeft,
      //padding: const EdgeInsets.symmetric(vertical: 48),
      //margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        height: 100,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 200,
                    child: RawMaterialButton(
                      onPressed: () => _onExit(context),
                      child: Text("Exit from waiting area"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      elevation: 2.0,
                      fillColor: Theme.of(context).accentColor,
                      padding: const EdgeInsets.all(15.0),
                    )),
                // Container(
                //     width: 80,
                //     child: RawMaterialButton(
                //       onPressed: () => {
                //         Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => CallPage(appt: appt),
                //             ))
                //       },
                //       child: Text("Exit"),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(25.0),
                //           side: BorderSide(color: Theme.of(context).primaryColor)),
                //       elevation: 2.0,
                //       fillColor: Theme.of(context).accentColor,
                //       padding: const EdgeInsets.all(15.0),
                //     )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onExit(BuildContext context) {
    Wakelock.disable();
    // _sendPeerMessage(
    //     "CALLEND|${globals.loginUserType == "PATIENT" ? widget.appt.DoctorCode : widget.appt.PatientCode}");
    _onWillPop().then((value) => () {
          if (value == true) {
            exitFromOPDArea();
          }
        });
  }

  exitFromOPDArea() async {
//    apptStream = await DatabaseMethods().getAppointmentDetails(widget.appointmentNumber); // Commented by Abhi since not required.

    String appointmentStatus = appt.data["appointmentStatus"];
    if (appointmentStatus == "WAITING") {  // Added by Anjali since status to be changed to pending only of the status is waiting.
      await DatabaseMethods().updateAppointmentDetails(
          widget.appointmentNumber, "appointmentStatus", "PENDING");
    }
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: new Text(
              "Exit from waiting area",
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
                  Navigator.of(context).pop();
                  exitFromOPDArea();
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: apptStream,
        // Firestore.instance
        //     .collection("Appointments")
        //     .document(widget.appointmentNumber)
        //     .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading");
          }
          appt = snapshot.data;

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: _backgroundColor,
              // floatingActionButton: UnicornDialer(
              //     //backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
              //     parentButtonBackground: Theme.of(context).accentColor,
              //     orientation: UnicornOrientation.VERTICAL,
              //     parentButton: Icon(Icons.more_vert),
              //     childButtons: childButtons),
              appBar: _buildAppBar(),

              //appBar:A ppBar(
              //   backgroundColor: Colors.transparent,
              //   elevation: 0.0,
              //   brightness: Brightness.light,
              //   iconTheme: IconThemeData(color: Colors.black87),
              //   automaticallyImplyLeading: false,
              //   title: Text(
              //     "Virtual OPD Waiting Area",
              //     style: TextStyle(
              //         //fontSize: 15.0,
              //         color: Colors.black,
              //         fontWeight: FontWeight.bold),
              //   ),
              // ),
              //backgroundColor: Colors.white,
              body:
                  //SlidingUpPanel(
                  // renderPanelSheet: false,
                  // padding: EdgeInsets.all(0.0),
                  // //maxHeight: 40,
                  // panel: _floatingPanel(),
                  // collapsed: _floatingCollapsed(),
                  //body:
                  Center(
                child: Stack(
                  children: <Widget>[
                    _viewRows(),

                    _toolbar(),

                    //_toolbarMsg()
                  ],
                ),
              ),
              //),
            ),
          );
        });
  }

  Padding _buildTopContent() {
    return Padding(
        padding: const EdgeInsets.only(left: 18, right: 0),
        child: Row(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[200]),
                height: 50,
                width: 50,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 120,
                  child: Text(
                    "${appt.data["doctorName"]}".toUpperCase(),
                    style: bodyTextStyle.copyWith(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "${appt.data["departmentName"]}".toUpperCase(),
                  style: bodyTextStyle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ));
  }

  Future<bool> _onBackPressed() {
    return 1 ?? false;
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back, color: appBarIconsColor),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
      actions: <Widget>[
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
        child: Text('Virtual OPD Waiting AREA'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.5,
              color: appBarIconsColor,
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'You are in virtual OPD waiting area. Please wait for the doctor to call you.',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(width: 24),
          MyTab(id: 1, text: 'About Doctor', isSelected: false),
          //MyTab(id: 2, text: 'Need Help?', isSelected: false),
        ],
      ),
    );
  }
}

class MyTab extends StatelessWidget {
  final int id;
  final String text;

  final bool isSelected;

  const MyTab(
      {Key key,
      @required this.id,
      @required this.isSelected,
      @required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => FunkyOverlay(id: id),
          );
        },
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  fontSize: isSelected ? 16 : 14,
                  color: isSelected ? Colors.red : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              Container(
                height: 6,
                width: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isSelected ? Color(0xFFFF5A1D) : Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FunkyOverlay extends StatefulWidget {
  final int id;

  const FunkyOverlay({
    Key key,
    @required this.id,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width - 100,
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.height / 2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: widget.id == 1 ? Text("About doctor") : Text("Help"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies});
  final Dependencies dependencies;

  TimerTextState createState() =>
      new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});
  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(
        new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
        callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RepaintBoundary(
          child: new SizedBox(
            height: 72.0,
            child: new MinutesAndSeconds(dependencies: dependencies),
          ),
        ),
        new RepaintBoundary(
          child: new SizedBox(
            height: 72.0,
            child: new Hundreds(dependencies: dependencies),
          ),
        ),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});
  final Dependencies dependencies;

  MinutesAndSecondsState createState() =>
      new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return new Text('$minutesStr:$secondsStr.', style: dependencies.textStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.dependencies});
  final Dependencies dependencies;

  HundredsState createState() => new HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({this.dependencies});
  final Dependencies dependencies;

  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return new Text(hundredsStr, style: dependencies.textStyle);
  }
}
