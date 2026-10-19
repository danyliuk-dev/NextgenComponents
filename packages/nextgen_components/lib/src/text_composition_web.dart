import 'dart:js_interop';
import 'package:web/web.dart' as web;

// Flutter's semantics editing strategy can omit composing ranges. Observe the
// native events for this focused editor as well, without mutating the DOM input.
class TextCompositionObserver {
  late final JSFunction start, end;
  web.EventTarget? target;
  bool active = false;
  TextCompositionObserver(
    bool Function() focused,
    void Function(bool, String) changed,
  ) {
    start = ((web.Event event) {
      if (!focused()) return;
      final value = text(event.target);
      if (value == null) return;
      target = event.target;
      active = true;
      changed(true, value);
    }).toJS;
    end = ((web.Event event) {
      if (!active || event.target != target) return;
      final value = text(event.target);
      reset();
      if (value != null) changed(false, value);
    }).toJS;
    web.document.addEventListener('compositionstart', start, true.toJS);
    web.document.addEventListener('compositionend', end, true.toJS);
  }
  String? text(web.EventTarget? target) {
    if (target.isA<web.HTMLInputElement>())
      return (target as web.HTMLInputElement).value;
    if (target.isA<web.HTMLTextAreaElement>())
      return (target as web.HTMLTextAreaElement).value;
    return null;
  }

  void reset() {
    active = false;
    target = null;
  }

  void dispose() {
    web.document.removeEventListener('compositionstart', start, true.toJS);
    web.document.removeEventListener('compositionend', end, true.toJS);
    reset();
  }
}
