import 'dart:convert';

class BookingDetails {
  String PatientCode;
  String PatientName;
  DateTime BookingDate;
  String SlotName;
  String SlotNumber;
  String SlotFromTime;
  String SlotToTime;
  String SlotTimeLabel;
  String ServiceType;
  String BookingType;
  String BookingAddress1;
  String BookingAddress2;
  String BookingAddress3;
  String BookingAddress4;
  String Remarks;
  int TotalAmount;

  BookingDetails(
      this.PatientCode,
      this.PatientName,
      this.BookingDate,
      this.SlotName,
      this.SlotNumber,
      this.SlotFromTime,
      this.SlotToTime,
      this.SlotTimeLabel,
      this.ServiceType,
      this.BookingType,
      this.BookingAddress1,
      this.BookingAddress2,
      this.BookingAddress3,
      this.BookingAddress4,
      this.Remarks,
      this.TotalAmount);
}

class BookingSaveDetails {
  String OrderNumber;
  DateTime OrderDate;
  String PatientCode;
  DateTime BookingDate;
  String SlotName;
  String SlotNumber;
  String SlotFromTime;
  String SlotToTime;
  String PaymentModeCode;
  String OrganizationCode;
  String ServiceType;
  String BookingType;
  String SlotTimeLabel;
  String PatientName;
  String PatientAge;
  String PatientGender;
  String BookingAddress1;
  String BookingAddress2;
  String BookingAddress3;
  String BookingAddress4;
  String Remarks;
  String paymentID;
  int paymentAmount;
  String signature;

  BookingSaveDetails(
    this.OrderNumber,
    this.OrderDate,
    this.PatientCode,
    this.BookingDate,
    this.SlotName,
    this.SlotNumber,
    this.SlotFromTime,
    this.SlotToTime,
    this.PaymentModeCode,
    this.OrganizationCode,
    this.ServiceType,
    this.BookingType,
    this.SlotTimeLabel,
    this.PatientName,
    this.PatientAge,
    this.PatientGender,
    this.BookingAddress1,
    this.BookingAddress2,
    this.BookingAddress3,
    this.BookingAddress4,
    this.Remarks,
    this.paymentID,
    this.paymentAmount,
    this.signature,
  );

  BookingSaveDetails.fromJson(Map<String, dynamic> json) {
    OrderNumber = json["OrderNumber"];
    OrderDate = json["OrderDate"];
    PatientCode = json["PatientCode"];
    BookingDate = json["BookingDate"];
    SlotName = json["SlotName"];
    SlotNumber = json["SlotNumber"];
    SlotFromTime = json["DoctorSlotFromTime"];
    SlotToTime = json["DoctorSlotToTime"];
    OrganizationCode = json["OrganizationCode"];
    PaymentModeCode = json["PaymentModeCode"];
    ServiceType = json["ServiceType"];
    BookingType = json["AppointmentType"];
    SlotTimeLabel = json["SlotTimeLabel"];
    PatientName = json["PatientName"];
    PatientAge = json["PatientAge"];
    PatientGender = json["PatientGender"];
    BookingAddress1 = json["BookingAddress1"];
    BookingAddress2 = json["BookingAddress2"];
    BookingAddress3 = json["BookingAddress3"];
    BookingAddress4 = json["BookingAddress4"];
    Remarks = json["Remarks"];
    paymentID = json["paymentID"];
    paymentAmount = json["paymentAmount"];
    signature = json["signature"];
  }

  String toJson(BookingSaveDetails savedetail) {
    var mapData = new Map();
    mapData["OrderNumber"] = savedetail.OrderNumber;
    mapData["OrderDate"] = savedetail.OrderDate;
    mapData["PatientCode"] = savedetail.PatientCode;
    mapData["BookingDate"] = savedetail.BookingDate;
    mapData["SlotName"] = savedetail.SlotName;
    mapData["SlotNumber"] = savedetail.SlotNumber;
    mapData["DoctorSlotFromTime"] = savedetail.SlotFromTime;
    mapData["DoctorSlotToTime"] = savedetail.SlotToTime;
    mapData["OrganizationCode"] = savedetail.OrganizationCode;
    mapData["PaymentModeCode"] = savedetail.PaymentModeCode;
    mapData["ServiceType"] = savedetail.ServiceType;
    mapData["BookingType"] = savedetail.BookingType;
    mapData["SlotTimeLabel"] = savedetail.SlotTimeLabel;
    mapData["PatientName"] = savedetail.PatientName;
    mapData["PatientAge"] = savedetail.PatientAge;
    mapData["PatientGender"] = savedetail.PatientGender;
    mapData["BookingAddress1"] = savedetail.BookingAddress1;
    mapData["BookingAddress2"] = savedetail.BookingAddress2;
    mapData["BookingAddress3"] = savedetail.BookingAddress3;
    mapData["BookingAddress4"] = savedetail.BookingAddress4;
    mapData["Remarks"] = savedetail.Remarks;

    mapData["paymentID"] = savedetail.paymentID;
    mapData["paymentAmount"] = savedetail.paymentAmount;
    mapData["signature"] = savedetail.signature;
    String json = jsonEncode(mapData); //JSON.encode(mapData);
    return json;
  }
}
