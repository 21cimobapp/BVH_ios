import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter/material.dart';
import '../utils/settings.dart';
import 'package:wakelock/wakelock.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:sliding_up_panel/sliding_up_panel.dart';
//import 'package:civideoconnectapp/src/pages/popup.dart';
//import 'package:civideoconnectapp/src/pages/popup_content.dart';
//import 'package:civideoconnectapp/src/pages/InfoPopup.dart';

class CallPageDoctor extends StatefulWidget {
  /// non-modifiable channel name of the page
  //final int userID;
  final DocumentSnapshot appt;

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
  String appTitle = "Video Call";
  final themeColor = Color(0xfff5a623);
  final primaryColor = Color(0xff203152);
  final greyColor = Color(0xffaeaeae);
  final greyColor2 = Color(0xffE8E8E8);

  bool _showChat = false;

  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  String chatRoomId;

  final Color _backgroundColor = Color(0xFFf0f0f0);

  final TextStyle titleTextStyle = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 11,
    height: 1,
    letterSpacing: .2,
    fontWeight: FontWeight.w600,
    color: Color(0xffafafaf),
  );
  final TextStyle contentTextStyle = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 16,
    height: 1.8,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

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
    initChat();
    Wakelock.enable();
  }

  initChat() async {
    List<String> users;
    List<String> userNames;

    if (globals.loginUserType == "PATIENT") {
      users = [globals.personCode, widget.appt.data["doctorCode"]];
      userNames = [globals.personName, widget.appt.data["NameCode"]];
    } else {
      users = [widget.appt.data["patientCode"], globals.personCode];
      userNames = [widget.appt.data["patientName"], globals.personName];
    }

    if (globals.loginUserType == "PATIENT") {
      chatRoomId = "${globals.personCode}_${widget.appt.data["patientCode"]}";
    } else {
      chatRoomId = "${widget.appt.data["patientCode"]}_${globals.personCode}";
    }

    Map<String, dynamic> chatRoom = {
      "users": users,
      "userNames": userNames,
      "chatRoomId": chatRoomId,
    };

    await DatabaseMethods().addChatRoom(chatRoom, chatRoomId);

    DatabaseMethods().getChats(chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
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
        null, widget.appt.data["appointmentNumber"], null, 0);
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
      // controller = AnimationController(
      //   vsync: this,
      //   duration: Duration(
      //       seconds: (widget.appt.data["slotDuration"] != null)
      //           ? widget.appt.data["slotDuration"] ?? 15 * 60
      //           : 15 * 60), //90
      // );

      // timer = Timer.periodic(
      //     Duration(
      //         seconds: (widget.appt.data["slotDuration"] != null)
      //             ? (widget.appt.data["slotDuration"] ?? 15 * 60)
      //             : 15 * 60),
      //     (Timer t) => setState(() {
      //           currentColor = Colors.red;
      //           timeOutMessage = "Call will end soon...";
      //         }));

      // controller.addStatusListener(((status) {
      //   if (status == AnimationStatus.completed) {
      //     print("completed");
      //     _callTimeUp(context);
      //   } else if (status == AnimationStatus.dismissed) {
      //     //controller.forward();
      //   }
      // }));

      //controller.forward();
      return SizedBox(
          width: 50,
          child: CircularCountDownTimer(
            duration: (widget.appt.data["slotDuration"] != null)
                ? widget.appt.data["slotDuration"] * 60
                : 15 * 60, //90,
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
                  Text(
                    "${widget.appt.data["patientName"]}",
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  (widget.appt.data["patientGender"] != null)
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
                                (widget.appt.data["patientAge"] != null)
                                    ? "Age : " + widget.appt.data["patientAge"]
                                    : "",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (widget.appt.data["patientGender"] != null)
                                    ? "Gender : " +
                                        widget.appt.data["patientGender"]
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
                  // (timeOutMessage == "")
                  //     ? Text("")
                  //     : Container(
                  //         padding: const EdgeInsets.all(10.0),
                  //         decoration: BoxDecoration(
                  //           color: Theme.of(context).primaryColor,
                  //           border: Border.all(color: Colors.red),
                  //           borderRadius: BorderRadius.circular(10),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.grey.withOpacity(0.5),
                  //               spreadRadius: 5,
                  //               blurRadius: 7,
                  //               offset:
                  //                   Offset(0, 3), // changes position of shadow
                  //             ),
                  //           ],
                  //         ),
                  //         child: Text(
                  //           timeOutMessage,
                  //           style: TextStyle(
                  //               fontSize: 15.0,
                  //               color: Colors.red,
                  //               fontWeight: FontWeight.bold),
                  //         ),
                  //       )
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

  _chatPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 20),

      //color: Colors.grey,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: <Widget>[
                Expanded(child: chatMessages()),
                Container(
                    margin: EdgeInsets.all(15.0),
                    height: 61,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35.0),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 5,
                                    color: Colors.grey)
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                // IconButton(
                                //     icon: Icon(Icons.face), onPressed: () {}),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: messageEditingController,
                                    decoration: InputDecoration(
                                        hintText: "Type a Message",
                                        border: InputBorder.none),
                                  ),
                                ),
                                // IconButton(
                                //   icon: Icon(Icons.photo_camera),
                                //   onPressed: () {},
                                // ),
                                // IconButton(
                                //   icon: Icon(Icons.attach_file),
                                //   onPressed: () {},
                                // )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                shape: BoxShape.circle),
                            child: Icon(
                              //Icons.keyboard_voice,
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            addMessage();
                          },
                        )
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
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
        child: Text('Consultation Room'.toUpperCase(),
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

  @override
  Widget build(BuildContext context) {
    appTitle = "Video Call with ${widget.appt.data["patientName"]}";

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: _buildAppBar(),
        // appBar: AppBar(
        //   //backgroundColor: Theme.of(context).primaryColor,
        //   automaticallyImplyLeading: false,
        //   title: Text(appTitle),
        // ),
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

  Future<bool> _onBackPressed() {
    return 1 ?? false;
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    time: snapshot.data.documents[index].data["time"],
                    sendByMe: globals.personCode ==
                        snapshot.data.documents[index].data["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": globals.personCode,
        "message": messageEditingController.text,
        'time': DateTime.now(),
      };

      DatabaseMethods().addMessage(chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final Timestamp time;
  final bool sendByMe;

  MessageTile(
      {@required this.message, @required this.time, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: sendByMe ? 0 : 24,
              right: sendByMe ? 24 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: sendByMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: sendByMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomLeft: Radius.circular(23))
                    : BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23)),
                gradient: LinearGradient(
                  colors: sendByMe
                      ? [
                          Theme.of(context).primaryColor,
                          Theme.of(context).accentColor
                        ]
                      : [Colors.grey[400], Colors.grey[300]],
                )),
            child: Text(message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: sendByMe ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
          ),
        ),
        Container(
            alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
            padding: EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: sendByMe ? 0 : 24,
                right: sendByMe ? 24 : 0),
            margin: sendByMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            child: Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(readTimestamp(time),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            )),
      ],
    );
  }

  String readTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();

    var time = '';

    time = timeAgo(date);

    return time;
  }

  String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "just now";
  }
}
