import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider = StateProvider.autoDispose((ref) => true);

class TeamsOfService extends ConsumerWidget {
  const TeamsOfService({super.key});

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
          'https://doc-hosting.flycricket.io/petyou-terms-of-use/067b3f13-b317-42a2-b6f1-6a0f294a0d41/terms'));

    return Scaffold(
        appBar: AppBar(title: const Text('利用規約')),
        body: ref.watch(isLoadingProvider)
            ? Container(
                color: Colors.transparent,
                child: const Center(child: LinearProgressIndicator()),
              )
            : WebViewWidget(controller: controller));
  }
}
