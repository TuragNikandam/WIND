class UriHelper {
  static Uri? getUriByStringURL(String url) {
    Uri? uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme.isEmpty ||
        uri.host.isEmpty ||
        uri.path.isEmpty) {
      return null;
    }
    return uri;
  }
}
