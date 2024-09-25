
import 'package:flutter/material.dart';
import 'package:mobile_view/screens/Customer/Dashboard/PumpControllerScreens/pump_controller_dashboard.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Logs/pump_log.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Logs/voltage_log.dart';

import 'hourly_data.dart';

class PumpList extends StatefulWidget {
  final List pumpList;
  const PumpList({super.key, required this.pumpList});

  @override
  State<PumpList> createState() => _PumpListState();
}

class _PumpListState extends State<PumpList> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: widget.pumpList.length,
          itemBuilder: (BuildContext context, int index) {
          final pumpItem = widget.pumpList[index];
            return Column(
              children: [
                Container(
                  // margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // boxShadow: customBoxShadow
                  ),
                  child: ListTile(
                    title: Text('${pumpItem['deviceName']}'),
                    subtitle: Text('${pumpItem['deviceId']}'),
                    trailing: IntrinsicWidth(
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HourlyData(userId: 12, controllerId: 39, nodeControllerId: pumpItem['controllerId'],)));
                              },
                              icon: Icon(Icons.power)
                          ),
                          IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NewPumpLogScreen(userId: 12, controllerId: 39, nodeControllerId: pumpItem['controllerId'],)));
                              },
                              icon: Icon(Icons.auto_graph)
                          ),
                          IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PumpVoltageLogScreen(userId: 12, controllerId: 39, nodeControllerId: pumpItem['controllerId'],)));
                              },
                              icon: Icon(Icons.electric_bolt)
                          ),
                        ],
                      ),
                    ),
                    leading: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: linearGradientLeading,
                      ),
                      child: Center(child: Text('${index+1}', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),)),
                    ),
                  ),
                ),
                // SizedBox(height: 15,)
              ],
            );
          }
      ),
    );
  }
}
