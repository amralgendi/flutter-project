import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:dio/dio.dart';
import 'package:hedieaty/home/data/barcode_details.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String scannedResult = "No barcode scanned yet.";

  final Dio _dio = Dio();

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      print(result.rawContent);

      final response = await _dio.get(
          "https://api.barcodelookup.com/v3/products?barcode=${result.rawContent}&formatted=y&key=nnbpuqi1qv0criduxsh7rm26zk1raw");

      if (response.statusCode == 200) {
        // Successfully fetched data
        setState(() {
          Map<String, dynamic> map = jsonDecode(response.data);

          BarcodeDetails details = BarcodeDetails.fromJson(map);

          scannedResult = details.barcodeNumber +
              '\n' +
              details.name +
              '\n' +
              details.price.toString(); // Display fetched data
        });
      } else {
        setState(() {
          scannedResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        scannedResult = "Failed to scan barcode: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scannedResult,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: const Text('Scan Barcode'),
            ),
          ],
        ),
      ),
    );
  }
}
