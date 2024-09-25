import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mobile_view/screens/Customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../ListOfFertilizerInSet.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import '../../Planning/NewIrrigationProgram/program_library.dart';
import '../Mobile Dashboard/wave_view.dart';
import '../Mobile Dashboard/Logs/hourly_data.dart';
const LinearGradient linearGradientLeading = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xff1D808E), Color(0xff044851)],
);

const LinearGradient linearGradientLeading2 = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xff1D808E), Color(0xff044851)],
);

LinearGradient redLinearGradientLeading = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Colors.red.shade300, Colors.red.shade700],
);

LinearGradient greenLinearGradientLeading = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Colors.green.shade300, Colors.green.shade700],
);
class PumpControllerDashboard extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int selectedSite;
  final int selectedMaster;
  final String deviceId;
  const PumpControllerDashboard({super.key, required this.userId, required this.deviceId, required this.controllerId, required this.selectedSite, required this.selectedMaster});

  @override
  State<PumpControllerDashboard> createState() => _PumpControllerDashboardState();
}

class _PumpControllerDashboardState extends State<PumpControllerDashboard> with TickerProviderStateMixin{
  late MqttPayloadProvider mqttPayloadProvider;
  // late PumpControllerProvider pumpControllerProvider;
  late AnimationController _controller;
  late Animation<double> _animation;
  // late Timer _timer;
  // late DateTime _startTime;
  String _formattedTime = "00:00:00";
  Map<int, String> segments = {};
  int selectedIndex = 0;
  final double titleFontSize = 13.sp;
  final double mediumFontSize = 14.sp;
  final double smallFontSize = 10.sp;
  @override
  void initState() {
    // TODO: implement initState
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
    // getLive();
    // getPumpControllerData();
    _controller.addListener(() {setState(() {});});
    _controller.repeat();
    // _startTime = DateTime.now();
    // _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    // _timer.cancel();
    // _formattedTime = "00:00:00";
    super.dispose();
  }

  Future<void> getLive() async{
    MQTTManager().publish(jsonEncode({
      "sentSms": "#live"
    }),"AppToFirmware/${widget.deviceId}");
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    if(mqttPayloadProvider.dataModel != null && mqttPayloadProvider.dataModel!.pumps.isNotEmpty) {
      if(int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps) == 2) {
        segments = {
          0 : "Motor 1",
          1 : "Motor 2",
        };
      } else {
        segments = {
          0 : "Motor 1",
          1 : "Motor 2",
          2 : "Motor 3",
        };
      }
    }
    return (mqttPayloadProvider.dataModel != null && mqttPayloadProvider.dataModel!.pumps.isNotEmpty)
        ? RefreshIndicator(
              onRefresh: getLive,
              child: ListView(
        children: [
          const SizedBox(height: 10,),
          ConnectionErrorToast(isConnected: mqttPayloadProvider.isCommunicatable),
          // SizedBox(height: 10,),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: customBoxShadow
            ),
            child: ListTile(
              horizontalTitleGap: 20,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "${mqttPayloadProvider.listOfSite[mqttPayloadProvider.selectedSite]['master'][mqttPayloadProvider.selectedMaster]['deviceName']}", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    // TextSpan(text: "${widget.deviceId}", style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
              // title: Text("${widget.deviceId}", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
              subtitle: Text(mqttPayloadProvider.listOfSite[mqttPayloadProvider.selectedSite]['master'][mqttPayloadProvider.selectedMaster]['deviceId']),
              // subtitle: Text(mqttPayloadProvider.isCommunicatable ? "Showing live" : "Displaying last synced data"),
              leading: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    children: [
                      getIcon(mqttPayloadProvider.pumpControllerData?.signalStrength),
                      Text("${mqttPayloadProvider.pumpControllerData?.signalStrength ?? "0"}%")
                    ],
                  ),
                ),
              ),
              trailing: IntrinsicWidth(
                child: (mqttPayloadProvider.dataModel!.pumps[0].reasonCode == 30 || mqttPayloadProvider.dataModel!.pumps[0].reasonCode == 31) ?
                Container(
                  decoration: BoxDecoration(
                      color: mqttPayloadProvider.dataModel!.pumps[0].reasonCode == 30 ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5,),
                  child: Row(
                    children: [
                      Icon(mqttPayloadProvider.dataModel!.pumps[0].reasonCode == 30 ? Icons.warning : Icons.done, color: Colors.white,),
                      Text("${mqttPayloadProvider.dataModel!.pumps[0].reasonCode == 30 ? "Power off" : "Power on"}", style: const TextStyle(color: Colors.white),)
                    ],
                  ),
                ) :
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Version : ", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        TextSpan(text: "${mqttPayloadProvider.pumpControllerData!.version}", style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for(var index = 0; index < 3; index++)
                  buildContainer(
                    title: ["RY", "YB", "BR"][index],
                    value: mqttPayloadProvider.dataModel!.voltage.split(',')[index],
                    color1: [
                      Colors.redAccent.shade100,
                      Colors.amberAccent.shade100,
                      Colors.lightBlueAccent.shade100,
                    ][index],
                    color2: [
                      Colors.redAccent.shade700,
                      Colors.amberAccent.shade700,
                      Colors.lightBlueAccent.shade700,
                    ][index],
                  )
              ],
            ),
          ),
          const SizedBox(height: 15,),
          for(var index = 0; index < int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps); index++)
            buildNewPumpDetails(index: index),
        ],
              ),
            )
        : const Center(child: CircularProgressIndicator());
  }

  Icon getIcon(int value) {
    Color iconColor;
    IconData iconData;

    if (value >= 10 && value <= 30) {
      iconData = MdiIcons.signalCellular1;
      iconColor = Colors.red;
    } else if (value > 30 && value <= 70) {
      iconData = MdiIcons.signalCellular2;
      iconColor = Colors.orange;
    } else if (value > 70 && value <= 100) {
      iconData = MdiIcons.signalCellular3;
      iconColor = Colors.green;
    } else {
      iconData = MdiIcons.signalOff;
      iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor);
  }

  Row buildRow({required BuildContext context, required IconData icon, required String title, required String value, Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color,),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$title  ",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildNewPumpDetails({required int index}) {
    final pumpItem = mqttPayloadProvider.pumpControllerData!.pumps[index];
    if(pumpItem.reason.contains('off') && !pumpItem.reason.contains('auto mobile key') && pumpItem.reasonCode != 0) {
      mqttPayloadProvider.dataModel!.pumps[index].status = 3;
    }
    _formattedTime = pumpItem.onDelayTimer;
    final voltageTripCondition = pumpItem.reasonCode == 3
        || pumpItem.reasonCode == 4
        || pumpItem.reasonCode ==5;
    final currentTripCondition = pumpItem.reasonCode == 8
        || pumpItem.reasonCode == 9
        || pumpItem.reasonCode == 10;
    final phase = pumpItem.phase;
    final otherTripCondition = pumpItem.reasonCode == 13
        || pumpItem.reasonCode == 14
        || pumpItem.reasonCode == 1
        || pumpItem.reasonCode == 2;
    final tripCondition = voltageTripCondition || currentTripCondition || otherTripCondition;
    final remainingTimeCondition = (pumpItem.maximumRunTimeRemaining != "00:00:00"
        && pumpItem.maximumRunTimeRemaining != "")
        && !tripCondition
        && (pumpItem.status == 1);
    final cyclicOnDelayCondition = (pumpItem.cyclicOnDelay != "00:00:00"
        && pumpItem.cyclicOnDelay != "") && pumpItem.status == 1 && !tripCondition;
    final cyclicOffDelayCondition = (pumpItem.cyclicOffDelay != "00:00:00"
        && pumpItem.cyclicOffDelay != "")
        && (pumpItem.status == 0 || pumpItem.status == 3)
        && (pumpItem.reasonCode == 30 || pumpItem.reasonCode == 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 25,
              decoration: const BoxDecoration(
                  gradient: linearGradientLeading,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
              ),
              child: Center(
                child: Text(
                  "Motor ${index+1}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize, color: Colors.white,),
                ),
              ),
            ),
            if(pumpItem.reasonCode != 30 && pumpItem.reasonCode != 31)
              Expanded(
                child: Container(
                  // width: double.maxFinite,
                  // color: pumpItem.reasonCode == 0
                  //     ? (pumpItem.status == 1
                  //     ? Colors.green.shade50
                  //     : Colors.red.shade50)
                  //     : (pumpItem.reason.contains('on') ? Colors.green.shade50 : Colors.red.shade50),
                  // // padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    pumpItem.reasonCode == 0
                        ? (pumpItem.status == 1 ? "Turned on through the mobile" : "Turned off through the mobile").toUpperCase()
                        : pumpItem.reason.toUpperCase(),
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: pumpItem.reasonCode == 0
                          ? (pumpItem.status == 1
                          ? Colors.green.shade700
                          : Colors.red.shade700)
                          : (pumpItem.reason.contains('on') ? Colors.green.shade700 : Colors.red.shade700),
                      fontWeight: FontWeight.bold,
                        fontSize: titleFontSize
                    ),
                    textAlign: TextAlign.right,
                    // overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : 400,
          decoration: BoxDecoration(
              boxShadow: neumorphicButtonShadow,
              // boxShadow: customBoxShadow,
              color: Colors.white,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              border: Border.all(color: Theme.of(context).primaryColor, width: 0.3)
          ),
          child: Column(
            children: [
              if(pumpItem.reasonCode != 30 && pumpItem.reasonCode != 31)
                Container(
                  width: double.maxFinite,
                  // color: pumpItem.reasonCode == 0
                  //     ? (pumpItem.status == 1
                  //     ? Colors.green.shade50
                  //     : Colors.red.shade50)
                  //     : (pumpItem.reason.contains('on') ? Colors.green.shade50 : Colors.red.shade50),
                  // padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if(voltageTripCondition || currentTripCondition)
                        Container(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(
                                color: pumpItem.reasonCode == 0
                                    ? (pumpItem.status == 1
                                    ? Colors.green.shade50
                                    : Colors.red.shade50)
                                    : (pumpItem.reason.contains('on') ? Colors.green.shade50 : Colors.red.shade50),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'SET ${voltageTripCondition
                                        ? phase == 1
                                        ? "RY"
                                        : phase == 2
                                        ? "YB"
                                        : "BR"
                                        : phase == 1
                                        ? "RC"
                                        : phase == 2
                                        ? "YC" : "BC"} : ',
                                    style: TextStyle(fontSize: smallFontSize, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: '${pumpItem.set}',
                                    style: TextStyle(fontSize: smallFontSize, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                        ),
                      // SizedBox(width: 10,),
                      // Text(
                      //   pumpItem.reasonCode == 0
                      //       ? (pumpItem.status == 1 ? "Turned on through the mobile" : "Turned off through the mobile")
                      //       : pumpItem.reason, style: TextStyle(overflow: TextOverflow.ellipsis),),
                      // SizedBox(width: 10,),
                      if(voltageTripCondition || currentTripCondition)
                        Container(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            decoration: BoxDecoration(
                                color: pumpItem.reasonCode == 0
                                    ? (pumpItem.status == 1
                                    ? Colors.green.shade50
                                    : Colors.red.shade50)
                                    : (pumpItem.reason.contains('on') ? Colors.green.shade50 : Colors.red.shade50),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'ACT ${voltageTripCondition
                                        ? phase == 1
                                        ? "RY"
                                        : phase == 2
                                        ? "YB"
                                        : "BR"
                                        : phase == 1
                                        ? "RC"
                                        : phase == 2
                                        ? "YC" : "BC"} : ',
                                    style: TextStyle(fontSize: smallFontSize, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: '${pumpItem.actual}',
                                    style: TextStyle(fontSize: smallFontSize, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const SizedBox(width: 10,),
                  Stack(
                    children: [
                      getTypesOfPump(
                          mode: mqttPayloadProvider.dataModel!.pumps[index].status,
                          controller: _controller,
                          animationValue: _animation.value
                      ),
                      if(pumpItem.onDelayLeft != "00:00:00")
                        Positioned(
                            top: 8,
                            left: 18,
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: CountdownTimerWidget(
                                  initialSeconds: parseTime(_formattedTime).inSeconds,
                                  fontColor: Colors.white,
                                )
                            )
                        )
                    ],
                  ),
                  Row(
                    children: [
                      BounceEffectButton(
                          label: "ON",
                          textColor: Colors.green,
                          onTap: () async {
                            setState(() {
                              mqttPayloadProvider.dataModel!.pumps[index].status = 2;
                            });
                            var data = {
                              "userId": widget.userId,
                              "controllerId": widget.controllerId,
                              "data": {"sentSms": "motor${index+1}on"},
                              "messageStatus": "Motor${index+1} On",
                              "createUser": widget.userId,
                              "hardware": {"sentSms": "motor${index+1}on"}
                            };
                            await MQTTManager().publish(jsonEncode({"sentSms": "motor${index+1}on"}), "AppToFirmware/${widget.deviceId}");
                            await HttpService().postRequest("createUserManualOperationInDashboard", data);
                          }
                      ),
                      BounceEffectButton(
                          label: "OFF",
                          textColor: Colors.red,
                          onTap: () async {
                            setState(() {
                              mqttPayloadProvider.dataModel!.pumps[index].status = 2;
                            });
                            var data = {
                              "userId": widget.userId,
                              "controllerId": widget.controllerId,
                              "data": {"sentSms": "motor${index+1}off"},
                              "messageStatus": "Motor${index+1} Off",
                              "createUser": widget.userId,
                              "hardware": {"sentSms": "motor${index+1}off"}
                            };
                            await MQTTManager().publish(jsonEncode({"sentSms": "motor${index+1}off"}), "AppToFirmware/${widget.deviceId}");
                            await HttpService().postRequest("createUserManualOperationInDashboard", data);
                          }
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if(int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps) == 1)
                        for(var i = 0; i < mqttPayloadProvider.dataModel!.current.toString().split(',').length; i++)
                          buildCurrentContainer(
                            title: ['RC : ', 'YC : ', 'BC : '][i],
                            value: "${mqttPayloadProvider.dataModel!.current.toString().split(',')[i].substring(2)} A",
                            color1: [
                              Colors.redAccent.shade100,
                              Colors.amberAccent.shade100,
                              Colors.lightBlueAccent.shade100,
                            ][i],
                            color2: [
                              Colors.redAccent.shade700,
                              Colors.amberAccent.shade700,
                              Colors.lightBlueAccent.shade700,
                            ][i],
                          ),
                      if(int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps) == 2 && index == 0)
                        for(var i = 0; i < int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps); i++)
                          buildCurrentContainer(
                            title: ['RC : ', 'YC : '][i],
                            value: "${mqttPayloadProvider.dataModel!.current.toString().split(',')[i].substring(2)} A",
                            color1: [
                              Colors.redAccent.shade100,
                              Colors.amberAccent.shade100,
                            ][i],
                            color2: [
                              Colors.redAccent.shade700,
                              Colors.amberAccent.shade700,
                            ][i],
                          ),
                      if(int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps) == 2 && index == 1)
                        buildCurrentContainer(
                          title: 'BC : ',
                          value: "${mqttPayloadProvider.dataModel!.current.toString().split(',').last.substring(2)} A",
                          color1: Colors.lightBlueAccent.shade100,
                          color2: Colors.lightBlueAccent.shade700,
                        ),
                      if(int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps) == 3 && index == 0)
                        buildCurrentContainer(
                          title: 'RC : ',
                          value: "${mqttPayloadProvider.dataModel!.current.toString().split(',').first.substring(2)} A",
                          color1: Colors.redAccent.shade100,
                          color2: Colors.redAccent.shade700,
                        ),
                      if(int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps) == 3 && index == 1)
                        buildCurrentContainer(
                          title: 'YC : ',
                          value: "${mqttPayloadProvider.dataModel!.current.toString().split(',')[1].substring(2)} A",
                          color1: Colors.amberAccent.shade100,
                          color2: Colors.amberAccent.shade700,
                        ),
                      if(int.parse(mqttPayloadProvider.pumpControllerData!.numberOfPumps) == 3 && index == 2)
                        buildCurrentContainer(
                          title: 'BC : ',
                          value: "${mqttPayloadProvider.dataModel!.current.toString().split(',').last.substring(2)} A",
                          color1: Colors.lightBlueAccent.shade100,
                          color2: Colors.lightBlueAccent.shade700,
                        ),
                    ],
                  ),
                  // const SizedBox(width: 10,),
                ],
              ),
              // const SizedBox(height: 10,),
              // const SizedBox(height: 10,),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        // color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        runAlignment: WrapAlignment.center,
                        // spacing: 15,
                        // runSpacing: 10,
                        direction: Axis.horizontal,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (remainingTimeCondition)
                                  Expanded(
                                    child: _buildCountdownColumn(
                                      title: "Remaining \ntime",
                                      gradient: linearGradientLeading2,
                                      initialSeconds: parseTime(pumpItem.maximumRunTimeRemaining).inSeconds,
                                    ),
                                  ),
                                if (remainingTimeCondition)
                                  SizedBox(width: 15),
                                if ((cyclicOffDelayCondition || cyclicOnDelayCondition) && mqttPayloadProvider.isCommunicatable)
                                  Expanded(
                                    child: _buildCountdownColumn(
                                      title: cyclicOffDelayCondition ? "Cyclic off \ndelay" : "Cyclic on \ndelay",
                                      gradient: cyclicOffDelayCondition ? redLinearGradientLeading : greenLinearGradientLeading,
                                      initialSeconds: parseTime(cyclicOffDelayCondition ? pumpItem.cyclicOffDelay : pumpItem.cyclicOnDelay).inSeconds,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // if(remainingTimeCondition || cyclicOffDelayCondition || cyclicOnDelayCondition)
                          //   Divider(
                          //     indent: 10,
                          //     endIndent: 10,
                          //     color: Theme.of(context).primaryColor,
                          //     thickness: 0.3,
                          //   ),
                          if (pumpItem.level.toString().split(',')[0] != "-")
                            _buildPumpDetailColumn(
                                title: "Level",
                                content: WaveView(
                                  percentageValue: pumpItem.level.toString().split(',')[1] != '-'
                                  // ? 70
                                      ? double.parse(pumpItem.level.toString().split(',')[1])
                                      : 0,
                                  width: pumpItem.waterMeter == "-" && pumpItem.pressure == "-" ? constraints.maxWidth/2 - 50 : 50,
                                  borderRadius: pumpItem.waterMeter == "-" && pumpItem.pressure == "-" ? 15 : 80,
                                  // height: ,
                                ),
                                icon: Icons.propane_tank,
                                footer1: "${pumpItem.level.toString().split(',')[0]} feet",
                                footer2: '',
                                condition: pumpItem.waterMeter == "-" && pumpItem.pressure == "-"
                            ),
                          if (pumpItem.waterMeter != "-")
                            _buildPumpDetailColumn(
                                title: "Water meter",
                                content: Container(
                                  height: 100,
                                  width: constraints.maxWidth * 0.3,
                                  child: CustomGauge(
                                    currentValue: pumpItem.waterMeter != '-'
                                        ? double.parse(pumpItem.waterMeter)
                                        : 0,
                                    maxValue: 120.0,
                                  ),
                                ),
                                icon: Icons.speed,
                                footer1: "${pumpItem.waterMeter} Lps",
                                footer2: "total flow:${pumpItem.cumulativeFlow} L",
                                condition: pumpItem.level.toString().split(',')[0] == "-" && (pumpItem.pressure == "-")
                            ),
                          if (pumpItem.pressure != "-")
                            _buildPumpDetailColumn(
                                title: "Pressure",
                                content: Container(
                                  height: 100,
                                  width: constraints.maxWidth * 0.3,
                                  child: CustomGauge(
                                    currentValue: pumpItem.pressure != '-'
                                        ? double.parse(pumpItem.pressure)
                                        : 0,
                                    maxValue: 15,
                                  ),
                                ),
                                icon: MdiIcons.carBrakeLowPressure,
                                footer1: "${pumpItem.pressure} bar",
                                footer2: '',
                                condition: pumpItem.waterMeter == "-" && pumpItem.level.toString().split(',')[0] == "-"
                            ),
                          if(pumpItem.float.split(':').every((element) => element != "-"))
                            Divider(
                              indent: 10,
                              endIndent: 10,
                              color: Theme.of(context).primaryColor,
                              thickness: 0.3,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for(var i = 0; i < pumpItem.float.split(':').length; i++)
                                if(pumpItem.float.split(':')[i] != "-")
                                  _buildColumn(
                                      title1: "Float ${i+1}",
                                      value1: pumpItem.float.split(':')[i].toString() == "1" ? "High" : "Low",
                                      constraints: constraints,
                                      icon: MdiIcons.formatFloatCenter,
                                      color: const Color(0xffb6f6e5)
                                  ),
                            ],
                          )
                        ],
                      ),
                    );
                  }
              ),
            ],
          ),
        ),
        const SizedBox(height: 15,)
      ],
    );
  }

  Widget _buildCountdownColumn({
    required String title,
    required Gradient gradient,
    required int initialSeconds,
  }) {
    return Column(
      key: ValueKey('$title-$initialSeconds'),
      children: [
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
        ),
        IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CountdownTimerWidget(
              initialSeconds: initialSeconds,
              fontColor: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPumpDetailColumn({
    required String title,
    required Widget content,
    required String footer1,
    required String footer2,
    required IconData icon,
    bool condition = true
  }) {
    if(condition) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    gradient: linearGradientLeading,
                    shape: BoxShape.circle
                ),
                child: Icon(icon, color: Colors.white,),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: titleFontSize),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Actual value".toUpperCase(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: titleFontSize),),
                          SizedBox(height: 5,),
                          if(footer2 != '')
                            Text("total flow".toUpperCase(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: titleFontSize),),
                        ],
                      ),
                      SizedBox(width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(":".toUpperCase(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: titleFontSize),),
                          SizedBox(height: 5,),
                          if(footer2 != '')
                            Text(":".toUpperCase(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: titleFontSize),),
                        ],
                      ),
                      SizedBox(width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(footer1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize),),
                          SizedBox(height: 5,),
                          if(footer2 != '')
                            Text(footer2.split(':')[1], style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize),),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          content
        ],
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title.toUpperCase()),
          content,
          Text(footer1, style: TextStyle(fontWeight: FontWeight.bold),),
          if(footer2 != '')
          // Text(footer2)
            Container(
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(5)
              ),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Column(
                children: [
                  Text("${footer2.split(':')[0]}".toUpperCase(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  Text("${footer2.split(':')[1]}", style: TextStyle(color: Colors.black)),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget buildCurrentContainer({
    required String title,
    required String value,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: 100,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [color1, color2],
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        // ),
        color: color1,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color2, width: 0.3),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.5),
            offset: const Offset(0, 0),
            // blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: titleFontSize,
            ),
          ),
          // SizedBox(height: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton({required String label, required Color textColor, required void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
        ),
        color: textColor,
        elevation: 10,
        child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                label,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                          offset: const Offset(2,2),
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.3)
                      )
                    ]
                ),
              ),
            )
        ),
      ),
    );
  }

  Widget buildContainer({
    required String title,
    required String value,
    required Color color1,
    required Color color2,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color2, width: 0.3),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.5),
              offset: const Offset(0, 0),
              // blurRadius: 2,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: titleFontSize
              ),
            ),
            // SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                  fontSize: titleFontSize
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> waitForControllerResponse({
  required BuildContext dialogContext,
  required BuildContext context,
  required bool Function() condition,
  required void Function() elseCondition,
  required void Function() acknowledgedFunction,
}) async {
  try {
    bool isAcknowledged = false;
    int maxWaitTime = 30;
    int elapsedTime = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Please wait for controller response..."),
              ],
            ),
          ),
        );
      },
    );

    while (elapsedTime < maxWaitTime) {
      await Future.delayed(const Duration(seconds: 1));
      elapsedTime++;

      if (condition()) {
        isAcknowledged = true;
        break;
      }
    }

    Navigator.of(context).pop();

    if (isAcknowledged) {
      acknowledgedFunction();
    } else {
      elseCondition();
      showAlertDialog(message: "Controller is not responding", context: context);
    }

  } catch (error, stackTrace) {
    // Navigator.of(context).pop();
    print(stackTrace);
    showAlertDialog(message: error.toString(), context: context);
    throw Exception("Error $e");
  }
}

Widget _buildColumn({
  required String title1,
  required String value1,
  BoxConstraints? constraints,
  IconData? icon,
  Color? color
}) {
  return Container(
    width: constraints != null ? constraints.maxWidth * 0.25 : null,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // CircleAvatar(
        //   backgroundColor: color,
        //   child: Icon(icon),
        // ),
        Text(title1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300), textAlign: TextAlign.center,),
        Text(value1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
      ],
    ),
  );
}

List<BoxShadow> neumorphicButtonShadow = [
  BoxShadow(
      offset: const Offset(0, 20),
      blurRadius: 15,
      color: Colors.black.withOpacity(0.0405)
  ),
  BoxShadow(
      offset: const Offset(0, 15),
      blurRadius: 12,
      color: Colors.black.withOpacity(0.03)
  ),
  BoxShadow(
      offset: const Offset(0, 9),
      blurRadius: 10,
      color: Colors.black.withOpacity(0.0195)
  ),
  // BoxShadow(
  //     offset: const Offset(0, -20),
  //     blurRadius: 6.47,
  //     color: Colors.black.withOpacity(0.0195)
  // ),
];

Widget getTypesOfPump({
  required int mode,
  required AnimationController controller,
  required double animationValue,
}) {
  return AnimatedBuilder(
    animation: controller,
    builder: (BuildContext context, Widget? child) {
      return CustomPaint(
        painter: Pump(
          rotationAngle: [1].contains(mode) ? animationValue : 0,
          mode: mode,
        ),
        size: const Size(100, 80),
      );
    },
  );
}

class Pump extends CustomPainter {
  final double rotationAngle;
  final int mode;

  Pump({required this.rotationAngle, required this.mode});

  final List<Color> pipeColor = const [Color(0xff166890), Color(0xff45C9FA), Color(0xff166890)];
  final List<Color> bodyColor = const [Color(0xffC7BEBE), Colors.white, Color(0xffC7BEBE)];
  final List<Color> headColorOn = const [Color(0xff097E54), Color(0xff10E196), Color(0xff097E54)];
  final List<Color> headColorOff = const [Color(0xff540000), Color(0xffB90000), Color(0xff540000)];
  final List<Color> headColorFault = const [Color(0xffF66E21), Color(0xffFFA06B), Color(0xffF66E21)];
  final List<Color> headColorIdle = [Colors.grey, Colors.grey.shade300, Colors.grey];

  List<Color> getMotorColor() {
    switch (mode) {
      case 1:
        return headColorOn;
      case 2:
        return headColorFault;
      case 3:
        return headColorOff;
      default:
        return headColorIdle;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Motor Head
    Paint motorHead = Paint()
      ..style = PaintingStyle.fill
      ..shader = getLinearShaderHor(getMotorColor(), Rect.fromCenter(center: const Offset(50, 20), width: 45, height: 40));
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(center: const Offset(50, 20), width: 45, height: 40),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
        bottomLeft: const Radius.circular(5),
      ),
      motorHead,
    );

    // Horizontal Lines
    Paint line = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    double startingPosition = 26;
    double lineGap = 8;
    for (var i = 0; i < 7; i++) {
      canvas.drawLine(
        Offset(startingPosition + (i * lineGap), 5),
        Offset(startingPosition + (i * lineGap), 35),
        line,
      );
    }
    canvas.drawLine(const Offset(28, 5), const Offset(72, 5), line);
    canvas.drawLine(const Offset(28, 35), const Offset(72, 35), line);

    // Pump Body
    Paint neck = Paint()
      ..shader = getLinearShaderHor(bodyColor, Rect.fromCenter(center: const Offset(50, 45), width: 20, height: 10));
    canvas.drawRect(Rect.fromCenter(center: const Offset(50, 45), width: 20, height: 10), neck);

    Paint body = Paint()
      ..style = PaintingStyle.fill
      ..shader = getLinearShaderHor(bodyColor, Rect.fromCenter(center: const Offset(50, 64), width: 35, height: 28));
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(center: const Offset(50, 64), width: 35, height: 28),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
        bottomLeft: const Radius.circular(5),
      ),
      body,
    );

    // Pump Joints
    Paint joint = Paint()
      ..shader = getLinearShaderVert(bodyColor, Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15));
    canvas.drawRect(Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15), joint);
    canvas.drawRect(Rect.fromCenter(center: const Offset(70, 64), width: 6, height: 15), joint);

    // Pump Shoulders
    Paint shoulder1 = Paint()
      ..shader = getLinearShaderVert(bodyColor, Rect.fromCenter(center: const Offset(24, 64), width: 6, height: 20));
    canvas.drawRect(Rect.fromCenter(center: const Offset(24, 64), width: 6, height: 20), shoulder1);
    canvas.drawRect(Rect.fromCenter(center: const Offset(75, 64), width: 6, height: 20), shoulder1);

    Paint shoulder2 = Paint()
      ..shader = getLinearShaderVert(pipeColor, Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15));
    canvas.drawRect(Rect.fromCenter(center: const Offset(20, 64), width: 6, height: 20), shoulder2);
    canvas.drawRect(Rect.fromCenter(center: const Offset(80, 64), width: 6, height: 20), shoulder2);

    // Pump Hands
    Paint hand = Paint()
      ..shader = getLinearShaderVert(pipeColor, Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15));
    canvas.drawRect(Rect.fromCenter(center: const Offset(10, 64), width: 18, height: 15), hand);
    canvas.drawRect(Rect.fromCenter(center: const Offset(90, 64), width: 18, height: 15), hand);

    // Rotating Blades
    Paint paint = Paint()..color = Colors.blueGrey;
    double centerX = 50;
    double centerY = 65;
    double radius = 8;
    double angle = (2 * pi) / 4; // Angle between each rectangle
    double rectangleWidth = 8;
    double rectangleHeight = 10;

    for (int i = 0; i < 4; i++) {
      double x = centerX + radius * cos(i * angle + rotationAngle / 2);
      double y = centerY + radius * sin(i * angle + rotationAngle / 2);
      double rotation = i * angle - pi / 2 + rotationAngle; // Rotate rectangles to fit the circle

      canvas.save(); // Save canvas state before rotation
      canvas.translate(x, y); // Translate to the position
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-rectangleWidth / 2, -rectangleHeight / 2, rectangleWidth, rectangleHeight),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(80),
          topLeft: const Radius.circular(40),
          topRight: const Radius.circular(40),
        ),
        paint,
      );
      canvas.restore(); // Restore canvas state after rotation
    }

    // Small Circle at Center
    Paint smallCircle = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 4, smallCircle);
  }

  Shader getLinearShaderVert(List<Color> colors, Rect rect) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    ).createShader(rect);
  }

  Shader getLinearShaderHor(List<Color> colors, Rect rect) {
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

class BounceEffectButton extends StatefulWidget {
  final String label;
  final Color textColor;
  final void Function()? onTap;

  const BounceEffectButton({super.key,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  _BounceEffectButtonState createState() => _BounceEffectButtonState();
}

class _BounceEffectButtonState extends State<BounceEffectButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      if (widget.onTap != null) {
        widget.onTap!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _animation,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: widget.textColor,
          elevation: 10,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Icon(Icons.power_settings_new_rounded, color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
              // child: Text(
              //   widget.label,
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 18,
              //     shadows: [
              //       Shadow(
              //         offset: const Offset(2, 2),
              //         blurRadius: 6,
              //         color: Colors.black.withOpacity(0.3),
              //       ),
              //     ],
              //   ),
              // ),
            ),
          ),
        ),
      ),
    );
  }
}

class CountdownTimerWidget extends StatefulWidget {
  final Color fontColor;
  final double fontSize;
  final FontWeight fontWeight;
  final int initialSeconds;

  CountdownTimerWidget({Key? key, required this.initialSeconds, this.fontColor = Colors.black, this.fontSize = 12, this.fontWeight = FontWeight.bold}) : super(key: key);

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int secondsRemaining;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    secondsRemaining = widget.initialSeconds;
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (secondsRemaining < 1) {
          timer.cancel();
        } else {
          secondsRemaining -= 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int hours = secondsRemaining ~/ 3600;
    int minutes = (secondsRemaining % 3600) ~/ 60;
    int seconds = secondsRemaining % 60;

    return Center(
      child: Text(
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: TextStyle(color: widget.fontColor, fontSize: widget.fontSize, fontWeight: widget.fontWeight),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class ConnectionErrorToast extends StatefulWidget {
  final bool isConnected;

  ConnectionErrorToast({required this.isConnected});

  @override
  _ConnectionErrorToastState createState() => _ConnectionErrorToastState();
}

class _ConnectionErrorToastState extends State<ConnectionErrorToast> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.isConnected
          ? const SizedBox.shrink()
          : Container(
        key: const ValueKey("ConnectionError"),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.shade300,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MdiIcons.signalOff, color: Colors.white, size: 16,),
              const SizedBox(width: 10),
              const Text(
                "No Connection",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomGauge extends StatelessWidget {
  final double currentValue;
  final double maxValue;

  const CustomGauge({super.key, required this.currentValue, required this.maxValue});

  @override
  Widget build(BuildContext context) {

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: maxValue > 100 ? maxValue+1 : maxValue+0.1,
          showLabels: true,
          showTicks: true,
          interval: maxValue,
          axisLineStyle: AxisLineStyle(
            thickness: 0.2,
            thicknessUnit: GaugeSizeUnit.factor,
            cornerStyle: CornerStyle.bothCurve,
            color: Colors.grey[300],
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: currentValue,
              width: 0.2,
              sizeUnit: GaugeSizeUnit.factor,
              enableAnimation: false,
              animationDuration: 1500,
              gradient: SweepGradient(
                colors: [Theme.of(context).primaryColor.withOpacity(0.5), Theme.of(context).primaryColor],
                stops: const [0.2, 0.8],
              ),
              cornerStyle: CornerStyle.bothCurve,
            ),
            MarkerPointer(
              value: currentValue,
              markerOffset: -10,
              enableDragging: true,
              markerType: MarkerType.invertedTriangle,
              color: Theme.of(context).primaryColor,
              markerHeight: 10,
              markerWidth: 10,
            ),
          ],
          majorTickStyle: const MajorTickStyle(
            length: 0.1,
            thickness: 1,
            lengthUnit: GaugeSizeUnit.factor,
            color: Colors.blueGrey,
          ),
          minorTickStyle: MinorTickStyle(
            length: 0.05,
            thickness: 1.5,
            lengthUnit: GaugeSizeUnit.factor,
            color: Colors.blueGrey[300],
          ),
        ),
      ],
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define scale factors based on the size
    double width = size.width;
    double height = size.height;

    // Create the path with scaled coordinates
    Path path_0 = Path();
    path_0.moveTo(0, height * 0.89);
    path_0.lineTo(0, height * 0.1146);
    path_0.cubicTo(0, height * 0.0438, width * 0.0283, height * 0.00868, width * 0.0425, 0);
    path_0.lineTo(width * 0.25, 0);
    path_0.cubicTo(width * 0.2992, 0, width * 0.2973, height * 0.1354, width * 0.305, height * 0.2031);
    path_0.cubicTo(width * 0.3115, height * 0.2572, width * 0.3367, height * 0.2916, width * 0.3475, height * 0.3021);
    path_0.lineTo(width * 0.95, height * 0.3021);
    path_0.cubicTo(width, height * 0.3021, width, height * 0.4115, width, height * 0.4115);
    path_0.lineTo(width, height * 0.89);
    path_0.cubicTo(width, height * 0.9734, width * 0.966, height, width * 0.95, height);
    path_0.lineTo(width * 0.0425, height);
    path_0.cubicTo(width * 0.0178, height, 0, height * 0.9261, 0, height * 0.89);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xffC6E9A7).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

