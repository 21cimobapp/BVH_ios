import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:http/http.dart' as http;

final Color _backgroundColor = Color(0xFFf0f0f0);

class ChatPage extends StatefulWidget {
  final String peerCode;
  final String peerName;

  ChatPage({this.peerCode, this.peerName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  String chatRoomId;
  String peerToken;
  bool peerIsOnline;

  setPeerDetails(f) {
    setState(() {
      peerToken = f.data['userToken'];
      peerIsOnline = f.data['onlineStatus'];
    });
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
        "sendTo": widget.peerCode,
        "message": messageEditingController.text,
        'time': DateTime.now(),
      };

      DatabaseMethods().addMessage(chatRoomId, chatMessageMap);

      sendNotification(
          widget.peerCode, peerToken, messageEditingController.text);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  static Future<void> sendNotification(peerCode, peerToken, msg) async {
    String token = peerToken;
    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    // await DatabaseMethods().getUserInfoByID(peerCode).then((snapshot) =>
    //     snapshot.documents.forEach((f) => token = f.data['userToken']));
    // print('token : $token');

    final data = {
      "notification": {
        "body": msg,
        "title": "Message from ${globals.personName}"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": "$token"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAelrRLcY:APA91bGCxyBn5Ii3vNjgTD_vvf0PbglJCKfcRW6cxfxuRWfZNzD8mhYqazUuWknVyWV-iXxRCCStiIvlKrW0FMXFZp47R9JveDwyHFZMGmnthZZf-uKG04w4zCqF-g_nqwNyYdb8vlEr'
    };

    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );

    try {
      final response = await Dio(options).post(postUrl, data: data);

      if (response.statusCode == 200) {
        //Fluttertoast.showToast(msg: 'Request Sent To Driver');
        print('notification Sent');
      } else {
        print('notification sending failed');
        // on failure do sth
      }
    } catch (e) {
      print('exception $e');
    }
  }

  @override
  void initState() {
    initChat();

    DatabaseMethods().getUserInfoByID(widget.peerCode).then(
        (snapshot) => snapshot.documents.forEach((f) => setPeerDetails(f)));

    super.initState();
  }

  initChat() async {
    List<String> users;
    List<String> userNames;

    if (globals.loginUserType == "PATIENT") {
      users = [globals.personCode, widget.peerCode];
      userNames = [globals.personName, widget.peerName];
    } else {
      users = [widget.peerCode, globals.personCode];
      userNames = [widget.peerName, globals.personName];
    }

    chatRoomId = getChatRoomId(globals.personCode, widget.peerCode);

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

  getChatRoomId(personCode, peerCode) {
    String chatID;
    if (globals.loginUserType == "PATIENT") {
      chatID = "${personCode}_${peerCode}";
    } else {
      chatID = "${peerCode}_${personCode}";
    }
    return chatID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   //iconTheme: IconThemeData(color: globals.appTextColor),
      //   title: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: <Widget>[
      //       MyCircleAvatar(
      //           imgUrl: "",
      //           personType:
      //               globals.loginUserType == "DOCTOR" ? "PATIENT" : "DOCTOR"),
      //       SizedBox(width: 15),
      //       Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: <Widget>[
      //           Container(
      //             width: 220,
      //             child: Text(
      //               widget.peerName,
      //               style: TextStyle(color: globals.appTextColor, fontSize: 20),
      //               overflow: TextOverflow.ellipsis,
      //             ),
      //           ),
      //           Text(
      //             peerIsOnline != null
      //                 ? peerIsOnline == true ? "Online" : ""
      //                 : "",
      //             style: TextStyle(color: Colors.white70, fontSize: 15),
      //           )
      //         ],
      //       )
      //     ],
      //   ),
      //   titleSpacing: 0,
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.more_vert),
      //       onPressed: () {},
      //     ),
      //   ],
      //   //backgroundColor: Theme.of(context).primaryColor,
      // ),
      body: Container(
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
      ),
    );
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
        child: Text('${widget.peerName}'.toUpperCase(),
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
            child: Text(readTimestamp(time),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300))),
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
