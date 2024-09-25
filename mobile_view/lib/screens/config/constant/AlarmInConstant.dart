import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobile_view/screens/config/constant/pump_in_constant.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/drop_down_button.dart';
import '../../../widget/text_form_field_constant.dart';
import 'general_in_constant.dart';


class NormalAlarmInConst extends StatefulWidget {
  const NormalAlarmInConst({super.key});

  @override
  State<NormalAlarmInConst> createState() => _NormalAlarmInConstState();
}

class _NormalAlarmInConstState extends State<NormalAlarmInConst> {
  final ScrollController _scrollController = ScrollController();
  int selectedLine = 0;
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 140;

  @override
  void initState() {
    _scrollable1 = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollable1.addAndGet();
    _verticalScroll2 = _scrollable1.addAndGet();
    _scrollable2 = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollable2.addAndGet();
    _horizontalScroll2 = _scrollable2.addAndGet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Container(
      color: const Color(0xfff3f3f3),
      child: Column(
        children:[
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xffE6EDF5),
                borderRadius: BorderRadius.circular(20)
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for(var line = 0;line < constantPvd.alarmUpdated.length;line++)
                    Row(
                      children: [
                        InkWell(
                          onTap: (){
                            setState(() {
                              selectedLine = line;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: line == selectedLine ? const Color(0xff1A7886) : null
                            ),
                            child: Center(child: Text('${constantPvd.alarmUpdated[line]['name']}',style: TextStyle(color: line == selectedLine ? Colors.white : Colors.black87,fontSize: 13,fontWeight: FontWeight.w200),)),
                          ),
                        ),
                        const SizedBox(width: 20,)
                      ],
                    )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                var width = 0.0;
                if(constraints.maxWidth > defaultSize * 8){
                  width = defaultSize * 8;
                }else{
                  width = constraints.maxWidth;
                }
                return Center(
                  child: Container(
                    decoration: const BoxDecoration(
                    ),
                    width: width,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            //Todo : first column
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xff96CED5),
                                // borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
                              ),
                              padding: const EdgeInsets.only(left: 8),
                              width: defaultSize,
                              height: 50,
                              alignment: Alignment.center,
                              child: const Center(child: Text('Line',style: TextStyle(color: Color(0xff30555A),fontSize: 13),)),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _verticalScroll1,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              // border: Border(bottom: BorderSide(width: 0.3))
                                            ),
                                            padding: const EdgeInsets.only(left: 8),
                                            width: defaultSize,
                                            height: (52 * 10).toDouble(),
                                            child: Center(
                                                child: Text('${constantPvd.alarmUpdated[selectedLine]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                // borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                                color: Color(0xffD3EBEE),
                              ),
                              width: width - 140,
                              height: 50,
                              child: SingleChildScrollView(
                                controller: _horizontalScroll1,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    getCell(width: 140, title: 'Alarm Type \n Lines'),
                                    getCell(width: 140, title: 'Scan Time'),
                                    getCell(width: 140, title: 'Alarm On \n Status'),
                                    getCell(width: 140, title: 'Reset After \n Irrigation'),
                                    getCell(width: 140, title: 'Auto Reset \n Duration'),
                                    getCell(width: 140, title: 'Threshold'),
                                    getCell(width: 140, title: 'Units'),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: width-140,
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  controller: _horizontalScroll2,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _horizontalScroll2,
                                    child: Container(
                                      child: Scrollbar(
                                        thumbVisibility: true,
                                        controller: _verticalScroll2,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          controller: _verticalScroll2,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: const BoxDecoration(
                                                      // border: Border(bottom: BorderSide(width: 0.3))
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        for(var j = 0;j < constantPvd.alarmUpdated[selectedLine]['alarm'].length;j++)
                                                          if(!['WRONG FEEDBACK','NO COMMUNICATION','NO POWER SUPPLY','NO FLOW','SUMP EMPTY','TANK FULL','PRESSURE SWITCH HIGH'].contains(constantPvd.alarmUpdated[selectedLine]['alarm'][j]['name']))
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  color: Colors.white,
                                                                  margin: const EdgeInsets.all(1),
                                                                  width: 140,
                                                                  height:50,
                                                                  child: getYourWidgetCriticalAlarm(context: context, type: 0, initialValue: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['name'], route: '', line: selectedLine, index: j),
                                                                ),
                                                                Container(
                                                                  color: Colors.white,
                                                                  margin: const EdgeInsets.all(1),
                                                                  width: 140,
                                                                  height:50,
                                                                  child: getYourWidgetCriticalAlarm(context: context,  type: 3, initialValue: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['scanTime'], route: 'scanTime', line: selectedLine, index: j),
                                                                ),
                                                                Container(
                                                                  color: Colors.white,
                                                                  margin: const EdgeInsets.all(1),
                                                                  width: 140,
                                                                  height:50,
                                                                  child: getYourWidgetCriticalAlarm(context: context, type: 2, initialValue: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['alarmOnStatus'], route: 'alarmOnStatus', line: selectedLine,list: ['Do Nothing','Stop Irrigation','Stop Fertigation','Skip Irrigation'], index: j),
                                                                ),
                                                                Container(
                                                                  color: Colors.white,
                                                                  margin: const EdgeInsets.all(1),
                                                                  width: 140,
                                                                  height:50,
                                                                  child: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['alarmOnStatus'] == 'Stop Irrigation'
                                                                      ? const Center(
                                                                      child: Text('N/A')
                                                                  )
                                                                      : constantPvd.alarmUpdated[selectedLine]['alarm'][j]['alarmOnStatus'] == 'Skip Irrigation' ? const Center(
                                                                    child: Text('Yes'),
                                                                  )
                                                                      : getYourWidgetCriticalAlarm(context: context, type: 2, initialValue: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['resetAfterIrrigation'], route: 'resetAfterIrrigation', line: selectedLine,list: ['Yes','No'], index: j),
                                                                ),
                                                                Container(
                                                                  color: Colors.white,
                                                                  margin: const EdgeInsets.all(1),
                                                                  width: 140,
                                                                  height:50,
                                                                  child: getYourWidgetCriticalAlarm(context: context, type: 3, initialValue: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['autoResetDuration'], route: 'autoResetDuration', line: selectedLine, index: j),
                                                                ),
                                                                Container(
                                                                  color: Colors.white,
                                                                  margin: const EdgeInsets.all(1),
                                                                  width: 140,
                                                                  height:50,
                                                                  child: ['NO FLOW','NO POWER SUPPLY'].contains(constantPvd.alarmUpdated[selectedLine]['alarm'][j]['name'])
                                                                      ?  const Center(child: Text('N/A'),)
                                                                      : getYourWidgetCriticalAlarm(context: context, type: 1, initialValue: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['threshold'], route: 'threshold', line: selectedLine, index: j,regex: regexForDecimal),
                                                                ),
                                                                Container(
                                                                  color: Colors.white,
                                                                  margin: const EdgeInsets.all(1),
                                                                  width: 140,
                                                                  height:50,
                                                                  child: getYourWidgetCriticalAlarm(context: context, type: 0, initialValue: constantPvd.alarmUpdated[selectedLine]['alarm'][j]['unit'], route: 'unit', line: selectedLine, index: j),
                                                                ),
                                                              ],
                                                            ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

Widget getYourWidgetCriticalAlarm({
  required BuildContext context,
  required int index,
  required int line,
  required int type,
  required String initialValue,
  required String route,
  List<dynamic>? list,
  List<TextInputFormatter>? regex,
}){
  var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
  var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
  if(type == 1){
    return SizedBox(
        width: 50,
        height: 40,
        child: TextFieldForConstant(
          initialValue: initialValue,
          inputFormatters: regex ?? regexForNumbers,
          onChanged: (value){
            constantPvd.alarmFunctionality([route,line,index, value]);
          },
        )
    );
  }else if(type == 2){
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xffF0F2F5)
        ),
        child: MyDropDown(
          initialValue: initialValue,
          itemList: list!,
          onItemSelected: (value){
            if(value != null){
              constantPvd.alarmFunctionality([route,line,index, value]);

            }
          },
        ),
      ),
    );
  }else if(type == 3){
    return InkWell(
        onTap: (){
          alertBoxForTimer(
              context: context,
              initialTime: initialValue,
              onTap: (){
                constantPvd.alarmFunctionality([route,line,index, getHmsFormat(overAllPvd)]);
                Navigator.pop(context);
              }
          );
        },
        child: Center(child: Text(initialValue))
    );
  }else{
    return Center(child: Text(initialValue,style: const TextStyle(fontSize: 11),));
  }

}