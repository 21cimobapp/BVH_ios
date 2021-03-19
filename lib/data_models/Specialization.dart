class Specialization {
  String speciality_code;
  String speciality_name;
  String speciality_detail;
  String speciality_image;

  Specialization(this.speciality_code, this.speciality_name,
      this.speciality_detail, this.speciality_image);
  Specialization.fromJson(Map<String, dynamic> json) {
    speciality_code = json["speciality_code"];
    speciality_name = json["speciality_name"];
    speciality_detail = json["speciality_detail"];
    speciality_image = json["speciality_image"];
  }
}