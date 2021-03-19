import 'package:cloud_firestore/cloud_firestore.dart';

class ParametFirestore {
  String _id;
  String _name;
  String _serviceType;
  int _price;
  String _imagepath;
  String _pkginclud;
  String _testinclud;
  String _que1;
  String _ans1;
  // String _tag1;
  // String _daata;

  bool selected = false;

  ParametFirestore(
    this._id,
    this._name,
    this._serviceType,
    this._price,
    this._imagepath,
    this._pkginclud,
    this._testinclud,
    this._que1,
    this._ans1,
    // this._tag1,
    // this._daata
  );

  ParametFirestore.map(dynamic obj) {
    this._id = obj['id'];
    this._name = obj['TestName'];
    this._price = obj['Price'];
    this._imagepath = obj['ImagePath'];
    this._pkginclud = obj['Package_included'];
    this._testinclud = obj['Test_included'];
    this._que1 = obj['Question1'];
    this._ans1 = obj['Answer1'];
    // this._tag1 = obj['tag'];
    // this._daata = obj['name'];
    this._serviceType = obj['serviceType'];
  }

  String get id => _id;
  String get TestName => _name;
  String get ServiceType => _serviceType;
  int get Price => _price;
  String get ImagePath => _imagepath;
  String get Package_included => _pkginclud;
  String get Test_included => _testinclud;
  String get Question1 => _que1;
  String get Answer1 => _ans1;

  // String get tag => _tag1;
  // String get name => _daata;

  /* Note.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['Name'];
    _price = snapshot.value['Price'];
  } */

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['TestName'] = _name;
    map['Price'] = _price;
    map['ImagePath'] = _imagepath;
    map['Package_included'] = _pkginclud;
    map['Test_included'] = _testinclud;
    map['Question1'] = _que1;
    map['Answer1'] = _ans1;
    // map['tag'] = _tag1;
    // map['name'] = _daata;
    map['ServiceType'] = _serviceType;

    return map;
  }

  ParametFirestore.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['TestName'];
    this._price = map['Price'];
    this._imagepath = map['ImagePath'];
    this._pkginclud = map['Package_included'];
    this._testinclud = map['Test_included'];
    this._que1 = map['Question1'];
    this._ans1 = map['Answer1'];
    this._serviceType = map['ServiceType'];
    // this._tag1 = map['tag'];
    // this._daata = map['name'];
  }

/* 
  int compare(TestName a, TaskState b) {
  if (a == b) return 0;
  switch(a) {
    case TaskState.newTask:
      return -1;
      break;
    case TaskState.started:
      if(b == TaskState.newTask) return 1;
      return -1;
      break;
    case TaskState.done:
      return 1;
      break;
  }
} */
}
