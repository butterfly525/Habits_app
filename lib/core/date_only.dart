String toDateKey(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

DateTime monthStart(DateTime date) => DateTime(date.year, date.month, 1);
DateTime monthEnd(DateTime date) => DateTime(date.year, date.month + 1, 0);
DateTime dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);
