import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobile_view/screens/config/constant/pump_in_constant.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widget/HoursMinutesSeconds.dart';
import '../../../widget/drop_down_button.dart';
import 'general_in_constant.dart';



class MainValveConstant extends StatefulWidget {
  const MainValveConstant({super.key});

  @override
  State<MainValveConstant> createState() => _MainValveConstantState();
}

class _MainValveConstantState extends State<MainValveConstant> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      return  Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          dataRowHeight: 40.0,
          headingRowHeight: 40,
          headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
          border: TableBorder.all(color: Colors.grey),
          columns: const [
            DataColumn2(
              label: Text('Name'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('Id'),
            ),
            DataColumn(
              label: Text('Line'),
            ),
            DataColumn(
              label: Text('Mode'),
            ),
            DataColumn(
              label: Text('Delay'),
            ),
          ],
          rows: [
            for(var i = 0;i < constantPvd.mainValveUpdated.length;i++)
              DataRow(cells: [
                DataCell(Text('${constantPvd.mainValveUpdated[i]['name']}')),
                DataCell(Text('${constantPvd.mainValveUpdated[i]['id']}')),
                DataCell(Text('${constantPvd.mainValveUpdated[i]['location']}')),
                DataCell(MyDropDown(initialValue: constantPvd.mainValveUpdated[i]['mode'], itemList: const ['No delay','Open before','Open after'], pvdName: 'mainvalve/mode', index: i)),
                DataCell(mainValveDelay(context,constantPvd,overAllPvd,i)),
              ])
          ],
        ),
      );
    });

  }
}

Widget mainValveDelay(BuildContext context,constantPvd,overAllPvd,index){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.mainValveUpdated[index]['delay']}',
              onPressed: (){
                constantPvd.mainValveFunctionality(['mainvalve/delay',index,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.mainValveUpdated[index]['delay']}',style: const TextStyle(color: Colors.black87),)
  );
}

class MainValveInConst extends StatefulWidget {
  const MainValveInConst({super.key});

  @override
  State<MainValveInConst> createState() => _MainValveInConstState();
}

class _MainValveInConstState extends State<MainValveInConst> {
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
        if(constraints.maxWidth > defaultSize * 5){
          width = defaultSize * 5;
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
                                  for(var i = 0;i < constantPvd.mainValveUpdated.length;i++)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.only(left: 8),
                                      width: defaultSize,
                                      height: 50,
                                      child: Center(
                                          child: Text('${constantPvd.mainValveUpdated[i]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                            getCell(width: 120, title: 'Mode'),
                            getCell(width: 120, title: 'Delay'),
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
                                      for(var i = 0;i < constantPvd.mainValveUpdated.length;i++)
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
                                                    child: getYourWidgetMainValve(context: context, index: i, type: 0, initialValue: constantPvd.mainValveUpdated[i]['id'], route: ''),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMainValve(context: context, index: i, type: 0, initialValue: constantPvd.mainValveUpdated[i]['location'], route: '',),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMainValve(context: context, index: i, type: 2, initialValue: constantPvd.mainValveUpdated[i]['mode'], route: 'mode',list: ['No delay','Open before','Open after']),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50,
                                                    child: getYourWidgetMainValve(context: context, index: i, type: 3, initialValue: constantPvd.mainValveUpdated[i]['delay'], route: 'delay'),
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
Widget getYourWidgetMainValve({
  required BuildContext context,
  required int index,
  required int type,
  required String initialValue,
  required String route,
  List<dynamic>? list
}){
  var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
  var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
  if(type == 2){
    return Center(
      child: MyDropDown(
        initialValue: initialValue,
        itemList: list!,
        onItemSelected: (value){
          if(value != null){
            constantPvd.mainValveFunctionality([route,index, value]);

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
                constantPvd.mainValveFunctionality([route,index, getHmsFormat(overAllPvd)]);
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

