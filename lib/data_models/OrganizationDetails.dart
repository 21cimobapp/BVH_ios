
class OrganizationDetails {
  String organization_code;
  String organization_name;
  String organization_suburbcode;
  String organization_suburb;
  String organization_citycode;
  String organization_city;

  OrganizationDetails(
      {this.organization_code,
        this.organization_name,
        this.organization_suburbcode,
        this.organization_suburb,
        this.organization_citycode,
        this.organization_city,
      });

  OrganizationDetails.fromJson(Map<String, dynamic> json) {
    organization_code = json["organization_code"];
    organization_name = json["organization_name"];
    organization_suburbcode = json["organization_suburbcode"];
    organization_suburb = json["organization_suburb"];
    organization_citycode = json["organization_citycode"];
    organization_city = json["organization_city"];
  }
}
