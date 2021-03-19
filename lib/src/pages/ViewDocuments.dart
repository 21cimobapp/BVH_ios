import 'package:civideoconnectapp/src/pages/PatientReports.dart';
import 'package:civideoconnectapp/src/pages/ShareFile.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:civideoconnectapp/src/pages/UploadFile.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:unicorndial/unicorndial.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
//import 'package:civideoconnectapp/src/utils/DocDatabaseUtil.dart';
//import 'package:civideoconnectapp/data_models/filedata.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:civideoconnectapp/src/pages/ViewImage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDocuments extends StatefulWidget {
  final String patientCode;

  const ViewDocuments({Key key, this.patientCode}) : super(key: key);

  @override
  _ViewDocumentsState createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewDocuments>
    with SingleTickerProviderStateMixin {
  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  //     new GlobalKey<RefreshIndicatorState>();
  //DocDatabaseUtil docDatabase;
  //List<FileData> files = new List();
  //List<FileData> filesOther = new List();

  TextStyle get bodyTextStyle => TextStyle(
        color: Color(0xFF083e64),
        fontSize: 13,
        fontFamily: 'OpenSans',
      );

  Stream<QuerySnapshot> documents;
  String uploadedBy;
  final Color _backgroundColor = Color(0xFFf0f0f0);

  List<bool> isSelected;
  int selectedCellIndex = -1;

  final ImagePicker picker = ImagePicker();
  var itemRef;
  bool downloading = false;
  double download = 0.0;
  File downloadFileName;
  String downloadingStr = "";
  String progressString = '0';

  @override
  void initState() {
    super.initState();
    isSelected = [true, false];

    uploadedBy = "PATIENT";

    loadDocuments();
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateTime.parse(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  Container getStructuredGridCell(DocumentSnapshot document, int index) {
    return Container(
      child: GestureDetector(
        onTap: () {
          //openFile(document);

          setState(() {
            if (selectedCellIndex == index)
              selectedCellIndex = -1;
            else
              selectedCellIndex = index;
          });
        },
        child: new Container(
          margin: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                offset: Offset(4, 4),
                blurRadius: 5,
                color: Colors.white70,
              )
            ],
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                  Center(
                      child: (document.data["documentType"] == "image")
                          ? FadeInImage.memoryNetwork(
                        //width: 150,
                        //height: 150,
                        placeholder: kTransparentImage,
                        image: document.data["documentURL"],
                        fit: BoxFit.fitWidth,
                      )
                          : getfileIcon(
                              document.data["documentName"].split(".").last,
                              document.data["documentCategory"])),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "${document.data["documentTitle"]}",
                            style: bodyTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            "${DateFormat("dd MMM yyyy").format(document.data["documentDate"].toDate())}",
                            style: bodyTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  (selectedCellIndex == index)
                      ? Positioned(
                          top: 20.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                RawMaterialButton(
                                  onPressed: () async {
                                    await openFile(document);
                                    setState(() {
                                      selectedCellIndex = -1;
                                    });
                                  },
                                  child: Text("View"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  elevation: 2.0,
                                  fillColor: Colors.blueGrey,
                                  padding: const EdgeInsets.all(5.0),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
//                                globals.loginUserType == "PATIENT"   // Commented by vrushali
//                                    ? RawMaterialButton(
//                                        onPressed: () async {
//                                          await shareFile(document);
//                                          setState(() {
//                                            selectedCellIndex = -1;
//                                          });
//                                        },
//                                        child: Text("Share"),
//                                        shape: RoundedRectangleBorder(
//                                            borderRadius:
//                                                BorderRadius.circular(25.0),
//                                            side: BorderSide(
//                                                color: Theme.of(context)
//                                                    .primaryColor)),
//                                        elevation: 2.0,
//                                        fillColor: Colors.blueGrey,
//                                        padding: const EdgeInsets.all(5.0),
//                                      )
//                                    : Container(),

                      uploadedBy == "PATIENT" ?
                                RawMaterialButton(  // added by vrushali
                                  onPressed: () { _showDeleteDialog(document);
                                  setState(() {
                                    selectedCellIndex = -1;
                                  });
                                  },
                                  child: Text("Delete"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(25.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColor)),
                                  elevation: 2.0,
                                  fillColor: Colors.blueGrey,
                                  padding: const EdgeInsets.all(5.0),
                                )
                          : Container(),

                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              )),
        ),
      ),
    );
  }

  getfileIcon(ext, category) {
    if (category == "EPRESCRIPTION")
      return Image.asset(
        'assets/images/eprescription.jpg',
      );
    else if (ext == "pdf")
      return Image.asset(
        'assets/images/PDFFile.png',
      );
    else {
      return Image.asset(
        'assets/images/documentFile.jpg',
      );
    }
  }

  openFile(DocumentSnapshot document) async {
    if (document.data["documentType"] == "image") {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewImage(document: document),
        ),
      );
    } else {
      downloadFile(document.data["documentURL"]);
    }
  }

  shareFile(DocumentSnapshot document) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ShareFile(patientCode: widget.patientCode, document: document),
      ),
    );
  }

  //added by vrushali
  Future<void> _showDeleteDialog(DocumentSnapshot document) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert...'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Are you sure want to delete ?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                deleteDocument(document);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // added by vrushali
  deleteDocument(DocumentSnapshot document) async {
    await DatabaseMethods().deleteDocuments(
        widget.patientCode, document.documentID);
    //Navigator.pop(context);
  }

  Future<void> downloadFile(url) async {
    Dio dio = Dio();
    String filename;
    try {
      var dir = await getApplicationDocumentsDirectory();
      filename = "${dir.path}/" + url.substring(url.lastIndexOf("/") + 1);

      await dio.download(url, filename, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progressString = "Completed";
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFScreen(path: filename),
      ),
    );
    print("Download completed");
  }

  Future<File> createFileOfPdfUrl(String url) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);

      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  // added by vrushali
  Widget floatingActionButtons(){
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Camera",
        currentButton: FloatingActionButton(
          heroTag: "Camera",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.camera),
          onPressed: () {
            uploadDocument(FileType.media);
          },
        )));
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Image",
        currentButton: FloatingActionButton(
          heroTag: "Image",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.image),
          onPressed: () {
            uploadDocument(FileType.image);
          },
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "PDF",
        currentButton: FloatingActionButton(
          heroTag: "PDF",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.file_upload),
          onPressed: () {
            uploadDocument(FileType.any);
          },
        )));
    if(uploadedBy == "PATIENT") {
      //floatingActionButton:
      return UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Theme.of(context).accentColor,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons);
    }else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
//    var childButtons = List<UnicornButton>();  // commented by vrushali
//
//    childButtons.add(UnicornButton(
//        hasLabel: true,
//        labelText: "Camera",
//        currentButton: FloatingActionButton(
//          heroTag: "Camera",
//          backgroundColor: Colors.redAccent,
//          mini: true,
//          child: Icon(Icons.camera),
//          onPressed: () {
//            uploadDocument(FileType.media);
//          },
//        )));
//    childButtons.add(UnicornButton(
//        hasLabel: true,
//        labelText: "Image",
//        currentButton: FloatingActionButton(
//          heroTag: "Image",
//          backgroundColor: Colors.redAccent,
//          mini: true,
//          child: Icon(Icons.image),
//          onPressed: () {
//            uploadDocument(FileType.image);
//          },
//        )));
//
//    childButtons.add(UnicornButton(
//        hasLabel: true,
//        labelText: "PDF",
//        currentButton: FloatingActionButton(
//          heroTag: "PDF",
//          backgroundColor: Colors.redAccent,
//          mini: true,
//          child: Icon(Icons.file_upload),
//          onPressed: () {
//            uploadDocument(FileType.any);
//          },
//        )));
    return Scaffold(
        backgroundColor: _backgroundColor,
        floatingActionButton: floatingActionButtons(), // changed by vrushali
//        UnicornDialer(
//            backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
//            parentButtonBackground: Theme.of(context).accentColor,
//            orientation: UnicornOrientation.VERTICAL,
//            parentButton: Icon(Icons.add),
//            childButtons: childButtons),
        appBar: _buildAppBar(),
        body: new Column(
          children: <Widget>[
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 40,
                      width: double.infinity,
                      color: Colors.white,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Documents",
                                style: bodyTextStyle.copyWith(
                                    fontWeight: FontWeight.bold)),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.teal,
                                child: RawMaterialButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PatientReports(
                                            patientCode: widget.patientCode),
                                      ),
                                    )
                                  },
                                  child: Text("Lab Reports",
                                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16,)),//bodyTextStyle),
                                )),
                          ],
                        ),
                      )),
                  SizedBox(height: 5),
                  Container(
                    height: 50,
                    child: ToggleButtons(
                      borderColor: Colors.grey[300],
                      disabledColor: Colors.grey[300],
                      fillColor: Colors.orangeAccent,
                      borderWidth: 2,
                      selectedBorderColor: Colors.grey[300],
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      children: <Widget>[
                        Container(
                          width: (MediaQuery.of(context).size.width / 2) - 10,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            (globals.loginUserType == "PATIENT")
                                ? 'My Documents'
                                : "Patient's Documents",
                            style: bodyTextStyle,
                          ),
                        ),
                        Container(
                          width: (MediaQuery.of(context).size.width / 2) - 10,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'From Doctor/Hospital',
                            style: bodyTextStyle,
                          ),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < isSelected.length; i++) {
                            isSelected[i] = i == index;
                          }
                        });
                        if (index == 0) {
                          uploadedBy = "PATIENT";
                          loadDocuments();
                        } else {
                          uploadedBy = "OTHERS";
                          loadDocuments();
                        }
                      },
                      isSelected: isSelected,
                    ),
                  ),
                ])),
            SizedBox(
              height: 10,
            ),
            downloading
                ? Center(
                    child: Container(
                    height: 120.0,
                    width: 300.0,
                    alignment: Alignment.center,
                    child: Card(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            " Downloading File: $progressString ",
                            style: bodyTextStyle.copyWith(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ))
                : Expanded(
                    child: StreamBuilder(
                        stream: documents,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? GridView.count(
                                  primary: true,
                                  crossAxisCount: 2,
                                  childAspectRatio: 1,
                                  children: List.generate(
                                      snapshot.data.documents.length, (index) {
                                    return getStructuredGridCell(
                                        snapshot.data.documents[index], index);
                                  }),
                                )
                              : Container(
                                  child: Text("Loading..."),
                                );
                        }),
                  )
          ],
        ));
  }

  uploadDocument(FileType f) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UploadFile(patientCode: widget.patientCode, fileType: f),
      ),
    );
    //loadDocuments();
  }

  loadDocuments() {
    DatabaseMethods()
        .getPatientDocuments(widget.patientCode, uploadedBy,
            globals.loginUserType, globals.personCode)
        .then((val) {
      setState(() {
        documents = val;
      });
    });
  }

  Widget _buildAppBar() {
    Color appBarIconsColor = Color(0xFF212121);
    return AppBar(
      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back, color: appBarIconsColor),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
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
        child: Text('My Documents'.toUpperCase(),
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

class PDFScreen extends StatefulWidget {
  final String path;

  PDFScreen({Key key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final Color _backgroundColor = Color(0xFFf0f0f0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.BOTH,
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
        child: Text('My Documents'.toUpperCase(),
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
