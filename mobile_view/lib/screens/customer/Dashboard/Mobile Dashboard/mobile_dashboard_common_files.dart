import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_view/ListOfFertilizerInSet.dart';
import 'package:mobile_view/constants/theme.dart';
import 'package:mobile_view/screens/Customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/schedule_program.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/wave_view.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/wave_view_in_alert.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../state_management/overall_use.dart';
import 'home_page.dart';
import 'Irrigation Pump Dashboard/irrigation_pump_false.dart';

double _calculatePosition(int index,double controllerValue) {
  double basePosition = initialPosition + (index * gap);
  double animatedPosition =
      basePosition + (speed * controllerValue);
  return animatedPosition;
}

Widget horizontalPipeRightFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else if(mode == 2)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_fert_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )

        ],
      );
    },
  );
}

Widget horizontalFertPipeRightFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_fert_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )

        ],
      );
    },
  );
}

Widget horizontalPipeLeftFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else if(mode == 2)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_fert_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
        ],
      );;
    },
  );
}

Widget horizontalAirPipeLeftFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_air_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/images/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
        ],
      );
    },
  );
}

Widget verticalPipeTopFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Container(
        child: Stack(
          children: [
            if(mode != 0)
              for (int i = 0; i < count; i++)
                Positioned(
                    top: _calculatePosition(i,controller.value),
                    child: SizedBox(
                      width: 10,
                      height: 100,
                      child:  SvgPicture.asset(
                          'assets/images/vertical_water_pipe${mode == 1 ? '' : '_b'}.svg',
                          semanticsLabel: 'Acme Logo'
                      ),
                    )
                )
            else
              for (int i = 0; i < count; i++)
                Positioned(
                    top: _calculatePosition(i,0),
                    child: SizedBox(
                      width: 10,
                      height: 100,
                      child:  SvgPicture.asset(
                          'assets/images/vertical_water_pipe_g.svg',
                          semanticsLabel: 'Acme Logo'
                      ),
                    )
                )

          ],
        ),
      );
    },
  );
}

Widget verticalPipeBottomFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Container(
        child: Stack(
          children: [
            if(mode != 0)
              for (int i = 0; i < count; i++)
                Positioned(
                    bottom: _calculatePosition(i,controller.value),
                    child: SizedBox(
                      width: 10,
                      height: 100,
                      child:  SvgPicture.asset(
                          'assets/images/vertical_water_pipe${mode == 1 ? '' : '_b'}.svg',
                          semanticsLabel: 'Acme Logo'
                      ),
                    )
                )
            else
              Positioned(
                  top: 0,
                  child: SizedBox(
                    width: 10,
                    height: 100,
                    child:  SvgPicture.asset(
                        'assets/images/vertical_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )

          ],
        ),
      );
    },
  );
}

class GetPumpAlertBox extends StatefulWidget {
  final int index;
  final int pumpMode;
  final AnimationController controller;
  final double controllerValue;
  final bool on;
  final String imeiNo;
  final String delay;
  const GetPumpAlertBox({super.key, required this.index, required this.controller, required this.on, required this.imeiNo, required this.controllerValue, required this.pumpMode, required this.delay});

  @override
  State<GetPumpAlertBox> createState() => _GetPumpAlertBoxState();
}

class _GetPumpAlertBoxState extends State<GetPumpAlertBox> {
  @override
  Widget build(BuildContext context) {
    var payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return InkWell(
      onTap: (){
        showDialog(
            context: context,
            builder: (context){
              return Consumer<MqttPayloadProvider>(builder: (context,payloadProvider,child){
                return AlertDialog(
                  backgroundColor: Colors.white,
                  // title: Text('${payloadProvider.sourcePump[widget.index]['Name']}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: payloadProvider.sourcePump[widget.index]['Version'] != null ? IntrinsicWidth(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: cardColor
                            ),
                            child: Row(
                              children: [
                                getIcon(int.parse(payloadProvider.sourcePump[widget.index]['SignalStrength'])),
                                Text('${payloadProvider.sourcePump[widget.index]['SignalStrength']} %',style: TextStyle(fontWeight: FontWeight.bold),)
                              ],
                            ),
                          ),
                        ) : null,
                        title: Text(payloadProvider.sourcePump[widget.index]['Name'],style: TextStyle(color: primaryColorDark,fontWeight: FontWeight.bold)),
                        subtitle: payloadProvider.sourcePump[widget.index]['Version'] != null ? Text('Version : ${payloadProvider.sourcePump[widget.index]['Version']}',) : null,
                        trailing: IconButton(
                          icon: Icon(Icons.cancel,color: Colors.black,),
                          onPressed: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      if(payloadProvider.sourcePump[widget.index]['Voltage'] != null)
                        if(payloadProvider.sourcePump[widget.index]['Voltage'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Voltage'),
                              SizedBox(height: 8,),
                              Row(
                                children: [
                                  for(var index = 0; index < 3; index++)
                                    buildContainer(
                                      title: ["RY", "YB", "BR"][index],
                                      value:payloadProvider.sourcePump[widget.index]['Voltage'].split(',')[index],
                                      color1: [
                                        Colors.redAccent.shade100,
                                        Colors.amberAccent.shade400,
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
                              SizedBox(height: 5,),
                            ],
                          ),
                      if(payloadProvider.sourcePump[widget.index]['Current'] != null)
                        if(payloadProvider.sourcePump[widget.index]['Current'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5,),
                              Text('Current'),
                              SizedBox(height: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  for(var c in payloadProvider.sourcePump[widget.index]['Current'].split(','))
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          gradient: LinearGradient(
                                            colors: currentColor[c.split(':')[0]],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        // color: currentColor[c.split(':')[0]]
                                      ),
                                      child: Column(
                                        children: [
                                          Text('${currentName['${c.split(':')[0]}']}'),
                                          Text('${c.split(':')[1]}'),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Wrap(
                          runSpacing: 10,
                          spacing: 10,
                          children: [
                            if(payloadProvider.sourcePump[widget.index]['Level'] != null)
                              if(payloadProvider.sourcePump[widget.index]['Level'].isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(5),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: customBoxShadow,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Text('${payloadProvider.sourcePump[widget.index]['Level'][0]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['Level'][0]['Name']} '
                                            '\n ${payloadProvider.sourcePump[widget.index]['Level'][0]['Value']} Feet'),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Color(0xffE8EDFE),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(80.0),
                                              bottomLeft: Radius.circular(80.0),
                                              bottomRight: Radius.circular(80.0),
                                              topRight: Radius.circular(80.0)),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.grey.withOpacity(0.4),
                                                offset: const Offset(2, 2),
                                                blurRadius: 4),
                                          ],
                                        ),
                                        child: WaveViewInAlert(
                                          percentageValue: payloadProvider.sourcePump[widget.index]['Level'][0]['LevelPercent'].toDouble(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            if(payloadProvider.sourcePump[widget.index]['OnOffReason'] != null && payloadProvider.sourcePump[widget.index]['OnOffReason'] != '0')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reason',style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(height: 3,),
                                  Text('${pumpAlarmMessage[payloadProvider.sourcePump[widget.index]['OnOffReason']]}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                                  if(payloadProvider.sourcePump[widget.index]['OnOffReason'] != null && ['3','4','5','8','9','10'].contains(payloadProvider.sourcePump[widget.index]['OnOffReason']))
                                    Text('( set = ${payloadProvider.sourcePump[widget.index]['SetValue']} ,'
                                        ' Actual = ${payloadProvider.sourcePump[widget.index]['ActualValue']} '
                                        '${pumpAlarmMessage[payloadProvider.sourcePump[widget.index]['OnOffReason']].contains('voltage') ? ', Phase = ${payloadProvider.sourcePump[widget.index]['Phase']}' : ''})',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                                  if(['7','8','9','10'].contains(payloadProvider.sourcePump[widget.index]['OnOffReason']))
                                    MaterialButton(
                                      color: Colors.red,
                                      onPressed: ()async{
                                        MQTTManager().publish(
                                            jsonEncode({"6300" : [{"6301" : '${payloadProvider.sourcePump[widget.index]['S_No']},${1}'}]}),
                                            "AppToFirmware/${widget.imeiNo}");
                                        setState(() {
                                          payloadProvider.sourcePump[widget.index]['reset'] = true;
                                        });
                                      },
                                      child: Text('Reset',style: TextStyle(color: Colors.white),),
                                    )
                                ],
                              ),
                            if(payloadProvider.sourcePump[widget.index]['Pressure'] != null)
                              if(payloadProvider.sourcePump[widget.index]['Pressure'].isNotEmpty)
                                getFloatWidget(context: context, image: 'pressure_sensor', value: '${payloadProvider.sourcePump[widget.index]['Pressure'][0]['Value']}', name: '${payloadProvider.sourcePump[widget.index]['Pressure'][0]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['Pressure'][0]['Name']}'),
                            if(payloadProvider.sourcePump[widget.index]['Watermeter'] != null)
                              if(payloadProvider.sourcePump[widget.index]['Watermeter'].isNotEmpty)
                                getFloatWidget(context: context, image: 'water_meter', value: '${payloadProvider.sourcePump[widget.index]['Watermeter'][0]['Value']}', name: '${payloadProvider.sourcePump[widget.index]['Watermeter'][0]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['Watermeter'][0]['Name']}'),
                            if(payloadProvider.sourcePump[widget.index]['SumpTankLow'] != null)
                              if(payloadProvider.sourcePump[widget.index]['SumpTankLow'].isNotEmpty)
                                getFloatWidget(context: context, image: 'sump_low', value: '${payloadProvider.sourcePump[widget.index]['SumpTankLow'][0]['Value']}', name: '${payloadProvider.sourcePump[widget.index]['SumpTankLow'][0]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['SumpTankLow'][0]['Name']}'),
                            if(payloadProvider.sourcePump[widget.index]['SumpTankHigh'] != null)
                              if(payloadProvider.sourcePump[widget.index]['SumpTankHigh'].isNotEmpty)
                                getFloatWidget(context: context, image: 'sump_high', value: '${payloadProvider.sourcePump[widget.index]['SumpTankHigh'][0]['Value']}', name: '${payloadProvider.sourcePump[widget.index]['SumpTankHigh'][0]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['SumpTankHigh'][0]['Name']}'),
                            if(payloadProvider.sourcePump[widget.index]['TopTankLow'] != null)
                              if(payloadProvider.sourcePump[widget.index]['TopTankLow'].isNotEmpty)
                                getFloatWidget(context: context, image: 'tank_low', value: '${payloadProvider.sourcePump[widget.index]['TopTankLow'][0]['Value']}', name: '${payloadProvider.sourcePump[widget.index]['TopTankLow'][0]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['TopTankLow'][0]['Name']}'),
                            if(payloadProvider.sourcePump[widget.index]['TopTankHigh'] != null)
                              if(payloadProvider.sourcePump[widget.index]['TopTankHigh'].isNotEmpty)
                                getFloatWidget(context: context, image: 'tank_high', value: '${payloadProvider.sourcePump[widget.index]['TopTankHigh'][0]['Value']}', name: '${payloadProvider.sourcePump[widget.index]['TopTankHigh'][0]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['TopTankHigh'][0]['Name']}'),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          for(var on in [1,0])
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: InkWell(
                                onTap: ()async{
                                  if(payloadProvider.sourcePump[widget.index]['${on}loading'] == null){
                                    MQTTManager().publish(
                                        jsonEncode({"6200" : [{"6201" : '${payloadProvider.sourcePump[widget.index]['S_No']},${on},${1}'}]}),
                                        "AppToFirmware/${widget.imeiNo}");
                                    setState(() {
                                      payloadProvider.sourcePump[widget.index]['${on}loading'] = true;
                                    });
                                    for(var i = 0;i < 8;i++){
                                      await Future.delayed(Duration(seconds: 1));
                                      if(i == 7){
                                        setState(() {
                                          payloadProvider.sourcePump[widget.index].remove('${on}loading');
                                        });
                                      }
                                      if(payloadProvider.sourcePump[widget.index]['${on}loading'] == null){
                                        break;
                                      }
                                    }
                                  }

                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: on == 1 ? Colors.green : Colors.red,
                                      border: Border.all(width: 0.5),
                                      boxShadow: [
                                        BoxShadow(
                                            offset: const Offset(0,0),
                                            blurRadius: 4,
                                            color:  on == 1 ? Colors.greenAccent : Colors.deepOrange
                                        ),

                                      ]
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: Image.asset('assets/images/on_off.png'),
                                      ),
                                      SizedBox(width: 5,),
                                      payloadProvider.sourcePump[widget.index]['${on}loading'] == null ?  Text(on == 1 ? 'Motor On' : 'Motor OFF',style: TextStyle(color: Colors.white,fontSize: 14),) : loadingButton()
                                    ],
                                  ),
                                  // child: payloadProvider.sourcePump[widget.index]['${on}loading'] == null ?  Text(on == 1 ? 'Motor On' : 'Motor OFF',style: TextStyle(color: Colors.white,fontSize: 14),) : loadingButtuon()
                                ),
                              ),
                            ),
                        ],
                      )

                    ],
                  ),
                );
              });

            }
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 5,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        width: 100,
        height: 100,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              child: Transform.scale(
                scale: 0.8,
                child: getTypesOfPump(mode: widget.pumpMode, controller: widget.controller, animationValue: widget.controllerValue),
              ),
            ),
            if(payloadProvider.sourcePump[widget.index]['OnOffReason'] != null && payloadProvider.sourcePump[widget.index]['OnOffReason'] != '0')
              Positioned(
                  right: 5,
                  top: 10,
                  child: Icon(Icons.info,color: Colors.orange,)
              ),
            if(payloadProvider.sourcePump[widget.index]['Level'] != null)
              if(payloadProvider.sourcePump[widget.index]['Level'].isNotEmpty)
                Positioned(
                    left: 5,
                    top: 20,
                    child: Container(
                      width: 10,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 10,
                          height: 30 * (payloadProvider.sourcePump[widget.index]['Level'][0]['LevelPercent']/100) as double,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue.shade300
                          ),
                        ),
                      ),
                    )
                ),
            if(payloadProvider.sourcePump[widget.index]['Level'] != null)
              if(payloadProvider.sourcePump[widget.index]['Level'].isNotEmpty)
                Positioned(
                    left: 2,
                    top: 2,
                    child: Text('${payloadProvider.sourcePump[widget.index]['Level'][0]['Value']}%',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
                ),
            Positioned(
                left: 2,
                bottom: 5,
                child: Text(payloadProvider.sourcePump[widget.index]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['Name'],style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
            ),
            if(widget.delay != '00:00:00')
              Positioned(
                  left: 30,
                  top: 15,
                  child: Container(
                      padding: EdgeInsets.all(2),
                      color: Colors.black,
                      child: Text(widget.delay,style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold,color: Colors.white),)
                  )
              ),
          ],
        ),
      ),
    );
  }
}

Map<String,dynamic> oPumpIcon = {
  'SignalStrength' : Icons.signal_cellular_alt_sharp,
  'Battery' : Icons.battery_5_bar,
  'Version' : Icons.insert_drive_file_rounded,
};

Widget getIrrigationPump({required String pumpName,required data,required String delay,required int pumpMode,required BuildContext context,required AnimationController controller,required double animationValue,required Widget resetButton}){
  return InkWell(
    onTap: (){
      showDialog(
          context: context,
          builder: (context){
            return Consumer<MqttPayloadProvider>(builder: (context,payloadProvider,child){
              return AlertDialog(
                backgroundColor: Colors.white,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: data['Version'] != null ? IntrinsicWidth(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: cardColor
                          ),
                          child: Row(
                            children: [
                              getIcon(int.parse(data['SignalStrength'])),
                              Text('${data['SignalStrength']} %',style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ) : null,
                      title: Text(pumpName,style: TextStyle(color: primaryColorDark,fontWeight: FontWeight.bold)),
                      subtitle: data['Version'] != null ? Text('Version : ${data['Version']}',) : null,
                    ),
                    if(data['Voltage'] != null)
                      if(data['Voltage'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voltage'),
                            SizedBox(height: 8,),
                            Row(
                              children: [
                                for(var index = 0; index < 3; index++)
                                  buildContainer(
                                    title: ["RY", "YB", "BR"][index],
                                    value:data['Voltage'].split(',')[index],
                                    color1: [
                                      Colors.redAccent.shade100,
                                      Colors.amberAccent.shade400,
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
                            SizedBox(height: 5,),
                          ],
                        ),
                    if(data['Current'] != null)
                      if(data['Current'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5,),
                            Text('Current'),
                            SizedBox(height: 8,),
                            if(data['Current'].split(',')[0][1] != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  for(var c in data['Current'].split(','))
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          gradient: LinearGradient(
                                            colors: currentColor[c.split(':')[0]],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        // color: currentColor[c.split(':')[0]]
                                      ),
                                      child: Column(
                                        children: [
                                          Text('${currentName['${c.split(':')[0]}']}'),
                                          Text('${c.split(':')[1]}'),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                    SizedBox(height: 10,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Wrap(
                        runSpacing: 10,
                        spacing: 10,
                        children: [
                          // dry run , overload, current spp, started drip
                          if(data['OnOffReason'] != null && data['OnOffReason'] != '0')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reason',style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 3,),
                                Text('${pumpAlarmMessage[data['OnOffReason']]}\n '
                                    '( set = ${data['SetValue']} ,'
                                    ' Actual = ${data['ActualValue']} '
                                    '${pumpAlarmMessage[data['OnOffReason']].contains('voltage') ? ', Phase = ${data['Phase']}' : ''})',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                                if(data['OnOffReason'] != null && ['3','4','5','8','9','10'].contains(data['OnOffReason']))
                                  Text('( set = ${data['SetValue']} ,'
                                      ' Actual = ${data['ActualValue']} '
                                      '${pumpAlarmMessage[data['OnOffReason']].contains('voltage') ? ', Phase = ${data['Phase']}' : ''})',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                                resetButton
                              ],
                            ),
                          if(data['Level'] != null)
                            if(data['Level'].isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: customBoxShadow,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Text('${data['Level'][0]['SW_Name'] ?? data['Level'][0]['Name']}'
                                          '\n ${data['Level'][0]['Value']} m'),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Color(0xffE8EDFE),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(80.0),
                                            bottomLeft: Radius.circular(80.0),
                                            bottomRight: Radius.circular(80.0),
                                            topRight: Radius.circular(80.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(0.4),
                                              offset: const Offset(2, 2),
                                              blurRadius: 4),
                                        ],
                                      ),
                                      child: WaveView(
                                        percentageValue: double.parse(data['Level'][0]['Value']),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          if(data['Pressure'] != null)
                            if(data['Pressure'].isNotEmpty)
                              getFloatWidget(context: context, image: 'pressure_sensor', value: '${data['Pressure'][0]['Value']}', name: '${data['Pressure'][0]['SW_Name'] ?? data['Pressure'][0]['Name']}'),
                          if(data['Watermeter'] != null)
                            if(data['Watermeter'].isNotEmpty)
                              getFloatWidget(context: context, image: 'water_meter', value: '${data['Watermeter'][0]['Value']}', name: '${data['Watermeter'][0]['SW_Name'] ?? data['Watermeter'][0]['Name']}'),
                          if(data['SumpTankLow'] != null)
                            if(data['SumpTankLow'].isNotEmpty)
                              getFloatWidget(context: context, image: 'sump_low', value: '${data['SumpTankLow'][0]['Value']}', name: '${data['SumpTankLow'][0]['SW_Name'] ?? data['SumpTankLow'][0]['Name']}'),
                          if(data['SumpTankHigh'] != null)
                            if(data['SumpTankHigh'].isNotEmpty)
                              getFloatWidget(context: context, image: 'sump_high', value: '${data['SumpTankHigh'][0]['Value']}', name: '${data['SumpTankHigh'][0]['SW_Name'] ?? data['SumpTankHigh'][0]['Name']}'),
                          if(data['TopTankLow'] != null)
                            if(data['TopTankLow'].isNotEmpty)
                              getFloatWidget(context: context, image: 'tank_low', value: '${data['TopTankLow'][0]['Value']}', name: '${data['TopTankLow'][0]['SW_Name'] ?? data['TopTankLow'][0]['Name']}'),
                          if(data['TopTankHigh'] != null)
                            if(data['TopTankHigh'].isNotEmpty)
                              getFloatWidget(context: context, image: 'tank_high', value: '${data['TopTankHigh'][0]['Value']}', name: '${data['TopTankHigh'][0]['SW_Name'] ?? data['TopTankHigh'][0]['Name']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });

          }
      );
    },
    child: Container(
      margin: EdgeInsets.only(right: 5,),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            child: Transform.scale(
              scale: 0.8,
              child: getTypesOfPump(mode: pumpMode, controller: controller, animationValue: animationValue,),
            ),
          ),
          if(data['OnOffReason'] != null && data['OnOffReason'] != '0')
            Positioned(
                right: 5,
                top: 10,
                child: Icon(Icons.info,color: Colors.orange,)
            ),
          if(data['Level'] != null)
            if(data['Level'].isNotEmpty)
              Positioned(
                  left: 5,
                  top: 20,
                  child: Container(
                    width: 10,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade300
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 10,
                        height: 30*(double.parse(data['Level'][0]['Value'])/100),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue.shade300
                        ),
                      ),
                    ),
                  )
              ),
          if(data['Level'] != null)
            if(data['Level'].isNotEmpty)
              Positioned(
                  left: 2,
                  top: 2,
                  child: Text('${data['Level'][0]['Value']}%',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
              ),
          Positioned(
              left: 2,
              bottom: 1,
              child: Text(pumpName,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
          ),
          if(delay != '00:00:00')
            Positioned(
                left: 30,
                top: 0,
                child: Container(
                    padding: EdgeInsets.all(2),
                    color: Colors.black,
                    child: Text(delay,style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold,color: Colors.white),)
                )
            ),
        ],
      ),
    ),
  );
}

dynamic currentColor = {
  '1' : [Colors.redAccent.shade100, Colors.redAccent.shade200],
  '2' : [Colors.amber.shade100, Colors.amber.shade200],
  '3' : [Colors.blue.shade100, Colors.blue.shade200],
};

dynamic currentName = {
  '1' : 'RC',
  '2' : 'YC',
  '3' : 'BC',
};

Widget getTypesOfPump({required mode,required AnimationController controller,required double animationValue}){
  return AnimatedBuilder(
    animation: controller,
    builder: (BuildContext context, Widget? child) {
      return CustomPaint(
        painter: Pump(rotationAngle: [1].contains(mode)? animationValue : 0,mode: mode),
        size: const Size(100,80),
      );
    },
  );
}

int getWaterPipeStatus(BuildContext context,{int? selectedLine}){
  MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
  int mode = 0;
  if(payloadProvider.irrigationPump.any((element) => [1].contains(element['Status']))){
    mode = 1;
  }

  if(selectedLine != null){
    if(selectedLine != 0){
      dynamic pumpUsedInLine = payloadProvider.irrigationPump.where((element) => element['Location'].contains(payloadProvider.lineData[selectedLine]['id'])).toList();
      if(pumpUsedInLine.any((element) => [1].contains(element['Status']))){
        mode = 1;
      }else{
        mode = 0;
      }
    }
  }
  return mode;
}

int getWaterPipeStatusForSourcePump(BuildContext context){
  MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
  int mode = 0;
  if(payloadProvider.sourcePump.any((element) => [1].contains(element['Status']))){
    mode = 1;
  }
  return mode;
}

Widget getActiveObjects({required BuildContext context,required bool active,required String title,required Function()? onTap,required int mode}){
  List<Color> gradient = active == true
      ? [Color(0xff22414C),Color(0xff294C5C)]
      : [];
  return  InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      height: (30 * getTextScaleFactor(context)).toDouble(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(mode == 1 ? 4 : 0),
            bottomLeft: Radius.circular(mode == 1 ? 4 : 0),
            topRight: Radius.circular(mode == 2 ? 4 : 0),
            bottomRight: Radius.circular(mode == 2 ? 4 : 0),
          ),
          gradient:  active == true ? LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: gradient,
          ) : null,
          color: active == false ? Color(0xffECECEC) : null
      ),
      child: Center(child: Text(title,style: TextStyle(fontWeight: FontWeight.bold,color: active == true ? Colors.white : Colors.black),)),
    ),
  );
}

int getFilter(filterStatus,BuildContext context,programStatus){
  int mode = 0;
  if(filterStatus == 1){
    mode = 1;
  }else if(filterStatus == 2){
    mode = 2;
  }else if(getWaterPipeStatus(context) == 0){
    mode = 0;
  }else if(filterStatus == 0){
    mode = 3;
  }
  if(programStatus == ''){
    mode = 0;
  }
  return mode;
}

Widget getInfoBox(
    {
      required BuildContext context,
      required String title,
      required String value,
      required Color border,
      required Color fillColor,
      Color? circularColor,
      Icon? icon,
    }){
  return Container(
    width: MediaQuery.of(context).size.width / 3,
    height: 80,
    decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: customBoxShadow
      // border: Border.all(color: Colors.black,width: 0.3)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if(circularColor != null)
          Container(
            margin: EdgeInsets.all(5),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: circularColor
            ),
            child: icon,
          ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(title,style: TextStyle(fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis),
              Text(value,overflow: TextOverflow.ellipsis,),
            ],
          ),
        ),

      ],
    ),
  );
}

String getImage(int code){
  if(code == 0){
    return 'b';
  }else if(code == 1){
    return 'g';
  }else if(code == 2){
    return 'o';
  }else{
    return 'r';
  }
}

getTextScaleFactor(context){
  return MediaQuery.of(context).textScaleFactor;
}

Widget getLineWidget({required BuildContext context,required AnimationController controller,required int selectedLine,required MqttPayloadProvider payloadProvider,required int currentLine}){
  double textScaleFactor = MediaQuery.of(context).textScaleFactor;
  int waterFlow = 0;
  for(var i in payloadProvider.currentSchedule){
    if(i['ProgCategory'].split('_').contains(payloadProvider.lineData[currentLine]['id'])){
      if(payloadProvider.irrigationPump.any((element) => [1].contains(element['Status']))){
        waterFlow = 1;
      }
      break;
    }
  }
  var joint = 'T_joint';
  if(payloadProvider.selectedLine != 0){
    joint = 'L_joint';
  }
  if(currentLine == payloadProvider.lineData.length - 1){
    joint = 'L_joint';
  }
  num item = 0;
  num screenSize = 0;
  var mainValve = payloadProvider.lineData[currentLine]['mainValve'].length;
  item += mainValve;
  var valve = payloadProvider.lineData[currentLine]['valve'].length;
  // var valve = 20;
  item += valve;
  // if(payloadProvider.lineData[currentLine]['pressureIn'] != null){
  //   item += payloadProvider.lineData[currentLine]['pressureIn'].isNotEmpty ? 1 : 0;
  // }
  // if(payloadProvider.lineData[currentLine]['pressureOut'] != null){
  //   item += payloadProvider.lineData[currentLine]['pressureOut'].isNotEmpty ? 1 : 0;
  // }
  item += payloadProvider.lineData[currentLine]['pressureSensor'].length;
  if(payloadProvider.lineData[currentLine]['dpValve'] != null){
    item += payloadProvider.lineData[currentLine]['dpValve'].isNotEmpty ? 1 : 0;
  }
  if(payloadProvider.lineData[currentLine]['waterMeter'] != null){
    item += payloadProvider.lineData[currentLine]['waterMeter'].isNotEmpty ? 1 : 0;
  }
  screenSize = MediaQuery.of(context).size.width - 40;
  var noWidgetInCalculatedWidth = screenSize / 70;
  double calculatedHeight = 0;
  if(item >= noWidgetInCalculatedWidth.round()){
    calculatedHeight = ((item/noWidgetInCalculatedWidth) + 1) * 77;
  }else{
    calculatedHeight = (120 * textScaleFactor);
  }

  return Container(
      padding: EdgeInsets.only(left: 8,right: 8),
      width: double.infinity,
      height: calculatedHeight.toDouble(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: calculatedHeight.toDouble(),
            child: Stack(
              children: [
                SizedBox(
                    width: 40,
                    height: joint == 'L_joint' ? calculatedHeight/2 : calculatedHeight.toDouble(),
                    child: verticalPipeTopFlow(count: (calculatedHeight~/100)+2, mode: getWaterPipeStatus(context,selectedLine: selectedLine), controller: controller,)
                ),
                Positioned(
                    top: calculatedHeight/2 + 8,
                    child: SizedBox(
                        width: 40,
                        height: 40,
                        child: horizontalPipeLeftFlow(count: 2,mode: waterFlow, controller: controller,)
                    )
                ),
                Positioned(
                  left: joint == 'L_joint' ? -1 : -3,
                  top: calculatedHeight/2 - (joint == 'L_joint' ? 2 : 0),
                  child: Transform.rotate(
                    angle: joint == 'L_joint' ? 3.14 : 4.71,
                    child: SizedBox(
                      width: 25 - (joint == 'L_joint' ? 5 : 0),
                      height: 25 - (joint == 'L_joint' ? 5 : 0),
                      child: SvgPicture.asset(
                        'assets/images/${joint}.svg',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.bottomCenter,
                    child: Text('${payloadProvider.lineData[currentLine]['name']} ${returnProgramName(payloadProvider: payloadProvider, currentLine: currentLine)}',style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff007988)
                    ),),
                    padding: EdgeInsets.all(2)
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: customBoxShadow
                  ),
                  padding: EdgeInsets.all(8),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.spaceEvenly,
                    // runSpacing: 10,
                    // spacing: 10.0,
                    children: [
                      if(payloadProvider.lineData[currentLine]['waterMeter'].isNotEmpty)
                        SizedBox(
                          width: 70,
                          height: 60,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 18,
                                child: Image.asset('assets/images/water_meter.png'),
                              ),
                              Text('WM.${currentLine}.1',style: TextStyle(fontSize: 11,overflow: TextOverflow.ellipsis),),
                              Text('${payloadProvider.lineData[currentLine]['waterMeter'][0]['value']}',style: TextStyle(fontSize: 11,overflow: TextOverflow.ellipsis),)
                            ],
                          ),
                        ),
                      for(var ps in payloadProvider.lineData[currentLine]['pressureSensor'])
                        SizedBox(
                          width: 70,
                          height: 60,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 23,
                                height: 23,
                                child: Image.asset('assets/images/pressure_sensor.png'),
                              ),
                              Text('${ps['hid'].contains('LI') ? 'Press In' : 'Press Out'} : \n${ps['value']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                            ],
                          ),
                        ),
                      // if(payloadProvider.lineData[currentLine]['pressureSensor'] != null)
                      //   SizedBox(
                      //     width: 70,
                      //     height: 60,
                      //     child: Column(
                      //       children: [
                      //         SizedBox(
                      //           width: 23,
                      //           height: 23,
                      //           child: Image.asset('assets/images/pressure_sensor.png'),
                      //         ),
                      //         Text('PSI.${currentLine}.1 : \n${payloadProvider.lineData[currentLine]['pressureIn']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                      //       ],
                      //     ),
                      //   ),
                      // if(payloadProvider.lineData[currentLine]['pressureSensor'] != null)
                      //   SizedBox(
                      //     width: 70,
                      //     height: 60,
                      //     child: Column(
                      //       children: [
                      //         SizedBox(
                      //           width: 23,
                      //           height: 23,
                      //           child: Image.asset('assets/images/pressure_sensor.png'),
                      //         ),
                      //         Text('PSO.${currentLine}.1 : \n${payloadProvider.lineData[currentLine]['pressureOut']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                      //       ],
                      //     ),
                      //   ),
                      for(var i = 0 ;i < mainValve;i++)
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 23,
                                height: 23,
                                child: Image.asset('assets/images/main_valve_${getImage(payloadProvider.lineData[currentLine]['mainValve'][i]['status'])}.png'),
                              ),
                              Text('${payloadProvider.lineData[currentLine]['mainValve'][i]['name']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                            ],
                          ),
                        ),
                      for(var i = 0 ;i < valve;i++)
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 23,
                                height: 23,
                                child: Image.asset('assets/images/valve_${getImage(payloadProvider.lineData[currentLine]['valve'][i]['status'])}.png'),
                              ),
                              Text('${payloadProvider.lineData[currentLine]['valve'][i]['name']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                            ],
                          ),
                        ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
  );
}

String returnProgramName({
  required MqttPayloadProvider payloadProvider,
  required int currentLine
}){
  var programName = '';
  for(var i in payloadProvider.currentSchedule){
    if(i['ProgCategory'].contains(payloadProvider.lineData[currentLine]['id'])){
      programName = i['ProgName'];
    }
  }
  return programName != '' ? '($programName)' : programName;
}

dynamic getAlarmMessage = {
  1 : 'Low Flow',
  2 : 'High Flow',
  3 : 'No Flow',
  4 : 'Ec High',
  5 : 'Ph Low',
  6 : 'Ph High',
  7 : 'Pressure Low',
  8 : 'Pressure High',
  9 : 'No Power Supply',
  10 : 'No Communication',
  11 : 'Wrong Feedback',
  12 : 'Sump Tank Empty',
  13 : 'Top Tank Full',
  14 : 'Low Battery',
  15 : 'Ec Difference',
  16 : 'Ph Difference',
  17 : 'Pump Off Alarm',
  18 : 'Pressure Switch High',
};

dynamic pumpAlarmMessage = {
  '1' : 'sump empty',
  '2' : 'upper tank full',
  '3' : 'low voltage',
  '4' : 'high voltage',
  '5' : 'voltage SPP',
  '6' : 'reverse phase',
  '7' : 'starter trip',
  '8' : 'dry run',
  '9' : 'overload',
  '10' : 'current SPP',
  '11' : 'cyclic trip',
  '12' : 'maximum run time',
  '13' : 'sump empty',
  '14' : 'upper tank full',
  '15' : 'RTC 1',
  '16' : 'RTC 2',
  '17' : 'RTC 3',
  '18' : 'RTC 4',
  '19' : 'RTC 5',
  '20' : 'RTC 6',
  '21' : 'auto mobile key off',
  '22' : 'cyclic time',
  '23' : 'RTC 1',
  '24' : 'RTC 2',
  '25' : 'RTC 3',
  '26' : 'RTC 4',
  '27' : 'RTC 5',
  '28' : 'RTC 6',
  '29' : 'auto mobile key on',
  '30' : 'Power off',
  '31' : 'Power on',
};

class MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double containerWidth;
  final double containerHeight;

  MarqueeText({
    required this.text,
    required this.style,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: containerWidth);

        bool isOverflowing = textPainter.didExceedMaxLines;

        return SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

void sentUserOperationToServer(String msg,dynamic data,BuildContext context) async {
  var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
  Map<String, Object> body = {
    "userId": overAllPvd.getUserId(),
    "controllerId": overAllPvd.controllerId,
    "messageStatus": msg,
    "hardware" : data,
    "createUser": overAllPvd.getUserId(),
  };
  final response = await HttpService().postRequest("createUserManualOperationInDashboard", body);
  if (response.statusCode == 200) {
  } else {
    throw Exception('Failed to load data');
  }
}

Widget findNestedLen({
  required data,
  required parentNo,
}) {
  List<Widget> list = [];
  if (data['Combined'].isEmpty) {
  } else {
    for (var i = 0;i < data['Combined'].length;i++) {
      list.add(
          findNestedLen(
            data: data['Combined'][i],
            parentNo: parentNo + 1,
          )
      );
    }
  }
  return Container(
    margin: EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.only(left: 20,right : 5,top: 10,bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(width: 2,color:flowChatColor[parentNo].withOpacity(data['Status'] == 1 ? 1.0 : 0.2), ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Condition : ${data['S_No']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11),),
                SizedBox(width: 30,),
                Icon(Icons.notifications_active,size: 20,color: Color(0xff054750).withOpacity(data['Status'] == 1 ? 1 : 0.3))
              ],
            ),
            SizedBox(height: 3,),
            SizedBox(
                width: 150,
                child: Text('${data['Condition']}',style: TextStyle(fontSize: 10))
            ),
            SizedBox(height: 3,),
          ],
        ),
        ...list,
      ],
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
      margin: const EdgeInsets.symmetric(horizontal: 5),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                // fontSize: 1,
              ),
            ),
            // SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

dynamic flowChatColor = {
  0 : Colors.blue,
  1 : Colors.deepOrange,
  2 : Colors.green,
  3 : Colors.purple,
  4 : Colors.grey,
  5 : Colors.blue,
  6 : Colors.deepOrange,
  7 : Colors.green,
  8 : Colors.purple,
  9 : Colors.grey,
  10 : Colors.blue,
  11 : Colors.deepOrange,
  12 : Colors.green,
  13 : Colors.purple,
  14 : Colors.grey,
};
