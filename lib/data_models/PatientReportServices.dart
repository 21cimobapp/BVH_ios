class PatientReportServices {
  String ServiceRqstNumber;
  DateTime ServiceRequestDate;
  String PatientCode;
  String PatientName;
  String ServiceCode;
  String ServiceName;
  String ServiceRenderNumber;
  DateTime ServiceRenderDate;
  String ServiceStatus;
  String DoctorName;

  PatientReportServices(
      this.ServiceRqstNumber,
      this.ServiceRequestDate,
      this.PatientCode,
      this.PatientName,
      this.ServiceCode,
      this.ServiceName,
      this.ServiceRenderNumber,
      this.ServiceRenderDate,
      this.ServiceStatus,
      this.DoctorName);

  PatientReportServices.fromJson(Map<String, dynamic> json) {
      ServiceRqstNumber= json["ServiceRqstNumber"];
      ServiceRequestDate= DateTime.parse(json["ServiceRequestDate"]);
      PatientCode= json["PatientCode"];
      PatientName= json["PatientName"];
      ServiceCode= json["ServiceCode"];
      ServiceName= json["ServiceName"];
      ServiceRenderNumber= json["ServiceRenderNumber"];
      ServiceRenderDate= DateTime.parse(json["ServiceRenderDate"]);
      ServiceStatus= json["ServiceStatus"];
      DoctorName = json["DoctorName"];
    
  }
}
