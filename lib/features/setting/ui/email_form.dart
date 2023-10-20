import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'backup.dart';
import 'reset_password.dart';

final visibleProvider = StateProvider((ref) => false);
final emailProvider = StateProvider((ref) => '');
final passwordProvider = StateProvider((ref) => '');
final passwordConfirmProvider = StateProvider((ref) => '');

final formKeyProvider = Provider((ref) => GlobalKey<FormState>());

final loginProvider = StateProvider((ref) => false);

final errorMsgProvider = StateProvider((ref) => '');

/*danger:
goog または メルパス未ログインの場合
⇒ 両方
どちらか一方ログイン済み
⇒ バックアップ画面

メルパスについて
上記両方の際に新規登録がまだの場合
⇒ 新規登録画面


 */

class EmailForm extends ConsumerWidget {
  const EmailForm({super.key});

  @override
  Widget build(context, ref) {
    final visible = ref.watch(visibleProvider);
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final passwordConfirm = ref.watch(passwordConfirmProvider);
    final errorMsg = ref.watch(errorMsgProvider);

    return Material(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Center(
                child: Form(
                    key: ref.watch(formKeyProvider),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                        child: TextFormField(
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              const InputDecoration(labelText: "メールアドレス"),
                          onChanged: (value) {
                            ref
                                .read(emailProvider.notifier)
                                .update((state) => value);
                          },
                          onFieldSubmitted: (String value) {
                            ref
                                .read(emailProvider.notifier)
                                .update((state) => value);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: TextFormField(
                          autofillHints: const [AutofillHints.password],
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: "パスワード（8文字以上）",
                            suffixIcon: IconButton(
                                icon: visible
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                                onPressed: () => ref
                                    .read(visibleProvider.notifier)
                                    .update((state) => !visible)),
                          ),
                          obscureText: visible,
                          onFieldSubmitted: (String value) {
                            ref
                                .read(passwordProvider.notifier)
                                .update((state) => value);
                          },
                          onChanged: (value) {
                            ref
                                .read(passwordProvider.notifier)
                                .update((state) => value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '入力がありません';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text('※ 新規登録のみ要入力',
                              style: TextStyle(fontSize: 12))),
                      Flexible(
                        child: TextFormField(
                          autofillHints: const [AutofillHints.password],
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: "パスワード（確認用）",
                            suffixIcon: IconButton(
                                icon: visible
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                                onPressed: () => ref
                                    .read(visibleProvider.notifier)
                                    .update((state) => !visible)),
                          ),
                          obscureText: visible,
                          onFieldSubmitted: (String value) {
                            ref
                                .read(passwordConfirmProvider.notifier)
                                .update((state) => value);
                          },
                          onChanged: (value) {
                            ref
                                .read(passwordConfirmProvider.notifier)
                                .update((state) => value);
                          },
                          validator: (value) {
                            if (ref.watch(loginProvider)) {
                              return null;
                            }
                            if (value == null || value.isEmpty) {
                              return '入力がありません';
                            }
                            if (password.isNotEmpty &&
                                password != passwordConfirm) {
                              return '入力が正しくありません';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Spacer(),
                      SizedBox(child: Text(errorMsg)),
                      TextButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const ResetPassword())),
                          child: const Text('パスワードを忘れた場合')),
                      const SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilledButton(
                              onPressed: () async {
                                final formkey = ref.read(formKeyProvider);
                                if (formkey.currentState!.validate()) {
                                  try {
                                    final FirebaseAuth auth =
                                        FirebaseAuth.instance;
                                    auth
                                        .createUserWithEmailAndPassword(
                                            email: email, password: password)
                                        .then((value) {
                                      ref
                                          .read(userProvider.notifier)
                                          .update((state) => value.user);
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                title:
                                                    const Text('新規登録が完了しました'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return const BackUp();
                                                        }));
                                                      },
                                                      child: const Text('次へ'))
                                                ]);
                                          });
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'email-already-in-use') {
                                      ref
                                          .read(errorMsgProvider.notifier)
                                          .update((state) => 'このアドレスは登録できません');
                                    }
                                    if (e.code == 'invalid-email') {
                                      ref
                                          .read(errorMsgProvider.notifier)
                                          .update((state) => 'このアドレスは登録できません');
                                    }
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                }
                              },
                              child: const Text('新規登録'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                ref
                                    .read(loginProvider.notifier)
                                    .update((state) => true);
                                final formkey = ref.read(formKeyProvider);
                                if (formkey.currentState!.validate()) {
                                  try {
                                    final FirebaseAuth auth =
                                        FirebaseAuth.instance;
                                    auth
                                        .signInWithEmailAndPassword(
                                            email: email, password: password)
                                        .then((value) {
                                      ref
                                          .read(userProvider.notifier)
                                          .update((state) => value.user);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BackUp()),
                                          (_) => false);
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      ref
                                          .read(errorMsgProvider.notifier)
                                          .update((state) => 'ユーザーが見つかりません');
                                    }
                                    if (e.code == 'invalid-email') {
                                      ref
                                          .read(errorMsgProvider.notifier)
                                          .update((state) => '無効なアドレスです');
                                    }
                                    if (e.code == 'wrong-password') {
                                      ref
                                          .read(errorMsgProvider.notifier)
                                          .update((state) => '一致しません');
                                    }
                                    print(e);
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              },
                              child: const Text('ログイン'),
                            ),
                          ])
                    ])))));
  }
}
