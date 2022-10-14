import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proxy/proxy_method_channel.dart';

void main() {
  MethodChannelProxy platform = MethodChannelProxy();
  const MethodChannel channel = MethodChannel('proxy');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
