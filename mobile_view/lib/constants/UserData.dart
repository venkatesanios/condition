import 'package:flutter/material.dart';

class UserData extends InheritedWidget {
  final int userId;
  final String userType, userName, countryCode, mobileNo, userEmailId, password;

  const UserData({super.key,
    required this.userId,
    required this.userType,
    required this.userName,
    required this.countryCode,
    required this.mobileNo,
    required this.userEmailId,
    required this.password,
    required Widget child,
  }) : super(child: child);

  static UserData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserData>();
  }

  @override
  bool updateShouldNotify(UserData oldWidget) {
    return userId != oldWidget.userId || userName != oldWidget.userName || userType != oldWidget.userType
        || countryCode != oldWidget.countryCode || mobileNo != oldWidget.mobileNo || userEmailId != oldWidget.userEmailId
        || password != oldWidget.password;
  }

}