import 'package:firebase_database/firebase_database.dart';

class ConversationChat {
  String _id;
  String _chatId;
  String _idFrom;
  String _idTo;
  String _direction;
  String _message;
  String _type;
  String _timeStamp;
  String _readflag;
  String _readTimeStamp;

  ConversationChat(
      this._id,
      this._chatId,
      this._idFrom,
      this._idTo,
      this._direction,
      this._message,
      this._type,
      this._timeStamp,
      this._readflag,
      this._readTimeStamp);

  ConversationChat.map(dynamic obj) {
    this._id = obj['_id'];
    this._chatId = obj['_chatId'];
    this._idFrom = obj['_idFrom'];
    this._idTo = obj['_idTo'];
    this._direction = obj['_direction'];
    this._message = obj['_message'];
    this._type = obj['_type'];
    this._timeStamp = obj['_timeStamp'];
    this._readflag = obj['_readflag'];
    this._readTimeStamp = obj['_readTimeStamp'];
  }

  String get id => _id;
  String get chatId => _chatId;
  String get idFrom => _idFrom;
  String get idTo => _idTo;
  String get direction => _direction;
  String get message => _message;
  String get type => _type;
  String get timeStamp => _timeStamp;
  String get readflag => _readflag;
  String get readTimeStamp => _readTimeStamp;

  ConversationChat.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _chatId = snapshot.value['chatId'];
    _idFrom = snapshot.value['idFrom'];
    _idTo = snapshot.value['idTo'];
    _direction = snapshot.value['direction'];
    _message = snapshot.value['message'];
    _type = snapshot.value['type'];
    _timeStamp = snapshot.value['timeStamp'];
    _readflag = snapshot.value['readflag'];
    _readTimeStamp = snapshot.value['readTimeStamp'];
  }
}
