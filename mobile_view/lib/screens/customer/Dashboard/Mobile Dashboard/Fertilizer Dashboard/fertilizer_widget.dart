import 'package:flutter/material.dart';
import 'package:mobile_view/constants/theme.dart';
import 'package:provider/provider.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import 'package:flutter_svg/svg.dart';
import '../mobile_dashboard_common_files.dart';

class FertilizerWidget extends StatefulWidget {
  final siteIndex;
  final int selectedLine;
  final int centralOrLocal;
  final AnimationController controller;
  const FertilizerWidget({super.key, required this.siteIndex, required this.centralOrLocal, required this.selectedLine, required this.controller});

  @override
  State<FertilizerWidget> createState() => _FertilizerWidgetState();
}

class _FertilizerWidgetState extends State<FertilizerWidget> {
  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    dynamic site = widget.centralOrLocal == 1  ? payloadProvider.fertilizerCentral : payloadProvider.fertilizerLocal;
    dynamic booster = site[widget.siteIndex]['Booster']?[0];
    dynamic channelList = site[widget.siteIndex]['Fertilizer'];
    dynamic ec = site[widget.siteIndex]['Ec'];
    dynamic ph = site[widget.siteIndex]['Ph'];

    return Container(
      // color: Colors.green,
      padding: EdgeInsets.only(left: 8,right: 8),
      width: double.infinity,
      height: (200 * getTextScaleFactor(context)).toDouble(),
      child: Stack(
        children: [
          Positioned(
              top: (20 * getTextScaleFactor(context)).toDouble(),
              child: SizedBox(
                  height: (20 * getTextScaleFactor(context)).toDouble(),
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text('${site[widget.siteIndex]['SW_Name'] ?? site[widget.siteIndex]['FertilizerSite']} ${site[widget.siteIndex]['Program'] != '' ? '(${site[widget.siteIndex]['Program']})' : ''}',style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff007988)
                  ),))
              )
          ),
          Positioned(
            top: (84 * getTextScaleFactor(context)).toDouble(),
            left: (6 * getTextScaleFactor(context)).toDouble(),
            child: SizedBox(
              width: 35,
              height: (35 * getTextScaleFactor(context)).toDouble(),
              child: Image.asset('assets/images/booster_${getImage(booster['Status'])}.png'),
            ),
          ),
          Positioned(
              top: (70 * getTextScaleFactor(context)).toDouble(),
              left: 15,
              child: Text('${booster['SW_Name'] ?? booster['Name']}',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold))
          ),
          Positioned(
            left: 5,
            bottom: (13 * getTextScaleFactor(context)).toDouble(),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 10,
                child: horizontalFertPipeRightFlow(count: 11, mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine) != 0 ? (![0,3].contains(booster['Status'])? 1 : 0) : 0, controller: widget.controller,)
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for(var i = 0; i < ec.length;i++)
                    Text('${ec[i]['SW_Name'] ?? ec[i]['Name']} : ${ec[i]['Status']}',style: TextStyle(fontSize: 11,fontWeight: FontWeight.normal),),
                  for(var i = 0; i < ph.length;i++)
                    Text('${ph[i]['SW_Name'] ?? ph[i]['Name']} : ${ph[i]['Status']}',style: TextStyle(fontSize: 11,fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
          SizedBox(
              width: 40,
              height: (200 * getTextScaleFactor(context)).toDouble(),
              child: verticalPipeTopFlow(count: 5, mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: widget.controller)
          ),
          if(site[widget.siteIndex]['FertilizerTankSelector'] != null && site[widget.siteIndex]['FertilizerTankSelector'].isNotEmpty)
            Positioned(
                bottom: 50,
                left: 15,
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: Image.asset('assets/images/selector${getStatus(site[widget.siteIndex]['FertilizerTankSelector'][0]['Status'])}.png'),
                )
            ),

          if(site[widget.siteIndex]['FertilizerTankSelector'] != null && site[widget.siteIndex]['FertilizerTankSelector'].isNotEmpty)
            Positioned(
                bottom: 30,
                left: 15,
                child: SizedBox(
                    width: 40,
                    child: Text('${site[widget.siteIndex]['FertilizerTankSelector'][0]['Name']}',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
                )
            ),
          if(site[widget.siteIndex]['Agitator'].isNotEmpty)
            Positioned(
                top: (25 * getTextScaleFactor(context)).toDouble(),
                left: 12,
                child: Text('${site[widget.siteIndex]['Agitator'][0]['Name']}',style: TextStyle(fontSize: 12),)
            ),
          if(site[widget.siteIndex]['Agitator'].isNotEmpty)
            Positioned(
                top: (40 * getTextScaleFactor(context)).toDouble(),
                left: 12,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    'assets/images/${getAgitatorStatus(site[widget.siteIndex]['Agitator'][0]['Status'])}.svg',
                  ),
                )
            ),
          if(site[widget.siteIndex]['Agitator'].isNotEmpty)
            Positioned(
                top: (40 * getTextScaleFactor(context)).toDouble(),
                left: 40,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 20,
                    child: horizontalAirPipeLeftFlow(count: 5, mode: [0,3].contains(site[widget.siteIndex]['Agitator'][0]['Status']) ? 0 : 1, controller: widget.controller,)
                )
            ),
          Positioned(
              top: (50 * getTextScaleFactor(context)).toDouble(),
              left: 40,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: (160 * getTextScaleFactor(context)).toDouble(),
                // color: Colors.white,
                child: Stack(
                  children: [
                    Positioned(
                      top: (60 * getTextScaleFactor(context)).toDouble(),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 8,
                          child: horizontalPipeLeftFlow(count: 11, mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine) != 0 ? (![0,3].contains(booster['Status']) ? 1 : 0) : 0, controller: widget.controller)
                        // child: Image.asset('assets/images/animated_horizontal_water_pipe.gif')
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(var i = 0;i < channelList.length;i++)
                          Stack(
                            children: [
                              InkWell(
                                onTap: (){
                                  showDialog(context: context, builder: (context){
                                    return AlertDialog(
                                      title: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: Text('${channelList[i]['SW_Name'] ?? channelList[i]['Name']}',style: TextStyle(overflow: TextOverflow.ellipsis),),
                                            width: MediaQuery.of(context).size.width * 0.4,
                                          ),
                                          IconButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(Icons.cancel)
                                          )
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.star_rate),
                                            title: Text('Flow Rate L/H'),
                                            subtitle: Text('${channelList[i]['FlowRate_LpH']}'),
                                          ),
                                          if(channelList[i]['FertMethod'] != 0)
                                            ListTile(
                                              leading: Icon(Icons.type_specimen),
                                              title: Text('Method'),
                                              subtitle: Text('${fertMethod[channelList[i]['FertMethod']]}'),
                                            ),
                                          if(channelList[i]['FertMethod'] != 0)
                                            ListTile(
                                              leading: Icon(Icons.type_specimen),
                                              title: Text('Set'),
                                              subtitle: Text('${[1,3,5].contains(channelList[i]['FertMethod']) ? channelList[i]['Duration'] : channelList[i]['Qty']}'),
                                            ),
                                        ],
                                      ),
                                    );
                                  });
                                },
                                child: SizedBox(
                                  width:(55 * getTextScaleFactor(context)).toDouble(),
                                  height:(130 * getTextScaleFactor(context)).toDouble(),
                                  child: SvgPicture.asset(
                                    'assets/images/${getChannelImg(payloadProvider: payloadProvider, channelData: channelList[i], selectedLine: widget.selectedLine, context: context)}.svg',
                                  ),
                                ),
                              ),
                              Positioned(
                                top: (50 * getTextScaleFactor(context)).toDouble(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${channelList[i]['Name']}',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                                    if(getWaterPipeStatus(context,selectedLine: widget.selectedLine) != 0)
                                      if(hideShowChannelValues('${['2','4','5'].contains(channelList[i]['FertMethod']) ? channelList[i]['QtyLeft'].toStringAsFixed(2) : getTime(channelList[i]['DurationLeft'])}',channelList[i]['Status']))
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: 3,vertical: 1),
                                            color: Colors.black,
                                            child: Text(['2','4','5'].contains(channelList[i]['FertMethod']) ? '${channelList[i]['QtyLeft'].toStringAsFixed(2)} L' : getTime(channelList[i]['DurationLeft']),style: TextStyle(fontSize: 8,fontWeight: FontWeight.bold,color: Colors.white),)
                                        ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                child: Container(
                                    padding: EdgeInsets.all(2),
                                    width: (50 * getTextScaleFactor(context)).toDouble(),
                                    color: primaryColorDark,
                                    child: Text('${channelList[i]['FlowRate_LpH']} L/H',style: TextStyle(fontSize: 8,fontWeight: FontWeight.bold,color: Colors.white),)
                                ),
                              )
                            ],
                          ),
                      ],
                    ),

                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

  String getTime(String time){
    var value = time.split(':');
    return '${value[0]}:${value[1]}:${value[2]}';
  }

  bool hideShowChannelValues(String data,int status){
    var value = true;
    if(['00:00:00','00:00:00:00'].contains(data)){
      value = false;
    }else if(['0.00','0.0'].contains(data)){
      value = false;
    }
    if([0,3].contains(status)){
      value = false;
    }
    return value;
  }

  String getBoosterImage(int status){
    String name = '';
    if(status == 0){
      name = '_g';
    }else if(status == 3){
      name = '_r';
    }
    return name;
  }
}

String getChannelImg({required MqttPayloadProvider payloadProvider,required channelData,required selectedLine,required context}){
  var img = getWaterPipeStatus(context,selectedLine: selectedLine) != 0 ? getChannelType(channelData) : 'channel_b';
  if(img == 'channel_b' && channelData['Status'] != 0){
    img = getChannelType(channelData);
  }
  for(var currentProgram in payloadProvider.currentSchedule){
    if(currentProgram['FC'] != null){
      for(var fc in currentProgram['FC']){
        if(channelData['Name'] == fc['Name']){
          if(fc['Status'] == 1){
            img = 'channel_g';
          }else if(fc['Status'] == 2){
            img = 'channel_o';
          }else if(fc['Status'] == 3){
            img = 'channel_r';
          }
        }
      }
    }
  }
  for(var node in payloadProvider.nodeDetails){
    for(var object in node['RlyStatus']){
      if(object['Name'] == channelData['Name']){
        if(object['Status'] == 3){
          img = 'channel_r';
        }
      }
    }
  }
  return img;
}

String getChannelType(dynamic channel){
  String mode = 'channel_b';
  if(channel['Status'] == 1){
    mode = 'channel_g';
  }else if(channel['Status'] == 2){
    mode = 'channel_o';
  }else if(channel['Status'] == 3){
    mode = 'channel_r';
  }else if(channel['Status'] == 4){
    mode = 'channel_b';
  }
  return mode;
}

String getAgitatorStatus(int status){
  var img = '';
  if(status == 0){
    img = 'agitator_b';
  }else if(status == 1){
    img = 'agitator_g';
  }else if(status == 2){
    img = 'agitator_o';
  }else{
    img = 'agitator_r';
  }
  return img;
}

String getStatus(int status){
  var img = '';
  if(status == 0){
    img = '_b';
  }else if(status == 1){
    img = '_g';
  }else if(status == 2){
    img = '_o';
  }else{
    img = '_r';
  }
  return img;
}

dynamic fertMethod = {
  1 : 'Time',
  2 : 'Quantity',
  3 : 'Proportional Time',
  4 : 'Proportional Quantity',
  5 : 'Proportional Time Per 1000L',
};

class PipeWithRunningWaterInHorizontal extends CustomPainter {
  final double ctrlValue;
  final int? mode;

  PipeWithRunningWaterInHorizontal({required this.ctrlValue, this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    Paint normalBubbles = Paint()..color = mode == null ? Color(0xff156CB4) : Colors.black;
    Paint gradientBubbles = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff488BC2), Color(0xff020E39)],
      ).createShader(Rect.fromLTWH(0, 0, 100, 15));

    // Draw 10 bubbles
    for (int i = 0; i < 10; i++) {
      double x = 5 + i * 10.0;
      double y = 3 * (ctrlValue * (i + 1));
      double size = 3 + (i % 2 == 0 ? 1.0 : 0.5); // Adjust size alternately
      canvas.drawOval(Rect.fromLTWH(x, y, size, size), normalBubbles);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}