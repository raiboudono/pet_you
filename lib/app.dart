import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_fonts/google_fonts.dart';

import 'layout/layout.dart';

import 'features/pet/application/pet_provider.dart';
import 'features/setting/application/app_setting_provider.dart';

import 'layout/onbording.dart';

final themeModeProvider = StateProvider<bool>((ref) => true);
final googleFontsProvider = StateProvider((ref) =>
    GoogleFonts.duruSansTextTheme(
        const TextTheme(bodyMedium: TextStyle(letterSpacing: 1))));

final appProvider = Provider((ref) => const App());

final currentSettingProvider = Provider(
  (ref) {
    return ref.watch(settingProvider);
  },
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final googleFonts = ref.watch(googleFontsProvider);
    final pets = ref.watch(petProvider);
    final isExists = ref.watch(settingProvider.notifier).isExists;

    return MaterialApp(
        theme: ThemeData(
            // colorSchemeSeed: Colors.indigoAccent,
            colorScheme: const ColorScheme.light(
              primary: Colors.indigoAccent,
              onPrimary: Colors.black,
            ),
            useMaterial3: true,
            brightness: Brightness.light,
            textTheme: googleFonts),
        darkTheme: ThemeData(
            // colorSchemeSeed: Colors.green,
            colorScheme: const ColorScheme.dark(
              // primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
            textTheme: googleFonts),
        themeMode: themeMode ? ThemeMode.light : ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ja', 'JP'),
        ],
        home: pets.isEmpty && isExists == null
            ? const Onbording()
            : const Layout());
  }
}
