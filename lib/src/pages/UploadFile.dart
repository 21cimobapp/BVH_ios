import 'package:civideoconnectapp/utils/Database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:uuid/uuid.dart';

final TextEditingController _controllerFileName = new TextEditingController();
final TextEditingController _controllerDate = new TextEditingController();

DateTime convertToDate(String input) {
  try {
    var d = new DateFormat.yMd().parseStrict(input);
    return d;
  } catch (e) {
    return null;
  }
}

class UploadFile extends StatefulWidget {
  final FileType fileType;
  final String patientCode;

  /// Creates a call page with given channel name.
  const UploadFile({Key key, this.patientCode, this.fileType})
      : super(key: key);

  final String title = 'Upload Documents';

  @override
  UploadFileState createState() => UploadFileState();
}

class UploadFileState extends State<UploadFile> {
  //
  String _path;
  Map<String, String> _paths;
  String _extension;
  FileType _pickType;
  bool _multiPick = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  String fileName;
  String filePath;
  File _document;
  bool _isUpload = false;
  final ImagePicker picker = ImagePicker();
  final Color _backgroundColor = Color(0xFFf0f0f0);

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;

    setState(() {
      _controllerDate.text = new DateFormat.yMd().format(result);
    });
  }

  void initState() {
    super.initState();

    _pickType = widget.fileType;
    _controllerDate.text = new DateFormat.yMd().format(DateTime.now());
    if (_pickType == FileType.image) {
      getImage();
    } else if (_pickType == FileType.media) {
      getCameraImage();
    } else {
      openFileExplorer();
    }
  }

  Future getCameraImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    String fileName;
    if (pickedFile == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _document = File(pickedFile.path);
        _controllerFileName.text = "Document";
      });
    }
  }

  Future getImage() async {
    //final pickedFile = await picker.getImage(source: imageSource);

    String fileName;

    _path = await FilePicker.getFilePath(
        type: FileType.custom, allowedExtensions: ['jpg', 'png']);
    if (_path == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _document = File(_path);
        fileName = _document.path.split("/").last;
        fileName = fileName.replaceAll(".${fileName.split(".").last}", "");
        _controllerFileName.text = fileName;
      });
    }
  }

  void openFileExplorer() async {
    try {
      String fileName;
      _path = null;
      if (_multiPick) {
        _paths = await FilePicker.getMultiFilePath(type: FileType.custom);
      } else {
        _path = await FilePicker.getFilePath(
            type: FileType.custom, allowedExtensions: ['pdf']);
      }
      if (_path != null) {
        fileName = _path.split('/').last;
        filePath = _path;

        uploadToFirebase(fileName, filePath);
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
  }

  uploadFileToFB() {
    _isUpload = true;
    fileName = _document.path.split('/').last;
    filePath = _document.path;

    uploadToFirebase(fileName, filePath);
  }

  uploadToFirebase(fileName, filePath) {
    if (_multiPick) {
      _paths.forEach((fileName, filePath) => {upload(fileName, filePath)});
    } else {
      upload(fileName, filePath);
    }
  }

  upload(fileName, filePath) {
    _extension = fileName.toString().split('.').last;
    // StorageReference storageRef = FirebaseStorage.instance.ref().child(
    //     "21ci/Appointments/" + widget.resourceAllocNumber + "/" + fileName);

    StorageReference storageRef = FirebaseStorage.instance
        .ref()
        .child("eRecords")
        .child(widget.patientCode)
        .child(fileName);

    final StorageUploadTask uploadTask = storageRef.putFile(
      File(filePath),
      StorageMetadata(
        contentType: '$_pickType/$_extension',
      ),
    );
    setState(() {
      _tasks.add(uploadTask);
    });
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }

  getFileType() {
    String fileType;
    fileType = _pickType.toString().split('.').last;
    if (fileType == "media") {
      return "image";
    } else {
      return fileType;
    }
  }

  _onUploadSuccess() async {
    //_showSnackBar("File Uploaded");

    Navigator.pop(context);
  }

  _onUploadFailed() async {
    //_showSnackBar("Upload Failed");
    Navigator.pop(context);
  }

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    _tasks.forEach((StorageUploadTask task) {
      final Widget tile = UploadTaskListTile(
        patientCode: widget.patientCode,
        fileName: fileName,
        fileType: getFileType(),
        task: task,
        onDismissed: () => setState(() => _tasks.remove(task)),
        onUploadSuccess: () => {_onUploadSuccess()},
        onUploadFailed: () => {_onUploadFailed()},
      );
      children.add(tile);
    });

    return new Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: _document == null
                        ? Text('No image selected.')
                        : Container(
                            height: MediaQuery.of(context).size.height / 4,
                            child: Image.file(_document)),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.image),
                      hintText: '',
                      labelText: 'Document Name',
                    ),
                    controller: _controllerFileName,
                  ),
                  Row(children: <Widget>[
                    new Expanded(
                        child: new TextFormField(
                      decoration: new InputDecoration(
                        icon: const Icon(Icons.calendar_today),
                        hintText: '',
                        labelText: 'Document Date',
                      ),
                      controller: _controllerDate,
                          readOnly: true,
                      //keyboardType: TextInputType.datetime,
                    )),
//                    new IconButton(
//                      icon: new Icon(Icons.more_horiz),
//                      tooltip: 'Choose date',
//                      onPressed: (() {
//                        _chooseDate(context, _controllerDate.text);
//                      }),
//                    )
                  ]),
                  SizedBox(
                    height: 20.0,
                  ),
                  _document == null || _isUpload
                      ? Center()
                      : Center(
                          child: Container(
                              width: 100,
                              child: RawMaterialButton(
                                onPressed: () => {uploadFileToFB()},
                                child: Icon(
                                  Icons.file_upload,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: Theme.of(context).accentColor)),
                                elevation: 2.0,
                                fillColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.all(15.0),
                              )),
                        ),
                  Flexible(
                    child: ListView(
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadFile(StorageReference ref) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/tmp.jpg');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final StorageFileDownloadTask task = ref.writeToFile(tempFile);
    final int byteCount = (await task.future).totalByteCount;
    var bodyBytes = downloadData.bodyBytes;
    final String name = await ref.getName();
    final String path = await ref.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
      '\npath: $path \nBytes Count :: $byteCount',
    );
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Image.memory(
          bodyBytes,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appBarIconsColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.only(right: 18.0),
        //   child: Icon(Icons.more_horiz, color: appBarIconsColor, size: 28),
        // )
      ],
      brightness: Brightness.light,
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text('Upload Documents'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.5,
              color: appBarIconsColor,
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}

class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile(
      {Key key,
      this.patientCode,
      this.fileName,
      this.task,
      this.fileType,
      this.onDismissed,
      this.onUploadSuccess,
      this.onUploadFailed})
      : super(key: key);
  final String patientCode;
  final String fileName;
  final String fileType;
  final StorageUploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onUploadSuccess;
  final VoidCallback onUploadFailed;

  String get status {
    String result = "";

    if (task.isComplete) {
      if (task.isSuccessful) {
        result = 'Complete';
        saveToDatabase();
      } else if (task.isCanceled) {
        result = 'Canceled';

        onUploadFailed();
      } else {
        result = 'Failed ERROR: ${task.lastSnapshot.error}';

        onUploadFailed();
      }
    } else if (task.isInProgress) {
      result = 'Uploading';
    } else if (task.isPaused) {
      result = 'Paused';
    }

    return result;
  }

  saveToDatabase() async {
    String url = await task.lastSnapshot.ref.getDownloadURL();

    Map<String, dynamic> document = {
      "documentCode":Uuid().v4().toString(),
      "patientCode": patientCode,
      "documentName": task.lastSnapshot.storageMetadata.name,
      "documentURL": url,
      "documentType": fileType,
      "documentTitle": _controllerFileName.text,
      "documentDate": convertToDate(_controllerDate.text),
      "uploadedDate": DateTime.now(),
      "uploadedBy": globals.loginUserType == "PATIENT" ? "PATIENT" : "OTHERS",
      "uploadedSource": globals.loginUserType,
    };

    await DatabaseMethods().addPatientDocument(document, patientCode);

    onUploadSuccess();
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,
          AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {
        Widget subtitle;
        if (asyncSnapshot.hasData) {
          final StorageTaskEvent event = asyncSnapshot.data;
          final StorageTaskSnapshot snapshot = event.snapshot;
          subtitle = Text('$status: ${_bytesTransferred(snapshot)} bytes sent');
        } else {
          subtitle = const Text('Starting...');
        }
        return Dismissible(
          key: Key(task.hashCode.toString()),
          onDismissed: (_) => onDismissed(),
          child: ListTile(
            title: Text(fileName),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Offstage(
                  offstage: !task.isInProgress,
                  child: IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => task.pause(),
                  ),
                ),
                Offstage(
                  offstage: !task.isPaused,
                  child: IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => task.resume(),
                  ),
                ),
                Offstage(
                  offstage: task.isComplete,
                  child: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => task.cancel(),
                  ),
                ),
                // Offstage(
                //   offstage: !(task.isComplete && task.isSuccessful),
                //   child: IconButton(
                //     icon: const Icon(Icons.file_download),
                //     onPressed: onDownload,
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
