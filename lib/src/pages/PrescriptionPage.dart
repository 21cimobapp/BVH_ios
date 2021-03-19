import 'dart:async';
import 'package:civideoconnectapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:civideoconnectapp/globals.dart' as globals;
import 'package:civideoconnectapp/utils/Database.dart';
import 'dart:io';
import 'package:civideoconnectapp/src/pages/GeneratePrescription.dart';
import 'package:civideoconnectapp/src/pages/ViewEPrescription.dart';

class PrescriptionPage extends StatefulWidget {
  final DocumentSnapshot appt;

  /// Creates a call page with given channel name.
  const PrescriptionPage({Key key, this.appt}) : super(key: key);

  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  DocumentSnapshot appt;

  EPrescription ePrescription;
  DateTime rxFollowupDate = DateTime.now();
  DateTime rxPrescriptionDate = DateTime.now();
  String appTitle = "e-Prescription";
  bool isPDFGenerate = false;
  bool isShowMedicineAdd = false;
  bool isShowTestAdd = false;
  bool isShowRadTestAdd = false;
  List<bool> medFrequency;
  List<bool> medTiming;
  RxMedicine rxMedicine;
  List<RxMedicine> rxMedicineList = [];

  RxTest rxTest;
  List<RxTest> rxTestList = [];

  final TextEditingController rxDiagnosis = new TextEditingController();
  final TextEditingController rxHistory = new TextEditingController();
  final TextEditingController rxNotes = new TextEditingController();
  final TextEditingController rxName = new TextEditingController();
  final TextEditingController rxDosage = new TextEditingController();
  final TextEditingController rxDuration = new TextEditingController();
  final TextEditingController rxRemark = new TextEditingController();

  final TextEditingController rxTestName = new TextEditingController();
  final TextEditingController rxTestInstructions = new TextEditingController();
  String rxTestType = "";

  List<Service> labServices = <Service>[
    Service("CBC", "Complete Blood Count"),
    Service("FAST", "Sugar Fasting"),
    Service("PP", "Sugar PP"),
    Service("VB12", "Vitamin B12"),
    Service("CBC", "Complete Blood Count"),
    Service("FAST", "Sugar Fasting"),
    Service("PP", "Sugar PP"),
    Service("VB12", "Vitamin B12"),
    Service("CBC", "Complete Blood Count"),
    Service("FAST", "Sugar Fasting"),
    Service("PP", "Sugar PP"),
    Service("VB12", "Vitamin B12"),
    Service("CBC", "Complete Blood Count"),
    Service("FAST", "Sugar Fasting"),
    Service("PP", "Sugar PP"),
    Service("VB12", "Vitamin B12"),
  ];

  Service _selectedLABService;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    //initializeRTC();
    medFrequency = [false, false, false, false];
    medTiming = [false, false];
    getEPrescription(widget.appt.data["appointmentNumber"]);
  }

  getEPrescription(appointmentNumber) async {
    await DatabaseMethods().getEPrescription(appointmentNumber).then((val) {
      setState(() {
        if (val.length > 0) ePrescription = val[0];
      });
    });
    if (ePrescription != null) {
      rxPrescriptionDate = ePrescription.prescriptionDate;
      rxDiagnosis.text = ePrescription.diagnosis;
      rxHistory.text = ePrescription.history;

      rxNotes.text = ePrescription.notes;
      rxFollowupDate = ePrescription.followupDate;

      if (ePrescription.followupDate.difference(DateTime.now()).inSeconds < 0) {
        rxFollowupDate = DateTime.now();
      }
      await DatabaseMethods()
          .getEPrescriptionMedicine(appointmentNumber)
          .then((val) {
        setState(() {
          rxMedicineList = val;
        });
      });

      await DatabaseMethods()
          .getEPrescriptionTest(appointmentNumber)
          .then((val) {
        setState(() {
          rxTestList = val;
        });
      });
    }
  }

  /// Video layout wrapper
  Widget _viewRows() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 10, top: 10),
            //padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  //height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),

                  child: Row(
                    children: <Widget>[
                      Column(children: <Widget>[
                        MyCircleAvatar(
                          imgUrl: "",
                          personType: "PATIENT",
                          size: 80,
                        ),
                        SizedBox(
                          width: 20,
                        )
                      ]),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.appt.data["patientName"],
                              style: TextStyle(
                                  fontSize: 20.0,
                                  //color: globals.appTextColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(
                            height: 10.0,
                            indent: 5.0,
                            color: Colors.black87,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Age/Gender: ${widget.appt.data["patientAge"]}/${widget.appt.data["patientGender"]}",
                              style: TextStyle(
                                fontSize: 15.0,
                                //color: globals.appTextColor,
                                //fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(child: precriptionDetails())
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget precriptionDetails() {
    return Container(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Appointment",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                      "${convertToDateString(widget.appt.data["apptDate"])}, ${widget.appt.data["slotName"]}"),
                ],
              ),
            ),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Upload prescription",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RawMaterialButton(
                    onPressed: () {},
                    child: Text("Select Image"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    elevation: 2.0,
                    //fillColor: Theme.of(context).accentColor,
                    padding: const EdgeInsets.all(10.0),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "History",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              // hack textfield height
              padding: EdgeInsets.only(bottom: 40.0),
              child: TextField(
                controller: rxHistory,
                decoration: InputDecoration(
                  hintText: "Known Diagnosis",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Text(
              "Diagnosis",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              // hack textfield height
              padding: EdgeInsets.only(bottom: 40.0),
              child: TextField(
                controller: rxDiagnosis,
                decoration: InputDecoration(
                  hintText: "Current Diagnosis",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Medicine",
                  style: TextStyle(fontSize: 20),
                ),
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      rxName.clear();
                      rxDosage.clear();
                      rxDuration.clear();
                      rxRemark.clear();

                      medFrequency = [false, false, false, false];
                      medTiming = [false, false];

                      //isShowMedicineAdd = true;

                      _showMedicine(context);
                    });
                  },
                  child: Text("Add"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  //fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(5.0),
                )
              ],
            ),
            isShowMedicineAdd
                ? Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Add Medicine"),
                        Container(
                            child: TextFormField(
                                controller: rxName,
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.image),
                                  hintText: '',
                                  labelText: 'Medicine Name',
                                ))),
                        Container(
                            child: TextFormField(
                                controller: rxDosage,
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.timer),
                                  hintText: '',
                                  labelText: 'Dosage',
                                ))),
                        ToggleButtons(
                          borderColor: Colors.grey[200],
                          fillColor: Theme.of(context).accentColor,
                          borderWidth: 2,
                          selectedBorderColor: Colors.grey[200],
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Morning',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Afternoon',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Evening',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Night',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < medFrequency.length; i++) {
                                if (i == index) {
                                  if (medFrequency[i] == true) {
                                    medFrequency[i] = false;
                                  } else
                                    medFrequency[i] = true;
                                }
                              }
                            });
                          },
                          isSelected: medFrequency,
                        ),
                        ToggleButtons(
                          borderColor: Colors.grey[200],
                          fillColor: Theme.of(context).accentColor,
                          borderWidth: 2,
                          selectedBorderColor: Colors.grey[200],
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Before food',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'After food',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < medTiming.length; i++) {
                                medTiming[i] = i == index;
                              }
                            });
                          },
                          isSelected: medTiming,
                        ),
                        Container(
                            child: TextFormField(
                                controller: rxDuration,
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.confirmation_number),
                                  hintText: '',
                                  labelText: 'Duration (in days)',
                                ))),
                        Container(
                            child: TextFormField(
                                controller: rxRemark,
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.info),
                                  hintText: '',
                                  labelText: 'Additional Remark',
                                ))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () {
                                String rxFrequency =
                                    "${medFrequency[0] == true ? 1 : 0}-${medFrequency[1] == true ? 1 : 0}-${medFrequency[2] == true ? 1 : 0}-${medFrequency[3] == true ? 1 : 0}";
                                String rxtiming = medTiming[0] == true
                                    ? "BF"
                                    : medTiming[0] == true
                                        ? "AF"
                                        : "";

                                rxMedicine = new RxMedicine(
                                    name: rxName.text,
                                    dosage: rxDosage.text,
                                    frequency: rxFrequency,
                                    timing: rxtiming,
                                    duration: rxDuration.text,
                                    remark: rxRemark.text);

                                setState(() {
                                  rxMedicineList.add(rxMedicine);
                                  isShowMedicineAdd = false;
                                });
                              },
                              child: Text("Save"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              elevation: 2.0,
                              //fillColor: Theme.of(context).accentColor,
                              padding: const EdgeInsets.all(5.0),
                            ),
                            SizedBox(width: 20),
                            RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  isShowMedicineAdd = false;
                                });
                              },
                              child: Text("Cancel"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              elevation: 2.0,
                              //fillColor: Theme.of(context).accentColor,
                              padding: const EdgeInsets.all(5.0),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(),
            rxMedicineList.length > 0
                ? Container(
                    height: 150,
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: new ListView.builder(
                        //scrollDirection: Axis.horizontal,
                        itemCount: rxMedicineList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Container(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Medicine ${index + 1}",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15)),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          rxMedicineList.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                          child: Icon(
                                        Icons.delete,
                                      )),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(rxMedicineList[index].name,
                                          style: TextStyle(fontSize: 25)),
                                    ),
                                    SizedBox(width: 20),
                                    Container(
                                      child: Text(
                                          rxMedicineList[index].dosage == ""
                                              ? ""
                                              : "(${rxMedicineList[index].dosage})",
                                          style: TextStyle(fontSize: 15)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                          rxMedicineList[index].frequency,
                                          style: TextStyle(fontSize: 15)),
                                    ),
                                    SizedBox(width: 20),
                                    Container(
                                      child: Text(
                                          rxMedicineList[index].timing == "BF"
                                              ? "Before food"
                                              : "After Food",
                                          style: TextStyle(fontSize: 15)),
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                        "${rxMedicineList[index].duration} day(s)",
                                        style: TextStyle(fontSize: 15)),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text("Remark:",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15)),
                                    SizedBox(width: 20),
                                    Text(rxMedicineList[index].remark,
                                        style: TextStyle(fontSize: 15)),
                                  ],
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          );
                        }))
                : Container(child: Text("No Medicines")),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Tests",
                  style: TextStyle(fontSize: 20),
                ),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: () {
                        setState(() {
                          rxTestType = "LAB";
                          rxTestName.clear();
                          rxTestInstructions.clear();
                          isShowTestAdd = true;
                        });
                      },
                      child: Text("Lab Test"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.greenAccent)),
                      elevation: 2.0,
                      //fillColor: Theme.of(context).accentColor,
                      padding: const EdgeInsets.all(5.0),
                    ),
                    SizedBox(width: 20),
                    RawMaterialButton(
                      onPressed: () {
                        setState(() {
                          rxTestType = "RAD";
                          rxTestName.clear();
                          rxTestInstructions.clear();
                          isShowTestAdd = true;
                        });
                      },
                      child: Text("Radiology Test"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.blueAccent)),
                      elevation: 2.0,
                      //fillColor: Theme.of(context).accentColor,
                      padding: const EdgeInsets.all(5.0),
                    )
                  ],
                ),
              ],
            ),
            isShowTestAdd
                ? Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Add Test"),
                        Container(
                            child: TextFormField(
                                controller: rxTestName,
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.image),
                                  hintText: '',
                                  labelText: 'Test Name',
                                ))),
                        Container(
                            child: TextFormField(
                                controller: rxTestInstructions,
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.info),
                                  hintText: '',
                                  labelText: 'Instructions',
                                ))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () {
                                rxTest = new RxTest(
                                  name: rxTestName.text,
                                  type: rxTestType,
                                  instructions: rxTestInstructions.text,
                                );

                                setState(() {
                                  rxTestList.add(rxTest);
                                  isShowTestAdd = false;
                                });
                              },
                              child: Text("Save"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              elevation: 2.0,
                              //fillColor: Theme.of(context).accentColor,
                              padding: const EdgeInsets.all(5.0),
                            ),
                            SizedBox(width: 20),
                            RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  isShowTestAdd = false;
                                });
                              },
                              child: Text("Cancel"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              elevation: 2.0,
                              //fillColor: Theme.of(context).accentColor,
                              padding: const EdgeInsets.all(5.0),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(),
            rxTestList.length > 0
                ? Container(
                    height: 80,
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: new ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: rxTestList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            child: Chip(
                              label: Text(rxTestList[index].name),
                              backgroundColor: rxTestList[index].type == "LAB"
                                  ? Colors.greenAccent
                                  : Colors.blueAccent,
                              //deleteIcon: Icons.delete,
                              onDeleted: () {
                                setState(() {
                                  rxTestList.removeAt(index);
                                });
                              },
                            ),
                          );
                        }))
                : Container(child: Text("No Lab Tests")),
            SizedBox(
              height: 20,
            ),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            Text(
              "Notes",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              // hack textfield height
              padding: EdgeInsets.only(bottom: 40.0),
              child: TextField(
                controller: rxNotes,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "Enter Notes",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            Text(
              "Next Followup on",
              style: TextStyle(fontSize: 20),
            ),
            Row(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Text("..."),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  elevation: 2.0,
                  //fillColor: Theme.of(context).accentColor,
                  padding: const EdgeInsets.all(1.0),
                ),
                SizedBox(
                  width: 20,
                ),
                Text("${rxFollowupDate.toLocal()}".split(' ')[0]),
              ],
            ),
            Divider(
              height: 10.0,
              indent: 5.0,
              color: Colors.black87,
            ),
            Row(
              children: <Widget>[
                Switch(
                  value: isPDFGenerate,
                  onChanged: (value) {
                    setState(() {
                      isPDFGenerate = value;
                    });
                  },
                  activeTrackColor: Colors.grey[200],
                  activeColor: Theme.of(context).accentColor,
                ),
                Text(
                  "Save and generate e-Prescription in PDF.\nThis report will be shared to Patient",
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
            Container(
              alignment: Alignment.center,
              child: RawMaterialButton(
                onPressed: () {
                  savePrescription();
                },
                child: Text("save e-Prescription"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Theme.of(context).primaryColor)),
                elevation: 2.0,
                fillColor: Theme.of(context).accentColor,
                padding: const EdgeInsets.all(10.0),
              ),
            ),
          ],
        ));
  }

  _showMedicine(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2 -
                        250 // adjust values according to your need
                    ), // adjust values according to your need
                child: AlertDialog(
                    title: Text("Add Medicine"),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                            controller: rxName,
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.image),
                              hintText: '',
                              labelText: 'Medicine Name',
                            )),
                        TextFormField(
                            controller: rxDosage,
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.timer),
                              hintText: '',
                              labelText: 'Dosage',
                            )),
                        ToggleButtons(
                          borderColor: Colors.grey[200],
                          fillColor: Theme.of(context).accentColor,
                          borderWidth: 2,
                          selectedBorderColor: Colors.grey[200],
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'M',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'A',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'E',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'N',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < medFrequency.length; i++) {
                                if (i == index) {
                                  if (medFrequency[i] == true) {
                                    medFrequency[i] = false;
                                  } else
                                    medFrequency[i] = true;
                                }
                              }
                            });
                          },
                          isSelected: medFrequency,
                        ),
                        ToggleButtons(
                          borderColor: Colors.grey[200],
                          fillColor: Theme.of(context).accentColor,
                          borderWidth: 2,
                          selectedBorderColor: Colors.grey[200],
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Before food',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'After food',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < medTiming.length; i++) {
                                medTiming[i] = i == index;
                              }
                            });
                          },
                          isSelected: medTiming,
                        ),
                        TextFormField(
                            controller: rxDuration,
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.confirmation_number),
                              hintText: '',
                              labelText: 'Duration (in days)',
                            )),
                        TextFormField(
                            controller: rxRemark,
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.info),
                              hintText: '',
                              labelText: 'Additional Remark',
                            )),
                      ],
                    ),
                    actions: <Widget>[
                      RawMaterialButton(
                        onPressed: () {
                          String rxFrequency =
                              "${medFrequency[0] == true ? 1 : 0}-${medFrequency[1] == true ? 1 : 0}-${medFrequency[2] == true ? 1 : 0}-${medFrequency[3] == true ? 1 : 0}";
                          String rxtiming = medTiming[0] == true
                              ? "BF"
                              : medTiming[0] == true
                                  ? "AF"
                                  : "";

                          rxMedicine = new RxMedicine(
                              name: rxName.text,
                              dosage: rxDosage.text,
                              frequency: rxFrequency,
                              timing: rxtiming,
                              duration: rxDuration.text,
                              remark: rxRemark.text);

                          setState(() {
                            rxMedicineList.add(rxMedicine);
                          });
                          Navigator.pop(context);

                          setState(() {});
                        },
                        child: Text("Save"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        elevation: 2.0,
                        //fillColor: Theme.of(context).accentColor,
                        padding: const EdgeInsets.all(5.0),
                      ),
                      SizedBox(width: 20),
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        elevation: 2.0,
                        //fillColor: Theme.of(context).accentColor,
                        padding: const EdgeInsets.all(5.0),
                      )
                    ]));
          });
        });
  }

  savePrescription() async {
    Map<String, dynamic> ePrescription = {
      "prescriptionDate": DateTime.now(),
      "diagnosis": rxDiagnosis.text,
      "history": rxHistory.text,
      "notes": rxNotes.text,
      "followupDate": rxFollowupDate,
    };

    await DatabaseMethods().deletePrescription(
        ePrescription, widget.appt.data["appointmentNumber"]);

    await DatabaseMethods().updatePrescription(
        ePrescription, widget.appt.data["appointmentNumber"]);

    for (var i = 0; i < rxMedicineList.length; i++) {
      Map<String, dynamic> medicine = {
        "name": rxMedicineList[i].name,
        "dosage": rxMedicineList[i].dosage,
        "frequency": rxMedicineList[i].frequency,
        "timing": rxMedicineList[i].timing,
        "duration": rxMedicineList[i].duration,
        "remark": rxMedicineList[i].remark,
      };

      await DatabaseMethods().addPrescriptionMedicine(
          medicine, widget.appt.data["appointmentNumber"]);
    }

    for (var i = 0; i < rxTestList.length; i++) {
      Map<String, dynamic> test = {
        "name": rxTestList[i].name,
        "type": rxTestList[i].type,
        "instructions": rxTestList[i].instructions,
      };

      await DatabaseMethods()
          .addPrescriptionTest(test, widget.appt.data["appointmentNumber"]);
    }

    await DatabaseMethods().updateAppointmentDetails(
        widget.appt.data["appointmentNumber"],
        "prescriptionStatus",
        "GENERATED");

    if (isPDFGenerate == true) {
      await generatePDF();
    }

    Navigator.pop(context);
  }

  generatePDF() async {
    File file;
    await reportView(context, widget.appt).then((value) => file = value);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewEPrescription(
            appt: widget.appt, pageTitle: "e-Prescription", path: file.path),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: rxFollowupDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(new Duration(days: 7)));
    if (picked != null && picked != rxFollowupDate)
      setState(() {
        rxFollowupDate = picked;
      });
  }

  String convertToDateString(Timestamp timestamp) {
    DateTime date = timestamp.toDate();

    return DateFormat("dd MMM yyyy").format(date);
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomLeft,
      //padding: const EdgeInsets.symmetric(vertical: 48),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 100,
              child: RawMaterialButton(
                onPressed: () => _onExit(context),
                child: Text("Exit"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  //side: BorderSide(color: Theme.of(context).primaryColor)
                ),
                elevation: 2.0,
                fillColor: Colors.red,
                padding: const EdgeInsets.all(15.0),
              )),
        ],
      ),
    );
  }

  String _loginUserType() {
    if (globals.loginUserType != null) {
      return globals.loginUserType;
    } else
      return '';
  }

  void _onExit(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).primaryColor,
        //automaticallyImplyLeading: false,
        title: Text(appTitle),
      ),
      backgroundColor: Colors.white,
      body:
          //SlidingUpPanel(
          // renderPanelSheet: false,
          // padding: EdgeInsets.all(0.0),
          // //maxHeight: 40,
          // panel: _floatingPanel(),
          // collapsed: _floatingCollapsed(),
          //body:
          SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            _viewRows(),

            //_toolbar(),

            //_toolbarMsg()
          ],
        ),
      ),
      //),
    );
  }
}

class Service {
  Service(this.ServiceCode, this.ServiceName);

  final String ServiceCode;
  final String ServiceName;
}

class MyTextField extends StatelessWidget {
  const MyTextField(this.controller, this.focusNode);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x4437474F),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          suffixIcon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: "Search here...",
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            bottom: 14,
          ),
        ),
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.folder_open,
          size: 24,
          color: Colors.grey[900].withOpacity(0.7),
        ),
        const SizedBox(width: 10),
        Text(
          "No Services Found",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[900].withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class PopupListItemWidget extends StatelessWidget {
  const PopupListItemWidget(this.item);

  final Service item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        item.ServiceName,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class SelectedItemWidget extends StatelessWidget {
  const SelectedItemWidget(this.selectedItem, this.deleteSelectedItem);

  final Service selectedItem;
  final VoidCallback deleteSelectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 4,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              child: Text(
                selectedItem.ServiceName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 22),
            color: Colors.grey[700],
            onPressed: deleteSelectedItem,
          ),
        ],
      ),
    );
  }
}
