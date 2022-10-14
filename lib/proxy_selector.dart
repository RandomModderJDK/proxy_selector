
import 'package:proxy_selector/models/proxy_dto.dart';

import 'proxy_selector_platform_interface.dart';

class ProxySelector {
  Future<Iterable<ProxyDto>?> getSystemProxyForUri(Uri uri) {
    return ProxySelectorPlatform.instance.getSystemProxyForUri(uri);
  }

  Future<Iterable<ProxyDto>?> getSystemProxyForUrl(String url) {
    return ProxySelectorPlatform.instance.getSystemProxyForUrl(url);
  }
}
