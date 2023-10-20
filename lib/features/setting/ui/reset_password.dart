import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

final emailProvider = StateProvider((ref) => '');

class ResetPassword extends ConsumerWidget {
  const ResetPassword({super.key});

  @override
  Widget build(context, ref) {
    final fieldKey = GlobalKey<FormFieldState>();

    return Material(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: TextFormField(
                  key: fieldKey,
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "メールアドレス"),
                  onChanged: (value) {
                    ref.read(emailProvider.notifier).update((state) => value);
                  },
                  onFieldSubmitted: (String value) {
                    ref.read(emailProvider.notifier).update((state) => value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスの入力がありません';
                    }
                    return null;
                  },
                ),
              ),
              const Spacer(),
              const Text('メールアドレス宛にパスワードを再設定するためのメールが送信されます\n'),
              FilledButton(
                onPressed: () async {
                  if (fieldKey.currentState!.validate()) {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      auth
                          .sendPasswordResetEmail(
                              email: ref.watch(emailProvider))
                          .then((voidValue) {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      });
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  }
                },
                child: const Text('パスワードを再設定する'),
              ),
            ]))));
  }
}
