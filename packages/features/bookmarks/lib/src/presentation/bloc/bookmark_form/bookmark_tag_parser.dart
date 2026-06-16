List<String> parseBookmarkTagsCsv(String csv) {
  return csv
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);
}
