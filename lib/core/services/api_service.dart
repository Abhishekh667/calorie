import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Map<String, dynamic>> searchFoodOpenFoodFacts(String query) async {
    try {
      final response = await _dio.get(
        'https://world.openfoodfacts.org/cgi/search.pl',
        queryParameters: {
          'search_terms': query,
          'json': true,
          'page_size': 20,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString(), 'products': []};
    }
  }

  Future<Map<String, dynamic>> getFoodByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        'https://world.openfoodfacts.org/api/v2/product/$barcode',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
