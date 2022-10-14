import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:proxy_selector/models/proxy_dto.dart';

import 'proxy_selector_method_channel.dart';

abstract class ProxySelectorPlatform extends PlatformInterface {
  /// Constructs a ProxySelectorPlatform.
  ProxySelectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static ProxySelectorPlatform _instance = MethodChannelProxySelector();

  /// The default instance of [ProxySelectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelProxySelector].
  static ProxySelectorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ProxySelectorPlatform] when
  /// they register themselves.
  static set instance(ProxySelectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Iterable<ProxyDto>?> getSystemProxyForUrl(String url) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Iterable<ProxyDto>?> getSystemProxyForUri(Uri uri) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
