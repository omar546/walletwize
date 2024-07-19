import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;
  static init() {
    dio = Dio(
      BaseOptions(
          baseUrl: 'http://16.170.98.54/',
          receiveDataWhenStatusError: true,
          headers: {
            'Content-Type': 'application/json',

          },
      ),
    );
    dio.options.followRedirects = true;
    dio.options.maxRedirects = 5;
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    dio.options.headers= {
    };
    return await dio.get(
      url,
      queryParameters: query,
    );
  }


  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    dio.options.headers={
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return dio.post(url, queryParameters: query, data: data);
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic> data,
    String lang = 'en',
    String? token,
  }) async {
    dio.options.headers={
      'lang': lang,
      'Authorization': token,
    };
    return dio.put(url, queryParameters: query, data: data);
  }
}

