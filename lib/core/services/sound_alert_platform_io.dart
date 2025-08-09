import 'package:flutter/services.dart';

Future<void> platformPlayMessageAlert() async {
  await SystemSound.play(SystemSoundType.alert);
}

void platformTryUnlockWebAudio() {}
