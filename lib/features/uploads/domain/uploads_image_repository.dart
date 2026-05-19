import 'dart:typed_data';

import '../data/upload_image_result.dart';
import '../data/upload_video_result.dart';

abstract interface class UploadsImageRepository {
  Future<UploadImageResult> uploadImage({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
    required UploadImageType type,
  });

  Future<UploadVideoResult> uploadVideo({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  });
}
