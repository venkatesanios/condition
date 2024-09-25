import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_view/constants/data_convertion.dart';
import 'package:mobile_view/constants/theme.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/schedule_program.dart';
import '../../../../constants/MQTTManager.dart';
import '../../../../constants/http_service.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../state_management/overall_use.dart';
import 'dashboard_payload_handler.dart';
import 'home_page.dart';

class CurrentScheduleForMobile extends StatefulWidget {
  final MQTTManager manager;
  final String deviceId;
  const CurrentScheduleForMobile({super.key, required this.manager, required this.deviceId});

  @override
  State<CurrentScheduleForMobile> createState() => _CurrentScheduleForMobileState();
}

class _CurrentScheduleForMobileState extends State<CurrentScheduleForMobile> {
  ScrollController _currentScheduleController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 50,),
        Text('Current Schedule',style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.black
        ),),
        SizedBox(height: 5,),
        if(payloadProvider.currentSchedule.isEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: Image.asset('assets/images/no_data.jpg'),
          ),
        if(payloadProvider.currentSchedule.isNotEmpty)
          Container(
            margin: EdgeInsets.all(8),
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Color(0xffE6EDF5),
                borderRadius: BorderRadius.circular(20)
            ),
            child: SingleChildScrollView(
              controller: _currentScheduleController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for(var i = 0;i < payloadProvider.currentSchedule.length;i++)
                    Row(
                      children: [
                        InkWell(
                          onTap: (){
                            setState(() {
                              payloadProvider.selectedCurrentSchedule = i;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: i == payloadProvider.selectedCurrentSchedule ? Color(0xff1A7886) : null
                            ),
                            child: Center(child: Text('${payloadProvider.currentSchedule[i]['ProgName']}',style: TextStyle(color: i == payloadProvider.selectedCurrentSchedule ? Colors.white : Colors.black87,fontSize: 13,fontWeight: FontWeight.w200),)),
                          ),
                        ),
                        SizedBox(width: 20,)
                      ],
                    )
                ],
              ),
            ),
          ),
        if(payloadProvider.currentSchedule.isNotEmpty)
          Container(
              padding: EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  ListTile(
                      subtitle: Text('${payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['StartTime']}',style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      ),
                      title: Text('Start time'),
                      trailing: IntrinsicWidth(
                        child: (payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['Message'] == 'Running.' || payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone'))
                            ? InkWell(
                          onTap: DashboardPayloadHandler(manager: widget.manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: payloadProvider.selectedCurrentSchedule).scheduleSkip,
                          // onTap: ()async{
                          //   if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['standaloneLoading'] == null){
                          //     if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('Manual')){
                          //       String payload = '0,0,0,0';
                          //       String payLoadFinal = jsonEncode({
                          //         "800": [{"801": payload}]
                          //       });
                          //       MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
                          //       Map<String, dynamic> manualOperation = {
                          //         "programName": payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].split('StandAlone - ')[1],
                          //         "programId": 0,
                          //         "method": 1,
                          //         "time": '00:00',
                          //         "flow": '0',
                          //         "selected": [],
                          //         'fromDashboard' : true
                          //       };
                          //       try {
                          //         final body = {"userId": overAllPvd.userId, "controllerId": overAllPvd.controllerId, "manualOperation": manualOperation, "createUser": overAllPvd.userId,'hardware' : jsonDecode(payLoadFinal)};
                          //         final response = await HttpService().postRequest("createUserManualOperation", body);
                          //         if (response.statusCode == 200) {
                          //           final jsonResponse = json.decode(response.body);
                          //         }
                          //       } catch (e) {
                          //         print('Error: $e');
                          //       }
                          //     }
                          //     else if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone')){
                          //       var programInfo = payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule];
                          //       final programModePayload = {
                          //         "3900": [
                          //           {
                          //             "3901":
                          //             "${0},"
                          //                 "${programInfo['ProgCategory']},"
                          //                 "${programInfo['ProgramS_No']},"
                          //                 "${programInfo['ZoneS_No']},"
                          //                 ","
                          //                 ","
                          //                 ","
                          //                 ","
                          //                 ","
                          //                 ","
                          //                 ","
                          //                 ","
                          //                 "${0},"
                          //                 ""
                          //           },
                          //           {
                          //             "3902": "${overAllPvd.getUserId()}"
                          //           }
                          //         ]
                          //       };
                          //       MQTTManager().publish(jsonEncode(programModePayload), 'AppToFirmware/${overAllPvd.imeiNo}');
                          //       Map<String, dynamic> manualOperation = {
                          //         "programName": payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].split('StandAlone - ')[1],
                          //         "programId": payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgramS_No'],
                          //         "startFlag":0,
                          //         "method": 1,
                          //         "time": '00:00:00',
                          //         "flow": '0',
                          //         "selected": [],
                          //         'fromDashboard' : true
                          //       };
                          //       try {
                          //         final body = {"userId": overAllPvd.userId, "controllerId": overAllPvd.controllerId, "manualOperation": manualOperation, "createUser": overAllPvd.userId,'hardware' : programModePayload};
                          //         final response = await HttpService().postRequest("createUserManualOperation", body);
                          //         if (response.statusCode == 200) {
                          //           final jsonResponse = json.decode(response.body);
                          //         }
                          //       } catch (e) {
                          //         print('Error: $e');
                          //       }
                          //
                          //     }
                          //     else{
                          //       String payload = '${payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ScheduleS_No']},0';
                          //       String payLoadFinal = jsonEncode({
                          //         "3700": [{"3701": payload},{
                          //           "3702": "${overAllPvd.getUserId()}"
                          //         }]
                          //       });
                          //       widget.manager.publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                          //       try {
                          //         var data = {
                          //           "userId": overAllPvd.getUserId(),
                          //           "controllerId": overAllPvd.controllerId,
                          //           "data": jsonDecode(payLoadFinal),
                          //           "hardware" : jsonDecode(payLoadFinal),
                          //           "messageStatus": "${payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ZoneName']} Skip",
                          //           "createUser": overAllPvd.getUserId()
                          //         };
                          //         final response = await HttpService().postRequest("createUserManualOperationInDashboard", data);
                          //         if (response.statusCode == 200) {
                          //           final jsonResponse = json.decode(response.body);
                          //         }
                          //       } catch (e) {
                          //         print('Error: $e');
                          //       }
                          //     }
                          //     setState(() {
                          //       payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['standaloneLoading'] = true;
                          //       payloadProvider.messageFromHw = '';
                          //     });
                          //     for(var seconds = 0;seconds < 8;seconds++){
                          //       await Future.delayed(Duration(seconds: 1));
                          //       if(payloadProvider.messageFromHw != ''){
                          //         stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware recieved successfully');
                          //         break;
                          //       }
                          //       if(seconds == 7){
                          //         setState(() {
                          //           payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule].remove('standaloneLoading');
                          //         });
                          //       }
                          //     }
                          //   }
                          //
                          //
                          // },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0,4),blurRadius: 4,color: Color(0xffCFCFCF).withOpacity(0.5)
                                  )
                                ]
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            child: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['standaloneLoading'] == null ? Row(
                              children: [
                                Text(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone') ? 'Stop' : 'Skip',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(Icons.skip_next,color: Colors.white,),
                              ],
                            ) : loadingButton(),
                          ),
                        ) : null,
                      )
                  ),
                  if(!payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone - Manual'))
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffA4D39C),
                      ),
                      child: Center(
                        child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: 35,
                              height: 35,
                              child: SvgPicture.asset(
                                'assets/images/mountain.svg',
                              ),
                            ),
                          ),
                          title: Text('${payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ZoneName']}',style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                          subtitle: Text('Flow rate : ${payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ActualFlowRate']} L/H',style: TextStyle(fontWeight: FontWeight.bold,color: primaryColorDark,overflow: TextOverflow.ellipsis),),
                          trailing: !payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone') ? Text('${getPercentage(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['Duration_Qty'],payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['Duration_QtyLeft'])}%',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),) : null,
                        ),
                      ),
                    ),
                  ListTile(
                    title: Text('Reason',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text('  ${programStartStopReason(code: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgramStartStopReason'])}',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                  ),
                  SizedBox(height: 10,),
                  //Todo: cycle
                  if(!payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone'))
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          border: Border(left: BorderSide(width: 10,color: Color(0xff1351F1)))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: SvgPicture.asset(
                                  'assets/images/cycle_leading.svg',
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text('Cycle',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                            ],
                          ),
                          getProgressWidget(title: 'Cycle', total: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['TotalCycle'].toString(), completed: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['CurrentCycle'].toString(), totalColor: Colors.black54, completedColor: Color(0xffFCE69C), totalText: 'Total RTC', completedText: 'Left RTC', column: false, fillColor: Color(0xffFFFAD6), gradient: [Color(0xffFFE8F5),Colors.white]),
                        ],
                      ),
                    ),
                  SizedBox(height: 10,),
                  //Todo: Zone Duration
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border(left: BorderSide(width: 10,color: Color(0xffD3054F)))
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: SvgPicture.asset(
                                'assets/images/zone_leading.svg',
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text('${!payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone') ? 'Zone' : ''} Duration',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('Left',style: TextStyle(color: Color(0xffD3054F)),),
                                if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone - Manual') && payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgType'] == 3)
                                  Text('- - - - - - -',style: TextStyle(color: Color(0xffD3054F),fontSize: 14,fontWeight: FontWeight.bold))
                                else
                                  Text(getLeftValue(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['Duration_QtyLeft']),style: TextStyle(color: Color(0xffD3054F),fontSize: 14,fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Total'),
                                if(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone - Manual') && payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgType'] == 3)
                                  Text('TimeLess',style: TextStyle(color: Color(0xffD3054F),fontSize: 14,fontWeight: FontWeight.bold))
                                else
                                  Text(getLeftValue(payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['Duration_Qty']),style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  //Todo: RTC and Zone Count
                  if(!payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['ProgName'].contains('StandAlone'))
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          border: Border(left: BorderSide(width: 10,color: Color(0xff10E196)))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              getProgressWidget(title: 'RTC', total: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['TotalRtc'].toString(), completed: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['CurrentRtc'].toString(), totalColor: Colors.black54, completedColor: Color(0xffFEB0E3), totalText: 'Total RTC', completedText: 'Left RTC', column: false, fillColor: Color(0xffFDE8FF), gradient: [Color(0xffFFF3BE),Colors.white]),                              SizedBox(height: 8,),
                              Text('RTC',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
                            ],
                          ),
                          Column(
                            children: [
                              getProgressWidget(title: 'Zone Count', total: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['TotalZone'].toString(), completed: payloadProvider.currentSchedule[payloadProvider.selectedCurrentSchedule]['CurrentZone'].toString(), totalColor: Colors.black54, completedColor: Color(0xffFFA090), totalText: 'Total Zone', completedText: 'Left Zone', column: false, fillColor: Color(0xffFFECE9), gradient: [Color(0xffCEFFEB),Colors.white]),
                              SizedBox(height: 8,),
                              Text('Zone Count',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 100,
                  )

                ],
              )
          ),
      ],
    );
  }

  String getLeftValue(value){
    if(value.runtimeType == String){
      // print('if Str : $value');
      return value;
    }else{
      // print('if not str : $value');
      return value.toStringAsFixed(2);
    }
  }

  String getPercentage(total,left){
    if(total.runtimeType == String){
      var totalSec = DataConvert().parseTimeString(total);
      var leftSec = DataConvert().parseTimeString(left);
      var percentage = ((totalSec-leftSec)/totalSec)*100;
      return percentage.toStringAsFixed(2);
    }else{
      var percentage = ((total.toInt() - left.toInt())/total.toInt())*100;
      return percentage.toStringAsFixed(2);
    }
  }

  Widget getProgressWidget(
      {
        String? title,
        String? total,
        String? completed,
        Color? totalColor,
        Color? completedColor,
        String? totalText,
        String? completedText,
        bool? column,
        Color? fillColor,
        List<Color>? gradient
      }){
    int percentValue = 0;
    if(total != '0'){
      percentValue = ((int.parse(completed!)/int.parse(total!))*100).toInt();
    }
    return CircularPercentIndicator(
      radius: 30.0,
      lineWidth: 5.0,
      percent: (percentValue.toDouble()/100),
      center: new Text('${completed}/${total}'),
      progressColor: Colors.green,
    );
    // return  Container(
    //   width: MediaQuery.of(context).size.width / 2.3,
    //   height: 120,
    //   decoration: BoxDecoration(
    //     color: fillColor,
    //     boxShadow: customBoxShadow,
    //     borderRadius: BorderRadius.circular(15),
    //     gradient: LinearGradient(
    //       colors: gradient,
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //     )
    //     // border: Border.all(color: Colors.orange)
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       SizedBox(height: 5,),
    //       Text('$title',style: TextStyle(fontWeight: FontWeight.bold),),
    //       SizedBox(height: 5,),
    //       // AnimatedRadialGauge(
    //       //   duration: Duration(seconds: 1),
    //       //   curve: Curves.elasticOut,
    //       //   radius: 50,
    //       //   value: percentValue.toDouble(),
    //       //   axis: GaugeAxis(
    //       //       min: 0,
    //       //       max: 100,
    //       //       degrees: 180,
    //       //       pointer: GaugePointer.needle(
    //       //         borderRadius: 16,
    //       //         width: 0,
    //       //         height: 0,
    //       //         color: Colors.green,
    //       //       ),
    //       //       progressBar: GaugeProgressBar.basic(
    //       //         color: completedColor,
    //       //       ),
    //       //       segments: [
    //       //         GaugeSegment(
    //       //           from: 0,
    //       //           to: 100,
    //       //           color: totalColor,
    //       //           cornerRadius: Radius.zero,
    //       //         ),
    //       //       ]
    //       //   ),
    //       // ),
    //       SizedBox(
    //         width: 60,
    //         height: 60,
    //         child: CircularPercentIndicator(
    //           radius: 30.0,
    //           lineWidth: 5.0,
    //           percent: (percentValue.toDouble()/100),
    //           center: new Text('${completed}'),
    //           progressColor: Colors.green,
    //         ),
    //       ),
    //       SizedBox(height: 5,),
    //       Row(
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               SizedBox(width: 10,),
    //               Icon(Icons.circle,color: totalColor,size: 15,),
    //               Text(total,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12),)
    //             ],
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               SizedBox(width: 10,),
    //               Icon(Icons.circle,color: completedColor,size: 15,),
    //               Text(completed,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12),)
    //             ],
    //           ),
    //         ],
    //       )
    //
    //     ],
    //   ),
    // );
  }

  Widget getProgressValueRow({required total,required completed}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(total),
        Text('/'),
        Text(completed),
      ],
    );
  }

  Widget getProgressValueColumn({required total,required completed}){
    return Container(
      width: double.infinity,
      height: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(total,style: TextStyle(fontSize: 11),),
          Text('/',style: TextStyle(fontSize: 11),),
          Text(completed,style: TextStyle(fontSize: 11),),
        ],
      ),
    );
  }
}
