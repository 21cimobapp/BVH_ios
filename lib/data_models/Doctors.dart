class Doctors {
  String DoctorCode;
  String DoctorName;
  String DoctorPhoto;
  String Qualification;
  String Designation;
  String AvailableDays;

  Doctors(this.DoctorCode, this.DoctorName, this.DoctorPhoto,
      this.Qualification,this.Designation, this.AvailableDays);
  Doctors.fromJson(Map<String, dynamic> json) {
    DoctorCode = json["DoctorCode"];
    DoctorName = json["DoctorName"];
    DoctorPhoto = json["DoctorPhoto"];
    Qualification = json["Qualification"];
    Designation = json["Designation"];
    AvailableDays = json["AvailableDays"];
  }
}