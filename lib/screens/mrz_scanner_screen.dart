import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:syrian_digital_id/l10n/generated/app_localizations.dart';
import '../models/passport_data.dart';
import '../providers/passport_provider.dart';
import '../utils/constants.dart';
import 'nfc_reader_screen.dart';

class MrzScannerScreen extends StatefulWidget {
  const MrzScannerScreen({super.key});

  @override
  State<MrzScannerScreen> createState() => _MrzScannerScreenState();
}

class _MrzScannerScreenState extends State<MrzScannerScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _showManualEntry = false;
  String? _cameraError;

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
        setState(() {
          _cameraError = 'No camera available';
          _showManualEntry = true;
        });
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = 'Camera: $e';
          _showManualEntry = true;
        });
      }
    }
  }

  void _proceed() {
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
      context,
      MaterialPageRoute(builder: (_) => const NfcReaderScreen()),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
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
          // Camera preview section (top half)
          Expanded(
            flex: _showManualEntry ? 0 : 2,
            child: _showManualEntry
                ? const SizedBox.shrink()
                : Stack(
                    children: [
                      if (_isCameraReady && _cameraController != null)
                        Positioned.fill(
                          child: CameraPreview(_cameraController!),
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),

                      // Passport frame overlay
                      if (_isCameraReady)
                        Positioned.fill(
                          child: CustomPaint(painter: _PassportOverlayPainter()),
                        ),

                      // Back button
                      Positioned(
                        top: 0,
                        left: 0,
                        child: SafeArea(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      // Guide text
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.scanPassportDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Manual entry section (bottom half)
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
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      isArabic ? 'أدخل بيانات الجواز' : 'Enter passport data',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? 'من سطور MRZ أسفل صفحة الصورة'
                          : 'From MRZ lines at bottom of photo page',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Document Number
                    _buildField(l10n.documentNumber, _docNumberController,
                        isArabic ? 'مثال: N12345678' : 'e.g. N12345678',
                        Icons.badge_outlined, TextInputType.text),
                    const SizedBox(height: 14),

                    // Date of Birth
                    _buildField(l10n.dateOfBirth, _dobController,
                        'YYMMDD (${isArabic ? "مثال" : "e.g."} 900115)',
                        Icons.cake_outlined, TextInputType.number, maxLen: 6),
                    const SizedBox(height: 14),

                    // Date of Expiry
                    _buildField(l10n.dateOfExpiry, _expiryController,
                        'YYMMDD (${isArabic ? "مثال" : "e.g."} 301231)',
                        Icons.event_outlined, TextInputType.number, maxLen: 6),

                    if (_formError != null) ...[
                      const SizedBox(height: 12),
                      Text(_formError!, style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 20),

                    // Next button
                    ElevatedButton.icon(
                      onPressed: _proceed,
                      icon: const Icon(Icons.nfc, color: Colors.white),
                      label: Text(
                        isArabic ? 'التالي: قراءة شريحة الجواز' : 'Next: Read Passport Chip',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLength: maxLen,
          textCapitalization: type == TextInputType.text
              ? TextCapitalization.characters
              : TextCapitalization.none,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

    final fw = size.width * 0.85;
    final fh = fw * 0.65;
    final l = (size.width - fw) / 2;
    final t = (size.height - fh) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(l, t, fw, fh), const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    final bp = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(l, t, fw, fh), const Radius.circular(12)), bp);

    final cp = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
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
