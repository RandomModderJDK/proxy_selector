import 'package:dio/dio.dart';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:proxy_selector/models/proxy_dto.dart';
import 'package:proxy_selector/proxy_selector.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textEditingController = TextEditingController();
  String _proxy = 'Unknown';
  String _response = "-";
  String? _error;
  String? _timeForExecution;
  bool _activateProxy = false;
  ProxySelector _proxyPlugin = ProxySelector();

  @override
  void initState() {
    super.initState();
    textEditingController.text = "https://example.com";
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _buttonCall() async {
    _proxyPlugin = ProxySelector();

    String? proxyAsList = "-";
    Response? response;
    String? error;
    String? timeForExecution;

    if (!mounted) return;

    setState(() {
      _proxy = proxyAsList ?? "-";
      _response = response?.data.toString() ?? "-";
      _error = error;
    });
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    Dio dio = Dio();
    try {
      final address = Uri.tryParse(textEditingController.text);

      if (!(address != null)) {
        error = " could not parse your input";
      } else {
        final stopwatch = Stopwatch()..start();
        final proxyForThisURL = _activateProxy
            ? (await _proxyPlugin.getSystemProxyForUri(address))
            : null;
        timeForExecution =
            _activateProxy ? stopwatch.elapsed.inMilliseconds.toString() : null;
        stopwatch.stop();

        if (proxyForThisURL != null && proxyForThisURL.isNotEmpty) {
          proxyAsList = proxyForThisURL.join();
          List<ProxyDto> proxies = List.from(proxyForThisURL);
          proxies.removeWhere((element) => element.type == "NONE");
          if (proxies.isNotEmpty) {
            dio.useProxy("${proxies.first.host}:${proxies.first.port}");
          }
        } else {
          error = "no proxy found";
        }

        response = await dio.get(
          address.toString(),
        );
      }
    } on PlatformException {
      _error = "Failed to get proxy.";
    } on DioError {
      _error = "could not request";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _proxy = proxyAsList ?? "-";
      _response = response?.data.toString() ?? "-";
      _timeForExecution = timeForExecution ?? "-";
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('proxy'),
          backgroundColor: Colors.green,
          actions: [
            const Text("Proxy on: "),
            Switch(
              value: _activateProxy,
              onChanged: (value) {
                setState(() {
                  _activateProxy = value;
                });
              },
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: textEditingController,
            ),
            Text(_proxy),
            Text("mill to get proxy: $_timeForExecution"),
            if (_error != null && _error!.isNotEmpty)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            OutlinedButton(
                onPressed: _buttonCall,
                child: const Text("Get proxy and call")),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_response),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
