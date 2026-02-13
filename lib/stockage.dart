class stockage {
  static final List<String> _links = [];

  static Future<void> write(String link) async {
    _links.add(link);
  }

  static Future<List<String>> readAll() async {
    return List<String>.from(_links);
  }
}
