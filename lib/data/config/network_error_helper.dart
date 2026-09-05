import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum NetworkErrorKind {
  noInternet,
  timeout,
  serverError,
  notFound,
  unknown,
}

class NetworkErrorInfo {
  final NetworkErrorKind kind;
  final String title;
  final String message;
  final IconData icon;

  const NetworkErrorInfo({
    required this.kind,
    required this.title,
    required this.message,
    required this.icon,
  });
}

class NetworkErrorHelper {
  static NetworkErrorInfo parse(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkErrorInfo(
            kind: NetworkErrorKind.timeout,
            title: 'Waktu Koneksi Habis',
            message:
                'Server memerlukan waktu terlalu lama untuk merespons. Pastikan sinyal Anda stabil dan coba lagi.',
            icon: Icons.timer_outlined,
          );

        case DioExceptionType.connectionError:
          return const NetworkErrorInfo(
            kind: NetworkErrorKind.noInternet,
            title: 'Koneksi Terputus',
            message:
                'Tidak dapat terhubung ke internet. Silakan periksa jaringan Wi-Fi atau data seluler Anda.',
            icon: Icons.wifi_off_rounded,
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          if (statusCode == 404) {
            return const NetworkErrorInfo(
              kind: NetworkErrorKind.notFound,
              title: 'Data Tidak Ditemukan',
              message:
                  'Informasi yang Anda cari tidak tersedia di server.',
              icon: Icons.search_off_rounded,
            );
          } else if (statusCode >= 500) {
            return const NetworkErrorInfo(
              kind: NetworkErrorKind.serverError,
              title: 'Gangguan Server',
              message:
                  'Server SWAPI sedang mengalami kendala sementara. Silakan coba beberapa saat lagi.',
              icon: Icons.cloud_off_rounded,
            );
          }
          return NetworkErrorInfo(
            kind: NetworkErrorKind.serverError,
            title: 'Gagal Memuat Data',
            message:
                'Terjadi kesalahan saat memproses data ($statusCode). Silakan coba lagi.',
            icon: Icons.error_outline_rounded,
          );

        case DioExceptionType.cancel:
          return const NetworkErrorInfo(
            kind: NetworkErrorKind.unknown,
            title: 'Permintaan Dibatalkan',
            message: 'Permintaan data ke server telah dibatalkan.',
            icon: Icons.cancel_outlined,
          );

        default:
          if (error.error is SocketException) {
            return const NetworkErrorInfo(
              kind: NetworkErrorKind.noInternet,
              title: 'Koneksi Terputus',
              message:
                  'Perangkat Anda sedang offline. Aktifkan Wi-Fi atau kuota internet Anda.',
              icon: Icons.wifi_off_rounded,
            );
          }
      }
    }

    if (error is SocketException) {
      return const NetworkErrorInfo(
        kind: NetworkErrorKind.noInternet,
        title: 'Koneksi Terputus',
        message:
            'Tidak ada akses internet. Periksa koneksi Anda dan coba kembali.',
        icon: Icons.wifi_off_rounded,
      );
    }

    final errStr = error?.toString().toLowerCase() ?? '';
    if (errStr.contains('socket') ||
        errStr.contains('network') ||
        errStr.contains('connection') ||
        errStr.contains('offline')) {
      return const NetworkErrorInfo(
        kind: NetworkErrorKind.noInternet,
        title: 'Koneksi Terputus',
        message:
            'Tidak dapat terhubung ke internet. Periksa koneksi jaringan Anda.',
        icon: Icons.wifi_off_rounded,
      );
    }

    return const NetworkErrorInfo(
      kind: NetworkErrorKind.unknown,
      title: 'Terjadi Kendala',
      message:
          'Gagal mengambil data terbaru dari server. Silakan coba beberapa saat lagi.',
      icon: Icons.error_outline_rounded,
    );
  }
}
