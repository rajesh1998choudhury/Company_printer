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

// //   final String webUrl = "http://192.168.1.45:8000/api/html_code";

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
// //       ..setNavigationDelegate(
// //         NavigationDelegate(
// //           onPageStarted: (url) => debugPrint("Started loading: $url"),
// //           onPageFinished: (url) async {
// //             debugPrint("Finished loading: $url");

// //             // Inject html2canvas into the page
// //             await _webViewController.runJavaScript('''
// //               var script = document.createElement('script');
// //               script.src = "https://html2canvas.hertzen.com/dist/html2canvas.min.js";
// //               script.onload = function() {
// //                 window.capturePageAsImage = async function() {
// //                   const canvas = await html2canvas(document.body);
// //                   return canvas.toDataURL("image/png").replace(/^data:image\\/png;base64,/, "");
// //                 };
// //               };
// //               document.head.appendChild(script);
// //             ''');
// //           },
// //           onWebResourceError: (error) =>
// //               debugPrint("WebView Error: ${error.description}"),
// //         ),
// //       )
// //       ..loadRequest(Uri.parse(webUrl));
// //   }

// //   Future<int?> _askPrintCount() async {
// //     final TextEditingController controller = TextEditingController(text: "1");
// //     return showDialog<int>(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: const Text('Enter number of copies'),
// //           content: TextField(
// //             controller: controller,
// //             keyboardType: TextInputType.number,
// //             decoration: const InputDecoration(
// //               border: OutlineInputBorder(),
// //               hintText: 'Enter count (e.g. 1, 2, 5)',
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context, null),
// //               child: const Text('Cancel'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 final text = controller.text.trim();
// //                 final parsed = int.tryParse(text);
// //                 if (parsed == null || parsed <= 0) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                         content: Text("Please enter a valid number")),
// //                   );
// //                   return;
// //                 }
// //                 Navigator.pop(context, parsed);
// //               },
// //               child: const Text('Print'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _printWebView({required int count}) async {
// //     try {
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

// //       // Rotate to landscape
// //       final img.Image rotated = img.copyRotate(decoded, angle: 270);

// //       // Resize image for 80mm printer (max width ≈ 576 dots)
// //       final img.Image resized = img.copyResize(rotated, width: 576);

// //       final profile = await CapabilityProfile.load();
// //       final generator = Generator(PaperSize.mm80, profile);
// //       final List<int> bytes = [];

// //       bytes.addAll(generator.image(resized));
// //       bytes.addAll(generator.feed(2));
// //       bytes.addAll(generator.cut());

// //       bool allSuccess = true;
// //       for (int i = 0; i < count; i++) {
// //         final result = await PrintBluetoothThermal.writeBytes(bytes);
// //         if (!result) {
// //           allSuccess = false;
// //           break;
// //         }
// //       }

// //       if (allSuccess) {
// //         _showMessage("✅ Printed $count copies successfully!");
// //       } else {
// //         _showMessage("❌ Failed to print!");
// //       }
// //     } catch (e) {
// //       _showMessage("❌ Print error: $e");
// //     }
// //   }

// //   void _showMessage(String msg) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
// //       body:
// //           // body: SafeArea(
// //           //   child: RotatedBox(
// //           //     quarterTurns: 1,
// //           //     child: Center(
// //           //       child: Container(
// //           //         width: 1000,
// //           //         padding: const EdgeInsets.all(8),
// //           //         decoration: BoxDecoration(
// //           //           border: Border.all(color: Colors.black),
// //           //         ),
// //           //         child: Column(
// //           //           crossAxisAlignment: CrossAxisAlignment.start,
// //           //           children: [
// //           //             // Header Row
// //           //             const Row(
// //           //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           //               children: [
// //           //                 Text(
// //           //                   "VRL LOGISTICS LTD",
// //           //                   style: TextStyle(
// //           //                       fontWeight: FontWeight.bold, fontSize: 18),
// //           //                 ),
// //           //                 Text(
// //           //                   "Consignor Copy",
// //           //                   style: TextStyle(fontSize: 14),
// //           //                 ),
// //           //               ],
// //           //             ),
// //           //             const Divider(color: Colors.black),

// //           //             // FROM + GSTIN + QR on right
// //           //             Row(
// //           //               crossAxisAlignment: CrossAxisAlignment.start,
// //           //               children: [
// //           //                 Expanded(
// //           //                   flex: 4,
// //           //                   child: Column(
// //           //                     crossAxisAlignment: CrossAxisAlignment.start,
// //           //                     children: [
// //           //                       _buildRow("From",
// //           //                           "HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659"),
// //           //                       _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //           //                     ],
// //           //                   ),
// //           //                 ),
// //           //                 const SizedBox(width: 8),
// //           //                 Column(
// //           //                   children: [
// //           //                     Image.asset(
// //           //                       "assets/QR_Code_Example.png", // Replace with your image path
// //           //                       width: 80,
// //           //                       height: 80,
// //           //                       fit: BoxFit.contain,
// //           //                     ),
// //           //                     const SizedBox(height: 4),
// //           //                     const Text("9024325258"),
// //           //                   ],
// //           //                 ),
// //           //               ],
// //           //             ),

// //           //             const SizedBox(height: 4),
// //           //             _buildRow("To", "KOPPAL [KA-KPL] - 74066-42467,08539-231066"),
// //           //             _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //           //             const SizedBox(height: 4),
// //           //             _buildRow("Consignor", "TVS SRICHAKRA LIMITED"),
// //           //             _buildRow("Consignee", "SRI GANESH AUTO AGENCY"),
// //           //             _buildRow("Inv.No", "9137500612     D.Value Rs. :  78812"),
// //           //             _buildRow("P.Code",
// //           //                 "18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"),
// //           //             _buildRow("Packing", "LOOSE TYRE Tyre"),
// //           //             _buildRow("BKDate",
// //           //                 "04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"),
// //           //             _buildRow("EwayNo", "122127932351     SelfNo :"),
// //           //             _buildRow("Service Category",
// //           //                 "Transport of Goods By Road     SAC NO: 996511"),

// //           //             const SizedBox(height: 8),

// //           //             // DOOR DELIVERY + Sign Row
// //           //             const Row(
// //           //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           //               children: [
// //           //                 Text(
// //           //                   "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
// //           //                   style: TextStyle(
// //           //                     fontWeight: FontWeight.bold,
// //           //                     fontSize: 15,
// //           //                     // decoration: TextDecoration.underline,
// //           //                   ),
// //           //                 ),
// //           //                 Text("Name /Stamp /Sign"),
// //           //               ],
// //           //             ),

// //           //             const Divider(color: Colors.black),
// //           //           ],
// //           //         ),
// //           //       ),
// //           //     ),
// //           //   ),
// //           // ),

// //           Column(
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

// //   static Widget _buildRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 3),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //               width: 100,
// //               child: Text(
// //                 "$label :",
// //                 style: const TextStyle(fontWeight: FontWeight.bold),
// //               )),
// //           Expanded(child: Text(value)),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// // import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import 'home_screen.dart';
// // import 'setting_screen.dart';

// // class PrinterScreen extends StatefulWidget {
// //   final BluetoothInfo? device;

// //   const PrinterScreen({super.key, required this.device});

// //   @override
// //   State<PrinterScreen> createState() => _PrinterScreenState();
// // }

// // class _PrinterScreenState extends State<PrinterScreen> {
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //   BluetoothInfo? connectedDevice;

// //   @override
// //   void initState() {
// //     super.initState();
// //     connectedDevice = widget.device;

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (connectedDevice == null) {
// //         _scaffoldKey.currentState?.openDrawer();
// //       }
// //     });
// //   }

// //   Future<int?> _askPrintCount() async {
// //     final TextEditingController controller = TextEditingController(text: "1");
// //     return showDialog<int>(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: const Text('Enter number of copies'),
// //           content: TextField(
// //             controller: controller,
// //             keyboardType: TextInputType.number,
// //             decoration: const InputDecoration(
// //               border: OutlineInputBorder(),
// //               hintText: 'Enter count (e.g. 1, 2, 5)',
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context, null),
// //               child: const Text('Cancel'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 final text = controller.text.trim();
// //                 final parsed = int.tryParse(text);
// //                 if (parsed == null || parsed <= 0) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                         content: Text("Please enter a valid number")),
// //                   );
// //                   return;
// //                 }
// //                 Navigator.pop(context, parsed);
// //               },
// //               child: const Text('Print'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _printBodyLayout({required int count}) async {
// //     try {
// //       final profile = await CapabilityProfile.load();
// //       final generator = Generator(PaperSize.mm80, profile);
// //       final List<int> bytes = [];

// //       // Header
// //       bytes.addAll(generator.text(
// //         "VRL LOGISTICS LTD",
// //         styles: const PosStyles(
// //           align: PosAlign.left,
// //           bold: true,
// //           height: PosTextSize.size1,
// //           width: PosTextSize.size1,
// //         ),
// //       ));

// //       bytes.addAll(generator.text(
// //         "Consignor Copy",
// //         styles: const PosStyles(align: PosAlign.right),
// //       ));
// //       bytes.addAll(generator.hr());

// //       // From Section
// //       bytes.addAll(generator.text(
// //           "From : HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659",
// //           styles: const PosStyles(bold: true)));
// //       bytes.addAll(generator.text("GSTIN : 29AABCV3609C1ZJ"));

// //       bytes.addAll(generator.text(
// //           "To : KOPPAL [KA-KPL] - 74066-42467,08539-231066",
// //           styles: const PosStyles(bold: true)));
// //       bytes.addAll(generator.text("GSTIN : 29AABCV3609C1ZJ"));

// //       bytes.addAll(generator.text("Consignor : TVS SRICHAKRA LIMITED"));
// //       bytes.addAll(generator.text("Consignee : SRI GANESH AUTO AGENCY"));
// //       bytes.addAll(
// //           generator.text("Inv.No : 9137500612     D.Value Rs. :  78812"));
// //       bytes.addAll(generator
// //           .text("P.Code : 18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"));
// //       bytes.addAll(generator.text("Packing : LOOSE TYRE Tyre"));
// //       bytes.addAll(generator.text(
// //           "BKDate : 04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"));
// //       bytes.addAll(generator.text("EwayNo : 122127932351     SelfNo :"));
// //       bytes.addAll(generator.text(
// //           "Service Category : Transport of Goods By Road     SAC NO: 996511"));

// //       bytes.addAll(generator.feed(1));

// //       bytes.addAll(generator.text(
// //           "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
// //           styles: const PosStyles(bold: true)));
// //       bytes.addAll(generator.text("Name /Stamp /Sign",
// //           styles: const PosStyles(align: PosAlign.right)));

// //       bytes.addAll(generator.hr());

// //       bytes.addAll(generator.feed(2));
// //       bytes.addAll(generator.cut());

// //       // Send the print commands
// //       bool allSuccess = true;
// //       for (int i = 0; i < count; i++) {
// //         final result = await PrintBluetoothThermal.writeBytes(bytes);
// //         if (!result) {
// //           allSuccess = false;
// //           break;
// //         }
// //       }

// //       if (allSuccess) {
// //         _showMessage("✅ Printed $count copies successfully!");
// //       } else {
// //         _showMessage("❌ Failed to print!");
// //       }
// //     } catch (e) {
// //       _showMessage("❌ Print error: $e");
// //     }
// //   }

// //   void _showMessage(String msg) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             Expanded(
// //               child: RotatedBox(
// //                 quarterTurns: 1,
// //                 child: Center(
// //                   child: Container(
// //                     width: 1000,
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       border: Border.all(color: Colors.black),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text(
// //                               "VRL LOGISTICS LTD",
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 18),
// //                             ),
// //                             Text(
// //                               "Consignor Copy",
// //                               style: TextStyle(fontSize: 14),
// //                             ),
// //                           ],
// //                         ),
// //                         const Divider(color: Colors.black),
// //                         Row(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Expanded(
// //                               flex: 4,
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   _buildRow("From",
// //                                       "HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659"),
// //                                   _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //                                 ],
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),
// //                             Column(
// //                               children: [
// //                                 Image.asset(
// //                                   "assets/QR_Code_Example.png",
// //                                   width: 80,
// //                                   height: 80,
// //                                   fit: BoxFit.contain,
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 const Text("9024325258"),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 4),
// //                         _buildRow(
// //                             "To", "KOPPAL [KA-KPL] - 74066-42467,08539-231066"),
// //                         _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //                         const SizedBox(height: 4),
// //                         _buildRow("Consignor", "TVS SRICHAKRA LIMITED"),
// //                         _buildRow("Consignee", "SRI GANESH AUTO AGENCY"),
// //                         _buildRow(
// //                             "Inv.No", "9137500612     D.Value Rs. :  78812"),
// //                         _buildRow("P.Code",
// //                             "18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"),
// //                         _buildRow("Packing", "LOOSE TYRE Tyre"),
// //                         _buildRow("BKDate",
// //                             "04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"),
// //                         _buildRow("EwayNo", "122127932351     SelfNo :"),
// //                         _buildRow("Service Category",
// //                             "Transport of Goods By Road     SAC NO: 996511"),
// //                         const SizedBox(height: 8),
// //                         const Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text(
// //                               "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
// //                               style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 15,
// //                               ),
// //                             ),
// //                             Text("Name /Stamp /Sign"),
// //                           ],
// //                         ),
// //                         const Divider(color: Colors.black),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(12),
// //               child: ElevatedButton.icon(
// //                 onPressed: () async {
// //                   final count = await _askPrintCount();
// //                   if (count != null && count > 0) {
// //                     await _printBodyLayout(count: count);
// //                   }
// //                 },
// //                 icon: const Icon(Icons.print),
// //                 label: const Text("Print This Page"),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.orange,
// //                   foregroundColor: Colors.white,
// //                   minimumSize: const Size.fromHeight(48),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   static Widget _buildRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 3),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //               width: 100,
// //               child: Text(
// //                 "$label :",
// //                 style: const TextStyle(fontWeight: FontWeight.bold),
// //               )),
// //           Expanded(child: Text(value)),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// // import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import 'home_screen.dart';
// // import 'setting_screen.dart';

// // class PrinterScreen extends StatefulWidget {
// //   final BluetoothInfo? device;

// //   const PrinterScreen({super.key, required this.device});

// //   @override
// //   State<PrinterScreen> createState() => _PrinterScreenState();
// // }

// // class _PrinterScreenState extends State<PrinterScreen> {
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //   BluetoothInfo? connectedDevice;

// //   @override
// //   void initState() {
// //     super.initState();
// //     connectedDevice = widget.device;

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (connectedDevice == null) {
// //         _scaffoldKey.currentState?.openDrawer();
// //       }
// //     });
// //   }

// //   Future<int?> _askPrintCount() async {
// //     final TextEditingController controller = TextEditingController(text: "1");
// //     return showDialog<int>(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: const Text('Enter number of copies'),
// //           content: TextField(
// //             controller: controller,
// //             keyboardType: TextInputType.number,
// //             decoration: const InputDecoration(
// //               border: OutlineInputBorder(),
// //               hintText: 'Enter count (e.g. 1, 2, 5)',
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context, null),
// //               child: const Text('Cancel'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 final text = controller.text.trim();
// //                 final parsed = int.tryParse(text);
// //                 if (parsed == null || parsed <= 0) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                         content: Text("Please enter a valid number")),
// //                   );
// //                   return;
// //                 }
// //                 Navigator.pop(context, parsed);
// //               },
// //               child: const Text('Print'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _printBodyLayout({required int count}) async {
// //     try {
// //       final profile = await CapabilityProfile.load();
// //       final generator = Generator(PaperSize.mm80, profile);
// //       final List<int> bytes = [];

// //       bytes.addAll(generator.text(
// //         "VRL LOGISTICS LTD",
// //         styles: const PosStyles(
// //           align: PosAlign.left,
// //           bold: true,
// //           height: PosTextSize.size1,
// //           width: PosTextSize.size1,
// //         ),
// //       ));

// //       bytes.addAll(generator.text(
// //         "Consignor Copy",
// //         styles: const PosStyles(align: PosAlign.right),
// //       ));
// //       bytes.addAll(generator.hr());

// //       bytes.addAll(generator.text(
// //           "From : HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659",
// //           styles: const PosStyles(bold: true)));
// //       bytes.addAll(generator.text("GSTIN : 29AABCV3609C1ZJ"));

// //       bytes.addAll(generator.text(
// //           "To : KOPPAL [KA-KPL] - 74066-42467,08539-231066",
// //           styles: const PosStyles(bold: true)));
// //       bytes.addAll(generator.text("GSTIN : 29AABCV3609C1ZJ"));

// //       bytes.addAll(generator.text("Consignor : TVS SRICHAKRA LIMITED"));
// //       bytes.addAll(generator.text("Consignee : SRI GANESH AUTO AGENCY"));
// //       bytes.addAll(
// //           generator.text("Inv.No : 9137500612     D.Value Rs. :  78812"));
// //       bytes.addAll(generator
// //           .text("P.Code : 18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"));
// //       bytes.addAll(generator.text("Packing : LOOSE TYRE Tyre"));
// //       bytes.addAll(generator.text(
// //           "BKDate : 04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"));
// //       bytes.addAll(generator.text("EwayNo : 122127932351     SelfNo :"));
// //       bytes.addAll(generator.text(
// //           "Service Category : Transport of Goods By Road     SAC NO: 996511"));

// //       bytes.addAll(generator.feed(1));

// //       bytes.addAll(generator.text(
// //           "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
// //           styles: const PosStyles(bold: true)));
// //       bytes.addAll(generator.text("Name /Stamp /Sign",
// //           styles: const PosStyles(align: PosAlign.right)));

// //       bytes.addAll(generator.hr());

// //       bytes.addAll(generator.feed(2));
// //       bytes.addAll(generator.cut());

// //       bool allSuccess = true;
// //       for (int i = 0; i < count; i++) {
// //         final result = await PrintBluetoothThermal.writeBytes(bytes);
// //         if (!result) {
// //           allSuccess = false;
// //           break;
// //         }
// //       }

// //       if (allSuccess) {
// //         _showMessage("\u2705 Printed \$count copies successfully!");
// //       } else {
// //         _showMessage("\u274C Failed to print!");
// //       }
// //     } catch (e) {
// //       _showMessage("\u274C Print error: \$e");
// //     }
// //   }

// //   void _showMessage(String msg) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             Expanded(
// //               child: RotatedBox(
// //                 quarterTurns: 1,
// //                 child: Center(
// //                   child: Container(
// //                     width: 1000,
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       border: Border.all(color: Colors.black),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text(
// //                               "VRL LOGISTICS LTD",
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 18),
// //                             ),
// //                             Text(
// //                               "Consignor Copy",
// //                               style: TextStyle(fontSize: 14),
// //                             ),
// //                           ],
// //                         ),
// //                         const Divider(color: Colors.black),
// //                         Row(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Expanded(
// //                               flex: 4,
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   _buildRow("From",
// //                                       "HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659"),
// //                                   _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //                                 ],
// //                               ),
// //                             ),
// //                             const SizedBox(width: 8),
// //                             Column(
// //                               children: [
// //                                 Image.asset(
// //                                   "assets/QR_Code_Example.png",
// //                                   width: 80,
// //                                   height: 80,
// //                                   fit: BoxFit.contain,
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 const Text("9024325258"),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 4),
// //                         _buildRow(
// //                             "To", "KOPPAL [KA-KPL] - 74066-42467,08539-231066"),
// //                         _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //                         const SizedBox(height: 4),
// //                         _buildRow("Consignor", "TVS SRICHAKRA LIMITED"),
// //                         _buildRow("Consignee", "SRI GANESH AUTO AGENCY"),
// //                         _buildRow(
// //                             "Inv.No", "9137500612     D.Value Rs. :  78812"),
// //                         _buildRow("P.Code",
// //                             "18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"),
// //                         _buildRow("Packing", "LOOSE TYRE Tyre"),
// //                         _buildRow("BKDate",
// //                             "04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"),
// //                         _buildRow("EwayNo", "122127932351     SelfNo :"),
// //                         _buildRow("Service Category",
// //                             "Transport of Goods By Road     SAC NO: 996511"),
// //                         const SizedBox(height: 8),
// //                         const Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text(
// //                               "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
// //                               style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 15,
// //                               ),
// //                             ),
// //                             Text("Name /Stamp /Sign"),
// //                           ],
// //                         ),
// //                         const Divider(color: Colors.black),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(12),
// //               child: ElevatedButton.icon(
// //                 onPressed: () async {
// //                   final count = await _askPrintCount();
// //                   if (count != null && count > 0) {
// //                     await _printBodyLayout(count: count);
// //                   }
// //                 },
// //                 icon: const Icon(Icons.print),
// //                 label: const Text("Print This Page"),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.orange,
// //                   foregroundColor: Colors.white,
// //                   minimumSize: const Size.fromHeight(48),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   static Widget _buildRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 3),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //               width: 100,
// //               child: Text(
// //                 "$label :",
// //                 style: const TextStyle(fontWeight: FontWeight.bold),
// //               )),
// //           Expanded(child: Text(value)),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:image/image.dart' as img;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'home_screen.dart';
// import 'setting_screen.dart';

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
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) => debugPrint("Loading: $url"),
//           onPageFinished: (url) => debugPrint("Loaded: $url"),
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
//               hintText: 'Enter count (e.g. 1, 2, 3)',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, null),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final count = int.tryParse(controller.text.trim());
//                 if (count == null || count <= 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Invalid number")),
//                   );
//                   return;
//                 }
//                 Navigator.pop(context, count);
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

//       final img.Image rotated = img.copyRotate(decoded, angle: 270);
//       final img.Image resized = img.copyResize(rotated, width: 576);

//       final profile = await CapabilityProfile.load();
//       final generator = Generator(PaperSize.mm80, profile);
//       final List<int> bytes = [];

//       bytes.addAll(generator.image(resized));
//       bytes.addAll(generator.feed(2));
//       bytes.addAll(generator.cut());

//       for (int i = 0; i < count; i++) {
//         await PrintBluetoothThermal.writeBytes(bytes); // ✅ No check, just write
//       }

//       _showMessage("✅ Printed $count copies successfully!");
//     } catch (e) {
//       _showMessage("❌ Error: $e");
//     }
//   }

//   // Future<void> _printWebView({required int count}) async {
//   //   try {
//   //     final Uint8List? imageBytes = await _screenshotController.capture();
//   //     if (imageBytes == null) {
//   //       _showMessage("❌ Failed to capture WebView.");
//   //       return;
//   //     }

//   //     final img.Image? decoded = img.decodeImage(imageBytes);
//   //     if (decoded == null) {
//   //       _showMessage("❌ Failed to decode image.");
//   //       return;
//   //     }

//   //     final img.Image rotated = img.copyRotate(decoded, angle: 270);
//   //     final img.Image resized = img.copyResize(rotated, width: 576);

//   //     final profile = await CapabilityProfile.load();
//   //     final generator = Generator(PaperSize.mm80, profile);
//   //     final List<int> bytes = [];

//   //     bytes.addAll(generator.image(resized));
//   //     bytes.addAll(generator.feed(2));
//   //     bytes.addAll(generator.cut());

//   //     bool allSuccess = true;
//   //     for (int i = 0; i < count; i++) {
//   //       final result = await PrintBluetoothThermal.writeBytes(bytes);
//   //       if (!result) {
//   //         allSuccess = false;
//   //         break;
//   //       }
//   //     }

//   //     if (allSuccess) {
//   //       _showMessage("✅ Printed $count copies successfully!");
//   //     } else {
//   //       _showMessage("❌ Failed to print!");
//   //     }
//   //   } catch (e) {
//   //     _showMessage("❌ Error: $e");
//   //   }
//   // }

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
