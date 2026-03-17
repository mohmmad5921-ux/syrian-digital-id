class PassportData {
  final String? documentNumber;
  final String? fullName;
  final String? fullNameAr;
  final String? nationality;
  final String? dateOfBirth;
  final String? dateOfExpiry;
  final String? sex;
  final String? issuingState;
  final String? mrzLine1;
  final String? mrzLine2;
  final List<int>? faceImage;

  PassportData({
    this.documentNumber,
    this.fullName,
    this.fullNameAr,
    this.nationality,
    this.dateOfBirth,
    this.dateOfExpiry,
    this.sex,
    this.issuingState,
    this.mrzLine1,
    this.mrzLine2,
    this.faceImage,
  });

  factory PassportData.fromJson(Map<String, dynamic> json) {
    return PassportData(
      documentNumber: json['document_number'],
      fullName: json['full_name'],
      fullNameAr: json['full_name_ar'],
      nationality: json['nationality'],
      dateOfBirth: json['date_of_birth'],
      dateOfExpiry: json['date_of_expiry'],
      sex: json['sex'],
      issuingState: json['issuing_state'],
      mrzLine1: json['mrz_line1'],
      mrzLine2: json['mrz_line2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_number': documentNumber,
      'full_name': fullName,
      'full_name_ar': fullNameAr,
      'nationality': nationality,
      'date_of_birth': dateOfBirth,
      'date_of_expiry': dateOfExpiry,
      'sex': sex,
      'issuing_state': issuingState,
      'mrz_line1': mrzLine1,
      'mrz_line2': mrzLine2,
    };
  }

  String get displaySex => sex == 'M' ? 'Male' : 'Female';
  String get displaySexAr => sex == 'M' ? 'ذكر' : 'أنثى';
}
