import 'package:firebase_database/firebase_database.dart';

class ConversationModel {
  String _id;
  String _chatId;
  String _idFrom;
  String _idTo;
  String _direction;
  String _message;
  String _type;
  String _timeStamp;
  String _fullName;
  String _image;

  ConversationModel(
      this._id,
      this._chatId,
      this._idFrom,
      this._idTo,
      this._direction,
      this._message,
      this._type,
      this._timeStamp,
      this._fullName,
      this._image);

  ConversationModel.map(dynamic obj) {
    this._id = obj['_id'];
    this._chatId = obj['_chatId'];
    this._idFrom = obj['_idFrom'];
    this._idTo = obj['_idTo'];
    this._direction = obj['_direction'];
    this._message = obj['_message'];
    this._type = obj['_type'];
    this._timeStamp = obj['_timeStamp'];
    this._fullName = obj['_fullName'];
    this._image = obj['_image'];
  }

  String get id => _id;
  String get chatId => _chatId;
  String get idFrom => _idFrom;
  String get idTo => _idTo;
  String get direction => _direction;
  String get message => _message;
  String get type => _type;
  String get timeStamp => _timeStamp;
  String get fullName => _fullName;
  String get image => _image;

  ConversationModel.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _chatId = snapshot.value['chatId'];
    _idFrom = snapshot.value['idFrom'];
    _idTo = snapshot.value['idTo'];
    _direction = snapshot.value['direction'];
    _message = snapshot.value['message'];
    _type = snapshot.value['type'];
    _timeStamp = snapshot.value['timeStamp'];
    _fullName = snapshot.value['fullName'];
    _image = snapshot.value['image'];
  }
}
