// import 'dart:wasm';

import 'package:civideoconnectapp/data_models/AppointmentDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseMethods {
  Future<void> addUserInfo(personCode, userData) async {
    Firestore.instance
        .collection("users")
        .document(personCode)
        .setData(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> updateDoctorOnlineStatus(String doctorCode, bool onlineStatus) {
    String dateField;

    Firestore.instance.collection("users").document(doctorCode).updateData({
      'onlineStatus': onlineStatus,
    });
  }

  Future<void> deleteUserInfo(String mobile) async {
    QuerySnapshot userInfoSnapshot = await getUserInfo(mobile);

    for (DocumentSnapshot doc in userInfoSnapshot.documents) {
      doc.reference.delete();
    }
  }

  getUserInfo(String mobile) async {
    return Firestore.instance
        .collection("users")
        .where("mobile", isEqualTo: mobile)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<QuerySnapshot> getUserInfoByID(String personCode) async {
    return Firestore.instance
        .collection("users")
        .where("userCode", isEqualTo: personCode)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Future<String> getChannelName() async {
  //   DocumentSnapshot snapshot =
  //       await Firestore.instance.collection('channels').document('567890');
  //   String channelName = snapshot['channelName'];
  //   if (channelName is String) {
  //     return channelName;
  //   } else {
  //     return "";
  //   }
  // }

  getUserName(personCode) async {
    String peerName = "";
    await Firestore.instance
        .collection('users')
        .document(personCode)
        .get()
        .then((DocumentSnapshot ds) {
      peerName = ds['userName'];
    });

    return peerName;
  }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .getDocuments();
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserChats(String personCode) async {
    return await Firestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: personCode)
        .snapshots();
  }

  Future<bool> addAppointment(apptDetails, apptID) {
    Firestore.instance
        .collection("Appointments")
        .document(apptID)
        .setData(apptDetails)
        .catchError((e) {
      print(e);
    });
  }

  Future<bool> addBooking(bookingDetails, bookingNumber) {
    Firestore.instance
        .collection("Orders")
        .document(bookingNumber)
        .setData(bookingDetails)
        .catchError((e) {
      print(e);
    });
  }

  Future<bool> addAddressBook(addressDetails, personCode) {
    Firestore.instance
        .collection("AddressBook")
        .document(personCode)
        .collection('Address')
        .add(addressDetails)
        .catchError((e) {
      print(e);
    });
  }

  getPatientAddressBook(String patientCode) async {
    return Firestore.instance
        .collection("AddressBook")
        .document(patientCode)
        .collection('Address')
        .snapshots();
  }

  getPatientOrders(String patientCode) async {
    return Firestore.instance
        .collection("Orders")
        .where("patientCode", isEqualTo: patientCode)
        .where("bookingDate", isGreaterThanOrEqualTo: DateTime.now())
        .orderBy("bookingDate")
        .snapshots();
  }

  getPatientAppointments(String patientCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isGreaterThanOrEqualTo: DateTime.now())
        .orderBy("doctorSlotToTime")
        .snapshots();
  }
  getPatientAppointmentLast(String patientCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isLessThanOrEqualTo: DateTime.now())
        .orderBy("doctorSlotToTime", descending: true)
        .limit(1)
        .snapshots();
  }

  getPatientAppointmentsNext(String patientCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isGreaterThanOrEqualTo: DateTime.now())
        .orderBy("doctorSlotToTime")
        .limit(1)
        .snapshots();
  }

  Future<String> getRazorPayKey()  async {
    String razorkey;
    await Firestore.instance
        .collection("Config")
//        .document("RazorPay")
//        .collection("RazorPayKey")
        .getDocuments()
        .then((QuerySnapshot snapshot) => snapshot.documents
        .forEach((f) => razorkey = f.data['RazorPayKey']));
//        .snapshots();
  return razorkey;
  }

  Future<List<PatientAppointmentDoctorList>> getPatientAppointmentDoctorList(
      String patientCode) async {
    final List<PatientAppointmentDoctorList> loadedList1 = [];
    final List<PatientAppointmentDoctorList> loadedList = [];

    await Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .orderBy("doctorSlotFromTime", descending: true)
        .getDocuments()
        .then((QuerySnapshot snapshot) => snapshot.documents
            .forEach((f) => loadedList1.add(PatientAppointmentDoctorList(
                  doctorCode: f.data['doctorCode'],
                  doctorName: f.data['doctorName'],
                ))));

    for (int i = 0; i < loadedList1.length; i++) {
      if (loadedList.lastIndexWhere(
              (element) => element.doctorCode == loadedList1[i].doctorCode) ==
          -1) {
        loadedList.add(loadedList1[i]);
      }
    }

    return loadedList;
  }

  Future<void> updateSharedocument(
      String patientCode, String documentID, List<String> value) {
    String dateField;

    Firestore.instance
        .collection("eRecords")
        .document(patientCode)
        .collection('Docuements')
        .document(documentID)
        .updateData({
      'sharedTo': value,
    });
  }

  // added by vrushali
  Future deleteDocuments(String patientCode,String documentId) async {
    await Firestore.instance
        .collection("eRecords")
        .document(patientCode)
        .collection('Docuements')
        .document(documentId).delete();
  }

  Future<String> getePrescription(
      String patientCode, String documentCode) async {
    String documentURL;

    await Firestore.instance
        .collection("eRecords")
        .document(patientCode)
        .collection('Docuements')
        .where('documentCode', isEqualTo: "$documentCode")
        .getDocuments()
        .then((QuerySnapshot snapshot) => snapshot.documents
            .forEach((f) => documentURL = f.data['documentURL']));

    return documentURL;
  }

  getPatientAppointmentsRecent(String patientCode) {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isGreaterThanOrEqualTo: DateTime.now())
        .orderBy("doctorSlotToTime")
        .snapshots();
  }

  getPatientAppointmentsPast(String patientCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isLessThan: DateTime.now())
        .orderBy("doctorSlotToTime", descending: true)
        .snapshots();
  }

  getDoctorAppointments(String doctorCode, DateTime apptDate) async {
    return Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("apptDate", isEqualTo: apptDate)
        .orderBy("doctorSlotFromTime")
        .snapshots();
  }

  Future<List<AppointmentSlots>> getDoctorAppointmentSlots(
      String doctorCode, DateTime apptDate) async {
    final List<AppointmentSlots> loadedList = [];

    await Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("apptDate", isEqualTo: apptDate)
        .orderBy("doctorSlotFromTime")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(AppointmentSlots(
              doctorSlotFromTime: f.data['doctorSlotFromTime'].toDate(),
              doctorSlotToTime: f.data['doctorSlotToTime'].toDate(),
            )),
          ),
        );

    return loadedList;
  }

  getDoctorAppointmentsPending(String doctorCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("appointmentStatus", isEqualTo: "DONE")
        .where("prescriptionStatus", whereIn: ['PENDING', 'GENERATED'])
        .orderBy("doctorSlotFromTime")
        .snapshots();
  }

  getDoctorAppointmentsWaitingOnly(String doctorCode, DateTime apptDate) async {
    return Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("apptDate", isEqualTo: apptDate)
        .where("appointmentStatus", isEqualTo: "WAITING")
        .orderBy("doctorSlotFromTime")
        .snapshots();
  }

  Stream<DocumentSnapshot> getAppointmentDetails(String appointmentNumber) {
    return Firestore.instance
        .collection("Appointments")
        .document(appointmentNumber)
        .snapshots();
  }

  getPatientDocuments(String patientCode, String uploadedBy,
      String loginUserType, String loginUserCode) async {
    if (uploadedBy == "PATIENT") {
      if (loginUserType == "PATIENT") {
        return Firestore.instance
            .collection("eRecords")
            .document(patientCode)
            .collection('Docuements')
            .where("uploadedBy", isEqualTo: uploadedBy)
            .orderBy("documentDate", descending: true)
            .snapshots();
      } else {
        return Firestore.instance
            .collection("eRecords")
            .document(patientCode)
            .collection('Docuements')
            .where("uploadedBy", isEqualTo: uploadedBy)
            .where('sharedTo', arrayContains: loginUserCode)
            .orderBy("documentDate", descending: true)
            .snapshots();
      }
    } else {
      return Firestore.instance
          .collection("eRecords")
          .document(patientCode)
          .collection('Docuements')
          .where("uploadedBy", isEqualTo: uploadedBy)
          .orderBy("documentDate", descending: true)
          .snapshots();
    }
  }

  Future<bool> addPatientDocument(document, patientCode) {
    Firestore.instance
        .collection("eRecords")
        .document(patientCode)
        .collection('Docuements')
        .document("${document["documentCode"]}")
        .setData(document)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> updateAppointmentDetails(
      String apptID, String field, String value) {
    String dateField;

    if (field == "appointmentStatus") {
      dateField = "${value}DateTime";

      Firestore.instance
          .collection('Appointments')
          .document(apptID)
          .updateData({
        '$field': value,
        'prescriptionStatus': 'PENDING',
        '$dateField': DateTime.now(),
      });
    } else {
      Firestore.instance
          .collection('Appointments')
          .document(apptID)
          .updateData({
        '$field': value,
      });
    }
  }

  var doctorTodaySummary = Map();

  Future<Map> getDoctorTodaySummary(String doctorCode) async {
    String appointmentStatus = "";
    doctorTodaySummary["Total"] = 0;
    doctorTodaySummary["Done"] = 0;

    await Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("apptDate",
            isEqualTo:
                DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()))
        .getDocuments()
        .then((snapshot) {
      return snapshot.documents.map((element) {
        appointmentStatus = element.data['name'];

        if (appointmentStatus == null)
          appointmentStatus = "PENDING";
        else if (appointmentStatus == "CANCELLED")
          appointmentStatus = "";
        else if (appointmentStatus == "DONE")
          appointmentStatus = "DONE";
        else
          appointmentStatus = "DONE";

        if (appointmentStatus == "PENDING") {
          doctorTodaySummary["Total"] += 1;
        } else if (appointmentStatus == "DONE") {
          doctorTodaySummary["Total"] += 1;
          doctorTodaySummary["Done"] += 1;
        }
      }).toList();

      //return doctorTodaySummary;
    });
  }

  Future<void> setPreConsultationMaster(apptID) async {
    await Firestore.instance
        .collection("PreConsultationMaster")
        //.orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach((f) => {
                Firestore.instance
                    .collection('Appointments')
                    .document(apptID)
                    .collection('PreConsultationInfo')
                    .document(f.data['id'])
                    .setData({
                  'id': f.data['id'],
                  'question': f.data['question'],
                  'answerType': f.data['answerType'],
                  'answerField1': f.data['answerField1'],
                  'sequence': f.data['sequence'],

                })
              }),
        );
  }

  Future<List<PreConsultationMasterList>> getPreConsultationMaster(
      apptID) async {
    final List<PreConsultationMasterList> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        //.orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(PreConsultationMasterList(
              id: f.data['id'],
              question: f.data['question'],
              answerType: f.data['answerType'],
              answerField1: f.data['answerField1'],
             // sequence: f.data['sequence'],
              answer1: f.data['answer1'],
              answer2: f.data['answer2'],
            )),
          ),
        );
    return loadedList;
  }

  getPreConsultationDetails(apptID) async {
    return Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        .orderBy("sequence")
        .snapshots();
  }

  Future<void> updatePreConsultationInfo1(
      String apptID,
      String questionID,
      String question,
      String answerType,
      String answerField1,
      int sequence,
      String value) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        .document(questionID)
        .setData({
      'id': questionID,
      'question': question,
      'answerType': answerType,
      'answerField1': answerField1,
      'sequence': sequence,
      'answer1': value,
    });
    return null;
  }

  Future<void> updatePreConsultationInfo2(
      String apptID,
      String questionID,
      String question,
      String answerType,
      String answerField1,
      int sequence,
      String value) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        .document(questionID)
        .setData({
      'id': questionID,
      'question': question,
      'answerType': answerType,
      'answerField1': answerField1,
      'sequence': sequence,
      'answer2': value,
    });
    return null;
  }

  Future<void> updatePrescription(ePrescription, apptID) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .setData(ePrescription);
    return null;
  }

  Future<void> addPrescriptionMedicine(medicine, apptID) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .add(medicine);
    return null;
  }

  Future<void> addPrescriptionTest(test, apptID) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .add(test);
    return null;
  }

  Future<void> deletePrescription(ePrescription, apptID) async {
    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .delete();

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });

    return null;
  }

  Future<List<EPrescription>> getEPrescription(apptID) async {
    final List<EPrescription> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(EPrescription(
              prescriptionDate: f.data['prescriptionDate'].toDate(),
              diagnosis: f.data['diagnosis'],
              history: f.data['history'],
              notes: f.data['notes'],
              followupDate: f.data['followupDate'].toDate(),
            )),
          ),
        );
    return loadedList;
  }

  Future<List<RxMedicine>> getEPrescriptionMedicine(apptID) async {
    final List<RxMedicine> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(RxMedicine(
              name: f.data['name'],
              dosage: f.data['dosage'],
              frequency: f.data['frequency'],
              timing: f.data['timing'],
              duration: f.data['duration'],
              remark: f.data['remark'],
            )),
          ),
        );
    return loadedList;
  }

  Future<List<RxTest>> getEPrescriptionTest(apptID) async {
    final List<RxTest> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(RxTest(
              name: f.data['name'],
              type: f.data['type'],
              instructions: f.data['instructions'],
            )),
          ),
        );
    return loadedList;
  }

  Future<List<List<String>>> getEPrescriptionMedicineRx(apptID) async {
    final List<List<String>> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(<String>[
              f.data['name'],
              f.data['dosage'],
              f.data['frequency'],
              "${f.data['duration']} day(s)",
              "${f.data['timing']} ${f.data['remark']}"
            ]),
          ),
        );
    if (loadedList.length > 0)
      loadedList.insert(0, <String>[
        'Medicine',
        'Dosage',
        'Frequency',
        'Duration',
        'Instructions'
      ]);

    return loadedList;
  }

  Future<List<List<String>>> getEPrescriptionTestRx(apptID) async {
    final List<List<String>> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(<String>[
              f.data['name'],
              f.data['instructions'],
            ]),
          ),
        );

    if (loadedList.length > 0)
      loadedList.insert(0, <String>[
        'Test Name',
        'Instructions',
      ]);

    return loadedList;
  }

  Future<List<DoctorSessions>> getDoctorSessions(
      doctorCode, sessionTypeID) async {
    final List<DoctorSessions> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document('Main')
        .collection('DoctorSession')
        .where("doctorCode", isEqualTo: doctorCode)
        .where("sessionTypeID", isEqualTo: sessionTypeID)
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(DoctorSessions(
              sessionID: f.data['sessionID'],
              sessionDay: f.data['sessionDay'],
              sessionTiming: f.data['sessionTiming'],
              sessionTimingID: f.data['sessionTimingID'],
              consultationFee: f.data['consultationFee'],
              startTime: f.data['startTime'],
              endTime: f.data['endTime'],
              slotDuration: 15,
            )),
          ),
        );

    return loadedList;
  }

  Future<List<DoctorData>> getDoctors(specialityId) async {
    final List<DoctorData> loadedList = [];
    if (specialityId == "ALL")
      await Firestore.instance
          .collection('Masters')
          .document("Main")
          .collection('Doctors')
          .getDocuments()
          .then(
            (QuerySnapshot snapshot) => snapshot.documents.forEach(
              (f) => loadedList.add(DoctorData(
                doctorCode: f.data['doctorCode'],
                doctorName: f.data['doctorName'],
                designation: f.data['designation'],
                qualification: f.data['qualification'],
                specialityCode: f.data['specialityCode'],
                availableDays: f.data['availableDays'],
                aboutDoctor: f.data['aboutDoctor'],
                doctorPhoto:
                    f.data['doctorPhoto'] == null ? "" : f.data['doctorPhoto'],
              )),
            ),
          );
    else
      await Firestore.instance
          .collection('Masters')
          .document("Main")
          .collection('Doctors')
          .where("specialityCode", isEqualTo: specialityId)
          .getDocuments()
          .then(
            (QuerySnapshot snapshot) => snapshot.documents.forEach(
              (f) => loadedList.add(DoctorData(
                doctorCode: f.data['doctorCode'],
                doctorName: f.data['doctorName'],
                designation: f.data['designation'],
                qualification: f.data['qualification'],
                specialityCode: f.data['specialityCode'],
                availableDays: f.data['availableDays'],
                aboutDoctor: f.data['aboutDoctor'],
                doctorPhoto:
                    f.data['doctorPhoto'] == null ? "" : f.data['doctorPhoto'],
              )),
            ),
          );
    return loadedList;
  }

  Future<List<DoctorSpeciality>> getDoctorSpeciality() async {
    final List<DoctorSpeciality> loadedList = [];

    // loadedList.add(DoctorSpeciality(
    //   specialityId: "ALL",
    //   speciality: "ALL",
    //   description: "",
    //   sequence: 0,
    // ));

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('DoctorSpeciality')
        .orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach((f) => {
                loadedList.add(DoctorSpeciality(
                  specialityId: f.data['specialityCode'],
                  speciality: f.data['speciality'],
                  description: f.data['description'],
                  sequence: f.data['sequence'],
                  imageURL: f.data['imageURL'],
                )),
              }),
        );
    return loadedList;
  }

  Future<List<HolidayData>> getHolidays() async {
    final List<HolidayData> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Holiday')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(HolidayData(
              holidayCode: f.data['holidayCode'],
              holidayDate: f.data['holidayDate'].toDate(),
              holidayDetails: f.data['holidayDetails'],
            )),
          ),
        );
    return loadedList;
  }

  Future<bool> addSliderImages(document, userType, imageID) {
    Firestore.instance
        .collection("SliderImages")
        .document(userType)
        .collection('Images')
        .document(imageID.toString())
        .setData(document)
        .catchError((e) {
      print(e);
    });
  }

  Future<List<SliderImages>> getSliderImages(userType) async {
    final List<SliderImages> loadedList = [];

    await Firestore.instance
        .collection("SliderImages")
        .document(userType)
        .collection('Images')
        .orderBy("imageID")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(SliderImages(
              documentName: f.data['documentName'],
              documentTitle: f.data['documentTitle'],
              documentType: f.data['documentType'],
              documentURL: f.data['documentURL'],
              effectiveDate: f.data['effectiveDate'].toDate(),
              imageID: f.data['imageID'],
              uploadedDate: f.data['uploadedDate'].toDate(),
              userType: f.data['userType'],
            )),
          ),
        );
    return loadedList;
  }
}

class PatientAppointmentDoctorList {
  String doctorCode;
  String doctorName;
  PatientAppointmentDoctorList({
    this.doctorCode,
    this.doctorName,
  });

  PatientAppointmentDoctorList.fromJson(Map<String, dynamic> json) {
    doctorCode = json["doctorCode"];
    doctorName = json["doctorName"];
  }
}

class SliderImages {
  String documentName;
  String documentTitle;
  String documentType;
  String documentURL;
  DateTime effectiveDate;
  int imageID;
  DateTime uploadedDate;
  String userType;

  SliderImages(
      {this.documentName,
      this.documentTitle,
      this.documentType,
      this.documentURL,
      this.effectiveDate,
      this.imageID,
      this.uploadedDate,
      this.userType});

  SliderImages.fromJson(Map<String, dynamic> json) {
    documentName = json["documentName"];
    documentTitle = json["documentTitle"];
    documentType = json["documentType"];
    documentURL = json["documentURL"];
    effectiveDate = json["effectiveDate"];
    imageID = json["imageID"];
    uploadedDate = json["uploadedDate"];
    userType = json["userType"];
  }
}

class HolidayData {
  String holidayCode;
  DateTime holidayDate;
  String holidayDetails;

  HolidayData({
    this.holidayCode,
    this.holidayDate,
    this.holidayDetails,
  });
}

class PreConsultationMasterList {
  final String id;
  final String question;
  final String answerType;
  final String answerField1;
  final int sequence;
  String answer1;
  String answer2;

  PreConsultationMasterList(
      {this.id,
      this.question,
      this.answerType,
      this.answerField1,
      this.sequence,
      this.answer1,
      this.answer2});
}

class EPrescription {
  DateTime prescriptionDate;
  String diagnosis;
  String history;
  String notes;
  DateTime followupDate;

  EPrescription({
    this.prescriptionDate,
    this.diagnosis,
    this.history,
    this.notes,
    this.followupDate,
  });
}

class RxMedicine {
  String name;
  String dosage;
  String frequency;
  String timing;
  String duration;
  String remark;

  RxMedicine({
    this.name,
    this.dosage,
    this.frequency,
    this.timing,
    this.duration,
    this.remark,
  });
}

class RxTest {
  String name;
  String type;
  String instructions;

  RxTest({
    this.name,
    this.type,
    this.instructions,
  });
}

class DoctorSpeciality {
  // final String specialityId;
  // final String speciality;
  // final String description;
  // final int sequence;
  // final String imageURL;
  String specialityId;
  String speciality;
  String description;
  int sequence;
  String imageURL;

  DoctorSpeciality(
      {this.specialityId,
      this.speciality,
      this.description,
      this.sequence,
      this.imageURL});
  // Added by Abhi API instead of Firebase.
  DoctorSpeciality.fromJson(Map<String, dynamic> json) {
    specialityId = json["speciality_code"];
    speciality = json["speciality_name"];
    description = json["speciality_detail"];
    sequence = 0;
    imageURL = json["speciality_image"];
  }
  // End Added by Abhi API instead of Firebase.
}

class DoctorData {
  String doctorCode;
  String doctorName;
  String designation;
  String qualification;
  String specialityCode;
  String availableDays;
  String aboutDoctor;
  String doctorPhoto;
  double VisitConsultCharge;
  double VideoConsultCharge;
  String deptCode;

  DoctorData(
      {this.doctorCode,
      this.doctorName,
      this.designation,
      this.qualification,
      this.specialityCode,
      this.availableDays,
      this.aboutDoctor,
      this.doctorPhoto,
      this.VisitConsultCharge,
      this.VideoConsultCharge,
      this.deptCode});

  DoctorData.fromJson(Map<String, dynamic> json) {
    doctorCode = json["doctorCode"];
    doctorName = json["doctorName"];
    designation = json["designation"];
    qualification = json["qualification"];
    specialityCode = json["specialityCode"];
    availableDays = json["availableDays"];
    aboutDoctor = json["aboutDoctor"];
    doctorPhoto = json["doctorPhoto"];
  }

  DoctorData.fromJsonnew(Map<String, dynamic> json) {
    doctorCode = json["DoctorCode"];
    doctorName = json["DoctorName"];
    designation = json["Designation"];
    availableDays = json["AvailableDays"];
    VisitConsultCharge = json["VisitConsultCharge"];
    VideoConsultCharge = json["VideoConsultCharge"];
    doctorPhoto = json["DoctorPhoto"];
    deptCode = json["DeptCode"];
  }
}

class DoctorSessions {
  String sessionID;
  String sessionDay;
  String sessionTiming;
  int sessionTimingID;
  int consultationFee;
  String startTime;
  String endTime;
  int slotDuration;

  DoctorSessions(
      {this.sessionID,
      this.sessionDay,
      this.sessionTiming,
      this.sessionTimingID,
      this.consultationFee,
      this.startTime,
      this.endTime,
      this.slotDuration});

  DoctorSessions.fromJson(Map<String, dynamic> json) {
    sessionID = json["sessionID"];
    sessionDay = json["sessionDay"];
    sessionTiming = json["sessionTiming"];
    sessionTimingID = json["sessionTimingID"];
    consultationFee = json["consultationFee"];
    startTime = json["startTime"];
    endTime = json["endTime"];
    slotDuration = json["slotDuration"];
  }
}

class AppointmentSlots {
  DateTime doctorSlotFromTime;
  DateTime doctorSlotToTime;

  AppointmentSlots({
    this.doctorSlotFromTime,
    this.doctorSlotToTime,
  });

  AppointmentSlots.fromJson(Map<String, dynamic> json) {
    doctorSlotFromTime = json["doctorSlotFromTime"];
    doctorSlotToTime = json["doctorSlotToTime"];
  }
}
