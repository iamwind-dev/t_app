import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/features/uploads/domain/uploads_image_repository.dart';

import 'upload_image_result.dart';
import 'upload_video_result.dart';

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

    final uploadPayload = response['upload'];
    final upload = uploadPayload is Map<String, dynamic>
        ? uploadPayload
        : response;

    return UploadImageResult.fromJson({
      ...upload,
      if (upload['type'] == null) 'type': type.value,
    });
  }

  @override
  Future<UploadVideoResult> uploadVideo({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/uploads/video',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType.parse(contentType),
        ),
      }),
      decode: _asMap,
    );

    final uploadPayload = response['upload'];
    final upload = uploadPayload is Map<String, dynamic>
        ? uploadPayload
        : response;

    return UploadVideoResult.fromJson(upload);
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Can\'t decode upload JSON object.');
  }
}
