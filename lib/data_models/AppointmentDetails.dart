class AppointmentDetails {
  String ResourceAllocNumber;
  DateTime ResourceAllocDate;
  String PatientCode;
  String PatientName;
  String AppointmentText;
  String PatientAge;
  String PatientGender;
  String AppointmentStatus;
  String PaymentMode;
  String PaymentStatus;
  String AppointmentType;
  String DoctorCode;
  String DoctorName;
  String DoctorPhoto;
  String DepartmentName;
  String AppointmentTypeACode;
  DateTime PortalAppointmentDateTime;
  String SlotName;
  int SlotDuration;

  AppointmentDetails(
      {this.ResourceAllocNumber,
      this.ResourceAllocDate,
      this.PatientCode,
      this.PatientName,
      this.AppointmentText,
      this.PatientAge,
      this.PatientGender,
      this.AppointmentStatus,
      this.PaymentMode,
      this.PaymentStatus,
      this.AppointmentType,
      this.DoctorCode,
      this.DoctorName,
      this.DoctorPhoto,
      this.DepartmentName,
      this.AppointmentTypeACode,
      this.PortalAppointmentDateTime,
      this.SlotName,
      this.SlotDuration});

  AppointmentDetails.fromJson(Map<String, dynamic> json) {
    ResourceAllocNumber = json["ResourceAllocNumber"];
    ResourceAllocDate = DateTime.parse(json["ResourceAllocDate"]);
    PatientCode = json["PatientCode"];
    PatientName = json["PatientName"];
    AppointmentText = json["AppointmentText"];
    PatientAge = json["PatientAge"];
    PatientGender = json["PatientGender"];
    AppointmentStatus = json["AppointmentStatus"];
    PaymentMode = json["PaymentMode"];
    PaymentStatus = json["PaymentStatus"];
    AppointmentType = json["AppointmentType"];
    DoctorCode = json["DoctorCode"];
    DoctorName = json["DoctorName"];
    DoctorPhoto = json["DoctorPhoto"];
    DepartmentName = json["DepartmentName"];
    AppointmentTypeACode = json["AppointmentTypeACode"];
    PortalAppointmentDateTime =
        DateTime.parse(json["PortalAppointmentDateTime"]);
    SlotName = json["SlotName"];
    SlotDuration = json["SlotDuration"];
  }
}
