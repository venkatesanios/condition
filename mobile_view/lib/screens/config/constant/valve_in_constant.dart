import 'package:flutter/cupertino.dart';
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

class ValveInConst extends StatefulWidget {
  const ValveInConst({super.key});

  @override
  State<ValveInConst> createState() => _ValveInConstState();
}

class _ValveInConstState extends State<ValveInConst> {
  int selectedLine = 0;
  final ScrollController _scrollController = ScrollController();
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;
  dynamic valveHideShow = {
    'valve' : true,
    'id' : true,
    'defaultDosage' : false,
    'nominalFlow' : true,
    'minimumFlow' : false,
    'maximumFlow' : false,
    'fillUpDelay' : false,
    'area' : false,
    'cropFactor' : false,
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
      child: Column(
        children: [
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
                  for(var line = 0;line < constantPvd.valveUpdated.length;line++)
                    Row(
                      children: [
                        InkWell(
                          onTap: (){
                            FocusScope.of(context).unfocus();
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
                            child: Center(child: Text('${constantPvd.valveUpdated[line]['name']}',style: TextStyle(color: line == selectedLine ? Colors.white : Colors.black87,fontSize: 13,fontWeight: FontWeight.w200),)),
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
                var count = 0;
                for(var key in valveHideShow.keys){
                  if(valveHideShow[key]){
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
                              child: const Center(child: Text('Name',style: TextStyle(color: Color(0xff30555A),fontSize: 13),)),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _verticalScroll1,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          for(var i = 0;i < constantPvd.valveUpdated[selectedLine]['valve'].length;i++)
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 1),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              padding: const EdgeInsets.only(left: 8),
                                              width: defaultSize,
                                              height: 50.3,
                                              child: Center(
                                                  child: Text('${constantPvd.valveUpdated[selectedLine]['valve'][i]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                                    if(valveHideShow['id'])
                                    getCell(width: 120, title: 'Id'),
                                    if(valveHideShow['defaultDosage'])
                                    getCell(width: 120, title: 'Default Dosage'),
                                    if(valveHideShow['nominalFlow'])
                                    getCell(width: 120, title: 'Nominal Flow'),
                                    if(valveHideShow['minimumFlow'])
                                    getCell(width: 120, title: 'Minimum Flow'),
                                    if(valveHideShow['maximumFlow'])
                                    getCell(width: 120, title: 'Maximum Flow'),
                                    if(valveHideShow['fillUpDelay'])
                                    getCell(width: 120, title: 'Fill Up Delay'),
                                    if(valveHideShow['area'])
                                    getCell(width: 120, title: 'Area'),
                                    if(valveHideShow['cropFactor'])
                                    getCell(width: 120, title: 'Crop Factor'),
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
                                              for(var i = 0;i < constantPvd.valveUpdated[selectedLine]['valve'].length;i++)
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: const BoxDecoration(
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          if(valveHideShow['id'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 0, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['id'], route: '', line: selectedLine),
                                                          ),
                                                          if(valveHideShow['defaultDosage'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 2, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['defaultDosage'], route: 'defaultDosage',list: ['Time','Quantity'], line: selectedLine),
                                                          ),
                                                          if(valveHideShow['nominalFlow'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 1, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['nominalFlow'], route: 'nominalFlow', line: selectedLine),
                                                          ),
                                                          if(valveHideShow['minimumFlow'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 1, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['minimumFlow'], route: 'minimumFlow', line: selectedLine),
                                                          ),
                                                          if(valveHideShow['maximumFlow'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 1, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['maximumFlow'], route: 'maximumFlow', line: selectedLine),
                                                          ),
                                                          if(valveHideShow['fillUpDelay'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 3, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['fillUpDelay'], route: 'fillUpDelay', line: selectedLine),
                                                          ),
                                                          if(valveHideShow['area'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 1, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['area'], route: 'area', line: selectedLine,regex: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),]),
                                                          ),
                                                          if(valveHideShow['cropFactor'])
                                                            Container(
                                                            margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                            color: Colors.white,
                                                            width: 120,
                                                            height: 50,
                                                            child: getYourWidgetValve(context: context, index: i, type: 1, initialValue: constantPvd.valveUpdated[selectedLine]['valve'][i]['cropFactor'], route: 'cropFactor', line: selectedLine),
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
Widget getYourWidgetValve({
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
  print('line : $line');
  print('index : $index');
  if(type == 1){
    return SizedBox(
        width: 50,
        height: 40,
        child: TextFieldForConstant(
          initialValue: initialValue,
          inputFormatters: regex ?? regexForNumbers,
          onChanged: (value){
            constantPvd.valveFunctionality([route,line,index, value]);
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
            constantPvd.valveFunctionality([route,line,index, value]);

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
                constantPvd.valveFunctionality([route,line,index, getHmsFormat(overAllPvd)]);
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


