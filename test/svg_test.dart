import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Verify splash and logo image assets exist', () async {
    expect(File('assets/images/logo.png').existsSync(), isTrue);
    expect(File('assets/images/student.png').existsSync(), isTrue);
    expect(File('android/app/src/main/res/drawable/launch_image.png').existsSync(), isTrue);
  });
}

