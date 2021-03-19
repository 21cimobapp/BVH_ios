import 'dart:async';
import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:civideoconnectapp/src/pages/SlidingCardsView.dart';
//import 'package:civideoconnectapp/src/pages/Tabs.dart';
import 'package:civideoconnectapp/src/pages/call.dart';
//import 'package:civideoconnectapp/utils/constants.dart';
import 'package:flutter/material.dart';
import '../utils/settings.dart';
import 'package:wakelock/wakelock.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

//import 'package:carousel_slider/carousel_slider.dart';

class VirtualOPDArea extends StatefulWidget {
  /// non-modifiable channel name of the page
  //final int userID;
  final AppointmentDetails appt;

  /// Creates a call page with given channel name.
  const VirtualOPDArea({Key key, this.appt}) : super(key: key);

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

  //AgoraRtmChannel _channel;

  //static TextStyle textStyle = TextStyle(fontSize: 18, color: Theme.of(context).primaryColor);

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "scaffold-Video-call");

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

    //
    Wakelock.enable();
  }

  showAlertDialog(BuildContext context) {
    assetsAudioPlayer.open(Audio("assets/DoctorCall.mp3"));
    assetsAudioPlayer.play();
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
            RawMaterialButton(
              onPressed: () {
                Navigator.pop(context);
                assetsAudioPlayer.stop();
                _sendPeerMessage("CONSOK");
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => CallPage(appt: widget.appt),
                //     ));

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
    String peerUid = widget.appt.DoctorCode;

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
          // Center(
          //   child: new Image.asset(
          //     'assets/WaitingRoom.jpg',
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 10, top: 10),
            //padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Container(
                //   width: MediaQuery.of(context).size.width - 20,
                //   //height: 80,
                //   alignment: Alignment.center,
                //   padding: const EdgeInsets.all(10.0),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     border: Border.all(color: Theme.of(context).primaryColor),
                //     borderRadius: BorderRadius.circular(10),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.5),
                //         spreadRadius: 5,
                //         blurRadius: 7,
                //         offset: Offset(0, 3), // changes position of shadow
                //       ),
                //     ],
                //   ),

                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: <Widget>[
                //       Container(
                //         alignment: Alignment.centerLeft,
                //         child: Text(
                //           "Virtual OPD Waiting Area",
                //           style: TextStyle(
                //               fontSize: 30.0,
                //               //color: globals.appTextColor,
                //               fontWeight: FontWeight.bold),
                //         ),
                //       ),
                //       Divider(
                //         height: 10.0,
                //         indent: 5.0,
                //         color: Colors.black87,
                //       ),
                //       Container(
                //         alignment: Alignment.centerLeft,
                //         child: Text(
                //           "You are in Virtual OPD Waiting Area.",
                //           style: TextStyle(
                //             fontSize: 15.0,
                //             //color: globals.appTextColor,
                //             //fontWeight: FontWeight.bold
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   //width: 250,
                //   alignment: Alignment.topLeft,
                //   // padding: const EdgeInsets.only(
                //   //     top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: <Widget>[
                //       Container(
                //         width: 200,
                //         child: Card(
                //             margin: const EdgeInsets.only(left: 10, top: 10),
                //             //margin: EdgeInsets.symmetric(vertical: 10),
                //             //elevation: 10.0,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(15.0),
                //             ),
                //             child: Column(children: <Widget>[
                //               Padding(
                //                 padding: const EdgeInsets.only(
                //                     top: 10.0,
                //                     bottom: 10.0,
                //                     left: 10.0,
                //                     right: 10.0),
                //                 child: Row(children: <Widget>[
                //                   Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: <Widget>[
                //                       Container(
                //                         width: 150,
                //                         child: Text("About Your Doctor",
                //                             style: Theme.of(context)
                //                                 .textTheme
                //                                 .subtitle,
                //                             overflow: TextOverflow.fade),
                //                       ),
                //                     ],
                //                   ),
                //                 ]),
                //               ),
                //             ])),
                //       ),
                //       Container(
                //         width: 200,
                //         child: Card(
                //             margin: const EdgeInsets.only(left: 10, top: 10),
                //             //margin: EdgeInsets.symmetric(vertical: 10),
                //             //elevation: 10.0,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(15.0),
                //             ),
                //             child: Column(children: <Widget>[
                //               Padding(
                //                 padding: const EdgeInsets.only(
                //                     top: 10.0,
                //                     bottom: 10.0,
                //                     left: 10.0,
                //                     right: 10.0),
                //                 child: Row(children: <Widget>[
                //                   Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: <Widget>[
                //                       Container(
                //                         width: 150,
                //                         child: Text("Need Help?",
                //                             style: Theme.of(context)
                //                                 .textTheme
                //                                 .subtitle,
                //                             overflow: TextOverflow.fade),
                //                       ),
                //                     ],
                //                   ),
                //                 ]),
                //               ),
                //             ])),
                //       ),
                //       _isConsDone
                //           ? Container(
                //               width: 200,
                //               child: Card(
                //                   margin:
                //                       const EdgeInsets.only(left: 10, top: 10),
                //                   //margin: EdgeInsets.symmetric(vertical: 10),
                //                   //elevation: 10.0,
                //                   shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(15.0),
                //                   ),
                //                   child: Column(children: <Widget>[
                //                     Padding(
                //                       padding: const EdgeInsets.only(
                //                           top: 10.0,
                //                           bottom: 10.0,
                //                           left: 10.0,
                //                           right: 10.0),
                //                       child: Row(children: <Widget>[
                //                         Column(
                //                           crossAxisAlignment:
                //                               CrossAxisAlignment.start,
                //                           children: <Widget>[
                //                             Container(
                //                               width: 150,
                //                               child: Text(
                //                                   "Comsultation Completed. You will get notification once your Prescription is ready",
                //                                   style: Theme.of(context)
                //                                       .textTheme
                //                                       .subtitle,
                //                                   overflow: TextOverflow.fade),
                //                             ),
                //                           ],
                //                         ),
                //                       ]),
                //                     ),
                //                   ])),
                //             )
                //           : Container()
                //     ],
                //   ),
                // ),
                SizedBox(height: 8),
                Header(),
                SizedBox(height: 20),
                Tabs(),
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
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 80,
              child: RawMaterialButton(
                onPressed: () => _onExit(context),
                child: Text("Exit"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Theme.of(context).primaryColor)),
                elevation: 2.0,
                fillColor: Theme.of(context).accentColor,
                padding: const EdgeInsets.all(15.0),
              )),
        ],
      ),
    );
  }

  void _onExit(BuildContext context) {
    Wakelock.disable();
    // _sendPeerMessage(
    //     "CALLEND|${globals.loginUserType == "PATIENT" ? widget.appt.DoctorCode : widget.appt.PatientCode}");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        // floatingActionButton: UnicornDialer(
        //     //backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
        //     parentButtonBackground: Theme.of(context).accentColor,
        //     orientation: UnicornOrientation.VERTICAL,
        //     parentButton: Icon(Icons.more_vert),
        //     childButtons: childButtons),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black87),
          automaticallyImplyLeading: false,
          title: Text(
            "Virtual OPD Waiting Area",
            style: TextStyle(
                //fontSize: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
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
  }

  Future<bool> _onBackPressed() {
    return 1 ?? false;
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'You are in Virtual OPD Waiting Area.',
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
          MyTab(id: 2, text: 'Need Help?', isSelected: false),
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
