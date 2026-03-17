import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syrian_digital_id/l10n/generated/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/passport_provider.dart';
import '../utils/constants.dart';

class DigitalIdScreen extends StatefulWidget {
  const DigitalIdScreen({super.key});

  @override
  State<DigitalIdScreen> createState() => _DigitalIdScreenState();
}

class _DigitalIdScreenState extends State<DigitalIdScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final passport = Provider.of<PassportProvider>(context);
    final data = passport.passportData;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    l10n.digitalId,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Verified badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: AppColors.success, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            l10n.verifiedId,
                            style: GoogleFonts.inter(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ID Card (Front)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: GestureDetector(
                        onTap: () => setState(() => _showBack = !_showBack),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _showBack
                              ? _buildCardBack(l10n, data)
                              : _buildCardFront(l10n, data),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Tap to flip card',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Wallet buttons
                    _buildWalletButton(
                      icon: Icons.wallet_rounded,
                      label: l10n.addToAppleWallet,
                      color: Colors.black,
                      onTap: () {
                        // TODO: Apple Wallet integration
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildWalletButton(
                      icon: Icons.account_balance_wallet_rounded,
                      label: l10n.addToGoogleWallet,
                      color: const Color(0xFF4285F4),
                      onTap: () {
                        // TODO: Google Wallet integration
                      },
                    ),

                    const SizedBox(height: 32),

                    // Details section
                    _buildDetailSection(l10n, data),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(AppLocalizations l10n, passportData) {
    return Container(
      key: const ValueKey('front'),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardGradientStart,
            AppColors.cardGradientMiddle,
            AppColors.cardGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Photo placeholder
                    Container(
                      width: 60,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: passportData?.faceImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                passportData!.faceImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white.withOpacity(0.5),
                              size: 32,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الهوية الرقمية السورية',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            passportData?.fullName ?? 'FULL NAME',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            passportData?.nationality ?? 'SYR',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardField(
                      'DOC NO.',
                      passportData?.documentNumber ?? '---',
                    ),
                    _buildCardField(
                      'DOB',
                      passportData?.dateOfBirth ?? '---',
                    ),
                    _buildCardField(
                      'EXPIRY',
                      passportData?.dateOfExpiry ?? '---',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Shield icon
          Positioned(
            top: 16,
            right: 16,
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(AppLocalizations l10n, passportData) {
    return Container(
      key: const ValueKey('back'),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.verificationCode,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            QrImageView(
              data: 'https://digitalidsyria.com/verify/SYR-000001',
              version: QrVersions.auto,
              size: 120,
              eyeStyle: const QrEyeStyle(
                color: AppColors.primary,
                eyeShape: QrEyeShape.square,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                color: AppColors.primary,
                dataModuleShape: QrDataModuleShape.square,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SYR-000001',
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildDetailSection(AppLocalizations l10n, passportData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(l10n.name, passportData?.fullName ?? '---'),
          const Divider(),
          _buildDetailRow(
              l10n.documentNumber, passportData?.documentNumber ?? '---'),
          const Divider(),
          _buildDetailRow(l10n.nationality, passportData?.nationality ?? '---'),
          const Divider(),
          _buildDetailRow(l10n.dateOfBirth, passportData?.dateOfBirth ?? '---'),
          const Divider(),
          _buildDetailRow(
              l10n.dateOfExpiry, passportData?.dateOfExpiry ?? '---'),
          const Divider(),
          _buildDetailRow(
            l10n.sex,
            passportData?.sex == 'M' ? l10n.male : l10n.female,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
