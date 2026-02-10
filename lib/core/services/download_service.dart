import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final downloadServiceProvider = Provider((ref) => DownloadService());

class DownloadService {
  final Dio _dio = Dio();

  Future<String?> downloadRingtone(String url, String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$fileName';
      
      // Fix Github URL if raw is used (common issue with some datastores)
      String downloadUrl = url;
      if (downloadUrl.contains('github.com') && downloadUrl.contains('/blob/')) {
        downloadUrl = downloadUrl.replaceFirst('github.com', 'raw.githubusercontent.com');
        downloadUrl = downloadUrl.replaceFirst('/blob/', '/');
      }

      await _dio.download(downloadUrl, savePath);
      return savePath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }
}
