import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:webview_flutter/webview_flutter.dart';

final isLoadingProvider = StateProvider.autoDispose((ref) => true);
final isAgreeProvider = StateProvider.autoDispose((ref) => false);

class EmailContactForm extends ConsumerWidget {
  const EmailContactForm({super.key});

  @override
  Widget build(context, ref) {
    final formKey = GlobalKey<FormState>();
    String subject = '';
    String body = '';

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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('お問い合わせ'), centerTitle: true),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Form(
                key: formKey,
                child: Column(children: [
                  const SizedBox(height: 40),
                  TextFormField(
                    maxLength: 20,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'タイトル',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return '入力がありません';
                      }
                      return null;
                    },
                    onSaved: (String? value) => subject = value!,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '本文',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return '入力がありません';
                      }
                      return null;
                    },
                    onSaved: (String? value) => body = value!,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      'お問い合わせいただき、ありがとうございます。回答まで通常2営業日ほどお時間をいただいております。何卒ご了承ください。',
                      style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 80),
                  Text.rich(
                      style: const TextStyle(fontSize: 12),
                      TextSpan(text: 'お問い合わせフォームをご利用の際は', children: [
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return Stack(children: [
                                    Container(
                                      color: Colors.transparent,
                                      child: const Center(
                                          child: LinearProgressIndicator()),
                                    ),
                                    if (ref.watch(isLoadingProvider))
                                      WebViewWidget(controller: controller)
                                  ]);
                                }));
                              },
                            text: 'プライバシーポリシー',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            )),
                        const TextSpan(text: 'に同意いただく必要があります'),
                      ])),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, child) {
                      return SizedBox(
                          width: 110,
                          child: CheckboxMenuButton(
                            value: ref.watch(isAgreeProvider),
                            onChanged: (bool? value) {
                              ref
                                  .read(isAgreeProvider.notifier)
                                  .update((state) => value!);
                            },
                            child: const Text("同意する",
                                style: TextStyle(fontSize: 13)),
                          ));
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer(builder: (context, ref, child) {
                    return FilledButton.icon(
                        onPressed: () {
                          if (!ref.watch(isAgreeProvider)) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const AlertDialog(
                                      content:
                                          Text('プライバシーポリシーに同意いただく必要があります'));
                                });
                            return;
                          }

                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final Email email = Email(
                              subject: subject,
                              body: body,
                              recipients: ['ysann914@gmail.com'],
                            );

                            FlutterEmailSender.send(email);

                            Navigator.of(context).pop();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: ref.watch(isAgreeProvider)
                              ? null
                              : Colors.black12,
                        ),
                        icon: const Icon(Icons.email),
                        label: const Text('送信'));
                  }),
                ]))));
  }
}
