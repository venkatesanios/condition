import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mobile_view/screens/Customer/Dashboard/Mobile%20Dashboard/home_screen.dart';
import 'package:mobile_view/screens/UserChat/user_chat.dart';
import 'package:mobile_view/state_management/MqttPayloadProvider.dart';
import 'package:mobile_view/state_management/overall_use.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/Dealer/CustomerListMDL.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import 'CreateAccount.dart';
import 'DeviceList.dart';
import 'MyPreference.dart';


enum Calendar {day, week, month, year}
typedef CallbackFunction = void Function(String result);

class DealerDashboard extends StatefulWidget {
  const DealerDashboard({Key? key, required this.userName, required this.countryCode, required this.mobileNo, required this.userId, required this.emailId}) : super(key: key);

  final String userName, countryCode, mobileNo, emailId;
  final int userId;

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {

  Calendar calendarView = Calendar.day;
  List<CustomerListMDL> myCustomerList = <CustomerListMDL>[];
  List<CustomerListMDL> filteredCustomerList = [];

  String selectedValue = 'All';
  List<String> dropdownItems = ['All', 'Last year', 'Last month', 'Last Week'];
  bool visibleLoading = false;

  bool searched = false;
  TextEditingController txtFldSearch = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getCustomerList();
  }

  void callbackFunction(String message)
  {
    Future.delayed(const Duration(milliseconds: 500), () {
      getCustomerList();
    });
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
      setState(() {
        visibleLoading = false;
      });
    }
  }




  Future<void> getCustomerList() async {
    indicatorViewShow();
    Map<String, Object> body = {"userType" : 2, "userId" : widget.userId};
    final response = await HttpService().postRequest("getUserList", body);
    if (response.statusCode == 200) {
      myCustomerList.clear();
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        final cntList = data["data"] as List;
        List<CustomerListMDL> tempList = [];
        for (int i = 0; i < cntList.length; i++) {
          tempList.add(CustomerListMDL.fromJson(cntList[i]));
        }
        indicatorViewHide();
        setState(() {
          myCustomerList.addAll(tempList);
          filteredCustomerList = myCustomerList;
          tempList=[];
        });
      }
    } else {
      indicatorViewHide();
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss on tap outside
      builder: (context) => AlertDialog(
        title: Text("Exit"),
        content: Text("Do you want to exit?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => exit(0),
            // onPressed: () => Navigator.of(context).pop(true),// Return true to pop the route
            child: Text(
              "Yes",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(false), // Return false to stay on the route
            child: Text(
              "No",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false; // Handle null case by returning false (stay on the route)
  }

  @override
  Widget build(BuildContext context)
  {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        bool canPop = await _onWillPop(context);
        if (canPop) {
          Navigator.pop(context);
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:  Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          backgroundColor: myTheme.primaryColor,
          actions: <Widget>[
            IconButton(onPressed:() {
              MQTTManager().onDisconnected();
              if (mounted){
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPreference(userID: widget.userId)));
              }
            }, icon: Icon(Icons.manage_accounts_outlined, color: Colors.white,)),
            IconButton(onPressed:() async{
              var payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
              var overAllPvd = Provider.of<OverAllUse>(context, listen: false);
              MQTTManager().onDisconnected();
              Future.delayed(Duration.zero, () {
                payloadProvider.clearData();
                overAllPvd.userId = 0;
                overAllPvd.controllerId = 0;
                overAllPvd.controllerType = 0;
                overAllPvd.imeiNo = '';
                overAllPvd.customerId = 0;
                overAllPvd.sharedUserId = 0;
                overAllPvd.takeSharedUserId = false;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              await prefs.remove('userName');
              await prefs.remove('userType');
              await prefs.remove('countryCode');
              await prefs.remove('mobileNumber');
              await prefs.remove('subscribeTopic');
              if (mounted){
                Navigator.pushReplacementNamed(context, '/loginOTP');
              }
            }, icon: Icon(Icons.logout, color: Colors.redAccent,)),
          ],
          //scrolledUnderElevation: 5.0,
          //shadowColor: Theme.of(context).colorScheme.shadow,
        ),
        body: visibleLoading? Visibility(
          visible: visibleLoading,
          child: Container(
            height: height,
            color: Colors.transparent,
            padding: EdgeInsets.fromLTRB(width/2 - 30, 0, width/2 - 30, 0),
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            ),
          ),
        ):
        SizedBox(
          width: width,
          child: Column(
            children: [
              searched?ListTile(
                title: TextField(
                  controller: txtFldSearch,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red,),
                        onPressed: () {
                          searched = false;
                          filteredCustomerList = myCustomerList;
                          _focusNode.unfocus();
                          txtFldSearch.clear();
                          setState(() {
                          });
                        },
                      ),
                      hintText: 'Search by name',
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      filteredCustomerList = myCustomerList.where((customer) {
                        return customer.userName.toLowerCase().startsWith(value.toLowerCase());
                      }).toList();
                    });
                  },
                ),
              ):
              ListTile(
                title: const Text('My Customer', style: TextStyle(fontSize: 17)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    myCustomerList.length>30 ? IconButton(tooltip: 'Search Customer', icon: const Icon(Icons.search), color: myTheme.primaryColor, onPressed: () async
                    {
                      setState(() {
                        searched=true;
                        _focusNode.requestFocus();
                      });
                    }):
                    const SizedBox(),
                    IconButton(tooltip: 'Create Customer account', icon: const Icon(Icons.person_add_outlined), color: myTheme.primaryColor, onPressed: () async
                    {
                      await showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: CreateAccount(callback: callbackFunction, subUsrAccount: false, customerId: widget.userId, from: 'Dealer',),
                          ));
                    }),
                  ],
                ),
              ),
              Expanded(
                  child : filteredCustomerList.isNotEmpty? ListView.builder(
                    itemCount: filteredCustomerList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final customer = filteredCustomerList[index];
                      return ListTile(
                        tileColor: Colors.white,
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
                          backgroundColor: Colors.transparent,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if((customer.criticalAlarmCount + customer.serviceRequestCount) > 0)
                              BadgeButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return  Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            color: Colors.teal.shade100,
                                            height: 30,
                                            child: Center(child: Text(customer.userName)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icons.hail,
                                badgeNumber: customer.criticalAlarmCount + customer.serviceRequestCount,
                              ),
                            IconButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserChatScreen(userId: customer.userId, dealerId: widget.userId, userName: customer.userName,)));
                                },
                                icon: Icon(Icons.chat)
                            ),
                            IconButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(userId: customer.userId, fromDealer: true)));
                                },
                                icon: Icon(Icons.space_dashboard)
                            ),
                          ],
                        ),
                        title: Text(customer.userName, style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                        subtitle: Text('+${customer.countryCode} ${customer.mobileNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                        onTap:() {
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  DeviceList(customerID: customer.userId, userName: customer.userName, userID: widget.userId, userType: 2, productStockList: [], callback: callbackFunction,)),);
                        },
                      );
                    },
                  ):
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Customers not found.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                          SizedBox(height: 5),
                          !searched?Text('Add your customer using top of the customer adding button.', style: TextStyle(fontWeight: FontWeight.normal)):
                          SizedBox(),
                          !searched?Icon(Icons.person_add_outlined):
                          SizedBox(),
                        ],
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BadgeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final int badgeNumber;

  const BadgeButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.badgeNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          tooltip: 'My alarm and Service request',
          onPressed: onPressed,
          icon: Icon(icon,),
        ),
        if (badgeNumber > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
