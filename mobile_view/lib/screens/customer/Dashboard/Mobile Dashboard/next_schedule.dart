import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/schedule_program.dart';
import 'package:provider/provider.dart';
import '../../../../ListOfFertilizerInSet.dart';
import '../../../../constants/theme.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NextScheduleForMobile extends StatefulWidget {
  // final int selectedLine;
  const NextScheduleForMobile({super.key});

  @override
  State<NextScheduleForMobile> createState() => _NextScheduleForMobileState();
}

class _NextScheduleForMobileState extends State<NextScheduleForMobile> {
  ScrollController _nextScheduleController = ScrollController();

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if(payloadProvider.nextSchedule.isEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Image.asset('assets/images/no_data.jpg'),
            ),
          if(payloadProvider.nextSchedule.isNotEmpty)
            ListView.builder(
                shrinkWrap: true,
                itemCount: payloadProvider.nextSchedule.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  var program = payloadProvider.nextSchedule[index];
                  if(['All',program['ProgCategory']].contains(payloadProvider.lineData[payloadProvider.selectedLine]['id'])) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 20,left: 5,right: 5),
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: customBoxShadow
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height/2.5,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xff036673)
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  height: MediaQuery.of(context).size.height/4,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        title: Text("Next Schedule",style: TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis, color: Colors.white),),
                                      ),
                                      ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        title: Text(
                                          program['ProgName'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 18,
                                              color: Colors.white
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${programSchedule[program['SchedulingMethod']]}',
                                          style: TextStyle(color: Colors.white,overflow: TextOverflow.ellipsis,),),
                                        trailing: Text('${program['ZoneName']}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14,overflow: TextOverflow.ellipsis),),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 15),
                                    child: Stack(
                                      fit: StackFit.loose,
                                      children: [
                                        DiagonalSplitWidget(),
                                        // Align(
                                        //   alignment: Alignment.center,
                                        //   child: Image.asset(
                                        //     "assets/SVGPicture/next_schedule_image.png",
                                        //   ),
                                        // ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                              children: [
                                                for(var i in ['Zone/CurrentZone','RTC/CurrentRtc','Cycle/CurrentCycle'])
                                                  Container(
                                                    width: MediaQuery.of(context).size.width - 80,
                                                    child: ListTile(
                                                        leading: Icon(Icons.repeat, color: Colors.white,),
                                                        title: Text('${i.split('/')[0]}',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                                        trailing: Text('${program[i.split('/')[1]]}',style: TextStyle(color: Colors.white, fontSize: 16),)
                                                    ),
                                                  )
                                              ]
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        buildScheduleItem(
                                            context: context,
                                            title: 'Start Date',
                                            iconColor: Colors.white,
                                            backGroundColor: Color(0xff0FA5D8),
                                            showIcon: true,
                                            showSubTitle: true,
                                            additionalInfo: "",
                                            subTitle: "at",
                                            icon: Icons.calendar_month,
                                            child: Text("${program['StartDate']}", style: TextStyle(color: Colors.white),),
                                            color: Color(0xff0FA5D8)
                                        ),
                                        buildScheduleItem(
                                            context: context,
                                            title: 'Start Time',
                                            iconColor: Colors.white,
                                            backGroundColor: Color(0xffF3B62A),
                                            // showIcon: true,
                                            // showSubTitle: true,
                                            // additionalInfo: "",
                                            // subTitle: "at",
                                            icon: Icons.timer,
                                            child: Text("${program['StartTime']}", style: TextStyle(color: Colors.white)),
                                            color: Color(0xffF3B62A)
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        buildScheduleItem(
                                            context: context,
                                            title: 'Location',
                                            iconColor: Colors.white,
                                            backGroundColor: Color(0xffF4745B),
                                            // showIcon: true,
                                            // showSubTitle: true,
                                            // additionalInfo: "",
                                            // subTitle: "at",
                                            icon: Icons.location_on,
                                            child: Text("${program['ProgCategory']}", style: TextStyle(color: Colors.white)),
                                            color: Color(0xffF4745B)
                                        ),
                                        buildScheduleItem(
                                            context: context,
                                            title: '${program['IrrigationMethod'] == 1 ? 'Duration' : 'Quantity'}',
                                            iconColor: Colors.white,
                                            backGroundColor: Color(0xff07594B),
                                            showIcon: true,
                                            showSubTitle: true,
                                            additionalInfo: "",
                                            subTitle: "at",
                                            icon: Icons.calculate_sharp,
                                            child: Text("${program['IrrigationDuration_Quantity']}", style: TextStyle(color: Colors.white)),
                                            color: Color(0xff07594B)
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                }
            ),
        ],
      ),
    );
  }
}

var scheduleMethod = {
  1 : 'No Schedule',
  2: 'Schedule By Days',
  3 : 'Schedule As Run List',
  4 : 'Day Count RTC'
};

Widget buildScheduleItem({
  required BuildContext context,
  required String title,
  String? subTitle,
  String? additionalInfo,
  bool showSubTitle = false,
  bool showIcon = false,
  EdgeInsets? padding,
  required Color iconColor,
  required Color backGroundColor,
  required Widget child,
  required Color color,
  IconData? icon}){
  return Card(
    elevation: 3,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: customBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if(showIcon)
            CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Icon(icon, color: iconColor,)),
          Row(
            children: [
              if(!showIcon)
                CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Icon(icon, color: iconColor,)),
              if(!showIcon)
                const SizedBox(width: 10,),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)),
            ],
          ),
          if(showSubTitle)
            Text(subTitle!, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis, color: Colors.white),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(!showSubTitle || additionalInfo != null)
                Text(additionalInfo ?? "", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis, color: Colors.white),),
              child
            ],
          )
        ],
      ),
    ),
  );
}

class DiagonalSplitWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15), // Rounded corners
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width - 50, 160), // Width and height of the widget
        painter: DiagonalPainter(),
      ),
    );
  }
}

class DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    // First half (left dark section)
    paint.color = Colors.grey[800]!;
    Path leftPath = Path();
    leftPath.moveTo(0, 0); // Start at top-left corner
    leftPath.lineTo(size.width * 0.6, 0); // Move to right (60% width)
    leftPath.lineTo(0, size.height); // Move down to bottom-left corner
    leftPath.close(); // Close the path (back to starting point)
    canvas.drawPath(leftPath, paint);

    // Second half (right teal section)
    paint.color = Colors.teal;
    Path rightPath = Path();
    rightPath.moveTo(size.width * 0.6, 0); // Start at top-middle (60% width)
    rightPath.lineTo(size.width, 0); // Move to top-right corner
    rightPath.lineTo(size.width, size.height); // Move down to bottom-right
    rightPath.lineTo(0, size.height); // Move to bottom-left corner
    rightPath.close();
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint if nothing changes
  }
}
