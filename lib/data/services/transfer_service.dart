import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/transfer_model.dart';

final transferServiceProvider = Provider<TransferService>((ref) {
  return TransferService(ref.read(dioProvider));
});

class TransferService {
  final Dio _dio;

  TransferService(this._dio);

  Future<List<Transfer>> getTransfers({
    String? status,
    int page = 1,
    int limit = AppConstants.pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        AppConstants.myTransfersEndpoint,
        queryParameters: queryParams,
      );

      final transfers = response.data['transfers'] ?? [];
      return (transfers as List<dynamic>)
          .map((json) => Transfer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Transfer> getTransferById(String id) async {
    try {
      final response =
          await _dio.get('${AppConstants.transfersEndpoint}/$id');
      final json = response.data['transfer'];
      if (json == null) throw 'Transfer not found in response';
      return Transfer.fromJson(json as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Transfer> updateTransferStatus(String id, String status) async {
    try {
      final response = await _dio.put(
        '${AppConstants.transfersEndpoint}/$id',
        data: {'status': status},
      );
      final json = response.data['transfer'];
      if (json == null) throw 'Transfer not found in response';
      return Transfer.fromJson(json as Map<String, dynamic>);
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
