// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:screenshot/screenshot.dart';
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
//   }

//   Future<Map<String, dynamic>> _loadLatestSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'printerCommand': prefs.getString('printerCommand') ?? 'TSPL',
//       'labelWidth': prefs.getInt('labelWidth') ?? 110,
//       'labelHeight': prefs.getInt('labelHeight') ?? 60,
//       'labelGap': prefs.getString('labelGap') ?? '1mm',
//       'angle': prefs.getInt('angle') ?? 0,
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
//       final settings = await _loadLatestSettings();

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

//       final rotated = img.copyRotate(decoded, angle: 90);
//       final resized = img.copyResize(rotated, width: 576); // for 80mm printer
//       final Uint8List monoData = _convertToMonochrome(resized);

//       final widthBytes = (resized.width + 7) ~/ 8;
//       final height = resized.height;

//       final String tsplCommand = '''
// SIZE ${settings['labelWidth']} mm,${settings['labelHeight']} mm
// GAP ${settings['labelGap']},0
// CLS
// BITMAP 0,0,$widthBytes,$height,0,${_toHexString(monoData)}
// PRINT $count
// ''';

//       final result =
//           await PrintBluetoothThermal.writeBytes(utf8.encode(tsplCommand));

//       if (result) {
//         _showMessage("✅ Printed $count copies successfully!");
//       } else {
//         _showMessage("❌ Failed to print.");
//       }
//     } catch (e) {
//       _showMessage("❌ Print error: $e");
//     }
//   }

//   Uint8List _convertToMonochrome(img.Image image) {
//     final int width = image.width;
//     final int height = image.height;
//     final int byteWidth = (width + 7) ~/ 8;

//     final Uint8List bytes = Uint8List(byteWidth * height);

//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         final pixel = image.getPixel(x, y);
//         final luminance = img.getLuminance(pixel);
//         final bit = luminance < 128 ? 1 : 0;
//         final byteIndex = y * byteWidth + (x ~/ 8);
//         final bitIndex = 7 - (x % 8);
//         if (bit == 1) {
//           bytes[byteIndex] |= (1 << bitIndex);
//         }
//       }
//     }

//     return bytes;
//   }

//   String _toHexString(Uint8List bytes) {
//     final StringBuffer buffer = StringBuffer();
//     for (final byte in bytes) {
//       buffer.write(byte.toRadixString(16).padLeft(2, '0'));
//     }
//     return buffer.toString().toUpperCase();
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

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'home_screen.dart';
import 'setting_screen.dart';

class PrinterScreen extends StatefulWidget {
  final BluetoothInfo? device;

  const PrinterScreen({super.key, required this.device});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BluetoothInfo? connectedDevice;
  final ScreenshotController _screenshotController = ScreenshotController();
  late WebViewController _webViewController;

  final String webUrl =
      'https://dev.vrlapps.com/corevrl/core_app_booking/bk_gcprint_collection_landscap.aspx';

  @override
  void initState() {
    super.initState();
    connectedDevice = widget.device;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (connectedDevice == null) {
        _scaffoldKey.currentState?.openDrawer();
      }
    });

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(webUrl));
  }

  Future<Map<String, dynamic>> _loadLatestSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'printerCommand': prefs.getString('printerCommand') ?? 'TSPL',
      'labelWidth': prefs.getInt('labelWidth') ?? 110,
      'labelHeight': prefs.getInt('labelHeight') ?? 60,
      'labelGap': prefs.getString('labelGap') ?? '1mm',
      'angle': prefs.getInt('angle') ?? 90,
    };
  }

  Future<int?> _askPrintCount() async {
    final TextEditingController controller = TextEditingController(text: "1");

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter number of copies'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter count (e.g. 1, 2, 5)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                final parsed = int.tryParse(text);
                if (parsed == null || parsed <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter a valid number")),
                  );
                  return;
                }
                Navigator.pop(context, parsed);
              },
              child: const Text('Print'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _printWebView({required int count}) async {
    try {
      final settings = await _loadLatestSettings();

      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes == null) {
        _showMessage("❌ Failed to capture WebView.");
        return;
      }

      final img.Image? decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        _showMessage("❌ Failed to decode image.");
        return;
      }

      // Rotate image if needed
      final img.Image rotated =
          img.copyRotate(decoded, angle: settings['angle']);

      // Resize to target width (576px for 80mm at 203 DPI)
      const int targetWidth = 576;
      final img.Image resized = img.copyResize(rotated, width: targetWidth);

      // Optional debug image save (if running on device with file access)
      // final File debugFile = File('/sdcard/print_debug.png');
      // await debugFile.writeAsBytes(img.encodePng(resized));

      // Convert to monochrome bitmap (1-bit per pixel)
      final Uint8List monoData = _convertToMonochrome(resized);

      final int widthBytes = (resized.width + 7) ~/ 8;
      final int height = resized.height;

      final String tsplCommand = '''
SIZE ${settings['labelWidth']} mm,${settings['labelHeight']} mm
GAP ${settings['labelGap']},0
CLS
BITMAP 0,0,$widthBytes,$height,0,${_toHexString(monoData)}
PRINT $count
''';

      final result = await PrintBluetoothThermal.writeBytes(
        utf8.encode(tsplCommand).toList(),
      );

      if (result) {
        _showMessage("✅ Printed $count copies successfully!");
      } else {
        _showMessage("❌ Failed to print.");
      }
    } catch (e) {
      _showMessage("❌ Print error: $e");
    }
  }

  Uint8List _convertToMonochrome(img.Image image) {
    final int width = image.width;
    final int height = image.height;
    final int byteWidth = (width + 7) ~/ 8;

    final Uint8List bytes = Uint8List(byteWidth * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        final bit = luminance < 128 ? 1 : 0;
        final byteIndex = y * byteWidth + (x ~/ 8);
        final bitIndex = 7 - (x % 8);
        if (bit == 1) {
          bytes[byteIndex] |= (1 << bitIndex);
        }
      }
    }

    return bytes;
  }

  String _toHexString(Uint8List bytes) {
    final StringBuffer buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase();
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _disconnect() async {
    await PrintBluetoothThermal.disconnect;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_connected_mac');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BluetoothDeviceScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(connectedDevice != null
            ? "Printer (${connectedDevice!.name})"
            : "Printer"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.devices, color: Colors.orange),
              title: const Text('Bluetooth Devices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BluetoothDeviceScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.orange),
              title: const Text('Printer Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrinterSettingScreen()),
                );
              },
            ),
            if (connectedDevice != null)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text("Disconnect"),
                onTap: _disconnect,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final count = await _askPrintCount();
                if (count != null && count > 0) {
                  await _printWebView(count: count);
                }
              },
              icon: const Icon(Icons.print),
              label: const Text("Print This Page"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
