import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Logs/pump_list.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/http_service.dart';
import '../../../../../state_management/overall_use.dart';
import '../IrrigationLog/list_of_log_config.dart';


import '../IrrigationLog/standalone_log.dart';

class IrrigationAndPumpLog extends StatefulWidget {
  final int userId, controllerId;
  const IrrigationAndPumpLog({super.key, required this.userId, required this.controllerId});

  @override
  State<IrrigationAndPumpLog> createState() => _IrrigationAndPumpLogState();
}

class _IrrigationAndPumpLogState extends State<IrrigationAndPumpLog> with TickerProviderStateMixin{
  late TabController tabController;
  List pumpList = [];
  String message = '';
  late OverAllUse overAllUse;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    overAllUse = Provider.of<OverAllUse>(context, listen: false);
    getUserNodePumpList();
    super.initState();
  }

  Future<void> getUserNodePumpList() async{
    Map<String, dynamic> userData = {
      "userId": overAllUse.userId,
      "controllerId": overAllUse.controllerId
    };

    print(userData);
    final result = await HttpService().postRequest('getUserNodePumpList', userData);
    setState(() {
      if(result.statusCode == 200 && jsonDecode(result.body)['data'] != null) {
        pumpList = jsonDecode(result.body)['data'];
      } else {
        message = jsonDecode(result.body)['message'];
      }
    });
    // print(result.body);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
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
                        Tab(text: "Irrigation Log",),
                        Tab(text: "Standalone Log",),
                        if(pumpList.isNotEmpty)
                          Tab(text: "Pump Log",)
                        else
                          Container()
                      ]
                  ),
                  // SizedBox(height: 10,),
                  Expanded(
                      child: TabBarView(
                          children: [
                            ListOfLogConfig(),
                            StandaloneLog(userId: widget.userId, controllerId: widget.controllerId,),
                            if(pumpList.isNotEmpty)
                              PumpList(pumpList: pumpList)
                            else
                              Container()
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
