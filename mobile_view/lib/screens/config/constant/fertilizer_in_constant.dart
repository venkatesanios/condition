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

class FertilizerInConst extends StatefulWidget {
  const FertilizerInConst({super.key});

  @override
  State<FertilizerInConst> createState() => _FertilizerInConstState();
}

class _FertilizerInConstState extends State<FertilizerInConst> {
  final ScrollController _scrollController = ScrollController();
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;
  dynamic fertilizerHideShow = {
    'fertilizerSite' : true,
    'location' : true,
    'noFlowBehavior' : false,
    'minimalOnTime' : true,
    'minimalOffTime' : true,
    'waterFlowStabilityTime' : false,
    'boosterOffDelay' : true,
    'agitator' : true,
    'selector' : true,
    'name' : true,
    'ratio' : true,
    'shortestPulse' : true,
    'nominalFlow' : true,
    'injectorMode' : true,
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
        for(var key in fertilizerHideShow.keys){
          if(fertilizerHideShow[key]){
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
                                  for(var i = 0;i < constantPvd.fertilizerUpdated.length;i++)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.only(left: 8),
                                      width: defaultSize,
                                      height: 50.3 * constantPvd.fertilizerUpdated[i]['fertilizer'].length,
                                      child: Center(
                                          child: Text('${constantPvd.fertilizerUpdated[i]['name']}',style: const TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.normal),overflow: TextOverflow.ellipsis,)
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
                             if(fertilizerHideShow['location'])
                              getCell(width: 120, title: 'Used In Lines'),
                             if(fertilizerHideShow['noFlowBehavior'])
                              getCell(width: 120, title: 'No Flow \n Action'),
                             if(fertilizerHideShow['minimalOnTime'])
                              getCell(width: 120, title: 'Minimal On \n Time'),
                             if(fertilizerHideShow['minimalOffTime'])
                              getCell(width: 120, title: 'Minimal Off \n Time'),
                             if(fertilizerHideShow['waterFlowStabilityTime'])
                              getCell(width: 120, title: 'Water Flow \n Stability Time'),
                             if(fertilizerHideShow['boosterOffDelay'])
                              getCell(width: 120, title: 'Booster Off \n Delay'),
                             if(fertilizerHideShow['agitator'])
                              getCell(width: 120, title: 'Agitator'),
                            if(fertilizerHideShow['selector'])
                              getCell(width: 120, title: 'selector'),
                             if(fertilizerHideShow['name'])
                              getCell(width: 120, title: 'Name'),
                             if(fertilizerHideShow['ratio'])
                              getCell(width: 120, title: 'Ratio'),
                             if(fertilizerHideShow['shortestPulse'])
                              getCell(width: 120, title: 'Shortest Pulse'),
                             if(fertilizerHideShow['nominalFlow'])
                              getCell(width: 120, title: 'Nominal Flow'),
                             if(fertilizerHideShow['injectorMode'])
                              getCell(width: 120, title: 'Injector Mode'),
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
                                      for(var i = 0;i < constantPvd.fertilizerUpdated.length;i++)
                                        Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                              ),
                                              child: Row(
                                                children: [
                                                 if(fertilizerHideShow['location'])
                                                  Container(
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    width: 120,
                                                    height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                    child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 0, initialValue: constantPvd.fertilizerUpdated[i]['location'], route: '', site: i),
                                                  ),
                                                 if(fertilizerHideShow['noFlowBehavior'])
                                                  Container(
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    width: 120,
                                                    height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                    child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 2, initialValue: constantPvd.fertilizerUpdated[i]['noFlowBehavior'], route: 'noFlowBehavior', site: i,list: ['Stop Faulty Fertilizer','Stop Fertigation','Stop Irrigation','Inform Only']),
                                                  ),
                                                 if(fertilizerHideShow['minimalOnTime'])
                                                  Container(
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    width: 120,
                                                    height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                    child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 3, initialValue: constantPvd.fertilizerUpdated[i]['minimalOnTime'], route: 'minimalOnTime', site: i,),
                                                  ),
                                                 if(fertilizerHideShow['minimalOffTime'])
                                                  Container(
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    width: 120,
                                                    height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                    child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 3, initialValue: constantPvd.fertilizerUpdated[i]['minimalOffTime'], route: 'minimalOffTime', site: i,),
                                                  ),
                                                 if(fertilizerHideShow['waterFlowStabilityTime'])
                                                  Container(
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    width: 120,
                                                    height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                    child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 3, initialValue: constantPvd.fertilizerUpdated[i]['waterFlowStabilityTime'], route: 'waterFlowStabilityTime', site: i,),
                                                  ),
                                                 if(fertilizerHideShow['boosterOffDelay'])
                                                  Container(
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    width: 120,
                                                    height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                    child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 3, initialValue: constantPvd.fertilizerUpdated[i]['boosterOffDelay'], route: 'boosterOffDelay', site: i,),
                                                  ),
                                                 if(fertilizerHideShow['agitator'])
                                                  Container(
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                    width: 120,
                                                    height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                    child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 2, initialValue: constantPvd.fertilizerUpdated[i]['agitator'], route: 'agitator', site: i,list: constantPvd.APIagitator),
                                                  ),
                                                  if(fertilizerHideShow['selector'])
                                                    Container(
                                                      color: Colors.white,
                                                      margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                      width: 120,
                                                      height: (50.2 * (constantPvd.fertilizerUpdated[i]['fertilizer'].length)).toDouble(),
                                                      child: getYourWidgetFertilizer(context: context, fertilizer: null, type: 2, initialValue: constantPvd.fertilizerUpdated[i]['selector'], route: 'selector', site: i,list: constantPvd.APIselector),
                                                    ),
                                                  Column(
                                                    children: [
                                                      for(var j = 0;j < constantPvd.fertilizerUpdated[i]['fertilizer'].length;j++)
                                                        Row(
                                                          children: [
                                                           if(fertilizerHideShow['name'])
                                                            Container(
                                                              color: Colors.white,
                                                              margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                              width: 120,
                                                              height: 50,
                                                              child: getYourWidgetFertilizer(context: context, fertilizer: j, type: 0, initialValue: constantPvd.fertilizerUpdated[i]['fertilizer'][j]['name'], route: 'fertilizer/agitator', site: i),
                                                            ),
                                                           if(fertilizerHideShow['ratio'])
                                                            Container(
                                                              color: Colors.white,
                                                              margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                              width: 120,
                                                              height: 50,
                                                              child: getYourWidgetFertilizer(context: context, fertilizer: j, type: 1, initialValue: constantPvd.fertilizerUpdated[i]['fertilizer'][j]['ratio'], route: 'fertilizer/ratio', site: i),
                                                            ),
                                                           if(fertilizerHideShow['shortestPulse'])
                                                            Container(
                                                              color: Colors.white,
                                                              margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                              width: 120,
                                                              height: 50,
                                                              child: getYourWidgetFertilizer(context: context, fertilizer: j, type: 1, initialValue: constantPvd.fertilizerUpdated[i]['fertilizer'][j]['shortestPulse'], route: 'fertilizer/shortestPulse', site: i),
                                                            ),
                                                           if(fertilizerHideShow['nominalFlow'])
                                                            Container(
                                                              color: Colors.white,
                                                              margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                              width: 120,
                                                              height: 50,
                                                              child: getYourWidgetFertilizer(context: context, fertilizer: j, type: 1, initialValue: constantPvd.fertilizerUpdated[i]['fertilizer'][j]['nominalFlow'], route: 'fertilizer/nominalFlow', site: i),
                                                            ),
                                                           if(fertilizerHideShow['injectorMode'])
                                                            Container(
                                                              color: Colors.white,
                                                              margin: const EdgeInsets.only(left: 1,right: 1,bottom: 1),
                                                              width: 120,
                                                              height: 50,
                                                              child: getYourWidgetFertilizer(context: context, fertilizer: j, type: 2, initialValue: constantPvd.fertilizerUpdated[i]['fertilizer'][j]['injectorMode'], route: 'fertilizer/injectorMode', site: i,list: ['Concentration','Ec controlled','Ph controlled','Regular']),
                                                            ),
                                                          ],
                                                        )
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

Widget getYourWidgetFertilizer({
  required BuildContext context,
  int? fertilizer,
  required int site,
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
            constantPvd.fertilizerFunctionality([route,site,fertilizer, value]);
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
            constantPvd.fertilizerFunctionality([route,site,fertilizer, value]);

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
                constantPvd.fertilizerFunctionality([route,site,fertilizer, getHmsFormat(overAllPvd)]);
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

