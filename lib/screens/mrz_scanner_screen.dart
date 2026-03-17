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
  TextRecognizer? _textRecognizer;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _mrzFound = false;
  String? _cameraError;
  String _statusText = '';

  // Manual entry controllers
  final _docNumberController = TextEditingController();
  final _dobController = TextEditingController();
  final _expiryController = TextEditingController();
  String? _formError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = 'No camera available');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.nv21,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      _textRecognizer = TextRecognizer();
      setState(() => _isCameraReady = true);

      // Start scanning after brief delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _cameraController != null && _cameraController!.value.isInitialized) {
        _cameraController!.startImageStream(_processImage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError = '$e');
      }
    }
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing || _mrzFound || _textRecognizer == null) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final recognized = await _textRecognizer!.processImage(inputImage);
      final mrzLines = MrzParser.extractMrzLines(recognized.text);

      if (mrzLines != null && mrzLines.length >= 2) {
        final parsed = MrzParser.parseTD3(mrzLines[0], mrzLines[1]);
        if (parsed != null) {
          _mrzFound = true;
          try { await _cameraController?.stopImageStream(); } catch (_) {}

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
          return;
        }
      }

      // Update status
      if (mounted && recognized.text.isNotEmpty) {
        setState(() => _statusText = 'Scanning...');
      }
    } catch (_) {}
    _isProcessing = false;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final bytes = image.planes.fold<List<int>>(
        <int>[], (prev, plane) => prev..addAll(plane.bytes));

      return InputImage.fromBytes(
        bytes: bytes as dynamic,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void _proceedManual() {
    final doc = _docNumberController.text.trim();
    final dob = _dobController.text.trim();
    final exp = _expiryController.text.trim();

    if (doc.isEmpty || dob.isEmpty || exp.isEmpty) {
      setState(() => _formError = 'Please fill all fields');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(dob) || !RegExp(r'^\d{6}$').hasMatch(exp)) {
      setState(() => _formError = 'Date format: YYMMDD (e.g. 900115)');
      return;
    }

    Provider.of<PassportProvider>(context, listen: false).setPassportData(
      PassportData(documentNumber: doc, dateOfBirth: dob, dateOfExpiry: exp),
    );
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const NfcReaderScreen()));
  }

  @override
  void dispose() {
    try { _cameraController?.dispose(); } catch (_) {}
    try { _textRecognizer?.close(); } catch (_) {}
    _docNumberController.dispose();
    _dobController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Camera preview (top)
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                if (_isCameraReady && _cameraController != null)
                  Positioned.fill(child: CameraPreview(_cameraController!))
                else if (_cameraError != null)
                  Center(child: Text(_cameraError!,
                      style: const TextStyle(color: Colors.red)))
                else
                  const Center(child: CircularProgressIndicator(color: Colors.white)),

                if (_isCameraReady)
                  Positioned.fill(child: CustomPaint(painter: _PassportOverlayPainter())),

                // Back button
                Positioned(
                  top: 0, left: 0,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Scanning status
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_statusText.isNotEmpty) ...[
                          const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.accent),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _isCameraReady
                              ? (isArabic ? 'وجّه الكاميرا على سطور MRZ' : 'Point camera at MRZ lines')
                              : (isArabic ? 'جاري تشغيل الكاميرا...' : 'Starting camera...'),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Manual entry (bottom)
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isArabic ? 'أو أدخل يدوياً' : 'Or enter manually',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    _buildField(l10n.documentNumber, _docNumberController,
                        isArabic ? 'مثال: N12345678' : 'e.g. N12345678',
                        Icons.badge_outlined, TextInputType.text),
                    const SizedBox(height: 12),
                    _buildField(l10n.dateOfBirth, _dobController,
                        'YYMMDD', Icons.cake_outlined, TextInputType.number, maxLen: 6),
                    const SizedBox(height: 12),
                    _buildField(l10n.dateOfExpiry, _expiryController,
                        'YYMMDD', Icons.event_outlined, TextInputType.number, maxLen: 6),

                    if (_formError != null) ...[
                      const SizedBox(height: 8),
                      Text(_formError!, style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _proceedManual,
                      icon: const Icon(Icons.nfc, color: Colors.white),
                      label: Text(
                        isArabic ? 'التالي: قراءة شريحة الجواز' : 'Next: Read Passport Chip',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      IconData icon, TextInputType type, {int? maxLen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLength: maxLen,
          textCapitalization: type == TextInputType.text
              ? TextCapitalization.characters : TextCapitalization.none,
          decoration: InputDecoration(
            hintText: hint, prefixIcon: Icon(icon),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _PassportOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final fw = size.width * 0.85, fh = fw * 0.65;
    final l = (size.width - fw) / 2, t = (size.height - fh) / 2;

    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(l, t, fw, fh), const Radius.circular(12)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(l, t, fw, fh), const Radius.circular(12)),
      Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final cp = Paint()
      ..color = Colors.white ..style = PaintingStyle.stroke
      ..strokeWidth = 4 ..strokeCap = StrokeCap.round;
    const c = 25.0;
    canvas.drawLine(Offset(l, t + c), Offset(l, t), cp);
    canvas.drawLine(Offset(l, t), Offset(l + c, t), cp);
    canvas.drawLine(Offset(l + fw - c, t), Offset(l + fw, t), cp);
    canvas.drawLine(Offset(l + fw, t), Offset(l + fw, t + c), cp);
    canvas.drawLine(Offset(l, t + fh - c), Offset(l, t + fh), cp);
    canvas.drawLine(Offset(l, t + fh), Offset(l + c, t + fh), cp);
    canvas.drawLine(Offset(l + fw - c, t + fh), Offset(l + fw, t + fh), cp);
    canvas.drawLine(Offset(l + fw, t + fh - c), Offset(l + fw, t + fh), cp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
