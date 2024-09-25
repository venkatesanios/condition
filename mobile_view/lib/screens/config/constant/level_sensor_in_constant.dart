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

class LevelSensorInConst extends StatefulWidget {
  const LevelSensorInConst({super.key});

  @override
  State<LevelSensorInConst> createState() => _LevelSensorInConstState();
}

class _LevelSensorInConstState extends State<LevelSensorInConst> {
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;

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
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        var width = 0.0;
        if(constraints.maxWidth > defaultSize * 9){
          width = defaultSize * 9;
        }else{
          width = constraints.maxWidth;
        }
        return Center(
          child: SizedBox(
            width: width,
            child: Row(
              children: [
                Column(
                  children: [
                    //Todo : first column
                    Container(
                      decoration: const BoxDecoration(
                          color: Color(0xff96CED5),
                      ),
                      padding: const EdgeInsets.only(left: 8),
                      width: defaultSize,
                      height: 50,
                      alignment: Alignment.center,
                      child: const Center(child: Text('Sensor',style: TextStyle(color: Color(0xff30555A),fontSize: 13),)),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _verticalScroll1,
                        child: Container(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  for(var i = 0;i < constantPvd.levelSensorUpdated.length;i++)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.white
                                      ),
                                      padding: const EdgeInsets.only(left: 8),
                                      width: defaultSize,
                                      height: 50.1,
                                      child: Center(
                                          child: Text('${constantPvd.levelSensorUpdated[i]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                        color: Color(0xffD3EBEE),
                      ),
                      width: width - 120,
                      height: 50,
                      child: SingleChildScrollView(
                        controller: _horizontalScroll1,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            getCell(width: 120, title: 'Id'),
                            getCell(width: 120, title: 'Line'),
                            getCell(width: 120, title: 'High Low'),
                            getCell(width: 120, title: 'Units'),
                            getCell(width: 120, title: 'Base'),
                            getCell(width: 120, title: 'Minimum'),
                            getCell(width: 120, title: 'Maximum'),
                            getCell(width: 120, title: 'Height'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: width-120,
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
                                      for(var i = 0;i < constantPvd.levelSensorUpdated.length;i++)
                                        Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 0, initialValue: constantPvd.levelSensorUpdated[i]['id'], route: ''),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 0, initialValue: constantPvd.levelSensorUpdated[i]['location'], route: ''),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 2, initialValue: constantPvd.levelSensorUpdated[i]['high/low'], route: 'high/low',list: ['-','primary','secondary']),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 2, initialValue: constantPvd.levelSensorUpdated[i]['units'], route: 'units',list: ['bar','dS/m']),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 2, initialValue: constantPvd.levelSensorUpdated[i]['base'], route: 'base',list: ['Current','Voltage']),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 1, initialValue: constantPvd.levelSensorUpdated[i]['minimum'], route: 'minimum',regex: regexForDecimal),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 1, initialValue: constantPvd.levelSensorUpdated[i]['maximum'], route: 'maximum',regex: regexForDecimal),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetLevelSensor(context: context, index: i, type: 1, initialValue: constantPvd.levelSensorUpdated[i]['height'], route: 'height',regex: regexForDecimal),
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
    );
  }
}


Widget getYourWidgetLevelSensor({
  required BuildContext context,
  required int index,
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
            constantPvd.levelSensorFunctionality([route,index, value]);
          },
        )
    );
  }else if(type == 2){
    return Center(
      child: MyDropDown(
        initialValue: initialValue,
        itemList: list!,
        onItemSelected: (value){
          if(value != null){
            constantPvd.levelSensorFunctionality([route,index, value]);

          }
        },
      ),
    );
  }else if(type == 3){
    return InkWell(
        onTap: (){
          alertBoxForTimer(
              context: context,
              initialTime: initialValue,
              onTap: (){
                constantPvd.levelSensorFunctionality([route,index, getHmsFormat(overAllPvd)]);
                Navigator.pop(context);
              }
          );
        },
        child: SizedBox(
          width: 100,
          height: 40,
          child: Center(child: Text(initialValue)),
        )
    );
  }else{
    return Center(child: Text(initialValue));
  }

}