import 'package:civideoconnectapp/utils/Database.dart';
import 'package:civideoconnectapp/utils/hospitallogo.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  Service(this.serviceCode, this.serviceName);

  final String serviceCode;
  final String serviceName;
}

Future<File> reportView(context, DocumentSnapshot appt) async {
  final Document pdf = Document();
  EPrescription ePrescription;
  List<List<String>> medicineRx = new List();
  List<List<String>> testRx = new List();

  await DatabaseMethods()
      .getEPrescription(appt.data["appointmentNumber"])
      .then((val) {
    ePrescription = val[0];
  });

  await DatabaseMethods()
      .getEPrescriptionMedicineRx(appt.data["appointmentNumber"])
      .then((val) {
    medicineRx = val;
  });

  await DatabaseMethods()
      .getEPrescriptionTestRx(appt.data["appointmentNumber"])
      .then((val) {
    testRx = val;
  });

  pdf.addPage(MultiPage(
      pageFormat:
          PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Column(children: <Widget>[
          Header(
              level: 0,
              child: Column(children: <Widget>[
                //HospitalLogo(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('e-Prescription', textScaleFactor: 2),
                      PdfLogo()
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(appt.data["doctorName"],
                          textScaleFactor: 1,
                          style: TextStyle(color: PdfColors.indigo)),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(appt.data["departmentName"],
                          textScaleFactor: 1,
                          style: TextStyle(color: PdfColors.grey)),
                    ])
              ])),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  appt.data["patientName"],
                  style: TextStyle(
                      fontSize: 25.0,
                      color: PdfColors.indigo,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat("dd MMM yyyy")
                      .format(appt.data["apptDate"].toDate()),
                  style: TextStyle(
                      fontSize: 15.0,
                      //color: globals.appTextColor,
                      fontWeight: FontWeight.bold),
                )
              ]),
        ]);
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (Context context) => <Widget>[
            Header(
                level: 0,
                child: Column(children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('e-Prescription', textScaleFactor: 2),
                        PdfLogo()
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(appt.data["doctorName"],
                            textScaleFactor: 2,
                            style: TextStyle(color: PdfColors.indigo)),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(appt.data["departmentName"],
                            textScaleFactor: 2,
                            style: TextStyle(color: PdfColors.grey)),
                      ])
                ])),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    appt.data["patientName"],
                    style: TextStyle(
                        fontSize: 25.0,
                        color: PdfColors.indigo,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat("dd MMM yyyy")
                        .format(appt.data["apptDate"].toDate()),
                    style: TextStyle(
                        fontSize: 15.0,
                        //color: globals.appTextColor,
                        fontWeight: FontWeight.bold),
                  )
                ]),
            Text("Patient Code: ${appt.data["patientCode"]}"),
            Text("${appt.data["patientAge"]}/${appt.data["patientGender"]}"),
            Header(
                level: 1,
                text: 'History',
                textStyle: TextStyle(color: PdfColors.indigo)),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Paragraph(text: ePrescription.history)),
            Header(
                level: 1,
                text: 'Diagnosis',
                textStyle: TextStyle(color: PdfColors.indigo)),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Paragraph(text: ePrescription.diagnosis)),
            Header(
                level: 1,
                text: 'Medication',
                textStyle: TextStyle(color: PdfColors.indigo)),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: medicineRx.length == 0
                    ? Text("N/A")
                    : Table.fromTextArray(context: context, data: medicineRx)),
            Header(
                level: 1,
                text: 'Tests',
                textStyle: TextStyle(color: PdfColors.indigo)),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: testRx.length == 0
                    ? Text("N/A")
                    : Table.fromTextArray(context: context, data: testRx)),
            Header(
                level: 1,
                text: 'Notes',
                textStyle: TextStyle(color: PdfColors.indigo)),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Paragraph(text: ePrescription.notes)),
            Padding(padding: const EdgeInsets.all(10)),
            Header(
                level: 1,
                text: 'Follow Up',
                textStyle: TextStyle(color: PdfColors.indigo)),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Paragraph(
                    text: DateFormat("dd MMM yyyy")
                        .format(ePrescription.followupDate))),
          ]));
  //save PDF\

  final dirList = await _getExternalStoragePath();

  String filename = "${dirList[0].path}/${appt.data["appointmentNumber"]}.pdf";

  File file = File(filename);
  await file.writeAsBytes(pdf.save());

  return file;
}

Future<List<Directory>> _getExternalStoragePath() {
  return getExternalStorageDirectories(type: StorageDirectory.documents);
}
