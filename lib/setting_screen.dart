import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterSettingScreen extends StatefulWidget {
  const PrinterSettingScreen({super.key});

  @override
  State<PrinterSettingScreen> createState() => _PrinterSettingScreenState();
}

class _PrinterSettingScreenState extends State<PrinterSettingScreen>
    with SingleTickerProviderStateMixin {
  String printerCommand = 'TSPL';
  int labelWidth = 110;
  int labelHeight = 60;
  String labelGap = '';
  int angle = 180;
  bool autoApply = true;
  String connectedDeviceName = '';
  String connectedDeviceMac = '';
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
    _loadSettings();
    _loadConnectedDevice();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      printerCommand = prefs.getString('printerCommand') ?? 'TSPL';
      labelWidth = prefs.getInt('labelWidth') ?? 220;
      labelHeight = prefs.getInt('labelHeight') ?? 120;
      labelGap = prefs.getString('labelGap') ?? '1mm';
      angle = prefs.getInt('angle') ?? 90;
      autoApply = prefs.getBool('autoApply') ?? true;
    });

    if (autoApply && await PrintBluetoothThermal.connectionStatus == true) {
      await _applySettingsToPrinter();
    }
  }

  Future<void> _loadConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      connectedDeviceName = prefs.getString('last_connected_name') ?? '';
      connectedDeviceMac = prefs.getString('last_connected_mac') ?? '';
    });
  }

  Future<void> _applySettingsToPrinter() async {
    String command = "SIZE $labelWidth mm,$labelHeight mm\n";
    command += "GAP $labelGap\n";
    command += "DIRECTION ${angle ~/ 90}\n";
    command += "CLS\n";
    command += "TEXT 100,100,\"3\",0,1,1,\"Test Print\"\n";
    command += "PRINT 1\n";

    await PrintBluetoothThermal.writeBytes(command.codeUnits);
  }

  Future<void> _printTestLabel() async {
    if (await PrintBluetoothThermal.connectionStatus == true) {
      String command = "SIZE $labelWidth mm,$labelHeight mm\n";
      command += "GAP $labelGap\n";
      command += "DIRECTION ${angle ~/ 90}\n";
      command += "CLS\n";
      command += "TEXT 100,100,\"3\",0,1,1,\"Test Print\"\n";
      command += "PRINT 1\n";

      await PrintBluetoothThermal.writeBytes(command.codeUnits);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printerCommand', printerCommand);
    await prefs.setInt('labelWidth', labelWidth);
    await prefs.setInt('labelHeight', labelHeight);
    await prefs.setString('labelGap', labelGap);
    await prefs.setInt('angle', angle);
    await prefs.setBool('autoApply', autoApply);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settings saved!")),
      );
    }
  }

  void _resetDefaults() {
    setState(() {
      printerCommand = 'TSPL';
      labelWidth = 220;
      labelHeight = 120;
      labelGap = '1mm';
      angle = 180;
      autoApply = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Printer Settings"),
          backgroundColor: Colors.orange),
      body: FadeTransition(
        opacity: _controller,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (connectedDeviceMac.isNotEmpty) ...[
              const Text("Connected Device",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.print, color: Colors.orange),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(connectedDeviceName),
                    TextButton.icon(
                      onPressed: _printTestLabel,
                      icon: const Icon(Icons.bug_report, size: 18),
                      label: const Text("Test", style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                subtitle: Text(connectedDeviceMac),
              ),
              const Divider(),
            ],
            const Text("Command for print image",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: printerCommand,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'TSPL', child: Text('TSPL')),
                DropdownMenuItem(value: 'ZPL', child: Text('ZPL')),
                DropdownMenuItem(value: 'ESC/POS', child: Text('ESC/POS')),
              ],
              onChanged: (val) => setState(() => printerCommand = val!),
            ),
            const SizedBox(height: 20),
            const Text("Label paper settings",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: labelWidth.toString(),
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Label width (mm)"),
                    onChanged: (val) => labelWidth = int.tryParse(val) ?? 110,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: labelHeight.toString(),
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Label height (mm)"),
                    onChanged: (val) => labelHeight = int.tryParse(val) ?? 60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: labelGap,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: '1mm', child: Text('1mm')),
                DropdownMenuItem(value: '2mm', child: Text('2mm')),
                DropdownMenuItem(value: '3mm', child: Text('3mm')),
                DropdownMenuItem(value: '4mm', child: Text('4mm')),
                DropdownMenuItem(value: '5mm', child: Text('5mm')),
              ],
              onChanged: (val) => setState(() => labelGap = val!),
            ),
            const SizedBox(height: 20),
            const Text("Select printing angle",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [0, 90, 180, 270].map((deg) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<int>(
                        value: deg,
                        groupValue: angle,
                        onChanged: (val) => setState(() => angle = val!)),
                    Text("$deg°")
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Auto-apply settings on connect"),
              value: autoApply,
              onChanged: (val) => setState(() => autoApply = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Settings"),
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Reset to Default"),
              onPressed: _resetDefaults,
            ),
          ],
        ),
      ),
    );
  }
}
