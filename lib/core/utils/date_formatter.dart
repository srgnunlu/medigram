import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy', 'tr_TR').format(dateTime);
  }

  static String formatDateShort(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDateWithTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(dateTime);
  }
}
