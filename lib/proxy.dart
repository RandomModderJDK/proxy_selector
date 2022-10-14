import 'package:proxy/models/proxy_dto.dart';

import 'proxy_platform_interface.dart';

class Proxy {
  Future<Iterable<ProxyDto>?> getSystemProxyForUri(Uri uri) {
    return ProxyPlatform.instance.getSystemProxyForUri(uri);
  }

  Future<Iterable<ProxyDto>?> getSystemProxyForUrl(String url) {
    return ProxyPlatform.instance.getSystemProxyForUrl(url);
  }
}
