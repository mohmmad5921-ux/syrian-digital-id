import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:syrian_digital_id/l10n/generated/app_localizations.dart';
import '../models/passport_data.dart';
import '../providers/passport_provider.dart';
import '../utils/constants.dart';
import '../utils/mrz_parser.dart';
import 'nfc_reader_screen.dart';

class MrzScannerScreen extends StatefulWidget {
  const MrzScannerScreen({super.key});

  @override
  State<MrzScannerScreen> createState() => _MrzScannerScreenState();
}

class _MrzScannerScreenState extends State<MrzScannerScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  bool _isCameraReady = false;
  String? _detectedMrz;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      imageFormatGroup: Platform.isIOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.nv21,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    setState(() => _isCameraReady = true);
    _cameraController!.startImageStream(_processImage);
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final recognized = await _textRecognizer.processImage(inputImage);
      final mrzLines = MrzParser.extractMrzLines(recognized.text);

      if (mrzLines != null && mrzLines.length >= 2) {
        final parsed = MrzParser.parseTD3(mrzLines[0], mrzLines[1]);
        if (parsed != null) {
          setState(() => _detectedMrz = '${mrzLines[0]}\n${mrzLines[1]}');

          // Stop the stream and navigate
          await _cameraController?.stopImageStream();

          final passportData = PassportData(
            documentNumber: parsed['documentNumber'],
            fullName: parsed['fullName'],
            nationality: parsed['nationality'],
            dateOfBirth: parsed['dateOfBirth'],
            dateOfExpiry: parsed['dateOfExpiry'],
            sex: parsed['sex'],
            issuingState: parsed['issuingState'],
            mrzLine1: mrzLines[0],
            mrzLine2: mrzLines[1],
          );

          if (mounted) {
            Provider.of<PassportProvider>(context, listen: false)
                .setPassportData(passportData);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NfcReaderScreen()),
            );
          }
        }
      }
    } catch (_) {}
    _isProcessing = false;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final bytes = image.planes.fold<List<int>>(
        <int>[],
        (prev, plane) => prev..addAll(plane.bytes),
      );

      final size = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final inputImageFormat = Platform.isIOS
          ? InputImageFormat.bgra8888
          : InputImageFormat.nv21;

      return InputImage.fromBytes(
        bytes: bytes as dynamic,
        metadata: InputImageMetadata(
          size: size,
          rotation: InputImageRotation.rotation0deg,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraReady)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),

          // Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _PassportOverlayPainter(),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Manual entry button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.keyboard, color: Colors.white),
                        onPressed: () {
                          // TODO: Manual entry
                        },
                      ),
                    ),
                    const Spacer(),
                    // Info button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.info_outline,
                            color: Colors.white),
                        onPressed: () {
                          _showInfoDialog(context, l10n);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom guide
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.scanPassportDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // MRZ hint text
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'P<SYR<<SURNAME<<GIVEN<NAMES<<<<<<<<<<<<\n<<<<<<XX12345678<<<689976464<2467<<<<24',
                      style: TextStyle(fontFamily: "Courier",
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Manual entry button
                  TextButton.icon(
                    icon: const Icon(Icons.keyboard_rounded,
                        color: AppColors.accent),
                    label: Text(
                      l10n.enterManually,
                      style: TextStyle(color: AppColors.accent),
                    ),
                    onPressed: () {
                      // TODO: Manual entry screen
                    },
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.scanPassport),
        content: Text(l10n.renewedPassportNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _PassportOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Calculate passport frame dimensions
    final frameWidth = size.width * 0.85;
    final frameHeight = frameWidth * 0.65; // Passport aspect ratio
    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2 - 40;

    // Draw darkened overlay with cut-out
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, frameWidth, frameHeight),
        const Radius.circular(12),
      ))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Frame border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, frameWidth, frameHeight),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLen = 30.0;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(left + frameWidth - cornerLen, top), Offset(left + frameWidth, top), cornerPaint);
    canvas.drawLine(Offset(left + frameWidth, top), Offset(left + frameWidth, top + cornerLen), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + frameHeight - cornerLen), Offset(left, top + frameHeight), cornerPaint);
    canvas.drawLine(Offset(left, top + frameHeight), Offset(left + cornerLen, top + frameHeight), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(left + frameWidth - cornerLen, top + frameHeight), Offset(left + frameWidth, top + frameHeight), cornerPaint);
    canvas.drawLine(Offset(left + frameWidth, top + frameHeight - cornerLen), Offset(left + frameWidth, top + frameHeight), cornerPaint);

    // MRZ chevrons at bottom of frame
    final chevronPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final mrzTop = top + frameHeight * 0.72;
    final mrzHeight = frameHeight * 0.22;
    for (int row = 0; row < 2; row++) {
      final y = mrzTop + (row * mrzHeight / 2);
      for (double x = left + 10; x < left + frameWidth - 10; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y + 4), chevronPaint);
        canvas.drawLine(Offset(x + 4, y + 4), Offset(x + 8, y), chevronPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
