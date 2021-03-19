import 'package:flutter/material.dart';
import '../utils/settings.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
//import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
//import 'package:agora_rtm/agora_rtm.dart';
import 'package:intl/intl.dart';
//import 'package:speech_recognition/speech_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
//import 'package:civideoconnectapp/data_models/chatdata.dart';
//import 'package:civideoconnectapp/src/utils/ChatDatabaseUtil.dart';
import 'package:civideoconnectapp/data_models/ConversationChat.dart';

import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

enum MessageDirection { sent, received, init }
enum MessageType { text, image, audio, document }

class ChatPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  //final int userID;
//  final AppointmentDetails appt;

  final String peerCode;
  final String peerName;

  /// Creates a call page with given channel name.
  const ChatPage({
    Key key,
    this.peerCode,
    this.peerName,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

DatabaseReference chatReferenceS;
DatabaseReference chatReferenceR;
DatabaseReference chatReferenceUpdS;
DatabaseReference chatReferenceUpdR;

class _ChatPageState extends State<ChatPage> {
  //AgoraRtmChannel _channel;
  //List<ChatData> chat = new List();
  //ChatDatabaseUtil chatDatabase;
  final themeColor = Color(0xfff5a623);
  final primaryColor = Color(0xff203152);
  final greyColor = Color(0xffaeaeae);
  final greyColor2 = Color(0xffE8E8E8);
  //final _peerMessageController = TextEditingController();
  final _channelMessageController = TextEditingController();
  //final _infoStrings = <String>[];
  // List<Map<String, dynamic>> messages = [
  //   {
  //     'status': MessageDirection.init,
  //     'message': "",
  //     'time': DateFormat("hh:mm aaa").format(DateTime.now())
  //   }
  // ];
  String chatID;
  bool _isLogin = false;
  bool _isOtherUserOnline = false;
  ScrollController _scrollController = new ScrollController();

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

  //SpeechRecognition _speech;
  // bool _speechRecognitionAvailable = false;
  // bool _isListening = false;

  List<ConversationChat> conversations;
  StreamSubscription<Event> _onNoteAddedSubscription;
  StreamSubscription<Event> _onNoteChangedSubscription;

  String transcription = '';
  var itemRef;
  @override
  void dispose() {
    try {
      super.dispose();
      //_channel.close();
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    //chatDatabase = ChatDatabaseUtil();
    //chatDatabase.initState();

    initChatService();
    //loadChat();
    //activateSpeechRecognizer();

    conversations = new List();

    _onNoteAddedSubscription = chatReferenceS.onChildAdded.listen(_onNoteAdded);

    _onNoteChangedSubscription =
        chatReferenceS.onChildChanged.listen(_onNoteUpdated);
  }

  void _onNoteAdded(Event event) {
    setState(() {
      conversations.insert(
          0, new ConversationChat.fromSnapshot(event.snapshot));
    });
  }

  void _onNoteUpdated(Event event) {
    var oldNoteValue =
        conversations.singleWhere((note) => note.id == event.snapshot.key);
    setState(() {
      conversations[conversations.indexOf(oldNoteValue)] =
          new ConversationChat.fromSnapshot(event.snapshot);
    });
  }

  void _deleteNote(
      BuildContext context, ConversationChat note, int position) async {
    await chatReferenceS
        .child(globals.personCode)
        .child(chatID)
        .child(note.id)
        .remove()
        .then((_) {
      setState(() {
        conversations.removeAt(position);
      });
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateTime.parse(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  // loadChat() async {
  //   chat.clear();
  //   itemRef = await chatDatabase.getChat(globals.personCode, chatID);
  //   itemRef.once().then((DataSnapshot snapshot) {
  //     Map<dynamic, dynamic> values = snapshot.value;
  //     values.forEach((key, values) {
  //       setState(() {
  //         chat.insert(
  //             0,
  //             new ChatData(
  //               key,
  //               values["chatID"],
  //               values["idFrom"],
  //               values["idTo"],
  //               values["direction"],
  //               values["message"],
  //               values["type"],
  //               convertToDate(values["timeStamp"]),
  //             ));
  //       });
  //     });
  //   });
  // }

  // void requestPermission() async {
  //   PermissionStatus permission = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.microphone);

  //   if (permission != PermissionStatus.granted) {
  //     await PermissionHandler()
  //         .requestPermissions([PermissionGroup.microphone]);
  //   }
  // }

  // void activateSpeechRecognizer() {
  //   requestPermission();

  //   _speech = new SpeechRecognition();
  //   _speech.setAvailabilityHandler(onSpeechAvailability);
  //   _speech.setCurrentLocaleHandler(onCurrentLocale);
  //   _speech.setRecognitionStartedHandler(onRecognitionStarted);
  //   _speech.setRecognitionResultHandler(onRecognitionResult);
  //   _speech.setRecognitionCompleteHandler(onRecognitionComplete);
  //   _speech
  //       .activate()
  //       .then((res) => setState(() => _speechRecognitionAvailable = res));
  // }

  // void start() => _speech
  //     .listen(locale: 'en_US')
  //     .then((result) => print('Started listening => result $result'));

  // void cancel() =>
  //     _speech.cancel().then((result) => setState(() => _isListening = result));

  // void stop() => _speech.stop().then((result) {
  //       setState(() => _isListening = result);
  //     });

  // void onSpeechAvailability(bool result) =>
  //     setState(() => _speechRecognitionAvailable = result);

  // void onCurrentLocale(String locale) =>
  //     setState(() => print("current locale: $locale"));

  // void onRecognitionStarted() => setState(() => _isListening = true);

  // void onRecognitionResult(String text) {
  //   setState(() {
  //     transcription = text;
  //     stop();
  //     //_toggleSendChannelMessage();
  //   });
  // }

  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      //_log('Please input text to send.');
      return;
    }
    //try {
    //await _channel.sendMessage(AgoraRtmMessage.fromText(text));
    //_log('Send channel message success.');

    saveToDatabase(text, "T", DateTime.now());

    _channelMessageController.clear();
    //} catch (errorCode) {
    //  print(errorCode.toString());
    //_log('Send channel message error: ' + errorCode.toString());
    //  }
  }

  saveToDatabase(text, messageType, timeStamp) async {
    chatReferenceS.push().set({
      'chatId': "" + chatID,
      'idFrom': "" + globals.personCode,
      'idTo': "" + widget.peerCode,
      'direction': "S",
      'message': "" + text,
      'type': "" + messageType,
      'timeStamp': "" + timeStamp.toString(),
      'readflag': "0",
      'readTimeStamp': ""
    }).then((_) {
      print('Updated');
    });

    chatReferenceR.push().set({
      'chatId': "" + chatID,
      'idFrom': "" + globals.personCode,
      'idTo': "" + widget.peerCode,
      'direction': "R",
      'message': "" + text,
      'type': "" + messageType,
      'timeStamp': "" + timeStamp.toString(),
      'readflag': "0",
      'readTimeStamp': ""
    }).then((_) {
      print('Updated');
    });

    chatReferenceUpdS.update({
      'chatId': "" + chatID,
      'idFrom': "" + globals.personCode,
      'idTo': "" + widget.peerCode,
      'direction': "S",
      'message': "" + text,
      'type': "" + messageType,
      'timeStamp': "" + timeStamp.toString(),
      "fullName": "" + "" + widget.peerName,
      "image": "" + "",
    }).then((_) {
      print('Transaction  committed.');
    });

    chatReferenceUpdR.update({
      'chatId': "" + chatID,
      'idFrom': "" + globals.personCode,
      'idTo': "" + widget.peerCode,
      'direction': "R",
      'message': "" + text,
      'type': "" + messageType,
      'timeStamp': "" + timeStamp,
      "fullName": "" + "" + globals.personName,
      "image": "" + "",
    }).then((_) {
      print('Transaction  committed.');
    });

    // var chatMsg = ChatData(
    //   chatID,
    //   chatID,
    //   globals.personCode,
    //   widget.peerCode,
    //   messageDirection,
    //   text,
    //   messageType,
    //   timeStamp,
    // );
    // setState(() {
    //   chat.insert(0, chatMsg);
    // });

    // _scrollController.animateTo(
    //   0.0,
    //   curve: Curves.easeOut,
    //   duration: const Duration(milliseconds: 300),
    // );

    // await chatDatabase.addChat(chatMsg);
    // await chatDatabase.updateChatHistory(chatMsg, widget.peerName);
  }

  // void onRecognitionComplete() => setState(() {
  //       _channelMessageController.text = transcription;
  //       //transcription = "";

  //       _isListening = false;
  //     });

  void initChatService() async {
    //await _createClient();
    //await _loginToChatService();

    if (globals.loginUserType == "PATIENT") {
      chatID = "${globals.personCode}_${widget.peerCode}";
    } else {
      chatID = "${widget.peerCode}_${globals.personCode}";
    }

    chatReferenceS = FirebaseDatabase.instance
        .reference()
        .child("21ci")
        .child("Chats")
        .child(globals.personCode)
        .child(chatID);

    chatReferenceUpdS = FirebaseDatabase.instance
        .reference()
        .child("21ci")
        .child("ChatsHistory")
        .child(globals.personCode)
        .child(widget.peerCode);

    chatReferenceUpdR = FirebaseDatabase.instance
        .reference()
        .child("21ci")
        .child("ChatsHistory")
        .child(widget.peerCode)
        .child(globals.personCode);
    chatReferenceR = FirebaseDatabase.instance
        .reference()
        .child("21ci")
        .child("Chats")
        .child(widget.peerCode)
        .child(chatID);
    // _channel = await _createChannel(chatID);
    // try {
    //   await _channel.join();
    // } catch (e) {}
  }

  // void _createClient() async {
  //   globals.clientRTM = await AgoraRtmClient.createInstance(APP_ID);
  //   globals.clientRTM.onMessageReceived =
  //       (AgoraRtmMessage message, String peerId) {
  //     _log("Peer msg:" + message.text);
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
  //         _isLogin = false;
  //       });
  //     }
  //   };
  // }

  // Future<AgoraRtmChannel> _createChannel(String name) async {
  //   AgoraRtmChannel channel = await globals.clientRTM.createChannel(name);
  //   channel.onMemberJoined = (AgoraRtmMember member) {
  //     // _log(
  //     //     "Member joined: " + member.userId + ', channel: ' + member.channelId);
  //     setState(() {
  //       _isOtherUserOnline = true;
  //     });
  //   };
  //   channel.onMemberLeft = (AgoraRtmMember member) {
  //     // _log("Member left: " + member.userId + ', channel: ' + member.channelId);
  //     setState(() {
  //       _isOtherUserOnline = false;
  //     });
  //   };
  //   channel.onMessageReceived =
  //       (AgoraRtmMessage message, AgoraRtmMember member) {
  //     //_log("Channel msg:" + message.text);

  //     //saveToDatabase("R", "T", MessageType.text, DateTime.now());
  //   };
  //   return channel;
  // }

  // void _loginToChatService() async {
  //   String userId = globals.loginUserType == "PATIENT"
  //       ? widget.appt.PatientCode
  //       : widget.appt.DoctorCode;

  //   try {
  //     await globals.clientRTM.login(null, userId);
  //     //_log('Connected : ' + userId);
  //     setState(() {
  //       _isLogin = true;
  //     });
  //   } catch (errorCode) {
  //     _log('Connetion error: ' + errorCode.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          //iconTheme: IconThemeData(color: globals.appTextColor),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MyCircleAvatar(
                  imgUrl: "",
                  personType:
                      globals.loginUserType == "DOCTOR" ? "PATIENT" : "DOCTOR"),
              SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 250,
                    child: Text(
                      widget.peerName,
                      style:
                          TextStyle(color: globals.appTextColor, fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "Online",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  )
                ],
              )
            ],
          ),
          titleSpacing: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
          //backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
                      itemCount: conversations?.length,
                      itemBuilder: (ctx, i) {
                        if (conversations.length > 0) {
                          if (conversations[i].direction == "R") {
                            return ReceivedMessagesWidget(
                                contactImgUrl: '',
                                message: conversations[i].message,
                                time:
                                    //"${DateFormat("hh:mm aaaa").format(conversations[i].timeStamp)}");
                                    "${DateFormat("hh:mm aaaa").format(convertToDate(conversations[i].timeStamp))}");
                          } else if (conversations[i].direction == "S") {
                            return SentMessageWidget(
                                message: conversations[i].message,
                                time:
                                    //"${DateFormat("hh:mm aaaa").format(chat[i].timeStamp)}");
                                    "${DateFormat("hh:mm aaaa").format(convertToDate(conversations[i].timeStamp))}");
                          } else {
                            return Center();
                          }
                        } else {
                          return Center();
                        }
                      },
                      reverse: true,
                    ),
                  ),
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
                                    controller: _channelMessageController,
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
                            _toggleSendChannelMessage();
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Positioned.fill(
            //   child: GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         _showBottom = false;
            //       });
            //     },
            //   ),
            // ),
            // _showBottom
            //     ? Positioned(
            //         bottom: 90,
            //         left: 25,
            //         right: 25,
            //         child: Container(
            //           padding: EdgeInsets.all(25.0),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             boxShadow: [
            //               BoxShadow(
            //                   offset: Offset(0, 5),
            //                   blurRadius: 15.0,
            //                   color: Colors.grey)
            //             ],
            //           ),
            //           child: GridView.count(
            //             mainAxisSpacing: 21.0,
            //             crossAxisSpacing: 21.0,
            //             shrinkWrap: true,
            //             crossAxisCount: 3,
            //             children: List.generate(
            //               icons.length,
            //               (i) {
            //                 return Container(
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(15.0),
            //                     color: Colors.grey[200],
            //                     border: Border.all(color: myGreen, width: 2),
            //                   ),
            //                   child: IconButton(
            //                     icon: Icon(
            //                       icons[i],
            //                       color: myGreen,
            //                     ),
            //                     onPressed: () {},
            //                   ),
            //                 );
            //               },
            //             ),
            //           ),
            //         ),
            //       )
            //     : Container(),
          ],
        ));
  }

  // Widget _showStatus() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: <Widget>[
  //       SizedBox(
  //         height: 60,
  //       ),
  //       getOtherUserStatus(),
  //       Container(
  //         alignment: Alignment.center,
  //         child: Text(
  //           globals.isLogin ? "Connected" : "Offline",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
  //         //width: 200.0,
  //         decoration: BoxDecoration(
  //             color: globals.isLogin ? Colors.green : Colors.red,
  //             borderRadius: BorderRadius.circular(8.0)),
  //         margin: EdgeInsets.only(right: 10.0),
  //       ),
  //     ],
  //   );
  // }

  // getOtherUserStatus() {
  //   if (_isOtherUserOnline == true) {
  //     return Container(
  //       alignment: Alignment.center,
  //       child: Text(
  //         globals.loginUserType == "PATIENT"
  //             ? "DOCTOR CONNECTED"
  //             : "PATIENT CONNECTED",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
  //       //width: 200.0,
  //       decoration: BoxDecoration(
  //           color: Colors.green, borderRadius: BorderRadius.circular(8.0)),
  //       margin: EdgeInsets.only(right: 10.0),
  //     );
  //   } else {
  //     return Container(
  //       alignment: Alignment.center,
  //       child: Text(
  //         globals.loginUserType == "PATIENT" ? "DOCTOR" : "PATIENT",
  //         style: TextStyle(color: Colors.grey),
  //       ),
  //       padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
  //       //width: 200.0,
  //       decoration: BoxDecoration(
  //           color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
  //       margin: EdgeInsets.only(right: 10.0),
  //     );
  //   }
  // }

  // Widget _buildSendChannelMessage() {
  //   //if (!_isLogin || !_isInChannel) {
  //   //  return Container();
  //   //}
  //   return Row(children: <Widget>[
  //     SizedBox(
  //       width: 10,
  //     ),
  //     new Expanded(
  //         child: new TextField(
  //             controller: _peerMessageController,
  //             decoration: InputDecoration(hintText: 'Type a message'))),
  //     // _buildVoiceInput(
  //     //   onPressed: _speechRecognitionAvailable && !_isListening
  //     //       ? () => start()
  //     //       : () => stop(),
  //     //   label: _isListening ? 'Listening...' : '',
  //     // ),
  //     new OutlineButton(
  //       child: Text('Send', style: textStyle),
  //       onPressed: _toggleSendChannelMessage,
  //     )
  //   ]);
  // }

  Widget _buildSendPeerMessage() {
    // return Row(children: <Widget>[
    //   SizedBox(
    //     width: 10,
    //   ),
    //   new Expanded(
    //       child: new TextField(
    //           controller: _peerMessageController,
    //           decoration: InputDecoration(hintText: 'Type a message'))),
    //   new OutlineButton(
    //     child: Text('Send', style: textStyle),
    //     onPressed: _toggleSendPeerMessage,
    //   )
    // ]);
    return Container(
      margin: EdgeInsets.all(15.0),
      height: 61,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                ],
              ),
              child: Row(
                children: [
                  //IconButton(icon: Icon(Icons.face), onPressed: () {}),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _channelMessageController,
                      decoration: InputDecoration(
                          hintText: "Type Something...",
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
          Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor, shape: BoxShape.circle),
            child: InkWell(
              child: Icon(
                //Icons.keyboard_voice,
                Icons.send,
                color: Colors.white,
              ),
              // onLongPress: () {
              //   setState(() {
              //     _showBottom = true;
              //   });
              // },
              onTap: () {
                _toggleSendChannelMessage();
              },
            ),
          )
        ],
      ),
    );
  }

  // Widget _buildVoiceInput({String label, VoidCallback onPressed}) =>
  //     new Padding(
  //         padding: const EdgeInsets.all(12.0),
  //         child: Row(
  //           children: <Widget>[
  //             FlatButton(
  //               child: Text(
  //                 label,
  //                 style: const TextStyle(color: Colors.black),
  //               ),
  //             ),
  //             IconButton(
  //               icon: Icon(Icons.mic),
  //               onPressed: onPressed,
  //             ),
  //           ],
  //         ));

  // void _toggleSendPeerMessage() async {
  //   String peerUid = globals.loginUserType == "PATIENT"
  //       ? widget.appt.DoctorCode
  //       : widget.appt.PatientCode;
  //   if (peerUid.isEmpty) {
  //     //_log('Please input peer user id to send message.');
  //     return;
  //   }

  //   String text = _peerMessageController.text;
  //   if (text.isEmpty) {
  //     //_log('Please input text to send.');
  //     return;
  //   }

  //   try {
  //     AgoraRtmMessage message = AgoraRtmMessage.fromText(text);
  //     _log(message.text);
  //     await globals.clientRTM.sendMessageToPeer(peerUid, message, false);
  //     _peerMessageController.clear();
  //     //_log('Send peer message success.');
  //   } catch (errorCode) {
  //     //_log('Send peer message error: ' + errorCode.toString());
  //     _peerMessageController.clear();
  //   }
  // }

  void _log(String info) {
    print(info);
    setState(() {
      //_infoStrings.insert(0, info);
    });
  }

  formatMessage(msg) {
    if (msg.toString().contains("Channel msg:")) {
      return Container(
          //height: 100,
          width: MediaQuery.of(context).size.width,
          //color: Theme.of(context).primaryColor,
          child: Column(children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              //Container(width: 35.0),
              Material(
                child: Image.asset(
                  globals.loginUserType == "PATIENT"
                      ? "assets/doctor_defaultpic.png"
                      : "assets/patient_defaultpic.png",
                  height: 35,
                  width: 35,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(18.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        msg.toString().replaceFirst("Channel msg:", ""),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        " " + DateFormat("H:m a").format(DateTime.now()),
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    )
                  ],
                ),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                //width: 250.0,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.0)),
                margin: EdgeInsets.only(left: 10.0),
              )
            ])
          ]));
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Flexible(
          child: Container(
            //height: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              //mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Container(
                    child: Text(
                      msg.toString(),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  " " + DateFormat("H:m a").format(DateTime.now()),
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                SizedBox(
                  width: 8.0,
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            //width: 250,

            decoration: BoxDecoration(
                color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
            //margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
            margin: EdgeInsets.only(bottom: false ? 20.0 : 10.0, right: 10.0),
          ),
        )
      ]);
    }
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
