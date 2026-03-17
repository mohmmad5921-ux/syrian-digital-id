class MrzParser {
  /// Parse two lines of MRZ text (TD3 format for passports - 44 chars per line)
  static Map<String, String>? parseTD3(String line1, String line2) {
    if (line1.length != 44 || line2.length != 44) return null;

    final documentType = line1.substring(0, 2).replaceAll('<', '');
    final issuingState = line1.substring(2, 5).replaceAll('<', '');
    
    // Name section: everything after position 5
    final nameSection = line1.substring(5);
    final nameParts = nameSection.split('<<');
    final surname = nameParts[0].replaceAll('<', ' ').trim();
    final givenNames = nameParts.length > 1
        ? nameParts[1].replaceAll('<', ' ').trim()
        : '';

    // Line 2
    final documentNumber = line2.substring(0, 9).replaceAll('<', '');
    final nationality = line2.substring(10, 13).replaceAll('<', '');
    final dob = line2.substring(13, 19); // YYMMDD
    final sex = line2.substring(20, 21);
    final expiry = line2.substring(21, 27); // YYMMDD

    return {
      'documentType': documentType,
      'issuingState': issuingState,
      'surname': surname,
      'givenNames': givenNames,
      'fullName': '$givenNames $surname'.trim(),
      'documentNumber': documentNumber,
      'nationality': nationality,
      'dateOfBirth': _formatDate(dob),
      'sex': sex,
      'dateOfExpiry': _formatDate(expiry),
    };
  }

  /// Parse TD1 format (ID cards - 30 chars per line, 3 lines)
  static Map<String, String>? parseTD1(String line1, String line2, String line3) {
    if (line1.length != 30 || line2.length != 30 || line3.length != 30) return null;

    final documentType = line1.substring(0, 2).replaceAll('<', '');
    final issuingState = line1.substring(2, 5).replaceAll('<', '');
    final documentNumber = line1.substring(5, 14).replaceAll('<', '');

    final dob = line2.substring(0, 6);
    final sex = line2.substring(7, 8);
    final expiry = line2.substring(8, 14);
    final nationality = line2.substring(15, 18).replaceAll('<', '');

    final nameSection = line3;
    final nameParts = nameSection.split('<<');
    final surname = nameParts[0].replaceAll('<', ' ').trim();
    final givenNames = nameParts.length > 1
        ? nameParts[1].replaceAll('<', ' ').trim()
        : '';

    return {
      'documentType': documentType,
      'issuingState': issuingState,
      'surname': surname,
      'givenNames': givenNames,
      'fullName': '$givenNames $surname'.trim(),
      'documentNumber': documentNumber,
      'nationality': nationality,
      'dateOfBirth': _formatDate(dob),
      'sex': sex,
      'dateOfExpiry': _formatDate(expiry),
    };
  }

  /// Clean recognized text for MRZ parsing
  static String cleanMrzText(String text) {
    return text
        .replaceAll('«', '<')
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll(' ', '')
        .toUpperCase();
  }

  /// Try to extract MRZ lines from raw OCR text
  static List<String>? extractMrzLines(String rawText) {
    final lines = rawText.split('\n').map((l) => cleanMrzText(l)).toList();
    
    // Filter lines that look like MRZ (contain << and have correct lengths)
    final mrzLines = lines.where((line) => 
      line.contains('<<') && (line.length == 44 || line.length == 30)
    ).toList();

    if (mrzLines.length >= 2) {
      // Take the last 2 (or 3 for TD1) lines
      if (mrzLines.any((l) => l.length == 44)) {
        // TD3 passport
        final td3Lines = mrzLines.where((l) => l.length == 44).toList();
        if (td3Lines.length >= 2) {
          return [td3Lines[td3Lines.length - 2], td3Lines.last];
        }
      }
    }
    return null;
  }

  /// Convert YYMMDD to readable date
  static String _formatDate(String yymmdd) {
    if (yymmdd.length != 6) return yymmdd;
    final yy = int.tryParse(yymmdd.substring(0, 2)) ?? 0;
    final mm = yymmdd.substring(2, 4);
    final dd = yymmdd.substring(4, 6);
    final year = yy > 50 ? 1900 + yy : 2000 + yy;
    return '$year-$mm-$dd';
  }
}
