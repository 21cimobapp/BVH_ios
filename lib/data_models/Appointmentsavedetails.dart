import 'dart:convert';

class Appointmentsavedetails {
  String Token;
  String PatientCode;
  String DoctorCode;
  String ApptDate;
  String SlotName;
  String SlotNumber;
  String DoctorSlotFromTime;
  String DoctorSlotToTime;
  String DoctorSlotFromTime1;
  String DoctorSlotToTime1;
  String PaymentModeCode;
  String OrganizationCode;
  String AppointmentType;
  String SlotTimeLabel;
  String PatientName;
  String DoctorName;
  String DoctorPhoto;
  String DepartmentName;
  String DoctorQualification;
  String PatientAge;
  String PatientGender;
  String PatientMobile;
  String PatientEmail;
  int SlotDuration;
  String paymentID;
  int paymentAmount;
  String signature;
  String DeptCode;
  String ServiceCode;
  String BillServiceCode;

  Appointmentsavedetails(
    this.Token,
    this.PatientCode,
    this.DoctorCode,
    this.ApptDate,
    this.SlotName,
    this.SlotNumber,
    this.DoctorSlotFromTime,
    this.DoctorSlotToTime,
    this.DoctorSlotFromTime1,
    this.DoctorSlotToTime1,
    this.PaymentModeCode,
    this.OrganizationCode,
    this.AppointmentType,
    this.SlotTimeLabel,
    this.PatientName,
    this.DoctorName,
    this.DoctorPhoto,
    this.DepartmentName,
    this.DoctorQualification,
    this.PatientAge,
    this.PatientGender,
    this.PatientMobile,
    this.PatientEmail,
    this.SlotDuration,
    this.paymentID,
    this.paymentAmount,
    this.signature,
    this.DeptCode,
      this.ServiceCode,
      this.BillServiceCode
  );

  Appointmentsavedetails.fromJson(Map<String, dynamic> json) {
    Token = json["Token"];
    PatientCode = json["PatientCode"];
    DoctorCode = json["DoctorCode"];
    ApptDate = json["ApptDate"];
    SlotName = json["SlotName"];
    SlotNumber = json["SlotNumber"];
    DoctorSlotFromTime = json["DoctorSlotFromTime"];
    DoctorSlotToTime = json["DoctorSlotToTime"];
    OrganizationCode = json["OrganizationCode"];
    PaymentModeCode = json["PaymentModeCode"];
    AppointmentType = json["AppointmentType"];
    SlotTimeLabel = json["SlotTimeLabel"];
    PatientName = json["PatientName"];
    DoctorName = json["DoctorName"];
    DoctorPhoto = json["DoctorPhoto"];
    DepartmentName = json["DepartmentName"];
    DoctorQualification = json["DoctorQualification"];
    PatientAge = json["PatientAge"];
    PatientGender = json["PatientGender"];
    SlotDuration = json["SlotDuration"];
    paymentID = json["paymentID"];
    paymentAmount = json["paymentAmount"];
    signature = json["signature"];
  }
  String toJson(Appointmentsavedetails savedetail) {
    var mapData = new Map();
    mapData["Token"] = savedetail.Token;
    mapData["PatientCode"] = savedetail.PatientCode;
    mapData["DoctorCode"] = savedetail.DoctorCode;
    mapData["ApptDate"] = savedetail.ApptDate;
    mapData["SlotName"] = savedetail.SlotName;
    mapData["SlotNumber"] = savedetail.SlotNumber;
    mapData["DoctorSlotFromTime"] = savedetail.DoctorSlotFromTime;
    mapData["DoctorSlotToTime"] = savedetail.DoctorSlotToTime;
    mapData["OrganizationCode"] = savedetail.OrganizationCode;
    mapData["PaymentModeCode"] = savedetail.PaymentModeCode;
    mapData["PatientName"] = savedetail.PatientName;
    mapData["DoctorName"] = savedetail.DoctorName;
    mapData["DoctorPhoto"] = savedetail.DoctorPhoto;
    mapData["DepartmentName"] = savedetail.DepartmentName;
    mapData["DoctorQualification"] = savedetail.DoctorQualification;
    mapData["PatientAge"] = savedetail.PatientAge;
    mapData["PatientGender"] = savedetail.PatientGender;
    mapData["SlotDuration"] = savedetail.SlotDuration;
    mapData["paymentID"] = savedetail.paymentID;
    mapData["paymentAmount"] = savedetail.paymentAmount;
    mapData["signature"] = savedetail.signature;
    String json = jsonEncode(mapData); //JSON.encode(mapData);
    return json;
  }
}
