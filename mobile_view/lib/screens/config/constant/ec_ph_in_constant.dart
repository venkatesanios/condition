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



class EcPhInConst extends StatefulWidget {
  const EcPhInConst({super.key});

  @override
  State<EcPhInConst> createState() => _EcPhInConstState();
}

class _EcPhInConstState extends State<EcPhInConst> {
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
        if(constraints.maxWidth > defaultSize * 11){
          width = defaultSize * 11;
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
                      child: const Center(child: Text('Site',style: TextStyle(color: Color(0xff30555A),fontSize: 13),)),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _verticalScroll1,
                        child: Container(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  for(var i = 0;i < constantPvd.ecPhUpdated.length;i++)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.white
                                      ),
                                      padding: const EdgeInsets.only(left: 8),
                                      width: defaultSize,
                                      height: 50.3 * constantPvd.ecPhUpdated[i]['setting'].length,
                                      child: Center(
                                          child: Text('${constantPvd.ecPhUpdated[i]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                            getCell(width: 120, title: 'Select'),
                            getCell(width: 120, title: 'Control \n Cycle'),
                            getCell(width: 120, title: 'Delta'),
                            getCell(width: 120, title: 'Fine Tunning'),
                            getCell(width: 120, title: 'Coarse Tunning'),
                            getCell(width: 120, title: 'Deadband'),
                            getCell(width: 120, title: 'Integ'),
                            getCell(width: 120, title: 'Control Sensor'),
                            getCell(width: 120, title: 'Avg Filt \n Speed'),
                            getCell(width: 120, title: 'Percentage'),
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
                                      for(var i = 0;i < constantPvd.ecPhUpdated.length;i++)
                                          Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                              ),
                                              child: Column(
                                                children: [
                                                  for(var j = 0;j < constantPvd.ecPhUpdated[i]['setting'].length;j++)
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                                margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                                color: Colors.white,
                                                                width: 120,
                                                                height: 50.2,
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 50,
                                                                      height: 50,
                                                                      child: Checkbox(
                                                                        value: constantPvd.ecPhUpdated[i]['setting'][j]['active'],
                                                                        onChanged: (value){
                                                                          constantPvd.ecPhFunctionality(['active',i,j,value]);
                                                                        },
                                                                      ),
                                                                    ),
                                                                    Text(constantPvd.ecPhUpdated[i]['setting'][j]['name'])
                                                                  ],
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 3, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['controlCycle'], route: 'controlCycle'),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 1, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['delta'], route: 'delta',regex: regexForDecimal),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 1, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['fineTunning'], route: 'fineTunning',regex: regexForDecimal),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 1, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['coarseTunning'], route: 'coarseTunning',regex: regexForDecimal),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 1, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['deadBand'], route: 'deadBand',regex: regexForDecimal),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 3, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['integ'], route: 'integ'),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 2, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['senseOrAvg'], route: 'senseOrAvg',list: constantPvd.ecPhUpdated[i]['setting'][j]['sensorList']),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 1, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['avgFilterSpeed'], route: 'avgFilterSpeed'),
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                          color: Colors.white,
                                                          width: 120,
                                                          height: 50.2,
                                                          child: getYourWidgetEcPh(context: context, site: i, index: j, type: 1, initialValue: constantPvd.ecPhUpdated[i]['setting'][j]['percentage'], route: 'percentage',regex: regexForNumbers),
                                                        ),
                                                      ],
                                                    )


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

Widget getYourWidgetEcPh({
  required BuildContext context,
  required int site,
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
            constantPvd.ecPhFunctionality([route,site,index, value]);
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
            constantPvd.ecPhFunctionality([route,site,index, value]);

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
                constantPvd.ecPhFunctionality([route,site,index, getHmsFormat(overAllPvd)]);
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


