import 'dart:async';
import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../utils/settings.dart';
import 'package:wakelock/wakelock.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
//import 'package:sliding_up_panel/sliding_up_panel.dart';
//import 'package:civideoconnectapp/src/pages/popup.dart';
//import 'package:civideoconnectapp/src/pages/popup_content.dart';
//import 'package:civideoconnectapp/src/pages/InfoPopup.dart';

class CallPageDoctor extends StatefulWidget {
  /// non-modifiable channel name of the page
  //final int userID;
  final AppointmentDetails appt;

  /// Creates a call page with given channel name.
  const CallPageDoctor({Key key, this.appt}) : super(key: key);

  @override
  _CallPageDoctorState createState() => _CallPageDoctorState();
}

class _CallPageDoctorState extends State<CallPageDoctor>
    with TickerProviderStateMixin {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool mutedVideo = false;
  AnimationController controller;
  static final orgColor = Colors.green;
  var currentColor = orgColor;
  var timeOutMessage = "";
  Timer timer;
  String appTitle = "Consultation Room";
  final themeColor = Color(0xfff5a623);
  final primaryColor = Color(0xff203152);
  final greyColor = Color(0xffaeaeae);
  final greyColor2 = Color(0xffE8E8E8);

  //final _peerMessageController = TextEditingController();
  final _channelMessageController = TextEditingController();

  final _chatInfoStrings = <String>[];

  bool _isLogin = false;
  bool _showChat = false;
  bool _isOtherUserOnline = false;
  bool _isInChannel = false;

  //static TextStyle textStyle = TextStyle(fontSize: 18, color: Theme.of(context).primaryColor);

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "scaffold-Video-call");

  @override
  void dispose() {
    // clear users
    //Wakelock.disable();
    _users.clear();
    // destroy sdk

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initializeRTC();

    Wakelock.enable();
  }

  void _log(String info) {
    print(info);
    setState(() {
      _chatInfoStrings.insert(0, info);
    });
  }

  Future<void> initializeRTC() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing',
        );
        _infoStrings.add('Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');

    await AgoraRtcEngine.joinChannel(
        null, widget.appt.ResourceAllocNumber, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
      Navigator.pop(context);
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(top: 80),
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  "Waiting for Patient to connect",
                  style: TextStyle(
                      fontSize: 15.0,
                      //color: globals.appTextColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );

      case 2:
        //timeOutMessage = "In Call";
        return Container(
            child: Column(
          children: <Widget>[
            //_expandedVideoRow([views[0]]),
            //_expandedVideoRow([views[1]])

            _videoView(views[1]),
          ],
        ));
      default:
        //timeOutMessage = "In Call";
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[1]]),
            _expandedVideoRow([views[2]])
          ],
        ));
    }
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomLeft,
      //padding: const EdgeInsets.symmetric(vertical: 48),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 60,
            child: RawMaterialButton(
              onPressed: _onToggleMute,
              child: Icon(
                muted ? Icons.mic_off : Icons.mic,
                color: muted ? Colors.white : Theme.of(context).accentColor,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: muted ? Theme.of(context).accentColor : Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
          ),
          Container(
            width: 60,
            child: RawMaterialButton(
              onPressed: _onToggleMuteVideo,
              child: Icon(
                mutedVideo ? Icons.videocam_off : Icons.videocam,
                color:
                    mutedVideo ? Colors.white : Theme.of(context).accentColor,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor:
                  mutedVideo ? Theme.of(context).accentColor : Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
          ),
          // SizedBox(
          //   width: 20,
          // ),

          // SizedBox(
          //   width: 20,
          // ),
          Container(
              width: 80,
              child: RawMaterialButton(
                onPressed: () => _onCallEnd(context),
                child: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 30.0,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.red)),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              )),
          Container(
            width: 60,
            child: RawMaterialButton(
              onPressed: _onSwitchCamera,
              child: Icon(
                Icons.switch_camera,
                color: Theme.of(context).accentColor,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
          ),
          Container(
            width: 60,
            child: RawMaterialButton(
              onPressed: () {
                setState(() {
                  _showChat == true ? _showChat = false : _showChat = true;
                });
              },
              child: Icon(
                _showChat ? Icons.chat_bubble : Icons.chat,
                color: _showChat ? Colors.white : Theme.of(context).accentColor,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor:
                  _showChat ? Theme.of(context).accentColor : Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
          ),

          // Container(
          //   width: 60,
          //   child: RawMaterialButton(
          //     onPressed: () {
          //       //showPopup(context, InfoPopup(appt:widget.appt), 'Chat');
          //       setState(() {

          //         _showChat==true?_showChat=false:_showChat=true;
          //       });
          //     },
          //     child: Icon(
          //       Icons.chat,
          //       color: Colors.blueAccent,
          //       size: 20.0,
          //     ),
          //     shape: CircleBorder(),
          //     elevation: 2.0,
          //     fillColor: Colors.white,
          //     padding: const EdgeInsets.all(12.0),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _toolbarMsg() {
    final views = _getRenderViews();
    if (views.length == 1) {
      return Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 50),
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Text(
                (_loginUserType() == "PATIENT")
                    ? "Waiting for Doctor to connect"
                    : "Waiting for Patient to connect",
                style: TextStyle(
                    fontSize: 15.0,
                    //color: globals.appTextColor,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    } else
      return Center();
  }

  String _loginUserType() {
    if (globals.loginUserType != null) {
      return globals.loginUserType;
    } else
      return '';
  }

  Widget getCountdown() {
    final views = _getRenderViews();
    if (views.length > 1) {
      controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: widget.appt.SlotDuration * 60), //90
      );

      timer = Timer.periodic(
          Duration(seconds: (widget.appt.SlotDuration * 60) - 60),
          (Timer t) => setState(() {
                currentColor = Colors.red;
                timeOutMessage = "Call will end soon...";
              }));

      controller.addStatusListener(((status) {
        if (status == AnimationStatus.completed) {
          print("completed");
          _callTimeUp(context);
        } else if (status == AnimationStatus.dismissed) {
          //controller.forward();
        }
      }));

      controller.forward();
      return SizedBox(
          width: 50,
          child: CircularCountDownTimer(
            duration: (widget.appt.SlotDuration * 60), //90,
            width: 50,
            height: 50,
            color: Colors.white,
            fillColor: currentColor,
            strokeWidth: 5.0,
            textStyle: TextStyle(
                fontSize: 10.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            isReverse: true,
            onComplete: () {
              print('Countdown Ended');
              //_onCallEnd(context);
            },
          ));
    } else {
      return SizedBox(width: 0, child: Text(""));
    }
  }

  /// Toolbar layout
  Widget _toolbarTop() {
    return Container(
      alignment: Alignment.topLeft,
      //color: Colors.white70,
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Column(
                children: <Widget>[
                  getCountdown(),
                  (widget.appt.PatientGender != null)
                      //(widget.appt.PatientAge != null)
                      ? Container(
                          //alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            //color: Theme.of(context).primaryColor,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                (widget.appt.PatientAge != null)
                                    ? "Age : " + widget.appt.PatientAge
                                    : "",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (widget.appt.PatientGender != null)
                                    ? "Gender : " + widget.appt.PatientGender
                                    : "",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : Center(),
                  //showWarningMessage()
                  SizedBox(
                    height: 10,
                  ),
                  (timeOutMessage == "")
                      ? Text("")
                      : Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            timeOutMessage,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                ],
              )),
          _selfView(),
        ],
      ),
    );
  }

  Widget showWarningMessage() {
    if (timeOutMessage == "") {
      Text("In Call");
    } else {
      return Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Text(
          timeOutMessage,
          style: TextStyle(
              fontSize: 15.0, color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  Widget _selfView() {
    final views = _getRenderViews();
    //switch (views.length) {
    // case 1:
    //   return Center();
    // case 2:
    if (mutedVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          color: Colors.black,
          height: 120.0,
          width: 120.0,
          child: Center(
            child: Icon(
              Icons.videocam_off,
              color: Theme.of(context).accentColor,
              size: 100.0,
            ),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          color: Colors.black,
          height: 120.0,
          width: 120.0,
          child: Center(
            child: _videoView(views[0]),
          ),
        ),
      );
    }
    //}
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _chatPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 80),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: ListView.builder(
          reverse: true,
          itemCount: _chatInfoStrings.length,
          itemBuilder: (BuildContext context, int index) {
            if (_infoStrings.isEmpty) {
              return null;
            }
            if (_chatInfoStrings[index].contains("Channel msg:")) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _chatInfoStrings[index]
                              .replaceFirst("Channel msg:", ""),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      //alignment: Alignment.topRight,
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _chatInfoStrings[index],
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _sendChannelMessage() async {
    // String text = _channelMessageController.text;
    // if (text.isEmpty) {
    //   //_log('Please input text to send.');
    //   return;
    // }
    // try {
    //   await _channel.sendMessage(AgoraRtmMessage.fromText(text));
    //   _log(text);
    //   _channelMessageController.clear();
    //   //_log('Send channel message success.');
    // } catch (errorCode) {
    //   _log('error: ' + errorCode.toString());
    //   _channelMessageController.clear();
    // }
  }

  Widget _buildSendChannelMessage() {
    //if (!_isLogin || !_isInChannel) {
    //  return Container();
    //}
    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 100),
      child: Row(children: <Widget>[
        SizedBox(
          width: 10,
        ),
        new Expanded(
            child: new TextField(
                controller: _channelMessageController,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide()),
                  hintText: 'Type a Message',
                ))),
        Container(
          color: Theme.of(context).accentColor,
          child: new IconButton(
            icon: Icon(
              Icons.send,
              color: globals.appTextColor,
            ),
            onPressed: _sendChannelMessage,
            //shape: CircleBorder()
          ),
        )
      ]),
    );
  }

  void _callTimeUp(BuildContext context) {
    //_onCallEnd(context);
  }

  void _onCallEnd(BuildContext context) {
    _users.clear();
    // destroy sdk

    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();

    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onToggleMuteVideo() {
    setState(() {
      mutedVideo = !mutedVideo;
    });
    AgoraRtcEngine.muteLocalVideoStream(mutedVideo);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          title: Text(appTitle),
        ),
        backgroundColor: Colors.white,
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
              _showChat == true ? _chatPanel() : Center(),
              _showChat == true ? _buildSendChannelMessage() : Center(),
              _toolbarTop(),

              _toolbar(),

              //_toolbarMsg()
            ],
          ),
        ),
        //),
      ),
    );
  }

  // Widget _floatingCollapsed() {
  //   return Container(
  //     //height: 200,
  //     padding: EdgeInsets.all(0.0),
  //     decoration: BoxDecoration(
  //       color: Colors.blueGrey,
  //       borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
  //     ),
  //     margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
  //     child: Center(
  //       child: Text(
  //         "More Info",
  //         style: TextStyle(fontSize: 20, color: Colors.white),
  //       ),
  //     ),
  //   );
  // }

  // Widget _floatingPanel() {
  //   return Container(
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.all(Radius.circular(24.0)),
  //         boxShadow: [
  //           BoxShadow(
  //             blurRadius: 20.0,
  //             color: Colors.grey,
  //           ),
  //         ]),
  //     margin: const EdgeInsets.all(10.0),
  //     child: Center(
  //         //   child: TabBar(
  //         //   tabs: [
  //         //     Tab(icon: Icon(Icons.chat)),
  //         //     Tab(icon: Icon(Icons.info)),
  //         //     Tab(icon: Icon(Icons.file_upload)),
  //         //   ],
  //         // ),
  //         ),
  //   );
  // }

  Future<bool> _onBackPressed() {
    return 1 ?? false;
  }

// showPopup(BuildContext context, Widget widget, String title,
//       {BuildContext popupContext}) {
//     Navigator.push(
//       context,
//       PopupLayout(
//         top: 100,
//         left: 30,
//         right: 30,
//         bottom: 0,

//         child: PopupContent(
//           content: Scaffold(
//           // appBar: AppBar(
//           //   title: Text(title),
//           //   leading: new Builder(builder: (context) {
//           //     return IconButton(
//           //       icon: Icon(Icons.arrow_back),
//           //       onPressed: () {
//           //         try {
//           //           Navigator.pop(context); //close the popup
//           //         } catch (e) {}
//           //       },
//           //     );
//           //   }),
//           //   brightness: Brightness.light,
//           // ),

//             resizeToAvoidBottomPadding: false,
//             body: widget,
//           ),
//         ),
//       ),
//     );
  //}

}
