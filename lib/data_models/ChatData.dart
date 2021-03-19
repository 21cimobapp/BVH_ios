import 'package:firebase_database/firebase_database.dart';

class ChatData {
  String _id;
  String _chatId;
  String _idFrom;
  String _idTo;
  String _direction;
  String _message;
  String _type;
  DateTime _timeStamp;

  ChatData(
    this._id,
    this._chatId,
    this._idFrom,
    this._idTo,
    this._direction,
    this._message,
    this._type,
    this._timeStamp,
  );

  String get id => _id;
  String get chatId => _chatId;
  String get idFrom => _idFrom;
  String get idTo => _idTo;
  String get direction => _direction;
  String get message => _message;
  String get type => _type;
  DateTime get timeStamp => _timeStamp;

  // FileData.addData(key, resourceAllocNumber, name, file, fileType) {
  //   _id = key;
  //   _resourceAllocNumber=resourceAllocNumber;
  //   _name = name;
  //   _file = file;
  //   _fileType = fileType;
  // }

  ChatData.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _chatId = snapshot.value['ChatId'];
    _idFrom = snapshot.value['idFrom'];
    _idTo = snapshot.value['idTo'];
    _direction = snapshot.value['direction'];
    _message = snapshot.value['message'];
    _type = snapshot.value['type'];
    _timeStamp = snapshot.value['timeStamp'];
  }
}
