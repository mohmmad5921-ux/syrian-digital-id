import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String language,
  }) async {
    final response = await _dio.post(ApiConfig.register, data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'language': language,
    });
    final token = response.data['token'];
    await _storage.write(key: _tokenKey, value: token);
    return User.fromJson({...response.data['user'], 'token': token});
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });
    final token = response.data['token'];
    await _storage.write(key: _tokenKey, value: token);
    return User.fromJson({...response.data['user'], 'token': token});
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } catch (_) {}
    await _storage.delete(key: _tokenKey);
  }

  Future<Map<String, dynamic>> submitDigitalId({
    required Map<String, dynamic> passportData,
    Uint8List? faceImage,
  }) async {
    final formData = FormData.fromMap({
      ...passportData,
      if (faceImage != null)
        'photo': MultipartFile.fromBytes(faceImage, filename: 'face.jpg'),
    });
    final response = await _dio.post(ApiConfig.digitalId, data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> getDigitalId() async {
    final response = await _dio.get(ApiConfig.digitalId);
    return response.data;
  }

  Future<Uint8List> downloadWalletPass() async {
    final response = await _dio.get(
      ApiConfig.walletPass,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }
}
