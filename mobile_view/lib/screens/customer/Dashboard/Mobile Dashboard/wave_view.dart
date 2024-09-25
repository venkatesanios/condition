import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

import '../../../../ListOfFertilizerInSet.dart';

class WaveView extends StatefulWidget {
  final double percentageValue;
  final double width;
  final double height;
  final double borderRadius;

  WaveView({super.key, this.percentageValue = 100.0, this.width = 50, this.height = 100, this.borderRadius = 80});

  @override
  _WaveViewState createState() => _WaveViewState();
}

class _WaveViewState extends State<WaveView> with TickerProviderStateMixin {
  AnimationController? animationController;
  AnimationController? waveAnimationController;
  List<Offset> animList1 = [];
  List<Offset> animList2 = [];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    waveAnimationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController?.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController?.forward();
      }
    });

    waveAnimationController!.addListener(() {
      // Wave calculation moved to build method
    });
    waveAnimationController?.repeat();
    animationController?.forward();
  }

  @override
  void dispose() {
    animationController?.dispose();
    waveAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = widget.width;
        double height = widget.height;

        // Generate wave points
        animList1.clear();
        animList2.clear();
        for (int i = -2; i <= width.toInt() + 2; i++) {
          double yOffset = math.sin((waveAnimationController!.value * 360 - i) %
              360 *
              vector.degrees2Radians) *
              1.5 + // Increased amplitude for more visible wave
              (height - ((widget.percentageValue / 100) * height));

          animList1.add(
            Offset(i.toDouble(), yOffset),
          );
          animList2.add(
            Offset(i.toDouble(), yOffset),
          );
        }

        return SizedBox(
          width: width,
          height: height,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: Colors.blue.shade100, width: 0.3),
                color: Colors.white,
                boxShadow: customBoxShadow
            ),
            child: AnimatedBuilder(
              animation: CurvedAnimation(
                parent: animationController!,
                curve: Curves.easeInOut,
              ),
              builder: (context, child) => Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: WaveClipper(animationController!.value, animList1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(color: Colors.blue.shade100, width: 0.3),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.shade100,
                            Colors.blue.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(animationController!.value, animList2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.shade100,
                            Colors.blue.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.blue.shade100, width: 0.3),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        'Level\n${widget.percentageValue.round()}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14, // Adjust font size to fit within dimensions
                          letterSpacing: 0.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 0,
                    bottom: 16,
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                          parent: animationController!,
                          curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn))),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 24,
                    bottom: 32,
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                          parent: animationController!,
                          curve: const Interval(0.6, 0.8, curve: Curves.fastOutSlowIn))),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 20,
                    bottom: 0,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 16 * (1.0 - animationController!.value), 0.0),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                              animationController!.status == AnimationStatus.reverse
                                  ? 0.0
                                  : 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Column(
                  //   children: <Widget>[
                  //     AspectRatio(
                  //       aspectRatio: 1,
                  //       child: Image.asset("assets/images/bottle.png"),
                  //     ),
                  //   ],
                  // )
                  // Additional widgets remain unchanged
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}