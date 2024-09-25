class ProductStockModel
{
  int productId, warranty;
  String categoryName, model, dtOfMnf, imeiNo;

  ProductStockModel({
    this.productId = 0,
    this.categoryName = '',
    this.model = '',
    this.imeiNo = '',
    this.dtOfMnf = '',
    this.warranty = 0,
  });

  factory ProductStockModel.fromJson(Map<String, dynamic> json) => ProductStockModel(
    productId: json['productId'],
    categoryName: json['categoryName'],
    model: json['model'],
    imeiNo: json['imeiNo'],
    dtOfMnf: json['dtOfMnf'],
    warranty: json['warranty'],
  );
}