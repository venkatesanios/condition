import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_view/Models/Customer/node_model.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/Fertilizer%20Dashboard/fertilizer_widget.dart';
import 'package:mobile_view/screens/customer/Planning/additionalinformation.dart';
import 'package:mobile_view/screens/customer/Planning/weather_report.dart';
import 'package:provider/provider.dart';
import '../../../ListOfFertilizerInSet.dart';
import '../../../Models/weather_model.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../../../state_management/overall_use.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
// import 'package:pretty_gauge/pretty_gauge.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen(
      {Key? key,
        required this.userId,
        required this.controllerId,
        this.deviceID});
  final userId, controllerId, deviceID;
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  //  0aa7f59482130e8e8384ae8270d79097 // API KEY
  // final WeatherService weatherService = WeatherService();
  Map<String, dynamic> weatherData = {};
  late Timer _timer;
  late DateTime _currentTime;
  late MqttPayloadProvider _mqttPayloadProvider;
  String sunrise = '06:00 AM';
  String sunset = '06:00 PM';
  String daylight = 'Day Light Length: 12:00:00';
  int tabclickindex = 0;
  WeatherModel weatherModelinstance = WeatherModel();
  bool isLoading = false;
  String lastSyncTime = "0";
  String sunriseTime = 'Loading';
  String sunsetTime = "Loading";
  String lastTime = "0";

  @override
  void initState() {
    _currentTime = DateTime.now();
    _startTimer();
    super.initState();
    Request();
    fetchSunriseSunset();
    fetchDatalive();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> fetchSunriseSunset() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        Uri.parse('https://api.sunrisesunset.io/json?lat=11.0168&lng=77.9558'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        sunriseTime = data['results']['sunrise'];
        sunsetTime = data['results']['sunset'];
        lastTime = DateTime.now().toLocal().toString();
        isLoading = false;
      });
    } else {
      setState(() {
        sunriseTime = 'Error';
        sunsetTime = 'Error';
        isLoading = false;
      });
    }
  }

  Future<void> fetchDatalive() async {
    // _watersource = Watersource.fromJson(json);
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    // print('body-------------$body');
    final response =
    await HttpService().postRequest("getUserWeatherLive", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata = jsonDecode(response.body);
        if (jsondata['code'] == 200) {
          Map<String, dynamic> payLoadFinal = {
            "5100": [
              {"5101": jsondata['data']},
            ]
          };
          _mqttPayloadProvider.updatehttpweather(payLoadFinal);
        }
        // print("----Live data"
        //     "----");
        // print('-----$jsondata');
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  //assets/images/rain1.gif
  Future<void> _refresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchDatalive();
    await fetchSunriseSunset();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    if (weatherData.isNotEmpty && (weatherData != null)) {
      sunrise = '${weatherData['results']['sunrise']}';
      sunset = '${weatherData['results']['sunset']}';
      daylight = 'Day Light Length: ${weatherData['results']['day_length']}';
    }
    if (_mqttPayloadProvider.weatherModelinstance.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_mqttPayloadProvider.weatherModelinstance.data!.isEmpty) {
      return const Center(child: Text('Currently No Weather Data Available'));
    } else if (_mqttPayloadProvider.weatherModelinstance.data![0] == null ||
        _mqttPayloadProvider
            .weatherModelinstance.data![0].WeatherSensorlist!.isEmpty) {
      return const Center(child: Text('Currently No Weather Data Available'));
    } else {
      return DefaultTabController(
        length: _mqttPayloadProvider
            .weatherModelinstance.data![0].WeatherSensorlist!.length,
        child: Scaffold(
          // appBar: AppBar(title: Text('Weather Station'),),
          body: Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                children: [
                  Container(
                    height: 65,
                    child: TabBar(
                      // controller: _tabController,
                      indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                      isScrollable: true,
                      unselectedLabelColor: Colors.grey,
                      labelColor: myTheme.primaryColor,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        for (var i = 0;
                        i <
                            _mqttPayloadProvider.weatherModelinstance
                                .data![0].WeatherSensorlist!.length;
                        i++)
                          Tab(
                            text: 'Weather Station  ${i + 1}',
                          ),
                      ],
                      onTap: (value) {
                        setState(() {
                          tabclickindex = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: TabBarView(children: [
                        for (var i = 0;
                        i <
                            _mqttPayloadProvider.weatherModelinstance
                                .data![0].WeatherSensorlist!.length;
                        i++)
                          buildTab(i)
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  changeval(int Selectindexrow) {}
  Widget buildTab(int i) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });
            await Future.delayed(const Duration(
              seconds: 0,
            ));
            await fetchDatalive();
            fetchSunriseSunset();
            setState(() {
              isLoading = false;
            });
          },
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/images1/Sunrise1.png",
                                    height: 110,
                                    width: 50,
                                  ),
                                  Text(
                                    sunriseTime,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 3.0,
                                            color: Colors.grey
                                                .withOpacity(0.5),
                                          ),
                                        ]),
                                  ),
                                  Text(
                                    "SunRise",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 3.0,
                                            color: Colors.grey
                                                .withOpacity(0.5),
                                          ),
                                        ]),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                                width: 30,
                              ),
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/images1/Sunrise.png",
                                    height: 140,
                                    width: 150,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "temperature°C",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black54,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 3.0,
                                            color: Colors.grey
                                                .withOpacity(0.5),
                                          ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    "assets/images1/sunset.png",
                                    height: 110,
                                    width: 60,
                                  ),
                                  Text(
                                    sunsetTime,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 3.0,
                                            color: Colors.grey
                                                .withOpacity(0.5),
                                          ),
                                        ]),
                                  ),
                                  Text(
                                    "SunSet",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 3.0,
                                            color: Colors.grey
                                                .withOpacity(0.5),
                                          ),
                                        ]),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.black54, // Start color
                          // Colors.orange,
                          Colors.black // End color
                        ],
                        begin: Alignment.topRight, // Start direction
                        end: Alignment.bottomRight, // End direction
                      ).createShader(Rect.fromLTWH(
                          0, 0, bounds.width, bounds.height)),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text(
                          "Last SyncTime : ${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].time} ",
                          //  ${_mqttPayloadProvider.weatherModel instance.data![0].WeatherSensor list![i].date
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 0.2,
                                  color: Colors.black54.withOpacity(0.1),
                                ),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.black, // Start color
                              Colors.black38, // End color
                            ],
                            begin: Alignment.topRight, // Start direction
                            end: Alignment.bottomRight, // End direction
                          ).createShader(Rect.fromLTWH(
                              0, 0, bounds.width, bounds.height)),
                          child: Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Text(
                              "Weather Sensors",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 3,
                                letterSpacing: 2.5,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        for (var index = 0;
                        index <
                            _mqttPayloadProvider
                                .weatherModelinstance
                                .data![0]
                                .WeatherSensorlist![0]
                                .sensorlist!
                                .length;
                        index++)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Set your desired borderRadius here

                              child: GestureDetector(
                                onDoubleTap: () {
                                  if (_mqttPayloadProvider
                                      .weatherModelinstance
                                      .data![0]
                                      .WeatherSensorlist![i]
                                      .sensorlist[index] !=
                                      'WindDirection') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReportPage(
                                            initialReportType:
                                            "${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].sensorlist[index]}"),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: customBoxShadow,
                                    color: Getcolor(cardValues(
                                        _mqttPayloadProvider
                                            .weatherModelinstance
                                            .data![0]
                                            .WeatherSensorlist![i]
                                            .sensorlist[index],
                                        i)),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceEvenly,
                                          children: [
                                            AdditionalInformation(
                                              assetImage: GetImage(
                                                  '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![0].sensorlist[index]}'),
                                              label:
                                              '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![0].sensorlist[index]}',
                                              value:
                                              '${cardValues(_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].sensorlist[index], i)} ${cardValuesunits(_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].sensorlist[index])}',
                                              Max:
                                              '00/00',
                                              Min:"00/00"
                                                  ""),
                                            Container(
                                              height: 140,
                                              margin: EdgeInsets.fromLTRB(
                                                  5, 0, 5, 5.0),
                                              child: SizedBox(
                                                height: 120,
                                                width: 80,
                                                child: '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![0].sensorlist[index]}' !=
                                                    'WindDirection'
                                                    ? animatedGaugeWidget(
                                                    0,
                                                    gaugemax(_mqttPayloadProvider
                                                        .weatherModelinstance
                                                        .data![0]
                                                        .WeatherSensorlist![
                                                    0]
                                                        .sensorlist[
                                                    index]),
                                                    cardValues(
                                                        _mqttPayloadProvider
                                                            .weatherModelinstance
                                                            .data![0]
                                                            .WeatherSensorlist![
                                                        0]
                                                            .sensorlist[index],
                                                        i))
                                                    : SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _mqttPayloadProvider
                                          .weatherModelinstance
                                          .data![0]
                                          .WeatherSensorlist![0]
                                          .sensorlist[index] ==
                                          "WindDirection"
                                          ? SizedBox()
                                          : SizedBox(
                                        height: 55,
                                        child: Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(
                                              200,
                                              0.0,
                                              0,
                                              27.0),
                                          child: Container(
                                            decoration:
                                            BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                10.0,
                                              ),
                                              color: getValueColor(
                                                  cardValues(
                                                      _mqttPayloadProvider
                                                          .weatherModelinstance
                                                          .data![0]
                                                          .WeatherSensorlist![
                                                      0]
                                                          .sensorlist[
                                                      index],
                                                      i),
                                                  gaugemax(_mqttPayloadProvider
                                                      .weatherModelinstance
                                                      .data![0]
                                                      .WeatherSensorlist![
                                                  0]
                                                      .sensorlist[index])),
                                              boxShadow: [
                                                BoxShadow(
                                                    color:
                                                    Colors.grey,
                                                    spreadRadius:
                                                    0.2,
                                                    blurRadius: 0.2,
                                                    blurStyle:
                                                    BlurStyle
                                                        .outer,
                                                    offset: Offset
                                                        .infinite),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets
                                                  .fromLTRB(15, 3.0,
                                                  15, 5.0),
                                              child: Text(
                                                GetTextStaus(
                                                    cardValues(
                                                        _mqttPayloadProvider
                                                            .weatherModelinstance
                                                            .data![
                                                        0]
                                                            .WeatherSensorlist![
                                                        0]
                                                            .sensorlist[
                                                        index],
                                                        i),
                                                    _mqttPayloadProvider
                                                        .weatherModelinstance
                                                        .data![0]
                                                        .WeatherSensorlist![
                                                    0]
                                                        .sensorlist[index]),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:
                                                  Colors.white,
                                                  letterSpacing:
                                                  1.2,
                                                  height: 0.0,
                                                  shadows: [
                                                    Shadow(
                                                      offset:
                                                      Offset(
                                                          0.1,
                                                          0.0),
                                                      color: Colors
                                                          .grey,
                                                      blurRadius:
                                                      0.5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getValueColor(String value, double max) {
    double doubleValue = double.parse(value);
    // print('doubleValue-->$doubleValue');
    // print('max-------->$max');

    if (doubleValue <= (30 / 100) * max) {
      return Colors.orange; // Low value
    } else if (doubleValue > (30 / 100) * max &&
        doubleValue <= (60 / 100) * max) {
      return Colors.green; // Medium value
    } else {
      return Colors.red; // High value
    }
  }

  Widget animatedGaugeWidget(double min, double max, String value) {
    double doubleValue = double.parse(value);
    Color getValueColor(double value) {
      if (value <= (30 / 100) * max) {
        return Colors.orange; // Low value
      } else if (value > (30 / 100) * max && value <= (60 / 100) * max) {
        return Colors.green; // Medium value
      } else {
        return Colors.red; // High value
      }
    }

    return AnimatedRadialGauge(
      duration: Duration(seconds: 5),
      value: doubleValue,
      //curve: Curves.elasticIn,
      axis: GaugeAxis(
        max: max,
        min: min,
        degrees: 250,
        style: const GaugeAxisStyle(
          thickness: 10,
        ),
        pointer: GaugePointer.triangle(
            width: 10,
            height: 22,
            color: Colors.black,
            // borderRadius: 3.0,
            position: GaugePointerPosition.surface()),
        progressBar: GaugeProgressBar.rounded(
          // color: Colors.orange,
          gradient: GaugeAxisGradient(colors: [
            Colors.green,
            Colors.amber,
            Color(0xFFE63B86),
            Colors.redAccent
          ], colorStops: [
            0.17,
            0.40,
            1.4,
            2.0
          ]),
        ),
        segments: [
          GaugeSegment(
              from: 0,
              to: (30 / 100) * max,
              // color: Colors.amberAccent,
              cornerRadius: Radius.circular(2.0)),
          GaugeSegment(
              from: (30 / 100) * max,
              to: (60 / 100) * max,
              // color: Colors.green,
              cornerRadius: Radius.zero),
          GaugeSegment(
            from: (60 / 100) * max,
            to: (100 / 100) * max,
            // color: Colors.red,
            cornerRadius: Radius.zero,
          ),
        ],
      ),
      builder: (context, child, value) => RadialGaugeLabel(
        value: value,
        style: TextStyle(
          color: getValueColor(doubleValue),
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String GetTextStaus(String valuestr, String title) {
    double value = double.parse(valuestr);
    if (title == 'SoilMoisture1') {
      if (value <= 100) return "Dry";
      if (value > 100 && value <= 200) return "Latchy";
      return "Wet";
    } else if (title == 'SoilMoisture2') {
      if (value <= 100) return "Dry";
      if (value > 100 && value <= 200) return "Latchy";
      return "Wet";
    } else if (title == 'SoilMoisture3') {
      if (value <= 100) return "Dry";
      if (value > 100 && value <= 200) return "Latchy";
      return "Wet";
    } else if (title == 'SoilMoisture4') {
      if (value <= 100) return "Dry";
      if (value > 100 && value <= 200) return "Latchy";
      return "Wet";
    } else if (title == 'SoilTemperature') {
      if (value < 30) return "Cool";
      if (value > 30 && value < 70) return "Moderate";
      return "Hot";
    } else if (title == 'Temperature') {
      if (value < 30) return "Cool";
      if (value > 30 && value < 70) return "Moderate";
      return "Hot";
    } else if (title == 'AtmospherePressure') {
      if (value < 30) return "Low";
      if (value > 30 && value < 70) return "Normal";
      return "High";
    } else if (title == 'Humidity') {
      if (value < 30) return "Dry";
      if (value > 30 && value < 70) return "Comfortable";
      return "Humid";
    } else if (title == 'LeafWetness') {
      if (value < 30) return "Dry";
      if (value > 30 && value < 70) return "Moist";
      return "Wet";
    } else if (title == 'Co2') {
      if (value < 300) return "Fresh";
      if (value > 300 && value < 800) return "Normal";
      return "Elevated";
    } else if (title == 'LDR') {
      if (value < 3) return "Dark";
      if (value > 3 && value < 7) return "PartialLight";
      return "FullLight";
    } else if (title == 'Lux') {
      if (value < 3) return "Dim";
      if (value > 3 && value < 7) return "Normal";
      return "Bright";
    } else if (title == 'WindDirection') {
      return 'eeee';
    } else if (title == 'Rainfall') {
      if (value < 20) return "Low";
      if (value > 20 && value < 80) return "Medium";
      return "High";
    } else if (title == 'WindSpeed') {
      if (value < 30) return "calm";
      if (value > 30 && value < 70) return "Breezy";
      return "Gusty";
    } else {
      return " ";
    }
  }

  String GetImage(String title) {
    String imageAsserStr = '';
    if (title == 'SoilMoisture1') {
      imageAsserStr = 'assets/images1/SoilMoisture.png';
    } else if (title == 'SoilMoisture2') {
      imageAsserStr = 'assets/images1/SoilMoisture.png';
    } else if (title == 'SoilMoisture3') {
      imageAsserStr = 'assets/images1/SoilMoisture.png';
    } else if (title == 'SoilMoisture4') {
      imageAsserStr = 'assets/images1/SoilMoisture.png';
    } else if (title == 'SoilTemperature') {
      imageAsserStr = 'assets/images1/SoilTemp .png';
    } else if (title == 'Temperature') {
      imageAsserStr = 'assets/images1/Temperature.png';
    } else if (title == 'AtmospherePressure') {
      imageAsserStr = 'assets/images1/pressure.png';
    } else if (title == 'Humidity') {
      imageAsserStr = 'assets/images1/humidity.png';
    } else if (title == 'LeafWetness') {
      imageAsserStr = 'assets/images1/leafWetness.png';
    } else if (title == 'Co2') {
      imageAsserStr = 'assets/images1/CO-2.png';
    } else if (title == 'LDR') {
      imageAsserStr = 'assets/images1/LDR.png';
    } else if (title == 'Lux') {
      imageAsserStr = 'assets/images1/Lux.png';
    } else if (title == 'WindDirection') {
      imageAsserStr = 'assets/images1/windDirection.png';
    } else if (title == 'Rainfall') {
      imageAsserStr = 'assets/images1/rainFall.png';
    } else if (title == 'WindSpeed') {
      imageAsserStr = 'assets/images1/WindSpeed.png';
    } else {
      imageAsserStr = '';
    }
    return imageAsserStr;
  }

  Color Getcolor(String val) {
    if (val == '1') {
      return Colors.red.shade100;
    } else if (val == '2') {
      return Colors.yellow.shade100;
    } else if (val == '3') {
      return Colors.orange.shade100;
    } else {
      return Colors.white70;
    }
  }

  String cardValues(String checkstr, int i) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    switch (checkstr) {
      case 'SoilMoisture1':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture1}';
      case 'SoilMoisture2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture2}';
      case 'SoilMoisture3':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture3}';
      case 'SoilMoisture4':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture4}';
      case 'SoilTemperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilTemperature}';
      case 'Humidity':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].humidity}';
      case 'Temperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].temperature}';
      case 'AtmospherePressure':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].atmospherePressure}';
      case 'Co2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].co2}';
      case 'LDR':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].ldr}';
      case 'Lux':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].lux}';
      case 'WindDirection':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windDirection}';
      case 'WindSpeed':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windSpeed}';
      case 'Rainfall':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].rainfall}';
      case 'LeafWetness':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].leafWetness}';
      default:
        return '0.0';
    }
  }

  String MaxValues(String checkstr, int i) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    switch (checkstr) {
      case 'SoilMoisture1':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture1Max}';
      case 'SoilMoisture2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture2Max}';
      case 'SoilMoisture3':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture3Max}';
      case 'SoilMoisture4':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture4Max}';
      case 'SoilTemperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilTemperatureMax}';
      case 'Humidity':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].humidityMax}';
      case 'Temperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].temperatureMax}';
      case 'AtmospherePressure':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].atmospherePressureMax}';
      case 'Co2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].co2Max}';
      case 'LDR':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].ldrMax}';
      case 'Lux':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].luxMax}';
      case 'WindDirection':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windDirectionMax}';
      case 'WindSpeed':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windSpeedMax}';
      case 'Rainfall':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].rainfallMax}';
      case 'LeafWetness':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].leafWetnessMax}';
      default:
        return '0';
    }
  }

  String MinValues(String checkstr, int i) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    switch (checkstr) {
      case 'SoilMoisture1':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture1Min}';
      case 'SoilMoisture2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture2Min}';
      case 'SoilMoisture3':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture3Min}';
      case 'SoilMoisture4':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture4Min}';
      case 'SoilTemperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilTemperatureMin}';
      case 'Humidity':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].humidityMin}';
      case 'Temperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].temperatureMin}';
      case 'AtmospherePressure':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].atmospherePressureMin}';
      case 'Co2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].co2Min}';
      case 'LDR':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].ldrMin}';
      case 'Lux':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].luxMin}';
      case 'WindDirection':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windDirectionMin}';
      case 'WindSpeed':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windSpeedMin}';
      case 'Rainfall':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].rainfallMin}';
      case 'LeafWetness':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].leafWetnessMin}';
      default:
        return '0';
    }
  }

  String MinTimeValues(String checkstr, int i) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    switch (checkstr) {
      case 'SoilMoisture1':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture1MinTime}';
      case 'SoilMoisture2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture2MinTime}';
      case 'SoilMoisture3':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture3MinTime}';
      case 'SoilMoisture4':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture4MinTime}';
      case 'SoilTemperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilTemperatureMinTime}';
      case 'Humidity':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].humidityMinTime}';
      case 'Temperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].temperatureMinTime}';
      case 'AtmospherePressure':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].atmospherePressureMinTime}';
      case 'Co2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].co2MinTime}';
      case 'LDR':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].ldrMinTime}';
      case 'Lux':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].luxMinTime}';
      case 'WindDirection':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windDirectionMinTime}';
      case 'WindSpeed':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windSpeedMinTime}';
      case 'Rainfall':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].rainfallMinTime}';
      case 'LeafWetness':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].leafWetnessMinTime}';
      default:
        return '0';
    }
  }

  String MaxTimeValues(String checkstr, int i) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    switch (checkstr) {
      case 'SoilMoisture1':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture1MaxTime}';
      case 'SoilMoisture2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture2MaxTime}';
      case 'SoilMoisture3':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture3MaxTime}';
      case 'SoilMoisture4':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture4MaxTime}';
      case 'SoilTemperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilTemperatureMaxTime}';
      case 'Humidity':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].humidityMaxTime}';
      case 'Temperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].temperatureMaxTime}';
      case 'AtmospherePressure':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].atmospherePressureMaxTime}';
      case 'Co2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].co2MaxTime}';
      case 'LDR':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].ldrMaxTime}';
      case 'Lux':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].luxMaxTime}';
      case 'WindDirection':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windDirectionMaxTime}';
      case 'WindSpeed':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windSpeedMaxTime}';
      case 'Rainfall':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].rainfallMaxTime}';
      case 'LeafWetness':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].leafWetnessMaxTime}';
      default:
        return '0';
    }
  }

  String cardValuesunits(String checkStr) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    switch (checkStr) {
      case 'SoilMoisture1':
        return 'CB';
      case 'SoilMoisture2':
        return 'CB';
      case 'SoilMoisture3':
        return 'CB';
      case 'SoilMoisture4':
        return 'CB';
      case 'SoilTemperature':
        return '°C';
      case 'Humidity':
        return '%';
      case 'Temperature':
        return '°C';
      case 'AtmospherePressure':
        return 'kpa';
      case 'Co2':
        return 'ppm';
      case 'LDR':
        return 'ldr';
      case 'Lux':
        return 'lx';
      case 'WindDirection':
        return '';
      case 'WindSpeed':
        return 'km/h';
      case 'Rainfall':
        return 'MM';
      case 'LeafWetness':
        return '%';
      default:
        return '';
    }
  }

  double gaugemax(String checkStr) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    switch (checkStr) {
      case 'SoilMoisture1':
        return 250.0;
      case 'SoilMoisture2':
        return 250.0;
      case 'SoilMoisture3':
        return 250.0;
      case 'SoilMoisture4':
        return 250.0;
      case 'SoilTemperature':
        return 100.0;
      case 'Humidity':
        return 100.0;
      case 'Temperature':
        return 100.0;
      case 'AtmospherePressure':
        return 100.0;
      case 'Co2':
        return 900.0;
      case 'LDR':
        return 5.0;
      case 'Lux':
        return 100.0;
      case 'WindDirection':
        return 0.0;
      case 'WindSpeed':
        return 10.0;
      case 'Rainfall':
        return 200.0;
      case 'LeafWetness':
        return 100.0;
      default:
        return 0.0;
    }
  }

  static String degreeToDirection(String degreestr) {
    // print('degreestr$degreestr');
    //  String cleanedString = degreestr.replaceAll('º', '').trim();
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

  String cardErrValues(String checkstr, int i) {
    _mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    switch (checkstr) {
      case 'SoilMoisture1':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture1Err}';
      case 'SoilMoisture2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture2Err}';
      case 'SoilMoisture3':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture3Err}';
      case 'SoilMoisture4':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilMoisture4Err}';
      case 'SoilTemperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].soilTemperatureErr}';
      case 'Humidity':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].humidityErr}';
      case 'Temperature':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].temperatureErr}';
      case 'AtmospherePressure':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].atmospherePressureErr}';
      case 'Co2':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].co2Err}';
      case 'LDR':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].ldrErr}';
      case 'Lux':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].luxErr}';
      case 'WindDirection':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windDirectionErr}';
      case 'WindSpeed':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].windSpeedErr}';
      case 'Rainfall':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].rainfallErr}';
      case 'LeafWetness':
        return '${_mqttPayloadProvider.weatherModelinstance.data![0].WeatherSensorlist![i].leafWetnessErr}';
      default:
        return '0';
    }

    return 'fontSize';
  }

  Request() {
    String payLoadFinal = jsonEncode({
      "5000": [
        {"5001": ""},
      ]
    });
    // MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
  }
// TODO: implement widget
}
