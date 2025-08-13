// import 'dart:async';
// import 'package:company_printer/printers_screens.dart';
// import 'package:flutter/material.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'home_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initAnimation();
//     _startApp();
//   }

//   void _initAnimation() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     _scaleAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     );

//     _controller.forward();
//   }

//   Future<void> _startApp() async {
//     await Future.delayed(const Duration(seconds: 2));

//     final prefs = await SharedPreferences.getInstance();
//     final savedName = prefs.getString('printer_name');
//     final savedMac = prefs.getString('printer_mac');

//     // If no saved printer → directly go to BluetoothDeviceScreen
//     if (savedName == null || savedMac == null) {
//       _navigateWithFade(() => const BluetoothDeviceScreen());
//       return;
//     }

//     final isConnected = await PrintBluetoothThermal.connectionStatus;

//     if (!mounted) return;

//     if (isConnected) {
//       // final prefs = await SharedPreferences.getInstance();
//       // final savedName = prefs.getString('printer_name');
//       // final savedMac = prefs.getString('printer_mac');

//       // final device = (savedName != null && savedMac != null)
//       //     ? BluetoothInfo(name: savedName, macAdress: savedMac)
//       //     : null;

//       _navigateWithFade(() => const PrinterScreen());
//     } else {
//       _navigateWithFade(() => const BluetoothDeviceScreen());
//     }
//   }

//   void _navigateWithFade(Widget Function() screenBuilder) {
//     Navigator.of(context).pushReplacement(
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 700),
//         pageBuilder: (_, __, ___) => screenBuilder(),
//         transitionsBuilder: (_, anim, __, child) {
//           return FadeTransition(opacity: anim, child: child);
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: ScaleTransition(
//           scale: _scaleAnimation,
//           child: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               FlutterLogo(size: 80),
//               SizedBox(height: 20),
//               CircularProgressIndicator(),
//               SizedBox(height: 10),
//               Text(
//                 "Checking Connected Bluetooth...",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
