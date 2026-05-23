import 'dart:convert';

import 'package:t_app/features/reels/domain/entities/reel.dart';

const String _sharedReelPrefix = 'reel-share:';

class SharedReelMessage {
  const SharedReelMessage({
    required this.reelId,
    required this.username,
    required this.displayName,
    required this.caption,
    required this.videoUrl,
    this.avatarUrl,
  });

  factory SharedReelMessage.fromReel(Reel reel) {
    return SharedReelMessage(
      reelId: reel.id,
      username: reel.username,
      displayName: reel.displayName,
      caption: reel.caption,
      videoUrl: reel.videoUrl,
      avatarUrl: reel.avatarUrl,
    );
  }

  factory SharedReelMessage.fromJson(Map<String, dynamic> json) {
    return SharedReelMessage(
      reelId: json['reelId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  final String reelId;
  final String username;
  final String displayName;
  final String caption;
  final String videoUrl;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      'reelId': reelId,
      'username': username,
      'displayName': displayName,
      'caption': caption,
      'videoUrl': videoUrl,
      'avatarUrl': avatarUrl,
    };
  }
}

String encodeSharedReelMessage(Reel reel) {
  final payload = Uri.encodeComponent(
    jsonEncode(SharedReelMessage.fromReel(reel).toJson()),
  );
  return '$_sharedReelPrefix$payload';
}

SharedReelMessage? tryDecodeSharedReelMessage(String? rawText) {
  if (rawText == null || !rawText.startsWith(_sharedReelPrefix)) {
    return null;
  }

  try {
    final encodedPayload = rawText.substring(_sharedReelPrefix.length);
    final decodedPayload = Uri.decodeComponent(encodedPayload);
    final json = jsonDecode(decodedPayload);
    if (json is Map<String, dynamic>) {
      return SharedReelMessage.fromJson(json);
    }
  } catch (_) {
    return null;
  }

  return null;
}
