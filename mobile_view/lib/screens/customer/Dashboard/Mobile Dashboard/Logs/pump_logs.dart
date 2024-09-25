import 'package:flutter/material.dart';
import 'package:mobile_view/screens/Customer/Dashboard/Mobile%20Dashboard/Logs/hourly_data.dart';
import 'package:mobile_view/screens/Customer/Dashboard/Mobile%20Dashboard/Logs/pump_log.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Logs/voltage_log.dart';
import 'package:provider/provider.dart';

import '../../../../../state_management/overall_use.dart';

class PumpLogs extends StatefulWidget {
  const PumpLogs({super.key});

  @override
  State<PumpLogs> createState() => _PumpLogsState();
}

class _PumpLogsState extends State<PumpLogs> with TickerProviderStateMixin{
  late TabController tabController;
  late OverAllUse overAllUse;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    overAllUse = Provider.of<OverAllUse>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    overAllUse = Provider.of<OverAllUse>(context, listen: true);
    return Scaffold(
      body: SafeArea(
          child: DefaultTabController(
              length: tabController.length,
              child: Column(
                children: [
                  TabBar(
                      tabs: [
                        Tab(text: "Pump log",),
                        Tab(text: "Power graph",),
                        Tab(text: "Voltage Log",),
                      ]
                  ),
                  // SizedBox(height: 10,),
                  Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                          children: [
                            NewPumpLogScreen(userId: overAllUse.userId, controllerId: overAllUse.controllerId),
                            HourlyData(userId: overAllUse.userId, controllerId: overAllUse.controllerId),
                            PumpVoltageLogScreen(userId: overAllUse.userId, controllerId: overAllUse.controllerId, nodeControllerId: 0,),
                          ]
                      )
                  )
                ],
              )
          )
      ),
    );
  }
}
