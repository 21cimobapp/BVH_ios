import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:civideoconnectapp/data_models/filedata.dart';

class DocDatabaseUtil {
  DatabaseReference _counterRef;
  DatabaseReference _userRef;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  int _counter;
  DatabaseError error;

  static final DocDatabaseUtil _instance = new DocDatabaseUtil.internal();

  DocDatabaseUtil.internal();

  factory DocDatabaseUtil() {
    return _instance;
  }

  void initState() {
    // Demonstrates configuring to the database using a file
    _counterRef = FirebaseDatabase.instance
        .reference()
        .child('21ci')
        .child('Documents')
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

  getDocuments(patientCode) async {
    return FirebaseDatabase.instance
        .reference()
        .child("21ci")
        .child("Documents")
        .child(patientCode);
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

  addDocument(FileData user) async {
    final TransactionResult transactionResult =
        await _counterRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;

      return mutableData;
    });

    if (transactionResult.committed) {
      _userRef = database
          .reference()
          .child("21ci")
          .child("Documents")
          .child(user.patientCode);
      _userRef.push().set(<String, String>{
        "name": "" + user.name,
        "file": "" + user.picFile,
        "fileType": "" + user.fileType,
        "nameCustom": "" + user.nameCustom,
        "documentDate": "" + user.documentDate.toString(),
        "uploadDate": "" + user.uploadDate.toString(),
        "source": "" + user.source,
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

  void deleteDocument(FileData user) async {
    _userRef = database
        .reference()
        .child("21ci")
        .child("Documents")
        .child(user.patientCode);
    await _userRef.child(user.id).remove().then((_) {
      print('Transaction  committed.');
    });
  }

  void dispose() {
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }
}
