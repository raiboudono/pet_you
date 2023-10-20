import 'package:isar/isar.dart';

import '../../features/setting/model/app_setting.dart';

class SettingRepository {
  SettingRepository(this.isar);
  Isar isar;

  AppSetting? getSetting() {
    return isar.appSettings.where().findFirstSync();
  }

  insertSetting(AppSetting setting) {
    isar.writeTxnSync(() {
      isar.appSettings.putSync(setting);
    });
  }
}
