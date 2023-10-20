import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:googleapis/drive/v3.dart' as drive3;
import 'package:path/path.dart' as p;
import 'dart:io' as io;
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import '../../../infra/isar_provider.dart';
import '../../album/model/media.dart';

final driveServiceProvider =
    StateProvider.family<DriveService, dynamic>((ref, client) {
  return DriveService(client);
});

/*danger:
ペット削除してもisarは1MGのままだから他もそうだろう
つまりデバイスのデータがなくなってもバックアップデータとの比較で判断つかない
全てのモデルを集めた容量という別の容量を得る必要がありそう
 */

class DriveService {
  final drive3.DriveApi drive;
  final backupFolder = 'appDataFolder';

  DriveService(client) : drive = drive3.DriveApi(client);

  Future<drive3.FilesResource> driveFileResource() async {
    final drive3.FilesResource filesResource = drive.files;

    return filesResource;
  }

  Future<void> backupFile(io.File file) async {
    final drive3.FilesResource filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource.list(
        spaces: backupFolder, $fields: 'files(id, fileExtension)');

    for (final driveFile in fileList.files!) {
      if (driveFile.fileExtension ==
          p.extension(file.path).replaceFirst('.', '')) {
        await filesResource.delete(driveFile.id!);
      }
    }

    await filesResource.create(
        drive3.File(name: p.basename(file.path), parents: [backupFolder]),
        uploadMedia: drive3.Media(file.openRead(), file.lengthSync()));
  }

  Future<void> backupFiles(List<Media> medias) async {
    final drive3.FilesResource filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource.list(
        spaces: backupFolder, $fields: 'files(id, fileExtension)');

    for (final driveFile in fileList.files!) {
      if (driveFile.fileExtension ==
          p.extension(medias.first.path).replaceFirst('.', '')) {
        await filesResource.delete(driveFile.id!);
      }
    }

    for (final media in medias) {
      final file = io.File(media.path);
      await filesResource.create(
          drive3.File(name: p.basename(media.path), parents: [backupFolder]),
          uploadMedia: drive3.Media(file.openRead(), file.lengthSync()));
    }
  }

  Future<void> deleteBackupAll() async {
    final drive3.FilesResource filesResource = await driveFileResource();
    final drive3.FileList fileList = await filesResource.list(
      spaces: backupFolder,
    );

    for (final driveFile in fileList.files!) {
      filesResource.delete(driveFile.id!);
    }
  }

  backupList() async {
    final drive3.FilesResource? filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource!.list(
        spaces: 'appDataFolder',
        $fields: 'files(name, id, size, fileExtension, createdTime, mimeType)');

    // print(fileList.files!.length);

    for (final drive3.File file in fileList.files!) {
      print(file.name);
      // print(file.mimeType);

      // print(file.spaces);
      // print(file.fullFileExtension);
      // print(file.id);

      // if (file.fileExtension == 'jpg') {
      //   print(file.name);
      //   print(file.createdTime);
      //   print(file.size);
      // }

      // if (file.fileExtension == 'isar') {
      //   print(file.name);
      //   print(file.createdTime);
      //   print(file.size);
      // }
    }
  }

  Future<double> backedupTotalSize() async {
    final drive3.FilesResource filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource.list(
        spaces: backupFolder, $fields: 'files(id, size)');

    final totalSize = fileList.files!.fold(
        0.0, (v1, file) => v1 + (double.tryParse(file.size ?? '0.0') ?? 0.0));

    return totalSize;
  }

  Future<double> backedupFileSizeByExtension(fileExtension) async {
    final drive3.FilesResource filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource.list(
        spaces: backupFolder, $fields: 'files(id, size, fileExtension)');

    final files =
        fileList.files!.where((file) => file.fileExtension == fileExtension);

    final totalSize = files.fold(
        0.0, (v1, file) => v1 + (double.tryParse(file.size ?? '0.0') ?? 0.0));

    return totalSize;
  }

  formatBackupDay(DateTime datetime) {
    return DateFormat.yMd("ja_JP").format(datetime);
  }

  Future<void> restoreFile() async {
    final drive3.FilesResource filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource.list(
        spaces: backupFolder, $fields: 'files(id, name, fileExtension)');

    final isarFile = fileList.files!
        .firstWhereOrNull((file) => file.fileExtension == 'isar');

    if (isarFile != null) {
      final res = await filesResource.get(isarFile.id!,
          downloadOptions: drive3.DownloadOptions.fullMedia) as drive3.Media;

      var list = <int>[];

      res.stream.listen((bytes) {
        list.insertAll(list.length, bytes);
      }, onDone: () async {
        io.File(p.join('/data/user/0/com.miya.pet_you/app_flutter', 'Pet.isar'))
            .writeAsBytesSync(list);
      });
    }
  }

  Future<void> restertApp(WidgetRef ref) async {
    await ref.read(isarProvider).close();

    ref.invalidate(isarProvider);

    await Future.delayed(const Duration(seconds: 1));

    await Restart.restartApp();
  }

  Future<void> restoreFiles(String fileExtension) async {
    final drive3.FilesResource filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource.list(
        spaces: backupFolder, $fields: 'files(id, name, fileExtension)');

    final driveFiles =
        fileList.files!.where((file) => file.fileExtension == fileExtension);

    if (driveFiles.isNotEmpty) {
      deleteFilesFromGalleryByExtension(fileExtension);

      for (final driveFile in driveFiles) {
        final res = await filesResource.get(driveFile.id!,
            downloadOptions: drive3.DownloadOptions.fullMedia) as drive3.Media;

        var list = <int>[];

        res.stream.listen((bytes) {
          list.insertAll(list.length, bytes);
        }, onDone: () async {
          final target = io.File(p.join(
              io.Directory.systemTemp.path, p.basename(driveFile.name!)));

          target.writeAsBytesSync(list);

          if (fileExtension == 'jpg') {
            await Gal.putImage(target.path, album: 'PetYou');
          } else {
            await Gal.putVideo(target.path, album: 'PetYou');
          }

          io.Directory(target.path).deleteSync(recursive: true);
        });
      }
    }
  }

  Future<List<bool>> getRestoreTargetExistsList() async {
    final drive3.FilesResource filesResource = await driveFileResource();

    final drive3.FileList fileList = await filesResource.list(
        spaces: backupFolder, $fields: 'files(id, name, fileExtension)');

    final driveImages =
        fileList.files!.where((file) => file.fileExtension == 'jpg');
    final driveMovies =
        fileList.files!.where((file) => file.fileExtension == 'mp4');
    final driveIsar =
        fileList.files!.where((file) => file.fileExtension == 'isar');

    return <bool>[
      driveImages.isNotEmpty,
      driveMovies.isNotEmpty,
      driveIsar.isNotEmpty
    ];
  }

  void deleteFilesFromGalleryByExtension(fileExtention) {
    final galleryDir = io.Directory('/storage/emulated/0/Pictures/PetYou');

    final files = galleryDir
        .listSync()
        .where((entry) => p.extension(entry.path) == '.$fileExtention');

    for (final file in files) {
      file.deleteSync();
    }
  }
}
