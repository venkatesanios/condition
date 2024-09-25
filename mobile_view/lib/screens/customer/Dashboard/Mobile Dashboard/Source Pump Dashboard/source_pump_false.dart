import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/waves.dart';
import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../constants/MQTTManager.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import '../mobile_dashboard_common_files.dart';
import 'package:provider/provider.dart';

class SourcePumpDashBoardFalse extends StatefulWidget {
  final int active;
  final int selectedLine;
  final String imeiNo;
  const SourcePumpDashBoardFalse({super.key, required this.active, required this.selectedLine, required this.imeiNo});

  @override
  State<SourcePumpDashBoardFalse> createState() => _SourcePumpDashBoardFalseState();
}

class _SourcePumpDashBoardFalseState extends State<SourcePumpDashBoardFalse> with TickerProviderStateMixin{
  late AnimationController _controller;
  late AnimationController _controllerReverse;
  MQTTManager manager = MQTTManager();
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
    // _controller.repeat();

    _controller.addListener(() {
      setState(() {

      });
    });
    _controller.repeat();
    _controllerReverse = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerReverse.repeat(reverse: true);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerReverse.dispose();
    // print('source pump false disposing...');
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Padding(
      padding: const EdgeInsets.only(left: 8,right: 8),
      child: Row(
        children: [
          Container(
            width: 100,
            height: payloadProvider.sourcePump.isEmpty ? 70 : 110,
            child: Stack(
              children: [
                Positioned(
                  bottom: 15,
                  right: 4,
                  left: 14,
                  child: SizedBox(
                    width: 70,
                    height: 80,
                    child: CustomPaint(
                      painter: WavePainter(_controllerReverse.value),
                      size: Size(70,80),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 0,
                  child: SizedBox(
                    width: 85,
                    height: 80,
                    child: SvgPicture.asset(
                      'assets/images/sump.svg',
                    ),
                  ),
                ),
                if(payloadProvider.sourcePump.isNotEmpty && payloadProvider.active == 1)
                  Positioned(
                      top: 12,
                      right: 7,
                      child: SizedBox(
                          width: 20,
                          height: 40,
                          child: verticalPipeTopFlow(count: 2,mode: getWaterPipeStatusForSourcePump(context), controller: _controller)
                      )
                  ),
                if(payloadProvider.sourcePump.isNotEmpty && payloadProvider.active == 1)
                  Positioned(
                      top: 10,
                      right: 8,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child:  Transform.rotate(
                          angle: 4.71,
                          child: SvgPicture.asset(
                              'assets/images/L_joint.svg',
                              semanticsLabel: 'Acme Logo'
                          ),
                        ),
                      )
                  ),

                Positioned(
                    left: 0,
                    bottom: 0,
                    child: SizedBox(
                        width: 20,
                        height: 30,
                        child: verticalPipeTopFlow(count: 3,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller)
                    )
                ),

                Positioned(
                    top: payloadProvider.sourcePump.isEmpty ? 30 :  73,
                    child: SizedBox(
                        width: 30,
                        height: 10,
                        child: horizontalPipeRightFlow(count: 3,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller)
                    )
                ),
                Positioned(
                    top: payloadProvider.sourcePump.isEmpty ? 30 : 73,
                    left: 0,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child:  Transform.rotate(
                        angle: 4.71,
                        child: SvgPicture.asset(
                            'assets/images/L_joint.svg',
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
              children: [
                SizedBox(height: 5,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: customBoxShadow
                  ),
                  // padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for(var i = 0;i < payloadProvider.sourcePump.length;i++)
                          Column(
                            children: [
                              if(widget.active == 1)
                                if(payloadProvider.selectedLine != 0 && payloadProvider.sourcePump[i]['Location'].contains(payloadProvider.lineData[payloadProvider.selectedLine]['id']) || payloadProvider.selectedLine == 0)
                                  GetPumpAlertBox(index: i, controller: _controller, on: true, imeiNo: widget.imeiNo, controllerValue: _animation.value, pumpMode: payloadProvider.sourcePump[i]['Status'], delay: payloadProvider.sourcePump[i]['OnDelayLeft'],)
                                else
                                  if(payloadProvider.sourcePump[i]['Program'] != '')
                                    if(payloadProvider.selectedLine != 0 && payloadProvider.sourcePump[i]['Location'].contains(payloadProvider.lineData[payloadProvider.selectedLine]['id']) || payloadProvider.selectedLine == 0)
                                      GetPumpAlertBox(index: i, controller: _controller, on: true, imeiNo: widget.imeiNo, controllerValue: _animation.value, pumpMode: payloadProvider.sourcePump[i]['Status'], delay: payloadProvider.sourcePump[i]['OnDelayLeft'])
                            ],
                          )
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
  }
}