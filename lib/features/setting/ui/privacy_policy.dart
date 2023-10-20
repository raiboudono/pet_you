import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider = StateProvider.autoDispose((ref) => true);

class PrivacyPolicy extends ConsumerWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(context, ref) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            Future.delayed(
                const Duration(
                  milliseconds: 500,
                ),
                () => ref
                    .read(isLoadingProvider.notifier)
                    .update((state) => false));
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://doc-hosting.flycricket.io/petyou-privacy-policy/b0ebc0d1-4ffa-4a9c-a449-867f90f799ee/privacy'));

    return Scaffold(
        appBar: AppBar(title: const Text('プライバシーポリシー')),
        body: ref.watch(isLoadingProvider)
            ? Container(
                color: Colors.transparent,
                child: const Center(child: LinearProgressIndicator()),
              )
            : WebViewWidget(controller: controller));
  }
}
