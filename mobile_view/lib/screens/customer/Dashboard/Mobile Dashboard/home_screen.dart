import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_view/FertilizerSet.dart';
import 'package:mobile_view/screens/config/constant/constant_tab_bar_view.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Logs/irrigation_and_pump_log.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Logs/pump_logs.dart';
import 'package:mobile_view/screens/customer/SystemDefinitionScreen/system_definition_screen.dart';
import 'package:mobile_view/state_management/MqttPayloadProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../GlobalFertilizerLimit.dart';
import '../../../../ListOfFertilizerInSet.dart';
import '../../../../Models/Customer/node_model.dart';
import '../../../../Models/hiddenmenu_model.dart';
import '../../../../calibration.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../state_management/irrigation_program_main_provider.dart';
import '../../../../state_management/overall_use.dart';
import '../../../NewPreference/preference_main_screen.dart';
import '../../../NewPreference/view_settings.dart';
import '../../Planning/NewIrrigationProgram/program_library.dart';
import '../../Planning/WeatherScreen.dart';
import '../../Planning/conditionscreen.dart';
import '../../Planning/fiterbackwash.dart';
import '../../Planning/frost_productionScreen.dart';
import '../../Planning/groupscreen.dart';
import '../../Planning/names_form.dart';
import '../../Planning/radiationsets.dart';
import '../../Planning/virtual_screen.dart';
import '../../Planning/watersourcenew.dart';
import '../../ScheduleView.dart';
import '../map/custommarker.dart';
import 'Logs/hourly_data.dart';
import 'Logs/pump_log.dart';
import 'home_page.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final bool fromDealer;
  const HomeScreen({super.key, required this.userId, required this.fromDealer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IrrigationProgramMainProvider irrigationProgramProvider;
  late OverAllUse overAllPvd;
  late MqttPayloadProvider payloadProvider;
  int selectIndex = 0;
  bool isBottomSheet = false;
  int userId = 53;
  int fetchcount = 0;
  int controllerId = 584;
  String imeiNo = 'B48C9D810C51';
  String uName = '';
  String uMobileNo = '';
  String uEmail = '';
  String appBarTitle = "Home page";
  HiddenMenu _hiddenMenu = HiddenMenu();
  dynamic listOfSite = [];
  int selectedSite = 0;
  int selectedMaster = 0;
  bool httperroronhs = false;
  MQTTManager manager = MQTTManager();
  // TODO: bottom menu bar button in page calling
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ProgramLibraryScreenNew(
      userId: 53,
      controllerId: 584,
      deviceId: 'B48C9D810C51',
      fromDealer: false,
    ),
    ScheduleViewScreen(
      deviceId: 'B48C9D810C51',
      userId: 53,
      controllerId: 584,
      customerId: 51,
    ),
    IrrigationAndPumpLog(userId: 0, controllerId: 0,),
  ];
  static  List<Widget> _widgetOptionspump = <Widget>[
    HomePage(),
    PreferenceMainScreen(
      controllerId: 584,userId: 53,deviceId: "",customerId: 15,
    ),
    ViewSettings(userId: 15, controllerId: 1),
    PumpLogs(),
  ];
  DateTime? _lastPressedAt;

  @override
  void initState() {
    // TODO: implement initState
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    // fetchData();
    if(payloadProvider.selectedSiteString == '' || overAllPvd.fromDealer){
      if(mounted) {
        getData();
        Future.delayed(Duration.zero, () {
          irrigationProgramProvider.updateBottomNavigation(0);
        });
      }
    }
    // getData();
    super.initState();
  }

  Future<void> getData() async{
    try{
      await mqttConfigureAndConnect();
      await initializeSharedPreference();
      await getDashBoardData();
      await fetchData();
    }catch(e){
      print('error: ${e.toString()}');
    }

    // if(payloadProvider.selectedSiteString == ''){
    //   await getDashBoardData();
    // }
  }

  Future<void> mqttConfigureAndConnect() async{
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    manager.initializeMQTTClient(state: payloadProvider);
    manager.connect();
  }

  Future<void> initializeSharedPreference() async {
    // print("getUserData function");
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero, () {
      setState(() {
        // final userIdFromPref = prefs.getString('userId') ?? '';
        uName = prefs.getString('userName') ?? '';
        uMobileNo = prefs.getString('mobileNumber') ?? '';
        uEmail = prefs.getString('email') ?? '';
      });
    });
    // print("uName:$uName,uMobileNo:$uMobileNo,uEmail:$uEmail,");
  }

  Future<void> fetchData() async {
    try{
      // print("fetch data function");
      Map<String, Object> body = {"userId": overAllPvd.userId, "controllerId": overAllPvd.controllerId};
      // print('fetchData body: $body');
      // Map<String, Object> body = {"userId": 15, "controllerId": 1};
      final response =
      await HttpService().postRequest("getUserMainMenuHiddenStatus", body);
      // print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = jsonDecode(response.body);
          _hiddenMenu = HiddenMenu.fromJson(jsonData);
        });
      } else {
        // _showSnackBar(response.body);
      }

    }catch(e){
      httperroronhs = true;
      print(e.toString());
    }
   
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

  void autoReferesh()async{
    manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
    manager.publish(payloadProvider.publishMessage,'AppToFirmware/${overAllPvd.imeiNo}');
    if(mounted) {
      setState(() {
        payloadProvider.tryingToGetPayload += 1;
      });
    }
  }

  Future<void> getDashBoardData() async{
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
      var getUserDetails = await service.postRequest('getCustomerDashboard', {'userId' : !widget.fromDealer ? userIdFromPref : widget.userId,});
      var jsonData = jsonDecode(getUserDetails.body);
      if(jsonData['code'] == 200){
        payloadProvider.listOfSite = jsonData['data'];
        if(jsonData['data'].isNotEmpty){
          //Modified by saravanan
          // print("user id ==> ${widget.userId}");
          // print("from dealer ==> ${widget.fromDealer}");
          await Future.delayed(Duration.zero, () {
            setState(() {
              payloadProvider.selectedSiteString = 'site-0';
              userId = !widget.fromDealer ? int.parse(userIdFromPref) : widget.userId;
              var selectedMasterData = payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster];
              overAllPvd.userId = userId;
              overAllPvd.fromDealer = widget.fromDealer;
              if(overAllPvd.fromDealer) {
                overAllPvd.dealerId = widget.userId;
              }
              overAllPvd.imeiNo = selectedMasterData['deviceId'];
              print(overAllPvd.imeiNo);
              overAllPvd.controllerId = selectedMasterData['controllerId'];
              overAllPvd.controllerType = selectedMasterData['categoryId'];
              overAllPvd.takeSharedUserId = false;
              if([1,2].contains(overAllPvd.controllerType)) {
                final rawData = payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['2400'][0]['2401'] as List;
                payloadProvider.nodeData = rawData.map((item) => NodeModel.fromJson(item)).toList();
              }
              if(selectedMasterData['irrigationLine'] != null){
                payloadProvider.editLineData(selectedMasterData['irrigationLine']);
              }
              payloadProvider.updateReceivedPayload(jsonEncode([3,4].contains(overAllPvd.controllerType) ? {"mC":"LD01",'cM' : selectedMasterData['liveMessage']} : selectedMasterData),true);
              payloadProvider.subscribeTopic = 'FirmwareToApp/${selectedMasterData['deviceId']}';
              payloadProvider.publishTopic = 'AppToFirmware/${selectedMasterData['deviceId']}';
              payloadProvider.publishMessage  = getPublishMessage();
            });
          });
          // print('categoryId = ${overAllPvd.controllerType}');
          for(var i = 0;i < 2;i++){
            Future.delayed(Duration(seconds: 3),(){
              autoReferesh();
            });
          }
        }
      }
      try{
        var getSharedUserDetails = await service.postRequest('getSharedUserDeviceList', {'userId' : userIdFromPref,'sharedUser' : null});
        var jsonDataSharedDevice = jsonDecode(getSharedUserDetails.body);
        if(jsonDataSharedDevice['code'] == 200){
          payloadProvider.listOfSharedUser = jsonDataSharedDevice['data'];
          // print('getSharedUserDevice : ${payloadProvider.listOfSharedUser}');
          // print(jsonDataSharedDevice['data'].runtimeType);
          if(payloadProvider.listOfSite.isEmpty){
            if(payloadProvider.listOfSharedUser['devices'].isNotEmpty){
              setState(() {
                if([1,2].contains(overAllPvd.controllerType)){
                  final rawData = payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['2400'][0]['2401'] as List;
                  payloadProvider.nodeData = rawData.map((item) => NodeModel.fromJson(item)).toList();
                }
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
                  autoReferesh();
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context);
    overAllPvd =  Provider.of<OverAllUse>(context, listen: true);
    payloadProvider =  Provider.of<MqttPayloadProvider>(context, listen: true);
    List<String> parameter = [];
    List<int> parameterid = [];
    List<Datum>? filteredList = _hiddenMenu.data?.where((item) => item.value == "1").toList();
    if (filteredList != null) {
      for (var item in filteredList) {
        parameter.add(item.parameter!);
        parameterid.add(item.dealerDefinitionId!);
      }
    }
    return overAllPvd.fromDealer == false ?
    PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        bool canPop = await _onWillPop(context);
        if (canPop) {
          Navigator.pop(context);
        } else {
          return;
        }
      },
      child: httperroronhs ? Material(
        child: SafeArea(
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
        ),
      ) : Scaffold(
         body: SafeArea(
          child: isBottomSheet
              ? _buildSelectedScreen()
              : [1,2].contains(overAllPvd.controllerType)
              ? _widgetOptions[irrigationProgramProvider.selectedIndex]
              : [3,4].contains(overAllPvd.controllerType)
              ? _widgetOptionspump[irrigationProgramProvider.selectedIndex]
              : Container(),
        ),
         bottomNavigationBar: Container(
          height: 75,
          decoration: BoxDecoration(
            boxShadow: customBoxShadow,
            color: Colors.white,
          ),
          child: [1,2].contains(overAllPvd.controllerType) ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "Dashboard";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(0);
                  },
                  icon: Icons.dashboard,
                  selected: irrigationProgramProvider.selectedIndex == 0,
                  label: "Dashboard"),
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "Program";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(1);
                  },
                  icon: Icons.schedule,
                  selected: irrigationProgramProvider.selectedIndex == 1,
                  label: "Program"),
              InkWell(
                onTap: () {
                  if(parameter.length > 0)
                    {
                  showModalBottomSheet(
                      backgroundColor: Colors.white,
                      context: context,
                      transitionAnimationController: AnimationController(
                        vsync: Navigator.of(context),
                        duration: const Duration(
                            milliseconds: 500), // Adjust the duration as needed
                        reverseDuration: const Duration(
                            milliseconds:
                            300), // Adjust the reverse duration as needed
                      ),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15))),
                      // showDragHandle: true,
                      builder: (BuildContext context) {
                        return Consumer<OverAllUse>(
                            builder: (context, overAllPvd, _) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  color: Colors.white,
                                ),
                                child:  RefreshIndicator(
                                  onRefresh:  () => fetchData() ,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          height: 310,
                                          width: MediaQuery.of(context).size.width,
                                          child: GridView.builder(
                                            itemCount: parameter.length,
                                            gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4, // Number of columns
                                              crossAxisSpacing:
                                              10.0, // Spacing between columns
                                              mainAxisSpacing:
                                              25.0, // Spacing between rows
                                              childAspectRatio:
                                              1.0, // Aspect ratio (width / height) of each grid item
                                            ),
                                            itemBuilder: (context, index) {
                                              return SizedBox(
                                                // height: 30,
                                                // width: 30,
                                                child: buildMenuItems(
                                                    context: context,
                                                    label: "${parameter[index]}",
                                                    id: parameterid[index],
                                                    icon: Icons.water_damage,
                                                    color: [
                                                      const Color(0xffF1F7FF),
                                                      const Color(0xffE9F2FF)
                                                    ],
                                                    borderColor:
                                                    const Color(0xffC7DDFF),
                                                    onTap: () {
                                                      setState(() {
                                                        appBarTitle = "${parameter[index]}";
                                                        isBottomSheet = true;
                                                        selectIndex = parameterid[index];
                                                        irrigationProgramProvider
                                                            .updateBottomNavigation(-1);
                                                      });
                                                      Navigator.of(context).pop();
                                                    }),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            setState(() {
                                              // isBottomSheet = false;
                                            });
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: linearGradientLeading,
                                                  boxShadow: customBoxShadow),
                                              child: const Icon(
                                                Icons.keyboard_arrow_down,
                                                size: 35,
                                                color: Colors.white,
                                              )),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        );
                      });
                }else{
                    setState(() {
                      fetchData();
                    });
              }},
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: linearGradientLeading,
                        boxShadow: customBoxShadow),
                    child: const Icon(
                      Icons.keyboard_arrow_up,
                      size: 35,
                      color: Colors.white,
                    )),
              ),
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "Schedule";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(2);
                  },
                  icon: Icons.calendar_month,
                  selected: irrigationProgramProvider.selectedIndex == 2,
                  label: "Schedule"),
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "Log";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(3);
                  },
                  icon: Icons.assessment,
                  selected: irrigationProgramProvider.selectedIndex == 3,
                  label: "Log"),
            ],
          ) : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "Dashboard";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(0);
                  },
                  icon: Icons.dashboard,
                  selected: irrigationProgramProvider.selectedIndex == 0,
                  label: "Dashboard"),
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "Settings";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(1);
                  },
                  icon: Icons.settings,
                  selected: irrigationProgramProvider.selectedIndex == 1,
                  label: "Settings"),
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "View";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(2);
                  },
                  icon: Icons.schedule,
                  selected: irrigationProgramProvider.selectedIndex == 2,
                  label: "View"),
              buildBottomNavigationTab(
                  context: context,
                  onPressed: () {
                    setState(() {
                      appBarTitle = "Logs";
                      isBottomSheet = false;
                    });
                    irrigationProgramProvider.updateBottomNavigation(3);
                  },
                  icon: Icons.auto_graph,
                  selected: irrigationProgramProvider.selectedIndex == 3,
                  label: "Logs"),
              // buildBottomNavigationTab(
              //     context: context,
              //     onPressed: () {
              //       setState(() {
              //         appBarTitle = "Log";
              //         isBottomSheet = false;
              //       });
              //       irrigationProgramProvider.updateBottomNavigation(4);
              //     },
              //     icon: Icons.auto_graph,
              //     selected: irrigationProgramProvider.selectedIndex == 4,
              //     label: "Log"),
            ],
          ),
        ),
      ))
     :  httperroronhs ? Material(
      child: SafeArea(
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
      ),
    ) : Scaffold(
      // appBar: AppBar(
      //   title: Text(appBarTitle),
      // ),
      body: SafeArea(
        child: isBottomSheet
            ? _buildSelectedScreen()
            : [1,2].contains(overAllPvd.controllerType)
            ? _widgetOptions[irrigationProgramProvider.selectedIndex]
            : [3,4].contains(overAllPvd.controllerType)
            ? _widgetOptionspump[irrigationProgramProvider.selectedIndex]
            : Container(),
      ),
      // Center(
      //   child: _widgetOptions[irrigationProgramProvider.selectedIndex],
      // ),
      // body: IndexedStack(
      //   index: irrigationProgramProvider.selectedIndex,
      //   children: _widgetOptions,
      // ),
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          boxShadow: customBoxShadow,
          color: Colors.white,
        ),
        child: [1,2].contains(overAllPvd.controllerType) ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Dashboard";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(0);
                },
                icon: Icons.dashboard,
                selected: irrigationProgramProvider.selectedIndex == 0,
                label: "Dashboard"),
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Program";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(1);
                },
                icon: Icons.schedule,
                selected: irrigationProgramProvider.selectedIndex == 1,
                label: "Program"),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    transitionAnimationController: AnimationController(
                      vsync: Navigator.of(context),
                      duration: const Duration(
                          milliseconds: 500), // Adjust the duration as needed
                      reverseDuration: const Duration(
                          milliseconds:
                          300), // Adjust the reverse duration as needed
                    ),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    // showDragHandle: true,
                    builder: (BuildContext context) {
                      return Consumer<OverAllUse>(
                          builder: (context, overAllPvd, _) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15)),
                                color: Colors.white,
                              ),
                              child:  RefreshIndicator(
                                onRefresh:  () => fetchData() ,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        height: 310,
                                        width: MediaQuery.of(context).size.width,
                                        child: GridView.builder(
                                          itemCount: parameter.length,
                                          gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4, // Number of columns
                                            crossAxisSpacing:
                                            10.0, // Spacing between columns
                                            mainAxisSpacing:
                                            25.0, // Spacing between rows
                                            childAspectRatio:
                                            1.0, // Aspect ratio (width / height) of each grid item
                                          ),
                                          itemBuilder: (context, index) {
                                            return SizedBox(
                                              // height: 30,
                                              // width: 30,
                                              child: buildMenuItems(
                                                  context: context,
                                                  label: "${parameter[index]}",
                                                  id: parameterid[index],
                                                  icon: Icons.water_damage,
                                                  color: [
                                                    const Color(0xffF1F7FF),
                                                    const Color(0xffE9F2FF)
                                                  ],
                                                  borderColor:
                                                  const Color(0xffC7DDFF),
                                                  onTap: () {
                                                    setState(() {
                                                      appBarTitle = "${parameter[index]}";
                                                      isBottomSheet = true;
                                                      selectIndex = parameterid[index];
                                                      irrigationProgramProvider
                                                          .updateBottomNavigation(-1);
                                                    });
                                                    Navigator.of(context).pop();
                                                  }),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            // isBottomSheet = false;
                                          });
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: linearGradientLeading,
                                                boxShadow: customBoxShadow),
                                            child: const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 35,
                                              color: Colors.white,
                                            )),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      );
                    });
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: linearGradientLeading,
                      boxShadow: customBoxShadow),
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    size: 35,
                    color: Colors.white,
                  )),
            ),
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Schedule";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(2);
                },
                icon: Icons.calendar_month,
                selected: irrigationProgramProvider.selectedIndex == 2,
                label: "Schedule"),
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Log";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(3);
                },
                icon: Icons.assessment,
                selected: irrigationProgramProvider.selectedIndex == 3,
                label: "Log"),
          ],
        ) : Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Dashboard";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(0);
                },
                icon: Icons.dashboard,
                selected: irrigationProgramProvider.selectedIndex == 0,
                label: "Dashboard"),
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Settings";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(1);
                },
                icon: Icons.settings,
                selected: irrigationProgramProvider.selectedIndex == 1,
                label: "Settings"),
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "View";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(2);
                },
                icon: Icons.schedule,
                selected: irrigationProgramProvider.selectedIndex == 2,
                label: "View"),
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Power";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(3);
                },
                icon: Icons.power,
                selected: irrigationProgramProvider.selectedIndex == 3,
                label: "Power"),
            buildBottomNavigationTab(
                context: context,
                onPressed: () {
                  setState(() {
                    appBarTitle = "Log";
                    isBottomSheet = false;
                  });
                  irrigationProgramProvider.updateBottomNavigation(4);
                },
                icon: Icons.auto_graph,
                selected: irrigationProgramProvider.selectedIndex == 4,
                label: "Log"),
          ],
        ),
      ),
    );

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

  Future<bool> _handleBackButton() async {
    final now = DateTime.now();
    final isWithinTwoSeconds = now.difference(_lastPressedAt!) <= const Duration(seconds: 2);
    _lastPressedAt = now;
    if (isWithinTwoSeconds) {
      // Exit the app
      await SystemNavigator.pop(); // Navigate back twice to exit
      return true;
    } else {
      // Show a snackbar with a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }
  // TODO: Bottom menu settings particular page calling in send user id and controller id
  Widget _buildSelectedScreen() {
    // fertSetPvd.closeOverLay();deviceId
    switch (selectIndex) {
      case 66:
        return watersourceUI1(
          userId: 53,
          controllerId: 584,
          deviceID: 'B48C9D810C51',
        );
      case 67:
        return const VirtualMeterScreen(
          userId: 53,
          controllerId: 584,
          deviceId: 'B48C9D810C51',
        );
      case 68:
        return const RadiationSetUI(
          userId: 53,
          controllerId: 584,
          deviceId: 'B48C9D810C51',
        );
      case 69:
        return const MyGroupScreen(
          userId: 53,
          controllerId: 584,
          deviceID: 'B48C9D810C51',
        );
      case 70:
        return ConditionScreen(
          userId: 53,
          controllerId: 584,
          deviceID: 'B48C9D810C51',
          isProgram: false,
        );
      case 71:
        return const FrostMobUI(
          userId: 53,
          controllerId: 584,
          deviceID: 'B48C9D810C51',
        );
      case 72:
        return const FilterBackwashUI1(
          userId: 53,
          controllerId: 584,
          deviceID: 'B48C9D810C51',
        );
      case 73:
        return FertilizerSetScreen(
            userId: 53,
            customerID: 15,
            controllerId: 584,
            deviceId: 'B48C9D810C51');
      case 74:
        return GlobalFertilizerLimit(
          customerId: 0,
            userId: 53,
            controllerId: 584,
            deviceId: 'B48C9D810C51');
      case 75:
        return SystemDefinition(userId: userId, controllerId: controllerId, deviceId: "");
      case 76:
        return const Center(child: Text('Program Queue'));
      case 77:
        return const WeatherScreen(
          userId: 53,
          controllerId: 584,
        );
      case 78:
        return PreferenceMainScreen(
          userId: 0,
          controllerId: 0,
          deviceId: "",
          customerId: 0,
        );
      case 79:
        return ConstantInConfig(userId: overAllPvd.customerId, deviceId: overAllPvd.imeiNo, customerId: overAllPvd.userId, controllerId: overAllPvd.controllerId);
      case 80:
        return Names(userID: overAllPvd.customerId, customerID: overAllPvd.userId, controllerId: overAllPvd.controllerId, imeiNo: overAllPvd.imeiNo);
      case 81:
        return CustomMarkerPage(userId: overAllPvd.customerId, controllerId: overAllPvd.controllerId, deviceID: overAllPvd.imeiNo,);
      case 127:
        return Calibration(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId, deviceId: overAllPvd.imeiNo,);

      default:
        return Container();
    }
  }
  Widget getIconsMenu(int name) {
    if (name == 66) {
      return Image.asset('assets/weather/menuwatersource.png');
    } else if (name == 67) {
      return Image.asset('assets/weather/menuwatersource.png');
    } else if (name == 68) {
      return Image.asset('assets/weather/menuradiationset.png');
    } else if (name == 69) {
      return Image.asset('assets/weather/menugroup.png');
    } else if (name == 70) {
      return Image.asset('assets/weather/menucondition.png');
    } else if (name == 71) {
      return Image.asset('assets/weather/menufrost.png');
    } else if (name == 72) {
      return Image.asset('assets/weather/menufilter.png');
    } else if (name == 73) {
      return Image.asset('assets/weather/menufertlizerset.png');
    } else if (name == 74) {
      return Image.asset('assets/weather/menuglobal.png');
    } else if (name == 75) {
      return Image.asset('assets/weather/menuwatersource.png');
    } else if (name == 76) {
      return Image.asset('assets/weather/menuprogramque.png');
    } else if (name == 77) {
      return Image.asset('assets/weather/menuweather.png');
    }else if (name == 78) {
      return Image.asset('assets/weather/menufrost.png');
    }else if (name == 79) {
      return Icon(Icons.construction);
    }else if (name == 80) {
      return Icon(Icons.contact_page_sharp);
    }
    else if (name == 81) {
      return Icon(Icons.map);
    }else {
      return Icon(Icons.person);
    }
  }

  Widget buildMenuItems(
      {required BuildContext context,
        IconData? icon,
        String? label,
        int? id,
        required List<Color> color,
        Color? borderColor,
        void Function()? onTap}) {
    List<Color> colors = [
      Color(0xffd2e5ee),
      Color(0xffcde6fc) ];
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors),
                boxShadow: customBoxShadow,
                border:
                Border.all(color: borderColor ?? Colors.grey, width: 0.3)),
            child: Center(
              child: getIconsMenu(id!),
            ),
          ),
      SizedBox(
            height: 5,
          ),
          SizedBox(
              width: 80,
              height: 40,
              child: Center(
                  child: Text(
                    label ?? "Coming soon",
                    textAlign: TextAlign.center,style: TextStyle(
                    fontSize: 12,
                  ),
                  )))
        ],
      ),
    );
  }

  Widget buildBottomNavigationTab(
      {required BuildContext context,
        required void Function()? onPressed,
        required IconData icon,
        required bool selected,
        required String label}) {
    return Expanded(
      child: Container(
        child: Column(
          children: [
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: selected ? Theme.of(context).primaryColor : Colors.black54,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                  color: selected ? Theme.of(context).primaryColor : Colors.black54,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal
              ),
            )
          ],
        ),
      ),
    );
  }
}
