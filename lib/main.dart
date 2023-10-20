import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:futter_you/features/setting/model/app_setting.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/notification/application/local_notification.dart';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'infra/isar_provider.dart';

final pathProvider = Provider((ref) => "");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await init();

  final dir = await getApplicationDocumentsDirectory();

  runApp(ProviderScope(overrides: [
    pathProvider.overrideWith((ref) => dir.path),
    themeModeProvider.overrideWith((ref) {
      final appSetting =
          ref.read(isarProvider).appSettings.where().findFirstSync();

      if (appSetting case AppSetting(:final theme)) return theme;

      return true;
    })
  ], child: const App()));
}
