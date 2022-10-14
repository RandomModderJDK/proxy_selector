import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:proxy_selector/models/proxy_dto.dart';

import 'proxy_selector_platform_interface.dart';

const String methodChannelName = "proxy_selector";
const String getSystemProxyForUriMethodName = "getSystemProxyForUri";


/// An implementation of [ProxySelectorPlatform] that uses method channels.
class MethodChannelProxySelector extends ProxySelectorPlatform {
 /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(methodChannelName);

  @override
  Future<Iterable<ProxyDto>?> getSystemProxyForUrl(String url) async {
    return getSystemProxyForUri(Uri.parse(url));
  }

  @override
  Future<Iterable<ProxyDto>?> getSystemProxyForUri(Uri uri) async {
    final jsonProxies = await methodChannel.invokeMethod<String?>(
        getSystemProxyForUriMethodName, {"uri": uri.toString()});
    if (jsonProxies != null || jsonProxies!.isNotEmpty) {
      final Iterable proxies = json.decode(jsonProxies);
      List<ProxyDto> desProxies =
          List<ProxyDto>.from(proxies.map((model) => ProxyDto.fromJson(model)));
      return desProxies;
    } else {
      return [];
    }
  }
}
