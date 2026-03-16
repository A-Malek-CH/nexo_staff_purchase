import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/staff_member_model.dart';

final staffServiceProvider = Provider<StaffService>((ref) {
  return StaffService(ref.read(dioProvider));
});

class StaffService {
  final Dio _dio;

  StaffService(this._dio);

  Future<List<StaffMember>> getStaff({bool? isActive, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['isActive'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        AppConstants.adminStaffsEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data =
          response.data['staffs'] ?? response.data['staff'] ?? response.data;
      return data.map((json) => StaffMember.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StaffMember> getStaffById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.adminStaffsEndpoint}/$id');
      final data = response.data['staff'] ?? response.data;
      return StaffMember.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StaffMember> createStaff(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(AppConstants.adminStaffsEndpoint, data: data);
      final responseData = response.data['staff'] ?? response.data;
      return StaffMember.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StaffMember> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('${AppConstants.adminStaffsEndpoint}/$id', data: data);
      final responseData = response.data['staff'] ?? response.data;
      return StaffMember.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteStaff(String id) async {
    try {
      await _dio.delete('${AppConstants.adminStaffsEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StaffMember> uploadAvatar(String id, File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      final response = await _dio.post(
        '${AppConstants.adminStaffsEndpoint}/$id/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final responseData = response.data['staff'] ?? response.data;
      return StaffMember.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'An error occurred: ${error.response!.statusMessage}';
    }
    return 'An unexpected error occurred.';
  }
}
