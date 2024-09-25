class CustomerProductModel
{
  int productId, productStatus;
  String categoryName, model, deviceId, siteName, modifyDate;

  CustomerProductModel({
    this.productId = 0,
    this.productStatus = 0,
    this.categoryName ='',
    this.model = '',
    this.deviceId = '',
    this.siteName = '',
    this.modifyDate = '',
  });

  factory CustomerProductModel.fromJson(Map<String, dynamic> json) => CustomerProductModel(
    productId: json['prdId'],
    productStatus: json['prdStatus'],
    categoryName: json['catName'],
    model: json['mdl'],
    deviceId: json['dvcId'],
    siteName: json['siteName'] ?? '',
    modifyDate: json['mDate'],
  );

}