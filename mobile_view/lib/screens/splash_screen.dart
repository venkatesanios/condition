import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_view/login_page.dart';
import 'package:mobile_view/screens/Dealer/DealerDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customer/Dashboard/Mobile Dashboard/home_screen.dart';
import 'customer/Dashboard/Mobile Dashboard/login_screenOTP/login_screenotp.dart';
import 'customer/Planning/NewIrrigationProgram/irrigation_program_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _group1Animation;
  late Animation<double> _group2Animation;
  late Animation<double> _circleAnimation1;
  late Animation<double> _circleAnimation2;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _group1Animation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceIn,
      ),
    );

    _group2Animation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 1),
      ),
    );

    _circleAnimation1 = Tween<double>(begin: 0, end: -90).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5),
      ),
    );

    _circleAnimation2 = Tween<double>(begin: -113, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5),
      ),
    );

    _animationController.forward();
    Future.delayed(const Duration(seconds: 5), () async {
      final prefs = await SharedPreferences.getInstance();
      final userIdFromPref = prefs.getString('userId') ?? '';
      final userType =  prefs.getString('userType') ?? '';

      print("userType ==> $userType");
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) {
            // userIdFromPref.isEmpty
            //     ? LoginForm() : userType=='2'?
            // DealerDashboard(userName: prefs.getString('userName')!, countryCode:  prefs.getString('countryCode')!, mobileNo:  prefs.getString('mobileNumber')!, userId: int.parse(prefs.getString('userId')!), emailId: prefs.getString('email')!):
            // HomeScreen();
            if( userIdFromPref.isEmpty) {
              return LoginScreen();
            } else {
              if(userType == "2") {
                return DealerDashboard(userName: prefs.getString('userName')!, countryCode:  prefs.getString('countryCode')!, mobileNo:  prefs.getString('mobileNumber')!, userId: int.parse(prefs.getString('userId')!), emailId: prefs.getString('email')!);
              } else if(userType == "3"){
                return HomeScreen(userId: 0, fromDealer: false,);
              } else {
                return Container();
              }
            }
          },
          transitionsBuilder: (context, animation1, animation2, child) {
            return FadeTransition(
              opacity: animation1,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: const BoxDecoration(
              gradient: linearGradientLeading,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _circleAnimation1,
                  builder: (context, child) {
                    return Positioned(
                      top: constraints.maxHeight * 0.01 + _circleAnimation1.value,
                      left: 0,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                ],
                                radius: 1.5
                            )
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _circleAnimation2,
                  builder: (context, child) {
                    return Positioned(
                      top: constraints.maxHeight * 0.01 + _circleAnimation2.value,
                      left: -113,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                ],
                                radius: 1.5
                            )
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _group2Animation,
                  builder: (context, child) {
                    return Positioned(
                      top: 300,
                      child: Transform.scale(
                        scale: _group1Animation.value,
                        child: SvgPicture.asset(
                          'assets/SVGPicture/oro_logo_white.svg',
                          width: constraints.maxWidth - 250,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _group2Animation,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 150,
                      child: Transform.rotate(
                        // angle:  _group2Animation.value * 2 * 3.14159265359,
                        angle:  (6.28 * _animationController.value),
                        child: SvgPicture.asset(
                          'assets/SVGPicture/Group 1000003222.svg',
                          width: constraints.maxWidth - 120,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _group1Animation,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 20,
                      child: Transform.scale(
                        scale: _group1Animation.value,
                        child: SvgPicture.asset(
                          'assets/SVGPicture/Group 1000003221.svg',
                          width: constraints.maxWidth - 220,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _group2Animation,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 50,
                      child: Transform.scale(
                        scale: _group2Animation.value,
                        child: SvgPicture.asset(
                          'assets/SVGPicture/how-it-works-image-3 1.svg',
                          width: constraints.maxWidth,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
