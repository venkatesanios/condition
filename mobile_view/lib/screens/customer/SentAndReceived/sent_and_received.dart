import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:provider/provider.dart';
import '../../../ListOfFertilizerInSet.dart';
import '../../../constants/http_service.dart';
import 'package:intl/intl.dart';
import '../../../state_management/overall_use.dart';

class SentAndReceived extends StatefulWidget {
  SentAndReceived({super.key});

  @override
  State<SentAndReceived> createState() => _SentAndReceivedState();
}

class _SentAndReceivedState extends State<SentAndReceived> {
  List<Message> messages = [];
  List<Notification> notifications = [];
  // List<DateTime> dates = List.generate(1, (index) => DateTime.now().subtract(Duration(days: index)));
  // DateTime startDate = DateTime.now();
  // DateTime endDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  CalendarFormat _calendarFormat2 = CalendarFormat.week;
  DateTime _focusedDay2 = DateTime.now();
  late OverAllUse overAllPvd;
  final validPassword = "Oro@321";
  TextEditingController passwordController = TextEditingController();
  dynamic sentPayload = '';
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool showNotificationHistory = false;

  @override
  void initState() {
    super.initState();
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    getUserSentAndReceivedMessageStatus();
  }

  Future<void> getUserSentAndReceivedMessageStatus() async {
    var data = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      final getUserSentAndReceivedMessageStatus = await HttpService().postRequest("getUserSentAndReceivedMessageStatus", data);
      final response = jsonDecode(getUserSentAndReceivedMessageStatus.body);
      if (getUserSentAndReceivedMessageStatus.statusCode == 200) {
        await Future.delayed(Duration.zero, () {
          setState(() {
            if (response['data'] is List) {
              messages = (response['data'] as List).map((e) => Message.fromJson(e)).toList();
            } else {
              log('Data is not a List');
            }
          });
        });
        // if (response['data'] is List) {
        //   setState(() {
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       _scrollController.animateTo(
        //         _scrollController.position.maxScrollExtent,
        //         duration: Duration(milliseconds: 200),
        //         curve: Curves.easeInOut,
        //       );
        //     });
        //   });
        // }
      } else {
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      log("$e");
      log("stackTrace ==> $stackTrace");
    }
  }

  Future<void> getUserPushNotification() async {
    var data = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      notifications.clear();
      final getUserPushNotification = await HttpService().postRequest("getUserPushNotification", data);
      final response = jsonDecode(getUserPushNotification.body);
      if (getUserPushNotification.statusCode == 200) {
        await Future.delayed(Duration.zero, () {
          setState(() {
            if (response['data'] is List) {
              notifications = (response['data'] as List).map((e) => Notification.fromJson(e)).toList();
            } else {
              log('Data is not a List');
            }
          });
        });
      } else {
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      log("$e");
      log("stackTrace ==> $stackTrace");
    }
  }

  Future<void> getUserSentAndReceivedHardwarePayload(int sentAndReceivedId) async {
    var data = {
      "userId": overAllPvd.userId,
      "controllerId": overAllPvd.controllerId,
      "sentAndReceivedId": sentAndReceivedId,
    };

    print(data);
    try {
      sentPayload = "";
      final getUserSentAndReceivedHardwarePayload = await HttpService().postRequest("getUserSentAndReceivedHardwarePayload", data);
      final response = jsonDecode(getUserSentAndReceivedHardwarePayload.body);
      if (getUserSentAndReceivedHardwarePayload.statusCode == 200) {
        if(response['code'] == 200) {
          sentPayload = jsonEncode((response['data']['message'] is String || response['data']['message'] == null) ? response['data'] : response['data']['message']);
          // print("sentPayload ==> $sentPayload");
          // sentPayload = getUserSentAndReceivedHardwarePayload.body;
        } else {
          sentPayload = jsonEncode(response);
        }
      } else {
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      log("$e");
      log("stackTrace ==> $stackTrace");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      appBar: AppBar(
        title: showNotificationHistory ? Text("Notification history", style: TextStyle(color: Theme.of(context).primaryColor),) :TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.5)),
          ),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Theme.of(context).primaryColor,
        ),
        actions: [
          IconButton(
              onPressed: () async{
                setState(() {
                  showNotificationHistory = !showNotificationHistory;
                });
                if(showNotificationHistory) {
                  await getUserPushNotification();
                } else {
                  await getUserSentAndReceivedMessageStatus();
                }
                // showNotificationsHistory();
              },
              icon: Icon(!showNotificationHistory ? Icons.notifications_active_rounded : Icons.message, color: Colors.orangeAccent,)
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  width: 0.3,
                ),
              ),
            ),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.now(),
              calendarFormat: _calendarFormat,
              headerStyle: HeaderStyle(headerPadding: EdgeInsets.symmetric(vertical: 0)),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
                if(showNotificationHistory) {
                  getUserPushNotification();
                } else {
                  getUserSentAndReceivedMessageStatus();
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          if(showNotificationHistory)
            Expanded(
                child: ListView.builder(
                    itemCount: notifications.isNotEmpty ? notifications.length : 1,
                    itemBuilder: (BuildContext context, int index) {
                      // print(notifications[index].);
                      if(notifications.isNotEmpty) {
                        return Column(
                          children: [
                            TimelineTile(notification: notifications[index],),
                            if(index == notifications.length - 1)
                              SizedBox(height: 50,)
                          ],
                        );
                      } else {
                        return Center(child: Text("Data not found"),);
                      }
                    }
                )
            )
          else
            Expanded(
              child: messages
                  .where((element) =>
              element.date == selectedDate.toString().split(' ')[0] &&
                  element.message.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList()
                  .isNotEmpty
                  ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: messages.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  if (selectedDate.toString().split(' ')[0] == message.date &&
                      message.message.toLowerCase().contains(searchQuery.toLowerCase())) {
                    return Column(
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            if (passwordController.text == validPassword) {
                              await getUserSentAndReceivedHardwarePayload(messages[index].sentAndReceivedId);
                              showPayloadDialog(message);
                            } else {
                              await showPasswordDialog(message);
                            }
                          },
                          onTap: () async {
                            if (passwordController.text == validPassword) {
                              await getUserSentAndReceivedHardwarePayload(messages[index].sentAndReceivedId);
                              showPayloadDialog(message);
                            }
                          },
                          child: ChatMessageBubble(
                            isSent: message.messageType == "SENT",
                            message: message.message,
                            time: message.time,
                            date: message.date,
                            sentUser: message.sentUser,
                            sentMobileNumber: message.sentMobileNumber,
                          ),
                        ),
                        if (index == messages.length - 1) const SizedBox(height: 60),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              )
                  : const Center(
                child: Text(
                  "User message not found",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            icon: const Icon(Icons.arrow_circle_up, color: Colors.green),
          ),
          IconButton(
            onPressed: () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            icon: const Icon(Icons.arrow_circle_down, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> showPasswordDialog(Message message) async {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sentPayload.isEmpty)
                    TextFormField(
                      controller: passwordController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Enter password",
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (passwordController.text != validPassword)
                    const Text('Invalid password', style: TextStyle(color: Colors.red)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () async {
                    if (passwordController.text == validPassword) {
                      await getUserSentAndReceivedHardwarePayload(message.sentAndReceivedId);
                      Navigator.pop(context);
                      showPayloadDialog(message);
                      stateSetter(() {});
                    } else {
                      stateSetter(() {});
                    }
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showPayloadDialog(Message message) async {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      // barrierColor: const Color(0xff6600),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Scaffold(
            body: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(message.message, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
                    subtitle: Text(message.messageType == "SENT" ? "Software payload" : "Hardware payload"),
                  ),
                  if (sentPayload != null && sentPayload.isNotEmpty)
                    JsonView.string(
                      sentPayload,
                      theme: JsonViewTheme(
                          backgroundColor: Colors.transparent,
                        openIcon: Icon(Icons.arrow_drop_down, color: Colors.black,),
                        closeIcon: Icon(Icons.arrow_drop_up, color: Colors.black,),
                        viewType: JsonViewType.collapsible,
                        defaultTextStyle: TextStyle(color: Colors.black),
                        keyStyle: TextStyle(color: Colors.black),
                        stringStyle: TextStyle(color: Colors.green),
                      ),
                    ) else
                    Text(sentPayload.toString())
                ],
              ),
            ),
            floatingActionButton: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: customBoxShadow
                ),
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.keyboard_double_arrow_left),
                    Text('Go Back'),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }
}

class TimelineTile extends StatelessWidget {
  final Notification notification;

  TimelineTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Dot
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16,),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                width: 2,
                height: 80,
                color: Colors.grey, // Line for timeline
              ),
            ],
          ),
        ),
        // Notification Content
        Expanded(
          child: Container(
            // margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // SizedBox(height: 4),
                Card(
                    margin: EdgeInsets.only(bottom: 5, right: 15),
                    elevation: 1,
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child:  ListTile(
                      title: Text(notification.notificationMessage),
                      // subtitle: Text(notification.notificationMessage.split(':')[1]),
                      leading: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffFFD5D5)
                        ),
                        child: Icon(Icons.directions_run, size: 20,),
                      ),
                    )
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final bool isSent;
  final String message;
  final String time;
  final String date;
  final String? sentUser;
  final String? sentMobileNumber;

  const ChatMessageBubble({
    Key? key,
    required this.isSent,
    required this.message,
    required this.time,
    required this.date,
    this.sentUser,
    this.sentMobileNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSent) _buildAvatar(context),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CustomPaint(
                            painter: ChatBubblePainter(isSent),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isSent && sentUser != null)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: sentUser,
                                            style: TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "   $sentMobileNumber",
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if(isSent) const SizedBox(height: 8),
                                  Text(message, style: const TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Text(time, style: const TextStyle(color: Colors.black, fontSize: 10)),
                    ],
                  ),
                ),
                if (isSent) const SizedBox(width: 5),
                if (isSent) _buildAvatar(context),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSent ? Colors.grey.withOpacity(0.5) : const Color(0xff40A3B1).withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: isSent ? const Color(0xffFDFDFD) : const Color(0xffE0FFF7),
        radius: 15,
        child: isSent
            ? Text(
          (sentUser?.split(" ").first[0] ?? '') + (sentUser?.split(" ").last[0] ?? ''),
          style: const TextStyle(color: Colors.purple, fontSize: 12),
        )
            : Icon(Icons.computer, color: Theme.of(context).primaryColor, size: 15,),
      ),
    );
  }

}

class ChatBubblePainter extends CustomPainter {
  final bool isMe;
  final Color borderColor;
  final double borderWidth;

  ChatBubblePainter(this.isMe, {this.borderColor = const Color(0xff000000), this.borderWidth = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    // Create the paint for the bubble fill
    final fillPaint = Paint()
      ..color = isMe ? const Color(0xffFDFDFD) : const Color(0xffE0FFF7)
      ..style = PaintingStyle.fill;

    // Create the paint for the bubble border
    final borderPaint = Paint()
      ..color = isMe ? Colors.grey.withOpacity(0.5) : Color(0xff40A3B1).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Define the path for the bubble
    final path = Path();
    if (isMe) {
      // Right-aligned bubble
      path.moveTo(10, 0);
      path.lineTo(size.width + 10, 0);
      path.quadraticBezierTo(size.width, 10, size.width, 10);
      path.lineTo(size.width, size.height - 10);
      path.quadraticBezierTo(size.width, size.height, size.width - 10, size.height);
      path.lineTo(20, size.height);
      path.lineTo(10, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - 10);
      path.lineTo(0, 10);
      path.quadraticBezierTo(0, 0, 10, 0);
    } else {
      // Left-aligned bubble
      path.moveTo(size.width - 10, 0);
      path.lineTo(-10, 0);
      path.quadraticBezierTo(0, 10, 0, 10);
      path.lineTo(0, size.height - 10);
      path.quadraticBezierTo(0, size.height, 10, size.height);
      path.lineTo(size.width - 20, size.height);
      path.lineTo(size.width - 10, size.height);
      path.quadraticBezierTo(size.width, size.height, size.width, size.height - 10);
      path.lineTo(size.width, 10);
      path.quadraticBezierTo(size.width, 0, size.width - 10, 0);
    }

    // Draw the fill
    canvas.drawPath(path, fillPaint);

    // Draw the border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Message {
  final String messageType;
  final int sentAndReceivedId;
  final String date;
  final String time;
  final String message;
  final String sentUser;
  final String sentMobileNumber;

  Message({
    required this.messageType,
    required this.sentAndReceivedId,
    required this.date,
    required this.time,
    required this.message,
    required this.sentUser,
    required this.sentMobileNumber
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageType: json['messageType'],
      sentAndReceivedId: json['sentAndReceivedId'],
      date: json['date'],
      time: json['time'],
      message: json['message'],
      sentUser: json['sentUser'],
      sentMobileNumber: json['sentMobileNumber'],
    );
  }
}

class Notification {
  final String date;
  final String time;
  final String notificationMessage;

  Notification({
    required this.date,
    required this.time,
    required this.notificationMessage
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
        date: json['date'],
        time: json['time'],
        notificationMessage: json['notificationMessage']
    );
  }
}