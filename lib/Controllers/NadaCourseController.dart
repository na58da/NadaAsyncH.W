import 'dart:io';
import 'package:get/get.dart';

import '../Helpers/NadaSQliteDbHelper.dart';
import '../Models/NadaCourseModel.dart';

class NadaCourseController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  var courseList = <CourseModel>[].obs;
  CourseModel? courseDetail;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getCourseList();
  }

  Future<void> getCourseList() async {
    try {
      isLoading(true);
      final localCourses = await _databaseHelper.getCourses();
      courseList.value = localCourses;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch courses: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> getCourseDetails(int courseId) async {
    try {
      isLoading(true);
      final localCourses = await _databaseHelper.getCourses();
      courseDetail = localCourses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch course details: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void addCourse({
    required String title,
    required String overview,
    required String subject,
    File? photo,
  }) async {
    try {
      isLoading(true);
      final newCourse = CourseModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        subject: subject,
        overview: overview,
        photo: photo?.path ?? '',
        createdAt: DateTime.now().toIso8601String(),
      );
      await _databaseHelper.insertCourse(newCourse);
      Get.snackbar('Success', 'Course added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add course: $e');
    } finally {
      isLoading(false);
      getCourseList();
    }
  }

  void updateCourse(
    int courseId, {
    required String title,
    required String overview,
    required String subject,
    File? photo,
  }) async {
    try {
      isLoading(true);
      final updatedCourse = CourseModel(
        id: courseId,
        title: title,
        subject: subject,
        overview: overview,
        photo: photo?.path ?? '',
        createdAt: DateTime.now().toIso8601String(),
      );
      await _databaseHelper.updateCourse(updatedCourse);
      Get.snackbar('Success', 'Course updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update course: $e');
    } finally {
      isLoading(false);
      getCourseList();
    }
  }

  void deleteCourse(int courseId) async {
    try {
      isLoading(true);
      await _databaseHelper.deleteCourse(courseId);
      Get.snackbar('Success', 'Course deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete course: $e');
    } finally {
      isLoading(false);
      getCourseList();
    }
  }
}
