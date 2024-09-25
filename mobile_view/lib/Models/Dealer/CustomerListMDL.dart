class CustomerListMDL
{
  CustomerListMDL({
    this.userId = 0,
    this.userName = '',
    this.countryCode = '',
    this.mobileNumber = '',
    this.emailId = '',
    this.serviceRequestCount = 0,
    this.criticalAlarmCount = 0,
  });

  int userId,serviceRequestCount,criticalAlarmCount;
  String userName, countryCode, mobileNumber, emailId;

  factory CustomerListMDL.fromJson(Map<String, dynamic> json) => CustomerListMDL(
    userId: json['userId'],
    userName: json['userName'],
    countryCode: json['countryCode'],
    mobileNumber: json['mobileNumber'],
    emailId: json['emailId'],
    serviceRequestCount: json['serviceRequestCount'],
    criticalAlarmCount: json['criticalAlarmCount'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'countryCode': countryCode,
    'mobileNumber': mobileNumber,
    'emailId': emailId,
    'serviceRequestCount': serviceRequestCount,
    'criticalAlarmCount': criticalAlarmCount,
  };
}