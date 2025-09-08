import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YagoutPayWebViewScreen extends StatefulWidget {
  final String htmlContent;
  final String successUrl;
  final String failureUrl;

  const YagoutPayWebViewScreen({
    super.key,
    required this.htmlContent,
    required this.successUrl,
    required this.failureUrl,
  });

  @override
  State<YagoutPayWebViewScreen> createState() => _YagoutPayWebViewScreenState();
}

class _YagoutPayWebViewScreenState extends State<YagoutPayWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    // On non-web platforms, explicitly enable JS. On web, skip to avoid
    // UnimplementedError from some plugin versions (JS is enabled by default).
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (url.startsWith(widget.successUrl)) {
              Navigator.pop(context, {'status': 'success', 'url': url});
            } else if (url.startsWith(widget.failureUrl)) {
              Navigator.pop(context, {'status': 'failure', 'url': url});
            }
          },
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.dataFromString(
        widget.htmlContent,
        mimeType: 'text/html',
        encoding: utf8,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YagoutPay')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
