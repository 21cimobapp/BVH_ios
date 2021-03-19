import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/globals.dart' as globals;

class ViewEPrescription extends StatefulWidget {
  final DocumentSnapshot appt;
  final String path;
  final String pageTitle;
  ViewEPrescription({Key key, this.appt, this.pageTitle, this.path})
      : super(key: key);

  _ViewEPrescriptionState createState() => _ViewEPrescriptionState();
}

class _ViewEPrescriptionState extends State<ViewEPrescription>
    with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Widget tile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.pageTitle),
        actions: <Widget>[
          tile == null ? Container() : tile,
          widget.appt.data["prescriptionStatus"] == "PUBLISHED"
              ? Container()
              : RaisedButton.icon(
                  onPressed: () {
                    String fileName;
                    fileName =
                        "ePrescription_${widget.appt.data["appointmentNumber"]}.pdf";
                    uploadToFirebase(fileName, widget.path);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  label: Text(
                    'Pubilish',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  icon: Icon(
                    Icons.publish,
                    color: Colors.white,
                  ),
                  textColor: Colors.white,
                  splashColor: Theme.of(context).accentColor,
                  color: Theme.of(context).primaryColor,
                )
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.WIDTH,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onPageChanged: (int page, int total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              label: Text("Page $currentPage of $pages)"),
              onPressed: () async {
                await snapshot.data.setPage(pages ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
  }

  uploadToFirebase(fileName, filePath) {
    upload(fileName, filePath);

    tile = UploadTaskListTile(
      patientCode: widget.appt.data["patientCode"],
      appointmentNumber: widget.appt.data["appointmentNumber"],
      fileName: fileName,
      fileType: "pdf",
      task: _tasks[0],
      onDismissed: () => setState(() => _tasks.remove(_tasks[0])),
      onUploadSuccess: () => {_onUploadSuccess()},
      onUploadFailed: () => {_onUploadFailed()},
    );
  }

  _onUploadSuccess() async {
    _showSnackBar("e-Prescription uploaded");

    Navigator.pop(context);
  }

  _onUploadFailed() async {
    _showSnackBar("e-Prescription upload Failed");
    //Navigator.pop(context);
  }

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  upload(fileName, filePath) {
    //String _extension = fileName.toString().split('.').last;
    // StorageReference storageRef = FirebaseStorage.instance.ref().child(
    //     "21ci/Appointments/" + widget.resourceAllocNumber + "/" + fileName);
    String _extension = "pdf";

    StorageReference storageRef = FirebaseStorage.instance
        .ref()
        .child("eRecords")
        .child(widget.appt.data["patientCode"])
        .child(fileName);

    final StorageUploadTask uploadTask = storageRef.putFile(
      File(filePath),
      StorageMetadata(
        contentType: '$FileType.any/$_extension',
      ),
    );
    setState(() {
      _tasks.add(uploadTask);
    });
  }
}

class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile(
      {Key key,
      this.patientCode,
      this.appointmentNumber,
      this.fileName,
      this.task,
      this.fileType,
      this.onDismissed,
      this.onUploadSuccess,
      this.onUploadFailed})
      : super(key: key);
  final String patientCode;
  final String appointmentNumber;
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
      "patientCode": patientCode,
      "documentName": task.lastSnapshot.storageMetadata.name,
      "documentURL": url,
      "documentType": fileType,
      "documentTitle": this.fileName,
      "documentDate": DateTime.now(),
      "uploadedDate": DateTime.now(),
      "uploadedBy": globals.loginUserType == "PATIENT" ? "PATIENT" : "OTHERS",
      "uploadedSource": globals.loginUserType,
      "documentCategory": "EPRESCRIPTION",
      "documentCode": "ePr$appointmentNumber"
    };

    await DatabaseMethods().addPatientDocument(document, patientCode);

    await DatabaseMethods().updateAppointmentDetails(
        appointmentNumber, "prescriptionStatus", "PUBLISHED");

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
