import 'package:flutter/material.dart';
import 'fertilizer_widget.dart';

class FertilizerSiteTrue extends StatefulWidget {
  final int siteIndex;
  final int selectedLine;
  final int centralOrLocal;

  const FertilizerSiteTrue({super.key, required this.siteIndex, required this.centralOrLocal, required this.selectedLine});

  @override
  State<FertilizerSiteTrue> createState() => _FertilizerSiteTrueState();
}

class _FertilizerSiteTrueState extends State<FertilizerSiteTrue> with SingleTickerProviderStateMixin{

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
    // print('Fertilizer Site True is dispose');
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FertilizerWidget(siteIndex: widget.siteIndex, centralOrLocal: widget.centralOrLocal, selectedLine: widget.selectedLine, controller: _controller,);
  }
}