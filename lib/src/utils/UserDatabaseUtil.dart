import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:civideoconnectapp/data_models/userdata.dart';

class UserDatabaseUtil {
  DatabaseReference _counterRef;
  DatabaseReference _userRef;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  int _counter;
  DatabaseError error;

  static final UserDatabaseUtil _instance = new UserDatabaseUtil.internal();

  UserDatabaseUtil.internal();

  factory UserDatabaseUtil() {
    return _instance;
  }

  void initState() {
    // Demonstrates configuring to the database using a file
    _userRef = database.reference().child("21ci").child("Users");
    _counterRef = FirebaseDatabase.instance
        .reference()
        .child('21ci')
        .child('Users')
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

  getUsers(resourceAllocNumber) async {
    return FirebaseDatabase.instance.reference().child("21ci").child("Users");
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

  addUser(UserData user) async {
    final TransactionResult transactionResult =
        await _counterRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;

      return mutableData;
    });

    if (transactionResult.committed) {
      _userRef.push().set(<String, String>{
        "mobileNumber": "" + user.mobileNumber,
        "firebaseMessagingToken": "" + user.firebaseMessagingToken,
        "userType": "" + user.userType,
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

  deleteUser(UserData user) async {
    await _userRef.child(user.id).remove().then((_) {
      print('Transaction  committed.');
    });
  }

  deleteUserByMobile(String mobileNumber) async {
    try {
      await _userRef
          .orderByChild("mobileNumber")
          .equalTo(mobileNumber)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> children = snapshot.value;
        if (children != null) {
          children.forEach((key, value) {
            _userRef.child(key).remove();
          });
        }
      });
    } catch (error) {
      print("deleteUserByMobile");
    }
  }

  getfirebaseMessagingToken(String mobileNumber) async {
    String firebaseMessagingToken;
    await _userRef
        .orderByChild("mobileNumber")
        .equalTo(mobileNumber)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> children = snapshot.value;
      if (children != null) {
        children.forEach((key, value) {
          firebaseMessagingToken = value.firebaseMessagingToken;
        });
      }
    });
    return firebaseMessagingToken;
  }

  void dispose() {
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }
}
