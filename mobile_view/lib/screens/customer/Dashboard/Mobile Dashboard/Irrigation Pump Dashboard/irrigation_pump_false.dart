import 'dart:convert';
import 'dart:math';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/wave_view.dart';
import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../constants/MQTTManager.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import 'irrigation_pump_true.dart';
import '../mobile_dashboard_common_files.dart';
import 'package:provider/provider.dart';

class IrrigationPumpDashBoardFalse extends StatefulWidget {
  final int active;
  final int selectedLine;
  final String imeiNo;
  const IrrigationPumpDashBoardFalse({super.key, required this.active, required this.selectedLine, required this.imeiNo});

  @override
  State<IrrigationPumpDashBoardFalse> createState() => _IrrigationPumpDashBoardFalseState();
}

class _IrrigationPumpDashBoardFalseState extends State<IrrigationPumpDashBoardFalse> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
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
    // print('irrigation pump false disposing...');
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

Widget getPumpDetails(){
  return Container(
    child: ListTile(
      leading: SizedBox(
        width: 30,
        height: 30,
        child: Image.asset('assets/images/water_meter.png'),
      ),
      title: Text('Water Meter'),
      trailing: Text('75 bar'),
    ),
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white
    ),
  );
}

Widget getFloatWidget({
  required BuildContext context,
  required String image,
  required String name,
  required String value,
}){
  return  Container(
    padding: EdgeInsets.all(5),
    width: MediaQuery.of(context).size.width * 0.3,
    decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: customBoxShadow,
        borderRadius: BorderRadius.circular(20)
    ),
    child: Column(
      children: [
        SizedBox(
            width: 40,
            height: 40,
            child: Image.asset('assets/images/$image.png')
        ),
        Text(name),
        Text(value),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    ),
  );
}