import 'package:flutter/material.dart';
import 'fertilizer_widget.dart';

class FertilizerSiteFalse extends StatefulWidget {
  final int siteIndex;
  final int selectedLine;
  final int centralOrLocal;
  const FertilizerSiteFalse({super.key, required this.siteIndex, required this.centralOrLocal, required this.selectedLine});

  @override
  State<FertilizerSiteFalse> createState() => _FertilizerSiteFalseState();
}

class _FertilizerSiteFalseState extends State<FertilizerSiteFalse> with SingleTickerProviderStateMixin{

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
    // print('Fertilizer Site False is dispose');
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FertilizerWidget(siteIndex: widget.siteIndex, centralOrLocal: widget.centralOrLocal, selectedLine: widget.selectedLine, controller: _controller,);
  }
}