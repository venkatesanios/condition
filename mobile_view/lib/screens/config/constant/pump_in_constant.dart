import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';
import '../../../state_management/constant_provider.dart';
import '../../../widget/drop_down_button.dart';
import '../../../widget/text_form_field_constant.dart';
import 'general_in_constant.dart';

class PumpInConst extends StatefulWidget {
  const PumpInConst({super.key});

  @override
  State<PumpInConst> createState() => _PumpInConstState();
}

class _PumpInConstState extends State<PumpInConst> {
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;
  dynamic pumpHideShow = {
    'pump' : true,
    'id' : true,
    'range' : true,
    'pumpStation' : true,
    'topTankFeet' : true,
    'sumpTankLow' : true,
    'sumpTankHigh' : true,
    'topTankLow' : true,
    'topTankHigh' : true,
  };

  @override
  void initState() {
    // print('widget.generalColumnData : ${widget.generalColumnData}');
    // print('widget.generalColumn : ${widget.generalColumn}');
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
        for(var key in pumpHideShow.keys){
          if(pumpHideShow[key]){
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
                      height: 40,
                      alignment: Alignment.center,
                      child: const Center(child: Text('Pump',style: TextStyle(color: Color(0xff30555A),fontSize: 13),)),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _verticalScroll1,
                        child: Container(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  for(var i in constantPvd.pumpUpdated)
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white
                                      ),
                                      margin: const EdgeInsets.only(bottom: 1),
                                      padding: const EdgeInsets.only(left: 8),
                                      width: defaultSize,
                                      height: 50.1,
                                      child: Center(
                                          child: Text('${i['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                      height: 40,
                      child: SingleChildScrollView(
                        controller: _horizontalScroll1,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if(pumpHideShow['id'])
                              getCell(width: 120, title: 'Id'),
                            if(pumpHideShow['range'])
                              getCell(width: 120, title: 'Range'),
                            if(pumpHideShow['pumpStation'])
                              getCell(width: 120, title: 'Pump Station'),
                            if(pumpHideShow['topTankFeet'])
                              getCell(width: 120, title: 'Top Tank Feet'),
                            if(pumpHideShow['topTankHigh'])
                              getCell(width: 120, title: 'Top Tank High'),
                            if(pumpHideShow['topTankLow'])
                              getCell(width: 120, title: 'Top Tank Low'),
                            if(pumpHideShow['sumpTankHigh'])
                              getCell(width: 120, title: 'Sump Tank High'),
                            if(pumpHideShow['sumpTankLow'])
                              getCell(width: 120, title: 'Sump Tank Low'),
                            // sumpTankLow
                            // sumpTankHigh
                            // topTankLow
                            // topTankHigh
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
                                      for(var i = 0;i < constantPvd.pumpUpdated.length;i++)                                      Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                              ),
                                              child: Row(
                                                children: [
                                                  if(pumpHideShow['id'])
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                      padding: const EdgeInsets.only(left: 8),
                                                      color: Colors.white,
                                                      width: defaultSize,
                                                      height: 50,
                                                      alignment: Alignment.centerLeft,
                                                      child: Center(child: Text(constantPvd.pumpUpdated[i]['id'],style: const TextStyle(color: Colors.black,fontWeight: FontWeight.normal),)),
                                                    ),
                                                  if(pumpHideShow['range'])
                                                    Container(
                                                    margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                    padding: const EdgeInsets.only(left: 8),
                                                    color: Colors.white,
                                                    width: defaultSize,
                                                    height: 50,
                                                    alignment: Alignment.centerLeft,
                                                    child: Center(
                                                      child: SizedBox(
                                                        width: 50,
                                                        height: 50,
                                                        child: TextFieldForConstant(
                                                          initialValue: constantPvd.pumpUpdated[i]['range'],
                                                          inputFormatters: regexForNumbers,
                                                          onChanged: (value){
                                                            constantPvd.pumpFunctionality(['range',i,value]);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if(pumpHideShow['pumpStation'])
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                      padding: const EdgeInsets.only(left: 8),
                                                      width: defaultSize,
                                                      color: Colors.white,
                                                      height: 50,
                                                      alignment: Alignment.centerLeft,
                                                      child: Center(
                                                        child: Checkbox(value: constantPvd.pumpUpdated[i]['pumpStation'],
                                                            onChanged: (value){
                                                              constantPvd.pumpFunctionality(['pumpStation',i,value]);
                                                            }),
                                                      )
                                                  ),
                                                  if(pumpHideShow['topTankFeet'])
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                      padding: const EdgeInsets.only(left: 8),
                                                      width: defaultSize,
                                                      color: Colors.white,
                                                      height: 50,
                                                      alignment: Alignment.centerLeft,
                                                      child: Center(
                                                        child: SizedBox(
                                                          width: 50,
                                                          height: 50,
                                                          child: TextFieldForConstant(
                                                            initialValue: constantPvd.pumpUpdated[i]['topTankFeet'],
                                                            inputFormatters: regexForNumbers,
                                                            onChanged: (value){
                                                              constantPvd.pumpFunctionality(['topTankFeet',i,value]);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if(pumpHideShow['topTankHigh'])
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                      padding: const EdgeInsets.only(left: 8),
                                                      width: defaultSize,
                                                      color: Colors.white,
                                                      height: 50,
                                                      alignment: Alignment.centerLeft,
                                                      child: Center(
                                                        child:  getFloat(initialValue: constantPvd.pumpUpdated[i]['topTankHigh'], list: getFloatList(constantPvd: constantPvd,initialValue: constantPvd.pumpUpdated[i]['topTankHigh']), constantPvd: constantPvd, route: 'topTankHigh', pump: i)
                                                      ),
                                                    ),
                                                  if(pumpHideShow['topTankLow'])
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                      padding: const EdgeInsets.only(left: 8),
                                                      width: defaultSize,
                                                      color: Colors.white,
                                                      height: 50,
                                                      alignment: Alignment.centerLeft,
                                                      child: Center(
                                                          child: getFloat(initialValue: constantPvd.pumpUpdated[i]['topTankLow'], list: getFloatList(constantPvd: constantPvd,initialValue: constantPvd.pumpUpdated[i]['topTankLow']), constantPvd: constantPvd, route: 'topTankLow', pump: i)
                                                      ),
                                                    ),
                                                  if(pumpHideShow['sumpTankHigh'])
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                      padding: const EdgeInsets.only(left: 8),
                                                      width: defaultSize,
                                                      color: Colors.white,
                                                      height: 50,
                                                      alignment: Alignment.centerLeft,
                                                      child: Center(
                                                          child: getFloat(initialValue: constantPvd.pumpUpdated[i]['sumpTankHigh'], list: getFloatList(constantPvd: constantPvd,initialValue: constantPvd.pumpUpdated[i]['sumpTankHigh']), constantPvd: constantPvd, route: 'sumpTankHigh', pump: i)
                                                      ),
                                                    ),
                                                  if(pumpHideShow['sumpTankLow'])
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                                      padding: const EdgeInsets.only(left: 8),
                                                      width: defaultSize,
                                                      color: Colors.white,
                                                      height: 50,
                                                      alignment: Alignment.centerLeft,
                                                      child: Center(
                                                          child: getFloat(initialValue: constantPvd.pumpUpdated[i]['sumpTankLow'], list: getFloatList(constantPvd: constantPvd,initialValue: constantPvd.pumpUpdated[i]['sumpTankLow']), constantPvd: constantPvd, route: 'sumpTankLow', pump: i)
                                                      ),
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
List<String> getFloatList({
  required ConstantProvider constantPvd,
  required String initialValue,
}){
  List<String> filteredList = ['-',...constantPvd.APItankFloat];
  List<String> heading = ['topTankHigh','topTankLow','sumpTankHigh','sumpTankLow'];
  for(var val in constantPvd.pumpUpdated){
    for(var key in heading){
      if(val[key] != '-'){
        if(initialValue != val[key]){
          if(filteredList.contains(val[key])){
            filteredList.remove(val[key]);
          }
        }
      }
    }


  }
  return filteredList;
}

Widget getCell({required double width,required String title}){
  return SizedBox(
    height: 40,
    width: width,
    child: Center(child: Text(title,style: const TextStyle(color: Color(0xff30555A)),)),
  );
}

Widget getFloat(
{
  required String initialValue,
  required List<String> list,
  required ConstantProvider constantPvd,
  required String route,
  required int pump,
}
    ){
  return MyDropDown(
    initialValue: initialValue,
    itemList: list,
    onItemSelected: (value){
      if(value != null){
        constantPvd.pumpFunctionality([route,pump, value]);
      }
    },
  );
}



