// Native platforms report composition through TextEditingValue.
class TextCompositionObserver {
  TextCompositionObserver(
    bool Function() focused,
    void Function(bool, String) changed,
  );
  bool get active => false;
  void reset() {}
  void dispose() {}
}
