import 'package:firebase_database/firebase_database.dart';

class FileData {
  String _id;
  String _patientCode;
  String _name;
  String _file;
  String _fileType;
  String _nameCustom;
  DateTime _documentDate;
  DateTime _uploadDate;
  String _source;

  FileData(this._id, this._patientCode, this._name, this._file, this._fileType,
      this._nameCustom, this._documentDate, this._uploadDate, this._source);

  String get patientCode => _patientCode;

  String get name => _name;

  String get picFile => _file;

  String get id => _id;

  String get fileType => _fileType;
  String get nameCustom => _nameCustom;
  DateTime get documentDate => _documentDate;
  DateTime get uploadDate => _uploadDate;
  String get source => _source;
  // FileData.addData(key, resourceAllocNumber, name, file, fileType) {
  //   _id = key;
  //   _resourceAllocNumber=resourceAllocNumber;
  //   _name = name;
  //   _file = file;
  //   _fileType = fileType;
  // }

  FileData.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];
    _file = snapshot.value['image'];
    _fileType = snapshot.value['fileType'];
    _nameCustom = snapshot.value['nameCustom'];
    _documentDate = snapshot.value['documentDate'];
    _uploadDate = snapshot.value['uploadDate'];
    _source = snapshot.value['source'];
  }
}
