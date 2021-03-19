import 'package:civideoconnectapp/utils/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class ShareFile extends StatefulWidget {
  final String patientCode;
  final DocumentSnapshot document;

  const ShareFile({Key key, this.patientCode, this.document}) : super(key: key);

  @override
  _ShareFileState createState() => _ShareFileState();
}

class _ShareFileState extends State<ShareFile>
    with SingleTickerProviderStateMixin {
  List<PatientAppointmentDoctorList> doctorList =
      List<PatientAppointmentDoctorList>();
  List<String> selectedDoctor = [];
  loadDoctorList() async {
    await DatabaseMethods()
        .getPatientAppointmentDoctorList(widget.patientCode)
        .then((val) {
      setState(() {
        doctorList = val;
      });
    });
    setState(() {
      if (widget.document.data["sharedTo"] != null)
        selectedDoctor = List<String>.from(widget.document.data["sharedTo"]);
      ;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDoctorList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Share File"),
          actions: <Widget>[
            RaisedButton.icon(
              onPressed: () {
                updateShareDocument();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              label: Text(
                'Update',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ),
              textColor: Colors.white,
              splashColor: Theme.of(context).accentColor,
              color: Theme.of(context).primaryColor,
            )
          ],
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: new Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Center(child: CircularProgressIndicator()),
                    Center(
                        child: (widget.document.data["documentType"] == "image")
                            ? FadeInImage.memoryNetwork(
                                width: 100,
                                height: 100,
                                placeholder: kTransparentImage,
                                image: widget.document.data["documentURL"],
                                fit: BoxFit.fitWidth,
                              )
                            : getfileIcon(
                                widget.document.data["documentName"]
                                    .split(".")
                                    .last,
                                widget.document.data["documentCategory"])),
                  ],
                )),
            Text(widget.document.data["documentTitle"]),
            Text(
                "${DateFormat("dd MMM yyyy").format(widget.document.data["documentDate"].toDate())}"),
            (selectedDoctor.length > 0)
                ? Text(
                    "Document shared with ${selectedDoctor.length} doctor(s)")
                : (doctorList.length > 0)
                    ? Text("Document is not shared with anyone")
                    : Container(),
            Expanded(
                child: ListView.builder(
              itemCount: doctorList.length,
              itemBuilder: (BuildContext context, int i) => GestureDetector(
                onLongPress: () {
                  selectDoctor(doctorList[i]);
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Theme.of(context).primaryColor),
                      color:
                          selectedDoctor.contains("${doctorList[i].doctorCode}")
                              ? Theme.of(context).primaryColor
                              : Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(doctorList[i].doctorName,
                          style: TextStyle(fontSize: 15),
                          overflow: TextOverflow.fade),
                      GestureDetector(
                        onTap: () {
                          selectDoctor(doctorList[i]);
                        },
                        child: selectedDoctor
                                .contains("${doctorList[i].doctorCode}")
                            ? Icon(Icons.cancel)
                            : Icon(Icons.arrow_forward),
                      )
                    ],
                  ),
                ),
              ),
            ))
          ],
        ));
  }

  updateShareDocument() async {
    await DatabaseMethods().updateSharedocument(
        widget.patientCode, widget.document.documentID, selectedDoctor);
    Navigator.pop(context);
  }

  selectDoctor(doc) {
    setState(() {
      if (selectedDoctor.contains("${doc.doctorCode}") == false)
        selectedDoctor.add("${doc.doctorCode}");
      else
        selectedDoctor.remove("${doc.doctorCode}");
    });
  }

  getfileIcon(ext, category) {
    Image img;

    if (category == "EPRESCRIPTION")
      img = Image.asset(
        'assets/images/eprescription.jpg',
      );
    else if (ext == "pdf")
      img = Image.asset(
        'assets/images/PDFFile.png',
      );
    else {
      img = Image.asset(
        'assets/images/documentFile.jpg',
      );
    }

    return Container(child: img);
  }
}
