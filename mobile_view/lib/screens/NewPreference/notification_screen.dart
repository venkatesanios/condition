import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/preference_provider.dart';
import '../../ListOfFertilizerInSet.dart';
import '../../widget/SCustomWidgets/custom_list_tile.dart';
import '../../widget/SCustomWidgets/custom_segmented_control.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late PreferenceProvider preferenceProvider;
  final ScrollController scrollController1 = ScrollController();
  final ScrollController scrollController2 = ScrollController();
  int selectedIndex = 0;

  @override
  void initState() {
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: false);
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: true);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isScreenSizeLarge = constraints.maxWidth >= 550;
        return Column(
          children: [
            const SizedBox(height: 10,),
            CustomSegmentedControl(
              segmentTitles: const {
                0: 'Events',
                1: 'Alarms',
              },
              groupValue: selectedIndex,
              onChanged: (value) {
                setState(() {
                  selectedIndex = value!;
                });
              },
            ),
            Expanded(
              child: selectedIndex == 0
                  ? Padding(
                padding: isScreenSizeLarge ? const EdgeInsets.symmetric(horizontal: 50, vertical: 20) : const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: _buildNotificationList(context, 'event', constraints),
              )
                  : Padding(
                padding: isScreenSizeLarge ? const EdgeInsets.symmetric(horizontal: 50, vertical: 20) : const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: _buildNotificationList(context, 'alarm', constraints),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationList(BuildContext context, String category, BoxConstraints constraints) {
    final notifications = category == 'event'
        ? preferenceProvider.eventNotificationData
        : preferenceProvider.alarmNotificationData;

    return ListView.builder(
      itemCount: notifications!.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 700 ? 10 : 200, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: customBoxShadow,
                  color: Colors.white
              ),
              child: CustomCheckBoxListTile(
                subtitle: notification.notificationDescription,
                value: notification.value ?? false,
                onChanged: (newValue) {
                  setState(() {
                    notification.value = newValue!;
                  });
                },
                borderRadius: BorderRadius.circular(15),
                showCircleAvatar: true,
                content: const IconData(0xf0164, fontFamily: 'MaterialIcons'),
                // icon: notification.iconCodePoint.length < 6 ? IconData(int.parse(notification.iconCodePoint), fontFamily: notification.iconFontFamily) : IconData(0xf0164, fontFamily: notification.iconFontFamily)
              ),
            ),
            if (index == notifications.length - 1)
              const SizedBox(height: 50),
          ],
        );
      },
    );
  }
}
