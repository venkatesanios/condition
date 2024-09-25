import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobile_view/screens/config/constant/pump_in_constant.dart';
import 'package:provider/provider.dart';
import '../../../ListOfFertilizerInSet.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/drop_down_button.dart';
import '../../../widget/text_form_field_constant.dart';
import 'general_in_constant.dart';


class MoistureSensorInConst extends StatefulWidget {
  const MoistureSensorInConst({super.key});

  @override
  State<MoistureSensorInConst> createState() => _MoistureSensorInConstState();
}

class _MoistureSensorInConstState extends State<MoistureSensorInConst> {
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
                                  for(var i = 0;i < constantPvd.moistureSensorUpdated.length;i++)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 1),
                                      decoration: const BoxDecoration(
                                          color: Colors.white
                                      ),
                                      padding: const EdgeInsets.only(left: 8),
                                      width: defaultSize,
                                      height: 50.1,
                                      child: Center(
                                          child: Text('${constantPvd.moistureSensorUpdated[i]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                            getCell(width: 120, title: 'valve'),
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
                                      for(var i = 0;i < constantPvd.moistureSensorUpdated.length;i++)
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
                                                    child: getYourWidgetMoistureSensor(context: context, index: i, type: 0, initialValue: constantPvd.moistureSensorUpdated[i]['id'], route: ''),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMoistureSensor(context: context, index: i, type: 0, initialValue: constantPvd.moistureSensorUpdated[i]['location'], route: ''),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMoistureSensor(context: context, index: i, type: 2, initialValue: constantPvd.moistureSensorUpdated[i]['high/low'], route: 'high/low',list: ['-','primary','secondary']),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMoistureSensor(context: context, index: i, type: 2, initialValue: constantPvd.moistureSensorUpdated[i]['units'], route: 'units',list: ['bar','dS/m']),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMoistureSensor(context: context, index: i, type: 2, initialValue: constantPvd.moistureSensorUpdated[i]['base'], route: 'base',list: ['Current','Voltage']),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMoistureSensor(context: context, index: i, type: 1, initialValue: constantPvd.moistureSensorUpdated[i]['minimum'], route: 'minimum',regex: regexForDecimal),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMoistureSensor(context: context, index: i, type: 1, initialValue: constantPvd.moistureSensorUpdated[i]['maximum'], route: 'maximum',regex: regexForDecimal),
                                                  ),
                                                  InkWell(
                                                    onTap: (){
                                                      sideSheet(constraints, i);
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                      color: Colors.white,
                                                      width: 120,
                                                      height: 50,
                                                      child : Center(
                                                        child: Text('${constantPvd.moistureSensorUpdated[i]['valve']}',overflow: TextOverflow.ellipsis,),
                                                      ),
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
  void sideSheet(constraints,int index,) {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      // barrierColor: const Color(0xff6600),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SizedBox(
                  width: constraints.maxWidth < 600 ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.2,
                  child: SelectingValveForMoistureSensor(index: index),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }

}


Widget getYourWidgetMoistureSensor({
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
            constantPvd.moistureSensorFunctionality([route,index, value]);
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
            constantPvd.moistureSensorFunctionality([route,index, value]);

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
                constantPvd.moistureSensorFunctionality([route,index, getHmsFormat(overAllPvd)]);
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

class SelectingValveForMoistureSensor extends StatefulWidget {
  final int index;
  const SelectingValveForMoistureSensor({super.key, required this.index});

  @override
  State<SelectingValveForMoistureSensor> createState() => _SelectingValveForMoistureSensorState();
}

class _SelectingValveForMoistureSensorState extends State<SelectingValveForMoistureSensor> {
  List<dynamic> valveList = [];
  @override
  void initState() {
    // TODO: implement initState
    var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
    for(var l in constantPvd.valveUpdated){
      if(constantPvd.moistureSensorUpdated[widget.index]['location'] == l['id']){
        for(var v in l['valve']){
          valveList.add({
            'name' : v['name'],
            'id' : v['id'],
            'hid' : v['hid'],
            'isSelect' : constantPvd.moistureSensorUpdated[widget.index]['valve'].contains(v['id']) ? true : false,
          });
        }
      }
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context, listen: true);
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: customBoxShadow
        ),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
              },
              color: Colors.red,
              child: const Text("Cancel",style: TextStyle(color: Colors.white),),
            ),
            MaterialButton(
              onPressed: (){
                var selectedValve = valveList.where((element)=> element['isSelect'] == true)
                    .toList().map((e) => e['id']).toList().join('_');
                constantPvd.moistureSensorFunctionality(['valve',widget.index,selectedValve]);
                Navigator.pop(context);
              },
              color: Theme.of(context).primaryColor,
              child: const Text("OK",style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            for(var valve in valveList)
              ListTile(
                title: Text('${valve['name']}',style: const TextStyle(fontSize: 12),),
                trailing: Checkbox(
                  value: valve['isSelect'],
                  onChanged: (value) {
                    setState(() {
                      valve['isSelect'] = !valve['isSelect'];
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
