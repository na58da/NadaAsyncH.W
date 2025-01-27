// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:nada_async_app/Config/constants.dart';
import 'package:nada_async_app/Views/NadaLoginPage.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nada_async_app/Views/NadaHomePage.dart';
import 'dart:convert';
import '../services/local_database_service.dart';
import '../APIServices/DioClient.dart';
import '../Helpers/NadaTokenStorage.dart';
import '../Models/NadaLoginResponseModel.dart';

class NadaLoginController extends GetxController {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  String? accessToken;
  String? refreshedToken;
  final DioClient _dioClient = DioClient();

  @override
  void onInit() {
    super.onInit();
    initializeTokens();
  }

  Future<void> initializeTokens() async {
    accessToken = await TokenStorage.getAccessToken();
    refreshedToken = await TokenStorage.getRefreshToken();
    if (accessToken != null) {
      Get.offAll(() => NadaHomePage());
      syncPendingRequests();
    }
  }

  Future<void> login(String email, String password) async {
    const url = baseAPIURLV1 + loginAPI; // Replace with your API login endpoint

    try {
      if (!await isConnected()) {
        // Save request locally if no connection
        await _dbService.insertPendingRequest(
          'login',
          jsonEncode({'email': email, 'password': password}),
        );
        Get.snackbar("Offline", "No internet connection. Data saved locally.",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final response = await _dioClient.dio.post(
        url,
        options: Options(contentType: "application/json"),
        data: {
          "email": email,
          "password": password,
        },
      );
      if (response.statusCode == 200) {
        final loginResponse = LoginResponseModel.fromJson(response.data);
        accessToken = loginResponse.accessToken;
        refreshedToken = loginResponse.refreshToken;

        // Save tokens to storage
        await TokenStorage.saveTokens(accessToken!, refreshedToken!);

        Get.snackbar("Success", "Login successful",
            snackPosition: SnackPosition.BOTTOM);
        Get.offAll(() => NadaHomePage());
      } else {
        Get.snackbar("Error", "Invalid credentials",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to login",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> syncPendingRequests() async {
    try {
      if (!await isConnected()) {
        return;
      }

      final pendingRequests = await _dbService.getPendingRequests();
      for (var request in pendingRequests) {
        final endpoint = request['endpoint'];
        final payload = jsonDecode(request['payload']);

        if (endpoint == 'login') {
          final response = await _dioClient.dio.post(
            baseAPIURLV1 + loginAPI,
            options: Options(contentType: "application/json"),
            data: payload,
          );

          if (response.statusCode == 200) {
            // If data is successfully uploaded, delete from local database
            await _dbService.deletePendingRequest(request['id']);
          }
        }
      }
      Get.snackbar("Sync", "Pending requests synced successfully.",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to sync data: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> refreshToken() async {
    const url =
        baseAPIURLV1 + refreshTokeAPI; // Replace with your refresh endpoint

    try {
      final response = await _dioClient.dio.post(
        url,
        data: {"refresh": refreshedToken},
      );

      if (response.statusCode == 200) {
        accessToken = response.data['access'];

        // Update stored access token
        await TokenStorage.saveTokens(accessToken!, refreshedToken!);
      } else {
        Get.snackbar("Error", "Failed to refresh token",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to refresh token",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Observable for password visibility
  var isPasswordVisible = false.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> logout() async {
    // Clear tokens from memory and storage
    accessToken = null;
    refreshedToken = null;
    await TokenStorage.clearTokens();
    Get.snackbar("Success", "Logged out successfully",
        snackPosition: SnackPosition.BOTTOM);
    Get.offAll(() => NadaLoginPage());
    Get.put(NadaLoginController());
  }

  // Helper method to check if there is an internet connection
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return connectivityResult != ConnectivityResult.none;
  }
}
