// import 'package:company_printer/printer_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BluetoothDeviceScreen extends StatefulWidget {
//   const BluetoothDeviceScreen({super.key});

//   @override
//   State<BluetoothDeviceScreen> createState() => _BluetoothDeviceScreenState();
// }

// class _BluetoothDeviceScreenState extends State<BluetoothDeviceScreen> {
//   List<BluetoothInfo> devices = [];
//   String connectedMac = '';
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _initPermissionsAndScan();
//     _loadConnectedMac();
//   }

//   Future<void> _loadConnectedMac() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       connectedMac = prefs.getString('last_connected_mac') ?? '';
//     });
//   }

//   Future<void> _initPermissionsAndScan() async {
//     await Permission.location.request();
//     await Permission.bluetooth.request();
//     await Permission.bluetoothScan.request();
//     await Permission.bluetoothConnect.request();
//     _scanDevices();
//   }

//   Future<void> _scanDevices() async {
//     setState(() => isLoading = true);
//     final results = await PrintBluetoothThermal.pairedBluetooths;
//     setState(() {
//       devices = results;
//       isLoading = false;
//     });
//   }

//   Future<void> _connectToDevice(BluetoothInfo device) async {
//     final bool wasMounted = mounted;
//     bool result = await PrintBluetoothThermal.connect(
//         macPrinterAddress: device.macAdress);

//     if (!wasMounted || !mounted) return;

//     if (result) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('last_connected_mac', device.macAdress);
//       if (!mounted) return;

//       setState(() => connectedMac = device.macAdress);

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => PrinterScreen(device: device)),
//       );
//     } else {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to connect to device")),
//       );
//     }
//   }

//   Future<void> _disconnect() async {
//     await PrintBluetoothThermal.disconnect;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('last_connected_mac');
//     setState(() => connectedMac = '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.orange,
//         title: const Text("Connect Bluetooth"),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _scanDevices,
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : ListView.builder(
//                 padding: const EdgeInsets.all(12),
//                 itemCount: devices.length,
//                 itemBuilder: (context, index) {
//                   final device = devices[index];
//                   final isConnected = device.macAdress == connectedMac;
//                   return Card(
//                     color: isConnected ? Colors.orange.shade100 : null,
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 16.0, horizontal: 16.0),
//                       title: Row(
//                         children: [
//                           Expanded(child: Text(device.name)),
//                           if (isConnected)
//                             const Text("Connected",
//                                 style: TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       subtitle: Text(device.macAdress),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (isConnected)
//                             const Icon(Icons.star, color: Colors.orange),
//                           PopupMenuButton<String>(
//                             onSelected: (value) {
//                               if (value == 'disconnect') {
//                                 _disconnect();
//                               } else if (value == 'connect') {
//                                 _connectToDevice(device);
//                               }
//                             },
//                             itemBuilder: (_) => [
//                               if (!isConnected)
//                                 const PopupMenuItem(
//                                     value: 'connect', child: Text('Connect')),
//                               if (isConnected)
//                                 const PopupMenuItem(
//                                     value: 'disconnect',
//                                     child: Text('Disconnect')),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }

import 'package:company_printer/model/mac_model.dart';
import 'package:company_printer/p.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BluetoothDeviceScreen extends StatefulWidget {
  const BluetoothDeviceScreen({super.key});

  @override
  State<BluetoothDeviceScreen> createState() => _BluetoothDeviceScreenState();
}

class _BluetoothDeviceScreenState extends State<BluetoothDeviceScreen> {
  List<BluetoothInfo> devices = [];
  String connectedMac = '';
  bool isLoading = false;

  List<Mac> allowedMacs = [];

  @override
  void initState() {
    super.initState();
    _initPermissionsAndScan();
    _loadConnectedMac();
  }

  Future<void> _loadConnectedMac() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      connectedMac = prefs.getString('last_connected_mac') ?? '';
    });
  }

  Future<void> _initPermissionsAndScan() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await _fetchAllowedMacs(); // ✅ Get valid MACs first
    _scanDevices();
  }

  Future<void> _fetchAllowedMacs() async {
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.45:8000/api/printers'));
      if (response.statusCode == 200) {
        final macModel = macModelFromJson(response.body);
        setState(() {
          allowedMacs = macModel.data;
        });
      } else {
        throw Exception('Failed to load MACs');
      }
    } catch (e) {
      debugPrint('Error fetching MACs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching allowed MACs')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _scanDevices() async {
    setState(() => isLoading = true);
    final results = await PrintBluetoothThermal.pairedBluetooths;
    setState(() {
      devices = results;
      isLoading = false;
    });
  }

  // Future<void> _connectToDevice(BluetoothInfo device) async {
  //   // ✅ Check if scanned MAC is in API list
  //   final matched =
  //       allowedMacs.any((mac) => mac.macAddress == device.macAdress);

  //   if (!matched) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("This device is not allowed")),
  //     );
  //     return; // ❌ Stop here
  //   }

  //   final wasMounted = mounted;

  //   bool result = await PrintBluetoothThermal.connect(
  //       macPrinterAddress: device.macAdress);

  //   if (!wasMounted || !mounted) return;

  //   if (result) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('last_connected_mac', device.macAdress);
  //     if (!mounted) return;

  //     setState(() => connectedMac = device.macAdress);

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => PrinterScreen(device: device)),
  //     );
  //   } else {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Failed to connect to device")),
  //     );
  //   }
  // }

  Future<void> _connectToDevice(BluetoothInfo device) async {
    final wasMounted = mounted;

    bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: device.macAdress,
    );

    if (!wasMounted || !mounted) return;

    if (result) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_connected_mac', device.macAdress);
      if (!mounted) return;

      setState(() => connectedMac = device.macAdress);

      // ✅ Check if connected MAC is in allowed list
      final matched =
          allowedMacs.any((mac) => mac.macAddress == device.macAdress);

      if (matched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Allowed printer connected.")),
        );

        // ✅ Navigate only if match
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PrinterScreen(device: device)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ This printer is not allowed.")),
        );

        await PrintBluetoothThermal.disconnect;

        await prefs.remove('last_connected_mac');

        setState(() => connectedMac = '');
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to device")),
      );
    }
  }

  // Future<void> _disconnect() async {
  //   await PrintBluetoothThermal.disconnect;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('last_connected_mac');
  //   setState(() => connectedMac = '');
  // }

  Future<void> _disconnect() async {
    await PrintBluetoothThermal.disconnect;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_connected_mac');
    setState(() => connectedMac = '');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Disconnected successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Connect Bluetooth"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchAllowedMacs();
          await _scanDevices();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final isConnected = device.macAdress == connectedMac;
                  return Card(
                    color: isConnected ? Colors.orange.shade100 : null,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      title: Row(
                        children: [
                          Expanded(child: Text(device.name)),
                          if (isConnected)
                            const Text("Connected",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                        ],
                      ),
                      subtitle: Text(device.macAdress),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isConnected)
                            const Icon(Icons.star, color: Colors.orange),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'disconnect') {
                                _disconnect();
                              } else if (value == 'connect') {
                                _connectToDevice(device);
                              }
                            },
                            itemBuilder: (_) => [
                              if (!isConnected)
                                const PopupMenuItem(
                                    value: 'connect', child: Text('Connect')),
                              if (isConnected)
                                const PopupMenuItem(
                                    value: 'disconnect',
                                    child: Text('Disconnect')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
