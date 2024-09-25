import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_view/screens/config/constant/general_in_constant.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../constants/theme.dart';
import '../state_management/irrigation_program_main_provider.dart';
import '../state_management/overall_use.dart';

class HoursMinutesSeconds extends StatefulWidget {
  final String initialTime;
  String? validation;
  String? waterTime;
  String? preTime;
  String? postTime;
  int? index;
  Map<String,dynamic>? fertilizerTime;
  void Function()? onPressed;
  HoursMinutesSeconds({
    super.key, required this.initialTime,this.validation,this.waterTime,this.preTime,this.postTime,this.onPressed,this.fertilizerTime,this.index
  });
  @override
  State<HoursMinutesSeconds> createState() => _HoursMinutesSecondsState();
}

class _HoursMinutesSecondsState extends State<HoursMinutesSeconds> {
  int selected = 0;
  bool releaseTimeForPrePost = true;
  bool releaseTimeForWater = true;
  bool releaseTimeForFertilizer = true;
  bool viewWidget = false;
  String message = '';
  bool keyBoardMode = false;
  List<List<String>> hrs = [['00','12'],['02','14'],['04','16'],['06','18'],['08','20'],['10','22']];
  List<List<String>> mins = [['00','30'],['05','35'],['10','40'],['15','45'],['20','50'],['25','55']];
  List<List<String>> secs = [['00','30'],['05','35'],['10','40'],['15','45'],['20','50'],['25','55']];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
        overAllPvd.editTime('hrs', double.parse(widget.initialTime.split(':')[0]).toInt());
        overAllPvd.editTime('min', double.parse(widget.initialTime.split(':')[1]).toInt());
        overAllPvd.editTime('sec', double.parse(widget.initialTime.split(':')[2]).toInt());
        print('hr : ${overAllPvd.hrs}');
        print('initialTime : ${widget.initialTime}');
      });
    }
  }

  int parseTimeString(String timeString) {
    List<String> parts = timeString.split(':');
    int totalSeconds = ((int.parse(parts[0]) * 3600) + (int.parse(parts[1]) * 60) + (int.parse(parts[2])));
    return totalSeconds;
  }

  void checkCondition(OverAllUse overAllPvd){
    int duration1 = 0;
    int duration2 = 0;
    int duration3 = 0;
    List<int> fertilizer = [];
    for(var i = 0;i < widget.fertilizerTime!['list'].length;i++){
      fertilizer.add(parseTimeString(widget.fertilizerTime!['list'][i]));
    }
    if(widget.validation == 'pre'){
      duration1 = parseTimeString(widget.waterTime!);
      duration2 = parseTimeString(widget.postTime!);
      duration3 = parseTimeString('${overAllPvd.hrs!}:${overAllPvd.min!}:${overAllPvd.sec!}');
    }else{
      duration1 = parseTimeString(widget.waterTime!);
      duration2 = parseTimeString(widget.preTime!);
      duration3 = parseTimeString('${overAllPvd.hrs!}:${overAllPvd.min!}:${overAllPvd.sec!}');
    }
    var result = duration1 - (duration2 + duration3);
    print(result);
    if(result > 0 || result == 0){
      setState(() {
        releaseTimeForPrePost = true;
      });
    }else{
      setState(() {
        releaseTimeForPrePost = false;
        message = '(Pre + Post)value should less than water value';
      });
    }
    for(var i = 0;i < fertilizer.length;i++){
      if(fertilizer[i] != 0){
        if(result < fertilizer[i]){
          setState(() {
            releaseTimeForPrePost = false;
            message = 'Mismatching channel - ${i+1} with duration between pre+post';
          });
        }
      }

    }
  }
  void checkCondition1(overAllPvd){
    int water = parseTimeString('${overAllPvd.hrs!}:${overAllPvd.min!}:${overAllPvd.sec!}');
    int pre = parseTimeString(widget.preTime!);
    int post = parseTimeString(widget.postTime!);
    List<int> fertilizer = [];
    bool condition_1 = false;
    for(var i = 0;i < widget.fertilizerTime!['list'].length;i++){
      fertilizer.add(parseTimeString(widget.fertilizerTime!['list'][i]));
    }
    var result = water - (pre + post);
    if(result > 0 || result == 0){
      setState(() {
        releaseTimeForWater = true;
      });
    }else{
      setState(() {
        releaseTimeForWater = false;
        condition_1 = true;
        message = 'water value should be more than (Pre + Post)value';
      });
    }
    if(condition_1 == false){
      for(var i = 0;i < fertilizer.length;i++){
        if(fertilizer[i] != 0){
          if(result < fertilizer[i]){
            setState(() {
              releaseTimeForWater = false;
              message = 'Water duration must be more than channel - ${i+1} duration';
            });
          }
        }
      }
    }
  }
  void checkCondition2(overAllPvd){
    int water = parseTimeString(widget.waterTime!);
    int pre = parseTimeString(widget.preTime!);
    int post = parseTimeString(widget.postTime!);
    int fertilizer = parseTimeString('${overAllPvd.hrs!}:${overAllPvd.min!}:${overAllPvd.sec!}');
    var result = water - (pre + post);
    print('result  : $result');
    if(fertilizer < result || fertilizer == result){
      setState(() {
        releaseTimeForFertilizer = true;
      });
    }else{
      setState(() {
        releaseTimeForFertilizer = false;
        message = 'Fertilizer should be given between pre time and post time';
      });
    }
    print('releaseTimeForFertilizer : $releaseTimeForFertilizer');
  }

  String message1(){
    if(widget.validation == 'water'){
      return 'water value should be more than (Pre + Post)value';
    }else if(widget.validation == 'pre' || widget.validation == 'post'){
      return '(Pre + Post)value should less than water value';
    }else if(widget.validation!.contains('fertilizer')){
      return 'Fertilizer should be given between pre time and post time';
    }else{
      return '';
    }
  }

  // You can change this to the desired number
  @override
  Widget build(BuildContext context) {
    final programPvd = Provider.of<IrrigationProgramMainProvider>(context);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(releaseTimeForPrePost == false || releaseTimeForWater == false || releaseTimeForFertilizer == false)
            Row(
              children: [
                SizedBox(
                    width: 205,
                    child: Center(child: Text(message,style: TextStyle(fontSize: 15,color: Colors.red),))),
                SizedBox(width: 5,),
                IconButton(
                    onPressed: (){
                      setState(() {
                        viewWidget = !viewWidget;
                      });
                    },
                    icon: Icon(viewWidget == false ? Icons.visibility : Icons.visibility_off)
                )
              ],
            ),
          SizedBox(height: 10,),
          if(viewWidget == false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      selected = 0;
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 60,
                    decoration: BoxDecoration(
                        color: selected == 0 ? myTheme.primaryColor : myTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Text('${overAllPvd.hrs} Hr',style: TextStyle(fontSize: 18,color: selected == 0 ? Colors.white : Colors.black),),
                    ),
                  ),
                ),
                const Text(':',style: TextStyle(fontSize: 20),),
                InkWell(
                  onTap: (){
                    setState(() {
                      selected = 1;
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 60,
                    decoration: BoxDecoration(
                        color: selected == 1 ?  myTheme.primaryColor : myTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Text('${overAllPvd.min} Min',style: TextStyle(fontSize: 18,color: selected == 1 ? Colors.white : Colors.black)),
                    ),
                  ),
                ),
                const Text(':',style: TextStyle(fontSize: 20),),
                InkWell(
                  onTap: (){
                    setState(() {
                      selected = 2;
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 60,
                    decoration: BoxDecoration(
                        color: selected == 2 ?  myTheme.primaryColor : myTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Text('${overAllPvd.sec} Sec',style: TextStyle(fontSize: 18,color: selected == 2 ? Colors.white : Colors.black)),
                    ),
                  ),
                ),

              ],
            ),
          SizedBox(height: 50,),
          if(keyBoardMode == false)
            Column(
              children: [
                if(viewWidget == false)
                  if(selected == 0)
                    Transform.scale(
                      scale: 1.2,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(105),
                            color: myTheme.primaryColor.withOpacity(0.2)
                        ),
                        width: 210,
                        height: 210,
                        child: Stack(
                          children: [
                            Center(
                              child: Transform.rotate(
                                angle: overAllPvd.hrs * 0.2617,
                                child: Container(
                                    width: 145,
                                    height: 145,
                                    child: Image.asset('assets/images/clock_needle.png')
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                width: 210,
                                height: 210,
                                child: SleekCircularSlider(
                                  onChangeEnd: (value){
                                    setState(() {
                                      // if(selected != 2){
                                      //   selected += 1;
                                      // }
                                    });
                                  },
                                  initialValue: overAllPvd.hrs.toDouble(),
                                  min: 0,// Initial value
                                  max: 24, // Maximum value
                                  appearance: CircularSliderAppearance(
                                    animDurationMultiplier: 0,
                                    customColors: CustomSliderColors(
                                      progressBarColors: [Colors.transparent,Colors.transparent], // Customize progress bar colors
                                      trackColor: Colors.transparent, // Customize track color
                                      shadowColor: myTheme.primaryColor, // Customize shadow color
                                      shadowMaxOpacity: 0.0, // Set shadow maximum opacity
                                    ),
                                    customWidths: CustomSliderWidths(
                                        progressBarWidth: 55, // Set progress bar width
                                        // trackWidth: 50, // Set track width
                                        shadowWidth: 20,
                                        handlerSize: 2// Set shadow width
                                    ),
                                    size: 210, // Set the slider's size
                                    startAngle: 270, // Set the starting angle
                                    angleRange: 360, // Set the angle range
                                    infoProperties: InfoProperties(
                                      // Customize label style
                                      mainLabelStyle: TextStyle(fontSize: 24, color: myTheme.primaryColor),
                                      modifier: (double value) {
                                        // Display value as a percentage
                                        // return '${(value.toStringAsFixed(0))} hr' == '24 hr' ? '0 hr' : '${(value.toStringAsFixed(0))} hr';
                                        return '';
                                      },
                                    ),
                                    spinnerMode: false, // Disable spinner mode
                                    animationEnabled: true, // Enable animation
                                  ),
                                  onChange: (double value) {
                                    overAllPvd.editTime('hrs', (value.round().toInt()) == 24 ? 0 : (value.round().toInt()));
                                    // setState(() {
                                    //   overAllPvd.hrs  = value.round().toDouble();
                                    // });
                                    // Handle value change here
                                  },
                                ),
                              ),
                            ),
                            for(var i = 0;i < hrs.length;i++)
                              Center(
                                child: Transform.rotate(
                                  angle: (i) * 0.523,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                                    // width: 20,
                                    height: 200,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Center(
                                          child: Transform.rotate(
                                              angle: 6.28 - ((i)*0.523),
                                              child: InkWell(
                                                  onTap: (){
                                                    overAllPvd.editTime('hrs', int.parse(hrs[i][0]));
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Text('${hrs[i][0]}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,color: overAllPvd.hrs == int.parse(hrs[i][0]) ? Colors.black : Colors.black54),),
                                                  )
                                              )
                                          ),
                                        ),
                                        Center(
                                          child: Transform.rotate(
                                              angle: 6.28 - ((i)*0.523),
                                              child: InkWell(
                                                  onTap: (){
                                                    overAllPvd.editTime('hrs', int.parse(hrs[i][1]));
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Text('${hrs[i][1]}',style: TextStyle(fontSize: overAllPvd.hrs == int.parse(hrs[i][1]) ? 16 : 14,fontWeight: FontWeight.w900,color: overAllPvd.hrs == int.parse(hrs[i][1]) ? Colors.black : Colors.black54)),
                                                  )
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                if(viewWidget == false)
                  if(selected == 1)
                    Transform.scale(
                      scale: 1.2,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(105),
                            color: myTheme.primaryColor.withOpacity(0.2)
                        ),
                        width: 210,
                        height: 210,
                        child: Stack(
                          children: [
                            Center(
                              child: Transform.rotate(
                                angle: overAllPvd.min * 0.1047,
                                child: Container(
                                    width: 145,
                                    height: 145,
                                    child: Image.asset('assets/images/clock_needle.png')
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                width: 210,
                                height: 210,
                                child: SleekCircularSlider(
                                  onChangeEnd: (value){
                                    setState(() {
                                      // if(selected != 2){
                                      //   selected += 1;
                                      // }
                                    });
                                  },
                                  initialValue: overAllPvd.min.toDouble(), // Initial value
                                  max: 59, // Maximum value
                                  appearance: CircularSliderAppearance(
                                    animDurationMultiplier: 0,
                                    customColors: CustomSliderColors(
                                      progressBarColors: [Colors.transparent,Colors.transparent], // Customize progress bar colors
                                      trackColor: Colors.transparent, // Customize track color
                                      shadowColor: myTheme.primaryColor, // Customize shadow color
                                      shadowMaxOpacity: 0.0, // Set shadow maximum opacity
                                    ),
                                    customWidths: CustomSliderWidths(
                                        progressBarWidth: 55, // Set progress bar width
                                        // trackWidth: 50, // Set track width
                                        shadowWidth: 20,
                                        handlerSize: 2// Set shadow width
                                    ),
                                    size: 210, // Set the slider's size
                                    startAngle: 270, // Set the starting angle
                                    angleRange: 360, // Set the angle range
                                    infoProperties: InfoProperties(
                                      // Customize label style
                                      mainLabelStyle: TextStyle(fontSize: 24, color: myTheme.primaryColor),
                                      modifier: (double value) {
                                        // Display value as a percentage
                                        // return '${(value.toStringAsFixed(0))} min' == '60 min' ? '0 min' : '${(value.toStringAsFixed(0))} min';
                                        return '';

                                      },
                                    ),
                                    spinnerMode: false, // Disable spinner mode
                                    animationEnabled: true, // Enable animation
                                  ),
                                  onChange: (double value) {
                                    overAllPvd.editTime('min', (value.round().toInt()) == 60 ? 0 : (value.round().toInt()));
                                    // Handle value change here
                                  },
                                ),
                              ),
                            ),
                            for(var i = 0;i < mins.length;i++)
                              Center(
                                child: Transform.rotate(
                                  angle: (i) * 0.523,
                                  child: Container(
                                    height: 200,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            print('tap function work');
                                            overAllPvd.editTime('min', int.parse(mins[i][0]));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Transform.rotate(
                                                angle: 6.28 - ((i)*0.523),
                                                child: Text('${mins[i][0]}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,color: overAllPvd.min == int.parse(mins[i][0]) ? Colors.black : Colors.black54),)
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            print('tap function work');
                                            overAllPvd.editTime('min', int.parse(mins[i][1]));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Transform.rotate(
                                                angle: 6.28 - ((i)*0.523),
                                                child: Text('${mins[i][1]}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,color: overAllPvd.min == int.parse(mins[i][1]) ? Colors.black : Colors.black54))
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),


                          ],
                        ),
                      ),
                    ),
                if(viewWidget == false)
                  if(selected == 2)
                    Transform.scale(
                      scale: 1.2,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(105),
                            color: myTheme.primaryColor.withOpacity(0.2)
                        ),
                        width: 210,
                        height: 210,
                        child: Stack(
                          children: [
                            Center(
                              child: Transform.rotate(
                                angle: overAllPvd.sec * 0.1047,
                                child: Container(
                                    width: 145,
                                    height: 145,
                                    child: Image.asset('assets/images/clock_needle.png')
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                // color: Colors.green,
                                width: 210,
                                height: 210,
                                child: SleekCircularSlider(
                                  initialValue: overAllPvd.sec.toDouble(), // Initial value
                                  max: 59, // Maximum value
                                  appearance: CircularSliderAppearance(
                                    animDurationMultiplier: 0,
                                    customColors: CustomSliderColors(
                                      progressBarColors: [Colors.transparent,Colors.transparent], // Customize progress bar colors
                                      trackColor: Colors.transparent, // Customize track color
                                      shadowColor: myTheme.primaryColor, // Customize shadow color
                                      shadowMaxOpacity: 0.0,  // Set shadow maximum opacity
                                    ),
                                    customWidths: CustomSliderWidths(
                                        progressBarWidth: 55, // Set progress bar width
                                        // trackWidth: 50, // Set track width
                                        shadowWidth: 20,
                                        handlerSize: 2// Set shadow width
                                    ),
                                    size: 210, // Set the slider's size
                                    startAngle: 270, // Set the starting angle
                                    angleRange: 360, // Set the angle range
                                    infoProperties: InfoProperties(
                                      // Customize label style
                                      mainLabelStyle: TextStyle(fontSize: 24, color: myTheme.primaryColor),
                                      modifier: (double value) {
                                        // Display value as a percentage
                                        // return '${(value.toStringAsFixed(0))} sec' == '60 sec' ? '0 sec' : '${(value.toStringAsFixed(0))} sec';
                                        return '';

                                      },
                                    ),
                                    spinnerMode: false, // Disable spinner mode
                                    animationEnabled: true, // Enable animation
                                  ),
                                  onChange: (double value) {
                                    overAllPvd.editTime('sec', (value.round().toInt()) == 60 ? 0 : (value.round().toInt()));
                                    // Handle value change here
                                  },
                                ),
                              ),
                            ),
                            for(var i = 0;i < secs.length;i++)
                              Center(
                                child: Transform.rotate(
                                  angle: (i) * 0.523,
                                  child: SizedBox(
                                    // width: 20,
                                    height: 200,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            overAllPvd.editTime('sec', int.parse(secs[i][0]));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Transform.rotate(
                                                angle: 6.28 - ((i)*0.523),
                                                child: Text('${secs[i][0]}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,color: overAllPvd.sec == int.parse(secs[i][0]) ? Colors.black : Colors.black54),)
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            overAllPvd.editTime('sec', int.parse(secs[i][1]));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Transform.rotate(
                                                angle: 6.28 - ((i)*0.523),
                                                child: Text('${secs[i][1]}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,color: overAllPvd.sec == int.parse(secs[i][1]) ? Colors.black : Colors.black54),)
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                          ],
                        ),
                      ),
                    ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      children: [
                        Text('Hr'),
                        TextFormField(
                          textAlign: TextAlign.center,
                          inputFormatters: regexForNumbers,
                          controller: overAllPvd.hourController,
                          onChanged: (value){
                            var myValue = value == '' ? '0' : value;
                            if(int.parse(myValue) >= 23){
                              setState(() {
                                overAllPvd.hourController.text = '23';
                                myValue = '23';
                              });
                            }
                            setState(() {
                              overAllPvd.hrs = int.parse(myValue);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Text(':'),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      children: [
                        Text('Min'),
                        TextFormField(
                          textAlign: TextAlign.center,
                          inputFormatters: regexForNumbers,
                          controller: overAllPvd.minController,
                          onChanged: (value){
                            var myValue = value == '' ? '0' : value;
                            if(int.parse(myValue) >= 60){
                              setState(() {
                                overAllPvd.minController.text = '59';
                                myValue = '59';
                              });
                            }
                            setState(() {
                              overAllPvd.min = int.parse(myValue);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Text(':'),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      children: [
                        Text('Sec'),
                        TextFormField(
                          textAlign: TextAlign.center,
                          inputFormatters: regexForNumbers,
                          controller: overAllPvd.secController,
                          onChanged: (value){
                            var myValue = value == '' ? '0' : value;
                            if(int.parse(myValue) >= 60){
                              setState(() {
                                overAllPvd.secController.text = '59';
                                myValue = '59';
                              });
                            }
                            setState(() {
                              overAllPvd.sec = int.parse(myValue);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          if(viewWidget == true)
            Container(
                width: 250,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if(viewWidget == true)
                      Container(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          title: Text('Water'),
                          trailing: Text(widget.validation == 'water' ? '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}' : '${widget.waterTime}'),
                        ),
                      ),
                    if(viewWidget == true)
                      Container(
                        color: Colors.brown.shade50,
                        child: ListTile(
                          title: Text('Pre time'),
                          trailing: Text(widget.validation == 'pre' ? '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}' : '${widget.preTime}'),
                        ),
                      ),
                    if(viewWidget == true)
                      Container(
                        color: Colors.brown.shade50,
                        child: ListTile(
                          title: Text('Post time'),
                          trailing: Text(widget.validation == 'post' ? '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}' : '${widget.postTime}'),
                        ),
                      ),
                    if(viewWidget == true)
                      if(widget.fertilizerTime != null)
                        for(var i =0;i< widget.fertilizerTime!['list'].length;i++)
                          Container(
                            color: Colors.brown.shade50,
                            child: ListTile(
                              title: Text('channel - ${i+1}'),
                              trailing: Text(widget.validation == 'fertilizer-${i}' ? '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}' : '${widget.fertilizerTime!['list'][i]}'),
                            ),
                          ),
                  ],
                )
            ),
          SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: (){
                    setState(() {
                      keyBoardMode = !keyBoardMode;
                    });
                  }, icon: Icon(keyBoardMode == false ? Icons.keyboard : Icons.access_time_filled)),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(myTheme.primaryColor.withOpacity(0.2))
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel',style: TextStyle(color: Colors.black87),)
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(myTheme.primaryColor)
                  ),
                  onPressed: widget.onPressed ?? (){
                    if(widget.validation == 'pre' || widget.validation == 'post'){
                      print('ok for prepost');
                      checkCondition(overAllPvd);
                      if(widget.validation == 'pre' && releaseTimeForPrePost){
                        programPvd.editPrePostMethod('preValue', programPvd.selectedGroup,'${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}');
                        Navigator.pop(context);
                      }
                      if(widget.validation == 'post' && releaseTimeForPrePost){
                        programPvd.editPrePostMethod('postValue', programPvd.selectedGroup,'${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}');
                        Navigator.pop(context);
                      }
                    }else if(widget.validation == 'water'){
                      print('ok for water');
                      checkCondition1(overAllPvd);
                      if(widget.validation == 'water' && releaseTimeForWater){
                        programPvd.editWaterSetting('timeValue', '${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}');
                        Navigator.pop(context);
                      }
                    }else if(widget.validation!.contains('fertilizer')){
                      print('widget1 : ${widget.validation}');
                      checkCondition2(overAllPvd);
                      if(widget.validation!.contains('fertilizer') && releaseTimeForFertilizer){
                        programPvd.editParticularChannelDetails('timeValue', programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing','${overAllPvd.hrs! < 10 ? '0' :''}${overAllPvd.hrs!}:${overAllPvd.min! < 10 ? '0' :''}${overAllPvd.min!}:${overAllPvd.sec! < 10 ? '0' :''}${overAllPvd.sec!}',widget.index);
                        Navigator.pop(context);
                      }
                    }else{
                      print('widget : ${widget.validation}');
                    }
                  },
                  child: Text('Ok',style: TextStyle(color: Colors.white),)
              )
            ],
          )
        ],
      ),
    );
  }
}