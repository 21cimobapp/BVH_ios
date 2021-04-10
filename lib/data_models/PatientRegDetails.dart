
class PatientDet {
  String salutationCode;
        String firstName;
        String otherName;
        String lastName;
        String age;
        DateTime dateOfBirth;
        String mobileNumber;
        String emailID;
        String genderCode;
        String address1;
        String address2;
        String cityCode;
        String stateCode;
        String pinCode;
        String profileImage;
        String relationCode;
        String registrationCode;
        String relation;

PatientDet(
  this.salutationCode,
        this.firstName,
        this.otherName,
        this.lastName,
        this.dateOfBirth,
        this.mobileNumber,
        this.emailID,
        this.genderCode,
        this.address1,
        this.address2,
        this.cityCode,
        this.stateCode,
        this.pinCode,
        this.profileImage,
        this.relationCode,
        this.registrationCode);

factory PatientDet.fromJson(Map<String, dynamic> json) {
return PatientDet( 
json['salutationCode'],
        json['firstName'],
        json['otherName'],
        json['lastName'],
        json['dateOfBirth'],
        json['mobileNumber'],
        json['emailID'],
        json['genderCode'],
        json['address1'],
        json['address2'],
        json['cityCode'],
        json['stateCode'],
        json['pinCode'],
        json['profileImage'],
        json['relationCode'],
        json['registrationCode']
);
}
}


class PatientRegDet {
  
  final String mobileNumber;
  int status;
  String err_code;
  List<PatientDet> patientDetails;
  

  PatientRegDet({
    this.mobileNumber,
    this.status,
    this.err_code,
    this.patientDetails

  });

  factory PatientRegDet.fromJson(Map<String, dynamic> parsedJson) {
    
    //print(streetsFromJson.runtimeType);
    return new PatientRegDet(
      mobileNumber: parsedJson['mobileNumber'],
      status: parsedJson['status'],
      err_code: parsedJson['err_code'],
//      patientDetails : (parsedJson['patientDetails'] as List)
      //.map((i) =>
       //       PatientDet.fromJson(i)).toList()
    );
  }

}