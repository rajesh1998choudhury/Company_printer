import 'dart:typed_data';
import 'package:company_printer/model/mac_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart' as escpos;

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  ReceiptController? controller;
  BluetoothDevice? bluetoothDeviceAddress;
  bool loading = false;

  List<Mac> allowedMacs = []; //new

  @override
  void initState() {
    super.initState();
    _loadSavedPrinter();
    _fetchAllowedMacs(); // new
  }

  Future<void> _fetchAllowedMacs() async {
    try {
      final response =
          await http.get(Uri.parse('http://45.64.107.7/api/printers'));
      if (response.statusCode == 200) {
        final macModel = macModelFromJson(response.body);
        setState(() {
          allowedMacs = macModel.data;
        });
      } else {
        throw Exception('Failed to load MAC list');
      }
    } catch (e) {
      debugPrint('Error fetching allowed MACs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching allowed MACs')),
      );
    }
  }

  Future<void> _loadSavedPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('printer_name');
    String? address = prefs.getString('printer_address');

    if (name != null && address != null) {
      setState(() {
        bluetoothDeviceAddress = BluetoothDevice(name: name, address: address);
      });
    }
  }

  Future<void> _savePrinter(BluetoothDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_name', device.name!);
    await prefs.setString('printer_address', device.address);
  }

  // Future<void> selectPrinter() async {
  //   final address = await FlutterBluetoothPrinter.selectDevice(context);
  //   if (address != null) {
  //     setState(() {
  //       bluetoothDeviceAddress = address;
  //     });
  //     _savePrinter(address);
  //   }
  // }

  Future<void> selectPrinter() async {
    //new
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null) {
      // ✅ Check MAC before saving
      if (!_isPrinterAllowed(device.address)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ This printer is not allowed.")),
        );
        return;
      }
      setState(() {
        bluetoothDeviceAddress = device;
      });
      _savePrinter(device);
    }
  }

  Future<Uint8List> loadImageBytes(String path) async {
    final data = await rootBundle.load(path);
    final originalImage = img.decodeImage(data.buffer.asUint8List())!;
    final resized = img.copyResize(originalImage,
        width: 576, height: 200); // Resize for thermal printer
    final rotated = img.copyRotate(resized, angle: 90);
    return Uint8List.fromList(img.encodeJpg(rotated));
  }

  Future<Uint8List> loadImageFullWidth(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Failed to load image. Status: ${response.statusCode}");
    }

    final originalImage = img.decodeImage(response.bodyBytes);
    if (originalImage == null) throw Exception("Unable to decode image");

    // Rotate if needed
    final rotated = img.copyRotate(originalImage, angle: 90);

    // Resize to 576px width (max for 80mm printer)
    final resized = img.copyResize(
      rotated,
      width: 576, // Change to 384 if using 58mm printer
      interpolation: img.Interpolation.linear,
    );

    return Uint8List.fromList(img.encodeJpg(resized));
  }

  Future<Uint8List> loadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final originalImage = img.decodeImage(response.bodyBytes);
        if (originalImage == null) throw Exception("Unable to decode image");

        // ⿡ Rotate first (if needed)
        final rotatedImage = img.copyRotate(originalImage, angle: 90);

        // ⿢ Resize to printer's full width (80mm printer → 576px, 58mm → 384px)
        // final resizedImage = img.copyResize(
        //   rotatedImage,
        //   width: 576, // Adjust based on your printer model
        //   interpolation: img.Interpolation.nearest,
        // );

        // ⿣ Return image bytes
        return Uint8List.fromList(img.encodeJpg(rotatedImage));
      } else {
        throw Exception(
            "Failed to load image. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("loadImageFromUrl ERROR: $e");
      rethrow;
    }
  }

  //new

  bool _isPrinterAllowed(String macAddress) {
    return allowedMacs.any((mac) => mac.macAddress == macAddress);
  }

  //new

  Future<int?> _askForCopies() async {
    final TextEditingController controller = TextEditingController(text: "1");

    return await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Number of Copies"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter copies",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int entered = int.tryParse(controller.text) ?? 1;
                if (entered < 1) entered = 1;
                Navigator.pop(context, entered);
              },
              child: const Text("Print"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Receipt Print"),
      //   backgroundColor: Colors.orange,
      //   actions: [
      //     IconButton(
      //       onPressed: () async {
      //         await selectPrinter();
      //         setState(() {}); // Refresh to update icon status
      //       },
      //       icon: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Row(
      //           children: [
      //             Icon(
      //               bluetoothDeviceAddress == null
      //                   ? Icons.bluetooth_disabled
      //                   : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
      //                       ? Icons.warning
      //                       : Icons.bluetooth_connected),
      //               color: bluetoothDeviceAddress == null
      //                   ? Colors.red
      //                   : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
      //                       ? Colors.orange
      //                       : Colors.green),
      //             ),
      //             const SizedBox(width: 4),
      //             Text(
      //               bluetoothDeviceAddress == null
      //                   ? "Disconnected"
      //                   : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
      //                       ? "Not Allowed"
      //                       : "Connected"),
      //               style: TextStyle(
      //                 color: bluetoothDeviceAddress == null
      //                     ? Colors.red
      //                     : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
      //                         ? Colors.orange
      //                         : Colors.green),
      //                 fontSize: 14,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       tooltip: bluetoothDeviceAddress == null
      //           ? "Select Printer"
      //           : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
      //               ? "Printer Not Allowed"
      //               : "Printer Connected"),
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        title: const Text("Receipt Print"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () async {
              if (bluetoothDeviceAddress == null) {
                // 🔹 No printer → select
                await selectPrinter();
              } else if (!_isPrinterAllowed(bluetoothDeviceAddress!.address)) {
                // 🔹 Printer not allowed → disconnect
                setState(() {
                  bluetoothDeviceAddress = null;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('printer_name');
                await prefs.remove('printer_address');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("❌ Printer not allowed. Disconnected.")),
                );
              } else {
                // 🔹 Printer allowed & connected → disconnect
                setState(() {
                  bluetoothDeviceAddress = null;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('printer_name');
                await prefs.remove('printer_address');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Printer disconnected.")),
                );
              }
              setState(() {}); // Refresh UI
            },
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    bluetoothDeviceAddress == null
                        ? Icons.bluetooth_disabled
                        : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
                            ? Icons.warning
                            : Icons.bluetooth_connected),
                    color: bluetoothDeviceAddress == null
                        ? Colors.red
                        : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
                            ? Colors.orange
                            : Colors.black),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    bluetoothDeviceAddress == null
                        ? "Disconnected"
                        : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
                            ? "Not Allowed"
                            : "Connected"),
                    style: TextStyle(
                      color: bluetoothDeviceAddress == null
                          ? Colors.red
                          : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
                              ? Colors.orange
                              : Colors.black),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            tooltip: bluetoothDeviceAddress == null
                ? "Select Printer"
                : (!_isPrinterAllowed(bluetoothDeviceAddress!.address)
                    ? "Printer Not Allowed - Click to Disconnect"
                    : "Disconnect Printer"),
          ),
        ],
      ),

      // appBar: AppBar(
      //   title: const Text("Receipt Print"),
      //   backgroundColor: Colors.orange,

      // ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(color: Colors.orange),
      //         child: Text('Menu',
      //             style: TextStyle(color: Colors.white, fontSize: 24)),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.devices, color: Colors.orange),
      //         title: const Text('Bluetooth Devices'),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (_) => const BluetoothDeviceScreen()),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: Receipt(
        builder: (context) => Column(
          children: [
            SizedBox(
              child: FutureBuilder<Uint8List>(
                future: loadImageFromUrl(
                    "http://45.64.107.7/table-image-mobile.png"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading image...");
                  } else if (snapshot.hasError) {
                    return const Text("Error loading image");
                  } else {
                    return Image.memory(snapshot.data!, width: 800);
                  }
                },
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
        onInitialized: (ctrl) {
          controller = ctrl;
        },
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          if (bluetoothDeviceAddress == null) {
            await selectPrinter();
          }

          if (bluetoothDeviceAddress == null) {
            debugPrint("No printer selected");
            return;
          }

          // ✅ MAC address validation
          if (!_isPrinterAllowed(bluetoothDeviceAddress!.address)) {
            //new
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ This printer is not allowed.")),
            );
            return;
          }

          // Ask for number of copies  //new
          int? copies = await _askForCopies();
          if (copies == null || copies < 1) {
            return; // Cancelled or invalid
          }

          // if (bluetoothDeviceAddress != null) {
          try {
            debugPrint(
                "bluetooh device ------ ${bluetoothDeviceAddress!.address}");

            final imageBytes = await loadImageFullWidth(
              'http://45.64.107.7/table-image-mobile.png',
            );
            debugPrint("image  bytes $imageBytes");

            final profile = await escpos.CapabilityProfile.load();

            final generator = escpos.Generator(
              escpos.PaperSize.mm80,
              profile,
            );

            final List<int> bytes = [];

            bytes.addAll(generator.image(
              img.decodeImage(imageBytes)!,
              align: escpos.PosAlign.left,
            ));
            bytes.addAll(generator.feed(1));
            bytes.addAll(generator.cut());

            for (int i = 0; i < copies; i++) {
              //new
              await FlutterBluetoothPrinter.printBytes(
                address: bluetoothDeviceAddress!.address,
                data: Uint8List.fromList(bytes),
                keepConnected: true,
              );
            } //new
            debugPrint("Printing Successfully completed...");
            debugPrint("✅ Printed $copies copies successfully.");
          } catch (e) {
            debugPrint("Printing failed: $e");
          }
          // }
        },
        child: const Text("Print Receipt"),
      ),
    );
  }
}
