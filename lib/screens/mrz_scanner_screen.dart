import 'package:flutter/material.dart';
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
  final _docNumberController = TextEditingController();
  final _dobController = TextEditingController();
  final _expiryController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _docNumberController.dispose();
    _dobController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _proceed() {
    final docNumber = _docNumberController.text.trim();
    final dob = _dobController.text.trim();
    final expiry = _expiryController.text.trim();

    if (docNumber.isEmpty || dob.isEmpty || expiry.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }

    // Validate date format (YYMMDD)
    if (!RegExp(r'^\d{6}$').hasMatch(dob) || !RegExp(r'^\d{6}$').hasMatch(expiry)) {
      setState(() => _error = 'Date format: YYMMDD (e.g. 900115)');
      return;
    }

    final passportData = PassportData(
      documentNumber: docNumber,
      dateOfBirth: dob,
      dateOfExpiry: expiry,
    );

    Provider.of<PassportProvider>(context, listen: false)
        .setPassportData(passportData);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NfcReaderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      l10n.scanPassport,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Passport icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Instructions
                        Text(
                          isArabic
                              ? 'أدخل بيانات الجواز من سطور MRZ\nالموجودة أسفل صفحة الصورة'
                              : 'Enter passport data from MRZ lines\nat the bottom of the photo page',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // MRZ hint
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'P<SYR<<SURNAME<<GIVEN<NAMES<<<<<<\n<<<<<<XX1234567<<<689976464<2467<<<',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Document Number
                        Text(
                          l10n.documentNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _docNumberController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: isArabic ? 'مثال: N12345678' : 'e.g. N12345678',
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date of Birth
                        Text(
                          l10n.dateOfBirth,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dobController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'YYMMDD (${isArabic ? "مثال" : "e.g."} 900115)',
                            prefixIcon: const Icon(Icons.cake_outlined),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date of Expiry
                        Text(
                          l10n.dateOfExpiry,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'YYMMDD (${isArabic ? "مثال" : "e.g."} 301231)',
                            prefixIcon: const Icon(Icons.event_outlined),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Error message
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Next button
                        ElevatedButton.icon(
                          onPressed: _proceed,
                          icon: const Icon(Icons.nfc, color: Colors.white),
                          label: Text(
                            isArabic ? 'التالي: قراءة شريحة الجواز' : 'Next: Read Passport Chip',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
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
        ),
      ),
    );
  }
}
