class UriHelper {
  static Uri? getUriByStringURL(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    return (uri.scheme.isNotEmpty && uri.host.isNotEmpty && uri.path.isNotEmpty)
        ? uri
        : null;
  }
}
