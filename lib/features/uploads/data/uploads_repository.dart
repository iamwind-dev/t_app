import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/features/uploads/domain/uploads_image_repository.dart';

import 'upload_image_result.dart';

class UploadsRepository implements UploadsImageRepository {
  const UploadsRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<UploadImageResult> uploadImage({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
    required UploadImageType type,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/uploads/image',
      data: FormData.fromMap({
        'type': type.value,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType.parse(contentType),
        ),
      }),
      decode: _asMap,
    );

    final upload = response['upload'];
    if (upload is Map<String, dynamic>) {
      return UploadImageResult.fromJson(upload);
    }

    throw const FormatException('Upload response is missing upload.');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
