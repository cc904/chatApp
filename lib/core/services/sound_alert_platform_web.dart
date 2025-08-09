import 'package:web/web.dart' as web;
import 'dart:js_interop';

Future<void> platformPlayMessageAlert() async {
  if (_webAudioUnlocked == false) return;
  _audio ??= web.HTMLAudioElement();
  _audio!.src = 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAESsAACJWAAACABAAZGF0YQAAAAA=';
  await _audio!.play().toDart;
  // 停止并复位
  Future.delayed(const Duration(milliseconds: 80), () {
    try {
      _audio?.pause();
      _audio?.currentTime = 0;
    } catch (_) {}
  });
}

void platformTryUnlockWebAudio() {
  _audio ??= web.HTMLAudioElement();
  _audio!.src = 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAESsAACJWAAACABAAZGF0YQAAAAA=';
  _audio!.play().toDart.then((_) {
    _webAudioUnlocked = true;
    _audio!.pause();
    _audio!.currentTime = 0;
  }).catchError((_) {
    _webAudioUnlocked = false;
  });
}

web.HTMLAudioElement? _audio;
bool _webAudioUnlocked = false;
