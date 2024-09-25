

import 'dart:convert';

ServicecustomerModel servicecustomerModelFromJson(String str) => ServicecustomerModel.fromJson(json.decode(str));

String servicecustomerModelToJson(ServicecustomerModel data) => json.encode(data.toJson());

class ServicecustomerModel {
  int? code;
  String? message;
  Data? data;

  ServicecustomerModel({
    this.code,
    this.message,
    this.data,
  });

  factory ServicecustomerModel.fromJson(Map<String, dynamic> json) => ServicecustomerModel(
    code: json["code"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<ServiceRequest>? serviceRequest;
  Default? dataDefault;

  Data({
    this.serviceRequest,
    this.dataDefault,
  });


  factory Data.fromJson(Map<String, dynamic> json) => Data(
    serviceRequest: json["serviceRequest"] == null ? [] : List<ServiceRequest>.from(json["serviceRequest"]!.map((x) => ServiceRequest.fromJson(x))).reversed.toList(),
    dataDefault: json["default"] == null ? null : Default.fromJson(json["default"]),
  );

  Map<String, dynamic> toJson() => {
    "serviceRequest": serviceRequest == null ? [] : List<dynamic>.from(serviceRequest!.map((x) => x.toJson())),
    "default": dataDefault?.toJson(),
  };
}

class Default {
  List<Dealer>? dealer;
  List<RequestType>? requestType;

  Default({
    this.dealer,
    this.requestType,
  });

  factory Default.fromJson(Map<String, dynamic> json) => Default(
    dealer: json["dealer"] == null ? [] : List<Dealer>.from(json["dealer"]!.map((x) => Dealer.fromJson(x))),
    requestType: json["requestType"] == null ? [] : List<RequestType>.from(json["requestType"]!.map((x) => RequestType.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "dealer": dealer == null ? [] : List<dynamic>.from(dealer!.map((x) => x.toJson())),
    "requestType": requestType == null ? [] : List<dynamic>.from(requestType!.map((x) => x.toJson())),
  };
}

class Dealer {
  int? userId;
  String? userName;

  Dealer({
    this.userId,
    this.userName,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) => Dealer(
    userId: json["userId"],
    userName: json["userName"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "userName": userName,
  };
}

class RequestType {
  int? requestTypeId;
  String? requestType;
  String? requestDescription;
  String? active;

  RequestType({
    this.requestTypeId,
    this.requestType,
    this.requestDescription,
    this.active,
  });

  factory RequestType.fromJson(Map<String, dynamic> json) => RequestType(
    requestTypeId: json["requestTypeId"],
    requestType: json["requestType"],
    requestDescription: json["requestDescription"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "requestTypeId": requestTypeId,
    "requestType": requestType,
    "requestDescription": requestDescription,
    "active": active,
  };
}

class ServiceRequest {
  int? requestTypeId;
  String? requestType;
  String? requestDescription;
  String? requestDate;
  String? requestTime;
  String? priority;
  int? responsibleUser;
  String? responsibleUserName;
  String? estimatedDate;
  String? status;
  String? closedDate;

  ServiceRequest({
    this.requestTypeId,
    this.requestType,
    this.requestDescription,
    this.requestDate,
    this.requestTime,
    this.priority,
    this.responsibleUser,
    this.responsibleUserName,
    this.estimatedDate,
    this.status,
    this.closedDate,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
    requestTypeId: json["requestTypeId"],
    requestType: json["requestType"],
    requestDescription: json["requestDescription"],
    requestDate: json["requestDate"],
    requestTime: json["requestTime"],
    priority: json["priority"],
    responsibleUser: json["responsibleUser"],
    responsibleUserName: json["responsibleUserName"],
    estimatedDate: json["estimatedDate"],
    status: json["status"],
    closedDate: json["closedDate"],
  );

  Map<String, dynamic> toJson() => {
    "requestTypeId": requestTypeId,
    "requestType": requestType,
    "requestDescription": requestDescription,
    "requestDate": requestDate,
    "requestTime": requestTime,
    "priority": priority,
    "responsibleUser": responsibleUser,
    "responsibleUserName": responsibleUserName,
    "estimatedDate": estimatedDate,
    "status": status,
    "closedDate": closedDate,
  };
}
