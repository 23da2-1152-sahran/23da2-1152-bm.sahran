import 'dart:io';
import 'package:http/http.dart' as http;

/// Configures HTTP client with proper headers to fix external image loading issues
class HttpClientConfig {
  static void configureHttpClient() {
    HttpOverrides.global = CustomHttpOverrides();
  }
}

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Custom HTTP client for loading images with proper headers
class CustomImageHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add User-Agent header to bypass some server restrictions
    request.headers['User-Agent'] =
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15';
    
    // Add other common headers
    request.headers['Accept'] = 'image/*,*/*;q=0.8';
    request.headers['Accept-Encoding'] = 'gzip, deflate';
    
    return http.Client().send(request);
  }
}

/// Get custom HTTP client for image loading
http.Client getImageHttpClient() {
  return CustomImageHttpClient();
}
