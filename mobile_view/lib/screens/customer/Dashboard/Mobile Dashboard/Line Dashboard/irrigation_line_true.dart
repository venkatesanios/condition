import 'package:flutter/material.dart';
import '../../../../../state_management/MqttPayloadProvider.dart';
import '../mobile_dashboard_common_files.dart';

class IrrigationLineFalse extends StatefulWidget {
  final int active;
  final int selectedLine;
  final int currentLine;
  final MqttPayloadProvider payloadProvider;
  const IrrigationLineFalse({super.key, required this.active, required this.selectedLine, required this.currentLine, required this.payloadProvider});
  @override
  State<IrrigationLineFalse> createState() => _IrrigationLineFalseState();
}

class _IrrigationLineFalseState extends State<IrrigationLineFalse> with SingleTickerProviderStateMixin{

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
    print('irrigation line True is dispose');
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return getLineWidget(context: context, selectedLine: widget.selectedLine, currentLine: widget.currentLine, payloadProvider: widget.payloadProvider, controller: _controller);
  }
}