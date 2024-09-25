import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/wave_view.dart';
import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../constants/MQTTManager.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import 'irrigation_pump_false.dart';
import '../mobile_dashboard_common_files.dart';
import 'package:provider/provider.dart';

class IrrigationPumpDashBoardTrue extends StatefulWidget {
  final int active;
  final int selectedLine;
  final String imeiNo;
  const IrrigationPumpDashBoardTrue({super.key, required this.active, required this.selectedLine, required this.imeiNo});

  @override
  State<IrrigationPumpDashBoardTrue> createState() => _IrrigationPumpDashBoardTrueState();
}

class _IrrigationPumpDashBoardTrueState extends State<IrrigationPumpDashBoardTrue> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late AnimationController _controllerReverse;
  late Timer _timer;

  late Animation<double> _animation;
  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);

    _controller.addListener(() {
      setState(() {

      });
    });
    _controller.repeat();
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // print('irrigation pump true disposing...');
    // TODO: implement dispose
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    if(payloadProvider.irrigationPump.isEmpty) {
      return Container();
    }
    if(payloadProvider.irrigationPump.any((element) => (element['Location'].contains(payloadProvider.lineData[widget.selectedLine]['id']) && element['Status'] == 1)) || (widget.selectedLine == 0 || widget.active == 1)){
      return Container(
        height: (145 * getTextScaleFactor(context)).toDouble(),
        padding: const EdgeInsets.only(left: 8,right: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: (145 * getTextScaleFactor(context)).toDouble(),
              child: Stack(
                children: [
                  Positioned(
                      top: 100,
                      child: SizedBox(
                          width: 40,
                          height: 10,
                          child: horizontalPipeRightFlow(count: 2,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller, )
                      )
                  ),
                  Positioned(
                      bottom: 0,
                      child: SizedBox(
                          width: 40,
                          height: (145 * getTextScaleFactor(context)).toDouble(),
                          child: verticalPipeTopFlow(count: 4,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller,)
                      )
                  ),
                  Positioned(
                      top: 93,
                      left: -3,
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child:  Transform.rotate(
                          angle: 4.71,
                          child: SvgPicture.asset(
                              'assets/images/T_joint.svg',
                              semanticsLabel: 'Acme Logo'
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    // height: 20,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text('List Of Irrigation Pump',style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff007988)
                      ),))
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: customBoxShadow
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for(var i in payloadProvider.irrigationPump)
                            pumpFiltering(
                                resetButton: ['7','8','9','10'].contains(i['OnOffReason']) ? MaterialButton(
                                  color: Colors.red,
                                  onPressed: ()async{
                                    MQTTManager().publish(
                                        jsonEncode({"6300" : [{"6301" : '${i['S_No']},${1}'}]}),
                                        "AppToFirmware/${widget.imeiNo}");
                                    setState(() {
                                      i['reset'] = true;
                                    });
                                  },
                                  child: Text('Reset',style: TextStyle(color: Colors.white),),
                                ) : Container(),
                                active: widget.active, selectedLine: widget.selectedLine, pumpData: i, lineId: payloadProvider.lineData[widget.selectedLine]['id'], context: context, controller: _controller, animationValue: _animation.value)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }else{
      return Container();
    }


  }

}

Widget getPump({
  required int active,
  required int selectedLine,
  required dynamic pumpData,
  required String lineId,
  required AnimationController controller,
  required double animationValue,
  required BuildContext context,
  required Widget resetButton,
}){
  return getIrrigationPump(pumpName: '${pumpData['SW_Name'] ?? pumpData['Name']}', delay: pumpData['OnDelayLeft'], pumpMode: pumpData['Status'], context: context, controller: controller, animationValue: animationValue,data: pumpData,resetButton: resetButton);
}

Widget pumpFiltering({
  required int active,
  required int selectedLine,
  required dynamic pumpData,
  required String lineId,
  required AnimationController controller,
  required double animationValue,
  required BuildContext context,
  required Widget resetButton,
}){
  Widget pump = Container();
  if(active == 1){
    if(selectedLine != 0 && pumpData['Location'].contains(lineId)){
      pump = getPump(active: active, selectedLine: selectedLine, pumpData: pumpData, lineId: lineId, context: context, controller: controller, animationValue: animationValue,resetButton: resetButton);
    }
    if(selectedLine == 0){
      pump = getPump(active: active, selectedLine: selectedLine, pumpData: pumpData, lineId: lineId, context: context, controller: controller, animationValue: animationValue,resetButton: resetButton);
    }
  }else{
    if(selectedLine != 0 && pumpData['Location'].contains(lineId) && pumpData['Program'] != ''){
      pump = getPump(active: active, selectedLine: selectedLine, pumpData: pumpData, lineId: lineId, context: context, controller: controller, animationValue: animationValue,resetButton: resetButton);
    }
    if(selectedLine == 0 && pumpData['Program'] != ''){
      pump = getPump(active: active, selectedLine: selectedLine, pumpData: pumpData, lineId: lineId, context: context, controller: controller, animationValue: animationValue,resetButton: resetButton);
    }
  }
  return pump;
}


