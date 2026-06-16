import 'package:database/database.dart';
import 'package:network/network.dart';

import '../datasources/bookmarks_remote_data_source.dart';
import '../local/bookmarks_local_data_source.dart';

/// Uploads local bookmark attachment paths and checkpoints remote URLs.
class BookmarkMediaUploadSync {
  BookmarkMediaUploadSync(this._local, this._remote);

  final BookmarksLocalDataSource _local;
  final BookmarksRemoteDataSource _remote;

  /// Bound on concurrent media uploads per row. Picked so the server isn't
  /// swamped by a row with many attachments, while still finishing notably
  /// faster than a serial drain.
  static const int _maxUploadConcurrency = 3;

  /// Uploads any local media files and persists the resulting remote URLs back
  /// to the row before the create/update call. If that call later fails, the
  /// next retry sees already-uploaded http(s) URLs and skips re-uploading.
  Future<void> checkpointUploads(BookmarkEntity row) async {
    final uploadedImages = await _uploadMediaFiles(row.imageUrls);
    final uploadedVideo = await _uploadVideoFile(row.videoUrl);
    if (_sameUrls(uploadedImages, row.imageUrls) &&
        uploadedVideo == row.videoUrl) {
      return;
    }
    row
      ..imageUrls = uploadedImages
      ..videoUrl = uploadedVideo;
    await _local.put(row);
  }

  bool _sameUrls(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<List<String>> _uploadMediaFiles(List<String> paths) async {
    final results = List<String?>.filled(paths.length, null);
    for (var start = 0; start < paths.length; start += _maxUploadConcurrency) {
      final end = (start + _maxUploadConcurrency).clamp(0, paths.length);
      await Future.wait(<Future<void>>[
        for (var i = start; i < end; i++)
          _uploadSingleMedia(paths[i]).then((url) => results[i] = url),
      ]);
    }
    return [for (final url in results) url!];
  }

  Future<String> _uploadSingleMedia(String path) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final file = await MultipartFile.fromFile(path);
    final res = await _remote.upload(file);
    final url = res['url'];
    if (url == null || url.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/upload'),
        error: 'Upload response missing url for $path',
      );
    }
    return url;
  }

  Future<String?> _uploadVideoFile(String? path) async {
    if (path == null) return null;
    return _uploadSingleMedia(path);
  }
}
