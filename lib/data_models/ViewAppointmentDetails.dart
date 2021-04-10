import 'package:flutter/cupertino.dart';

class ViewAppointmentDetails {
  String ApptNumber;
  DateTime ApptRqstDate;
  String FromTime;
  String ToTime;
  DateTime FromTime1;
  DateTime ToTime1;
  String PatientCode;
  String PatientName;
//  String AppointmentText;
//  String PatientAge;
//  String PatientGender;
  String AppointmentStatus;
//  String PaymentMode;
//  String PaymentStatus;
  String ApptTypeCode;
  String ApptType;
  String ApptPeriod;
  String DoctorCode;
  String DoctorName;
  String DeptCode;
  String DeptName;
//  String AppointmentTypeACode;
//  DateTime PortalAppointmentDateTime;
//  String SlotName;
//  int SlotDuration;

  ViewAppointmentDetails(
      {this.ApptNumber,
      this.ApptRqstDate,
        this.FromTime,
        this.ToTime,
      this.PatientCode,
      this.PatientName,
//      this.AppointmentText,
//      this.PatientAge,
//      this.PatientGender,
      this.AppointmentStatus,
//      this.PaymentMode,
//      this.PaymentStatus,
      this.ApptType,
        this.ApptPeriod,
      this.DoctorCode,
      this.DoctorName,
      this.DeptCode,
      this.DeptName
//      this.AppointmentTypeACode,
//      this.PortalAppointmentDateTime,
//      this.SlotName,
//      this.SlotDuration
      });

  ViewAppointmentDetails.fromJson(Map<String, dynamic> json) {
    ApptNumber = json["ApptNumber"];
    ApptRqstDate = DateTime.parse(json["ApptRqstDate"]);
    FromTime = json["FromTime"];
    ToTime = json["ToTime"];
    String apptDate = json["ApptRqstDate"];
    apptDate = apptDate.substring(0,apptDate.indexOf('T'));
    String FapptDate = apptDate+' '+json["FromTime"];
    String TapptDate = apptDate+' '+json["ToTime"];
    FromTime1 = DateTime.parse(FapptDate);
    ToTime1 = DateTime.parse(TapptDate);
    PatientCode = json["PatientCode"];
    PatientName = json["PatientName"];
//    AppointmentText = json["AppointmentText"];
//    PatientAge = json["PatientAge"];
//    PatientGender = json["PatientGender"];
    AppointmentStatus = json["AppointmentStatus"];
//    PaymentMode = json["PaymentMode"];
//    PaymentStatus = json["PaymentStatus"];
    ApptTypeCode = json["ApptType"];
    ApptTypeCode=="2"?ApptType ="VIDEOCONSULT":ApptType ="VISITCONSULT";
    ApptPeriod = json["ApptPeriod"];
    DoctorCode = json["DoctorCode"];
    DoctorName = json["DoctorName"];
    DeptCode = json["DeptCode"];
    DeptName = json["DeptName"];

//    ApptType = json["ApptType"];
//    PortalAppointmentDateTime =
//        DateTime.parse(json["PortalAppointmentDateTime"]);
//    SlotName = json["SlotName"];
//    SlotDuration = json["SlotDuration"];
  }
}
