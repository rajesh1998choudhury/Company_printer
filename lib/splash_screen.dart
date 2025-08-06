import 'dart:async';
import 'package:company_printer/p.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _startApp();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final isConnected = await PrintBluetoothThermal.connectionStatus;

    if (!mounted) return;

    if (isConnected) {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('printer_name');
      final savedMac = prefs.getString('printer_mac');

      final device = (savedName != null && savedMac != null)
          ? BluetoothInfo(name: savedName, macAdress: savedMac)
          : null;

      _navigateWithFade(() => PrinterScreen(device: device));
    } else {
      _navigateWithFade(() => const BluetoothDeviceScreen());
    }
  }

  void _navigateWithFade(Widget Function() screenBuilder) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => screenBuilder(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterLogo(size: 80),
              SizedBox(height: 20),
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(
                "Checking Connected Bluetooth...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:company_printer/home_screen.dart';
// import 'package:company_printer/model/mac_model.dart';
// import 'package:company_printer/printer_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:shared_preferences/shared_preferences.dart';

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

//     final isConnected = await PrintBluetoothThermal.connectionStatus;

//     if (!mounted) return;

//     final prefs = await SharedPreferences.getInstance();
//     final savedName = prefs.getString('printer_name');
//     final savedMac = prefs.getString('printer_mac');

//     if (isConnected && savedMac != null) {
//       final allowed = await _fetchAllowedMacs();

//       final matched = allowed.any((mac) => mac.macAddress == savedMac);

//       if (matched) {
//         final device = BluetoothInfo(
//           name: savedName ?? '',
//           macAdress: savedMac,
//         );

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('✅ Allowed printer connected.')),
//         );

//         _navigateWithFade(() => PrinterScreen(device: device));
//       } else {
//         await PrintBluetoothThermal.disconnect;
//         await prefs.remove('printer_name');
//         await prefs.remove('printer_mac');

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('❌ Printer not allowed.')),
//         );

//         _navigateWithFade(() => const BluetoothDeviceScreen());
//       }
//     } else {
//       _navigateWithFade(() => const BluetoothDeviceScreen());
//     }
//   }

//   Future<List<Mac>> _fetchAllowedMacs() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.1.45:8000/api/printers'),
//       );

//       if (response.statusCode == 200) {
//         final model = macModelFromJson(response.body);
//         return model.data;
//       } else {
//         debugPrint('API failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('API error: $e');
//     }

//     return [];
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
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
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

// import 'package:flutter/material.dart';

// class ConsignmentNoteScreen extends StatefulWidget {
//   const ConsignmentNoteScreen({super.key});

//   @override
//   State<ConsignmentNoteScreen> createState() => _ConsignmentNoteScreenState();
// }

// class _ConsignmentNoteScreenState extends State<ConsignmentNoteScreen> {
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 130,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Consignment Note'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top Row with Logo and Title
//                 const Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.local_shipping, size: 28),
//                         SizedBox(width: 8),
//                         Text(
//                           'VRL LOGISTICS LTD',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       'Consignor Copy',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 const Divider(),
//                 // From & To
//                 _buildRow(
//                   'From:',
//                   'HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659\nGSTIN : 29AABCV3609C1ZJ',
//                 ),
//                 _buildRow(
//                   'To:',
//                   'KOPPAL [KA-KPL] - 74066-42467,08539-231066\nGSTIN : 29AABCV3609C1ZJ',
//                 ),
//                 const Divider(),
//                 // Consignor and Consignee
//                 _buildRow('Consignor:', 'TVS SRICHAKRA LIMITED'),
//                 _buildRow('Consignee:', 'SRI GANESH AUTO AGENCY'),
//                 const Divider(),
//                 // Invoice Details
//                 _buildRow('Inv.No:', '9137500612'),
//                 _buildRow('D.Value Rs.:', '78812'),
//                 _buildRow('P.Code:',
//                     '18695 - GST PAYABLE BY A/C PARTY-RCM A/C - DOOR'),
//                 _buildRow('Packing:', 'LOOSE TYRE Tyre'),
//                 _buildRow('BKDate:', '04-06-2025'),
//                 _buildRow('Nos:', '17'),
//                 _buildRow('Ch Weight:', '595'),
//                 _buildRow('Rate:', '116.00'),
//                 _buildRow('EwayNo:', '122127932351'),
//                 _buildRow('Self No:', '-'),
//                 const Divider(),
//                 // Service Category
//                 _buildRow('Service Category:',
//                     'Transport of Goods by Road\nSAC NO: 996511'),
//                 _buildRow(
//                   'DOOR DELIVERY / ETD:',
//                   '04-06 17:40 - EntBy: 68889',
//                 ),
//                 const SizedBox(height: 16),
//                 // QR and Signature
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       children: [
//                         Container(
//                           height: 80,
//                           width: 80,
//                           color: Colors.grey[300],
//                           child: const Center(
//                             child: Text('QR\nCODE'),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         const Text('9024325258'),
//                       ],
//                     ),
//                     const Text('Name / Stamp / Sign'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class ConsignmentNoteScreen extends StatefulWidget {
//   const ConsignmentNoteScreen({super.key});

//   @override
//   State<ConsignmentNoteScreen> createState() => _ConsignmentNoteScreenState();
// }

// class _ConsignmentNoteScreenState extends State<ConsignmentNoteScreen> {
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 130,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: RotatedBox(
//           quarterTurns: 1, // 90 degrees clockwise
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.only(
//               left: 10,
//             ),
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.local_shipping, size: 28),
//                           SizedBox(width: 8),
//                           Text(
//                             'VRL LOGISTICS LTD',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         'Consignor Copy',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // const SizedBox(height: 12),
//                   const Divider(),
//                   _buildRow(
//                     'From:',
//                     'HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659\nGSTIN : 29AABCV3609C1ZJ',
//                   ),
//                   _buildRow(
//                     'To:',
//                     'KOPPAL [KA-KPL] - 74066-42467,08539-231066\nGSTIN : 29AABCV3609C1ZJ',
//                   ),
//                   const Divider(),
//                   _buildRow('Consignor:', 'TVS SRICHAKRA LIMITED'),
//                   _buildRow('Consignee:', 'SRI GANESH AUTO AGENCY'),
//                   const Divider(),
//                   _buildRow('Inv.No:', '9137500612'),
//                   _buildRow('D.Value Rs.:', '78812'),
//                   _buildRow('P.Code:',
//                       '18695 - GST PAYABLE BY A/C PARTY-RCM A/C - DOOR'),
//                   _buildRow('Packing:', 'LOOSE TYRE Tyre'),
//                   _buildRow('BKDate:', '04-06-2025'),
//                   _buildRow('Nos:', '17'),
//                   _buildRow('Ch Weight:', '595'),
//                   _buildRow('Rate:', '116.00'),
//                   _buildRow('EwayNo:', '122127932351'),
//                   _buildRow('Self No:', '-'),
//                   const Divider(),
//                   _buildRow('Service Category:',
//                       'Transport of Goods by Road\nSAC NO: 996511'),
//                   _buildRow(
//                     'DOOR DELIVERY / ETD:',
//                     '04-06 17:40 - EntBy: 68889',
//                   ),
//                   // const SizedBox(height: 16),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         children: [
//                           Container(
//                             height: 80,
//                             width: 80,
//                             color: Colors.grey[300],
//                             child: const Center(
//                               child: Text('QR\nCODE'),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text('9024325258'),
//                         ],
//                       ),
//                       const Text('Name / Stamp / Sign'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

// class ConsignmentNoteScreen extends StatefulWidget {
//   const ConsignmentNoteScreen({super.key});

//   @override
//   State<ConsignmentNoteScreen> createState() => _ConsignmentNoteScreenState();
// }

// class _ConsignmentNoteScreenState extends State<ConsignmentNoteScreen> {
//   final ScreenshotController screenshotController = ScreenshotController();

//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 130,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   Future<void> _printConsignmentNote() async {
//     try {
//       final Uint8List? capturedImage =
//           await screenshotController.capture(pixelRatio: 2.0);

//       if (capturedImage == null) {
//         debugPrint("Failed to capture screenshot.");
//         return;
//       }

//       bool isConnected = await PrintBluetoothThermal.connectionStatus == true;

//       if (!isConnected) {
//         debugPrint("Not connected to any printer.");
//         return;
//       }

//       final result = await PrintBluetoothThermal.writeBytes(capturedImage);
//       debugPrint("Print result: $result");
//     } catch (e) {
//       debugPrint("Error while printing: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _printConsignmentNote,
//         label: const Text("Print"),
//         icon: const Icon(Icons.print),
//       ),
//       body: SafeArea(
//         child: RotatedBox(
//           quarterTurns: 1, // Landscape
//           child: Screenshot(
//             controller: screenshotController,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(10),
//               child: Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.local_shipping, size: 28),
//                               SizedBox(width: 8),
//                               Text(
//                                 'VRL LOGISTICS LTD',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             'Consignor Copy',
//                             style: TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ],
//                       ),
//                       const Divider(),
//                       _buildRow(
//                         'From:',
//                         'HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659\nGSTIN : 29AABCV3609C1ZJ',
//                       ),
//                       _buildRow(
//                         'To:',
//                         'KOPPAL [KA-KPL] - 74066-42467,08539-231066\nGSTIN : 29AABCV3609C1ZJ',
//                       ),
//                       const Divider(),
//                       _buildRow('Consignor:', 'TVS SRICHAKRA LIMITED'),
//                       _buildRow('Consignee:', 'SRI GANESH AUTO AGENCY'),
//                       const Divider(),
//                       _buildRow('Inv.No:', '9137500612'),
//                       _buildRow('D.Value Rs.:', '78812'),
//                       _buildRow('P.Code:',
//                           '18695 - GST PAYABLE BY A/C PARTY-RCM A/C - DOOR'),
//                       _buildRow('Packing:', 'LOOSE TYRE Tyre'),
//                       _buildRow('BKDate:', '04-06-2025'),
//                       _buildRow('Nos:', '17'),
//                       _buildRow('Ch Weight:', '595'),
//                       _buildRow('Rate:', '116.00'),
//                       _buildRow('EwayNo:', '122127932351'),
//                       _buildRow('Self No:', '-'),
//                       const Divider(),
//                       _buildRow('Service Category:',
//                           'Transport of Goods by Road\nSAC NO: 996511'),
//                       _buildRow(
//                         'DOOR DELIVERY / ETD:',
//                         '04-06 17:40 - EntBy: 68889',
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             children: [
//                               Container(
//                                 height: 80,
//                                 width: 80,
//                                 color: Colors.grey[300],
//                                 child: const Center(child: Text('QR\nCODE')),
//                               ),
//                               const SizedBox(height: 4),
//                               const Text('9024325258'),
//                             ],
//                           ),
//                           const Text('Name / Stamp / Sign'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
