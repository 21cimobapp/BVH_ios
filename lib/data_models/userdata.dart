import 'package:firebase_database/firebase_database.dart';

class UserData {
  String _id;
  String _personCode;
  String _mobileNumber;
  String _firebaseMessagingToken;
  String _userType;

  UserData(this._id, this._personCode,this._mobileNumber, this._firebaseMessagingToken,this._userType);

  String get id => _id;
  
  
  String get mobileNumber => _mobileNumber;
  
  String get firebaseMessagingToken => _firebaseMessagingToken;
  
  String get userType => _userType;

String get personCode => _personCode;
  // UserData.addData(key, resourceAllocNumber, name, file, fileType) {
  //   _id = key;
  //   _resourceAllocNumber=resourceAllocNumber;
  //   _name = name;
  //   _file = file;
  //   _fileType = fileType;
  // }

  UserData.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _personCode = snapshot.value['personCode'];
    _mobileNumber = snapshot.value['mobileNumber'];
    _firebaseMessagingToken = snapshot.value['firebaseMessagingToken'];
    _userType = snapshot.value['userType'];
  }
}
