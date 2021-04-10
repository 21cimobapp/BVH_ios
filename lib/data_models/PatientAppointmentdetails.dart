class PatientAppointmentdetails {
  String PatientCode;
  String PatientName;
  String GenderCode;
  String PatientMobile;
  String PatientEmail;
  String DoctorCode;
  String DoctorName;
  String DoctorDesignation;
  DateTime ApptDate;
  String SlotName;
  String SlotNumber;
  String DoctorSlotFromTime;
  String DoctorSlotToTime;
  String DoctorSlotFromTime1;
  String DoctorSlotToTime1;
  String SlotTimeLabel;
  String AppointmentType;
  int SlotDuration;
  int ConsultationFee;
  String VisitType;
  String ServiceCode;
  String BillServiceCode;
  String OrganizationCode;

  PatientAppointmentdetails(
      this.PatientCode,
      this.PatientName,
      this.GenderCode,
      this.PatientMobile,
      this.PatientEmail,
      this.DoctorCode,
      this.DoctorName,
      this.DoctorDesignation,
      this.ApptDate,
      this.SlotName,
      this.SlotNumber,
      this.DoctorSlotFromTime,
      this.DoctorSlotToTime,
      this.DoctorSlotFromTime1,
      this.DoctorSlotToTime1,
      this.SlotTimeLabel,
      this.AppointmentType,
      this.SlotDuration,
      this.ConsultationFee,
      this.VisitType,
      this.ServiceCode,
      this.OrganizationCode);
}



class PatienRegistrationDetails {
  String FirstName;
  String LastName;
  String FullName;
  String patientCode;
  String genderACode;
  String mobileNumber;
  String emailID;


  PatienRegistrationDetails(
      this.FirstName,
      this.LastName,
      this.FullName,
      this.patientCode,
      this.genderACode,
      this.mobileNumber,
      this.emailID,
      );
  PatienRegistrationDetails.fromJsonnew(Map<String, dynamic> json) {
    FirstName = json["FirstName"];
    LastName = json["LastName"];
    FullName = json["FullName"];
    patientCode=json["PersonCode"];
    genderACode=json["GenderCode"];
    mobileNumber = json["MobileNumber"];
    emailID=json["EmailID"];
  }

  }

class DoctorServiceDetails {
  String ServiceCode;
  String ServiceName;



  DoctorServiceDetails(
      this.ServiceCode,
      this.ServiceName,
      );
  DoctorServiceDetails.fromJsonnew(Map<String, dynamic> json) {
    ServiceCode = json["ServiceCode"];
    ServiceName = json["ServiceName"];

  }

}


class PatientAppointment {
  String SlotAvailable;
  String DoctorTimingSlotName;
  String DoctorSlotFromTime;
  String DoctorSlotToTime;
  String SlotTimeLabel;
  String AppointmentType;
  int SlotDuration;
  String SlotNumber;
  int SlotNumberID;
  int ConsultationFee;


  PatientAppointment(
      this.SlotAvailable,
      this.DoctorTimingSlotName,
      this.DoctorSlotFromTime,
      this.DoctorSlotToTime,
      this.SlotTimeLabel,
      this.AppointmentType,
      this.SlotDuration,
      this.SlotNumber,
      this.SlotNumberID,
      this.ConsultationFee);

  PatientAppointment.fromJson(Map<String, dynamic> json) {
    SlotAvailable = json["SlotAvailable"];
    DoctorTimingSlotName = json["DoctorTimingSlotName"];
    DoctorSlotFromTime = json["DoctorSlotFromTime"];
    DoctorSlotToTime = json["DoctorSlotToTime"];
    SlotTimeLabel = json["SlotTimeLabel"];
    AppointmentType = json["AppointmentType"];
    SlotDuration = json["SlotDuration"];
    SlotNumber = json["SlotNumber"];
    SlotNumberID = json["SlotNumberID"];
    ConsultationFee = json["ConsultationFee"];
  }
  PatientAppointment.fromJsonnew(Map<String, dynamic> json) {
    SlotAvailable = json["SlotStatus"];
//    DoctorTimingSlotName = json["SlotID"];
    DoctorSlotFromTime = json["SlotTime"];
//    DoctorSlotToTime = json["DoctorSlotToTime"];
    SlotTimeLabel = json["SlotTimeText"];
//    AppointmentType = json["AppointmentType"];
    SlotDuration = json["SlotDuration"];
  }
}
