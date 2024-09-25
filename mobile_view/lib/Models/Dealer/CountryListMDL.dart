class CountryListMDL
{
  CountryListMDL({
    this.countryId = 0,
    this.countryName = '',
    this.countryCode = '',
    this.isoCode1 = '',
  });

  int countryId;
  String countryName, countryCode, isoCode1;

  factory CountryListMDL.fromJson(Map<String, dynamic> json) => CountryListMDL(
    countryId: json['countryId'],
    countryName: json['countryName'],
    countryCode: json['countryCode'],
    isoCode1: json['isoCode1'],
  );

  Map<String, dynamic> toJson() => {
    'countryId': countryId,
    'countryName': countryName,
    'countryCode': countryCode,
    'isoCode1': isoCode1,
  };
}