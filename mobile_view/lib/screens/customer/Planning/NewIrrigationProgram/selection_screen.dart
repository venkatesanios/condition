import 'package:flutter/material.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/schedule_screen.dart';
import 'package:mobile_view/screens/customer/Planning/NewIrrigationProgram/sequence_screen.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/irrigation_program_main_provider.dart';
import '../../../../widget/SCustomWidgets/custom_animated_switcher.dart';
import 'conditions_screen.dart';

final purpleLight = const Color(0xff8833FF).withOpacity(0.05);
final purpleDark = const Color(0xff8833FF).withOpacity(0.35);
final redLight = const Color(0xffFFF7E5).withOpacity(0.5);
final redDark = const Color(0xffFF857D).withOpacity(0.35);
final greenLight = const Color(0xffECF5EF).withOpacity(0.5);
final greenDark = const Color(0xff10E196).withOpacity(0.35);
const yellowLight = Color(0xffFFF7E5);
const yellowDark = Color(0xfffdce7f);
final primaryColorLight = const Color(0xffE3FFF5).withOpacity(0.5);

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> with SingleTickerProviderStateMixin{
  late IrrigationProgramMainProvider irrigationProgramProvider;
  late AnimationController ctrlValue;

  @override
  void initState() {
    super.initState();
    ctrlValue = AnimationController(vsync: this,duration: const Duration(seconds: 1));
    ctrlValue.addListener(() {setState(() {});});
    ctrlValue.repeat();
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    if(irrigationProgramProvider.selectionModel!.data.headUnits!.length == 1) {
      irrigationProgramProvider.selectionModel!.data.headUnits![0].selected = true;
    }
    irrigationProgramProvider.calculateTotalFlowRate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    ctrlValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context);
    final selectionData = irrigationProgramProvider.selectionModel!.data;
    final primaryColorDark = Theme.of(context).primaryColor.withOpacity(0.35);
    final centralFilterCondition = irrigationProgramProvider.selectionModel!.data.centralFilter!.isNotEmpty ?
    irrigationProgramProvider.selectionModel!.data.centralFilter!
        .where((ecSensor) => irrigationProgramProvider.selectionModel!.data.centralFilterSite!
        .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false;
    final localFilterCondition = irrigationProgramProvider.selectionModel!.data.localFilter!.isNotEmpty ?
    irrigationProgramProvider.selectionModel!.data.localFilter!
        .where((ecSensor) => irrigationProgramProvider.selectionModel!.data.localFilterSite!
        .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.width * 0.025,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle(title: "General"),
                buildSection(
                  title: "Main Valves",
                  dataList: selectionData.mainValve,
                  lightColor: yellowLight,
                  darkColor: yellowDark,
                  image: Image.asset(
                    'assets/images/m_valve.png',
                  ),
                ),
                buildSection(
                  title: "Head Units",
                  dataList: selectionData.headUnits,
                  lightColor: greenLight,
                  darkColor: greenDark,
                  image: Image.asset(
                    'assets/images/irrigation_line1.png',
                  ),
                ),
                if(selectionData.irrigationPump!.length > 1)
                  buildListTile(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                      context: context,
                      title: "Enable pump station mode",
                      subTitle: "Automated pump selection based on flow",
                      icon: Icons.heat_pump,
                      textColor: Colors.black,
                      trailing: Switch(
                          value: irrigationProgramProvider.isPumpStationMode,
                          onChanged: (newValue) => irrigationProgramProvider.updatePumpStationMode(newValue, 0)
                      )
                  ),
                if(irrigationProgramProvider.isPumpStationMode)
                  const SizedBox(height: 30,),
                if(selectionData.irrigationPump!.length > 1)
                  CustomAnimatedSwitcher(
                    condition: irrigationProgramProvider.isPumpStationMode,
                    child: buildListTile(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                        context: context,
                        title: "Change over",
                        subTitle: "Automated pump selection",
                        icon: Icons.change_circle,
                        textColor: Colors.black,
                        trailing: Switch(
                            value: irrigationProgramProvider.isChangeOverMode,
                            onChanged: (newValue) => irrigationProgramProvider.updatePumpStationMode(newValue, 1)
                        )
                    ),
                  ),
                if(selectionData.irrigationPump!.length > 1)
                  const SizedBox(height: 30,),
                CustomAnimatedSwitcher(
                    condition: !irrigationProgramProvider.isPumpStationMode,
                    child: buildSection(
                        title: "Irrigation Pumps",
                        dataList: selectionData.irrigationPump,
                        lightColor: redLight,
                        darkColor: redDark,
                        image: Image.asset(
                          'assets/images/source_pump1.png',
                        )
                    )
                ),
                if(selectionData.centralFertilizerSite!.isNotEmpty || selectionData.localFertilizerSite!.isNotEmpty)
                  buildSectionTitle(title: "Fertilizer"),
                buildSection(
                    title: "Central fertilizer site",
                    dataList: selectionData.centralFertilizerSite,
                    lightColor: purpleLight,
                    darkColor: purpleDark,
                    image: Image.asset(
                      'assets/images/central_fertilizer_site2.png',
                    )
                ),
                buildRow(
                    context: context,
                    title: "Central fert Selector",
                    dataList: selectionData.selectorForCentral,
                    lightColor: primaryColorLight,
                    darkColor: primaryColorDark,
                    height: -70.00,
                    condition: selectionData.selectorForCentral!.isNotEmpty && selectionData.centralFertilizerSite!.any((element) => element.selected == true)
                ),
                // buildSection("Central fertilizer set", selectionData.centralFertilizerSet, lightColor: yellowLight, darkColor: yellowDark),
                buildRow(
                    context: context,
                    title: "EC sensors in central site",
                    dataList:  irrigationProgramProvider.selectionModel!.data.ecSensor!.where((ecSensor) =>
                        irrigationProgramProvider.selectionModel!.data.centralFertilizerSite!.any((site) =>
                        site.id == ecSensor.location && site.selected == true)),
                    lightColor: greenLight,
                    darkColor: greenDark,
                    height: selectionData.selectorForCentral!.isNotEmpty ? -140.00: -70.00,
                    condition: irrigationProgramProvider.selectionModel!.data.ecSensor!.isNotEmpty ?
                    irrigationProgramProvider.selectionModel!.data.ecSensor!
                        .where((ecSensor) => irrigationProgramProvider.selectionModel!.data.centralFertilizerSite!
                        .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false
                ),
                buildRow(
                    context: context,
                    title: "pH sensors in central site",
                    dataList: irrigationProgramProvider.selectionModel!.data.phSensor!.where((ecSensor) =>
                        irrigationProgramProvider.selectionModel!.data.centralFertilizerSite!.any((site) =>
                        site.id == ecSensor.location && site.selected == true)),
                    lightColor: redLight,
                    darkColor: redDark,
                    height: selectionData.selectorForCentral!.isNotEmpty ? -210.0 : -140.0,
                    condition: irrigationProgramProvider.selectionModel!.data.phSensor!.isNotEmpty ?
                    irrigationProgramProvider.selectionModel!.data.phSensor!
                        .where((ecSensor) => irrigationProgramProvider.selectionModel!.data.centralFertilizerSite!
                        .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false
                ),
                buildSection(title: "Local fertilizer site", dataList: selectionData.localFertilizerSite, lightColor: purpleLight, darkColor: purpleDark),
                buildRow(
                    context: context,
                    title: "Local fert Selector",
                    dataList: selectionData.selectorForLocal,
                    lightColor: yellowLight,
                    darkColor: yellowDark,
                    height: -70.0,
                    condition: selectionData.selectorForCentral!.isNotEmpty && selectionData.localFertilizerSite!.any((element) => element.selected == true)
                ),
                // buildSection("Local fertilizer set", selectionData.localFertilizerSet, lightColor: greenLight, darkColor: greenDark),
                buildRow(
                    context: context,
                    title: "EC sensors in local site",
                    dataList: irrigationProgramProvider.selectionModel!.data.ecSensor!.where((ecSensor) =>
                        irrigationProgramProvider.selectionModel!.data.localFertilizerSite!.any((site) =>
                        site.id == ecSensor.location && site.selected == true)),
                    lightColor: greenLight,
                    darkColor: greenDark,
                    height: selectionData.selectorForLocal!.isNotEmpty ? -140.0: -70.0,
                    condition: irrigationProgramProvider.selectionModel!.data.ecSensor!.isNotEmpty ?
                    irrigationProgramProvider.selectionModel!.data.ecSensor!
                        .where((ecSensor) => irrigationProgramProvider.selectionModel!.data.localFertilizerSite!
                        .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false
                ),
                buildRow(
                    context: context,
                    title: "pH sensors in local site",
                    dataList: irrigationProgramProvider.selectionModel!.data.phSensor!.where((ecSensor) =>
                        irrigationProgramProvider.selectionModel!.data.localFertilizerSite!.any((site) =>
                        site.id == ecSensor.location && site.selected == true)),
                    lightColor: redLight,
                    darkColor: redDark,
                    height: selectionData.selectorForLocal!.isNotEmpty ? -210.0: -70.0,
                    condition: irrigationProgramProvider.selectionModel!.data.phSensor!.isNotEmpty ?
                    irrigationProgramProvider.selectionModel!.data.phSensor!
                        .where((ecSensor) => irrigationProgramProvider.selectionModel!.data.localFertilizerSite!
                        .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false
                ),
                if(selectionData.centralFilter!.isNotEmpty || selectionData.localFilter!.isNotEmpty)
                  buildSectionTitle(title: "Filters"),
                buildSection(title: "Central filter site", dataList: selectionData.centralFilterSite, lightColor: yellowLight, darkColor: yellowDark),
                buildRow(
                    context: context,
                    title: "Central filters",
                    dataList: irrigationProgramProvider.selectionModel!.data.centralFilter!.where((ecSensor) =>
                        irrigationProgramProvider.selectionModel!.data.centralFilterSite!.any((site) =>
                        site.id == ecSensor.location && site.selected == true)),
                    lightColor: greenLight,
                    darkColor: greenDark,
                    height: -70.0,
                    condition: centralFilterCondition
                ),
                if(MediaQuery.of(context).size.width > 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: centralFilterCondition,
                    child: Row(
                      children: [
                        Expanded(
                          child: buildListTile(
                            context: context,
                            title: 'Central Filter Operation Mode'.toUpperCase(),
                            subTitle: "Select central Filter operation mode",
                            textColor: Colors.black,
                            icon: Icons.filter_list_outlined,
                            trailing:  buildPopUpMenuButton(
                                context: context,
                                dataList: irrigationProgramProvider.filtrationModes,
                                onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, true),
                                selected: irrigationProgramProvider.selectedCentralFiltrationMode,
                                child: Text(irrigationProgramProvider.selectedCentralFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                            ),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: buildListTile(
                              context: context,
                              title: 'Central Filtration Beginning Only'.toUpperCase(),
                              subTitle: "Filtration preference",
                              textColor: Colors.black,
                              icon: Icons.filter_list_outlined,
                              trailing:  Switch(
                                  value: irrigationProgramProvider.centralFiltBegin,
                                  onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, true)
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: centralFilterCondition,
                    child: buildListTile(
                      context: context,
                      title: 'Central Filter Operation Mode'.toUpperCase(),
                      subTitle: "Select central Filter operation mode",
                      textColor: Colors.black,
                      icon: Icons.filter_list_outlined,
                      trailing:  buildPopUpMenuButton(
                          context: context,
                          dataList: irrigationProgramProvider.filtrationModes,
                          onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, true),
                          selected: irrigationProgramProvider.selectedCentralFiltrationMode,
                          child: Text(irrigationProgramProvider.selectedCentralFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200 && centralFilterCondition)
                  const SizedBox(height: 30,),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -210.0,
                    condition: centralFilterCondition,
                    child: buildListTile(
                        context: context,
                        title: 'Central Filtration Beginning Only'.toUpperCase(),
                        subTitle: "Filtration preference",
                        textColor: Colors.black,
                        icon: Icons.filter_list_outlined,
                        trailing:  Switch(
                            value: irrigationProgramProvider.centralFiltBegin,
                            onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, true)
                        )
                    ),
                  ),
                if(centralFilterCondition)
                  const SizedBox(height: 30,),
                buildSection(title: "Local filter site", dataList: selectionData.localFilterSite, lightColor: redLight, darkColor: redDark),
                buildRow(
                    context: context,
                    title: "Local filters",
                    dataList: irrigationProgramProvider.selectionModel!.data.localFilter!.where((ecSensor) =>
                        irrigationProgramProvider.selectionModel!.data.localFilterSite!.any((site) =>
                        site.id == ecSensor.location && site.selected == true)),
                    lightColor: purpleLight,
                    darkColor: purpleDark,
                    height: -70.0,
                    condition: irrigationProgramProvider.selectionModel!.data.localFilter!.isNotEmpty ?
                    irrigationProgramProvider.selectionModel!.data.localFilter!
                        .where((ecSensor) => irrigationProgramProvider.selectionModel!.data.localFilterSite!
                        .any((site) => site.id == ecSensor.location && site.selected == true)).isNotEmpty : false
                ),
                if(MediaQuery.of(context).size.width > 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: localFilterCondition,
                    child: Row(
                      children: [
                        Expanded(
                          child: buildListTile(
                            context: context,
                            title: 'Local Filter Operation Mode'.toUpperCase(),
                            subTitle: "Select central Filter operation mode",
                            textColor: Colors.black,
                            icon: Icons.filter_alt_outlined,
                            trailing:  buildPopUpMenuButton(
                                context: context,
                                dataList: irrigationProgramProvider.filtrationModes,
                                onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, false),
                                selected: irrigationProgramProvider.selectedLocalFiltrationMode,
                                child: Text(irrigationProgramProvider.selectedLocalFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                            ),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: buildListTile(
                              context: context,
                              title: 'Local Filtration Beginning Only'.toUpperCase(),
                              subTitle: "Filtration preference",
                              textColor: Colors.black,
                              icon: Icons.filter_list_outlined,
                              trailing:  Switch(
                                  value: irrigationProgramProvider.localFiltBegin,
                                  onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, false)
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: localFilterCondition,
                    child: buildListTile(
                      context: context,
                      title: 'Local Filter Operation Mode'.toUpperCase(),
                      subTitle: "Select central Filter operation mode",
                      textColor: Colors.black,
                      icon: Icons.filter_alt_outlined,
                      trailing:  buildPopUpMenuButton(
                          context: context,
                          dataList: irrigationProgramProvider.filtrationModes,
                          onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, false),
                          selected: irrigationProgramProvider.selectedLocalFiltrationMode,
                          child: Text(irrigationProgramProvider.selectedLocalFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200)
                  const SizedBox(height: 30,),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -210.0,
                    condition: localFilterCondition,
                    child: buildListTile(
                        context: context,
                        title: 'Local Filtration Beginning Only'.toUpperCase(),
                        subTitle: "Filtration preference",
                        textColor: Colors.black,
                        icon: Icons.filter_list_outlined,
                        trailing:  Switch(
                            value: irrigationProgramProvider.localFiltBegin,
                            onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, false)
                        )
                    ),
                  ),
                const SizedBox(height: 50,)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSection({required String title, required dataList, void Function(int)? getIndex,
    required Color lightColor, required Color darkColor, bool showSubList = false, Widget? image}) {
    if (dataList?.isNotEmpty ?? false) {
      return Column(
        children: [
          showSubList ?
          buildSubList(
            context: context,
            dataList: dataList,
            title: title,
            children: [
              if(!(title == "Central fert Selector" || title == "Local fert Selector"))
                ...dataList.map((element) {
                  return buildListOfContainer(
                    context: context,
                    onTap: () {
                      setState(() {
                        element.selected = !element.selected!;
                      });
                    },
                    itemName: element.name ?? "No name",
                    containerColor: element.selected! ? darkColor : lightColor,
                  );
                }),
              if(title == "Central fert Selector" || title == "Local fert Selector")
                for (var index = 0; index < dataList!.length; index++)
                  buildListOfContainer(
                    context: context,
                    onTap: () {
                      setState(() {
                        if (title == "Local fert Selector") {
                          // Toggle selection for Local
                          bool isCurrentlySelected = irrigationProgramProvider.selectionModel!.data.selectorForLocal![index].selected!;

                          // Unselect all selectors in Local
                          irrigationProgramProvider.selectionModel!.data.selectorForLocal!.forEach((element) {
                            element.selected = false;
                          });

                          // Unselect the corresponding selector in Central
                          irrigationProgramProvider.selectionModel!.data.selectorForCentral![index].selected = false;

                          // If the current selector was not already selected, select it
                          if (!isCurrentlySelected) {
                            irrigationProgramProvider.selectionModel!.data.selectorForLocal![index].selected = true;
                          }

                        } else {
                          // Toggle selection for Central
                          bool isCurrentlySelected = irrigationProgramProvider.selectionModel!.data.selectorForCentral![index].selected!;

                          // Unselect all selectors in Central
                          irrigationProgramProvider.selectionModel!.data.selectorForCentral!.forEach((element) {
                            element.selected = false;
                          });

                          // Unselect the corresponding selector in Local
                          irrigationProgramProvider.selectionModel!.data.selectorForLocal![index].selected = false;

                          // If the current selector was not already selected, select it
                          if (!isCurrentlySelected) {
                            irrigationProgramProvider.selectionModel!.data.selectorForCentral![index].selected = true;
                          }
                        }
                      });
                    },
                    itemName: dataList[index].name ?? "No name",
                    containerColor: dataList[index].selected! ? darkColor : lightColor,
                  )
            ],
          )
              : buildLineAndValveContainerUpdated(
            context: context,
            title: title,
            showSubList: showSubList,
            dataList: dataList,
            leading: image != null ? Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle
              ),
              child: image,
            )
                : null,
            children: [
              for (var index = 0; index < dataList!.length; index++)
                buildListOfContainer(
                  context: context,
                  onTap: () {
                    setState(() {
                      if(title == "Central fertilizer site" || title == "Local fertilizer site" || title == "Central filter site" || title == "Local filter site") {
                        if(dataList.any((element) => element.selected == true)) {
                          int oldIndex = dataList.indexWhere((element) => element.selected == true);
                          dataList![oldIndex].selected = !dataList[oldIndex].selected!;
                          if(oldIndex == index){
                            dataList![index].selected = false;
                          } else{
                            dataList![index].selected = true;
                          }
                        } else {
                          dataList![index].selected = true;
                        }
                      } else {
                        dataList[index].selected = !dataList[index].selected!;
                        print("Selected ${dataList[index].selected}");
                        print("${irrigationProgramProvider.selectionModel!.data.headUnits!.map((e) => e.toJson())}");
                      }
                    });
                  },
                  itemName: dataList[index].name ?? "No name",
                  containerColor: dataList[index].selected! ? darkColor : lightColor,
                )
            ],
          ),
          const SizedBox(height: 30),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget buildRow({required BuildContext context, required String title, required dataList,
    required darkColor, required lightColor, required height, required bool condition, child}) {
    return CustomAnimatedSwitcher(
      condition: condition,
      child: Row(
        children: [
          AnimatedLShape(height: height,),
          Expanded(
            flex: 15,
            child: child ?? buildSection(
              showSubList: true,
              title: title, dataList: dataList, lightColor: lightColor, darkColor: darkColor,
            ),
          )
        ],
      ),
    );
  }

  Widget buildSectionTitle({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: Text(title, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
    );
  }
}

class LShapeDivider extends CustomPainter{
  BuildContext context;
  double height;
  double? ctrValue;
  LShapeDivider({required this.context,required this.height, this.ctrValue});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.strokeWidth = 1;
    paint.color = Theme.of(context).primaryColorDark  ;
    canvas.drawLine(const Offset(20, 0), Offset(20+((size.width-20)*ctrValue!), 0), paint);
    canvas.drawLine(const Offset(20, 0), Offset(20, height*ctrValue!), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class AnimatedLShape extends StatefulWidget {
  final double height;
  const AnimatedLShape({super.key, required this.height});

  @override
  State<AnimatedLShape> createState() => _AnimatedLShapeState();
}

class _AnimatedLShapeState extends State<AnimatedLShape> with SingleTickerProviderStateMixin{
  late AnimationController ctrlValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ctrlValue = AnimationController(vsync: this,duration: const Duration(seconds: 1));
    ctrlValue.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    ctrlValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 10,
      child: CustomPaint(
        painter: LShapeDivider(context: context, height: widget.height, ctrValue: ctrlValue.value),
        size: const Size(1,1),
      ),
    );
  }
}

