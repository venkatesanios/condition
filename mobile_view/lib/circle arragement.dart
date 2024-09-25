import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';


class MyCircle extends StatefulWidget {
  const MyCircle({Key? key}) : super(key: key);

  @override
  State<MyCircle> createState() => _MyCircleState();
}

class _MyCircleState extends State<MyCircle>with TickerProviderStateMixin {
  late AnimationController _controller;
  // late AnimationController _controllerReverse;
  late Animation<double> _animation;
  final double _speed = 100.0; // Speed of animation
  final double _gap = 99.0; // Gap between icons
  final double _initialPosition = -100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
    // _controller.repeat();

    _controller.addListener(() {
    });
    _controller.repeat();
    // _controllerReverse = AnimationController(
    //   duration: Duration(seconds: 1),
    //   vsync: this,
    // );
    // _controllerReverse.repeat(reverse: true);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Irrigation'),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1500,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  // connectingSourcePump(),
                  topSourcePump(),
                  middleSourcePump(),
                  bottomSourcePump(),
                  // ...getWaterTank(),
                  ...sourcePumpToWaterTankPipeConnection(),
                  // ...waterTankToIrrigationPumpPipeConnection(),
                  // ...connectingIrrigationPump(),
                  // topIrrigationPump(),
                  // middleIrrigationPump(),
                  // bottomIrrigationPump(),
                  // irrigationPumpToFilterConnection(),
                  // ...connectingFilter(),
                  // topFilter(),
                  // bottomFilter()

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculatePosition(int index) {
    double basePosition = _initialPosition + (index * _gap);
    double animatedPosition = basePosition + (_speed * _controller.value);
    return animatedPosition;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    // _controllerReverse.dispose();
    super.dispose();
  }

  Widget irrigationPumpToFilterConnection(){
    return Positioned(
      top:57,
      left: 759,
      child: Container(
        width: 40,
        height: 15.0, // Adjust height as per your preference
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                for (int i = 0; i < 7; i++)
                  Positioned(
                      top: 0,
                      left: _calculatePosition(i),
                      child: SizedBox(
                        width: 50,
                        height: 100,
                        child: CustomPaint(
                          painter: PipeWithRunningWaterInHorizontal(ctrlValue: 0),
                          size: const Size(100,15),
                        ),
                      )
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> sourcePumpToWaterTankPipeConnection(){
    return [
      Positioned(
        top: 56,
        left: 248,
        child: Container(
          width: 70,
          height: 15.0, // Adjust height as per your preference
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  for (int i = 0; i < 7; i++)
                    Positioned(
                        top: 0,
                        left: _calculatePosition(i),
                        child: SizedBox(
                          width: 100,
                          height: 15,
                          child: SvgPicture.asset(
                            'assets/images/horizontalPipe.svg',
                          ),
                        ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      Positioned(
        left: 310,
        top: 56,
        child: SizedBox(
          width: 40,
          height: 30,
          child: SvgPicture.asset(
              'assets/images/l_joint.svg',
              // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
              semanticsLabel: 'A red up arrow'
          ),
        ),
      ),
      Positioned(
          left: 328,
          top: 82,
          child: SizedBox(
            width: 15,
            height: 80,
            child: SvgPicture.asset(
              'assets/images/horizontalPipe.svg',
            ),
          )
      ),
    ];
  }

  List<Widget> waterTankToIrrigationPumpPipeConnection(){
    return [
      Positioned(
          left: 420,
          top: 81,
          child: SizedBox(
            width: 15,
            height: 80,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    for (int i = 0; i < 7; i++)
                      Positioned(
                          bottom: _calculatePosition(i),
                          left: 0,
                          child: SizedBox(
                            width: 80,
                            height: 15,
                            child: CustomPaint(
                              painter: PipeWithRunningWaterInVertical(ctrlValue: 0),
                              size: const Size(80,15),
                            ),
                          )
                      ),
                  ],
                );
              },
            ),
          )
      ),
      Positioned(
        left: 415,
        top: 54,
        child: Transform.rotate(
          angle: 4.71,
          child: SizedBox(
            width: 40,
            height: 30,
            child: SvgPicture.asset(
                'assets/images/l_joint.svg',
                // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                semanticsLabel: 'A red up arrow'
            ),
          ),
        ),
      ),
      Positioned(
        top: 56,
        left: 450,
        child: Container(
          width: 70,
          height: 15.0, // Adjust height as per your preference
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  for (int i = 0; i < 7; i++)
                    Positioned(
                        top: 0,
                        left: _calculatePosition(i),
                        child: SizedBox(
                          width: 70,
                          height: 100,
                          child: CustomPaint(
                            painter: PipeWithRunningWaterInHorizontal(ctrlValue: 0),
                            size: const Size(70,15),
                          ),
                        )
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ];
  }

  Widget pumpWithPipeForSourcePump({required mode}){
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          width: 200,
          height: 80,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 100,
                  height: 80,
                  child: CustomPaint(
                    painter: Pump(rotationAngle: mode == 1 ? _animation.value : 0,mode: mode),
                    size: const Size(100,80),
                  ),
                ),
              ),
              Positioned(
                left: 99,
                top: 57,
                child: mode == 1
                    ? Container(
                  width: 100,
                  height: 15.0, // Adjust height as per your preference
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          for (int i = 0; i < 2; i++)
                            Positioned(
                              top: 0,
                              left: _calculatePosition(i),
                              child: SizedBox(
                                width: 100,
                                height: 15,
                                child: SvgPicture.asset(
                                    'assets/images/horizontalPipe.svg',
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                )
                    : Container(
                  width: 100,
                  height: 15,
                  color: Colors.grey.shade400,
                ),
              ),

            ],
          ),
        );
      },

    );
  }

  Widget pumpWithPipeForIrrigationPump({required mode}){
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          width: 250,
          height: 80,
          child: Stack(
            children: [
              Positioned(
                left: 38,
                top: 56,
                child: mode == 1 ? Container(
                  width: 45,
                  height: 15.0, // Adjust height as per your preference
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          for (int i = 0; i < 7; i++)
                            Positioned(
                                top: 0,
                                left: _calculatePosition(i),
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child: CustomPaint(
                                    painter: PipeWithRunningWaterInHorizontal(ctrlValue: 0),
                                    size: const Size(100,15),
                                  ),
                                )
                            ),
                        ],
                      );
                    },
                  ),
                ) : Container(
                  width: 100,
                  height: 15,
                  color: Colors.grey.shade400,
                ),
              ),
              Positioned(
                left: 80,
                top: 0,
                child: Container(
                  width: 100,
                  height: 80,
                  child: CustomPaint(
                    painter: Pump(rotationAngle: mode == 1 ? _animation.value : 0,mode: mode),
                    size: const Size(100,80),
                  ),
                ),
              ),
              Positioned(
                left: 179,
                top: 57,
                child: mode == 1 ? Container(
                  width: 40,
                  height: 15.0, // Adjust height as per your preference
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          for (int i = 0; i < 7; i++)
                            Positioned(
                                top: 0,
                                left: _calculatePosition(i),
                                child: SizedBox(
                                  width: 40,
                                  height: 100,
                                  child: CustomPaint(
                                    painter: PipeWithRunningWaterInHorizontal(ctrlValue: 0),
                                    size: const Size(100,15),
                                  ),
                                )
                            ),
                        ],
                      );
                    },
                  ),
                ) : Container(
                  width: 50,
                  height: 15,
                  color: Colors.grey.shade400,
                ),
              ),

            ],
          ),
        );
      },

    );
  }

  Widget topSourcePump(){
    return Positioned(
        left: 10,
        top: 0,
        child: Container(
          width: 239,
            height: 100,
            child: Stack(
              children: [
                pumpWithPipeForSourcePump(mode: 1),
                Positioned(
                  left: 199,
                  top: 57,
                  child: SizedBox(
                    width: 40,
                    height: 30,
                    child: SvgPicture.asset(
                        'assets/images/t_joint.svg',
                        // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                        semanticsLabel: 'A red up arrow'
                    ),
                  ),
                ),
              ],
            ))
    );
  }

  Widget topIrrigationPump(){
    return Positioned(
        left: 500,
        top: 0,
        child: Container(
            width: 300,
            height: 100,
            child: Stack(
              children: [
                pumpWithPipeForIrrigationPump(mode: 1),
                Positioned(
                  left: 219,
                  top: 57,
                  child: SizedBox(
                    width: 40,
                    height: 30,
                    child: SvgPicture.asset(
                        'assets/images/t_joint.svg',
                        // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                        semanticsLabel: 'A red up arrow'
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 56,
                  child: SizedBox(
                    width: 40,
                    height: 30,
                    child: SvgPicture.asset(
                        'assets/images/t_joint.svg',
                        // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                        semanticsLabel: 'A red up arrow'
                    ),
                  ),
                ),
              ],
            ))
    );
  }

  Widget middleSourcePump(){
    return Positioned(
      left: 10,
      top: 100,
      child: SizedBox(
        width: 240,
        height: 80,
        child: Stack(
          children: [
            pumpWithPipeForSourcePump(mode: 2),
            Positioned(
              top: 50,
              left: 190,
              child: Transform.rotate(
                angle: 1.57,
                child: SizedBox(
                  width: 40,
                  height: 30,
                  child: SvgPicture.asset(
                      'assets/images/t_joint.svg',
                      // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                      semanticsLabel: 'A red up arrow'
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget middleIrrigationPump(){
    return Positioned(
      left: 500,
      top: 100,
      child: SizedBox(
        width: 300,
        height: 100,
        child: Stack(
          children: [
            pumpWithPipeForIrrigationPump(mode: 3),
            Positioned(
              top: 50,
              left: 211,
              child: Transform.rotate(
                angle: 1.57,
                child: SizedBox(
                  width: 40,
                  height: 30,
                  child: SvgPicture.asset(
                      'assets/images/t_joint.svg',
                      // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                      semanticsLabel: 'A red up arrow'
                  ),
                ),
              ),
            ),
            Positioned(
              top: 48,
              left: 7,
              child: Transform.rotate(
                angle: 4.71,
                child: SizedBox(
                  width: 40,
                  height: 30,
                  child: SvgPicture.asset(
                      'assets/images/t_joint.svg',
                      // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                      semanticsLabel: 'A red up arrow'
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSourcePump(){
    return Positioned(
        left: 10,
        top: 200,
        child: Container(
            width: 240,
            height: 100,
            child: Stack(
              children: [
                pumpWithPipeForSourcePump(mode: 1),
                Positioned(
                  left: 191,
                  top: 43,
                  child: Transform.rotate(
                    angle: 1.57,
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: SvgPicture.asset(
                          'assets/images/l_joint.svg',
                          // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                          semanticsLabel: 'A red up arrow'
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }

  Widget bottomIrrigationPump(){
    return Positioned(
        left: 500,
        top: 200,
        child: Container(
            width: 300,
            height: 100,
            child: Stack(
              children: [
                pumpWithPipeForIrrigationPump(mode: 1),
                Positioned(
                  left: 211,
                  top: 43,
                  child: Transform.rotate(
                    angle: 1.57,
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: SvgPicture.asset(
                          'assets/images/l_joint.svg',
                          // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                          semanticsLabel: 'A red up arrow'
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 5,
                  top: 41,
                  child: Transform.rotate(
                    angle: 3.14,
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: SvgPicture.asset(
                          'assets/images/l_joint.svg',
                          // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                          semanticsLabel: 'A red up arrow'
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }

  Widget connectingSourcePump(){
    return Positioned(
      left: 221, // Adjust left position as needed
      top: 70, // Adjust top position as needed
      child: AnimatedPipeWidgetVertical(
        reverse: false,
        controller: _controller, // Pass your AnimationController here, // Pass your AnimationController for reverse animation
        speed: 100.0, // Optionally, you can adjust speed, gap, and initial position here
        gap: 99.0,
        initialPosition: -100,
      ),
    );
  }

  List<Widget> connectingIrrigationPump(){
    return [
      Positioned(
        left: 512,
        top: 70,
        child: SizedBox(
          width: 15,
          height: 180,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  for (int i = 0; i < 7; i++)
                    Positioned(
                        top: _calculatePosition(i),
                        left: 0,
                        child: SizedBox(
                          width: 15,
                          height: 100,
                          child: CustomPaint(
                            painter: PipeWithRunningWaterInVertical(ctrlValue: 0),
                            size: const Size(15,100),
                          ),
                        )
                    ),
                ],
              );
            },
          ),
        )
    ),
      Positioned(
          left: 731,
          top: 70,
          child: SizedBox(
            width: 15,
            height: 180,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    for (int i = 0; i < 7; i++)
                      Positioned(
                          bottom: _calculatePosition(i),
                          left: 0,
                          child: SizedBox(
                            width: 15,
                            height: 100,
                            child: CustomPaint(
                              painter: PipeWithRunningWaterInVertical(ctrlValue: 0),
                              size: const Size(15,100),
                            ),
                          )
                      ),
                  ],
                );
              },
            ),
          )
      ),

    ];
  }

  // List<Widget> getWaterTank(){
  //   return [
  //     Positioned(
  //       left: 280,
  //       top: 150,
  //       child: Container(
  //         child: CustomPaint(
  //           painter: WaterTank(),
  //           size: Size(200,100),
  //         ),
  //       ),
  //     ),
  //     Positioned(
  //         left: 313,
  //         top: 86,
  //         child: AnimatedBuilder(
  //           animation: _controller,
  //           builder: (context, child) {
  //             return CustomPaint(
  //               size: Size(
  //                   135,
  //                   140), // Set the size of the custom paint
  //               painter: WavePainter(
  //                   0), // Use the WavePainter to paint the wave
  //             );
  //           },
  //         )
  //     ),
  //   ];
  // }

  Widget topFilter(){
    return Positioned(
        left: 798,
        top: 27,
        child: Container(
            width: 300,
            height: 120,
            child: Stack(
              children: [
                Positioned(
                  left: 40,
                    child: FilterWithPipe(leftPipe: 1,rightPipe: 0)),
                Positioned(
                  left: 235,
                  top: 78,
                  child: SizedBox(
                    width: 40,
                    height: 30,
                    child: SvgPicture.asset(
                        'assets/images/t_joint.svg',
                        // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                        semanticsLabel: 'A red up arrow'
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 30,
                  child: SizedBox(
                    width: 40,
                    height: 30,
                    child: SvgPicture.asset(
                        'assets/images/t_joint.svg',
                        // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                        semanticsLabel: 'A red up arrow'
                    ),
                  ),
                ),
              ],
            ))
    );
  }

  Widget bottomFilter(){
    return Positioned(
        left: 798,
        top: 150,
        child: Container(
            width: 300,
            height: 100,
            child: Stack(
              children: [
                Positioned(
                  left: 38,
                    child: FilterWithPipe(leftPipe: 0,rightPipe: 1)
                ),
                Positioned(
                  left: 227,
                  top: 65,
                  child: Transform.rotate(
                    angle: 1.57,
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: SvgPicture.asset(
                          'assets/images/l_joint.svg',
                          semanticsLabel: 'A red up arrow'
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 5,
                  top: 15,
                  child: Transform.rotate(
                    angle: 3.14,
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: SvgPicture.asset(
                          'assets/images/l_joint.svg',
                          // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                          semanticsLabel: 'A red up arrow'
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }

  List<Widget> connectingFilter(){
    return [
      Positioned(
          left: 810,
          top: 70,
          child: SizedBox(
            width: 15,
            height: 100,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    for (int i = 0; i < 7; i++)
                      Positioned(
                          top: _calculatePosition(i),
                          left: 0,
                          child: SizedBox(
                            width: 15,
                            height: 100,
                            child: CustomPaint(
                              painter: PipeWithRunningWaterInVertical(ctrlValue: 0),
                              size: const Size(15,100),
                            ),
                          )
                      ),
                  ],
                );
              },
            ),
          )
      ),
      Positioned(
          left: 1045,
          top: 120,
          child: SizedBox(
            width: 15,
            height: 100,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    for (int i = 0; i < 7; i++)
                      Positioned(
                          bottom: _calculatePosition(i),
                          left: 0,
                          child: SizedBox(
                            width: 15,
                            height: 100,
                            child: CustomPaint(
                              painter: PipeWithRunningWaterInVertical(ctrlValue: 0),
                              size: const Size(15,100),
                            ),
                          )
                      ),
                  ],
                );
              },
            ),
          )
      ),

    ];
  }

  Widget FilterWithPipe({required int leftPipe,required int rightPipe}){
    return SizedBox(
      width: 350,
      height: 100,
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 30,
              child: Container(
                width: 80,
                height: 15.0, // Adjust height as per your preference
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        for (int i = 0; i < 7; i++)
                          Positioned(
                              top: 0,
                              right: leftPipe == 1 ? _calculatePosition(i) : null,
                              left: rightPipe == 1 ? _calculatePosition(i) : null,
                              child: SizedBox(
                                width: 50,
                                height: 100,
                                child: CustomPaint(
                                  painter: PipeWithRunningWaterInHorizontal(ctrlValue: 0,mode: leftPipe == 1 ? 1 : null),
                                  size: const Size(100,15),
                                ),
                              )
                          ),
                      ],
                    );
                  },
                ),
              )
          ),
          Positioned(
            left: 155,
            top: 78,
            child:Container(
              width: 40,
              height: 15.0, // Adjust height as per your preference
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    children: [
                      for (int i = 0; i < 7; i++)
                        Positioned(
                            top: 0,
                            right: leftPipe == 1 ? _calculatePosition(i) : null,
                            left: rightPipe == 1 ? _calculatePosition(i) : null,
                            child: SizedBox(
                              width: 40,
                              height: 100,
                              child: CustomPaint(
                                painter: PipeWithRunningWaterInHorizontal(ctrlValue: 0),
                                size: const Size(100,15),
                              ),
                            )
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 90,
            top: 20,
            child: Container(
              width: 70,
              height: 80,
              child: Center(
                child: CustomPaint(
                  painter: filterPaint(mode: leftPipe == 1 ? 1 : null,),
                  size: const Size(70,80),
                ),
              ),
            ),
          ),
          Positioned(
            top: 22,
            left: 0,
            child: SizedBox(
              width: 30,
              height: 30,
              child: SvgPicture.asset(
                  'assets/images/notch.svg',
                  // colorFilter: ColorFilter.mode(Colors.blac, BlendMode.srcIn),
                  semanticsLabel: 'A red up arrow'
              ),
            ),
          ),
          Positioned(
            top: 52,
            left: 8,
            child: SizedBox(
              width: 15,
              height: 50,
              child: AnimatedPipeWidgetVertical(controller: _controller, reverse: true,)
            ),
          ),

        ],
      ),
    );
  }
}

class AnimatedPipeWidgetHorizontal extends StatelessWidget {
  final AnimationController controller;
  // final AnimationController controllerReverse;

  const AnimatedPipeWidgetHorizontal({
    Key? key,
    required this.controller,
    // required this.controllerReverse,
  }) : super(key: key);
  final double _speed = 100.0; // Speed of animation
  final double _gap = 99.0; // Gap between icons
  final double _initialPosition = -100;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 15.0, // Adjust height as per your preference
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: [
              for (int i = 0; i < 2; i++)
                Positioned(
                  top: 0,
                  left: _calculatePosition(i),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: PipeWithRunningWaterInHorizontal(ctrlValue: 0),
                      size: const Size(100, 15),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  double _calculatePosition(int index) {
    double basePosition = _initialPosition + (index * _gap);
    double animatedPosition = basePosition + (_speed * controller.value);
    return animatedPosition;
  }

}

class AnimatedPipeWidgetVertical extends StatelessWidget {
  final AnimationController controller;
  // final AnimationController controllerReverse;
  final double speed;
  final double gap;
  final double initialPosition;
  final bool reverse;

  const AnimatedPipeWidgetVertical({
    Key? key,
    required this.controller,
    // required this.controllerReverse,
    required this.reverse,
    this.speed = 100.0,
    this.gap = 99.0,
    this.initialPosition = -100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 180,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: [
              for (int i = 0; i < 3; i++)
                Positioned(
                  top: reverse == true ? _calculatePosition(i) : 0,
                  bottom: reverse == false ? _calculatePosition(i) : 0,
                  left: 0,
                  child: SizedBox(
                    width: 15,
                    height: 100,
                    child: CustomPaint(
                      painter: PipeWithRunningWaterInVertical(
                        ctrlValue: 0,
                      ),
                      size: const Size(15, 100),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _calculatePosition(int index) {
    double basePosition = initialPosition + (index * gap);
    double animatedPosition = basePosition + (speed * controller.value);
    return animatedPosition;
  }
}

class filterPaint extends CustomPainter{
  int? mode;
  filterPaint({this.mode});
  @override
  void paint(Canvas canvas, Size size) {
    List<Color> mode0 = [
      Color(0xff00580B),
      Color(0xff002D10)
    ];
    List<Color> mode1 = [
      Colors.brown.shade500,
      Colors.brown,
    ];
    List<Color> insideMode0 = [
      Color(0xff9DC3A7),
      Color(0xff9EB1A5)
    ];
    List<Color> insideMode1 = [
      Colors.grey,
      Colors.grey.shade500,
    ];
    Paint paint = Paint();
    paint.strokeWidth = 2.0;
    paint.style = PaintingStyle.fill;
    Rect filterBox = Rect.fromLTWH(0, 0, 70, 80);
    Rect filterInsideBox = Rect.fromLTWH(0, 0, 69, 77);
    Paint insideBox = Paint();
    insideBox.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        if(mode == null)
          ...insideMode0
        else
          ...insideMode1
      ],
    ).createShader(filterBox);
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        ...mode0
        // if(mode == null)
        //   ...mode0
        // else
        //   ...mode1

      ],
    ).createShader(filterBox);
    canvas.drawRRect(RRect.fromRectXY(filterBox, 40, 10), paint);
    canvas.drawRect(Rect.fromLTWH(-10, 10, 15, 15), paint);
    canvas.drawRect(Rect.fromLTWH(68, 58, 12, 15), paint);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromCenter(
                center: Offset(size.width/2,size.height/2),
                width: 69,
                height: 77
            ),
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25)),
        insideBox
    );
    Paint sandBackground = Paint();
    sandBackground.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 25, 70, 30), paint);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(20, -7, 30, 8),
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0)),
        paint
    );
    Paint sand = Paint();
    sand.color = Colors.brown.shade300;
    for(var line = 0;line < 10;line++){
      for(var i = 0;i < 23;i++){
        canvas.drawCircle(Offset(2+(i*3), 25 + (line * 3)), 1, sand);
      }
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}

class WaterTank extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    Paint land = Paint();
    Paint wall = Paint();
    wall.color = Colors.blueGrey;
    land.color = Colors.brown.shade300;
    canvas.drawRect(Rect.fromLTWH(0, 0, 30, 100), land);
    canvas.drawRect(Rect.fromLTWH(29.5, 0, 5, 80), wall);
    canvas.drawRect(Rect.fromLTWH(29.5, 80, 170.5, 20), land);
    canvas.drawRect(Rect.fromLTWH(29.5, 75.5, 170, 5), wall);
    canvas.drawRect(Rect.fromLTWH(170.5, 0, 30, 100), land);
    canvas.drawRect(Rect.fromLTWH(166.5, 0, 5, 81), wall);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}

class PipeWithRunningWaterInHorizontal extends CustomPainter {
  final double ctrlValue;
  final int? mode;

  PipeWithRunningWaterInHorizontal({required this.ctrlValue, this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    Paint normalBubbles = Paint()..color = mode == null ? Color(0xff156CB4) : Colors.black;
    Paint gradientBubbles = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff488BC2), Color(0xff020E39)],
      ).createShader(Rect.fromLTWH(0, 0, 100, 15));

    // Draw 10 bubbles
    for (int i = 0; i < 10; i++) {
      double x = 5 + i * 10.0;
      double y = 3 * (ctrlValue * (i + 1));
      double size = 3 + (i % 2 == 0 ? 1.0 : 0.5); // Adjust size alternately
      canvas.drawOval(Rect.fromLTWH(x, y, size, size), normalBubbles);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class PipeWithRunningWaterInVertical extends CustomPainter {
  final double ctrlValue;

  PipeWithRunningWaterInVertical({required this.ctrlValue});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Rect rect = Rect.fromLTWH(0, 0, 15, 100);
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xff8CD9FE),
        Color(0xff43D9FA),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    Paint normalBubbles = Paint()..color = Color(0xff156CB4);
    Paint gradientBubbles = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xff488BC2),
          Color(0xff020E39),
        ],
      ).createShader(Rect.fromLTWH(0, 0, 15, 100));

    // Draw 10 bubbles
    for (int i = 0; i < 10; i++) {
      double x = 3 * (ctrlValue * (i + 1));
      double y = 5 + i * 10.0;
      double size = 3 + (i % 2 == 0 ? 1.0 : 0.5); // Adjust size alternately
      canvas.drawOval(Rect.fromLTWH(x, y, size, size), normalBubbles);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Pump extends CustomPainter {
  final double rotationAngle;
  final int mode;

  Pump({required this.rotationAngle,required this.mode});

  List<Color> pipeColor = const [Color(0xff166890), Color(0xff45C9FA), Color(0xff166890)];
  List<Color> bodyColor = const [Color(0xffC7BEBE), Colors.white, Color(0xffC7BEBE)];
  List<Color> headColorOn = const [Color(0xff097E54), Color(0xff10E196), Color(0xff097E54)];
  List<Color> headColorOff = const [Color(0xff540000), Color(0xffB90000), Color(0xff540000)];
  List<Color> headColorFault = const [Color(0xffF66E21), Color(0xffFFA06B), Color(0xffF66E21)];
  List<Color> headColorIdle = [Colors.grey, Colors.grey.shade300, Colors.grey];

  List<Color> getMotorColor(){
    if(mode == 1){
      return headColorOn;
    }else if(mode == 2){
      return headColorOff;
    }else if(mode == 3){
      return headColorFault;
    }else{
      return headColorIdle;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {

    Paint motorHead = Paint();
    Radius headRadius = Radius.circular(5);
    motorHead.color = Color(0xff097B52);
    motorHead.style = PaintingStyle.fill;
    motorHead.shader = getLinearShaderHor(getMotorColor(),Rect.fromCenter(center: Offset(50,18), width: 35, height: 35));
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: Offset(50,20), width: 45, height: 40),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), motorHead);
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: Offset(50,20), width: 45, height: 40),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), motorHead);
    Paint line = Paint();
    line.color = Colors.white;
    line.strokeWidth = 1;
    line.style = PaintingStyle.fill;
    double startingPosition = 26;
    double lineGap = 8;
    for(var i = 0;i < 7;i++)
      canvas.drawLine(Offset(startingPosition+(i*lineGap), 5), Offset(startingPosition+(i*lineGap), 35), line);
    canvas.drawLine(Offset(28, 5), Offset(72, 5), line);
    canvas.drawLine(Offset(28, 35), Offset(72, 35), line);


    Paint neck = Paint();
    neck.shader = getLinearShaderHor(bodyColor,Rect.fromCenter(center: Offset(50,45), width: 20, height: 10));
    neck.strokeWidth = 0.5;
    neck.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(50,45 ), width: 20, height: 10), neck);

    Paint body = Paint();
    body.style = PaintingStyle.fill;
    body.shader = getLinearShaderHor(bodyColor,Rect.fromCenter(center: Offset(50,64), width: 35, height: 28));
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: Offset(50,64), width: 35, height: 28),topLeft: headRadius,topRight: headRadius,bottomRight: headRadius,bottomLeft: headRadius), body);

    Paint joint = Paint();
    joint.shader = getLinearShaderVert(bodyColor,Rect.fromCenter(center: Offset(30,64 ), width: 6, height: 15));
    joint.strokeWidth = 0.5;
    joint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(30,64 ), width: 6, height: 15), joint);
    canvas.drawRect(Rect.fromCenter(center: Offset(70,64 ), width: 6, height: 15), joint);

    Paint sholder1 = Paint();
    sholder1.shader = getLinearShaderVert(bodyColor,Rect.fromCenter(center: Offset(24,64 ), width: 6, height: 20));
    sholder1.strokeWidth = 0.5;
    sholder1.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(24,64 ), width: 6, height: 20), sholder1);
    canvas.drawRect(Rect.fromCenter(center: Offset(75,64 ), width: 6, height: 20), sholder1);

    Paint sholder2 = Paint();
    sholder2.shader = getLinearShaderVert(pipeColor,Rect.fromCenter(center: Offset(30,64), width: 6, height: 15));
    sholder2.strokeWidth = 0.5;
    sholder2.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(20,64 ), width: 6, height: 20), sholder2);
    canvas.drawRect(Rect.fromCenter(center: Offset(80,64 ), width: 6, height: 20), sholder2);

    Paint hand = Paint();
    hand.shader = getLinearShaderVert(pipeColor,Rect.fromCenter(center: Offset(30,64), width: 6, height: 15));
    hand.strokeWidth = 0.5;
    hand.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(10,64 ), width: 18, height: 15), hand);
    canvas.drawRect(Rect.fromCenter(center: Offset(90,64 ), width: 18 , height: 15), hand);

    Paint paint = Paint()..color = Colors.blueGrey;
    double centerX = 50;
    double centerY = 65;
    double radius = 8;
    double angle = (2 * pi) / 4; // Angle between each rectangle
    double rectangleWidth = 8;
    double rectangleHeight = 10;

    for (int i = 0; i < 4; i++) {
      double x = centerX + radius * cos(i * angle + rotationAngle/2);
      double y = centerY + radius * sin(i * angle + rotationAngle/2);
      double rotation = i * angle - pi / 2 + rotationAngle; // Rotate rectangles to fit the circle

      canvas.save(); // Save canvas state before rotation
      canvas.translate(x, y); // Translate to the position
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-rectangleWidth / 2, -rectangleHeight / 2, rectangleWidth, rectangleHeight),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(80),
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        paint,
      );
      canvas.restore(); // Restore canvas state after rotation
    }
    Paint smallCircle = Paint();
    smallCircle.color = Colors.black;
    smallCircle.style = PaintingStyle.fill;

    // Draw a small circle at the center
    canvas.drawCircle(Offset(centerX, centerY), 4, smallCircle);
  }

  dynamic getLinearShaderVert(List<Color> colors,Rect rect){
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    ).createShader(rect);
  }

  dynamic getLinearShaderHor(List<Color> colors,Rect rect){
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors,
    ).createShader(rect);
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}