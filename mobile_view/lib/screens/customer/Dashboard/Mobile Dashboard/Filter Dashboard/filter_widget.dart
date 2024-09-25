import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import '../home_page.dart';
import 'package:provider/provider.dart';
import '../mobile_dashboard_common_files.dart';

class FilterWidget extends StatefulWidget {
  int filterMode;
  String filterName;
  String duration;
  String program;
  final AnimationController controller;
  final int selectedLine;
  FilterWidget({super.key,required this.duration,required this.filterMode,required this.filterName,required this.program, required this.selectedLine, required this.controller});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    int filterMode = getWaterPipeStatus(context,selectedLine: widget.selectedLine) != 0 ? widget.filterMode : 0;
    if(filterMode == 0 && widget.filterMode != 0){
      filterMode = -widget.filterMode;

    }
    for(var currentProgram in payloadProvider.currentSchedule){
      if(currentProgram['FL'] != null){
        for(var fl in currentProgram['FL']){
          if(widget.filterName == fl['Name']){
            filterMode = -fl['Status'];
          }
        }
      }
    }
    for(var node in payloadProvider.nodeDetails){
      for(var object in node['RlyStatus']){
        if(object['Name'] == widget.filterName){
          if(object['Status'] == 3){
            filterMode = 4;
          }
        }
      }
    }
    return Container(
      width: 100,
      height: (120 * getTextScaleFactor(context)).toDouble(),
      child: Stack(
        children: [
          Positioned(
            top: (3 * getTextScaleFactor(context)).toDouble(),
            child: SizedBox(
              width: 100,
              height: 80,
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/filter_mode_${filterMode.abs()}.svg',
                    ),
                  ),
                  Positioned(
                      left: 75,
                      top: 48,
                      child: SizedBox(
                          width: 40,
                          height: 40,
                          child: filterMode == 3
                              ? horizontalPipeLeftFlow(count: 2,mode: 1, controller: widget.controller, )
                              : [1,2].contains(filterMode)
                              ? horizontalPipeRightFlow(count: 2,mode: 1, controller: widget.controller, )
                              : horizontalPipeLeftFlow(count: 2,mode: 0, controller: widget.controller,)
                      )
                  ),
                  Positioned(
                      left: 0,
                      top: 13,
                      child: Transform.scale(
                        scale: 0.7,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: SvgPicture.asset(
                            'assets/images/${[1,2].contains(filterMode) ? '3_way_valve_backwash' : '3_way_valve_filtration'}.svg',
                          ),
                        ),
                      )
                  ),
                  if([1,2].contains(filterMode))
                    Positioned(
                        left: 10,
                        top: 35,
                        child: SizedBox(
                            width: 20,
                            height: 30,
                            child: verticalPipeTopFlow(count: 2,mode: 2, controller: widget.controller,)
                        )
                    ),
                  if([1].contains(filterMode))
                    Positioned(
                        left: 30,
                        top:30,
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 3,vertical: 2),
                            color: Colors.black,
                            child: Text('${widget.duration}',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.white),)
                        )
                    )
                ],
              ),
            ),
          ),
          Positioned(
              left: 10,
              bottom: (1 * getTextScaleFactor(context)).toDouble(),
              child: Text(widget.filterName,style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),)
          ),
        ],
      ),
    );
  }
}

