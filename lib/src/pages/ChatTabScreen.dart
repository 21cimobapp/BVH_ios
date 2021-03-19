import 'package:civideoconnectapp/src/pages/ChatPage.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:flutter/material.dart';
//import 'package:civideoconnectapp/data_models/ConversationModel.dart';
import 'dart:async';
//import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
//import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatTabScreen extends StatefulWidget {
  @override
  _ChatTabScreenState createState() => new _ChatTabScreenState();
}

//DatabaseReference notesReference;

class _ChatTabScreenState extends State<ChatTabScreen> {
  //List<ConversationModel> conversations;
  //StreamSubscription<Event> _onNoteAddedSubscription;
  //StreamSubscription<Event> _onNoteChangedSubscription;

  Stream<QuerySnapshot> chatHistory;

  @override
  void initState() {
    super.initState();

    DatabaseMethods().getUserChats(globals.personCode).then((val) {
      setState(() {
        chatHistory = val;
      });
    });

    // notesReference = FirebaseDatabase.instance
    //     .reference()
    //     .child("21ci")
    //     .child("ChatsHistory")
    //     .child(globals.personCode);

    // conversations = new List();

    // _onNoteAddedSubscription = notesReference.onChildAdded.listen(_onNoteAdded);
    // _onNoteChangedSubscription =
    //     notesReference.onChildChanged.listen(_onNoteUpdated);
  }

  // void _onNoteAdded(Event event) {
  //   setState(() {
  //     conversations.add(new ConversationModel.fromSnapshot(event.snapshot));
  //   });
  // }

  // void _onNoteUpdated(Event event) {
  //   var oldNoteValue =
  //       conversations.singleWhere((note) => note.id == event.snapshot.key);
  //   setState(() {
  //     conversations[conversations.indexOf(oldNoteValue)] =
  //         new ConversationModel.fromSnapshot(event.snapshot);
  //   });
  // }

  // void _deleteNote(
  //     BuildContext context, ConversationModel note, int position) async {
  //   await notesReference.child(note.id).remove().then((_) {
  //     setState(() {
  //       conversations.removeAt(position);
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: chatHistory,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  // String peerName = "";
                  // DocumentSnapshot snapshot= await Firestore.instance.collection('channels').document('567890').
                  // var channelName = snapshot['channelName'];
                  // peerName = Firestore.instance.collection('users').document(
                  //     snapshot.data.documents[index].data["users"][1]).get("userName");

                  return conversation(
                    context,
                    snapshot.data.documents[index], //.data["users"][1],
                    "",
                    "",
                  );
                })
            : Container();
      },
    );
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateTime.parse(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  getPeerName(peerCode) async {
    String peerName = "";

    // DatabaseMethods().getUserInfoByID(peerCode).then((val) {
    //   peerName = val.documents[0].data["userName"].toString();
    // }).catchError((e) {
    //   print(e.toString());
    // });

    return peerName;
  }

  Widget conversation(BuildContext context, document, message, timeStamp) {
    String peerCode = "";
    String peerName = "";

    if (globals.loginUserType == "PATIENT") {
      peerCode = document.data["users"][1];
      peerName = document.data["userNames"][1];
    } else {
      peerCode = document.data["users"][0];
      peerName = document.data["userNames"][0];
    }
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => ChatPage(
                peerCode: peerCode,
                peerName: peerName,
              ))),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: MyCircleAvatar(
                  imgUrl: "",
                  personType:
                      globals.loginUserType == "DOCTOR" ? "PATIENT" : "DOCTOR"),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 230,
                        child: Text(
                          "$peerName",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Text(
                      //   message,
                      //   style: TextStyle(color: Colors.grey),
                      // ),
                    ],
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: <Widget>[
                  //     SizedBox(
                  //       height: 5,
                  //     ),
                  //     Text(
                  //       timeStamp,
                  //       style: TextStyle(
                  //           // color: conversation.direction == "S"
                  //           //     ? Color(0xFF25D366)
                  //           //     : Colors.grey),
                  //           color: Colors.grey),
                  //     ),
                  //     // conversation.messageCout > 0
                  //     //     ? Chip(
                  //     //         backgroundColor: Color(0xFF25D366),
                  //     //         label: Text(
                  //     //           '${conversation.messageCout}',
                  //     //           style: TextStyle(color: Colors.white),
                  //     //         ),
                  //     //       )
                  //     //     : Text(''),
                  //   ],
                  // )
                ],
              ),
            ),
            // Container(
            //   width: 330,
            //   height: 1,
            //   margin: EdgeInsets.only(left: 56, top: 21),
            //   color: Colors.grey.withOpacity(.2),
            // )
          ],
        ),
      ),
    );
  }
}
