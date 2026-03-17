import 'package:flutter/material.dart';
import '../models/passport_data.dart';

class PassportProvider extends ChangeNotifier {
  PassportData? _passportData;
  bool _isScanning = false;
  bool _isReadingNfc = false;
  double _nfcProgress = 0.0;
  String _nfcStatus = '';

  PassportData? get passportData => _passportData;
  bool get isScanning => _isScanning;
  bool get isReadingNfc => _isReadingNfc;
  double get nfcProgress => _nfcProgress;
  String get nfcStatus => _nfcStatus;
  bool get hasPassportData => _passportData != null;

  void setScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  void setReadingNfc(bool value) {
    _isReadingNfc = value;
    notifyListeners();
  }

  void updateNfcProgress(double progress, String status) {
    _nfcProgress = progress;
    _nfcStatus = status;
    notifyListeners();
  }

  void setPassportData(PassportData data) {
    _passportData = data;
    notifyListeners();
  }

  void clearData() {
    _passportData = null;
    _isScanning = false;
    _isReadingNfc = false;
    _nfcProgress = 0.0;
    _nfcStatus = '';
    notifyListeners();
  }
}
