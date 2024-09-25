import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mobile_view/widget/HoursMinutesSeconds.dart';
import 'package:mobile_view/widget/TextFieldForGlobalFert.dart';
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/GlobalFertLimitProvider.dart';
import '../../state_management/overall_use.dart';

class GlobalFertilizerLimit extends StatefulWidget {
  const GlobalFertilizerLimit({super.key, required this.userId, required this.customerId, required this.controllerId, required this.deviceId});
  final int userId, controllerId, customerId;
  final String deviceId;

  @override
  State<GlobalFertilizerLimit> createState() => _GlobalFertilizerLimitState();
}

class _GlobalFertilizerLimitState extends State<GlobalFertilizerLimit> {
  int selectedLine = 0;
  ScrollController _scrollController = ScrollController();
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollable1 = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollable1.addAndGet();
    _verticalScroll2 = _scrollable1.addAndGet();
    _scrollable2 = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollable2.addAndGet();
    _horizontalScroll2 = _scrollable2.addAndGet();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getUserPlanningGlobalFertilizerLimit();
      });
    }
  }
  Future<void> getUserPlanningGlobalFertilizerLimit() async {
    var gfertpvd = Provider.of<GlobalFertLimitProvider>(context, listen: false);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserPlanningGlobalFertilizerLimit', {'userId' : overAllPvd.userId,'controllerId' : overAllPvd.controllerId});
      var jsonData = jsonDecode(response.body);
      print('jsonData : $jsonData');
      gfertpvd.editGlobalFert(jsonData['data']);
    }catch(e){
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    var gfertpvd = Provider.of<GlobalFertLimitProvider>(context, listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Global Limit'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          showDialog(context: context, builder: (context){
            return Consumer<GlobalFertLimitProvider>(builder: (context,fertSetPvd,child){
              return AlertDialog(
                title: Text(fertSetPvd.wantToSendData == 0 ? 'Send to server' : fertSetPvd.wantToSendData == 1 ?  'Sending.....' : fertSetPvd.wantToSendData == 2 ? 'Success...' : 'Oopss!!!',style: TextStyle(color: fertSetPvd.wantToSendData == 3 ? Colors.red : Colors.green),),
                content: fertSetPvd.wantToSendData == 0 ? Text('Are you sure want to send data ? ') : SizedBox(
                  width: 200,
                  height: 200,
                  child: fertSetPvd.wantToSendData == 2 ? Image.asset(fertSetPvd.wantToSendData == 3 ? 'assets/images/serverError.png' : 'assets/images/success.png') :LoadingIndicator(
                    indicatorType: Indicator.pacman,
                  ),
                ),
                actions: [
                  if(fertSetPvd.wantToSendData == 0)
                    InkWell(
                      onTap: ()async{
                        fertSetPvd.hwPayload();
                        fertSetPvd.editWantToSendData(1);
                        try{
                          var body = {
                            "userId" : overAllPvd.userId,
                            "createUser" : overAllPvd.userId,
                            "controllerId" : overAllPvd.controllerId,
                            'globalFertilizerLimit' : gfertpvd.globalFert
                          };
                          HttpService service = HttpService();
                          var response = await service.postRequest('createUserPlanningGlobalFertilizerLimit', body);
                          var jsonData = jsonDecode(response.body);
                          if(jsonData['code'] == 200){
                            Future.delayed(Duration(seconds: 1), () {
                              fertSetPvd.editWantToSendData(2);
                            });
                          }else{
                            fertSetPvd.editWantToSendData(3);
                          }
                          print('jsonData : ${jsonData['code']}');
                          MQTTManager().publish(jsonEncode(gfertpvd.hwPayload()),'AppToFirmware/${overAllPvd.imeiNo}');
                        }catch(e){
                          print(e.toString());
                        }
                        // store.writeDataInJsonFile('configFile', fertSetPvd.sendData());
                      },
                      child: Container(
                        child: Center(
                          child: Text('Yes',style: TextStyle(color: Colors.white,fontSize: 16),
                          ),
                        ),
                        width: 80,
                        height: 30,
                        color: myTheme.primaryColor,
                      ),
                    ),
                  if([2,3].contains(fertSetPvd.wantToSendData))
                    InkWell(
                      onTap: (){
                        fertSetPvd.editWantToSendData(0);
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Center(
                          child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
                          ),
                        ),
                        width: 80,
                        height: 30,
                        color: myTheme.primaryColor,
                      ),
                    )
                ],
              );
            });
          });
        },
        child: Icon(Icons.send),

      ),
      body: LayoutBuilder(builder: (context,constraints){
        print('check : ${MediaQuery.of(context).viewInsets.bottom}');
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(8),
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: Color(0xffE6EDF5),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(var line = 0;line < gfertpvd.globalFert.length;line++)
                        Row(
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {
                                  selectedLine = line;
                                });
                                print('selectedLine => $selectedLine');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: line != null ? (line == selectedLine ? Color(0xff1A7886) : null) : Color(0xff1A7886)
                                ),
                                child: Center(child: Text('${gfertpvd.globalFert[line]['name']}',style: TextStyle(color: line == selectedLine ? Colors.white : Colors.black87,fontSize: 13,fontWeight: FontWeight.w200),)),
                              ),
                            ),
                            const SizedBox(width: 20,)
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
            if(gfertpvd.globalFert.length != 0)
              SliverToBoxAdapter(
                  child: Container(
                    height: (constraints.maxHeight - 50) > (50 + gfertpvd.globalFert[selectedLine]['valve'].length * 45) ? (50 + gfertpvd.globalFert[selectedLine]['valve'].length * 45).toDouble() : (constraints.maxHeight - 50),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20))
                    ),
                    margin: const EdgeInsets.only(left: 10,right: 10),
                    child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      var width = constraints.maxWidth;
                      return Row(
                        children: [
                          Column(
                            children: [
                              //Todo : first column
                              Container(
                                // color: Color(0xffF7F9FA),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xff1C7C8A),
                                        Color(0xff03464F),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )
                                ),
                                padding: const EdgeInsets.only(left: 8),
                                width: 100,
                                height: 50,
                                alignment: Alignment.center,
                                child: Text('Valve',style: TextStyle(color: Colors.white),),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _verticalScroll1,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            for(var index = 0;index < gfertpvd.globalFert[selectedLine]['valve'].length; index++)
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffDCF3DD),
                                                      border: Border(bottom: BorderSide(width: 0.5)),
                                                    ),
                                                    width: 100,
                                                    height: 40.5,
                                                    child: Center(
                                                      child: Text('${gfertpvd.globalFert[selectedLine]['valve'][index]['name']}',style: TextStyle(color: Colors.black),),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 0,
                                                    height: 40,
                                                    child: CustomPaint(
                                                      painter: VerticalDotBorder(borderColor: Colors.black),
                                                      size: Size(0,40),
                                                    ),
                                                  ),
                                                ],
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
                                // color: Color(0xffF7F9FA),
                                color: Color(0xff03464F),
                                width: width-100,
                                height: 50,
                                child: SingleChildScrollView(
                                  controller: _horizontalScroll1,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 0,
                                        height: 50,
                                        child: CustomPaint(
                                          painter: VerticalDotBorder(borderColor: Colors.black),
                                          size: Size(0,50),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Center(
                                            child: Text('Water',style: TextStyle(color: Colors.white),),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                // color: Color(0xffEAEAEA),
                                                color: Colors.orange.shade200,
                                                padding: const EdgeInsets.only(left: 8),
                                                width: 100,
                                                height: 25,
                                                alignment: Alignment.center,
                                                child: Text('Quantity',style: TextStyle(color: Colors.black),),
                                              ),
                                              // Container(
                                              //   // color: Color(0xffEAEAEA),
                                              //   color: Colors.orange.shade200,
                                              //   padding: const EdgeInsets.only(left: 8),
                                              //   width: 100,
                                              //   height: 25,
                                              //   alignment: Alignment.center,
                                              //   child: Text('Time',style: TextStyle(color: Colors.black),),
                                              // ),

                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 0,
                                        height: 50,
                                        child: CustomPaint(
                                          painter: VerticalDotBorder(borderColor: Colors.black),
                                          size: Size(0,50),
                                        ),
                                      ),
                                      if(gfertpvd.central > 1)
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Center(
                                              child: Text('<C - Channels>',style: TextStyle(color: Colors.white),),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if(gfertpvd.central >= 1)
                                                  returnChannel('CH1',Colors.blueGrey.shade200),
                                                if(gfertpvd.central >= 2)
                                                  returnChannel('CH2',Colors.blueGrey.shade200),
                                                if(gfertpvd.central >= 3)
                                                  returnChannel('CH3',Colors.blueGrey.shade200),
                                                if(gfertpvd.central >= 4)
                                                  returnChannel('CH4',Colors.blueGrey.shade200),
                                                if(gfertpvd.central >= 5)
                                                  returnChannel('CH5',Colors.blueGrey.shade200),
                                                if(gfertpvd.central >= 6)
                                                  returnChannel('CH6',Colors.blueGrey.shade200),
                                                if(gfertpvd.central >= 7)
                                                  returnChannel('CH7',Colors.blueGrey.shade200),
                                                if(gfertpvd.central >= 8)
                                                  returnChannel('CH8',Colors.blueGrey.shade200,false),
                                              ],
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        width: 0,
                                        height: 50,
                                        child: CustomPaint(
                                          painter: VerticalDotBorder(borderColor: Colors.black),
                                          size: Size(0,50),
                                        ),
                                      ),
                                      if(gfertpvd.local > 1)
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Center(
                                              child: Text('<L - Channels>',style: TextStyle(color: Colors.white),),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if(gfertpvd.local >= 1)
                                                  returnChannel('CH1',Colors.orange.shade200),
                                                if(gfertpvd.local >= 2)
                                                  returnChannel('CH2',Colors.orange.shade200),
                                                if(gfertpvd.local >= 3)
                                                  returnChannel('CH3',Colors.orange.shade200),
                                                if(gfertpvd.local >= 4)
                                                  returnChannel('CH4',Colors.orange.shade200),
                                                if(gfertpvd.local >= 5)
                                                  returnChannel('CH5',Colors.orange.shade200),
                                                if(gfertpvd.local >= 6)
                                                  returnChannel('CH6',Colors.orange.shade200),
                                                if(gfertpvd.local >= 7)
                                                  returnChannel('CH7',Colors.orange.shade200),
                                                if(gfertpvd.local >= 8)
                                                  returnChannel('CH8',Colors.orange.shade200,false),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: width-100,
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
                                              child:  Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  for(var index = 0;index < gfertpvd.globalFert[selectedLine]['valve'].length; index++)
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(bottom: BorderSide(width: 0.5)),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                width: 100,
                                                                height: 40,
                                                                child: TextFieldForGlobalFert(purpose: 'quantity/$selectedLine/$index/quantity', initialValue: '${gfertpvd.globalFert[selectedLine]['valve'][index]['quantity']}', index: index),
                                                                alignment: Alignment.center,
                                                              ),
                                                              // Container(
                                                              //   width: 100,
                                                              //   height: 40,
                                                              //   child: waterTime(context, overAllPvd, gfertpvd, index),
                                                              //   alignment: Alignment.center,
                                                              // ),
                                                              SizedBox(
                                                                width: 0,
                                                                height: 40,
                                                                child: CustomPaint(
                                                                  painter: VerticalDotBorder(borderColor: Colors.black),
                                                                  size: Size(0,40),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              if(gfertpvd.central >= 1)
                                                                getDosingRow(gfertpvd, index, 'central1'),
                                                              if(gfertpvd.central >= 2)
                                                                getDosingRow(gfertpvd, index, 'central2'),
                                                              if(gfertpvd.central >= 3)
                                                                getDosingRow(gfertpvd, index, 'central3'),
                                                              if(gfertpvd.central >= 4)
                                                                getDosingRow(gfertpvd, index, 'central4'),
                                                              if(gfertpvd.central >= 5)
                                                                getDosingRow(gfertpvd, index, 'central5'),
                                                              if(gfertpvd.central >= 6)
                                                                getDosingRow(gfertpvd, index, 'central6'),
                                                              if(gfertpvd.central >= 7)
                                                                getDosingRow(gfertpvd, index, 'central7'),
                                                              if(gfertpvd.central >= 8)
                                                                getDosingRow(gfertpvd, index, 'central8'),
                                                              SizedBox(
                                                                width: 0,
                                                                height: 40,
                                                                child: CustomPaint(
                                                                  painter: VerticalDotBorder(borderColor: Colors.black),
                                                                  size: Size(0,40),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              if(gfertpvd.local >= 1)
                                                                getDosingRow(gfertpvd, index, 'local1'),
                                                              if(gfertpvd.local >= 2)
                                                                getDosingRow(gfertpvd, index, 'local2'),
                                                              if(gfertpvd.local >= 3)
                                                                getDosingRow(gfertpvd, index, 'local3'),
                                                              if(gfertpvd.local >= 4)
                                                                getDosingRow(gfertpvd, index, 'local4'),
                                                              if(gfertpvd.local >= 5)
                                                                getDosingRow(gfertpvd, index, 'local5'),
                                                              if(gfertpvd.local >= 6)
                                                                getDosingRow(gfertpvd, index, 'local6'),
                                                              if(gfertpvd.local >= 7)
                                                                getDosingRow(gfertpvd, index, 'local7'),
                                                              if(gfertpvd.local >= 8)
                                                                getDosingRow(gfertpvd, index, 'local8'),
                                                              SizedBox(
                                                                width: 0,
                                                                height: 40,
                                                                child: CustomPaint(
                                                                  painter: VerticalDotBorder(borderColor: Colors.black),
                                                                  size: Size(0,40),
                                                                ),
                                                              ),

                                                            ],
                                                          ),

                                                          // Container(
                                                          //   height: 60,
                                                          //   width: gfertpvd.local * 62.5 + (gfertpvd.local == 1 || gfertpvd.local == 2 ? 100 : 0),
                                                          //   child: Center(
                                                          //     child: Row(
                                                          //       mainAxisAlignment: MainAxisAlignment.center,
                                                          //       children: [
                                                          //         if(gfertpvd.local >= 1)
                                                          //           getDosingRow(gfertpvd, index, 'local1'),
                                                          //         if(gfertpvd.local >= 2)
                                                          //           getDosingRow(gfertpvd, index, 'local2'),
                                                          //         if(gfertpvd.local >= 3)
                                                          //           getDosingRow(gfertpvd, index, 'local3'),
                                                          //         if(gfertpvd.local >= 4)
                                                          //           getDosingRow(gfertpvd, index, 'local4'),
                                                          //         if(gfertpvd.local >= 5)
                                                          //           getDosingRow(gfertpvd, index, 'local5'),
                                                          //         if(gfertpvd.local >= 6)
                                                          //           getDosingRow(gfertpvd, index, 'local6'),
                                                          //         if(gfertpvd.local >= 7)
                                                          //           getDosingRow(gfertpvd, index, 'local7'),
                                                          //         if(gfertpvd.local >= 8)
                                                          //           getDosingRow(gfertpvd, index, 'local8'),
                                                          //       ],
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),

                                                ],
                                              )
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
                      );
                    },),
                  )
              )
          ],
        );
      }),
    );
  }
  Widget returnChannel(String title,Color color,[bool? lastone]){
    return Container(
      color: Colors.orange.shade200,
      padding: const EdgeInsets.only(left: 8),
      width: 100,
      height: 25,
      alignment: Alignment.center,
      child: Text(title,style: TextStyle(color: Colors.black),),
    );
  }
  Widget getColumn({required double width,required String title}){
    return Container(
      width: width,
      height: 60,
      child: Center(child: Text(title,style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),)),
    );
  }
  Widget waterTime(BuildContext context,overAllPvd,GlobalFertLimitProvider gfertpvd,int valveIndex){
    return TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent)
        ),
        onPressed: ()async{
          showDialog(context: context, builder: (context){
            return AlertDialog(
              content: SizedBox(
                width: 300,
                child: HoursMinutesSeconds(
                  initialTime: '${gfertpvd.globalFert[selectedLine]['valve'][valveIndex]['time']}',
                  onPressed: (){
                    gfertpvd.editGfert('time',selectedLine,valveIndex,'time','${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}');
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          });
        },
        child: Text('${gfertpvd.globalFert[selectedLine]['valve'][valveIndex]['time']}',style: TextStyle(color: Colors.black87,fontSize: 12),)
    );
  }

  Widget getDosingRow(GlobalFertLimitProvider gfertpvd,int index,String title){
    return SizedBox(
      width: 100,
      height: 40,
      child: Center(
          child: gfertpvd.globalFert[selectedLine]['valve'][index][title]['value'] == null ? Center(child: Text('N/A')) : Center(child: TextFieldForGlobalFert(purpose: 'central_local/$selectedLine/$index/$title', initialValue: '${gfertpvd.globalFert[selectedLine]['valve'][index][title]['value']}', index: index))
      ),
    );
  }
}

double getSize(double first,double second){
  if(first > second){
    return second;
  }else{
    return first;
  }
}

class VerticalDotBorder extends CustomPainter{
  final Color borderColor;
  VerticalDotBorder({required Color this.borderColor});
  @override
  void paint(Canvas canvas, Size size) {
    Paint border = Paint();
    border.color = borderColor;
    border.strokeWidth = 1;
    final double dashWidth = 5;
    final double dashSpace = 5;
    double currentY = 0;

    while (currentY < size.height) {
      canvas.drawLine(
          Offset(0, currentY), Offset(0, currentY + dashWidth), border);
      currentY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}
