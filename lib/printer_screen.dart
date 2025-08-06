// // import 'dart:typed_data';
// // import 'package:company_printer/home_screen.dart';
// // import 'package:company_printer/setting_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// // import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
// // import 'package:screenshot/screenshot.dart';
// // import 'package:image/image.dart' as img;

// // class PrinterScreen extends StatefulWidget {
// //   final BluetoothInfo? device;

// //   const PrinterScreen({super.key, required this.device});

// //   @override
// //   State<PrinterScreen> createState() => _PrinterScreenState();
// // }

// // class _PrinterScreenState extends State<PrinterScreen> {
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //   BluetoothInfo? connectedDevice;
// //   final ScreenshotController _screenshotController = ScreenshotController();
// //   late WebViewController _webViewController;

// //   final String webUrl =
// //       'https://dev.vrlapps.com/corevrl/core_app_booking/bk_gcprint_collection_landscap.aspx';

// //   @override
// //   void initState() {
// //     super.initState();
// //     connectedDevice = widget.device;

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (connectedDevice == null) {
// //         _scaffoldKey.currentState?.openDrawer();
// //       }
// //     });

// //     _webViewController = WebViewController()
// //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //       ..loadRequest(Uri.parse(webUrl));
// //   }

// //   // Helper to load latest settings from SharedPreferences
// //   Future<Map<String, dynamic>> _loadLatestSettings() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return {
// //       'printerCommand': prefs.getString('printerCommand') ?? 'TSPL',
// //       'labelWidth': prefs.getInt('labelWidth') ?? 110,
// //       'labelHeight': prefs.getInt('labelHeight') ?? 60,
// //       'labelGap': prefs.getString('labelGap') ?? '1mm',
// //       'angle': prefs.getInt('angle') ?? 180,
// //     };
// //   }

// //   Future<int?> _askPrintCount() async {
// //     int selectedCount = 1;
// //     return showDialog<int>(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: const Text('Select number of copies'),
// //           content: StatefulBuilder(
// //             builder: (context, setState) {
// //               return Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Text(
// //                     '$selectedCount copies',
// //                     style: const TextStyle(
// //                         fontSize: 18, fontWeight: FontWeight.bold),
// //                   ),
// //                   Slider(
// //                     value: selectedCount.toDouble(),
// //                     min: 1,
// //                     max: 10,
// //                     divisions: 9,
// //                     label: '$selectedCount',
// //                     onChanged: (value) {
// //                       setState(() {
// //                         selectedCount = value.round();
// //                       });
// //                     },
// //                   ),
// //                 ],
// //               );
// //             },
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context, null),
// //               child: const Text('Cancel'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () => Navigator.pop(context, selectedCount),
// //               child: const Text('Print'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _printWebView({required int count}) async {
// //     try {
// //       final settings = await _loadLatestSettings();

// //       // 🟢 Capture screenshot
// //       final Uint8List? imageBytes = await _screenshotController.capture();
// //       if (imageBytes == null) {
// //         _showMessage("❌ Failed to capture WebView.");
// //         return;
// //       }

// //       final img.Image? decoded = img.decodeImage(imageBytes);
// //       if (decoded == null) {
// //         _showMessage("❌ Failed to decode image.");
// //         return;
// //       }

// //       // ✅ Convert mm ➜ dots
// //       int widthDots = (57 * (203 / 25.4)).round(); // ≈ 456
// //       int heightDots = (30 * (203 / 25.4)).round(); // ≈ 240

// //       // Clamp width to printer head max (58mm roll)
// //       if (widthDots > 384) {
// //         widthDots = 384;
// //       }

// //       // 🔁 Rotate 90° clockwise
// //       final img.Image rotated = img.copyRotate(decoded, angle: 90);

// //       // ✅ Swap width & height after rotate
// //       final int finalWidth = heightDots; // 240
// //       final int finalHeight = widthDots; // 384

// //       final img.Image resized = img.copyResize(
// //         rotated,
// //         width: finalWidth,
// //         height: finalHeight,
// //       );

// //       final profile = await CapabilityProfile.load();
// //       final generator = Generator(PaperSize.mm58, profile);
// //       final List<int> bytes = [];

// //       bytes.addAll(generator.image(resized));
// //       bytes.addAll(generator.feed(2));
// //       bytes.addAll(generator.cut());

// //       // final result = await PrintBluetoothThermal.writeBytes(bytes);

// //       bool allSuccess = true;

// //       for (int i = 0; i < count; i++) {
// //         final result = await PrintBluetoothThermal.writeBytes(bytes);
// //         if (!result) {
// //           allSuccess = false;
// //           break;
// //         }
// //       }

// //       if (allSuccess) {
// //         _showMessage("✅ Printed 57×30 mm (rotated 90°)!");
// //       } else {
// //         _showMessage("❌ Failed to print!");
// //       }
// //     } catch (e) {
// //       _showMessage("❌ Print error: $e");
// //     }
// //   }

// //   void _showMessage(String msg) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(msg)),
// //     );
// //   }

// //   Future<void> _disconnect() async {
// //     await PrintBluetoothThermal.disconnect;
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('last_connected_mac');

// //     if (!mounted) return;
// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(builder: (_) => const BluetoothDeviceScreen()),
// //       (route) => false,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       key: _scaffoldKey,
// //       appBar: AppBar(
// //         backgroundColor: Colors.orange,
// //         title: Text(connectedDevice != null
// //             ? "Printer (${connectedDevice!.name})"
// //             : "Printer"),
// //       ),
// //       drawer: Drawer(
// //         child: ListView(
// //           padding: EdgeInsets.zero,
// //           children: [
// //             const DrawerHeader(
// //               decoration: BoxDecoration(color: Colors.orange),
// //               child: Text('Menu',
// //                   style: TextStyle(color: Colors.white, fontSize: 24)),
// //             ),
// //             ListTile(
// //               leading: const Icon(Icons.devices, color: Colors.orange),
// //               title: const Text('Bluetooth Devices'),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                       builder: (_) => const BluetoothDeviceScreen()),
// //                 );
// //               },
// //             ),
// //             ListTile(
// //               leading: const Icon(Icons.settings, color: Colors.orange),
// //               title: const Text('Printer Settings'),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                       builder: (_) => const PrinterSettingScreen()),
// //                 );
// //               },
// //             ),
// //             if (connectedDevice != null)
// //               ListTile(
// //                 leading: const Icon(Icons.logout, color: Colors.orange),
// //                 title: const Text("Disconnect"),
// //                 onTap: _disconnect,
// //               ),
// //           ],
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: Screenshot(
// //               controller: _screenshotController,
// //               child: WebViewWidget(controller: _webViewController),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: ElevatedButton.icon(
// //               onPressed: () async {
// //                 final count = await _askPrintCount();
// //                 if (count != null && count > 0) {
// //                   await _printWebView(count: count);
// //                 }
// //               },
// //               icon: const Icon(Icons.print),
// //               label: const Text("Print This Page"),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.orange,
// //                 foregroundColor: Colors.white,
// //                 minimumSize: const Size.fromHeight(48),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'dart:typed_data';
// import 'package:company_printer/home_screen.dart';
// import 'package:company_printer/setting_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:image/image.dart' as img;

// class PrinterScreen extends StatefulWidget {
//   final BluetoothInfo? device;

//   const PrinterScreen({super.key, required this.device});

//   @override
//   State<PrinterScreen> createState() => _PrinterScreenState();
// }

// class _PrinterScreenState extends State<PrinterScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   BluetoothInfo? connectedDevice;
//   final ScreenshotController _screenshotController = ScreenshotController();
//   late WebViewController _webViewController;

//   final String webUrl =
//       // "http://192.168.1.45:8000/api/html_code";
//       'https://dev.vrlapps.com/corevrl/core_app_booking/bk_gcprint_collection_landscap.aspx';

//   @override
//   void initState() {
//     super.initState();
//     connectedDevice = widget.device;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (connectedDevice == null) {
//         _scaffoldKey.currentState?.openDrawer();
//       }
//     });

//     _webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse(webUrl));

//     // _webViewController = WebViewController()
//     //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     //   ..setNavigationDelegate(
//     //     NavigationDelegate(
//     //       onPageStarted: (url) => print("Started: $url"),
//     //       onPageFinished: (url) => print("Finished: $url"),
//     //       onWebResourceError: (error) =>
//     //           print("WebView Error: ${error.description}"),
//     //     ),
//     //   )
//     //   ..loadRequest(Uri.parse(webUrl));
//   }

//   Future<Map<String, dynamic>> _loadLatestSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'printerCommand': prefs.getString('printerCommand') ?? 'TSPL',
//       'labelWidth': prefs.getInt('labelWidth') ?? 110,
//       'labelHeight': prefs.getInt('labelHeight') ?? 60,
//       'labelGap': prefs.getString('labelGap') ?? '1mm',
//       'angle': prefs.getInt('angle') ?? 180,
//     };
//   }

//   Future<int?> _askPrintCount() async {
//     final TextEditingController controller = TextEditingController(text: "1");

//     return showDialog<int>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Enter number of copies'),
//           content: TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Enter count (e.g. 1, 2, 5)',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, null),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final text = controller.text.trim();
//                 final parsed = int.tryParse(text);
//                 if (parsed == null || parsed <= 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text("Please enter a valid number")),
//                   );
//                   return;
//                 }
//                 Navigator.pop(context, parsed);
//               },
//               child: const Text('Print'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _printWebView({required int count}) async {
//     try {
//       // final settings = await _loadLatestSettings();

//       final Uint8List? imageBytes = await _screenshotController.capture();
//       if (imageBytes == null) {
//         _showMessage("❌ Failed to capture WebView.");
//         return;
//       }

//       final img.Image? decoded = img.decodeImage(imageBytes);
//       if (decoded == null) {
//         _showMessage("❌ Failed to decode image.");
//         return;
//       }

//       // Convert mm to printer dots
//       int widthDots = (5000 * (203 / 25.4)).round(); // ≈ 456
//       int heightDots = (50 * (203 / 25.4)).round(); // ≈ 240

//       if (widthDots > 384) {
//         widthDots = 384; // clamp for 58mm printer
//       }

//       // Rotate 90°
//       final img.Image rotated = img.copyRotate(decoded, angle: 0);

//       // Swap width/height after rotate
//       final int finalWidth = heightDots; // 240
//       final int finalHeight = widthDots; // 384

//       final img.Image resized = img.copyResize(
//         rotated,
//         width: finalWidth,
//         height: finalHeight,
//       );

//       print("Original: ${decoded.width}x${decoded.height}");
//       print("Rotated: ${rotated.width}x${rotated.height}");
//       print("Resized: ${resized.width}x${resized.height}");
//       print("Final: $finalWidth x $finalHeight");

//       final profile = await CapabilityProfile.load();
//       final generator = Generator(PaperSize.mm80, profile);
//       final List<int> bytes = [];

//       bytes.addAll(generator.image(resized));
//       bytes.addAll(generator.feed(2));
//       bytes.addAll(generator.cut());

//       bool allSuccess = true;

//       for (int i = 0; i < count; i++) {
//         final result = await PrintBluetoothThermal.writeBytes(bytes);
//         if (!result) {
//           allSuccess = false;
//           break;
//         }
//       }

//       if (allSuccess) {
//         _showMessage("✅ Printed $count copies successfully!");
//       } else {
//         _showMessage("❌ Failed to print!");
//       }
//     } catch (e) {
//       _showMessage("❌ Print error: $e");
//     }
//   }

//   void _showMessage(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }

//   Future<void> _disconnect() async {
//     await PrintBluetoothThermal.disconnect;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('last_connected_mac');

//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const BluetoothDeviceScreen()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         backgroundColor: Colors.orange,
//         title: Text(connectedDevice != null
//             ? "Printer (${connectedDevice!.name})"
//             : "Printer"),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.orange),
//               child: Text('Menu',
//                   style: TextStyle(color: Colors.white, fontSize: 24)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.devices, color: Colors.orange),
//               title: const Text('Bluetooth Devices'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => const BluetoothDeviceScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings, color: Colors.orange),
//               title: const Text('Printer Settings'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => const PrinterSettingScreen()),
//                 );
//               },
//             ),
//             if (connectedDevice != null)
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.orange),
//                 title: const Text("Disconnect"),
//                 onTap: _disconnect,
//               ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Screenshot(
//               controller: _screenshotController,
//               child: WebViewWidget(controller: _webViewController),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: ElevatedButton.icon(
//               onPressed: () async {
//                 final count = await _askPrintCount();
//                 if (count != null && count > 0) {
//                   await _printWebView(count: count);
//                 }
//               },
//               icon: const Icon(Icons.print),
//               label: const Text("Print This Page"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(48),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:typed_data';
// import 'package:company_printer/home_screen.dart';
// import 'package:company_printer/setting_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:image/image.dart' as img;

// class PrinterScreen extends StatefulWidget {
//   final BluetoothInfo? device;

//   const PrinterScreen({super.key, required this.device});

//   @override
//   State<PrinterScreen> createState() => _PrinterScreenState();
// }

// class _PrinterScreenState extends State<PrinterScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   BluetoothInfo? connectedDevice;
//   final ScreenshotController _screenshotController = ScreenshotController();
//   late WebViewController _webViewController;

//   final String webUrl =
//       "https://dev.vrlapps.com/corevrl/core_app_booking/bk_gcprint_collection_landscap.aspx";

//   @override
//   void initState() {
//     super.initState();
//     connectedDevice = widget.device;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (connectedDevice == null) {
//         _scaffoldKey.currentState?.openDrawer();
//       }
//     });

//     _webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) => debugPrint("Started loading: $url"),
//           onPageFinished: (url) async {
//             debugPrint("Finished loading: $url");

//             // Inject html2canvas into the page
//             await _webViewController.runJavaScript('''
//               var script = document.createElement('script');
//               script.src = "https://html2canvas.hertzen.com/dist/html2canvas.min.js";
//               script.onload = function() {
//                 window.capturePageAsImage = async function() {
//                   const canvas = await html2canvas(document.body);
//                   return canvas.toDataURL("image/png").replace(/^data:image\\/png;base64,/, "");
//                 };
//               };
//               document.head.appendChild(script);
//             ''');
//           },
//           onWebResourceError: (error) =>
//               debugPrint("WebView Error: ${error.description}"),
//         ),
//       )
//       ..loadRequest(Uri.parse(webUrl));
//   }

//   Future<int?> _askPrintCount() async {
//     final TextEditingController controller = TextEditingController(text: "1");
//     return showDialog<int>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Enter number of copies'),
//           content: TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Enter count (e.g. 1, 2, 5)',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, null),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final text = controller.text.trim();
//                 final parsed = int.tryParse(text);
//                 if (parsed == null || parsed <= 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text("Please enter a valid number")),
//                   );
//                   return;
//                 }
//                 Navigator.pop(context, parsed);
//               },
//               child: const Text('Print'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _printWebView({required int count}) async {
//     try {
//       final Uint8List? imageBytes = await _screenshotController.capture();
//       if (imageBytes == null) {
//         _showMessage("❌ Failed to capture WebView.");
//         return;
//       }

//       final img.Image? decoded = img.decodeImage(imageBytes);
//       if (decoded == null) {
//         _showMessage("❌ Failed to decode image.");
//         return;
//       }

//       // Rotate to landscape
//       final img.Image rotated = img.copyRotate(decoded, angle: 270);

//       // Resize image for 80mm printer (max width ≈ 576 dots)
//       final img.Image resized = img.copyResize(rotated, width: 576);

//       final profile = await CapabilityProfile.load();
//       final generator = Generator(PaperSize.mm80, profile);
//       final List<int> bytes = [];

//       bytes.addAll(generator.image(resized));
//       bytes.addAll(generator.feed(2));
//       bytes.addAll(generator.cut());

//       bool allSuccess = true;
//       for (int i = 0; i < count; i++) {
//         final result = await PrintBluetoothThermal.writeBytes(bytes);
//         if (!result) {
//           allSuccess = false;
//           break;
//         }
//       }

//       if (allSuccess) {
//         _showMessage("✅ Printed $count copies successfully!");
//       } else {
//         _showMessage("❌ Failed to print!");
//       }
//     } catch (e) {
//       _showMessage("❌ Print error: $e");
//     }
//   }

//   void _showMessage(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Future<void> _disconnect() async {
//     await PrintBluetoothThermal.disconnect;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('last_connected_mac');

//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const BluetoothDeviceScreen()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         backgroundColor: Colors.orange,
//         title: Text(connectedDevice != null
//             ? "Printer (${connectedDevice!.name})"
//             : "Printer"),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.orange),
//               child: Text('Menu',
//                   style: TextStyle(color: Colors.white, fontSize: 24)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.devices, color: Colors.orange),
//               title: const Text('Bluetooth Devices'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => const BluetoothDeviceScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings, color: Colors.orange),
//               title: const Text('Printer Settings'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => const PrinterSettingScreen()),
//                 );
//               },
//             ),
//             if (connectedDevice != null)
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.orange),
//                 title: const Text("Disconnect"),
//                 onTap: _disconnect,
//               ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Screenshot(
//               controller: _screenshotController,
//               child: WebViewWidget(controller: _webViewController),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: ElevatedButton.icon(
//               onPressed: () async {
//                 final count = await _askPrintCount();
//                 if (count != null && count > 0) {
//                   await _printWebView(count: count);
//                 }
//               },
//               icon: const Icon(Icons.print),
//               label: const Text("Print This Page"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(48),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
