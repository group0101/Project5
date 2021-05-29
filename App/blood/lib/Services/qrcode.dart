import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

/// show QR code
class QRCodeView extends StatefulWidget {
  @override
  _QRCodeViewState createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeView> {
  User _user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = context.read<User>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code"),
      ),
      body: Container(
        height: double.infinity,
        child: Center(
          child: Container(
            child: QrImage(
              data: "${_user.uid} ${_user.email}",
              version: QrVersions.auto,
              foregroundColor: Colors.black,
              size: MediaQuery.of(context).size.width * 0.9,
            ),
          ),
        ),
      ),
    );
  }
}

/// create QR code Scanner
class QRCodeScan extends StatefulWidget {
  @override
  _QRCodeScanState createState() => _QRCodeScanState();
}

class _QRCodeScanState extends State<QRCodeScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  Barcode result;
  String qrText;

  // reassemble in debug mode for hot reload
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          GestureDetector(
            onTap: () {
              controller.resumeCamera();
            },
            child: ClipPath(
              clipper: MyClipper(),
              child: Container(
                color: _primary.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// run after qr view is created
  ///
  /// creates qr controller to scan qr code
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) {
        if (scanData.format == BarcodeFormat.qrcode) {
          controller.pauseCamera();
          Navigator.of(context).pop(scanData.code);
        }
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/// create clippath filter for QR code scanner
class MyClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    // TODO: implement getClip
    double side = size.width * 0.9;
    double top = (size.height - side) / 2;
    double left = size.width * 0.05;
    Path path = Path();
    path.moveTo(left, top);
    path.lineTo(left + side, top);
    path.lineTo(left + side, top + side);
    path.lineTo(0, top + side);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, 0);
    path.lineTo(0, top + side);
    path.lineTo(left, top + side);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
