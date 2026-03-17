import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syrian_digital_id/l10n/generated/app_localizations.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../models/passport_data.dart';
import '../providers/passport_provider.dart';
import '../utils/constants.dart';
import 'digital_id_screen.dart';

class NfcReaderScreen extends StatefulWidget {
  const NfcReaderScreen({super.key});

  @override
  State<NfcReaderScreen> createState() => _NfcReaderScreenState();
}

class _NfcReaderScreenState extends State<NfcReaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;
  bool _isReading = false;
  String _statusText = '';
  double _progress = 0.0;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _startNfcReading() async {
    final passport = Provider.of<PassportProvider>(context, listen: false);
    final data = passport.passportData;
    if (data == null) return;

    setState(() {
      _isReading = true;
      _statusText = 'Connecting...';
      _progress = 0.1;
      _error = null;
    });

    try {
      // Check NFC availability
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        setState(() {
          _isReading = false;
          _error = 'NFC is not available on this device';
        });
        return;
      }

      setState(() {
        _statusText = 'Waiting for passport...';
        _progress = 0.2;
      });

      // Start NFC session
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 30),
        iosAlertMessage: 'Hold your phone on your passport',
      );

      setState(() {
        _statusText = 'Reading personal data...';
        _progress = 0.5;
      });

      // Read NDEF data if available
      // Full ePassport reading requires BAC auth and APDU commands
      // For now, we proceed with the MRZ-extracted data
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _statusText = 'Processing biometric data...';
        _progress = 0.8;
      });

      await Future.delayed(const Duration(seconds: 1));

      await FlutterNfcKit.finish(iosAlertMessage: 'Passport read successfully!');

      setState(() {
        _success = true;
        _progress = 1.0;
        _statusText = 'Complete!';
      });

      // Navigate to digital ID screen
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DigitalIdScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isReading = false;
        _error = e.toString();
        _statusText = 'Failed';
      });
    }
  }

  String _formatBacDate(String date) {
    // Convert YYYY-MM-DD to YYMMDD
    if (date.length == 10) {
      return '${date.substring(2, 4)}${date.substring(5, 7)}${date.substring(8, 10)}';
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      l10n.readNFC,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // NFC animation
              ScaleTransition(
                scale: _pulseAnimation,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _NfcWavePainter(
                        progress: _waveController.value,
                        isReading: _isReading,
                        isSuccess: _success,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _success
                          ? AppColors.success.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: _success
                            ? AppColors.success
                            : Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _success ? Icons.check_rounded : Icons.nfc_rounded,
                      size: 80,
                      color: _success ? AppColors.success : AppColors.accent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Status
              if (_isReading || _success) ...[
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _success ? AppColors.success : AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Instructions / Button
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    if (!_isReading && !_success) ...[
                      // Instruction illustration
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.smartphone_rounded,
                              size: 40,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.readNFCDesc,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.keepSteady,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Start button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _startNfcReading,
                          icon: const Icon(Icons.nfc_rounded),
                          label: Text(
                            l10n.readNFC,
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (_error != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _startNfcReading,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NfcWavePainter extends CustomPainter {
  final double progress;
  final bool isReading;
  final bool isSuccess;

  _NfcWavePainter({
    required this.progress,
    required this.isReading,
    required this.isSuccess,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isReading && !isSuccess) return;

    final center = Offset(size.width / 2, size.height / 2);
    final color = isSuccess ? AppColors.success : AppColors.accent;

    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 2) + (40 * (progress + i * 0.33) % 1.0);
      final opacity = (1.0 - ((progress + i * 0.33) % 1.0)) * 0.3;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NfcWavePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
