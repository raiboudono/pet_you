import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:googleapis/drive/v3.dart' as drive3;

final googleSignInServiceProvider =
    StateNotifierProvider((ref) => GoogleSignInService(
          GoogleSignIn(scopes: [
            drive3.DriveApi.driveAppdataScope,
          ]),
        ));

class GoogleSignInService extends StateNotifier<gapis.AuthClient?> {
  final GoogleSignIn? googleSignIn;
  GoogleSignInAccount? account;

  GoogleSignInService(this.googleSignIn) : super(null);

  signIn() async {
    account = await googleSignIn?.signIn();
    state = await googleSignIn?.authenticatedClient();
  }

  signOut() {}
}
