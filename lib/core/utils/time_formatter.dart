class TimeFormatter {
  const TimeFormatter._();

  static String formatSocialTime(
    Object? input, {
    DateTime? now,
  }) {
    final date = _parseDate(input);
    if (date == null) {
      return '';
    }

    final currentTime = (now ?? DateTime.now()).toLocal();
    final difference = currentTime.difference(date);
    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Vừa xong';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    }

    final currentDate = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == currentDate.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    }

    final day = _twoDigits(date.day);
    final month = _twoDigits(date.month);
    if (date.year == currentTime.year) {
      return '$day/$month';
    }

    return '$day/$month/${date.year}';
  }

  static String formatFullDateTime(Object? input) {
    final date = _parseDate(input);
    if (date == null) {
      return '';
    }

    final day = _twoDigits(date.day);
    final month = _twoDigits(date.month);
    final hour = _twoDigits(date.hour);
    final minute = _twoDigits(date.minute);
    return '$day/$month/${date.year} $hour:$minute';
  }

  static DateTime? _parseDate(Object? input) {
    if (input == null) {
      return null;
    }
    if (input is DateTime) {
      return input.toLocal();
    }
    if (input is String && input.isNotEmpty) {
      final parsed = DateTime.tryParse(input);
      return parsed?.toLocal();
    }

    return null;
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
