import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state_management/constant_provider.dart';


// class MyDropDown extends StatefulWidget {
//   int index;
//   String initialValue;
//   String pvdName;
//   List<dynamic> itemList;
//
//   MyDropDown({super.key,
//     required this.initialValue,
//     required this.itemList,
//     required this.pvdName,
//     required this.index,
//   });
//
//   @override
//   State<MyDropDown> createState() => _MyDropDownState();
// }
//
// class _MyDropDownState extends State<MyDropDown> {
//   bool isEditing = false;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   void toggleEditing() {
//     setState(() {
//       isEditing = !isEditing;
//
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
//     var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
//     return GestureDetector(
//       onTap: toggleEditing,
//       child: isEditing
//           ? Container(
//         width: double.infinity,
//         child: Center(
//           child: DropdownButton(
//             focusColor: Colors.transparent,
//             // style: ioText,
//             value: widget.initialValue,
//             underline: Container(),
//             items: widget.itemList.map((dynamic items) {
//               return DropdownMenuItem(
//                 onTap: (){
//                   toggleEditing();
//                 },
//                 value: items,
//                 child: Container(
//                     child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
//                 ),
//               );
//             }).toList(),
//             // After selecting the desired option,it will
//             // change button value to selected value
//             onChanged: (dynamic newValue) {
//               if(widget.pvdName == 'editWaterSource_sp'){
//                 configPvd.sourcePumpFunctionality(['editWaterSource_sp',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editRelayCount_sp'){
//                 configPvd.sourcePumpFunctionality(['editRelayCount_sp',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editLevelType_sp'){
//                 configPvd.sourcePumpFunctionality(['editLevelType_sp',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editLevelType_ip'){
//                 configPvd.irrigationPumpFunctionality(['editLevelType_ip',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editRelayCount_ip'){
//                 configPvd.irrigationPumpFunctionality(['editRelayCount_ip',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editCentralDosing'){
//                 configPvd.irrigationLinesFunctionality(['editCentralDosing',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editCentralFiltration'){
//                 configPvd.irrigationLinesFunctionality(['editCentralFiltration',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editIrrigationPump'){
//                 configPvd.irrigationLinesFunctionality(['editIrrigationPump',widget.index,newValue!]);
//               }else if(widget.pvdName == 'constant-general-waterPulse'){
//                 constantPvd.generalFunctionality(widget.index,newValue!);
//               }else if(widget.pvdName == 'line/irrigationPump'){
//                 constantPvd.irrigationLineFunctionality(['line/irrigationPump',widget.index,newValue!]);
//               }else if(widget.pvdName == 'line/lowFlowBehavior'){
//                 constantPvd.irrigationLineFunctionality(['line/lowFlowBehavior',widget.index,newValue!]);
//               }else if(widget.pvdName == 'line/highFlowBehavior'){
//                 constantPvd.irrigationLineFunctionality(['line/highFlowBehavior',widget.index,newValue!]);
//               }else if(widget.pvdName == 'line/leakageLimit'){
//                 constantPvd.irrigationLineFunctionality(['line/leakageLimit',widget.index,newValue!]);
//               }else if(widget.pvdName == 'mainvalve/mode'){
//                 constantPvd.mainValveFunctionality(['mainvalve/mode',widget.index,newValue!]);
//               }else if(widget.pvdName == 'fertilizer/noFlowBehavior'){
//                 constantPvd.fertilizerFunctionality(['fertilizer/noFlowBehavior',widget.index,newValue!]);
//               }else if(widget.pvdName == 'filter/flushing'){
//                 constantPvd.filterFunctionality(['filter/flushing',widget.index,newValue!]);
//               }else if(widget.pvdName == 'analogSensor/type'){
//                 constantPvd.analogSensorFunctionality(['analogSensor/type',widget.index,newValue!]);
//               }else if(widget.pvdName == 'analogSensor/units'){
//                 constantPvd.analogSensorFunctionality(['analogSensor/units',widget.index,newValue!]);
//               }else if(widget.pvdName == 'analogSensor/base'){
//                 constantPvd.analogSensorFunctionality(['analogSensor/base',widget.index,newValue!]);
//               }else if(widget.pvdName == 'moistureSensor/units'){
//                 constantPvd.moistureSensorFunctionality(['moistureSensor/units',widget.index,newValue!]);
//               }else if(widget.pvdName == 'moistureSensor/base'){
//                 constantPvd.moistureSensorFunctionality(['moistureSensor/base',widget.index,newValue!]);
//               }else if(widget.pvdName == 'levelSensor/units'){
//                 constantPvd.levelSensorFunctionality(['levelSensor/units',widget.index,newValue!]);
//               }else if(widget.pvdName == 'levelSensor/base'){
//                 constantPvd.levelSensorFunctionality(['levelSensor/base',widget.index,newValue!]);
//               }else if(widget.pvdName == 'moistureSensor_high_low'){
//                 constantPvd.moistureSensorFunctionality(['moistureSensor_high_low',widget.index,newValue!]);
//               }else if(widget.pvdName == 'levelSensor_high_low'){
//                 constantPvd.levelSensorFunctionality(['levelSensor_high_low',widget.index,newValue!]);
//               }else if(widget.pvdName == 'editDropDownValue'){
//                 constantPvd.editDropDownValue(newValue!);
//               }else{
//                 var forWhat = widget.pvdName.split('/');
//                 if(forWhat[0] == 'm_o_line'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0]== 'valve_defaultDosage'){
//                   constantPvd.valveFunctionality(['valve_defaultDosage',int.parse(forWhat[1]),int.parse(forWhat[2]),newValue!]);
//                 }else if(forWhat[0]== 'ecPhSenseOrAvg'){
//                   constantPvd.ecPhFunctionality(['ecPhSenseOrAvg',int.parse(forWhat[1]),forWhat[2],int.parse(forWhat[3]),newValue!]);
//                 }else if(forWhat[0]== 'fertilizer_injectorMode'){
//                   constantPvd.fertilizerFunctionality(['fertilizer_injectorMode',int.parse(forWhat[1]),forWhat[2],int.parse(forWhat[3]),newValue!]);
//                 }else if(forWhat[0] == 'm_i_line'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_localDosing'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_localDosing'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_localFiltration'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_localFiltration'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_centralDosing'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_centralDosing'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_centralFiltration'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_centralFiltration'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_sourcePump'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_agitator'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_selector'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_sourcePump'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_o_irrigationPump'){
//                   configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_irrigationPump'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_analogSensor'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_temperature'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_soilTemperature'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_rainGauge'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_lux'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_ldr'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_co2'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_windSpeed'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_windDirection'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_leafWetness'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_humidity'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_contact'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'm_i_commonPressureSensor'){
//                   configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
//                 }else if(forWhat[0] == 'alarm_status'){
//                   constantPvd.alarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
//                 }else if(forWhat[0] == 'alarm_reset_irrigation'){
//                   constantPvd.alarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
//                 }else if(forWhat[0] == 'critical_alarm_status'){
//                   constantPvd.criticalAlarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
//                 }else if(forWhat[0] == 'critical_alarm_reset_irrigation'){
//                   constantPvd.criticalAlarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
//                 }else if(forWhat[0] == 'ecPhAvgFiltSpeed'){
//                   constantPvd.ecPhFunctionality([forWhat[0], int.parse(forWhat[1]),forWhat[2], int.parse(forWhat[3]), newValue]);
//                 }
//               }
//             },
//           ),
//         ),
//       )
//           : Container(
//           margin: EdgeInsets.all(2),
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//           ),
//           height: double.infinity,
//           child: Center(child: Text(widget.initialValue,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600,color: myTheme.primaryColor),))
//       ),
//     );
//
//   }
// }


//////////////////////////////////////////////////////////////////



class MyDropDown extends StatefulWidget {
  int? index;
  String initialValue;
  String? pvdName;
  List<dynamic> itemList;
  bool? split;
  dynamic onItemSelected;


  MyDropDown({this.onItemSelected, this.index,required this.initialValue,required this.itemList, this.pvdName,this.split});

  @override
  _MyDropDownState createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  final GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return GestureDetector(
      key: _menuKey,
      onTap: (){
        final RenderBox button = _menuKey.currentContext!.findRenderObject() as RenderBox;
        final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
        final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromPoints(
              position,
              Offset(position.dx + button.size.width, position.dy + button.size.height),
            ),
            Offset.zero & overlay.size,
          ),
          items: widget.itemList.map((item) {
            return PopupMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ).then(widget.onItemSelected ?? (newValue) {
          if(widget.split == true){
            newValue = newValue?.split('\n')[0];
          }
          if (newValue != null) {
            print('value is : ${newValue}');
            if(widget.pvdName == 'line/irrigationPump'){
              constantPvd.irrigationLineFunctionality(['line/irrigationPump',widget.index,newValue!]);
            }else if(widget.pvdName == 'line/lowFlowBehavior'){
              constantPvd.irrigationLineFunctionality(['line/lowFlowBehavior',widget.index,newValue!]);
            }else if(widget.pvdName == 'line/highFlowBehavior'){
              constantPvd.irrigationLineFunctionality(['line/highFlowBehavior',widget.index,newValue!]);
            }else if(widget.pvdName == 'line/leakageLimit'){
              constantPvd.irrigationLineFunctionality(['line/leakageLimit',widget.index,newValue!]);
            }else if(widget.pvdName == 'mainvalve/mode'){
              constantPvd.mainValveFunctionality(['mainvalve/mode',widget.index,newValue!]);
            }else if(widget.pvdName == 'fertilizer/noFlowBehavior'){
              constantPvd.fertilizerFunctionality(['fertilizer/noFlowBehavior',widget.index,newValue!]);
            }else if(widget.pvdName == 'fertilizer/agitator'){
              constantPvd.fertilizerFunctionality(['fertilizer/agitator',widget.index,newValue!]);
            }else if(widget.pvdName == 'filter/flushing'){
              constantPvd.filterFunctionality(['filter/flushing',widget.index,newValue!]);
            }else if(widget.pvdName == 'analogSensor/type'){
              constantPvd.analogSensorFunctionality(['analogSensor/type',widget.index,newValue!]);
            }else if(widget.pvdName == 'analogSensor/units'){
              constantPvd.analogSensorFunctionality(['analogSensor/units',widget.index,newValue!]);
            }else if(widget.pvdName == 'analogSensor/base'){
              constantPvd.analogSensorFunctionality(['analogSensor/base',widget.index,newValue!]);
            }else if(widget.pvdName == 'moistureSensor/units'){
              constantPvd.moistureSensorFunctionality(['moistureSensor/units',widget.index,newValue!]);
            }else if(widget.pvdName == 'moistureSensor/base'){
              constantPvd.moistureSensorFunctionality(['moistureSensor/base',widget.index,newValue!]);
            }else if(widget.pvdName == 'levelSensor/units'){
              constantPvd.levelSensorFunctionality(['levelSensor/units',widget.index,newValue!]);
            }else if(widget.pvdName == 'levelSensor/base'){
              constantPvd.levelSensorFunctionality(['levelSensor/base',widget.index,newValue!]);
            }else if(widget.pvdName == 'moistureSensor_high_low'){
              constantPvd.moistureSensorFunctionality(['moistureSensor_high_low',widget.index,newValue!]);
            }else if(widget.pvdName == 'levelSensor_high_low'){
              constantPvd.levelSensorFunctionality(['levelSensor_high_low',widget.index,newValue!]);
            }else if(widget.pvdName == 'editDropDownValue'){
              constantPvd.editDropDownValue(newValue!);
            }else{
              print('newValue : $newValue');
              var forWhat = widget.pvdName!.split('/');
              if(forWhat[0]== 'valve_defaultDosage'){
                constantPvd.valveFunctionality(['valve_defaultDosage',int.parse(forWhat[1]),int.parse(forWhat[2]),newValue!]);
              }else if(forWhat[0]== 'ecPhSenseOrAvg'){
                constantPvd.ecPhFunctionality(['ecPhSenseOrAvg',int.parse(forWhat[1]),forWhat[2],int.parse(forWhat[3]),newValue!]);
              }else if(forWhat[0]== 'fertilizer_injectorMode'){
                constantPvd.fertilizerFunctionality(['fertilizer_injectorMode',int.parse(forWhat[1]),forWhat[2],int.parse(forWhat[3]),newValue!]);
              }else if(forWhat[0] == 'alarm_status'){
                constantPvd.alarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'alarm_reset_irrigation'){
                constantPvd.alarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'critical_alarm_status'){
                constantPvd.criticalAlarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'critical_alarm_reset_irrigation'){
                constantPvd.criticalAlarmFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'ecPhAvgFiltSpeed'){
                constantPvd.ecPhFunctionality([forWhat[0], int.parse(forWhat[1]),forWhat[2], int.parse(forWhat[3]), newValue]);
              }
            }
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.initialValue,
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
