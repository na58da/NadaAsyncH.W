import 'package:dio/dio.dart';
import 'package:nada_async_app/Config/constants.dart';
import 'package:nada_async_app/Controllers/NadaLoginController.dart';
import 'package:get/get.dart';

class DioClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseURL, // Replace with your API base URL
    connectTimeout: Duration(seconds: 5000),
    receiveTimeout: Duration(seconds: 5000),
  ));

  DioClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print(options);
        // Add access token to headers
        final token = Get.find<NadaLoginController>().accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        //print("aaaaaaaaaaaaaaaaaaaaaaaaa${e}");

        // Handle 401 errors (e.g., token expiration)
        if (e.response?.statusCode == 401) {
          Get.find<NadaLoginController>().refreshToken();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
