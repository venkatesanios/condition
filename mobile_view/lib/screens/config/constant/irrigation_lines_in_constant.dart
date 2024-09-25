import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobile_view/screens/config/constant/pump_in_constant.dart';
import 'package:provider/provider.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/drop_down_button.dart';
import '../../../widget/text_form_field_constant.dart';
import 'general_in_constant.dart';


class IrrigationLineInConst extends StatefulWidget {
  const IrrigationLineInConst({super.key});

  @override
  State<IrrigationLineInConst> createState() => _IrrigationLineInConstState();
}

class _IrrigationLineInConstState extends State<IrrigationLineInConst> {
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;
  dynamic lineHideShow = {
    'line' : true,
    'id' : true,
    'pump' : false,
    'lowFlowDelay' : true,
    'highFlowDelay' : true,
    'lowFlowBehavior' : true,
    'highFlowBehavior' : true,
    'leakageLimit' : false,
  };

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
        var count = 0;
        for(var key in lineHideShow.keys){
          if(lineHideShow[key]){
            count += 1;
          }
        }
        if(constraints.maxWidth > defaultSize * count){
          width = defaultSize * count;
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
                                  for(var i = 0;i < constantPvd.irrigationLineUpdated.length;i++)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.white
                                      ),
                                      padding: const EdgeInsets.only(left: 8),
                                      width: defaultSize,
                                      height: 50.1,
                                      child: Center(
                                          child: Text('${constantPvd.irrigationLineUpdated[i]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                              if(lineHideShow['id'])
                            getCell(width: 120, title: 'Id'),
                              if(lineHideShow['pump'])
                            getCell(width: 120, title: 'Pump'),
                              if(lineHideShow['lowFlowDelay'])
                            getCell(width: 120, title: 'Low Flow Delay'),
                              if(lineHideShow['highFlowDelay'])
                            getCell(width: 120, title: 'High Flow Delay'),
                              if(lineHideShow['lowFlowBehavior'])
                            getCell(width: 120, title: 'Low Flow Action'),
                              if(lineHideShow['highFlowBehavior'])
                            getCell(width: 120, title: 'High Flow Action'),
                              if(lineHideShow['leakageLimit'])
                            getCell(width: 120, title: 'Leakage Limit'),
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
                                      for(var i = 0;i < constantPvd.irrigationLineUpdated.length;i++)
                                        Row(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                            ),
                                            child: Row(
                                              children: [
                                                if(lineHideShow['id'])
                                                  Container(
                                                  margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                  color: Colors.white,
                                                  width: 120,
                                                  height: 50,
                                                  child: getYourWidgetIrrigationLine(context: context, index: i, type: 0, initialValue: constantPvd.irrigationLineUpdated[i]['id'], route: ''),
                                                ),
                                                if(lineHideShow['pump'])
                                                  Container(
                                                  margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                  color: Colors.white,
                                                  width: 120,
                                                  height: 50,
                                                  child: getYourWidgetIrrigationLine(context: context, index: i, type: 2, initialValue: constantPvd.irrigationLineUpdated[i]['pump'], route: 'pump',list: constantPvd.APIpump),
                                                ),
                                                if(lineHideShow['lowFlowDelay'])
                                                  Container(
                                                  margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                  color: Colors.white,
                                                  width: 120,
                                                  height: 50,
                                                  child: getYourWidgetIrrigationLine(context: context, index: i, type: 3, initialValue: constantPvd.irrigationLineUpdated[i]['lowFlowDelay'], route: 'lowFlowDelay'),
                                                ),
                                                if(lineHideShow['highFlowDelay'])
                                                  Container(
                                                  margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                  color: Colors.white,
                                                  width: 120,
                                                  height: 50,
                                                  child: getYourWidgetIrrigationLine(context: context, index: i, type: 3, initialValue: constantPvd.irrigationLineUpdated[i]['highFlowDelay'], route: 'highFlowDelay'),
                                                ),
                                                if(lineHideShow['lowFlowBehavior'])
                                                  Container(
                                                  margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                  color: Colors.white,
                                                  width: 120,
                                                  height: 50,
                                                  child: getYourWidgetIrrigationLine(context: context, index: i, type: 2, initialValue: constantPvd.irrigationLineUpdated[i]['lowFlowBehavior'], route: 'lowFlowBehavior',list: ['Ignore','Do next','wait']),
                                                ),
                                                if(lineHideShow['highFlowBehavior'])
                                                  Container(
                                                  margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                  color: Colors.white,
                                                  width: 120,
                                                  height: 50,
                                                  child: getYourWidgetIrrigationLine(context: context, index: i, type: 2, initialValue: constantPvd.irrigationLineUpdated[i]['highFlowBehavior'], route: 'highFlowBehavior',list: ['Ignore','Do next','wait']),
                                                ),
                                                if(lineHideShow['leakageLimit'])
                                                  Container(
                                                  margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                  color: Colors.white,
                                                  width: 120,
                                                  height: 50,
                                                  child: getYourWidgetIrrigationLine(context: context, index: i, type: 1, initialValue: constantPvd.irrigationLineUpdated[i]['leakageLimit'], route: 'leakageLimit'),
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

Widget getYourWidgetIrrigationLine({
  required BuildContext context,
  required int index,
  required int type,
  required String initialValue,
  required String route,
  List<dynamic>? list
}){
  var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
  var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
  if(type == 1){
    return SizedBox(
        width: 50,
        height: 40,
        child: TextFieldForConstant(
          initialValue: initialValue,
          inputFormatters: regexForNumbers,
          onChanged: (value){
            constantPvd.irrigationLineFunctionality([route,index, value]);
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
            constantPvd.irrigationLineFunctionality([route,index, value]);

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
                constantPvd.irrigationLineFunctionality([route,index, getHmsFormat(overAllPvd)]);
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

