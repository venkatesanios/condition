import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_view/constants/theme.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'package:provider/provider.dart';
import '../../../../ListOfFertilizerInSet.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import '../../../../state_management/overall_use.dart';
import '../../Planning/NewIrrigationProgram/irrigation_program_main.dart';
import 'dashboard_payload_handler.dart';
import 'home_page.dart';
import 'mobile_dashboard_common_files.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ScheduleProgramForMobile extends StatefulWidget {
  final int selectedLine;
  final MQTTManager manager;
  final String deviceId;
  final int userId;
  final int controllerId;
  const ScheduleProgramForMobile({super.key, required this.manager, required this.deviceId, required this.selectedLine, required this.userId, required this.controllerId});

  @override
  State<ScheduleProgramForMobile> createState() => _ScheduleProgramForMobileState();
}

class _ScheduleProgramForMobileState extends State<ScheduleProgramForMobile> {
  ScrollController _ScheduleProgramController = ScrollController();

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    return  Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 40,),
        Text('List Of Program',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
        SizedBox(height: 20,),
        if(payloadProvider.upcomingProgram.isNotEmpty)
          for(var program in payloadProvider.upcomingProgram)
            if(['All',program['ProgCategory']].contains(payloadProvider.lineData[widget.selectedLine]['id']))
              Container(
                margin: EdgeInsets.only(bottom: 20,left: 10,right: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: customBoxShadow
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: CircleAvatar(
                        backgroundColor: primaryColorDark,
                        child: Center(
                          child: Text(program['ProgName'].isNotEmpty ? program['ProgName'].substring(0, 1).toUpperCase() : '',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      title: Text(program['ProgName'],style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text('${programSchedule[program['SchedulingMethod']]}',style: TextStyle(color: primaryColorDark,overflow: TextOverflow.ellipsis),),
                      trailing: Text('${program['TotalZone']} Zones',style: TextStyle(color: primaryColorDark,fontWeight: FontWeight.bold,fontSize: 14),),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey.shade200,
                            value: (program['ProgramStatusPercentage']/100).toDouble(),
                            color: Colors.green,
                          ),
                        ),
                        Text('  ${program['ProgramStatusPercentage']} %'),
                      ],
                    ),
                    SizedBox(height: 5,),
                    if(program['StartCondition'].isNotEmpty || program['StopCondition'].isNotEmpty)
                      Column(
                        children: [
                          SizedBox(height: 5,),
                          for(var condition in ['StartCondition','StopCondition'])
                            if(program[condition] != null && program[condition].isNotEmpty)
                              Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${condition.contains('Start') ? 'Start' : 'Stop'} Condition Details',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                              InkWell(
                                  onTap: (){
                                    int index = payloadProvider.upcomingProgram.indexOf(program);
                                    showDialog(context: context, builder: (context){
                                      return Consumer<MqttPayloadProvider>(builder: (context,payloadProvider,child){
                                        dynamic program = payloadProvider.upcomingProgram[index];
                                        return AlertDialog(
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${condition.contains('Start') ? 'Start' : 'Stop'} Condition'),
                                              IconButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  }, icon: Icon(Icons.cancel,color: Colors.red,)
                                              )
                                            ],
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      findNestedLen(
                                                          data: program[condition],
                                                        parentNo: 0
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // actions: [
                                          //   TextButton(
                                          //       onPressed: (){
                                          //         Navigator.pop(context);
                                          //       },
                                          //       child: Text('Ok')
                                          //   )
                                          // ],
                                        );
                                      });
                                    });
                                  },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.pink,

                                  ),
                                    child: Text('View',style: TextStyle(color: Colors.white),)
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                        ],
                      ),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month,color: Colors.black,),
                              SizedBox(width: 10,),
                              Text('Start Date to End Date',style: TextStyle(color: Colors.black),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('${program['StartDate']}',style: TextStyle(color: Colors.black,),),
                              Text('to',style: TextStyle(color: Colors.black),),
                              Text('${program['EndDate']}',style: TextStyle(color: Colors.black,),),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text('${program['StartTime'] == '-' ? 'No Schedule' : 'Start Time : ${program['StartTime']}'}',style: TextStyle(color: Colors.pink),),
                          SizedBox(height: 5,),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Stop Reason',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                        Text('  ${programStartStopReason(code: program['StartStopReason'])}',style: TextStyle(color: primaryColorDark,fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pause Resume Reason',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                        Text('  ${programStartStopReason(code: program['PauseResumeReason'])}',style: TextStyle(color: primaryColorDark,fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: DashboardPayloadHandler(manager: widget.manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: payloadProvider.upcomingProgram.indexOf(program)).programStartStop,
                              // onTap:()async{
                              //   if(int.parse(program['ProgOnOff']) >= 0){
                              //     if(program['startStopCode'] == null){
                              //       String payload = '${program['SNo']},${program['ProgOnOff']}';
                              //       String payLoadFinal = jsonEncode({
                              //         "2900": [{"2901": payload}]
                              //       });
                              //       widget.manager.publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                              //       sentUserOperationToServer('${program['ProgName']} ${programOnOff[program['ProgOnOff']]}', payLoadFinal,context);
                              //       setState(() {
                              //         program['startStopCode'] = true;
                              //         payloadProvider.messageFromHw = '';
                              //       });
                              //       for(var seconds = 0;seconds < 8;seconds++){
                              //         await Future.delayed(Duration(seconds: 1));
                              //         if(payloadProvider.messageFromHw != ''){
                              //           stayAlert(context: context, payloadProvider: payloadProvider, message: 'Hardware recieved successfully');
                              //           break;
                              //         }
                              //         if(seconds == 7){
                              //           setState(() {
                              //             program.remove('startStopCode');
                              //           });
                              //         }
                              //       }
                              //       Future.delayed(Duration(seconds: 8),(){
                              //         setState(() {
                              //           program.remove('startStopCode');
                              //         });
                              //       });
                              //     }
                              //   }
                              // },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: programOnOffColor[program['ProgOnOff']],
                                ),
                                child:program['startStopCode'] == null
                                    ? Text('${programOnOff[program['ProgOnOff']]}',style: TextStyle(color: Colors.white),)
                                    : loadingButton(),
                              ),
                            ),
                            SizedBox(width: 10,),
                            InkWell(
                              onTap: DashboardPayloadHandler(manager: widget.manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: payloadProvider.upcomingProgram.indexOf(program)).programPauseResume,
                              // onTap:()async{
                              //   if(program['pauseResumeCode'] == null){
                              //     String payload = '${program['SNo']},${program['ProgPauseResume']}';
                              //     String payLoadFinal = jsonEncode({
                              //       "2900": [{"2901": payload}]
                              //     });
                              //     widget.manager.publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                              //     sentUserOperationToServer('${program['ProgName']} ${program['ProgPauseResume'] != '1' ? 'Pause' : 'Resume'} by Manual', payLoadFinal,context);
                              //   }
                              //   setState(() {
                              //     program['pauseResumeCode'] = true;
                              //     payloadProvider.messageFromHw = '';
                              //   });
                              //   for(var seconds = 0;seconds < 8;seconds++){
                              //     await Future.delayed(Duration(seconds: 1));
                              //     if(payloadProvider.messageFromHw != ''){
                              //       stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware recieved successfully');
                              //       break;
                              //     }
                              //     if(seconds == 7){
                              //       setState(() {
                              //         program.remove('pauseResumeCode');
                              //       });
                              //     }
                              //   }
                              // },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: programOnOffColor[program['ProgPauseResume']],
                                ),
                                child : program['pauseResumeCode'] == null ? Text('${program['ProgPauseResume'] == '2' ? 'Pause' : 'Resume'}',style: TextStyle(color:Colors.black),)
                                    : loadingButton(),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap:()async{
                            var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

                            String prgType = '';
                            bool conditionL = false;
                            if(program['ProgCategory'].contains('IL')){
                              prgType='Irrigation Program';
                            }else{
                              prgType='Agitator Program';
                            }
                            if((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['conditionLibraryCount'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['conditionLibraryCount']) > 0 ){
                              conditionL = true;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) {
                                return IrrigationProgram(userId: widget.userId, controllerId: widget.controllerId, serialNumber: program['SNo'], deviceId: widget.deviceId,programType: prgType,conditionsLibraryIsNotEmpty: conditionL, fromDealer: false,);
                              })
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: primaryColorDark,
                            ),
                            child : Text('Edit',style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),


                  ],
                ),
              ),
        SizedBox(height: 50,),

      ],
    );
  }
}

Map<int,String> programSchedule = {
  1 : 'No Schedule',
  2 : 'Schedule by Days',
  3 : 'Schedule as Run List',
  4 : 'Day Count RTC'
};

dynamic programOnOff = {
  '-1' : 'PausedCouldntStart',
  '1' : 'StartManually',
  '-2' : 'StartedByConditionCouldntStop',
  '7' : 'StopManually',
  '13' : 'ByPassStartCondition',
  '11' : 'ByPassCondition',
  '12' : 'BypassStopConditionAndStart',
  '0' : 'StopManually',
  '2' : 'Pause',
  '3' : 'Resume',
  '4' : 'ContinueManually',
  '-3' : 'StartedByRtcCouldntStop',
};

dynamic programOnOffColor = {
  '-1' : Colors.grey.shade200,
  '1' : Colors.green,
  '-2' : Colors.grey.shade200,
  '7' : Colors.red,
  '13' : Colors.green,
  '11' : Colors.green,
  '12' : Colors.red,
  '0' : Colors.red,
  '2' : Colors.orange,
  '3' : Colors.yellow,
  '4' : Colors.green,
  '-3' : Colors.grey.shade200,
};

String programStartStopReason({required int code}){
  switch(code){
    case (1):
      return 'Running As Per Schedule';
    case (2):
      return 'Turned On Manually';
    case (3):
      return 'Started By Condition';
    case (4):
      return 'TurnedOff Manually';
    case (5):
      return 'Program TurnedOff';
    case (6):
      return 'Zone TurnedOff';
    case (7):
      return 'Stopped By Condition';
    case (8):
      return 'Disabled By Condition';
    case (9):
      return 'StandAlone Program Started';
    case (10):
      return 'StandAlone Program Stopped';
    case (11):
      return 'StandAlone Program Stopped After SetValue';
    case (12):
      return 'Stand Alone Manual Started';
    case (13):
      return 'StandAlone Manual Stopped';
    case (14):
      return 'StandAlone Manual Stopped AfterSetValue';
    case (15):
      return 'Started By Day CountRtc';
    case (16):
      return 'Paused By User';
    case (17):
      return 'Manually Started Paused By User';
    case (18):
      return 'Program Deleted';
    case (19):
      return 'Program Ready';
    case (20):
      return 'Program Completed';
    case (21):
      return 'Resumed By User';
    case (22):
      return 'Paused By Condition';
    case (23):
      return 'Program Ready And Run By Condition';
    case (24):
      return 'Running As PerSchedule And Condition';
    case (25):
      return 'Started B yCondition Paused By User';
    case (26):
      return 'Resumed By Condition';
    case (27):
      return 'Bypassed Start ConditionManually';
    case (28):
      return 'Bypassed Stop ConditionManually';
    case (29):
      return 'Continue Manually';
    case (30):
      return '-';
    case (31):
      return 'Program Completed';
    case (32):
      return 'Waiting For Condition';
    case (33):
      return 'Started By Condition And Run As Per Schedule';
    default:
      return 'code : $code';
  }
}

Widget loadingButton(){
  return SizedBox(
    width: 20,
    height: 20,
    child: LoadingIndicator(
      colors: [
        Colors.white,
        Colors.white,
      ],
      indicatorType: Indicator.ballPulse,
    ),
  );
}