import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Kesalahan pengambilan data HTTP yang aman ditampilkan ke pengguna.
class PostException implements Exception {
  /// Membuat kesalahan dengan [message] yang ramah pengguna.
  const PostException(this.message);

  /// Pesan yang ditampilkan pada UI.
  final String message;

  @override
  String toString() => message;
}

/// Satu kiriman (post) dari API publik.
class Post {
  /// Membuat ringkasan post.
  const Post({required this.id, required this.title, required this.body});

  /// Identitas post dari server.
  final int id;

  /// Judul post.
  final String title;

  /// Isi ringkas post.
  final String body;
}

/// Repository data contoh dari API publik (jsonplaceholder).
class PostRepository {
  /// Membuat repository; [client] dapat diganti saat pengujian.
  PostRepository({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  /// Mengambil maksimal [limit] post dari `BASE_URL/posts`.
  ///
  /// Melempar [PostException] dengan pesan ramah pengguna bila gagal.
  Future<List<Post>> fetchPosts({int limit = 10}) async {
    if (!AppConfig.hasBaseUrl) {
      throw const PostException('BASE_URL belum dikonfigurasi pada berkas .env');
    }

    final Uri uri = AppConfig.endpoint('posts');
    try {
      final http.Response response = await _client
          .get(
            uri,
            headers: <String, String>{
              'Accept': 'application/json',
              if (AppConfig.apiKey.isNotEmpty) 'X-API-Key': AppConfig.apiKey,
            },
          )
          .timeout(_timeout);

      // Log aman: hanya endpoint dan status, tanpa API key maupun isi respons.
      debugPrint('GET ${uri.path} -> ${response.statusCode}');

      if (response.statusCode != 200) {
        throw PostException('Gagal memuat data (HTTP ${response.statusCode})');
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const PostException('Format respons tidak dikenali');
      }

      return decoded
          .take(limit)
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> item) => Post(
              id: (item['id'] as num?)?.toInt() ?? 0,
              title: (item['title'] as String? ?? '').trim(),
              body: (item['body'] as String? ?? '').trim(),
            ),
          )
          .toList();
    } on SocketException {
      throw const PostException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw const PostException('Permintaan melebihi batas 10 detik');
    } on http.ClientException {
      throw const PostException('Koneksi ke server gagal');
    } on FormatException {
      throw const PostException('Respons API tidak valid');
    }
  }

  /// Menutup koneksi HTTP yang dipakai repository.
  void dispose() {
    _client.close();
  }
}
