import 'package:dio/dio.dart';

class ApiErrors {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi terputus. Silakan periksa jaringan Anda.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Sesi Anda telah berakhir. Silakan login kembali.';
          } else if (statusCode == 403) {
            return 'Anda tidak memiliki akses ke halaman ini.';
          } else if (statusCode == 404) {
            return 'Data tidak ditemukan.';
          } else if (statusCode == 500) {
            return 'Terjadi kesalahan pada server.';
          }
          return 'Terjadi kesalahan: ${error.response?.statusMessage}';
        case DioExceptionType.cancel:
          return 'Permintaan dibatalkan.';
        case DioExceptionType.connectionError:
          return 'Tidak ada koneksi internet.';
        default:
          return 'Terjadi kesalahan yang tidak diketahui.';
      }
    }
    return error.toString();
  }
}
