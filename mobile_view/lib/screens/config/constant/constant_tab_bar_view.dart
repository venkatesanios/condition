import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/config/constant/pump_in_constant.dart';
import 'package:mobile_view/screens/config/constant/valve_in_constant.dart';
import 'package:mobile_view/screens/config/constant/water_meter_in_constant.dart';
import 'package:provider/provider.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import 'CriticalAlarmInConstant.dart';
import 'FinishInConstant.dart';
import 'analog_sensor_in_constant.dart';
import 'ec_ph_in_constant.dart';
import 'fertilizer_in_constant.dart';
import 'general_in_constant.dart';
import 'global_alarm.dart';
import 'irrigation_lines_in_constant.dart';
import 'level_sensor_in_constant.dart';
import 'main_valve_in_constant.dart';
import 'moisture_sensor_in_constant.dart';

class ConstantInConfig extends StatefulWidget {
  const ConstantInConfig({super.key, required this.userId, required this.deviceId, required this.customerId, required this.controllerId});
  final userId, deviceId, customerId, controllerId;

  @override
  State<ConstantInConfig> createState() => _ConstantInConfigState();
}

class _ConstantInConfigState extends State<ConstantInConfig> with TickerProviderStateMixin{
  late TabController myController ;
  late ConstantProvider constantPvd ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    constantPvd = Provider.of<ConstantProvider>(context,listen: false);
    myController = TabController(length: constantPvd.myTabsUpdated.length, vsync: this);
    if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getUserConstant();
      });
    }
  }

  Future<void> getUserConstant() async {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserConstant', {'userId' : overAllPvd.userId, 'controllerId' : overAllPvd.controllerId});
      var jsonData = jsonDecode(response.body);
      constantPvd.fetchSettings(jsonData['data']['constant']);
      constantPvd.fetchAll(jsonData['data']);
      setState(() {
        myController = TabController(length: constantPvd.myTabsUpdated.length, vsync: this);
      });
    }catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Scaffold(
      appBar: AppBar(title: Text('Constant'),),
      floatingActionButton: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.small(
              heroTag: 'btn 1',
              tooltip: 'Previous',
              backgroundColor: myController.index == 0 ? Colors.white54 : Colors.white,
              onPressed: myController.index == 0
                  ? null
                  : () {
                if (myController.index != 0) {
                  setState(() {
                    myController.animateTo(myController.index - 1);
                  });
                }
              },
              child: const Icon(Icons.arrow_back_outlined),
            ),
            FloatingActionButton.small(
              heroTag: 'btn 2',
              tooltip: 'Next',
              // backgroundColor: configPvd.selectedTab == 11 ? Colors.white54 : myTheme1.colorScheme.primary,
              backgroundColor: myController.index == 13 ? Colors.white54 : Colors.white,
              onPressed: myController.index == 13
                  ? null
                  : () {
                if (myController.index != 13) {
                  setState(() {
                    myController.animateTo(myController.index + 1);
                  });
                  // configPvd.editSelectedTab(configPvd.selectedTab + 1);
                }
              },
              child: const Icon(Icons.arrow_forward_outlined),
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: constantPvd.myTabs.length,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0XFFF3F3F3),
              child: TabBar(
                  controller: myController,
                  indicatorColor: myTheme.primaryColor,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  isScrollable: true,
                  onTap: (e){
                    FocusScope.of(context).unfocus();
                  },
                  tabs: [
                    for(var i = 0;i < constantPvd.myTabsUpdated.length;i++)
                      Tab(
                        text: constantPvd.myTabsUpdated[i]['parameter'],
                      ),
                  ]
              ),
            ),
            Expanded(
              child: TabBarView(
                  controller: myController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...getTab(),
                    // const GeneralInConst(),
                    // const PumpInConst(),
                    // const IrrigationLineInConst(),
                    // const MainValveInConst(),
                    // const ValveInConst(),
                    // const WaterMeterInConst(),
                    // const FertilizerInConst(),
                    // const EcPhInConst(),
                    // // const FilterConstant(),
                    // const AnalogSensorInConst(),
                    // const MoistureSensorInConst(),
                    // const LevelSensorInConst(),
                    // const NormalAlarmInConst(),
                    // const CriticalAlarmInConst(),
                    // const GlobalAlarmInConstant(),
                    if(myController.length > 1)
                      FinishInConstant(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId, customerId: overAllPvd.customerId, deviceId: overAllPvd.imeiNo)
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getTab(){
    var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
    List<Widget> listOfWidget = [];
    for(var i in constantPvd.myTabsUpdated){
      switch(i['dealerDefinitionId']){
        case(82):
          listOfWidget.add(const GeneralInConst());
        case(83):
          listOfWidget.add(const PumpInConst());
        case(84):
          listOfWidget.add(const IrrigationLineInConst());
        case(85):
          listOfWidget.add(const MainValveInConst());
        case(86):
          listOfWidget.add(const ValveInConst());
        case(87):
          listOfWidget.add(const WaterMeterInConst());
        case(88):
          listOfWidget.add(const FertilizerInConst());
        case(89):
          listOfWidget.add(const EcPhInConst());
        case(90):
          listOfWidget.add(const AnalogSensorInConst());
        case(91):
          listOfWidget.add(const MoistureSensorInConst());
        case(92):
          listOfWidget.add(const LevelSensorInConst());
        // case(93):
        //   listOfWidget.add(const NormalAlarmInConst());
        case(94):
          listOfWidget.add(const CriticalAlarmInConst());
        case(95):
          listOfWidget.add(const GlobalAlarmInConstant());
      }
    }
    return listOfWidget;
  }

}