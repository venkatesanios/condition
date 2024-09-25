import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_view/constants/theme.dart';

import '../../../../constants/MQTTManager.dart';
import '../../../../state_management/MqttPayloadProvider.dart';
import '../../../../state_management/overall_use.dart';
import 'package:provider/provider.dart';


class controllerlog extends StatefulWidget {
  @override
  _controllerlogState createState() => _controllerlogState();
}

class _controllerlogState extends State<controllerlog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late OverAllUse overAllPvd;
  late MqttPayloadProvider mqttPayloadProvider;
  MQTTManager manager = MQTTManager();

  // late controllerlog logpayloadProvider;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    mqttConfigureAndConnect();
    // logpayloadProvider = Provider.of<controllerlog>(context, listen: false);
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    getlog(7);
  }



  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myTheme.primaryColorLight,
        title: Text('Controller Log'),
      ),
      body: Column(
        children: [

          TabBar(
            onTap: (value) {
              getlog(value+7);
            },
            dividerColor: Colors.teal,
            controller: _tabController,
            tabs: [
              Tab(text: 'Schedule'),
              Tab(text: 'UARD'),
              Tab(text: 'UARD-0'),
              Tab(text: 'UARD-4'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScrollableText('1'),
                _buildScrollableText('2'),
                _buildScrollableText('3'),
                _buildScrollableText('4'),
              ],
            ),
          ),
          SizedBox(height: 5,),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: (){
              getlog (11);
            },
            child: Text('Stop'),
          ),
        ],
      ),
    );
  }
  void mqttConfigureAndConnect() {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    manager.initializeMQTTClient(state: mqttPayloadProvider);
    manager.connect();
  }

  Widget _buildScrollableText(String type) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(

        controller: _scrollController,
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            type == '1' ? Text(mqttPayloadProvider.sheduleLog) : type == '2' ? Text(mqttPayloadProvider.uardLog) :  type == '3' ? Text(mqttPayloadProvider.uard0Log) :  type == '4' ? Text(mqttPayloadProvider.uard4Log) :  Text("Waiting...."),
          ],
        ),
      ),
    );
  }

  getlog (int data)
  {
    manager.subscribeToTopic('OroGemLog/${overAllPvd.imeiNo}');
    // mqttPayloadProvider.editSubscribeTopic('OroGemLog/${overAllPvd.imeiNo}');

    ///7-schudele log
    ///8 uart
    ///9 uart0
    ///10 uart 4
    print(data);
    String payLoadFinal = jsonEncode({
      "5700": [
        {"5701": "$data"},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${overAllPvd.imeiNo}');
  }



  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
