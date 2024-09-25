import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../ListOfFertilizerInSet.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import '../mobile_dashboard_common_files.dart';
import 'package:provider/provider.dart';
import 'filter_widget.dart';

class FiltrationSiteFalse extends StatefulWidget {
  final int centralOrLocal;
  final int siteIndex;
  final int selectedLine;
  const FiltrationSiteFalse({super.key, required this.siteIndex, required this.centralOrLocal, required this.selectedLine});
  @override
  State<FiltrationSiteFalse> createState() => _FiltrationSiteFalseState();
}

class _FiltrationSiteFalseState extends State<FiltrationSiteFalse> with SingleTickerProviderStateMixin{

  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {

      });
    });
    _controller.repeat();

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // print('filter site false dispose');
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    dynamic site = widget.centralOrLocal == 1  ? payloadProvider.filtersCentral : payloadProvider.filtersLocal;
    return Container(
        padding: EdgeInsets.only(left: 8,right: 8),
        width: double.infinity,
        height: (180 * getTextScaleFactor(context)).toDouble(),
        child: Row(
          children: [
            Container(
              width: 40,
              height: (180 * getTextScaleFactor(context)).toDouble(),
              child: Stack(
                children: [
                  SizedBox(
                      width: 40,
                      height: (180 * getTextScaleFactor(context)).toDouble(),
                      child: verticalPipeTopFlow(count: 4, mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller, )
                  ),
                  Positioned(
                    left: 10,
                    top: 30,
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: SvgPicture.asset(
                        'assets/images/pressure_sensor.svg',
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 150,
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: SvgPicture.asset(
                        'assets/images/pressure_sensor.svg',
                      ),
                    ),
                  ),
                  Positioned(
                      top: (180 * getTextScaleFactor(context)).toDouble()/2 + 7,
                      child: SizedBox(
                          width: 40,
                          height: 40,
                          child: horizontalPipeLeftFlow(count: 2,mode: (site[widget.siteIndex]['Program'] != '' && getWaterPipeStatus(context,selectedLine: widget.selectedLine) != 0) ? 1 : 0, controller: _controller,)
                      )
                  ),
                  Positioned(
                    left: -3,
                    top: (180 * getTextScaleFactor(context)).toDouble()/2,
                    child: Transform.rotate(
                      angle: 4.71,
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: SvgPicture.asset(
                          'assets/images/T_joint.svg',
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.bottomCenter,
                        child: Text('${site[widget.siteIndex]['SW_Name'] ?? site[widget.siteIndex]['FilterSite']} ${site[widget.siteIndex]['Program'] != '' ? '(${site[widget.siteIndex]['Program']})' : '' }',style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff007988)
                        ),),
                        padding: EdgeInsets.all(2)
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: (140 * getTextScaleFactor(context)).toDouble(),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: customBoxShadow
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            height: (120 * getTextScaleFactor(context)).toDouble(),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if(site.isNotEmpty)
                                    for(var filter in site[widget.siteIndex]['FilterStatus'])
                                      FilterWidget(filterName: filter['SW_Name'] ?? filter['Name'], filterMode: getFilter(filter['Status'],context,site[widget.siteIndex]['Program']), duration: site[widget.siteIndex]['DurationLeft'], program: site[widget.siteIndex]['Program'], selectedLine: widget.selectedLine, controller: _controller,),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if(site[widget.siteIndex]['PrsIn'] != '-')
                          Positioned(
                            top: 0,
                            left: 10,
                            child: Container(
                              width: 150,
                              height: (20 * getTextScaleFactor(context)).toDouble(),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xff3A96D2)
                              ),
                              child: Center(
                                  child: Text('Pressure In : ${site[widget.siteIndex]['PrsIn']}',style: TextStyle(color: Colors.white,fontSize: 12),)
                              ),
                            ),
                          ),
                        if(site[widget.siteIndex]['PrsOut'] != '-')
                          Positioned(
                            bottom: 0,
                            left: 10,
                            child: Container(
                              width: 150,
                              height: (20 * getTextScaleFactor(context)).toDouble(),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xff3A96D2)
                              ),
                              child: Center(
                                  child: Text('Pressure Out : ${site[widget.siteIndex]['PrsOut']}',style: TextStyle(color: Colors.white,fontSize: 12),)
                              ),
                            ),
                          ) ,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}