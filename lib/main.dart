import 'package:company_printer/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      // home: ConsignmentNoteScreen(),
      // home: ThermalConsignmentReceipt(),
      // home: VRLLogisticsScreen(),
    );
  }
}

// class VRLLogisticsScreen extends StatelessWidget {
//   const VRLLogisticsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: RotatedBox(
//           quarterTurns: 1,
//           child: Center(
//             child: Container(
//               width: 1000,
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Row
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "VRL LOGISTICS LTD",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 18),
//                       ),
//                       Text(
//                         "Consignor Copy",
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                   const Divider(color: Colors.black),

//                   // FROM + GSTIN + QR on right
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 4,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildRow("From",
//                                 "HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659"),
//                             _buildRow("GSTIN", "29AABCV3609C1ZJ"),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Column(
//                         children: [
//                           Image.asset(
//                             "assets/QR_Code_Example.png", // Replace with your image path
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.contain,
//                           ),
//                           const SizedBox(height: 4),
//                           const Text("9024325258"),
//                         ],
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 4),
//                   _buildRow("To", "KOPPAL [KA-KPL] - 74066-42467,08539-231066"),
//                   _buildRow("GSTIN", "29AABCV3609C1ZJ"),
//                   const SizedBox(height: 4),
//                   _buildRow("Consignor", "TVS SRICHAKRA LIMITED"),
//                   _buildRow("Consignee", "SRI GANESH AUTO AGENCY"),
//                   _buildRow("Inv.No", "9137500612     D.Value Rs. :  78812"),
//                   _buildRow("P.Code",
//                       "18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"),
//                   _buildRow("Packing", "LOOSE TYRE Tyre"),
//                   _buildRow("BKDate",
//                       "04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"),
//                   _buildRow("EwayNo", "122127932351     SelfNo :"),
//                   _buildRow("Service Category",
//                       "Transport of Goods By Road     SAC NO: 996511"),

//                   const SizedBox(height: 8),

//                   // DOOR DELIVERY + Sign Row
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                           // decoration: TextDecoration.underline,
//                         ),
//                       ),
//                       Text("Name /Stamp /Sign"),
//                     ],
//                   ),

//                   const Divider(color: Colors.black),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 3),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//               width: 100,
//               child: Text(
//                 "$label :",
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               )),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }


// // class VRLLogisticsScreen extends StatelessWidget {
// //   const VRLLogisticsScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SafeArea(
// //         child: RotatedBox(
// //           quarterTurns: 1,
// //           child: Center(
// //             child: Container(
// //               width: 1000,
// //               padding: const EdgeInsets.all(8),
// //               decoration: BoxDecoration(
// //                 border: Border.all(color: Colors.black),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Header row
// //                   const Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         "VRL LOGISTICS LTD",
// //                         style: TextStyle(
// //                             fontWeight: FontWeight.bold, fontSize: 18),
// //                       ),
// //                       Text(
// //                         "Consignor Copy",
// //                         style: TextStyle(fontSize: 14),
// //                       ),
// //                     ],
// //                   ),
// //                   const Divider(color: Colors.black),
// //                   _buildRow(
// //                       "From", "HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659"),
// //                   _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //                   const SizedBox(height: 4),
// //                   _buildRow("To", "KOPPAL [KA-KPL] - 74066-42467,08539-231066"),
// //                   _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //                   const SizedBox(height: 4),
// //                   _buildRow("Consignor", "TVS SRICHAKRA LIMITED"),
// //                   _buildRow("Consignee", "SRI GANESH AUTO AGENCY"),
// //                   _buildRow("Inv.No", "9137500612     D.Value Rs. :  78812"),
// //                   _buildRow("P.Code",
// //                       "18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"),
// //                   _buildRow("Packing", "LOOSE TYRE Tyre"),
// //                   _buildRow("BKDate",
// //                       "04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"),
// //                   _buildRow("EwayNo", "122127932351     SelfNo :"),
// //                   _buildRow("Service Category",
// //                       "Transport of Goods By Road     SAC NO: 996511"),
// //                   const SizedBox(height: 4),
// //                   const Text(
// //                     "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 15,
// //                       decoration: TextDecoration.underline,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Row(
// //                     children: [
// //                       const Spacer(),
// //                       Column(
// //                         children: [
// //                           Image.asset(
// //                             // 'assets/qr.png',
// //                             "assets/QR_Code_Example.png",
// //                             width: 80,
// //                             height: 80,
// //                             fit: BoxFit.contain,
// //                           ),
// //                           const SizedBox(height: 4),
// //                           const Text("9024325258"),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                   const Divider(color: Colors.black),
// //                   const Align(
// //                     alignment: Alignment.centerRight,
// //                     child: Text("Name /Stamp /Sign"),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
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

// // class VRLLogisticsScreen extends StatelessWidget {
// //   const VRLLogisticsScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Center(
// //         child: Container(
// //           width: 1000,
// //           padding: const EdgeInsets.all(8),
// //           decoration: BoxDecoration(
// //             border: Border.all(color: Colors.black),
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Header row
// //               const Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     "VRL LOGISTICS LTD",
// //                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
// //                   ),
// //                   Text(
// //                     "Consignor Copy",
// //                     style: TextStyle(fontSize: 14),
// //                   ),
// //                 ],
// //               ),
// //               const Divider(color: Colors.black),
// //               _buildRow("From", "HUBBALLI APMC MARKET [HBLAPMC] - 93791-68659"),
// //               _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //               const SizedBox(height: 4),
// //               _buildRow("To", "KOPPAL [KA-KPL] - 74066-42467,08539-231066"),
// //               _buildRow("GSTIN", "29AABCV3609C1ZJ"),
// //               const SizedBox(height: 4),
// //               _buildRow("Consignor", "TVS SRICHAKRA LIMITED"),
// //               _buildRow("Consignee", "SRI GANESH AUTO AGENCY"),
// //               _buildRow("Inv.No", "9137500612     D.Value Rs. :  78812"),
// //               _buildRow("P.Code",
// //                   "18695 - GST PAYABLE BY A/C PARTY-RCM    A/C - DOOR"),
// //               _buildRow("Packing", "LOOSE TYRE Tyre"),
// //               _buildRow("BKDate",
// //                   "04-06-2025     Nos :17     Ch Weight :595     Rate : 116.00"),
// //               _buildRow("EwayNo", "122127932351     SelfNo :"),
// //               _buildRow("Service Category",
// //                   "Transport of Goods By Road     SAC NO: 996511"),
// //               const SizedBox(height: 4),
// //               const Text(
// //                 "DOOR DELIVERY / ETD :04-06  17:40 - EntBy :68889",
// //                 style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 15,
// //                     decoration: TextDecoration.underline),
// //               ),
// //               const SizedBox(height: 8),
// //               Row(
// //                 children: [
// //                   const Spacer(),
// //                   Column(
// //                     children: [
// //                       Image.asset(
// //                         'assets/qr.png', // 🔁 Replace with your image path
// //                         width: 80,
// //                         height: 80,
// //                         fit: BoxFit.contain,
// //                       ),
// //                       const SizedBox(height: 4),
// //                       const Text("9024325258"),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //               const Divider(color: Colors.black),
// //               const Align(
// //                 alignment: Alignment.centerRight,
// //                 child: Text("Name /Stamp /Sign"),
// //               ),
// //             ],
// //           ),
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
