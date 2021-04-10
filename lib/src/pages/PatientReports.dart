import 'dart:typed_data';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:civideoconnectapp/data_models/PatientReportServices.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter_share/flutter_share.dart';
import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:permission_handler/permission_handler.dart';

//Uint8List _bytesImage;
//String ImageData;
//Uint8List _bytesImage=Base64Decoder().convert(ImageData);

final Color _backgroundColor = Color(0xFFf0f0f0);

class PatientReports extends StatefulWidget {
  final String patientCode;

  const PatientReports({Key key, this.patientCode}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PatientReportsState();
}

class _PatientReportsState extends State<PatientReports> {
  bool issearching = false;
  Color appBarIconsColor = Color(0xFF212121);
  Widget cusSearchBar;
  Widget cusSearchBarDefault;
  Icon cusIcon;
  List<PatientReportServices> _notes = List<PatientReportServices>();
  List<PatientReportServices> filterednotes = List<PatientReportServices>();

  Future<List<PatientReportServices>> apiData() async {
    String url = "${globals.apiHostingURLBVH}/MobileAppPatient/GetPatientReports";
    var response = await http.post(url, body: {
      "PatientCode": widget.patientCode,
      "DateType": "ALL",
    });
    var notes = List<PatientReportServices>();
    if (response.statusCode == 200) {
      var notesJson = json.decode(response.body)['patientReports'];
      for (var notejson in notesJson) {
        notes.add(PatientReportServices.fromJson(notejson));
      }
    }
    return notes;
  }

//String _mySelection;
//Widget txt;
  // List data = List();
  // apipdfData() async {
  //   String url = "${globals.apiHostingURL}/Report/mapp_ViewAttachment";
  //   var response = await http.post(url, body: {
  //     "type": "REPORT",
  //     "serviceRenderNumber": "ABCRR200000014",
  //   });
  //   var extractdata = jsonDecode(response.body)['Attachment'];
  //   setState(() {
  //     data = extractdata;
  //     // txt=Text(data);
  //   });
  //   print(extractdata);
  // }

//Uint8List.fromList(filterednotes);
//String ImageData;
//Uint8List _bytesImage=Base64Decoder().convert(ImageData);

/*Future<List<DocParameter>> apiData() async {
  String url = "http://7b68e60e.ngrok.io/api/DefaultAPI/GetDocDetails";
  var response = await http.get(url);
  var notes = List<DocParameter>();
  if (response.statusCode == 200) {
    var notesJson = json.decode(response.body);
   //  ImageData = base64.encode(response.bodyBytes);
    for (var notejson in notesJson) {
      notes.add(DocParameter.fromJson(notejson));
    }
  }
  return notes;
}*/
  @override
  void initState() {

    apiData().then((value) {
      setState(() {
        _notes.addAll(value);
        filterednotes.addAll(value);
      });
    });

    cusIcon = Icon(Icons.search, color: appBarIconsColor);

    cusSearchBarDefault = Text('Patient Reports'.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          letterSpacing: 0.5,
          color: appBarIconsColor,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.bold,
        ));
    cusSearchBar = cusSearchBarDefault;

    //apipdfData();
    super.initState();
  }
  void getPermission() async{
    print("getPermission");
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  @override
  Widget build(BuildContext context) {
    /* if (ImageData == null)
      return new Container();
    Uint8List bytes = base64.decode(ImageData);
 */
    return Scaffold(
        appBar: _buildAppBar(),
        body: ListView.builder(
            itemCount: filterednotes.length,
            itemBuilder: (BuildContext context, int i) => ListTile(
                // leading: Container(

                //     decoration: BoxDecoration(
                //       border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                //       color: Colors.white,
                //       shape: BoxShape.circle,
                //     ),
                //     child: Icon(Icons.play_arrow)),
                title: Text(
                  filterednotes[i].ServiceName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    //color: Theme.of(context).primaryColor
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy')
                          .format(filterednotes[i].ServiceRequestDate),
                      style: TextStyle(
                          fontSize: 14.0, color: Colors.grey.shade700),
                    ),
                    SizedBox(width: 20,),
                    Text(
                      filterednotes[i].ServiceStatus == "Stage Authentication1"
                          ? "Report is Ready"
                          : filterednotes[i].ServiceStatus,
                      style: TextStyle(
                          fontSize: 14.0, color: Colors.grey.shade700),
                    ),
                    ]),
                    Text(filterednotes[i].DoctorName,
                      style: TextStyle(
                          fontSize: 14.0, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                trailing: Container(
                    child:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 1),
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      constraints: BoxConstraints.tight(Size.fromWidth(50)),
                      icon: Image.asset(
                        'assets/images/PDFFile.png',
                        fit: BoxFit.cover,
                      ),
                      tooltip: "Chat",
                      color: Colors.white,
                      onPressed: () =>
                          {showPDF(filterednotes[i].ServiceRenderNumber)},
                    ),
                  ),
                          SizedBox(width: 10,),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor, width: 1),
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              constraints: BoxConstraints.tight(Size.fromWidth(50)),
//                              icon: Image.asset(
//                                'assets/images/PDFFile.png',
//                                fit: BoxFit.cover,
//                              ),
                              icon: Icon(Icons.file_download),
                              tooltip: "Chat",
                              color: Colors.white,
                              onPressed: () =>
                              {
                              data(filterednotes[i].ServiceRenderNumber)
                              },
                            ),
                          ),


                ]),
                )
            ))
        // itemBuilder: (context, index) {
        //   return new GestureDetector(
        //     child:

        //     Container(
        //       child: Card(
        //           elevation: 10.0,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(15.0),
        //           ),
        //           child: Padding(
        //             padding: const EdgeInsets.only(
        //                 top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
        //             child: Row(children: <Widget>[

        //               Column(

        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: <Widget>[
        //                   SizedBox(width: 100),
        //                   Text(
        //                     filterednotes[index].ServiceName,
        //                     style: TextStyle(
        //                         fontSize: 18.0,
        //                         fontWeight: FontWeight.bold,
        //                         color: Colors.purple),
        //                   ),
        //                   Text(
        //                     filterednotes[index].ServiceRenderDate,
        //                     style: TextStyle(
        //                         fontSize: 14.0, color: Colors.grey.shade700),
        //                   ),
        //                 ],
        //               ),

        //               Column(
        //                 children: <Widget>[
        //                   IconButton(
        //                     icon: Image.asset(
        //                       'assets/images/PDFFile.png',
        //                       fit: BoxFit.cover,
        //                     ),
        //                     onPressed: () {
        //                       showPDF(filterednotes[index].ServiceRenderNumber);
        //                     },
        //                   ),
        //                 ],
        //               )
        //             ]),
        //           )),
        //     ),
        //     onTap: () {},
        //   );
        // },

        //) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Future<String> data(serviceRendrNumber) async {
    print("downlod");
    getPermission();

    File file;
    String url = "${globals.apiHostingURLBVH}/MobileAppPatient/ViewAttachment";
    //String url = "http://43.252.88.147/RNSMobAppAPI/Report/mapp_ViewAttachment";
    http.Response response = await http.post(url, body: {
      "serviceRenderNumber": "$serviceRendrNumber",
      "type": "REPORT",
    }
    );
    var extractdata = jsonDecode(response.body)["Attachment"];
    if (extractdata != null && extractdata[0] != null) {
      var bytes = base64Decode(extractdata[0]['FileContent']);
//      var dir = await getDownloadsDirectory();
var dir1 =  await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
//       var dir = await getApplicationDocumentsDirectory();
      // file = File("${dir}/${extractdata[0]['FileName']}.pdf");
//      file = File("${dir}/${getRandomString(10)}.pdf");
//      //file = File("${dir}/${extractdata[0]['FileName']}");

      var dir = await getApplicationDocumentsDirectory();

      print(dir1);
      print(dir.path);
      file = File("${dir1}/${globals.personName}_${extractdata[0]['FileName']}.pdf");
//      file = File("${dir1}/1.pdf");
//       await file.writeAsBytes(bytes);
      File f1=await file.writeAsBytes(bytes);
      if(f1 != null){
        print('downlod successfully..!');
//                 Scaffold.of(context).showSnackBar(SnackBar(
//                      content: Text('Download Successfully..!'),
//                      duration: Duration(seconds: 3),
//                    ));
        Fluttertoast.showToast(
            msg: "Downloaded Successfully..!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

  showPDF(serviceRendrNumber) async {
    File file;
    String url = "${globals.apiHostingURLBVH}/MobileAppPatient/ViewAttachment";
    try {
      //var data = await http.get(url);
      var response = await http.post(url, body: {
        "serviceRenderNumber": "$serviceRendrNumber",
        "type": "REPORT",
      });

      var extractdata = jsonDecode(response.body)['Attachment'];
      if (extractdata != null && extractdata[0] != null) {
        var bytes = base64Decode(extractdata[0]['FileContent']);
        var dir = await getApplicationDocumentsDirectory();
        file = File(
            "${dir.path}/${DateFormat("ddMMyyyyhhmm").format(DateTime.now())}.pdf");

        await file.writeAsBytes(bytes);
      }
    } catch (e) {
      //throw Exception("Error opening url file");
    }
    if (file != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFScreen(path: file.path),
        ),
      );
    }
  }

  onTapped(int position) {
    var a = _notes[position].ServiceName;
    print("Name:" + a);

    var b = _notes[position].ServiceRenderDate;

    Widget okButton = FlatButton(
      child: Text(
        "OK",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    var alertDialog = Theme(
        data: Theme.of(context)
            .copyWith(dialogBackgroundColor: Colors.orangeAccent),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Report Details!",
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          contentPadding: EdgeInsets.all(30.0),
          content: Text(
            'Name:$a, \REnder Date:$b  '

            //"Name:"+a
            ,
            maxLines: 100,
            style: TextStyle(fontSize: 22.0, color: Colors.white),
          ),
          actions: [
            okButton,
          ],
        ));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
    print('Card $position tapped');
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
        new IconButton(
          onPressed: () {
            setState(() {
              if (this.cusIcon.icon == Icons.search) {
                this.issearching = true;
                filterednotes = _notes;
                this.cusIcon = Icon(
                  Icons.cancel,
                  color: Colors.black,
                );
                this.cusSearchBar = TextField(
                  textInputAction: TextInputAction.go,
                  autofocus: true,
                  decoration: new InputDecoration(
                    hintText: 'Search here...',
                  ),
                  onChanged: (string) {
                    setState(() {
                      filterednotes = _notes
                          .where((n) => (n.ServiceName.toLowerCase()
                              .contains(string.toLowerCase())))
                          .toList();
                    });
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                );
              } else {
                this.issearching = false;
                filterednotes = _notes;
                this.cusIcon = Icon(Icons.search, color: Colors.black);
                this.cusSearchBar = cusSearchBarDefault;
              }
            });
          },
          icon: cusIcon,
        ),
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
        child: this.cusSearchBar,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

    // shareFile() async {
    //   await FlutterShare.shareFile(
    //     title: 'Example share',
    //     text: 'Example share text',
    //     filePath: widget.path,
    //   );
    // }
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
        child: Text('Document'.toUpperCase(),
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
