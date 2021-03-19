// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:civideoconnectapp/src/pages/UploadFile.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:civideoconnectapp/globals.dart' as globals;
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:unicorndial/unicorndial.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;
// import 'package:civideoconnectapp/src/utils/DocDatabaseUtil.dart';
// import 'package:civideoconnectapp/data_models/filedata.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:transparent_image/transparent_image.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:civideoconnectapp/src/pages/ViewImage.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:dio/dio.dart';
// import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

// class ViewDocuments extends StatefulWidget {
//   final String patientCode;

//   const ViewDocuments({Key key, this.patientCode}) : super(key: key);

//   @override
//   _ViewDocumentsState createState() => _ViewDocumentsState();
// }

// class _ViewDocumentsState extends State<ViewDocuments>
//     with SingleTickerProviderStateMixin {
//   List<AppointmentDetails> apptList = List<AppointmentDetails>();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       new GlobalKey<RefreshIndicatorState>();
//   DocDatabaseUtil docDatabase;
//   List<FileData> files = new List();
//   List<FileData> filesOther = new List();

//   TabController _tabController;

//   final List<Tab> tabs = <Tab>[
//     new Tab(
//         text: (globals.loginUserType == "PATIENT")
//             ? "My Documents"
//             : "Patient's Documents"),
//     new Tab(text: "Uploaded by Doctor/Hospital")
//   ];

//   final ImagePicker picker = ImagePicker();
//   var itemRef;
//   bool downloading = false;
//   double download = 0.0;
//   File downloadFileName;
//   String downloadingStr = "";
//   String progressString = '0';

//   @override
//   void initState() {
//     super.initState();
//     docDatabase = DocDatabaseUtil();
//     docDatabase.initState();
//     _tabController = new TabController(vsync: this, length: tabs.length);
//     // firebaseDatabase
//     //     .ref()
//     //     .child("21ci")
//     //     .child("Appointments")
//     //     .child(widget.resourceAllocNumber)
//     //     .onChildAdded
//     //     .listen(_updateList);
//     loadDocuments();
//   }

//   // _updateList(Event event) {
//   //   setState(() {
//   //     files.add(new FileData.fromSnapshot(event.snapshot));
//   //   });
//   // }
//   DateTime convertToDate(String input) {
//     try {
//       var d = DateTime.parse(input);
//       return d;
//     } catch (e) {
//       return null;
//     }
//   }

//   loadDocuments() async {
//     files.clear();
//     itemRef = await docDatabase.getDocuments(widget.patientCode);
//     itemRef.once().then((DataSnapshot snapshot) {
//       Map<dynamic, dynamic> values = snapshot.value;
//       values.forEach((key, values) {
//         setState(() {
//           if (values["source"] == "PATIENT") {
//             files.add(new FileData(
//                 key,
//                 widget.patientCode,
//                 values["name"],
//                 values["file"],
//                 values["fileType"],
//                 values["nameCustom"],
//                 convertToDate(values["documentDate"]),
//                 convertToDate(values["uploadDate"]),
//                 values["source"]));
//           } else {
//             filesOther.add(new FileData(
//                 key,
//                 widget.patientCode,
//                 values["name"],
//                 values["file"],
//                 values["fileType"],
//                 values["nameCustom"],
//                 convertToDate(values["documentDate"]),
//                 convertToDate(values["uploadDate"]),
//                 values["source"]));
//           }
//         });
//       });
//     });
//   }

//   // _updateList(Event event) {
//   //   setState(() {
//   //     files.add(new FileData.fromSnapshot(event.snapshot));
//   //   });
//   // }

//   Container getStructuredGridCell(FileData file) {
//     return Container(
//       child: GestureDetector(
//         onTap: () {
//           openFile(file);
//         },
//         child: new Container(
//           margin: EdgeInsets.all(5.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//             boxShadow: <BoxShadow>[
//               BoxShadow(
//                 offset: Offset(4, 4),
//                 blurRadius: 5,
//                 color: Colors.white70,
//               )
//             ],
//           ),
//           child: ClipRRect(
//               borderRadius: BorderRadius.all(Radius.circular(5.0)),
//               child: Stack(
//                 children: <Widget>[
//                   Center(child: CircularProgressIndicator()),
//                   Center(
//                       child: (file.fileType == "image")
//                           ? FadeInImage.memoryNetwork(
//                               //width: 150,
//                               //height: 150,
//                               placeholder: kTransparentImage,
//                               image: file.picFile,
//                               fit: BoxFit.fitWidth,
//                             )
//                           : getfileIcon(file.name.split(".").last)),
//                   Positioned(
//                     bottom: 0.0,
//                     left: 0.0,
//                     right: 0.0,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Color.fromARGB(200, 0, 0, 0),
//                             Color.fromARGB(0, 0, 0, 0)
//                           ],
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                         ),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                           vertical: 10.0, horizontal: 20.0),
//                       child: Column(
//                         children: <Widget>[
//                           Text(
//                             "${file.nameCustom}",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20.0,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                           Text(
//                             "${DateFormat("dd").format(file.documentDate)} ${DateFormat("MMM").format(file.documentDate)} ${DateFormat("yyyy").format(file.documentDate)}",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10.0,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )),
//         ),
//       ),
//     );
//     // Card(
//     //   child: Stack(
//     //     children: <Widget>[
//     //       Center(child: CircularProgressIndicator()),
//     //       Center(
//     //         child: (file.fileType == "image")
//     //             ? GestureDetector(
//     //                 onTap: () {
//     //                   openFile(file);
//     //                 },
//     //                 child: Container(
//     //                   //width: 100,
//     //                   //height: 100,
//     //                   margin: EdgeInsets.only(
//     //                       left: 10, right: 10, bottom: 10, top: 10),
//     //                   decoration: BoxDecoration(
//     //                     borderRadius: BorderRadius.all(Radius.circular(10)),
//     //                     boxShadow: <BoxShadow>[
//     //                       BoxShadow(
//     //                         offset: Offset(4, 4),
//     //                         blurRadius: 10,
//     //                         color: Colors.black.withOpacity(.8),
//     //                       )
//     //                     ],
//     //                   ),
//     //                   child: Column(
//     //                     mainAxisSize: MainAxisSize.min,
//     //                     children: <Widget>[
//     //                       FadeInImage.memoryNetwork(
//     //                         placeholder: kTransparentImage,
//     //                         image: file.picFile,
//     //                         fit: BoxFit.cover,
//     //                       ),
//     //                       //Text(file.name)
//     //                     ],
//     //                   ),
//     //                 ),
//     //               )
//     //             : GestureDetector(
//     //                 onTap: () {
//     //                   openFile(file);
//     //                 },
//     //                 child: Container(
//     //                   // width: 200,
//     //                   // height: 200,
//     //                   color: Colors.white,
//     //                   child: getfileIcon(file.name.split(".").last),
//     //                 ),
//     //               ),
//     //       ),
//     //     ],
//     //   ),
//     // );
//   }

//   getfileIcon(ext) {
//     if (ext == "pdf")
//       return Image.asset(
//         'assets/images/PDFFile.png',
//       );
//     else {
//       return Image.asset(
//         'assets/images/documentFile.jpg',
//       );
//     }
//   }

//   openFile(FileData file) async {
//     if (file.fileType == "image") {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ViewImage(file: file),
//         ),
//       );
//     } else {
//       //   createFileOfPdfUrl(file.picFile).then((f) {
//       //   setState(() {
//       //     Navigator.push(
//       //                     context,
//       //                     MaterialPageRoute(
//       //                       builder: (context) => PDFScreen(path: f.path),
//       //                     ),
//       //                   );
//       //   });
//       // });

//       downloadFile(file.picFile);
//     }
//   }

//   Future<void> downloadFile(url) async {
//     Dio dio = Dio();
//     String filename;
//     try {
//       var dir = await getApplicationDocumentsDirectory();
//       filename = "${dir.path}/" + url.substring(url.lastIndexOf("/") + 1);

//       await dio.download(url, filename, onReceiveProgress: (rec, total) {
//         print("Rec: $rec , Total: $total");

//         setState(() {
//           downloading = true;
//           progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
//         });
//       });
//     } catch (e) {
//       print(e);
//     }

//     setState(() {
//       downloading = false;
//       progressString = "Completed";
//     });

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PDFScreen(path: filename),
//       ),
//     );
//     print("Download completed");
//   }

//   Future<File> createFileOfPdfUrl(String url) async {
//     Completer<File> completer = Completer();
//     print("Start download file from internet!");
//     try {
//       final filename = url.substring(url.lastIndexOf("/") + 1);
//       var request = await HttpClient().getUrl(Uri.parse(url));
//       var response = await request.close();
//       var bytes = await consolidateHttpClientResponseBytes(response);
//       var dir = await getApplicationDocumentsDirectory();
//       print("Download files");
//       print("${dir.path}/$filename");
//       File file = File("${dir.path}/$filename");

//       await file.writeAsBytes(bytes, flush: true);

//       completer.complete(file);
//     } catch (e) {
//       throw Exception('Error parsing asset file!');
//     }

//     return completer.future;
//   }

//   @override
//   Widget build(BuildContext context) {
//     var childButtons = List<UnicornButton>();
//     final List<Widget> children = <Widget>[];

//     // _tasks.forEach((StorageUploadTask task) {
//     //   final Widget tile = UploadTaskListTile(
//     //     task: task,
//     //     onDismissed: () => setState(() => _tasks.remove(task)),
//     //     onDownload: () => downloadFile(task.lastSnapshot.ref),
//     //   );
//     //   children.add(tile);
//     // });

//     childButtons.add(UnicornButton(
//         hasLabel: true,
//         labelText: "Camera",
//         currentButton: FloatingActionButton(
//           heroTag: "Camera",
//           backgroundColor: Colors.redAccent,
//           mini: true,
//           child: Icon(Icons.camera),
//           onPressed: () {
//             uploadDocument(FileType.media);
//           },
//         )));
//     childButtons.add(UnicornButton(
//         hasLabel: true,
//         labelText: "Image",
//         currentButton: FloatingActionButton(
//           heroTag: "Image",
//           backgroundColor: Colors.redAccent,
//           mini: true,
//           child: Icon(Icons.image),
//           onPressed: () {
//             uploadDocument(FileType.image);
//           },
//         )));

//     childButtons.add(UnicornButton(
//         hasLabel: true,
//         labelText: "PDF",
//         currentButton: FloatingActionButton(
//           heroTag: "PDF",
//           backgroundColor: Colors.redAccent,
//           mini: true,
//           child: Icon(Icons.file_upload),
//           onPressed: () {
//             uploadDocument(FileType.any);
//           },
//         )));
//     return Scaffold(
//         floatingActionButton: UnicornDialer(
//             backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
//             parentButtonBackground: Theme.of(context).accentColor,
//             orientation: UnicornOrientation.VERTICAL,
//             parentButton: Icon(Icons.add),
//             childButtons: childButtons),
//         appBar: AppBar(
//           title: Text("Documents"),
//           //backgroundColor: Theme.of(context).primaryColor,
//           bottom: new TabBar(
//             isScrollable: true,
//             unselectedLabelColor: Colors.white54,
//             labelColor: Colors.white,
//             indicatorSize: TabBarIndicatorSize.tab,
//             indicator: new BubbleTabIndicator(
//               indicatorHeight: 25.0,
//               indicatorColor: Theme.of(context).accentColor,
//               tabBarIndicatorSize: TabBarIndicatorSize.tab,
//             ),
//             tabs: tabs,
//             controller: _tabController,
//           ),
//           actions: <Widget>[],
//           //backgroundColor: Theme.of(context).primaryColor,
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: tabs.map((Tab tab) {
//             return new Column(
//               children: <Widget>[
//                 downloading
//                     ? Center(
//                         child: Container(
//                         height: 120.0,
//                         width: 300.0,
//                         alignment: Alignment.center,
//                         child: Card(
//                           color: Colors.black,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: <Widget>[
//                               CircularProgressIndicator(),
//                               SizedBox(
//                                 height: 20.0,
//                               ),
//                               Text(
//                                 " Downloading File: $progressString ",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ))
//                     : Expanded(
//                         child: GridView.count(
//                           primary: true,
//                           crossAxisCount: 2,
//                           childAspectRatio: 1,
//                           children: List.generate(
//                               (tab.text.contains("Uploaded"))
//                                   ? filesOther.length
//                                   : files.length, (index) {
//                             return getStructuredGridCell(
//                                 (tab.text.contains("Uploaded"))
//                                     ? filesOther[index]
//                                     : files[index]);
//                           }),
//                         ),
//                       )
//               ],
//             );
//           }).toList(),
//         ));
//   }

//   uploadDocument(FileType f) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             UploadFile(patientCode: widget.patientCode, fileType: f),
//       ),
//     );
//     loadDocuments();
//   }
// }

// class PDFScreen extends StatefulWidget {
//   final String path;

//   PDFScreen({Key key, this.path}) : super(key: key);

//   _PDFScreenState createState() => _PDFScreenState();
// }

// class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
//   final Completer<PDFViewController> _controller =
//       Completer<PDFViewController>();
//   int pages = 0;
//   int currentPage = 0;
//   bool isReady = false;
//   String errorMessage = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Document"),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.share),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Stack(
//         children: <Widget>[
//           PDFView(
//             filePath: widget.path,
//             enableSwipe: true,
//             swipeHorizontal: false,
//             autoSpacing: false,
//             pageFling: true,
//             defaultPage: currentPage,
//             fitPolicy: FitPolicy.BOTH,
//             onRender: (_pages) {
//               setState(() {
//                 pages = _pages;
//                 isReady = true;
//               });
//             },
//             onError: (error) {
//               setState(() {
//                 errorMessage = error.toString();
//               });
//               print(error.toString());
//             },
//             onPageError: (page, error) {
//               setState(() {
//                 errorMessage = '$page: ${error.toString()}';
//               });
//               print('$page: ${error.toString()}');
//             },
//             onViewCreated: (PDFViewController pdfViewController) {
//               _controller.complete(pdfViewController);
//             },
//             onPageChanged: (int page, int total) {
//               print('page change: $page/$total');
//               setState(() {
//                 currentPage = page;
//               });
//             },
//           ),
//           errorMessage.isEmpty
//               ? !isReady
//                   ? Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : Container()
//               : Center(
//                   child: Text(errorMessage),
//                 )
//         ],
//       ),
//       floatingActionButton: FutureBuilder<PDFViewController>(
//         future: _controller.future,
//         builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
//           if (snapshot.hasData) {
//             return FloatingActionButton.extended(
//               label: Text("Page $currentPage of $pages)"),
//               onPressed: () async {
//                 await snapshot.data.setPage(pages ~/ 2);
//               },
//             );
//           }

//           return Container();
//         },
//       ),
//     );
//   }
// }
