import 'dart:convert';
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mobile_view/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/Dealer/CustomerProductModel.dart';
import '../../Models/Dealer/ProductStockModel.dart';
import '../../constants/http_service.dart';


enum MasterController {gem1, gem2, gem3, gem4, gem5, gem6, gem7, gem8, gem9, gem10,}

class DeviceList extends StatefulWidget {
  final int customerID, userID, userType;
  final String userName;
  final List<ProductStockModel> productStockList;
  final void Function(String) callback;
  const DeviceList({super.key, required this.customerID, required this.userName, required this.userID, required this.userType, required this.productStockList, required this.callback});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> with SingleTickerProviderStateMixin
{
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> productSalesList = {};
  bool checkboxValue = false;

  List<CustomerProductModel> customerProductList = <CustomerProductModel>[];
  List<ProductStockModel> myMasterControllerList = <ProductStockModel>[];

  List<ProductStockModel> nodeStockList = <ProductStockModel>[];


  int selectedRadioTile = 0;
  final ValueNotifier<MasterController> _selectedItem = ValueNotifier<MasterController>(MasterController.gem1);
  final TextEditingController _textFieldSiteName = TextEditingController();
  final TextEditingController _textFieldSiteDisc = TextEditingController();

 // final List<InterfaceModel> interfaceType = <InterfaceModel>[];
  List<int> selectedProduct = [];

  bool checkboxValueNode = false;
  final List<String> _interfaceInterval = ['0 sec', '5 sec', '10 sec', '20 sec', '30 sec', '45 sec','1 min','5 min','10 min','30 min','1 hr']; // Option 2
  //List<CustomerListMDL> myCustomerChildList = <CustomerListMDL>[];
  List<int> nodeStockSelection = [];
  int currentSiteInx = 0;
  int currentMstInx = 0;
  bool visibleLoading = false;


  @override
  void initState() {
    super.initState();
    print(widget.userType);
    initFunction();
  }

  Future<void> initFunction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedRadioTile = 0;
    getCustomerType();

    selectedProduct.clear();
    for(int i=0; i<widget.productStockList.length; i++){
      selectedProduct.add(0);
    }
  }



  void resetPopop(){
    checkboxValue = false;
  }

  void removeProductStockById(int productId) {
    widget.productStockList.removeWhere((productStock) => productStock.productId == productId);
  }

  Future<void> getCustomerType() async
  {
    getMyAllProduct();
  }

  Future<void> getMyAllProduct() async
  {
    indicatorViewShow();
    final body = widget.userType == 1 ? {"fromUserId": widget.userID, "toUserId": widget.customerID ,"set":1, "limit":100} : {"fromUserId": widget.userID, "toUserId": widget.customerID, "set":1, "limit":100};
    final response = await HttpService().postRequest("getCustomerProduct", body);
    if (response.statusCode == 200)
    {
      customerProductList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"]['product'] as List;
        for (int i=0; i < cntList.length; i++) {
          customerProductList.add(CustomerProductModel.fromJson(cntList[i]));
        }
        indicatorViewHide();
      }
    }
    else{
      indicatorViewHide();
    }
  }

  void indicatorViewShow() {
    if(mounted){
      setState(() {
        visibleLoading = true;
      });
    }
  }

  void indicatorViewHide() {
    if(mounted){
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          visibleLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.userName,  style: TextStyle(color: Colors.white),),
        backgroundColor: myTheme.primaryColor,
        actions: [
          PopupMenuButton(
            tooltip: 'Add Product',
            child: MaterialButton(
              onPressed:null,
              textColor: Colors.black54,
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 3),
                  Text('Product', style: TextStyle(color: Colors.white),),
                ],
              ),
            ),
            onCanceled: () {
              checkboxValue = false;
            },
            itemBuilder: (context) {
              return List.generate(myMasterControllerList.length+1 ,(index) {
                if(myMasterControllerList.isEmpty){
                  return const PopupMenuItem(
                    child: Text('No master controller available to create site'),
                  );
                }
                else if(myMasterControllerList.length == index){
                  return PopupMenuItem(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          color: Colors.red,
                          textColor: Colors.white,
                          child: const Text('CANCEL'),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                        ),
                        MaterialButton(
                          color: Colors.green,
                          textColor: Colors.white,
                          child: const Text('CREATE'),
                          onPressed: () async {
                            Navigator.pop(context);
                            _displayCustomerSiteDialog(context, myMasterControllerList[selectedRadioTile].categoryName,
                                myMasterControllerList[selectedRadioTile].model,
                                myMasterControllerList[selectedRadioTile].imeiNo.toString());
                          },
                        ),
                      ],
                    ),
                  );
                }
                return PopupMenuItem(
                  value: index,
                  child: AnimatedBuilder(
                      animation: _selectedItem,
                      builder: (context, child) {
                        return RadioListTile(
                          value: MasterController.values[index],
                          groupValue: _selectedItem.value,
                          title: child,  onChanged: (value) {
                          _selectedItem.value = value!;
                          selectedRadioTile = value.index;
                        },
                          subtitle: Text(myMasterControllerList[index].model),
                        );
                      },
                      child: Text(myMasterControllerList[index].categoryName)

                  ),
                );
              },);
            },
          ),
          const SizedBox(width: 20,),
        ],
      ),
      body: visibleLoading? Visibility(
        visible: visibleLoading,
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 25, 0, MediaQuery.sizeOf(context).width/2 - 25, 0),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 700,
            columns: [
              const DataColumn2(
                  label: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold),),
                  fixedWidth: 50
              ),
              const DataColumn2(
                label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold),),
                size: ColumnSize.L,
              ),
              const DataColumn2(
                label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold),),
                size: ColumnSize.L,
              ),
              const DataColumn2(
                label: Text('IMEI', style: TextStyle(fontWeight: FontWeight.bold),),
                size: ColumnSize.L,
              ),
              const DataColumn2(
                label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              const DataColumn2(
                label: Text('Modify Date', style: TextStyle(fontWeight: FontWeight.bold),),
                fixedWidth: 100,
              ),
              DataColumn2(
                label: const Text('Action', style: TextStyle(fontWeight: FontWeight.bold),),
                fixedWidth: widget.userType==2 ? 70 : 0,
              ),
            ],
            rows: List<DataRow>.generate(customerProductList.length, (index) => DataRow(cells: [
              DataCell(Text('${index+1}')),
              DataCell(Text(customerProductList[index].categoryName)),
              DataCell(Text(customerProductList[index].model)),
              DataCell(Text(customerProductList[index].deviceId)),
              //DataCell(widget.userType==2 ? Text(widget.customerProductList[index].siteName) : widget.customerProductList[index].buyer == widget.userName? const Text('-') : Text(widget.customerProductList[index].buyer)),
              DataCell(
                  Center(
                    child: widget.userType == 1? Row(
                      children: [
                        CircleAvatar(radius: 5,
                          backgroundColor:
                          customerProductList[index].productStatus==1? Colors.pink:
                          customerProductList[index].productStatus==2? Colors.blue:
                          customerProductList[index].productStatus==3? Colors.purple:
                          //customerProductList[index].productStatus==4? Colors.yellow:
                          //customerProductList[index].productStatus==5? Colors.deepOrangeAccent:
                          Colors.green,
                        ),
                        const SizedBox(width: 5,),
                        customerProductList[index].productStatus==1? const Text('In-Stock'):
                        customerProductList[index].productStatus==2? const Text('Stock'):
                        customerProductList[index].productStatus==3? const Text('Sold-Out'):
                        //customerProductList[index].productStatus==4? const Text('Pending'):
                        //customerProductList[index].productStatus==5? const Text('Installed'):
                        const Text('Active'),
                      ],
                    ) :
                    widget.userType == 2? Row(
                      children: [
                        CircleAvatar(radius: 5,
                          backgroundColor:
                          customerProductList[index].productStatus==2? Colors.pink:
                          customerProductList[index].productStatus==3? Colors.blue:
                          //customerProductList[index].productStatus==4? Colors.yellow:
                          //customerProductList[index].productStatus==5? Colors.deepOrangeAccent:
                          Colors.green,
                        ),
                        const SizedBox(width: 5,),
                        customerProductList[index].productStatus==2? const Text('In-Stock'):
                        customerProductList[index].productStatus==3? const Text('Stock'):
                        //customerProductList[index].productStatus==4? const Text('Pending'):
                        //customerProductList[index].productStatus==5? const Text('Installed'):
                        const Text('Active'),
                      ],
                    ) :
                    Row(
                      children: [
                        CircleAvatar(radius: 5,
                          backgroundColor:
                          customerProductList[index].productStatus==3? Colors.pink:
                          //customerProductList[index].productStatus==4? Colors.yellow:
                          //customerProductList[index].productStatus==5? Colors.deepOrangeAccent:
                          Colors.green,
                        ),
                        const SizedBox(width: 5,),
                        customerProductList[index].productStatus==3? const Text('In-Stock'):
                        //customerProductList[index].productStatus==4? const Text('Pending'):
                        //customerProductList[index].productStatus==5? const Text('Installed'):
                        const Text('Active'),
                      ],
                    ),
                  )
              ),
              DataCell(Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(customerProductList[index].modifyDate)))),
              widget.userType==2 ? DataCell(Center(child:
              customerProductList[index].productStatus==2||customerProductList[index].productStatus==3? IconButton(tooltip:'Remove product',onPressed: () {
                print('${customerProductList[index].productId}');

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Remove Product'),
                      content: Text('Are you sure you want to remove the ${customerProductList[index].categoryName}?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: Text('Remove'),
                          onPressed: () {
                            getMyAllProduct();
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    );
                  },
                );

              }, icon: const Icon(Icons.remove_circle_outline, color:  Colors.red,),):const Text('--'))) : DataCell.empty,
            ]))),
      ),

    );
  }

  Future<void> _displayCustomerSiteDialog(BuildContext context, String ctrlName, String ctrlModel, String ctrlIemi) async {
    return showDialog(context: context,  builder: (context) {
      return AlertDialog(
        title: const Text('Create Customer Site'),
        content: SizedBox(
          height: 223,
          child : Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const CircleAvatar(),
                  title: Text(ctrlName),
                  subtitle: Text('$ctrlModel\n$ctrlIemi'),
                ),
                TextFormField(
                  controller: _textFieldSiteName,
                  decoration: const InputDecoration(hintText: "Enter your site name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _textFieldSiteDisc,
                  decoration: const InputDecoration(hintText: "Description"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            child: const Text('CANCEL'),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            child: const Text('CREATE'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Map<String, dynamic> body = {
                  "userId": widget.customerID,
                  "dealerId": widget.userID,
                  "productId": myMasterControllerList[selectedRadioTile].productId,
                  "categoryName": myMasterControllerList[selectedRadioTile].categoryName,
                  "createUser": widget.userID,
                  "groupName": _textFieldSiteName.text,
                };
                final response = await HttpService().postRequest("createUserGroupAndDeviceList", body);
                if(response.statusCode == 200)
                {
                  var data = jsonDecode(response.body);
                  if(data["code"]==200)
                  {
                    //getCustomerSite();
                    //getMasterProduct();
                    //getNodeStockList();
                    if(mounted){
                      Navigator.pop(context);
                    }

                  }
                  else{
                    //_showSnackBar(data["message"]);
                    //_showAlertDialog('Warning', data["message"]);
                  }
                }
              }
            },
          ),
        ],
      );
    });
  }


  List<int> missingArray(List<int> no) {
    List<int> missingValues = [];
    if(no.isNotEmpty){
      int n = no.reduce(max);
      List<int> intArray = List.generate(n, (index) => index + 1);
      for (var value in intArray) {
        if (!no.contains(value)) {
          missingValues.add(value);
        }
      }
    }
    return missingValues;
  }

  String convertToHHmmss(String timeString)
  {
    List<String> parts = timeString.split(' ');
    int quantity = int.parse(parts[0]);
    String unit = parts[1];

    int seconds;
    switch (unit) {
      case 'sec':
        seconds = quantity;
        break;
      case 'min':
        seconds = quantity * 60;
        break;
      case 'hr':
        seconds = quantity * 3600;
        break;
      default:
        return 'Invalid input';
    }

    String formattedTime = formatSecondsToTime(seconds);

    return formattedTime;
  }

  String formatSecondsToTime(int seconds) {
    // Calculate hours, minutes, and remaining seconds
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    // Format as HH:mm:ss
    String formattedTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

}