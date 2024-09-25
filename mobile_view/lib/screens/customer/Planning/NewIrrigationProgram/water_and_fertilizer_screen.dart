import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/irrigation_program_main_provider.dart';
import '../../../../state_management/overall_use.dart';
import '../../../../widget/HoursMinutesSeconds.dart';
import '../../../config/constant/general_in_constant.dart';



class WaterAndFertilizerScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  final bool isIrrigationProgram;
  const WaterAndFertilizerScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber, required this.isIrrigationProgram});

  @override
  State<WaterAndFertilizerScreen> createState() => _WaterAndFertilizerScreenState();
}

class _WaterAndFertilizerScreenState extends State<WaterAndFertilizerScreen> {

  FocusNode myFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var programPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: false);
        programPvd.waterAndFert();
        programPvd.editSegmentedControlGroupValue(0);
        // programPvd.selectingTheSite();
        if(programPvd.sequenceData.isNotEmpty){
          programPvd.editGroupSiteInjector(programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite', programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite :programPvd.selectedLocalSite);
        }
      });
    }
    myFocus.addListener(() {
      var programPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: false);
      if(myFocus.hasFocus == false){
        dynamic result = programPvd.editWaterSetting('quantityValue', programPvd.waterQuantity.text);
        if(result != null){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: const Text('Limitation Alert!',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
              content: Text('${result['message']}',style: const TextStyle(fontSize: 14)),
              actions: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    height: 30,
                    color: Theme.of(context).primaryColor,
                    child: const Center(
                      child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        }
        setState(() {

        });
      }
    });
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final programPvd = Provider.of<IrrigationProgramMainProvider>(context);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    if(programPvd.sequenceData.isEmpty){
      return const Center(
          child: Text('Please Create At least One Sequence')
      );
    }
    return LayoutBuilder(builder: (context,constraint){
      double screenSizeForGraph = constraint.maxWidth - 16;

      return Container(
        // padding: const EdgeInsets.all(10.0),
        color: const Color(0xffF6FEFF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10,left: 8,right: 8),
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xffE6EDF5),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for(var seq = 0;seq < programPvd.sequenceData.length;seq++)
                      Row(
                        children: [
                          mySeqButtons(
                            programPvd: programPvd,
                            index: seq,
                            verticalPadding: 8,
                            radius: 15,
                            name: '${programPvd.sequenceData[seq]['seqName']}',
                            onTap: (){
                              _scrollController.animateTo((seq * (programPvd.selectedGroup > seq ? (programPvd.sequenceData[seq]['seqName'].length * 3) : (programPvd.sequenceData[seq]['seqName'].length * 7))).toDouble(), duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                              programPvd.editGroupSiteInjector('selectedGroup', seq);
                              if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty){
                                programPvd.editSegmentedCentralLocal(0);
                              }else if(programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty){
                                programPvd.editSegmentedCentralLocal(1);
                              }
                            },
                          ),
                          const SizedBox(width: 20,)
                        ],
                      )
                  ],
                ),
              ),
            ),
            Container(
                alignment: Alignment.center,
                height: 80,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if(programPvd.sequenceData.isNotEmpty)
                      SizedBox(
                        width: constraint.maxWidth - 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if(['0','0.0',''].contains(programPvd.waterValueInQuantity))
                              Expanded(child: Text('0',style: graphTextStyle,)),
                            if(!['0','0.0',''].contains(programPvd.waterValueInQuantity))
                              for(var i = 0;i < generateValuesLiters(double.parse(programPvd.waterValueInQuantity)).length;i++)
                                Text('${generateValuesLiters(double.parse(programPvd.waterValueInQuantity))[i]} L',style: graphTextStyle),
                          ],
                        ),
                      ),
                    const SizedBox(height: 5,),
                    Container(
                      margin: EdgeInsets.only(left: 8,right: 8),
                      width: screenSizeForGraph,
                      color: const Color(0xffD8E6FD),
                      child: Row(
                        children: [
                          if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty || programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty)
                            AnimatedContainer(
                                width: returnWidth(programPvd,'pre',screenSizeForGraph),
                                decoration: BoxDecoration(
                                    color: const Color(0xff5CB2D1),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                height: 40,
                                duration: const Duration(milliseconds: 500)
                            ),
                          SizedBox(
                            height: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'])
                                  for(var inj = 0;inj < programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length;inj++)
                                    if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj]['method'].contains('Pro'))
                                      Container(
                                        width: returnWidthForProMethod(programPvd, screenSizeForGraph),
                                        height: 30/programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xffFF857D),
                                                  Color(0xff5CB2D1),
                                                  Color(0xffFF857D),
                                                  Color(0xff5CB2D1),
                                                  Color(0xffFF857D),
                                                  Color(0xff5CB2D1),
                                                  Color(0xffFF857D),
                                                  Color(0xff5CB2D1),
                                                  Color(0xffFF857D),
                                                  Color(0xff5CB2D1),
                                                  Color(0xffFF857D),
                                                  Color(0xff5CB2D1),

                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight
                                            )
                                        ),
                                      )
                                    else
                                      Container(
                                        width: returnWidthForProMethod(programPvd, screenSizeForGraph),
                                        height: 30/programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length,
                                        child: Row(
                                          children: [
                                            AnimatedContainer(
                                              width: returnWidthForFertilizer(programPvd,programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj],screenSizeForGraph),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10)),
                                                color:const Color(0xffFF857D),
                                              ),
                                              height: 30/programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length,
                                              duration: const Duration(milliseconds: 500),
                                            ),
                                            if(returnWidthForFertilizer(programPvd,programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj],screenSizeForGraph) > 0)
                                              Expanded(
                                                child: Container(
                                                  // width: constraint.maxWidth - (returnWidth(programPvd,'pre',constraint.maxWidth) + returnWidth(programPvd,'post',constraint.maxWidth) + returnWidthForFertilizer(programPvd,programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][inj],constraint.maxWidth)) -1,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                                                    color:const Color(0xff1D808E),
                                                    // color:Colors.blueGrey
                                                  ),
                                                  height: 30/programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length,
                                                  // duration: const Duration(milliseconds: 500),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: SizedBox(
                              // color: Color(0xffD8E6FD),
                              width: double.infinity,
                              height: 40,
                            ),
                          ),
                          if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty || programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty)
                            AnimatedContainer(
                              // width: returnWidth(programPvd.sequenceData[programPvd.selectedGroup]['timeValue'],programPvd.sequenceData[programPvd.selectedGroup]['postValue'],constraints.maxWidth),
                                width: returnWidth(programPvd,'post',screenSizeForGraph),
                                decoration: BoxDecoration(
                                    color: const Color(0xff6EA661),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                height: 40,
                                duration: const Duration(seconds: 1)
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: constraint.maxWidth - 10.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(programPvd.waterValueInTime == '00:00:00' || programPvd.waterValueInTime == '0:0:0')
                            Text('00:00:00',style: graphTextStyle,),
                          if(programPvd.waterValueInTime != '00:00:00' && programPvd.waterValueInTime != '0:0:0')
                            ...generateTimeValues(programPvd.waterValueInTime),
                          //   Text(generateTimeValues(programPvd.waterValueInTime)[0],style: graphTextStyle),
                          // if(programPvd.waterValueInTime != '00:00:00')
                          //   Text(generateTimeValues(programPvd.waterValueInTime)[1],style: graphTextStyle),
                          // if(programPvd.waterValueInTime != '00:00:00')
                          //   Text(generateTimeValues(programPvd.waterValueInTime)[2],style: graphTextStyle),
                          // if(programPvd.waterValueInTime != '00:00:00')
                          //   Text(generateTimeValues(programPvd.waterValueInTime)[3],style: graphTextStyle),
                        ],
                      ),
                    ),

                  ],
                )
            ),
            SizedBox(height: 10,),
            Container(
                width: constraint.maxWidth,
                height: constraint.maxHeight - 35 - 41 - 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  color: const Color(0xffF9FEFF),
                  width: double.infinity,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 30,
                          child: Row(
                            children: [
                              SizedBox(
                                width: (constraint.maxWidth - 20)/2,
                                child: Row(
                                  children: [
                                    Icon(Icons.apple_rounded,color: Color(0xff5CB2D1),),
                                    SizedBox(width: 20,),
                                    Text('Pre water')
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: (constraint.maxWidth - 20)/2,
                                child: Row(
                                  children: [
                                    Icon(Icons.apple_rounded,color: Color(0xff6EA661)),
                                    SizedBox(width: 20,),
                                    Text('Post water')
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 30,
                          child: Row(
                            children: [
                              SizedBox(
                                width: (constraint.maxWidth - 20)/2,
                                child: Row(
                                  children: [
                                    Icon(Icons.apple_rounded,color: Color(0xffFF857D),),
                                    SizedBox(width: 20,),
                                    Text('Fertilizer Value')
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: (constraint.maxWidth - 20)/2,
                                child: Row(
                                  children: [
                                    Icon(Icons.apple_rounded,color: Color(0xff1D808E),),
                                    SizedBox(width: 20,),
                                    Text('Balance water')
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.only(left: 10,right: 10),
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                              color: listOfSeqColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: customBoxShadow
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              currentSequence(),
                              currentSequenceDetails(programPvd),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 20,),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.only(left: 10,right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 0.3,color: Colors.blueGrey),
                              boxShadow: customBoxShadow,
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              )
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('Method',style: TextStyle(color: Colors.black,fontSize: 14),),
                                leading: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: SvgPicture.asset(
                                      'assets/images/method.svg',
                                      semanticsLabel: 'Acme Logo'
                                  ),
                                ),
                                trailing: DropdownButton(
                                  icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
                                  style: const TextStyle(color: Colors.black),
                                  dropdownColor: Colors.white,
                                  value: programPvd.sequenceData[programPvd.selectedGroup]['method'],
                                  underline: Container(),
                                  items: ['Time','Quantity'].map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items,style: const TextStyle(fontSize: 12,color: Colors.black),),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    programPvd.editWaterSetting('method', value.toString());
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text('Value',style: TextStyle(color: Colors.black,fontSize: 14),),
                                leading: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: SvgPicture.asset(
                                    'assets/images/time_quantity.svg',
                                  ),
                                ),
                                trailing:  SizedBox(
                                  child: SizedBox(
                                    width: 100,
                                    height: 30,
                                    child: Center(
                                        child: Transform.scale(
                                          scale: 0.9,
                                          child: SizedBox(
                                            width: 80,
                                            height: 28,
                                            child: programPvd.sequenceData[programPvd.selectedGroup]['method'] == 'Quantity' ? TextFormField(
                                              cursorColor: Colors.black,
                                              controller: programPvd.waterQuantity,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                              ],
                                              focusNode: myFocus,
                                              maxLength: 8,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14,color: Colors.black),
                                              decoration: const InputDecoration(
                                                  fillColor: Colors.white,
                                                  counterText: '',
                                                  contentPadding: EdgeInsets.only(bottom: 5),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.black)
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.black)
                                                  ),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1)
                                                  )
                                              ),
                                              onFieldSubmitted: (value){
                                                programPvd.editWaterSetting('quantityValue', value);
                                              },
                                              onChanged: (value){
                                              },
                                            ) :  InkWell(
                                              onTap: (){
                                                _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'waterTimeValue',programPvd.sequenceData[programPvd.selectedGroup]['timeValue'],'water');
                                              },
                                              child: SizedBox(
                                                width: 80,
                                                height: 40,
                                                child: Center(
                                                  child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['timeValue']}',style: const TextStyle(color: Colors.black,fontSize: 14),),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty || programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty)
                                ListTile(
                                    title: const Text('Pre - Post Method',style: TextStyle(color: Colors.black,fontSize: 14),),
                                    leading: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: SvgPicture.asset(
                                          'assets/images/pre_post_method.svg',
                                          semanticsLabel: 'Acme Logo'
                                      ),
                                    ),
                                    trailing:  DropdownButton(
                                      dropdownColor: Colors.white,
                                      icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
                                      value: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'],
                                      underline: Container(),
                                      items: ['Time','Quantity'].map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items,style: const TextStyle(fontSize: 12,color: Colors.black),),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        programPvd.editPrePostMethod('prePostMethod',programPvd.selectedGroup,value.toString());
                                      },
                                    )
                                ),
                              if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty || programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty)
                                ListTile(
                                  title: const Text('Pre Value',style: TextStyle(color: Colors.black,fontSize: 14),),
                                  leading: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: SvgPicture.asset(
                                        'assets/images/pre_value.svg',
                                        semanticsLabel: 'Acme Logo'
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    width: 100,
                                    height: 30,
                                    child: Center(
                                        child: Transform.scale(
                                          scale: 0.8,
                                          child: SizedBox(
                                            width: 80,
                                            height: 28,
                                            child: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'] == 'Quantity' ? TextFormField(
                                              cursorColor: Colors.black,
                                              controller: programPvd.preValue,
                                              maxLength: 6,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                              ],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14,color: Colors.black),
                                              decoration: const InputDecoration(
                                                  fillColor: Colors.white,
                                                  counterText: '',
                                                  contentPadding: EdgeInsets.only(bottom: 5),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.black)
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.black)
                                                  ),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1)
                                                  )
                                              ),
                                              onChanged: (value){
                                                dynamic result = programPvd.editPrePostMethod('preValue',programPvd.selectedGroup,value);
                                                if(result != null){
                                                  closeKeyboard(context);
                                                  showDialog(context: context, builder: (context){
                                                    return AlertDialog(
                                                      title: const Text('Limitation Alert!',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                                                      content: Text('${result['message']}',style: const TextStyle(fontSize: 14)),
                                                      actions: [
                                                        InkWell(
                                                          onTap: (){
                                                            Navigator.pop(context);
                                                            closeKeyboard(context);
                                                          },
                                                          child: Container(
                                                            width: 80,
                                                            height: 30,
                                                            color: Theme.of(context).primaryColor,
                                                            child: const Center(
                                                              child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                                }
                                              },
                                            ) :  InkWell(
                                              onTap: (){
                                                _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'pre',programPvd.sequenceData[programPvd.selectedGroup]['preValue'],'pre');
                                              },
                                              child: SizedBox(
                                                width: 80,
                                                height: 40,
                                                child: Center(
                                                  child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['preValue']}',style: const TextStyle(color: Colors.black,fontSize: 16),),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                              if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty || programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty)
                                ListTile(
                                  title: const Text('Post Value',style: TextStyle(color: Colors.black,fontSize: 14),),
                                  leading: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: SvgPicture.asset(
                                      'assets/images/post_value.svg',
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    width: 100,
                                    height: 30,
                                    child: Center(
                                        child: Transform.scale(
                                          scale: 0.8,
                                          child: SizedBox(
                                            width: 80,
                                            height: 28,
                                            child: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'] == 'Quantity' ? TextFormField(
                                              cursorColor: Colors.black,
                                              controller: programPvd.postValue,
                                              maxLength: 6,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                              ],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14,color: Colors.black),
                                              decoration: const InputDecoration(
                                                  fillColor: Colors.white,
                                                  counterText: '',
                                                  contentPadding: EdgeInsets.only(bottom: 5),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.black)
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.black)
                                                  ),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(width: 1)
                                                  )
                                              ),
                                              onChanged: (value)async{
                                                dynamic result = await programPvd.editPrePostMethod('postValue',programPvd.selectedGroup,value);
                                                if(result != null){
                                                  closeKeyboard(context);
                                                  showDialog(context: context, builder: (context){
                                                    return AlertDialog(
                                                      title: const Text('Limitation Alert!',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                                                      content: Text('${result['message']}',style: const TextStyle(fontSize: 14)),
                                                      actions: [
                                                        InkWell(
                                                          onTap: (){
                                                            Navigator.pop(context);
                                                            closeKeyboard(context);
                                                          },
                                                          child: Container(
                                                            width: 80,
                                                            height: 30,
                                                            color: Theme.of(context).primaryColor,
                                                            child: const Center(
                                                              child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                                }
                                                setState(() {

                                                });
                                              },
                                            ) :  InkWell(
                                              onTap: (){
                                                _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'post',programPvd.sequenceData[programPvd.selectedGroup]['postValue'],'post');
                                              },
                                              child: SizedBox(
                                                width: 80,
                                                height: 40,
                                                child: Center(
                                                  child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['postValue']}',style: const TextStyle(color: Colors.black,fontSize: 16),),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                              if(returnMoistureCondition(programPvd.apiData['moisture']).length!= 1)
                                ListTile(
                                  title: const Text('Moisture Condition',style: TextStyle(color: Colors.black,fontSize: 14),),
                                  leading: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: SvgPicture.asset(
                                      'assets/images/moisture_condition.svg',
                                    ),
                                  ),
                                  trailing: DropdownButton(
                                    icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
                                    dropdownColor: Colors.white,
                                    value: programPvd.sequenceData[programPvd.selectedGroup]['moistureCondition'],
                                    underline: Container(),
                                    items: returnMoistureCondition(programPvd.apiData['moisture']).map((items) {
                                      return DropdownMenuItem(
                                        value: items['name'],
                                        child: Text(
                                          items['name'],
                                          style: const TextStyle(fontSize: 14, color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      programPvd.editGroupSiteInjector('applyMoisture', returnMoistureCondition(programPvd.apiData['moisture']).where((element) => element['name'] == value).toList()[0]);
                                    },
                                  ),
                                ),
                              if(returnMoistureCondition(programPvd.apiData['level']).length != 1)
                                ListTile(
                                  title: const Text('Level Condition',style: TextStyle(color: Colors.black,fontSize: 14),),
                                  leading: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: SvgPicture.asset(
                                      'assets/images/level_condition.svg',
                                    ),
                                  ),
                                  trailing: DropdownButton(
                                    icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
                                    dropdownColor: Colors.white,
                                    value: programPvd.sequenceData[programPvd.selectedGroup]['levelCondition'],
                                    underline: Container(),
                                    items: returnMoistureCondition(programPvd.apiData['level']).map((items) {
                                      return DropdownMenuItem(
                                        value: items['name'],
                                        child: Text(
                                          items['name'],
                                          style: const TextStyle(fontSize: 14, color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      programPvd.editGroupSiteInjector('applyLevel', returnMoistureCondition(programPvd.apiData['level']).where((element) => element['name'] == value).toList()[0]);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty && programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty)
                        SliverToBoxAdapter(
                          child: Row(
                            children: [
                              const SizedBox(width: 10,),
                              SizedBox(
                                width: 150,
                                child: MaterialButton(
                                  elevation: 1,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                                  ),
                                  color: programPvd.segmentedControlCentralLocal == 0 ? Theme.of(context).primaryColor : Colors.white,
                                  onPressed: (){
                                    programPvd.editSegmentedCentralLocal(0);
                                    // programPvd.selectingTheSite();
                                  },
                                  child: Text("Central", style: TextStyle(color: programPvd.segmentedControlCentralLocal == 0 ? Colors.white : Colors.black),),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: MaterialButton(
                                  elevation: 1,
                                  color: programPvd.segmentedControlCentralLocal == 1 ? Theme.of(context).primaryColor : Colors.white,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))
                                  ),
                                  onPressed: (){
                                    programPvd.editSegmentedCentralLocal(1);
                                    // programPvd.selectingTheSite();
                                  },
                                  child: Text("Local",style: TextStyle(color: programPvd.segmentedControlCentralLocal == 1 ? Colors.white : Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                        if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                          SliverToBoxAdapter(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey
                                ),
                                child: CheckboxListTile(
                                    title: Text('${programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['name']}',style: TextStyle(color: Colors.white),),
                                    checkColor: Colors.white,
                                    fillColor: MaterialStateProperty.all(Colors.green),
                                    value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'],
                                    onChanged: (value){
                                      programPvd.editGroupSiteInjector(programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizer' : 'applyFertilizer', value);
                                    }
                                ),
                              )
                          ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                        if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                          if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'])
                            if(returnSelectedSiteRecipe(programPvd).isNotEmpty)
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Checkbox(
                                                value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['applyRecipe'],
                                                onChanged: (value){
                                                  programPvd.editGroupSiteInjector('applyRecipe', value);
                                                }
                                            ),
                                            Text('Apply Recipe',style: wf,)
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 40,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: returnSelectedSiteRecipe(programPvd).length,
                                              itemBuilder: (context,index){
                                                // return Text('yes')
                                                return Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: (){
                                                        // programPvd.editGroupSiteInjector(programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite', index);
                                                        dynamic result = programPvd.editGroupSiteInjector('selectedRecipe', index);
                                                        if(result != null){
                                                          showDialog(context: context, builder: (context){
                                                            return AlertDialog(
                                                              title: const Text('Limitation Alert!',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                                                              content: Text('${result['message']}',style: const TextStyle(fontSize: 14)),
                                                              actions: [
                                                                InkWell(
                                                                  onTap: (){
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: Container(
                                                                    width: 80,
                                                                    height: 30,
                                                                    color: Theme.of(context).primaryColor,
                                                                    child: const Center(
                                                                      child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                        }
                                                        setState(() {

                                                        });
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.only(left: 10,top: 5,bottom: 5,right: 10),
                                                        decoration: BoxDecoration(
                                                            color: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite']]['recipe'] == index ? liteViolet : Colors.white,
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(width: 1,color: violetBorder)
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${returnSelectedSiteRecipe(programPvd)[index]['name']}',style: const TextStyle(color: Colors.black,fontSize: 12),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),


                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),


                      if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                        if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                          if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite :  programPvd.selectedLocalSite]['ecValue'] != null || programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.segmentedControlCentralLocal == 0 ? programPvd.selectedCentralSite :  programPvd.selectedLocalSite]['phValue'] != null)
                            if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'])
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  width: 250,
                                  height: 60,
                                  child: Row(
                                    children: [
                                      if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][programPvd.selectedCentralSite]['ecValue'] != null)
                                        SizedBox(
                                          width: 120,
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needEcValue'] == false)
                                                InkWell(
                                                    onTap: (){
                                                      programPvd.editEcPhNeedOrNot('ec');
                                                    },
                                                    child: const Icon(Icons.radio_button_off,color: Colors.black,)
                                                )
                                              else
                                                InkWell(
                                                    onTap: (){
                                                      programPvd.editEcPhNeedOrNot('ec');
                                                    },
                                                    child: const Icon(Icons.radio_button_checked,color: Colors.green)
                                                ),
                                              Text("EC",style: wf,),
                                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needEcValue'] == true)
                                                SizedBox(
                                                  width: 60,
                                                  height: 40,
                                                  child: TextFormField(
                                                    controller: programPvd.ec,
                                                    maxLength: 3,
                                                    inputFormatters: regexForDecimal,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 14),
                                                    decoration: const InputDecoration(
                                                        counterText: '',
                                                        contentPadding: EdgeInsets.only(bottom: 5),
                                                        enabledBorder: OutlineInputBorder(
                                                        ),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 1)
                                                        )
                                                    ),
                                                    onChanged: (value){
                                                      programPvd.editEcPh(programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', 'ecValue', value);
                                                    },
                                                  ),
                                                )
                                              else
                                                const SizedBox(width: 60,)
                                            ],
                                          ),
                                        ),
                                      if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['phValue'] != null)
                                        SizedBox(
                                          width: 120,
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needPhValue'] == false)
                                                InkWell(
                                                    onTap: (){
                                                      programPvd.editEcPhNeedOrNot('ph');
                                                    },
                                                    child: const Icon(Icons.radio_button_off,color: Colors.black,)
                                                )
                                              else
                                                InkWell(
                                                    onTap: (){
                                                      programPvd.editEcPhNeedOrNot('ph');
                                                    },
                                                    child: const Icon(Icons.radio_button_checked,color: Colors.green)
                                                ),
                                              const Text("PH",style: TextStyle(fontSize: 12),),
                                              if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['needPhValue'] == true)
                                                SizedBox(
                                                  width: 60,
                                                  height: 40,
                                                  child: TextFormField(
                                                    controller: programPvd.ph,
                                                    maxLength: 6,
                                                    inputFormatters: regexForDecimal,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 14),
                                                    decoration: const InputDecoration(
                                                        counterText: '',
                                                        contentPadding: EdgeInsets.only(bottom: 5),
                                                        enabledBorder: OutlineInputBorder(
                                                        ),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 1)
                                                        )
                                                    ),
                                                    onChanged: (value){
                                                      programPvd.editEcPh(programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', 'phValue', value);
                                                    },
                                                  ),
                                                )
                                              else
                                                const SizedBox(width: 60,)
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                      if(programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == true)
                        if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0)
                          if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'])
                            SliverToBoxAdapter(
                              child: Container(
                                margin: EdgeInsets.only(left: 10,right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(width: 0.5,color: Colors.black87)
                                ),
                                width: double.infinity,
                                height: ((45 * programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length) + 50).toDouble() ,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xff1C7B89),
                                              Color(0xff074B55)
                                            ]
                                        ),

                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          const SizedBox(
                                            width: 100,
                                            height: 40,
                                            child: Center(
                                              child: Text('Fertilizer',style: TextStyle(fontSize: 16,color: Colors.white),),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 100,
                                            height: 40,
                                            child: Center(
                                              child: Text('Method',style: TextStyle(fontSize: 16,color: Colors.white),),
                                            ),
                                          ),
                                          // fertilizerColumn(name: 'Method'),
                                          const SizedBox(
                                            width: 100,
                                            height: 40,
                                            child: Center(
                                              child: Text('Value',style: TextStyle(fontSize: 16,color: Colors.white),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: double.infinity,
                                      height: 1,
                                      child: Divider(
                                        height: 1,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    for(var index = 0;index < programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'].length;index++)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 40,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                  child: Checkbox(
                                                      activeColor: Theme.of(context).primaryColorDark,
                                                      value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['onOff'],
                                                      onChanged: (value){
                                                        programPvd.editOnOffInInjector(programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing',index,value!);
                                                      }
                                                  ),
                                                ),
                                                Text('${programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['id']}',style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),)
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            height: 40,
                                            child: Center(
                                                child: DropdownButton(
                                                  isExpanded: true,
                                                  dropdownColor: Colors.white,
                                                  value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['method'],
                                                  underline: Container(),
                                                  items: ['Time','Pro.time','Quantity','Pro.quantity','Pro.quant per 1000L'].map((String items) {
                                                    return DropdownMenuItem(
                                                      value: items,
                                                      child: Text(items,style: const TextStyle(fontSize: 12,color: Colors.black),),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    programPvd.editParticularChannelDetails('method', programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', value,index);
                                                  },
                                                )
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            height: 40,
                                            child: Center(
                                                child: SizedBox(
                                                  width: 60,
                                                  height: 28,
                                                  child: ['Pro.quantity','Quantity','Pro.quant per 1000L'].contains(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['method']) ? TextFormField(
                                                    controller: programPvd.getInjectorController(index),
                                                    maxLength: 6,
                                                    inputFormatters: regexForDecimal,
                                                    // inputFormatters: [
                                                    //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                    // ],
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 14),
                                                    decoration: const InputDecoration(
                                                        counterText: '',
                                                        contentPadding: EdgeInsets.only(bottom: 5),
                                                        enabledBorder: OutlineInputBorder(
                                                        ),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(width: 1)
                                                        )
                                                    ),
                                                    onChanged: (value){
                                                      dynamic result = programPvd.editParticularChannelDetails('quantityValue', programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing', value,index);

                                                      if(result != null){
                                                        closeKeyboard(context);
                                                        showDialog(context: context, builder: (context){
                                                          return AlertDialog(
                                                            title: const Text('Limitation Alert!',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                                                            content: Text('${result['message']}',style: const TextStyle(fontSize: 14)),
                                                            actions: [
                                                              InkWell(
                                                                onTap: (){
                                                                  closeKeyboard(context);
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Container(
                                                                  width: 80,
                                                                  height: 30,
                                                                  color: Theme.of(context).primaryColor,
                                                                  child: const Center(
                                                                    child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                      }
                                                      setState(() {

                                                      });
                                                    },
                                                  ) :  InkWell(
                                                    onTap: (){
                                                      _showTimePicker(
                                                          programPvd,
                                                          overAllPvd,
                                                          programPvd.selectedGroup,
                                                          'timeValue',
                                                          programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['timeValue'],
                                                          'fertilizer',
                                                          index
                                                      );
                                                    },
                                                    child: SizedBox(
                                                      width: 80,
                                                      height: 40,
                                                      child: Center(
                                                        child: Text('${programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][0]['fertilizer'][index]['timeValue']}',style: const TextStyle(fontSize: 12),),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 100,
                        ),
                      )
                      // if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length == 0 || programPvd.isSiteVisible(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'],programPvd.segmentedControlCentralLocal == 0 ? 'central' : 'local') == false)
                      //   if(programPvd.segmentedControlGroupValue == 1)
                      //     const SliverToBoxAdapter(
                      //       child: SizedBox(
                      //         width: double.infinity,
                      //         height: 100,
                      //         child: Row(
                      //           children: [
                      //             Text(
                      //               'Not Available: \u{1F6AB}', // Unicode for "no entry" emoji
                      //               style: TextStyle(fontSize: 36,color: Colors.red),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),


                    ],
                  ),
                )
            )
          ],
        ),
      );
    });
  }

  Widget fertilizerColumn({required String name}){
    return Expanded(
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(name,style: const TextStyle(fontSize: 16,color: Colors.white),),
        ),
      ),
    );
  }
  Widget fertilizerRow({required Widget myWidget}){
    return SizedBox(
        width: 100,
        height: 40,
        child: myWidget
    );
  }
  List<Map<String,dynamic>> returnMoistureCondition(myData){
    List<Map<String,dynamic>> data = [{'name': '-','sNo' : 0}];
    for(var i in myData){
      // data.add(i['name']);
      data.add(i);
    }
    // // // print('data : $data');
    return data;
  }

  void _showTimePicker(IrrigationProgramMainProvider programPvd,OverAllUse overAllPvd,int index,String purpose,value,validation,[int? fertIndex]) async {
    // // print('showed');
    var fertilizerList = [
      if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty)
        ...[for(var i in programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'][0]['fertilizer']) formatTime(programPvd.fertilizerValueInSec(fertilizerData: i))],
      if(programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty)
        ...[for(var i in programPvd.sequenceData[programPvd.selectedGroup]['localDosing'][0]['fertilizer']) formatTime(programPvd.fertilizerValueInSec(fertilizerData: i))]
    ];
    Widget check(){
      // // print('start check');
      String water = formatTime(programPvd.waterValueInSec());
      String pre = formatTime(programPvd.preValueInSec());
      String post = formatTime(programPvd.postValueInSec());
      if(validation == 'water'){
        return HoursMinutesSeconds(
          initialTime: '$value',
          waterTime: water,
          postTime: post,
          preTime: pre,
          validation: 'water',
          fertilizerTime: {
            'list' : fertilizerList
          },
        );
      }
      else if(validation == 'pre'){
        return HoursMinutesSeconds(
          initialTime: '$value',
          waterTime: water,
          postTime: post,
          preTime: pre,
          validation: 'pre',
          fertilizerTime: {
            'list' : fertilizerList
          },
        );
      }
      else if(validation == 'post'){
        // // print('start post');
        return HoursMinutesSeconds(
          initialTime: '$value',
          waterTime: water,
          postTime: post,
          preTime: pre,
          validation: 'post',
          fertilizerTime: {
            'list' : fertilizerList
          },
        );
      }
      else if(validation == 'fertilizer'){
        return HoursMinutesSeconds(
          index: fertIndex,
          initialTime: '$value',
          waterTime: water,
          postTime: post,
          preTime: pre,
          validation: 'fertilizer-$fertIndex',
          fertilizerTime: {
            'list' : fertilizerList
          },
        );
      }
      else{
        // // print('nothing');
        return const Text('nothing');
      }
    }
    // // print('purpose : $purpose');
    overAllPvd.editTimeAll();
    overAllPvd.editTime('hrs',int.parse(value.split(':')[0]));
    overAllPvd.editTime('min',int.parse(value.split(':')[1]));
    overAllPvd.editTime('sec',int.parse(value.split(':')[2]));
    // programPvd.sequenceData[programPvd.selectedGroup]['timeValue'],programPvd.sequenceData[programPvd.selectedGroup]['postValue']
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: check(),
        );
      },
    );
  }

  Widget waterSetting(int index,IrrigationProgramMainProvider programPvd,OverAllUse overAllPvd){
    if(index == 0){
      return ListTile(
        title: const Text('Method',style: TextStyle(color: Colors.black,fontSize: 14),),
        leading: SizedBox(
          width: 30,
          height: 30,
          child: SvgPicture.asset(
            'assets/images/default_icon.svg',
          ),
        ),
        trailing: DropdownButton(
          icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          value: programPvd.sequenceData[programPvd.selectedGroup]['method'],
          underline: Container(),
          items: ['Time','Quantity'].map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items,style: const TextStyle(fontSize: 12,color: Colors.black),),
            );
          }).toList(),
          onChanged: (value) {
            programPvd.editWaterSetting('method', value.toString());
          },
        ),
      );
    }else if(index == 1){
      return ListTile(
        title: const Text('Value',style: TextStyle(color: Colors.black,fontSize: 14),),
        leading: SizedBox(
          width: 30,
          height: 30,
          child: SvgPicture.asset(
            'assets/images/default_icon.svg',
          ),
        ),
        trailing:  SizedBox(
          child: SizedBox(
            width: 100,
            height: 30,
            child: Center(
                child: Transform.scale(
                  scale: 0.8,
                  child: SizedBox(
                    width: 80,
                    height: 28,
                    child: programPvd.sequenceData[programPvd.selectedGroup]['method'] == 'Quantity' ? TextFormField(
                      cursorColor: Colors.black,
                      controller: programPvd.waterQuantity,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      focusNode: myFocus,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14,color: Colors.black),
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          counterText: '',
                          contentPadding: EdgeInsets.only(bottom: 5),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1)
                          )
                      ),
                      onFieldSubmitted: (value){
                        programPvd.editWaterSetting('quantityValue', value);
                      },
                    ) :  InkWell(
                      onTap: (){
                        _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'waterTimeValue',programPvd.sequenceData[programPvd.selectedGroup]['timeValue'],'water');
                      },
                      child: SizedBox(
                        width: 80,
                        height: 40,
                        child: Center(
                          child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['timeValue']}',style: const TextStyle(color: Colors.black,fontSize: 14),),
                        ),
                      ),
                    ),
                  ),
                )
            ),
          ),
        ),
      );
    }else if(index == 2){
      return ListTile(
        title: const Text('Moisture \n Condition',style: TextStyle(color: Colors.black,fontSize: 14),),
        leading: SizedBox(
          width: 30,
          height: 30,
          child: SvgPicture.asset(
            'assets/images/default_icon.svg',
          ),
        ),
        trailing: DropdownButton(
          icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
          dropdownColor: Colors.white,
          value: programPvd.sequenceData[programPvd.selectedGroup]['moistureCondition'],
          underline: Container(),
          items: returnMoistureCondition(programPvd.apiData['moisture']).map((items) {
            return DropdownMenuItem(
              value: items['name'],
              child: Text(
                items['name'],
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (value) {
            programPvd.editGroupSiteInjector('applyMoisture', returnMoistureCondition(programPvd.apiData['moisture']).where((element) => element['name'] == value).toList()[0]);
          },
        ),
      );
    }else{
      return ListTile(
        title: const Text('Level \n Condition',style: TextStyle(color: Colors.black,fontSize: 14),),
        // subtitle: Text('Condition',style: TextStyle(color: Colors.white,fontSize: 12)),
        leading: SizedBox(
          width: 30,
          height: 30,
          child: SvgPicture.asset(
            'assets/images/default_icon.svg',
          ),
        ),
        trailing: DropdownButton(
          icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
          dropdownColor: Colors.white,
          value: programPvd.sequenceData[programPvd.selectedGroup]['levelCondition'],
          underline: Container(),
          items: returnMoistureCondition(programPvd.apiData['moisture']).map((items) {
            return DropdownMenuItem(
              value: items['name'],
              child: Text(
                items['name'],
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (value) {
            programPvd.editGroupSiteInjector('applyLevel', returnMoistureCondition(programPvd.apiData['level']).where((element) => element['name'] == value).toList()[0]);
          },
        ),
      );
    }

  }
  Widget fertilizerSetting(int index,IrrigationProgramMainProvider programPvd,OverAllUse overAllPvd){
    if(index == 0){
      return ListTile(
        title: const Text('Apply Fertilizer',style: TextStyle(color: Colors.black,fontSize: 14),),
        // leading: SizedBox(
        //   width: 30,
        //   height: 30,
        //   child: SvgPicture.asset(
        //       'assets/images/default_icon.svg',
        //       semanticsLabel: 'Acme Logo'
        //   ),
        // ),
        leading: const Icon(Icons.add_alert,),
        trailing: Checkbox(
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
            value: programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizerForCentral' : 'applyFertilizerForLocal'],
            onChanged: (value){
              programPvd.editGroupSiteInjector(programPvd.segmentedControlCentralLocal == 0 ? 'applyFertilizer' : 'applyFertilizer', value);
            }
        ),
      );
    }
    else if(index == 1){
      return ListTile(
          title: const Text('Pre - Post Method',style: TextStyle(color: Colors.black,fontSize: 14),),
          // subtitle: const Text('Method',style: TextStyle(color: Colors.white)),
          // leading: SizedBox(
          //   width: 30,
          //   height: 30,
          //   child: SvgPicture.asset(
          //       'assets/images/default_icon.svg',
          //       semanticsLabel: 'Acme Logo'
          //   ),
          // ),
          leading: const Icon(Icons.add_alert,),
          trailing:  DropdownButton(
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,size: 15,),
            value: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'],
            underline: Container(),
            items: ['Time','Quantity'].map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items,style: const TextStyle(fontSize: 12,color: Colors.black),),
              );
            }).toList(),
            onChanged: (value) {
              programPvd.editPrePostMethod('prePostMethod',programPvd.selectedGroup,value.toString());
            },
          )
      );
    }
    else if(index == 2){
      return ListTile(
        title: const Text('Pre Value',style: TextStyle(color: Colors.black,fontSize: 14),),
        // subtitle: const Text('Value',style: TextStyle(color: Colors.white)),
        // leading: SizedBox(
        //   width: 30,
        //   height: 30,
        //   child: SvgPicture.asset(
        //       'assets/images/default_icon.svg',
        //       semanticsLabel: 'Acme Logo'
        //   ),
        // ),
        leading: const Icon(Icons.add_alert,),
        trailing: SizedBox(
          width: 100,
          height: 30,
          child: Center(
              child: Transform.scale(
                scale: 0.8,
                child: SizedBox(
                  width: 80,
                  height: 28,
                  child: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'] == 'Quantity' ? TextFormField(
                    cursorColor: Colors.black,
                    controller: programPvd.preValue,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14,color: Colors.black),
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        counterText: '',
                        contentPadding: EdgeInsets.only(bottom: 5),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1)
                        )
                    ),
                    onChanged: (value){
                      dynamic result = programPvd.editPrePostMethod('preValue',programPvd.selectedGroup,value);
                      if(result != null){
                        closeKeyboard(context);
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: const Text('Limitation Alert!',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                            content: Text('${result['message']}',style: const TextStyle(fontSize: 14)),
                            actions: [
                              InkWell(
                                onTap: (){
                                  closeKeyboard(context);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 80,
                                  height: 30,
                                  color: Theme.of(context).primaryColor,
                                  child: const Center(
                                    child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                      }
                      setState(() {

                      });
                    },
                  ) :  InkWell(
                    onTap: (){
                      _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'pre',programPvd.sequenceData[programPvd.selectedGroup]['preValue'],'pre');
                    },
                    child: SizedBox(
                      width: 80,
                      height: 40,
                      child: Center(
                        child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['preValue']}',style: const TextStyle(color: Colors.black,fontSize: 16),),
                      ),
                    ),
                  ),
                ),
              )
          ),
        ),
      );
    }
    else{
      return ListTile(
        title: const Text('Post Value',style: TextStyle(color: Colors.black,fontSize: 14),),
        // subtitle: const Text('Value',style: TextStyle(color: Colors.white)),
        // leading: SizedBox(
        //   width: 30,
        //   height: 30,
        //   child: SvgPicture.asset(
        //     'assets/images/default_icon.svg',
        //   ),
        // ),
        leading: const Icon(Icons.add_alert,),
        trailing: SizedBox(
          width: 100,
          height: 30,
          child: Center(
              child: Transform.scale(
                scale: 0.8,
                child: SizedBox(
                  width: 80,
                  height: 28,
                  child: programPvd.sequenceData[programPvd.selectedGroup]['prePostMethod'] == 'Quantity' ? TextFormField(
                    cursorColor: Colors.black,
                    controller: programPvd.postValue,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14,color: Colors.black),
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        counterText: '',
                        contentPadding: EdgeInsets.only(bottom: 5),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1)
                        )
                    ),
                    onChanged: (value){
                      dynamic result = programPvd.editPrePostMethod('postValue',programPvd.selectedGroup,value);
                      if(result != null){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: const Text('Limitation Alert!',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                            content: Text('${result['message']}',style: const TextStyle(fontSize: 14)),
                            actions: [
                              InkWell(
                                onTap: (){
                                  closeKeyboard(context);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 80,
                                  height: 30,
                                  color: Theme.of(context).primaryColor,
                                  child: const Center(
                                    child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                      }
                      setState(() {

                      });
                    },
                  ) :  InkWell(
                    onTap: (){
                      _showTimePicker(programPvd,overAllPvd,programPvd.selectedGroup,'post',programPvd.sequenceData[programPvd.selectedGroup]['postValue'],'post');
                    },
                    child: SizedBox(
                      width: 80,
                      height: 40,
                      child: Center(
                        child: Text('${programPvd.sequenceData[programPvd.selectedGroup]['postValue']}',style: const TextStyle(color: Colors.black,fontSize: 16),),
                      ),
                    ),
                  ),
                ),
              )
          ),
        ),
      );
    }

  }

}



Widget listOfSequence(Widget myWidget,BoxConstraints constraints){
  return Container(
      decoration: BoxDecoration(
        color: listOfSeqColor,
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: violetBorder,width: 0.5)
      ),
      padding: const EdgeInsets.only(top: 10),
      height: constraints.maxHeight,
      width: 150,
      child: SingleChildScrollView(child: myWidget)
  );
}

// List getLiters(totalLiters){
//   var list = [];
//   dynamic liter = 0;
//   for(var i = 0;i < 7;i++){
//     liter += totalLiters/7;  a
//     list.add(liter);
//   }
//   return list;
// }

Widget sequenceWidget({required bool top,required bool bottom,required int seq,required IrrigationProgramMainProvider programPvd}){
  return  SizedBox(
    width: 100,
    height: 50,
    child: Stack(
      children: [
        Center(
          child: InkWell(
            onTap: (){
              programPvd.editGroupSiteInjector('selectedGroup', seq);
              if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].isNotEmpty){
                programPvd.editSegmentedCentralLocal(0);
              }else if(programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].isNotEmpty){
                programPvd.editSegmentedCentralLocal(1);
              }
              // if(programPvd.segmentedControlCentralLocal == 0){
              //   if(!programPvd.selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)){
              //     programPvd.editGroupSiteInjector('selectedCentralSite', 0);
              //   }else{
              //     for(var i = 0;i < programPvd.selectionModel.data!.centralFertilizerSite!.length;i++){
              //       if(programPvd.selectionModel.data!.centralFertilizerSite![i].selected == true){
              //         for(var j = 0;j < programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'].length;j++){
              //           if(programPvd.sequenceData[programPvd.selectedGroup]['centralDosing'][j]['sNo'] == programPvd.selectionModel.data!.centralFertilizerSite![i].sNo){
              //             programPvd.editGroupSiteInjector('selectedCentralSite', j);
              //           }
              //         }
              //       }
              //     }
              //   }
              // }else{
              //   if(!programPvd.selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)){
              //     programPvd.editGroupSiteInjector('selectedLocalSite', 0);
              //   }else{
              //     for(var i = 0;i < programPvd.selectionModel.data!.localFertilizerSite!.length;i++){
              //       if(programPvd.selectionModel.data!.localFertilizerSite![i].selected == true){
              //         for(var j = 0;j < programPvd.sequenceData[programPvd.selectedGroup]['localDosing'].length;j++){
              //           if(programPvd.sequenceData[programPvd.selectedGroup]['localDosing'][j]['sNo'] == programPvd.selectionModel.data!.localFertilizerSite![i].sNo){
              //             programPvd.editGroupSiteInjector('selectedLocalSite', j);
              //           }
              //         }
              //       }
              //     }
              //   }
              // }
            },
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                gradient: seq == programPvd.selectedGroup ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff1C7C8A),
                      Color(0xff03464F)
                    ]
                ) : null,
                border: Border.all(width: 1,color: const Color(0xff03464F)),
                borderRadius: BorderRadius.circular(10),
                // color: seq == programPvd.selectedGroup ? Colors.white : null
              ),
              child: Center(child: Text('Sequence ${seq + 1}',style: TextStyle(fontWeight: fw200,color: seq == programPvd.selectedGroup ? Colors.white : Colors.black),)),
            ),
          ),
        ),
        if(top == true)
          Positioned(
              bottom: 40,
              left: 45,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(width: 1,color: const Color(0xff03464F))
                ),
              )
          ),

        if(bottom == true)
          Positioned(
              top: 40,
              left: 45,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(width: 1,color: const Color(0xff03464F))
                ),
              )
          ),
      ],
    ),
  );
}

BorderSide border_1 = const BorderSide(width: 5,color: Color(0xff2B5C4B));
BorderSide border_0 = const BorderSide(width: 0);
Radius radius_20 = const Radius.circular(20);

Widget mySegmentedController({required int segmentedControlValue,required Map<int, Widget> option,required void Function(int?) onChanged}){
  return SizedBox(
      width: 150,
      height: 40,
      child: CupertinoSlidingSegmentedControl(
        thumbColor: liteViolet,
        groupValue: segmentedControlValue,
        children: option,
        backgroundColor: Colors.white,
        onValueChanged: onChanged,
      )
  );
}

Widget currentSequence(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const SizedBox(width: 10,),
      SizedBox(
        width: 30,
        height: 30,
        child: SvgPicture.asset(
            'assets/images/default.svg',
            semanticsLabel: 'Acme Logo'
        ),
      ),
      const SizedBox(width: 10,),
      const Text('Sequence 1.1',style: TextStyle(color: Colors.black),),
      const SizedBox(width: 10,),
    ],
  );
}

Widget currentSequenceDetails(IrrigationProgramMainProvider programPvd){
  return  Expanded(
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for(var i in programPvd.sequenceData[programPvd.selectedGroup]['valve'])
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.shade50,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade100,offset: const Offset(0,2))
                    ]
                ),
                child: Text('${i['name']}',style: TextStyle(fontWeight: fw200,color: Colors.black,fontSize: 12),),
              )
          ],
        ),
      ),

    ),
  );
}

double returnWidth(IrrigationProgramMainProvider programPvd,String preOrPostValue,double screenWidth){
  var water = programPvd.waterValueInSec();
  var ratio = water / (preOrPostValue == 'pre' ? programPvd.preValueInSec() : programPvd.postValueInSec());
  return (ratio == 0 || water == 0 || ratio.isInfinite) ? 0 : screenWidth/ratio;
}

double returnWidthForProMethod(IrrigationProgramMainProvider programPvd,double screenWidth){
  var water = programPvd.waterValueInSec();
  var value = water - programPvd.preValueInSec() - programPvd.postValueInSec();
  var ratio = water/value;
  // // print('value : ${screenWidth/ratio}');
  return (ratio == 0 || water == 0 || ratio.isInfinite) ? 0 : screenWidth/ratio;
}

double returnWidthForFertilizer(IrrigationProgramMainProvider programPvd,dynamic fertilizer,double screenWidth){
  var water = programPvd.waterValueInSec();
  var ratio = water / programPvd.fertilizerValueInSec(fertilizerData: fertilizer);
  return (ratio == 0 || water == 0 || ratio.isInfinite ) ? 0 : screenWidth/ratio;
}

List<double> generateValuesLiters(double givenValue) {
  // print('givenValue : $givenValue');
  List<double> values = [];
  int step = (givenValue / (givenValue < 3 ? 2 : 4)).round(); // Calculate step size
  for (int i = 0; i <= givenValue; i += step) {
    values.add(i.toDouble());
  }
  if (values.length < 5) {
    values.add(givenValue);
  }
  return values;
}


List<Widget> generateTimeValues(String inputTime) {
  // // print('inputTime : $inputTime');
  // Split the input time into hours, minutes, and seconds
  print('inputTime : $inputTime');
  List<Widget> values = [];

  if(inputTime != ''){
    List<String> parts = inputTime.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    // Calculate the total number of hours
    double totalHours = hours + (minutes / 60) + (seconds / 3600);

    // Calculate the step size
    double step = totalHours / 4;

    // Generate five evenly spaced time values
    for (double i = 0; i <= totalHours; i += step) {
      int remainingHours = i.floor();
      int remainingMinutes = ((i - remainingHours) * 60).floor();
      values.add(Text('${remainingHours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:00',style: graphTextStyle));
    }
    if (values.length < 5) {
      // If fewer than five values, add the given value
      values.add(Text(inputTime,style: graphTextStyle));
    }
  }

  return values;
}

String formatTime(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  String hoursStr = hours.toString().padLeft(2, '0');
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');

  return '$hoursStr:$minutesStr:$secondsStr';
}


Color violetBorder = const Color(0xff8833FF);
Color liteViolet = const Color(0xffE2D5FF);
Color liteOrange = const Color(0xffFFF7E5);
FontWeight fw200 = FontWeight.w200;
Color listOfSeqColor = Colors.white;
TextStyle graphTextStyle = const TextStyle(fontSize: 10);
List<BoxShadow> customBoxShadow = [
  BoxShadow(
      offset: const Offset(0,45),
      blurRadius: 112,
      color: Colors.black.withOpacity(0.06)
  ),
  BoxShadow(
      offset: const Offset(0,22.78),
      blurRadius: 48.83,
      color: Colors.black.withOpacity(0.04)
  ),
  BoxShadow(
      offset: const Offset(0,9),
      blurRadius: 18.2,
      color: Colors.black.withOpacity(0.03)
  ),
  BoxShadow(
      offset: const Offset(0,1.97),
      blurRadius: 6.47,
      color: Colors.black.withOpacity(0.02)
  ),
];

List<dynamic> returnSelectedSiteRecipe(IrrigationProgramMainProvider programPvd){
  var list = [];
  // print('recipe : ${programPvd.recipe}');
  for(var i in programPvd.recipe){
    var selectedSite = programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite'];
    if(selectedSite != -1){
      if(programPvd.sequenceData[programPvd.selectedGroup][programPvd.segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][selectedSite]['sNo'] == i['sNo']){
        list = i['recipe'];
      }
    }
  }
  // print('selected recipe : ${list}');
  return list;
}

Widget customizeGridView({required double maxWith,required double maxHeight,required double screenWidth,required List<Widget> listOfWidget}){
  var eachRowCount = (screenWidth - 20)~/(maxWith+10);
  List<List<Widget>> gridWidgetRow = [];
  for(var i = 0;i < listOfWidget.length;i +=(listOfWidget.length - i) < eachRowCount ? (listOfWidget.length - i) : eachRowCount){
    List<Widget> rows = [];
    for(var j = 0;j < ((listOfWidget.length - i) < eachRowCount ? (listOfWidget.length - i) : eachRowCount);j++){
      rows.add(listOfWidget[i + j]);
    }
    gridWidgetRow.add(rows);
  }
  return Column(
    children: [
      for(var row in gridWidgetRow)
        SizedBox(
          width: screenWidth,
          height: maxHeight+20,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: screenWidth,
                height: maxHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for(var widget = 0;widget < row.length;widget++)
                      Row(
                        mainAxisAlignment: eachRowCount == 1 ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: (((screenWidth - 20) - (eachRowCount * maxWith))/eachRowCount)/2.toInt().toDouble(),
                          ),
                          SizedBox(
                              width: maxWith,
                              height: maxHeight,
                              child: row[widget]
                          ),
                          SizedBox(
                            width: (((screenWidth - 20) - (eachRowCount * maxWith))/eachRowCount)/2.toInt().toDouble(),
                          ),
                        ],
                      )
                  ],
                ),
              ),

              // SizedBox(height: 10,)
            ],
          ),
        ),
    ],
  );
}


TextStyle wf = const TextStyle(fontSize: 12);
Widget mySeqButtons({required String name,required void Function() onTap,double? radius,double? verticalPadding,int? index,required IrrigationProgramMainProvider programPvd}){
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 10,horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 5),
          color: index != null ? (index == programPvd.selectedGroup ? const Color(0xff1A7886) : null) : const Color(0xff1A7886)
      ),
      child: Center(child: Text(name,style: TextStyle(color: index != null ? (index == programPvd.selectedGroup ? Colors.white : Colors.black87) : Colors.white,fontSize: 14,fontWeight: FontWeight.w200),)),
    ),
  );
}