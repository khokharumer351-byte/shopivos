import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../supabase_client.dart';

class StorageRepository {
  final _random = Random();

  /// Uploads an image to the public `product-images` bucket and returns its URL.
  Future<String> uploadProductImage(Uint8List bytes, String fileName) async {
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final path =
        'products/${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(0x7fffffff).toRadixString(16)}.$ext';
    final bucket = supabase.storage.from(AppConfig.productImagesBucket);

    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: _mimeType(ext), upsert: false),
    );
    return bucket.getPublicUrl(path);
  }

  String _mimeType(String ext) => switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
}
