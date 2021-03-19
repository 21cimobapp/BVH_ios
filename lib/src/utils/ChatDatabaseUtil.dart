import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:civideoconnectapp/data_models/chatdata.dart';

class ChatDatabaseUtil {
  DatabaseReference _counterRef;
  DatabaseReference _userRef;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  int _counter;
  DatabaseError error;

  static final ChatDatabaseUtil _instance = new ChatDatabaseUtil.internal();

  ChatDatabaseUtil.internal();

  factory ChatDatabaseUtil() {
    return _instance;
  }

  void initState() {
    // Demonstrates configuring to the database using a file
    _counterRef = FirebaseDatabase.instance
        .reference()
        .child('21ci')
        .child('Chats')
        .child('counter');
    // Demonstrates configuring the database directly

    database.reference().child('counter').once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _counterRef.keepSynced(true);

    _counterSubscription = _counterRef.onValue.listen((Event event) {
      error = null;
      _counter = event.snapshot.value ?? 0;
    }, onError: (Object o) {
      error = o;
    });
  }

  getData() async {
    return await FirebaseDatabase.instance
        .reference()
        .child('counter')
        .limitToFirst(10);
  }

  getChat(personCode, chatID) async {
    return FirebaseDatabase.instance
        .reference()
        .child("21ci")
        .child("Chats")
        .child(personCode)
        .child(chatID);
    //.limitToFirst(10);
  }

  DatabaseError getError() {
    return error;
  }

  int getCounter() {
    return _counter;
  }

  DatabaseReference ref() {
    return _userRef;
  }

  updateChatHistory(ChatData chat, userName) async {
    _userRef = database
        .reference()
        .child("21ci")
        .child("ChatsHistry")
        .child(chat.idFrom)
        .child(chat.idTo);

    await _userRef.update({
      "chatId": "" + chat.chatId,
      "idFrom": "" + chat.idFrom,
      "idTo": "" + chat.idTo,
      "direction": "S",
      "message": "" + chat.message,
      "type": "" + chat.type,
      "timeStamp": "" + chat.timeStamp.toString(),
      "fullName": "" + userName,
      "image": "" + "",
    }).then((_) {
      print('Transaction  committed.');
    });

    _userRef = database
        .reference()
        .child("21ci")
        .child("ChatsHistry")
        .child(chat.idTo)
        .child(chat.idFrom);

    await _userRef.update({
      "chatId": "" + chat.chatId,
      "idFrom": "" + chat.idFrom,
      "idTo": "" + chat.idTo,
      "direction": "R",
      "message": "" + chat.message,
      "type": "" + chat.type,
      "timeStamp": "" + chat.timeStamp.toString(),
      "fullName": "" + userName,
      "image": "" + "",
    }).then((_) {
      print('Transaction  committed.');
    });
  }

  addChat(ChatData chat) async {
    final TransactionResult transactionResult =
        await _counterRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;

      return mutableData;
    });

    if (transactionResult.committed) {
      _userRef = database
          .reference()
          .child("21ci")
          .child("Chats")
          .child(chat.idFrom)
          .child(chat.chatId);

      _userRef.push().set(<String, String>{
        "chatId": "" + chat.chatId,
        "idFrom": "" + chat.idFrom,
        "idTo": "" + chat.idTo,
        "direction": "S",
        "message": "" + chat.message,
        "type": "" + chat.type,
        "timeStamp": "" + chat.timeStamp.toString(),
      }).then((_) {
        print('Transaction  committed.');
      });

      _userRef = database
          .reference()
          .child("21ci")
          .child("Chats")
          .child(chat.idTo)
          .child(chat.chatId);

      _userRef.push().set(<String, String>{
        "chatId": "" + chat.chatId,
        "idFrom": "" + chat.idFrom,
        "idTo": "" + chat.idTo,
        "direction": "R",
        "message": "" + chat.message,
        "type": "" + chat.type,
        "timeStamp": "" + chat.timeStamp.toString(),
      }).then((_) {
        print('Transaction  committed.');
      });
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  void deleteChat(ChatData chat) async {
    _userRef =
        database.reference().child("21ci").child("Chats").child(chat.idFrom);
    await _userRef.child(chat.chatId).remove().then((_) {
      print('Transaction  committed.');
    });
  }

  void dispose() {
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }
}
