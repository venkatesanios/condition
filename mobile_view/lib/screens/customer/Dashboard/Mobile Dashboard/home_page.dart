import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/ListOfFertilizerInSet.dart';
import 'package:mobile_view/constants/theme.dart';
import 'package:mobile_view/screens/Customer/Planning/names_form.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Line%20Dashboard/irrigation_line_false.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/current_schedule.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/next_schedule.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/schedule_program.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/sidedrawer.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Source%20Pump%20Dashboard/source_pump_true.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Irrigation%20Pump%20Dashboard/irrigation_pump_true.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/mobile_dashboard_common_files.dart';
import 'package:mobile_view/state_management/MqttPayloadProvider.dart';
import 'package:provider/provider.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../constants/snack_bar.dart';
import '../../../../state_management/overall_use.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../stand_alone_operation.dart';
import '../../Planning/NewIrrigationProgram/schedule_screen.dart';
import '../PumpControllerScreens/pump_controller_dashboard.dart';
import 'Fertilizer Dashboard/fertilizer_site_false.dart';
import 'Fertilizer Dashboard/fertilizer_site_true.dart';
import 'Filter Dashboard/filtration_site_false.dart';
import 'Filter Dashboard/filtration_site_true.dart';
import 'Line Dashboard/irrigation_line_true.dart';
import 'NodeDetails/node_details.dart';
import 'NodeDetails/node_status.dart';
import 'Irrigation Pump Dashboard/irrigation_pump_false.dart';
import 'Source Pump Dashboard/source_pump_false.dart';
import 'dashboard_payload_handler.dart';

final double speed = 100.0;
final double gap = 100;
final double initialPosition = -100.0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  late MqttPayloadProvider payloadProvider;
  late OverAllUse overAllPvd;
  MQTTManager manager = MQTTManager();
  bool sourcePumpMode = false;
  bool irrigationLineMode = false;
  bool irrigationPumpMode = false;
  bool filtrationWidgetMode = false;
  bool fertigationWidgetMode = false;
  late Timer _timer;
  int selectedTab = 0;
  int userId = 0;
  double appBarHeight = 105.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    // mqttConfigureAndConnect();
    // if(payloadProvider.selectedSiteString == ''){
    //   getData();
    // }
    // // TODO: implement initState
    // _controller = AnimationController(
    //   duration: Duration(seconds: 1),
    //   vsync: this,
    // );
    // _controllerReverse = AnimationController(
    //   duration: Duration(seconds: 1),
    //   vsync: this,
    // );
    // _controller.addListener(() {
    //   setState(() {
    //
    //   });
    // });
    // _controller.repeat();
    // _controllerReverse.repeat(reverse: true);
    _timer = Timer.periodic(Duration(seconds: 15), (Timer timer){
      setState(() {
        irrigationLineMode = !irrigationLineMode;
        sourcePumpMode = !sourcePumpMode;
        irrigationPumpMode = !irrigationPumpMode;
        filtrationWidgetMode = !filtrationWidgetMode;
        fertigationWidgetMode = !fertigationWidgetMode;
      });
    });
    super.initState();
  }

  void getData() async{
    // print('//////////////////////////////////////////get function called//////////////////////////');
    if(payloadProvider.timerForCentralFertigation != null){
      setState(() {
        payloadProvider.timerForIrrigationPump!.cancel();
        payloadProvider.timerForSourcePump!.cancel();
        payloadProvider.timerForCentralFiltration!.cancel();
        payloadProvider.timerForLocalFiltration!.cancel();
        payloadProvider.timerForCentralFertigation!.cancel();
        payloadProvider.timerForLocalFertigation!.cancel();
        payloadProvider.timerForCurrentSchedule!.cancel();
      });
    }
    payloadProvider.clearData();
    final prefs = await SharedPreferences.getInstance();
    final userIdFromPref = prefs.getString('userId') ?? '';
    // payloadProvider.editLoading(true);
    try{
      HttpService service = HttpService();
      var getUserDetails = await service.postRequest('getCustomerDashboard', {'userId' : userIdFromPref,});
      var jsonData = jsonDecode(getUserDetails.body);
      if(jsonData['code'] == 200){
        payloadProvider.listOfSite = jsonData['data'];
        if(jsonData['data'].isNotEmpty){
          //Modified by saravanan
          await Future.delayed(Duration.zero, () {
            setState(() {
              payloadProvider.selectedSiteString = 'site-0';
              userId = int.parse(userIdFromPref);
              var selectedMasterData = payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster];
              overAllPvd.userId = userId;
              overAllPvd.imeiNo = selectedMasterData['deviceId'];
              overAllPvd.controllerId = selectedMasterData['controllerId'];
              overAllPvd.controllerType = selectedMasterData['categoryId'];
              overAllPvd.takeSharedUserId = false;
              if(selectedMasterData['irrigationLine'] != null){
                payloadProvider.editLineData(selectedMasterData['irrigationLine']);
              }
              payloadProvider.updateReceivedPayload(jsonEncode([3,4].contains(overAllPvd.controllerType) ? {"mC":"LD01",'cM' : selectedMasterData['liveMessage']} : selectedMasterData),true);
              payloadProvider.subscribeTopic = 'FirmwareToApp/${selectedMasterData['deviceId']}';
              payloadProvider.publishTopic = 'AppToFirmware/${selectedMasterData['deviceId']}';
              payloadProvider.publishMessage  = getPublishMessage();
            });
          });
          for(var i = 0;i < 2;i++){
            Future.delayed(Duration(seconds: 3),(){
              autoRefresh();
            });
          }
        }
      }
      try{
        var getSharedUserDetails = await service.postRequest('getSharedUserDeviceList', {'userId' : userIdFromPref,'sharedUser' : null});
        var jsonDataSharedDevice = jsonDecode(getSharedUserDetails.body);
        if(jsonDataSharedDevice['code'] == 200){
          payloadProvider.listOfSharedUser = jsonDataSharedDevice['data'];
          if(payloadProvider.listOfSite.isEmpty){
            if(payloadProvider.listOfSharedUser['devices'].isNotEmpty){
              setState(() {
                var selectedMasterData = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster];
                payloadProvider.selectedSiteString = 'sharedUser-0';
                payloadProvider.selectedMaster = 0;
                if(selectedMasterData['irrigationLine'] != null){
                  payloadProvider.editLineData(selectedMasterData['irrigationLine']);
                }
                overAllPvd.takeSharedUserId = true;
                overAllPvd.sharedUserId = jsonDataSharedDevice['data']['users'][0]['userId'];
                overAllPvd.imeiNo = selectedMasterData['deviceId'];
                overAllPvd.controllerId = selectedMasterData['controllerId'];
                overAllPvd.controllerType = selectedMasterData['categoryId'];
                payloadProvider.updateReceivedPayload(jsonEncode([3,4].contains(overAllPvd.controllerType) ? {"mC":"LD01",'cM' : selectedMasterData['liveMessage']} : selectedMasterData),true);
                payloadProvider.subscribeTopic = 'FirmwareToApp/${selectedMasterData['deviceId']}';
                payloadProvider.publishTopic = 'AppToFirmware/${selectedMasterData['deviceId']}';
                payloadProvider.publishMessage  = getPublishMessage();
              });
              for(var i = 0;i < 2;i++){
                Future.delayed(Duration(seconds: 3),(){
                  autoRefresh();
                });
              }
            }
          }

        }
      }catch(e,stackTrace){
        setState(() {
          payloadProvider.httpError = true;
        });
        print(' Error getSharedUserDeviceList  => ${e.toString()}');
        print(' trace getSharedUserDeviceList  => ${stackTrace}');
      }
      setState(() {
        payloadProvider.httpError = false;
      });
    }catch(e,stackTrace){
      setState(() {
        payloadProvider.httpError = true;
      });
      print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }
  }

  void mqttConfigureAndConnect() {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    manager.initializeMQTTClient(state: payloadProvider);
    manager.connect();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  dynamic getPublishMessage(){
    dynamic refersh = '';
    if(![3,4].contains(!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['categoryId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId'])){
      refersh = jsonEncode({"3000":[{"3001":""}]});
    }else{
      refersh = jsonEncode({"sentSms": "#live"});
    }
    return refersh;
  }

  void autoRefresh()async{
    // manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
    manager.publish(payloadProvider.publishMessage,'AppToFirmware/${overAllPvd.imeiNo}');
    setState(() {
      payloadProvider.tryingToGetPayload += 1;
    });
  }

  Future onRefresh() async{
    if(manager.isConnected){
      autoRefresh();
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(seconds: 5));
  }

  dynamic getLinePauseResumeMessage(code){
    var lineMessage = '';
    switch (code){
      case(0):{
        lineMessage = '';
      }
      case(1):{
        lineMessage = 'Paused Manually';
      }
      case(2):{
        lineMessage = 'Scheduled Program Paused By StandAlone Program';
      }
      case(3):{
        lineMessage = 'Paused By System Definition';
      }
      case(4):{
        lineMessage = 'Paused By LowFlow Alarm';
      }
      case(5):{
        lineMessage = 'Paused By HighFlow Alarm';
      }
      case(6):{
        lineMessage = 'Paused By NoFlow Alarm';
      }
      case(7):{
        lineMessage = 'Paused By EcHigh';
      }
      case(8):{
        lineMessage = 'Paused By PhLow';
      }
      case(9):{
        lineMessage = 'Paused By PhHigh';
      }
      case(10):{
        lineMessage = 'Paused By PressureLow';
      }
      case(11):{
        lineMessage = 'Paused By PressureHigh';
      }
      case(12):{
        lineMessage = 'Paused By No Power Supply';
      }
      case(13):{
        lineMessage = 'Paused By No Communication';
      }
    }
    return lineMessage;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryColorDark.withOpacity(0.15),
      statusBarIconBrightness: Brightness.dark,
    ));
    overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return (!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite.isNotEmpty : payloadProvider.listOfSharedUser['devices'].isNotEmpty)
        ? Scaffold(
      key: _scaffoldKey,
      backgroundColor: cardColor,
      floatingActionButton: ![3,4].contains(overAllPvd.controllerType) ? Container(
        padding: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0,-50),
                  blurRadius: 112,
                  color: Colors.black.withOpacity(0.06)
              ),
            ],
            // color: primaryColorDark,
            borderRadius: BorderRadius.only(topRight: Radius.circular(40),topLeft: Radius.circular(40))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if(payloadProvider.currentSchedule.isNotEmpty)
              InkWell(
                onTap: (){
                  setState(() {
                    selectedTab = 0;
                  });
                  sideSheet( payloadProvider: payloadProvider, selectedTab: selectedTab, overAllPvd: overAllPvd);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff95D394),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(30),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8))
                  ),
                  padding: const EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                  child: Text('Current\nSchedule',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
                ),
              ),
            if(payloadProvider.nextSchedule.isNotEmpty)
              InkWell(
                onTap: (){
                  setState(() {
                    selectedTab = 1;
                  });
                  sideSheet( payloadProvider: payloadProvider, selectedTab: selectedTab, overAllPvd: overAllPvd);

                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffFF9A49),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(30),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8))
                  ),
                  padding: const EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                  child: Text('Next\nSchedule',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
                ),
              ),
            InkWell(
              onTap: (){
                setState(() {
                  selectedTab = 2;
                });
                sideSheet( payloadProvider: payloadProvider, selectedTab: selectedTab, overAllPvd: overAllPvd);

              },
              child: Container(
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   fit: BoxFit.fill,
                  //   image: AssetImage(
                  //     'assets/images/schedule.png'
                  //   )
                  // ),
                    color: Color(0xff69BCFC),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(30),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8))
                ),
                padding: const EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                child: Text('Scheduled\nProgram',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
              ),
            ),
          ],
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //Modified by saravanan
      drawer: !overAllPvd.fromDealer ? DrawerWidget(listOfSite: payloadProvider.listOfSite, manager: manager,) : Container(),
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(
      //       (payloadProvider.listOfSite.isNotEmpty
      //           ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'].length > 1 || [1,2].contains(overAllPvd.controllerType)
      //           : true)
      //           ? appBarHeight
      //           : 60) * getTextScaleFactor(context),
      //   child: AppBar(
      //     backgroundColor: primaryColorDark.withOpacity(0.1),
      //     title: InkWell(
      //       onTap: (){
      //         showModalBottomSheet(
      //             context: context,
      //             builder: (BuildContext context){
      //               return StatefulBuilder(builder: (context, StateSetter stateSetter) {
      //                 return Container(
      //                   height: 400,
      //                   decoration: BoxDecoration(
      //                       color: Colors.white,
      //                       borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
      //                   ),
      //                   child: Column(
      //                     children: [
      //                       Padding(
      //                         padding: const EdgeInsets.all(8.0),
      //                         child: Text('List of Site',style: TextStyle(fontSize: 20),),
      //                       ),
      //                       Expanded(
      //                         child: SingleChildScrollView(
      //                           child: Column(
      //                             children: [
      //                               for(var site = 0;site < payloadProvider.listOfSite.length;site++)
      //                                 ListTile(
      //                                   title: Text(payloadProvider.listOfSite[site]['groupName']),
      //                                   trailing: IntrinsicWidth(
      //                                     child: Radio(
      //                                       value: 'site-${site}',
      //                                       groupValue: payloadProvider.selectedSiteString,
      //                                       onChanged: (value) {
      //                                         stateSetter((){
      //                                           setState(() {
      //                                             var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
      //                                             payloadProvider.selectedSite = site;
      //                                             payloadProvider.selectedSiteString = value!;
      //                                             payloadProvider.selectedMaster = 0;
      //                                             overAllPvd.takeSharedUserId = false;
      //                                             print("payloadProvider.listOfSite => ${payloadProvider.listOfSite}");
      //                                             var selectedMasterData = payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster];
      //                                             overAllPvd.imeiNo = selectedMasterData['deviceId'];
      //                                             overAllPvd.controllerId = selectedMasterData['controllerId'];
      //                                             overAllPvd.controllerType = selectedMasterData['categoryId'];
      //                                             if(selectedMasterData['irrigationLine'] != null){
      //                                               payloadProvider.editLineData(selectedMasterData['irrigationLine']);
      //                                             }
      //                                             manager.unSubscribe(
      //                                               unSubscribeTopic: unSubscribeTopic,
      //                                               subscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
      //                                               publishTopic: 'AppToFirmware/${overAllPvd.imeiNo}',
      //                                               publishMessage: getPublishMessage(),
      //                                             );
      //                                             payloadProvider.updateReceivedPayload(jsonEncode([3,4].contains(overAllPvd.controllerType) ? {"mC":"LD01",'cM' : selectedMasterData['liveMessage']} : selectedMasterData),true);
      //                                             manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
      //
      //                                             Future.delayed(Duration(milliseconds: 300),(){
      //                                               Navigator.pop(context);
      //                                             });
      //                                           });
      //                                         });
      //                                       },
      //                                     ),
      //                                   ),
      //                                 ),
      //                               if(payloadProvider.listOfSharedUser.isNotEmpty)
      //                                 for(var sharedUser = 0;sharedUser < payloadProvider.listOfSharedUser['users'].length;sharedUser++)
      //                                   if(payloadProvider.listOfSharedUser['devices'].isNotEmpty)
      //                                     ListTile(
      //                                       title: Text(payloadProvider.listOfSharedUser['users'][sharedUser]['userName']),
      //                                       trailing: IntrinsicWidth(
      //                                         child: Radio(
      //                                           value: 'sharedUser-${sharedUser}',
      //                                           groupValue: payloadProvider.selectedSiteString,
      //                                           onChanged: (value) async{
      //                                             try{
      //                                               // print('before => ${overAllPvd.userId}');
      //                                               HttpService service = HttpService();
      //                                               var getSharedUserDetails = await service.postRequest('getSharedUserDeviceList', {'userId' : overAllPvd.userId,"sharedUser" : payloadProvider.listOfSharedUser['users'][sharedUser]['userId']});
      //                                               stateSetter((){
      //                                                 setState((){
      //                                                   var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
      //                                                   payloadProvider.selectedSite = sharedUser;
      //                                                   payloadProvider.selectedSiteString = value!;
      //                                                   payloadProvider.selectedMaster = 0;
      //                                                   var jsonDataSharedDevice = jsonDecode(getSharedUserDetails.body);
      //                                                   // print('code is =======================       ${jsonDataSharedDevice['code']}      ========================');
      //                                                   if(jsonDataSharedDevice['code'] == 200){
      //                                                     payloadProvider.listOfSharedUser = jsonDataSharedDevice['data'];
      //                                                     // print('getSharedUserDeviceList : ${payloadProvider.listOfSharedUser}');
      //                                                     if(payloadProvider.listOfSharedUser['devices'].isNotEmpty){
      //                                                       setState(() {
      //                                                         payloadProvider.selectedMaster = 0;
      //                                                         var imeiNo = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId'];
      //                                                         var controllerId = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId'];
      //                                                         overAllPvd.sharedUserId = jsonDataSharedDevice['data']['users'][0]['userId'];
      //                                                         overAllPvd.takeSharedUserId = true;
      //                                                         overAllPvd.imeiNo = imeiNo;
      //                                                         overAllPvd.controllerId = controllerId;
      //                                                         overAllPvd.controllerType = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId'];
      //                                                         if(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine'] != null){
      //                                                           payloadProvider.editLineData(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine']);
      //                                                         }
      //                                                         payloadProvider.updateReceivedPayload(jsonEncode([3,4].contains(overAllPvd.controllerType) ? {"mC":"LD01",'cM' : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveMessage']} : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]),true);
      //                                                         payloadProvider.editSubscribeTopic('FirmwareToApp/$imeiNo');
      //                                                         payloadProvider.editPublishTopic('AppToFirmware/$imeiNo');
      //                                                         payloadProvider.editPublishMessage(getPublishMessage());
      //                                                         manager.unSubscribe(
      //                                                             unSubscribeTopic: unSubscribeTopic,
      //                                                             subscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
      //                                                             publishTopic: 'AppToFirmware/${overAllPvd.imeiNo}',
      //                                                             publishMessage: getPublishMessage()
      //                                                         );
      //                                                         manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
      //                                                         Future.delayed(Duration(milliseconds: 300),(){
      //                                                           Navigator.pop(context);
      //                                                         });
      //                                                       });
      //                                                       for(var i = 0;i < 2;i++){
      //                                                         Future.delayed(Duration(seconds: 3),(){
      //                                                           autoReferesh();
      //                                                         });
      //                                                       }
      //                                                     }
      //                                                   }
      //                                                   overAllPvd.editImeiNo(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId']);
      //                                                   overAllPvd.editControllerId(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId']);
      //                                                   overAllPvd.editControllerType(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId']);
      //                                                 });
      //                                               });
      //                                             }catch(e,stackTrace){
      //                                               setState(() {
      //                                                 payloadProvider.httpError = true;
      //                                               });
      //                                               // print(' Site selecting Error getSharedUserDeviceList  => ${e.toString()}');
      //                                               // print(' Site selecting trace getSharedUserDeviceList  => ${stackTrace}');
      //                                             }
      //                                             // print('after => ${overAllPvd.userId}');
      //
      //                                           },
      //                                         ),
      //                                       ),
      //                                     ),
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 );
      //               });
      //             }
      //         );
      //       },
      //       child: SizedBox(
      //         width: MediaQuery.of(context).size.width * 0.5,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text('${!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['groupName'] : payloadProvider.listOfSharedUser['users'][payloadProvider.selectedSite]['userName']}',style: TextStyle(fontSize: 14,overflow: TextOverflow.ellipsis,fontWeight: FontWeight.bold),),
      //                 Text('Last Sync : \n${payloadProvider.lastUpdate.day}/${payloadProvider.lastUpdate.month}/${payloadProvider.lastUpdate.year} ${payloadProvider.lastUpdate.hour}:${payloadProvider.lastUpdate.minute}:${payloadProvider.lastUpdate.second}',style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 12,overflow: TextOverflow.ellipsis),),
      //               ],
      //             ),
      //             SizedBox(
      //               width: 15,
      //                 child: Icon(Icons.arrow_drop_down_sharp)
      //             )
      //           ],
      //         ),
      //       ),
      //     ),
      //     //Modified by saravanan
      //     bottom : (payloadProvider.listOfSite.isNotEmpty
      //         ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'].length > 1 || [1,2].contains(overAllPvd.controllerType)
      //         : true)
      //         ? PreferredSize(
      //       preferredSize: Size.fromHeight(40),
      //       child: Container(
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20))
      //         ),
      //         padding: const EdgeInsets.all(8.0),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Container(
      //               padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
      //               decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(8),
      //                   color: primaryColorDark
      //               ),
      //               child: PopupMenuButton<int>(
      //                 offset: Offset(0,50),
      //                 child: Row(
      //                   children: [
      //                     SizedBox(
      //                       width: 30,
      //                       height: 30,
      //                       child: Image.asset('assets/images/choose_controller.png'),
      //                     ),
      //                     // Text('${(!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['deviceName'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceName'])}\n'
      //                     //     '${(!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['deviceId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId'])}',style: TextStyle(fontSize: 12,color: Colors.white),),
      //                     Column(
      //                       children: [
      //                         SizedBox(
      //                           width: MediaQuery.of(context).size.width * 0.3,
      //                           child: Text('${(!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['deviceName'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceName'])}'
      //                             ,style: TextStyle(fontSize: 12,color: Colors.white,overflow: TextOverflow.ellipsis),),
      //                         ),
      //                         Row(
      //                           children: [
      //                             Icon(Icons.wifi,color: Colors.orange,size: 20,),
      //                             SizedBox(width: 10,),
      //                             Text('${payloadProvider.wifiStrength}',style: TextStyle(color: Colors.white),)
      //                           ],
      //                         )
      //                       ],
      //                     ),
      //                   ],
      //                 ),
      //                 initialValue: payloadProvider.selectedMaster,
      //                 onSelected: (int master) {
      //                   setState(() {
      //                     payloadProvider.selectedMaster = master;
      //                   });
      //                 },
      //                 itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
      //                   for(var master = 0;master < (!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'] : payloadProvider.listOfSharedUser['devices']).length;master++)
      //                     PopupMenuItem<int>(
      //                       value: master,
      //                       child: Text('${(!overAllPvd.takeSharedUserId
      //                           ? '${payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][master]['deviceName']}\n${payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][master]['deviceId']}'
      //                           : '${payloadProvider.listOfSharedUser['devices'][master]['deviceName']}\n${payloadProvider.listOfSharedUser['devices'][master]['deviceId']}')}'),
      //                       onTap: ()async{
      //                         print(payloadProvider.listOfSharedUser['devices'].length);
      //                         var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
      //                         payloadProvider.selectedMaster = master;
      //                         overAllPvd.editImeiNo((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['deviceId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId']));
      //                         overAllPvd.editControllerType((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['categoryId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId']));
      //                         overAllPvd.editControllerId((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['controllerId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId']));
      //                         var selectedMaster = !overAllPvd.takeSharedUserId
      //                             ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]
      //                             : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster];
      //                         payloadProvider.updateReceivedPayload(
      //                             jsonEncode([3,4].contains(overAllPvd.controllerType)
      //                                 ? {"mC":"LD01",'cM' : selectedMaster['liveMessage']} : selectedMaster),true);
      //                         manager.unSubscribe(
      //                             unSubscribeTopic: unSubscribeTopic,
      //                             subscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
      //                             publishTopic: 'AppToFirmware/${overAllPvd.imeiNo}',
      //                             publishMessage: getPublishMessage()
      //                         );
      //
      //                         for(var i = 0;i < 5;i++){
      //                           await Future.delayed(Duration(seconds: 3));
      //                           autoReferesh();
      //                         }
      //                       },
      //                     ),
      //                 ],
      //               ),
      //             ),
      //             if(![3,4].contains(overAllPvd.controllerType))
      //               Container(
      //                 padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
      //                 decoration: BoxDecoration(
      //                     borderRadius: BorderRadius.circular(8),
      //                     color: Colors.white
      //                 ),
      //                 child: PopupMenuButton<int>(
      //                   offset: Offset(0,50),
      //                   child: Row(
      //                     children: [
      //                       SizedBox(
      //                         width: 30,
      //                         height: 30,
      //                         child: Image.asset('assets/images/irrigation_line1.png'),
      //                       ),
      //                       SizedBox(
      //                         width: MediaQuery.of(context).size.width * 0.3,
      //                           child: Text(' ${payloadProvider.lineData[payloadProvider.selectedLine]['name']}',style: TextStyle(fontSize: 12,color: Colors.black,overflow: TextOverflow.ellipsis),)
      //                       ),
      //                     ],
      //                   ),
      //                   initialValue: payloadProvider.selectedLine,
      //                   onSelected: (int line) {
      //                     setState(() {
      //                       payloadProvider.selectedLine = line;
      //                     });
      //                   },
      //                   itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
      //                     for(var line = 0;line < payloadProvider.lineData.length;line++)
      //                       PopupMenuItem<int>(
      //                         value: line,
      //                         child: Text('${payloadProvider.lineData[line]['name']}'),
      //                         onTap: (){
      //                           setState(() {
      //                             payloadProvider.selectedLine = line;
      //                           });
      //                         },
      //                       ),
      //                   ],
      //                 ),
      //               ),
      //             if(![3,4].contains(overAllPvd.controllerType))
      //               InkWell(
      //                 onTap:  (){
      //                   showModalBottomSheet(
      //                     context: context,
      //                     builder: (BuildContext context) {
      //                       return Consumer<MqttPayloadProvider>(
      //                         builder: (context, payloadProvider, child) {
      //                           return Container(
      //                             height: 300,
      //                             decoration: BoxDecoration(
      //                               color: Colors.white,
      //                               borderRadius: BorderRadius.only(
      //                                 topLeft: Radius.circular(20),
      //                                 topRight: Radius.circular(20),
      //                               ),
      //                             ),
      //                             child: Column(
      //                               children: [
      //                                 Row(
      //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                   children: [
      //                                     Padding(
      //                                       padding: const EdgeInsets.symmetric(horizontal: 10),
      //                                       child: Text(
      //                                         'Alarms',
      //                                         style: TextStyle(fontSize: 20),
      //                                       ),
      //                                     ),
      //                                     IconButton(
      //                                       onPressed: () {
      //                                         // Close the bottom sheet
      //                                         Navigator.pop(context);
      //                                       },
      //                                       icon: Icon(Icons.cancel),
      //                                     ),
      //                                   ],
      //                                 ),
      //                                 for(var i in payloadProvider.alarmList)
      //                                   ListTile(
      //                                     title: Text('${getAlarmMessage(i['AlarmType'])}'),
      //                                     subtitle: Text('Location : ${i['Location']}'),
      //                                     trailing: MaterialButton(
      //                                       color: i['Status'] == 1 ? Colors.orange : Colors.red,
      //                                       onPressed: () {
      //                                         String payload =  '${i['S_No']}';
      //                                         String payLoadFinal = jsonEncode({
      //                                           "4100": [{"4101": payload}]
      //                                         });
      //                                         MQTTManager().publish(payLoadFinal, payloadProvider.publishTopic);
      //                                       },
      //                                       child: Text('Reset',style: TextStyle(color: Colors.white),),
      //                                     ),
      //                                   )
      //                               ],
      //                             ),
      //                           );
      //                         },
      //                       );
      //                     },
      //                   );
      //                 },
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(8.0),
      //                   child: Stack(
      //                     children: [
      //                       Icon(Icons.notifications,color: Colors.black,size: 30,),
      //                       if(payloadProvider.alarmList.isNotEmpty)
      //                         Positioned(
      //                           top: 0,
      //                           left: 10,
      //                           child: CircleAvatar(
      //                             radius: 8,
      //                             backgroundColor: Colors.red,
      //                             child: Center(
      //                                 child: Text('1',style: TextStyle(color: Colors.white,fontSize: 12),)
      //                             ),
      //                           ),
      //                         )
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //           ],
      //         ),
      //       ),
      //     )
      //         : PreferredSize(preferredSize: Size.zero, child: Container()),
      //     actions: [
      //       if(payloadProvider.currentSchedule.isNotEmpty)
      //         if(payloadProvider.currentSchedule.any((element) => !element['ProgName'].contains('StandAlone')))
      //           Row(
      //           children: [
      //             getActiveObjects(
      //                 context: context,
      //                 active: payloadProvider.active == 1 ? true : false,
      //                 title: 'All',
      //                 onTap: (){
      //                   setState(() {
      //                     payloadProvider.active = 1;
      //                   });
      //                 },
      //                 mode: payloadProvider.active
      //             ),
      //             getActiveObjects(
      //                 context: context,
      //                 active: payloadProvider.active == 2 ? true : false,
      //                 title: 'Active',
      //                 onTap: (){
      //                   setState(() {
      //                     payloadProvider.active = 2;
      //                   });
      //                   print('active : ${payloadProvider.active}');
      //                 },
      //                 mode: payloadProvider.active
      //             ),
      //
      //           ],
      //         ),
      //       if([3,4].contains(overAllPvd.controllerType))
      //         IconButton(onPressed: () => onRefresh, icon: Icon(Icons.refresh)),
      //       //Modified by saravanan
      //       if([1,2].contains(overAllPvd.controllerType))
      //         buildPopUpMenuButton(
      //             context: context,
      //             dataList: ["Standalone", "Node status", "Node details"],
      //             onSelected: (newValue){
      //               if(newValue == "Standalone") {
      //                 showGeneralDialog(
      //                   barrierLabel: "Side sheet",
      //                   barrierDismissible: true,
      //                   // barrierColor: const Color(0xff6600),
      //                   transitionDuration: const Duration(milliseconds: 300),
      //                   context: context,
      //                   pageBuilder: (context, animation1, animation2) {
      //                     return Align(
      //                       alignment: Alignment.centerRight,
      //                       child: Container(
      //                           width: MediaQuery.of(context).size.width - 50,
      //                           child: ManualOperationScreen(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId, customerId: overAllPvd.customerId, deviceId: overAllPvd.imeiNo,)
      //                       ),
      //                     );
      //                   },
      //                   transitionBuilder: (context, animation1, animation2, child) {
      //                     return SlideTransition(
      //                       position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
      //                       child: child,
      //                     );
      //                   },
      //                 );
      //               } else if(newValue == "Node status") {
      //                 // nodeStatus(context: context,);
      //               } else if(newValue == "Node details") {
      //                 // showNodeDetailsBottomSheet(context: context);
      //               }
      //             },
      //             child: Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 5.0),
      //               child: Icon(Icons.more_vert),
      //             )
      //         )
      //     ],
      //     surfaceTintColor: Colors.white,
      //   ),
      // ),
      // Modified by saravanan
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: (){
                          if(overAllPvd.fromDealer) {
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
                            Navigator.of(context).pop();
                          } else {
                            _scaffoldKey.currentState?.openDrawer();
                          }
                        },
                        icon: Icon(!overAllPvd.fromDealer ? Icons.menu : Icons.arrow_back,size: 25,)
                    ),
                    InkWell(
                      onTap: (){
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context){
                              return StatefulBuilder(builder: (context, StateSetter stateSetter) {
                                return Container(
                                  height: 400,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('List of Site',style: TextStyle(fontSize: 20),),
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for(var site = 0;site < payloadProvider.listOfSite.length;site++)
                                                ListTile(
                                                  title: Text(payloadProvider.listOfSite[site]['groupName']),
                                                  trailing: IntrinsicWidth(
                                                    child: Radio(
                                                      value: 'site-${site}',
                                                      groupValue: payloadProvider.selectedSiteString,
                                                      onChanged: (value) {
                                                        stateSetter((){
                                                          setState(() {
                                                            var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
                                                            payloadProvider.selectedSite = site;
                                                            payloadProvider.selectedSiteString = value!;
                                                            payloadProvider.selectedMaster = 0;
                                                            overAllPvd.takeSharedUserId = false;
                                                            var selectedMasterData = payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster];
                                                            overAllPvd.imeiNo = selectedMasterData['deviceId'];
                                                            overAllPvd.controllerId = selectedMasterData['controllerId'];
                                                            overAllPvd.controllerType = selectedMasterData['categoryId'];
                                                            if(selectedMasterData['irrigationLine'] != null){
                                                              payloadProvider.editLineData(selectedMasterData['irrigationLine']);
                                                            }
                                                            manager.unSubscribe(
                                                              unSubscribeTopic: unSubscribeTopic,
                                                              subscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
                                                              publishTopic: 'AppToFirmware/${overAllPvd.imeiNo}',
                                                              publishMessage: getPublishMessage(),
                                                            );
                                                            payloadProvider.updateReceivedPayload(jsonEncode([3,4].contains(overAllPvd.controllerType) ? {"mC":"LD01",'cM' : selectedMasterData['liveMessage']} : selectedMasterData),true);
                                                            manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');

                                                            Future.delayed(Duration(milliseconds: 300),(){
                                                              Navigator.pop(context);
                                                            });
                                                          });
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              if(payloadProvider.listOfSharedUser.isNotEmpty)
                                                for(var sharedUser = 0;sharedUser < payloadProvider.listOfSharedUser['users'].length;sharedUser++)
                                                  if(payloadProvider.listOfSharedUser['devices'].isNotEmpty)
                                                    ListTile(
                                                      title: Text(payloadProvider.listOfSharedUser['users'][sharedUser]['userName']),
                                                      trailing: IntrinsicWidth(
                                                        child: Radio(
                                                          value: 'sharedUser-${sharedUser}',
                                                          groupValue: payloadProvider.selectedSiteString,
                                                          onChanged: (value) async{
                                                            try{
                                                              HttpService service = HttpService();
                                                              var getSharedUserDetails = await service.postRequest('getSharedUserDeviceList', {'userId' : overAllPvd.userId,"sharedUser" : payloadProvider.listOfSharedUser['users'][sharedUser]['userId']});
                                                              stateSetter((){
                                                                setState((){
                                                                  var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
                                                                  payloadProvider.selectedSite = sharedUser;
                                                                  payloadProvider.selectedSiteString = value!;
                                                                  payloadProvider.selectedMaster = 0;
                                                                  var jsonDataSharedDevice = jsonDecode(getSharedUserDetails.body);
                                                                  // print('code is =======================       ${jsonDataSharedDevice['code']}      ========================');
                                                                  if(jsonDataSharedDevice['code'] == 200){
                                                                    payloadProvider.listOfSharedUser = jsonDataSharedDevice['data'];
                                                                    // print('getSharedUserDeviceList : ${payloadProvider.listOfSharedUser}');
                                                                    if(payloadProvider.listOfSharedUser['devices'].isNotEmpty){
                                                                      setState(() {
                                                                        payloadProvider.selectedMaster = 0;
                                                                        var imeiNo = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId'];
                                                                        var controllerId = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId'];
                                                                        overAllPvd.sharedUserId = jsonDataSharedDevice['data']['users'][0]['userId'];
                                                                        overAllPvd.takeSharedUserId = true;
                                                                        overAllPvd.imeiNo = imeiNo;
                                                                        overAllPvd.controllerId = controllerId;
                                                                        overAllPvd.controllerType = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId'];
                                                                        if(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine'] != null){
                                                                          payloadProvider.editLineData(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine']);
                                                                        }
                                                                        payloadProvider.updateReceivedPayload(jsonEncode([3,4].contains(overAllPvd.controllerType) ? {"mC":"LD01",'cM' : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveMessage']} : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]),true);
                                                                        payloadProvider.editSubscribeTopic('FirmwareToApp/$imeiNo');
                                                                        payloadProvider.editPublishTopic('AppToFirmware/$imeiNo');
                                                                        payloadProvider.editPublishMessage(getPublishMessage());
                                                                        manager.unSubscribe(
                                                                            unSubscribeTopic: unSubscribeTopic,
                                                                            subscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
                                                                            publishTopic: 'AppToFirmware/${overAllPvd.imeiNo}',
                                                                            publishMessage: getPublishMessage()
                                                                        );
                                                                        manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
                                                                        Future.delayed(Duration(milliseconds: 300),(){
                                                                          Navigator.pop(context);
                                                                        });
                                                                      });
                                                                      for(var i = 0;i < 2;i++){
                                                                        Future.delayed(Duration(seconds: 3),(){
                                                                          autoRefresh();
                                                                        });
                                                                      }
                                                                    }
                                                                  }
                                                                  overAllPvd.editImeiNo(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId']);
                                                                  overAllPvd.editControllerId(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId']);
                                                                  overAllPvd.editControllerType(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId']);
                                                                });
                                                              });
                                                            }catch(e,stackTrace){
                                                              setState(() {
                                                                payloadProvider.httpError = true;
                                                              });
                                                              // print(' Site selecting Error getSharedUserDeviceList  => ${e.toString()}');
                                                              // print(' Site selecting trace getSharedUserDeviceList  => ${stackTrace}');
                                                            }
                                                            // print('after => ${overAllPvd.userId}');

                                                          },
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            }
                        );
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['groupName'] : payloadProvider.listOfSharedUser['users'][payloadProvider.selectedSite]['userName']}',style: TextStyle(fontSize: 14,overflow: TextOverflow.ellipsis,fontWeight: FontWeight.bold),),
                                Text('Last Sync : \n${payloadProvider.lastUpdate.day}/${payloadProvider.lastUpdate.month}/${payloadProvider.lastUpdate.year} ${payloadProvider.lastUpdate.hour}:${payloadProvider.lastUpdate.minute}:${payloadProvider.lastUpdate.second}',style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 12,overflow: TextOverflow.ellipsis),),
                              ],
                            ),
                            SizedBox(
                                width: 15,
                                child: Icon(Icons.arrow_drop_down_sharp)
                            )
                          ],
                        ),
                      ),
                    ),
                    if(payloadProvider.currentSchedule.isNotEmpty)
                      if(payloadProvider.currentSchedule.any((element) => !element['ProgName'].contains('StandAlone')))
                        Row(
                          children: [
                            getActiveObjects(
                                context: context,
                                active: payloadProvider.active == 1 ? true : false,
                                title: 'All',
                                onTap: (){
                                  setState(() {
                                    payloadProvider.active = 1;
                                  });
                                },
                                mode: payloadProvider.active
                            ),
                            getActiveObjects(
                                context: context,
                                active: payloadProvider.active == 2 ? true : false,
                                title: 'Active',
                                onTap: (){
                                  setState(() {
                                    payloadProvider.active = 2;
                                  });
                                },
                                mode: payloadProvider.active
                            ),

                          ],
                        ),
                    if([3,4].contains(overAllPvd.controllerType))
                      TextButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Names(userID: overAllPvd.userId, customerID: overAllPvd.userId, controllerId: overAllPvd.controllerId, imeiNo: overAllPvd.imeiNo)));
                      }, child: Text("Names")),
                    //Modified by saravanan
                    if([1,2].contains(overAllPvd.controllerType))
                      buildPopUpMenuButton(
                          context: context,
                          dataList: ["Standalone", "Node status", "Node details"],
                          onSelected: (newValue){
                            if(newValue == "Standalone") {
                              showGeneralDialog(
                                barrierLabel: "Side sheet",
                                barrierDismissible: true,
                                // barrierColor: const Color(0xff6600),
                                transitionDuration: const Duration(milliseconds: 300),
                                context: context,
                                pageBuilder: (context, animation1, animation2) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: ManualOperationScreen(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId, customerId: overAllPvd.customerId, deviceId: overAllPvd.imeiNo,)
                                    ),
                                  );
                                },
                                transitionBuilder: (context, animation1, animation2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
                                    child: child,
                                  );
                                },
                              );
                            } else if(newValue == "Node status") {
                              showGeneralDialog(
                                barrierLabel: "Side sheet",
                                barrierDismissible: true,
                                barrierColor: const Color(0xff66000000),
                                transitionDuration: const Duration(milliseconds: 300),
                                context: context,
                                pageBuilder: (context, animation1, animation2) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Material(
                                      elevation: 15,
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.zero,
                                      child: Consumer<MqttPayloadProvider>(
                                          builder: (context, mqttPayloadProvider, _) {
                                            return NodeStatus();
                                          }
                                      ),
                                    ),
                                  );
                                },
                                transitionBuilder: (context, animation1, animation2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
                                    child: child,
                                  );
                                },
                              );
                            } else if(newValue == "Node details") {
                              showNodeDetailsBottomSheet(context: context);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Icon(Icons.more_vert),
                          )
                      )
                  ],
                ),
                (payloadProvider.listOfSite.isNotEmpty
                    ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'].length > 1 || [1,2].contains(overAllPvd.controllerType)
                    : true)
                    ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                    // boxShadow: customBoxShadow
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: primaryColorDark
                        ),
                        child: PopupMenuButton<int>(
                          offset: Offset(0,50),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: Image.asset('assets/images/choose_controller.png'),
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    child: Text('${(!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['deviceName'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceName'])}'
                                      ,style: TextStyle(fontSize: 12,color: Colors.white,overflow: TextOverflow.ellipsis),),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.wifi,color: Colors.orange,size: 20,),
                                      SizedBox(width: 10,),
                                      Text('${payloadProvider.wifiStrength}',style: TextStyle(color: Colors.white),)
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          initialValue: payloadProvider.selectedMaster,
                          onSelected: (int master) {
                            setState(() {
                              payloadProvider.selectedMaster = master;
                            });
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                            for(var master = 0;master < (!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'] : payloadProvider.listOfSharedUser['devices']).length;master++)
                              PopupMenuItem<int>(
                                value: master,
                                child: Text(!overAllPvd.takeSharedUserId
                                    ? '${payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][master]['deviceName']}\n${payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][master]['deviceId']} ${[1,2].contains(payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][master]['categoryId']) ? '(version : ${payloadProvider.version})' : ''}'
                                    : '${payloadProvider.listOfSharedUser['devices'][master]['deviceName']}\n${payloadProvider.listOfSharedUser['devices'][master]} ${[1,2].contains(payloadProvider.listOfSharedUser['devices'][master]['categoryId']) ? '(version : ${payloadProvider.version})' : ''}'
                                ),
                                onTap: ()async{
                                  var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
                                  payloadProvider.selectedMaster = master;
                                  overAllPvd.editImeiNo((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['deviceId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId']));
                                  overAllPvd.editControllerType((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['categoryId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId']));
                                  overAllPvd.editControllerId((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['controllerId'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId']));
                                  var selectedMaster = !overAllPvd.takeSharedUserId
                                      ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]
                                      : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster];
                                  manager.unSubscribe(
                                      unSubscribeTopic: unSubscribeTopic,
                                      subscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
                                      publishTopic: 'AppToFirmware/${overAllPvd.imeiNo}',
                                      publishMessage: getPublishMessage()
                                  );
                                  payloadProvider.updateReceivedPayload(
                                      jsonEncode([3,4].contains(overAllPvd.controllerType)
                                          ? {"mC":"LD01",'cM' : selectedMaster['liveMessage']} : selectedMaster),true);


                                  for(var i = 0;i < 1;i++){
                                    await Future.delayed(Duration(seconds: 3));
                                    autoRefresh();
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                      if(![3,4].contains(overAllPvd.controllerType))
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white
                          ),
                          child: PopupMenuButton<int>(
                            offset: Offset(0,50),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Image.asset('assets/images/irrigation_line1.png'),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    child: Text(' ${payloadProvider.lineData[payloadProvider.selectedLine]['name']}',style: TextStyle(fontSize: 12,color: Colors.black,overflow: TextOverflow.ellipsis),)
                                ),
                              ],
                            ),
                            initialValue: payloadProvider.selectedLine,
                            onSelected: (int line) {
                              setState(() {
                                payloadProvider.selectedLine = line;
                              });
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                              for(var line = 0;line < payloadProvider.lineData.length;line++)
                                PopupMenuItem<int>(
                                  value: line,
                                  child: Text('${payloadProvider.lineData[line]['name']}'),
                                  onTap: (){
                                    setState(() {
                                      payloadProvider.selectedLine = line;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      if(![3,4].contains(overAllPvd.controllerType))
                        InkWell(
                          onTap:  (){
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Consumer<MqttPayloadProvider>(
                                  builder: (context, payloadProvider, child) {
                                    return Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(
                                                  'Alarms',
                                                  style: TextStyle(fontSize: 20),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  // Close the bottom sheet
                                                  Navigator.pop(context);
                                                },
                                                icon: Icon(Icons.cancel),
                                              ),
                                            ],
                                          ),
                                          for(var alarm = 0;alarm < payloadProvider.alarmList.length;alarm++)
                                            ListTile(
                                              title: Text('${getAlarmMessage[payloadProvider.alarmList[alarm]['AlarmType']]}'),
                                              subtitle: Text('Location : ${payloadProvider.alarmList[alarm]['Location']}'),
                                              trailing: MaterialButton(
                                                color: payloadProvider.alarmList[alarm]['Status'] == 1 ? Colors.orange : Colors.red,
                                                onPressed: DashboardPayloadHandler(manager: manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: alarm).alarmReset,
                                                // onPressed: () {
                                                //   String payload =  '${i['S_No']}';
                                                //   String payLoadFinal = jsonEncode({
                                                //     "4100": [{"4101": payload}]
                                                //   });
                                                //   MQTTManager().publish(payLoadFinal, payloadProvider.publishTopic);
                                                // },
                                                child: Text('Reset',style: TextStyle(color: Colors.white),),
                                              ),
                                            )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Icon(Icons.notifications,color: Colors.black,size: 30,),
                                if(payloadProvider.alarmList.isNotEmpty)
                                  Positioned(
                                    top: 0,
                                    left: 10,
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.red,
                                      child: Center(
                                          child: Text('1',style: TextStyle(color: Colors.white,fontSize: 12),)
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                    : Container()
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: [1,2].contains(overAllPvd.controllerType) ? SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(payloadProvider.tryingToGetPayload > 3)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.red
                              ),
                              child: Center(
                                child: Text('Please Check Internet In Your Controller.....',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          if(payloadProvider.powerSupply == 0)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.deepOrange
                              ),
                              child: Center(
                                child: Text('No Power To ${!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['deviceName'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceName']}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                              ),
                            ),
                          if(![3,4].contains(overAllPvd.controllerType))
                            ListTile(
                              leading: SizedBox(
                                width: 30,
                                height: 30,
                                child: Image.asset('assets/images/irrigation_line1.png'),
                              ),
                              subtitle: getLinePauseResumeMessage(payloadProvider.lineData[payloadProvider.selectedLine]['mode']) == '' ? null : Text('${getLinePauseResumeMessage(payloadProvider.lineData[payloadProvider.selectedLine]['mode'])}',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                              title: Text('${payloadProvider.lineData[payloadProvider.selectedLine]['name']}',style: TextStyle(fontSize: 12,color: Colors.black),),
                              trailing: [0,1].contains(payloadProvider.lineData[payloadProvider.selectedLine]['mode'])
                                  ? MaterialButton(
                                color: payloadProvider.lineData[payloadProvider.selectedLine]['mode'] == 0 ? Colors.orange : Colors.yellow,
                                onPressed: DashboardPayloadHandler(manager: manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context).irrigationLinePauseResume,
                                // onPressed: ()async{
                                //   if(payloadProvider.lineData[payloadProvider.selectedLine]['pauseResumeCodeHomePage'] == null){
                                //     var lineString = '';
                                //     for(var i = 1;i < payloadProvider.lineData.length;i++){
                                //
                                //       if(lineString.isNotEmpty){
                                //         lineString += ';';
                                //       }
                                //       if(payloadProvider.selectedLine == 0){
                                //         lineString += '${payloadProvider.lineData[i]['sNo']},${payloadProvider.lineData[1]['mode'] == 0 ? 1 : 0}';
                                //       }else{
                                //         lineString += '${payloadProvider.lineData[i]['sNo']},${i == payloadProvider.selectedLine ? (payloadProvider.lineData[i]['mode'] == 0 ? 1 : 0) : payloadProvider.lineData[i]['mode']}';
                                //       }
                                //     }
                                //     var message = {
                                //       "4900" : [
                                //         {
                                //           "4901" : lineString
                                //         },
                                //         {
                                //           "4902" : '${overAllPvd.userId}'
                                //         },
                                //       ]
                                //     };
                                //     manager.publish(jsonEncode(message),'AppToFirmware/${overAllPvd.imeiNo}');
                                //     try {
                                //       var data = {
                                //         "userId": overAllPvd.getUserId(),
                                //         "controllerId": overAllPvd.controllerId,
                                //         "data": message,
                                //         "hardware" : message,
                                //         "messageStatus": "${payloadProvider.lineData[payloadProvider.selectedLine]['name']} ${payloadProvider.lineData[payloadProvider.selectedLine]['mode'] == 0 ? 'Resume' : 'Pause'}",
                                //         "createUser": overAllPvd.getUserId()
                                //       };
                                //       final response = await HttpService().postRequest("createUserManualOperationInDashboard", data);
                                //       if (response.statusCode == 200) {
                                //         final jsonResponse = json.decode(response.body);
                                //       }
                                //     } catch (e) {
                                //       print('Error: $e');
                                //     }
                                //     setState(() {
                                //       payloadProvider.lineData[payloadProvider.selectedLine]['pauseResumeCodeHomePage'] = true;
                                //       payloadProvider.messageFromHw = '';
                                //     });
                                //     for(var seconds = 0;seconds < 8;seconds++){
                                //       await Future.delayed(Duration(seconds: 1));
                                //       if(payloadProvider.messageFromHw != ''){
                                //         setState(() {
                                //           payloadProvider.lineData[payloadProvider.selectedLine].remove('pauseResumeCodeHomePage');
                                //         });
                                //         stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware recieved successfully');
                                //         break;
                                //       }
                                //       if(seconds == 7){
                                //         setState(() {
                                //           payloadProvider.lineData[payloadProvider.selectedLine].remove('pauseResumeCodeHomePage');
                                //         });
                                //       }
                                //     }
                                //   }
                                // },
                                child: payloadProvider.lineData[payloadProvider.selectedLine]['loading'] == null
                                    ?  Text(payloadProvider.lineData[payloadProvider.selectedLine]['mode'] == 0 ? 'Pause' : 'Resume',style: TextStyle(color: payloadProvider.lineData[payloadProvider.selectedLine]['mode'] == 0 ? Colors.white : Colors.black),)
                                    : loadingButton(),
                              ) : null,
                            ),
                          if([3,4].contains(overAllPvd.controllerType))
                            PumpControllerDashboard(userId: overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : userId, deviceId: overAllPvd.imeiNo, controllerId: overAllPvd.controllerId, selectedSite: payloadProvider.selectedSite, selectedMaster: payloadProvider.selectedMaster,)
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(sourcePumpMode)
                                  SourcePumpDashBoardTrue(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, imeiNo: overAllPvd.imeiNo,)
                                else
                                  SourcePumpDashBoardFalse(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, imeiNo: overAllPvd.imeiNo,),
                                if(irrigationPumpMode)
                                  IrrigationPumpDashBoardTrue(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, imeiNo: overAllPvd.imeiNo,)
                                else
                                  IrrigationPumpDashBoardFalse(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, imeiNo: overAllPvd.imeiNo,),
                                for(var i = 0;i < payloadProvider.filtersCentral.length;i++)
                                  filterFertilizerLineFiltering(active: payloadProvider.active, siteIndex: i, selectedLine: payloadProvider.selectedLine, programName: payloadProvider.filtersCentral[i]['Program'], siteData: payloadProvider.filtersCentral[i], centralOrLocal: 1, filter_Fertilizer_line: 1),
                                for(var i = 0;i < payloadProvider.filtersLocal.length;i++)
                                  filterFertilizerLineFiltering(active: payloadProvider.active, siteIndex: i, selectedLine: payloadProvider.selectedLine, programName: payloadProvider.filtersLocal[i]['Program'], siteData: payloadProvider.filtersLocal[i], centralOrLocal: 2,filter_Fertilizer_line: 1),
                                for(var i = 0;i < payloadProvider.fertilizerCentral.length;i++)
                                  filterFertilizerLineFiltering(active: payloadProvider.active, siteIndex: i, selectedLine: payloadProvider.selectedLine, programName: payloadProvider.fertilizerCentral[i]['Program'], siteData: payloadProvider.fertilizerCentral[i], centralOrLocal: 1,filter_Fertilizer_line: 2),
                                for(var i = 0;i < payloadProvider.fertilizerLocal.length;i++)
                                  filterFertilizerLineFiltering(active: payloadProvider.active, siteIndex: i, selectedLine: payloadProvider.selectedLine, programName: payloadProvider.fertilizerLocal[i]['Program'], siteData: payloadProvider.fertilizerLocal[i], centralOrLocal: 2,filter_Fertilizer_line: 2),
                                for(var line = 1;line < payloadProvider.lineData.length;line++)
                                  if(payloadProvider.selectedLine == 0 || line == payloadProvider.selectedLine)
                                    if(irrigationLineMode)
                                      IrrigationLineTrue(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, currentLine: line, payloadProvider: payloadProvider)
                                    else
                                      IrrigationLineFalse(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, currentLine: line, payloadProvider: payloadProvider),
                                SizedBox(height: payloadProvider.irrigationPump.isEmpty ? 500 : 180,),
                              ],
                            )
                        ],
                      ),
                    )
                ) : PumpControllerDashboard(userId: overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : userId, deviceId: overAllPvd.imeiNo, controllerId: overAllPvd.controllerId, selectedSite: payloadProvider.selectedSite, selectedMaster: payloadProvider.selectedMaster,),
              ),
            ),
          ],
        ),
      ),
    )
        : payloadProvider.httpError == true
        ? Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Network is unreachable!!'),
          MaterialButton(
            onPressed: (){
              getData();
            },
            child: Text('RETRY',style: TextStyle(color: Colors.white),),
            color: Colors.blueGrey,
          ),
        ],
      ),
    )
        : getLoadingWidget(context: context, controllerValue: 0);
  }

  Widget filterFertilizerLineFiltering({
    required int active,
    required int siteIndex,
    required int selectedLine,
    required int centralOrLocal,
    required int filter_Fertilizer_line,
    required String programName,
    required dynamic siteData,
    dynamic currentLine,
  }){
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    Widget filterWidget = filtrationWidgetMode
        ? FiltrationSiteTrue(siteIndex: siteIndex, centralOrLocal: centralOrLocal, selectedLine: selectedLine,)
        : FiltrationSiteFalse(siteIndex: siteIndex, centralOrLocal: centralOrLocal, selectedLine: selectedLine,);
    Widget fertilizerWidget = fertigationWidgetMode
        ? FertilizerSiteTrue(siteIndex: siteIndex, centralOrLocal: centralOrLocal,selectedLine: selectedLine,)
        : FertilizerSiteFalse(siteIndex: siteIndex, centralOrLocal: centralOrLocal,selectedLine: selectedLine,);
    Widget widget = Container();
    if(active == 1 && selectedLine == 0){
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    }
    else if(active == 1 && selectedLine != 0 && (siteData['Location'] ?? siteData['Line']).contains(payloadProvider.lineData[selectedLine]['id'])){
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    }
    else if(active == 2 && programName != '' && selectedLine == 0){
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    }else if(active == 2 && programName != '' && selectedLine != 0 && (siteData['Location'] ?? siteData['Line']).contains(payloadProvider.lineData[selectedLine]['id'])){
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    }
    return widget;
  }

  void sideSheet({
    required MqttPayloadProvider payloadProvider,
    required selectedTab,
    required OverAllUse overAllPvd
  }) {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Scaffold(
                    floatingActionButton: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: customBoxShadow
                        ),
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.keyboard_double_arrow_left),
                            Text('Go Back'),
                          ],
                        ),
                      ),
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                    body: Container(
                      padding: const EdgeInsets.all(3),
                      // margin: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.zero,
                      ),
                      height: double.infinity,
                      width:  MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(selectedTab == 0)
                              CurrentScheduleForMobile(manager: manager, deviceId: '${overAllPvd.imeiNo}',),
                            if(selectedTab == 1)
                              NextScheduleForMobile(),
                            if(selectedTab == 2)
                              ScheduleProgramForMobile(manager: manager, deviceId: '${overAllPvd.imeiNo}', selectedLine: payloadProvider.selectedLine, userId: overAllPvd.userId, controllerId: overAllPvd.controllerId,),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }
}

Widget getLoadingWidget({
  required BuildContext context,
  required double controllerValue
}){
  return Container(
    color: Colors.white,
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Loading....',style: TextStyle(fontSize: 24,color: Colors.black),),
        Transform.rotate(
          angle: 6.28 * controllerValue,
          child: Icon(Icons.hourglass_bottom,color: Colors.black,),
        )
      ],
    ),
  );
}

void stayAlert({required BuildContext context,required MqttPayloadProvider payloadProvider,required String message}){
  GlobalSnackBar.show(context, message, int.parse(payloadProvider.messageFromHw['Code']));
  // showDialog(context: context, builder: (context){
  //   return AlertDialog(
  //     title: Text('Message From Hardware'),
  //     content: Text('${payloadProvider.messageFromHw}'),
  //     actions: [
  //       TextButton(
  //           onPressed: (){
  //             Navigator.pop(context);
  //           },
  //           child: Text('OK')
  //       )
  //     ],
  //   );
  // });
}

class Pump extends CustomPainter {
  final double rotationAngle;
  final int mode;
  Pump({required this.rotationAngle,required this.mode});

  List<Color> pipeColor = const [Color(0xff166890), Color(0xff45C9FA), Color(0xff166890)];
  List<Color> bodyColor = const [Color(0xffC7BEBE), Colors.white, Color(0xffC7BEBE)];
  List<Color> headColorOn = const [Color(0xff097E54), Color(0xff10E196), Color(0xff097E54)];
  List<Color> headColorOff = const [Color(0xff540000), Color(0xffB90000), Color(0xff540000)];
  List<Color> headColorFault = const [Color(0xffF66E21), Color(0xffFFA06B), Color(0xffF66E21)];
  List<Color> headColorIdle = [Colors.grey, Colors.grey.shade300, Colors.grey];

  List<Color> getMotorColor(){
    if(mode == 1){
      return headColorOn;
    }else if(mode == 3){
      return headColorOff;
    }else if(mode == 2){
      return headColorFault;
    }else{
      return headColorIdle;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {

    Paint motorHead = Paint();
    Radius headRadius = Radius.circular(5);
    motorHead.color = Color(0xff097B52);
    motorHead.style = PaintingStyle.fill;
    motorHead.shader = getLinearShaderHor(getMotorColor(),Rect.fromCenter(center: Offset(50,18), width: 35, height: 35));
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: Offset(50,20), width: 45, height: 40),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), motorHead);
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: Offset(50,20), width: 45, height: 40),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), motorHead);
    Paint line = Paint();
    line.color = Colors.white;
    line.strokeWidth = 1;
    line.style = PaintingStyle.fill;
    double startingPosition = 26;
    double lineGap = 8;
    for(var i = 0;i < 7;i++)
      canvas.drawLine(Offset(startingPosition+(i*lineGap), 5), Offset(startingPosition+(i*lineGap), 35), line);
    canvas.drawLine(Offset(28, 5), Offset(72, 5), line);
    canvas.drawLine(Offset(28, 35), Offset(72, 35), line);


    Paint neck = Paint();
    neck.shader = getLinearShaderHor(bodyColor,Rect.fromCenter(center: Offset(50,45), width: 20, height: 10));
    neck.strokeWidth = 0.5;
    neck.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(50,45 ), width: 20, height: 10), neck);

    Paint body = Paint();
    body.style = PaintingStyle.fill;
    body.shader = getLinearShaderHor(bodyColor,Rect.fromCenter(center: Offset(50,64), width: 35, height: 28));
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: Offset(50,64), width: 35, height: 28),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), body);

    Paint joint = Paint();
    joint.shader = getLinearShaderVert(bodyColor,Rect.fromCenter(center: Offset(30,64 ), width: 6, height: 15));
    joint.strokeWidth = 0.5;
    joint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(30,64 ), width: 6, height: 15), joint);
    canvas.drawRect(Rect.fromCenter(center: Offset(70,64 ), width: 6, height: 15), joint);

    Paint sholder1 = Paint();
    sholder1.shader = getLinearShaderVert(bodyColor,Rect.fromCenter(center: Offset(24,64 ), width: 6, height: 20));
    sholder1.strokeWidth = 0.5;
    sholder1.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(24,64 ), width: 6, height: 20), sholder1);
    canvas.drawRect(Rect.fromCenter(center: Offset(75,64 ), width: 6, height: 20), sholder1);

    Paint sholder2 = Paint();
    sholder2.shader = getLinearShaderVert(pipeColor,Rect.fromCenter(center: Offset(30,64), width: 6, height: 15));
    sholder2.strokeWidth = 0.5;
    sholder2.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(20,64 ), width: 6, height: 20), sholder2);
    canvas.drawRect(Rect.fromCenter(center: Offset(80,64 ), width: 6, height: 20), sholder2);

    Paint hand = Paint();
    hand.shader = getLinearShaderVert(pipeColor,Rect.fromCenter(center: Offset(30,64), width: 6, height: 15));
    hand.strokeWidth = 0.5;
    hand.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(10,64 ), width: 18, height: 15), hand);
    canvas.drawRect(Rect.fromCenter(center: Offset(90,64 ), width: 18 , height: 15), hand);

    Paint paint = Paint()..color = Colors.blueGrey;
    double centerX = 50;
    double centerY = 65;
    double radius = 8;
    double angle = (2 * pi) / 4; // Angle between each rectangle
    double rectangleWidth = 8;
    double rectangleHeight = 10;

    for (int i = 0; i < 4; i++) {
      double x = centerX + radius * cos(i * angle + rotationAngle/2);
      double y = centerY + radius * sin(i * angle + rotationAngle/2);
      double rotation = i * angle - pi / 2 + rotationAngle; // Rotate rectangles to fit the circle

      canvas.save(); // Save canvas state before rotation
      canvas.translate(x, y); // Translate to the position
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-rectangleWidth / 2, -rectangleHeight / 2, rectangleWidth, rectangleHeight),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(80),
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        paint,
      );
      canvas.restore(); // Restore canvas state after rotation
    }
    Paint smallCircle = Paint();
    smallCircle.color = Colors.black;
    smallCircle.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 4, smallCircle);
  }

  dynamic getLinearShaderVert(List<Color> colors,Rect rect){
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    ).createShader(rect);
  }

  dynamic getLinearShaderHor(List<Color> colors,Rect rect){
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors,
    ).createShader(rect);
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class FilterPaint extends CustomPainter{
  int? mode;
  FilterPaint({this.mode});
  @override
  void paint(Canvas canvas, Size size) {
    List<Color> mode0 = [
      // Colors.black54,
      Colors.black,
      Colors.black,
    ];
    List<Color> mode1 = [
      Color(0xff00580B),
      Color(0xff002D10)
    ];

    List<Color> mode2 = [
      // Color(0xffFFA06B),
      Color(0xffF66E21),
      Color(0xffF66E21),
    ];

    List<Color> mode3 = [
      // Color(0xff0E6FFF),
      Color(0xff26437A),
      Color(0xff26437A),
    ];

    List<Color> insideMode0 = [
      Colors.white,
      Color(0xffD0F5FD),
      Color(0xffB0532C),
    ];

    List<Color> insideMode1 = [
      Color(0xff9DC3A7),
      Color(0xff9EB1A5)
    ];
    List<Color> insideMode2 = [

      // Color(0xffB0532C),
      // Colors.black54,
      Colors.black54,
      // Color(0xffB0532C),
      Color(0xffD0F5FD),
      Color(0xffD0F5FD),
      // Colors.orange.shade50,
      // Colors.orange.shade200,
    ];
    List<Color> insideMode3 = [
      Color(0xffD0F5FD),
      Color(0xffD0F5FD),
      Color(0xffD0F5FD),
      Color(0xffB0532C),
      Color(0xffB0532C),
      Color(0xffD0F5FD),
      Color(0xffD0F5FD),
      Color(0xffD0F5FD),
    ];

    Paint paint = Paint();
    paint.strokeWidth = 2.0;
    paint.style = PaintingStyle.fill;
    Rect filterBox = Rect.fromLTWH(0, 0, 70, 80);
    // Rect filterInsideBox = Rect.fromLTWH(0, 0, 69, 77);
    Paint insideBox = Paint();
    insideBox.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        if(mode == 0)
          ...insideMode0
        else if(mode == 1)
          ...insideMode1
        else if(mode == 2)
            ...insideMode2
          else
            ...insideMode3
      ],
    ).createShader(filterBox);
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        if(mode == 0)
          ...mode0
        else if(mode == 1)
          ...mode1
        else if(mode == 2)
            ...mode2
          else
            ...mode3

      ],
    ).createShader(filterBox);
    canvas.drawRRect(RRect.fromRectXY(filterBox, 40, 10), paint);
    canvas.drawRect(Rect.fromLTWH(-10, 10, 15, 15), paint);
    canvas.drawRect(Rect.fromLTWH(68, 58, 12, 15), paint);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromCenter(
                center: Offset(35,40),
                width: 64,
                height: 77
            ),
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25)),
        insideBox
    );
    Paint sandBackground = Paint();
    sandBackground.color = Colors.black;
    // canvas.drawRect(Rect.fromLTWH(0, 25, 70, 30), paint);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(20, -7, 30, 8),
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0)),
        paint
    );
    Paint sand = Paint();
    sand.color = Colors.brown.shade300;
    // for(var line = 0;line < 10;line++){
    //   for(var i = 0;i < 23;i++){
    //     canvas.drawCircle(Offset(2+(i*3), 25 + (line * 3)), 1, sand);
    //   }
    // }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
