import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';

class FinishInConstant extends StatefulWidget {
  const FinishInConstant({super.key, required this.userId, required this.controllerId, required this.customerId, required this.deviceId});
  final userId, controllerId, customerId,deviceId;
  // MqttClass? singleInstanceMqtt;

  @override
  State<FinishInConstant> createState() => _FinishInConstantState();
}

class _FinishInConstantState extends State<FinishInConstant> {
  @override
  Widget build(BuildContext context) {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    return Container(
      color: const Color(0xFFF3F3F3),
      child: Center(
        child: InkWell(
          onTap: ()async{
            var flag = 0;
            showDialog(context: context, builder: (context){
              return Consumer<ConstantProvider>(builder: (context,constantPvd,child){
                return AlertDialog(
                  title: Text(constantPvd.wantToSendData == 0
                      ? 'Send to server' : constantPvd.wantToSendData == 1
                      ?  'Sending.....' : constantPvd.wantToSendData == 2
                      ? 'Success...' : constantPvd.wantToSendData == 3
                      ? 'No Internet' : constantPvd.wantToSendData == 4
                      ? 'Mqtt Error' : 'Code Error',style: TextStyle(color: (constantPvd.wantToSendData == 3 || constantPvd.wantToSendData == 4) ? Colors.red : Colors.green),),
                  content: constantPvd.wantToSendData == 0
                      ? const Text('Are you sure want to send data ? ')
                      : SizedBox(
                    width: 200,
                    height: 200,
                    child: constantPvd.wantToSendData == 2
                        ? Image.asset('assets/images/success.png')
                        : constantPvd.wantToSendData == 3
                        ? Image.asset('assets/images/serverError.png')
                        : constantPvd.wantToSendData == 4
                        ? Image.asset('assets/images/mqttError.png')
                        :const LoadingIndicator(
                      indicatorType: Indicator.pacman,
                    ),
                  ),
                  actions: [
                    if(constantPvd.wantToSendData == 0)
                      InkWell(
                        onTap: ()async{
                          constantPvd.editWantToSendData(1);
                          HttpService service = HttpService();
                          try{
                            setState(() {
                              payloadProvider.messageFromHw = {};
                            });
                            MQTTManager().publish(jsonEncode(constantPvd.sendDataToHW()),'AppToFirmware/${overAllPvd.imeiNo}');
                            delayLoop : for(var i = 0;i < 30;i++){
                              await Future.delayed(Duration(seconds: 1));
                              if(payloadProvider.messageFromHw.isNotEmpty){
                                if(payloadProvider.messageFromHw['Code'] == '200'){
                                  flag = 1;
                                }
                                break delayLoop;
                              }
                            }
                            var response = await service.postRequest('createUserConstant', {
                              'controllerReadStatus' : flag.toString(),
                              'userId' : overAllPvd.userId,
                              'controllerId' : overAllPvd.controllerId,
                              'createUser' : overAllPvd.userId,
                              'general' : constantPvd.generalUpdated,
                              'pump' : constantPvd.pumpUpdated,
                              'line' : constantPvd.irrigationLineUpdated,
                              // 'line' : [],
                              'mainValve' : constantPvd.mainValveUpdated,
                              // 'mainValve' : [],
                              'valve' : constantPvd.valveUpdated,
                              // 'valve' : [],
                              'waterMeter' : constantPvd.waterMeterUpdated,
                              // 'waterMeter' : [],
                              'fertilization' : constantPvd.fertilizerUpdated,
                              // 'fertilization' : [],
                              'ecPh' : constantPvd.ecPhUpdated,
                              // 'ecPh' : [],
                              'filtration' : constantPvd.filterUpdated,
                              // 'filtration' : [],
                              'analogSensor' : constantPvd.analogSensorUpdated,
                              // 'analogSensor' : [],
                              'moistureSensor' : constantPvd.moistureSensorUpdated,
                              // 'moistureSensor' : [],
                              'levelSensor' : constantPvd.levelSensorUpdated,
                              // 'levelSensor' : [],
                              'normalAlarm' : constantPvd.alarmUpdated,
                              'criticalAlarm' : constantPvd.criticalAlarmUpdated,
                              'globalAlarm' : constantPvd.globalAlarmUpdated,
                            });
                            var jsonData = jsonDecode(response.body);
                            if(jsonData['code'] == 200){
                              Future.delayed(const Duration(seconds: 1), () {
                                if(flag == 0){
                                  constantPvd.editWantToSendData(4);
                                }else{
                                  constantPvd.editWantToSendData(2);
                                }
                              });
                            }else{
                              constantPvd.editWantToSendData(3);
                            }

                          }catch(e){
                            print(e.toString());
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 30,
                          color: myTheme.primaryColor,
                          child: const Center(
                            child: Text('Yes',style: TextStyle(color: Colors.white,fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    if([2,3,4].contains(constantPvd.wantToSendData))
                      InkWell(
                        onTap: (){
                          constantPvd.editWantToSendData(0);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 80,
                          height: 30,
                          color: myTheme.primaryColor,
                          child: const Center(
                            child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
                            ),
                          ),
                        ),
                      )
                  ],
                );
              });

            });
          },
          child: Container(
            width: 250,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: constantPvd.flag == '0' ? Colors.yellow : Colors.green.shade200,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/sendToServer.png')),
                const Text('Send',style: TextStyle(fontSize: 20,color: Colors.black),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}