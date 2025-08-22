import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricUtils {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
      );
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}
