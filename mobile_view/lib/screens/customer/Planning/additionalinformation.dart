import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class AdditionalInformation extends StatelessWidget {
  final String label;
  final String value;
  final String assetImage;
  final String Max;
  final String Min;

  const AdditionalInformation(
      {super.key,
        required this.label,
        required this.value,
        required this.assetImage,
        required this.Max,
        required this.Min});

  static String degreeToDirection(String degreestr) {
    print('degreestr$degreestr');
    String cleanedString = degreestr.replaceAll('º', '').trim();
    double degree = double.parse(degreestr);
    if ((degree >= 337.5 && degree <= 360) ||
        (degree >= 0.0 && degree < 22.5)) {
      return 'North';
    } else if (degree >= 22.5 && degree < 67.5) {
      return 'NorthEast';
    } else if (degree >= 67.5 && degree < 112.5) {
      return 'East';
    } else if (degree >= 112.5 && degree < 157.5) {
      return 'SouthEast';
    } else if (degree >= 157.5 && degree < 202.5) {
      return 'South';
    } else if (degree >= 202.5 && degree < 247.5) {
      return 'SouthWest';
    } else if (degree >= 247.5 && degree < 292.5) {
      return 'West';
    } else if (degree >= 292.5 && degree < 337.5) {
      return 'NorthWest';
    } else {
      return degreestr;
    }
  }

  void handleAxisLabelCreated(AxisLabelCreatedArgs args) {
    if (args.text == '90') {
      args.text = 'E';
      args.labelStyle = const GaugeTextStyle(
        color: Color(0xFFDF5F2D),
        fontSize: 10,
      );
    } // Gauge TextStyle
    else if (args.text == '360') {
      args.text = '';
    } else {
      if (args.text == '0') {
        args.text = 'N';
      } else if (args.text == '180') {
        args.text = 'S';
      } else if (args.text == '270') {
        args.text = 'W';
      }
      args.labelStyle =
      const GaugeTextStyle(color: Color(0xFFFFFFFF), fontSize: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            label != "WindDirection"
                ? Image.asset(
              assetImage,
              width: 75,
              height: 80,
              fit: BoxFit.scaleDown,
            )
                : Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5)),
                  child: SfRadialGauge(
                      backgroundColor: Colors.teal.shade50,
                      enableLoadingAnimation: true,
                      animationDuration: 1000,
                      axes: <RadialAxis>[
                        RadialAxis(
                            backgroundImage:
                            AssetImage('assets/weather/compass.png'),
                            radiusFactor: 1,
                            canRotateLabels: true,
                            offsetUnit: GaugeSizeUnit.factor,
                            onLabelCreated: handleAxisLabelCreated,
                            startAngle: 270,
                            endAngle: 270,
                            maximum: 360,
                            interval: 30,
                            minorTicksPerInterval: 4,
                            showAxisLine: false,
                            showFirstLabel: false,
                            showLastLabel: false,
                            showLabels: false,
                            canScaleToFit: false,
                            showTicks: false,
                            minimum: 0,
                            ranges: <GaugeRange>[],
                            pointers: <GaugePointer>[
                              MarkerPointer(
                                value: double.parse(value),
                                color: Colors.redAccent,
                                enableAnimation: true,
                                animationDuration: 1200,
                                markerOffset: 0.62,
                                offsetUnit: GaugeSizeUnit.factor,
                                markerType: MarkerType.triangle,
                                markerHeight: 30,
                                markerWidth: 5,
                              ),
                              MarkerPointer(
                                value: double.parse(value) < 180
                                    ? double.parse(value) + 180
                                    : double.parse(value) - 180,
                                color: Colors.grey,
                                enableAnimation: true,
                                animationDuration: 1200,
                                markerOffset: 0.60,
                                offsetUnit: GaugeSizeUnit.factor,
                                markerType: MarkerType.triangle,
                                markerHeight: 30,
                                markerWidth: 5,
                              )
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  widget: Container(
                                      child: Text(degreeToDirection(value),
                                          style: const TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold))),
                                  angle: 90,
                                  positionFactor: 1.8)
                            ]),
                      ])),
            ),
            const SizedBox(
              height: 15,
            ),
            label != "WindDirection"
                ? Text(
              "Max : $Max",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
                : Text(''),
            const SizedBox(
              height: 3,
            ),
            label != "WindDirection"
                ? Text(
              "Min :  $Min",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
                : Text(''),
          ],
        ),
        const SizedBox(
          width: 25,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 0, 65.0),
          child: Column(
            children: [
              Text(
                label == "AtmospherePressure" ? "AirPressure" : label,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
                width: 0,
              ),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent),
              )
            ],
          ),
        ),
        SizedBox(
          width: 00,
        ),
      ],
    );
  }
}
