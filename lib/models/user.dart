class User {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? email;
  final String? phone;
  final String language;
  final String? token;
  final DigitalIdInfo? digitalId;

  User({
    this.id,
    this.name,
    this.nameAr,
    this.email,
    this.phone,
    this.language = 'ar',
    this.token,
    this.digitalId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      nameAr: json['name_ar'],
      email: json['email'],
      phone: json['phone'],
      language: json['language'] ?? 'ar',
      token: json['token'],
      digitalId: json['digital_id'] != null
          ? DigitalIdInfo.fromJson(json['digital_id'])
          : null,
    );
  }
}

class DigitalIdInfo {
  final int id;
  final String serialNumber;
  final String status;
  final String? photoUrl;

  DigitalIdInfo({
    required this.id,
    required this.serialNumber,
    required this.status,
    this.photoUrl,
  });

  factory DigitalIdInfo.fromJson(Map<String, dynamic> json) {
    return DigitalIdInfo(
      id: json['id'],
      serialNumber: json['serial_number'],
      status: json['status'],
      photoUrl: json['photo_url'],
    );
  }

  bool get isVerified => status == 'verified';
}
