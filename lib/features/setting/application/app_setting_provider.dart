import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infra/repository_provider.dart';
import '../../../../constants/work/work.dart';

import '/../../../infra/setting/setting_repository.dart';

import '../model/app_setting.dart';

final settingProvider =
    StateNotifierProvider<SettingStateNotifier, AppSetting?>((ref) {
  final repository = ref.watch(repositoryProvider(Work.setting));
  return SettingStateNotifier(repository);
});

class SettingStateNotifier extends StateNotifier<AppSetting?> {
  SettingStateNotifier(this._repository) : super(_repository.getSetting());
  final SettingRepository _repository;

  void saveSetting(AppSetting setting) {
    _repository.insertSetting(setting);
    state = _repository.getSetting();
  }

  AppSetting? get isExists => _repository.getSetting();

  bool get isTutorial => _repository.getSetting()?.tutorial ?? false;
}
