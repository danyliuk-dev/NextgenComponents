import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

class Topic {
  final String id;
  String name;
  Topic(this.id, this.name);
}

void main() {
  test('typed snapshot retains identity, mappings and immutable options', () {
    final item = Topic('ops', 'Operations');
    var calls = 0;
    final data = NgChipData(
      [item],
      value: (x) {
        calls++;
        return x.id;
      },
      text: (x) => x.name,
      disabled: (_) => true,
      removable: (_) => false,
      appearance: (_) => const NgChipAppearance(themeColor: 'warning'),
    );
    expect(identical(data.getItem('ops'), item), isTrue);
    expect(calls, 1);
    item.name = 'Revised';
    expect(data.items.single.label, 'Operations');
    expect(data.items.single.disabled, isTrue);
    expect(data.canRemove(data.items.single), isFalse);
    expect(data.getAppearance(data.items.single).themeColor, 'warning');
    expect(() => data.items.clear(), throwsUnsupportedError);
    expect(() => data.getItem('missing'), throwsArgumentError);
    expect(
      NgChipData(
        [item],
        value: (x) => x.id,
        text: (x) => x.name,
      ).items.single.label,
      'Revised',
    );
  });
  test('invalid model mappings fail before rendering', () {
    NgChipData<Topic> bind(List<Topic> items) =>
        NgChipData(items, value: (x) => x.id, text: (x) => x.name);
    expect(() => bind([Topic('x', 'A'), Topic('x', 'B')]), throwsArgumentError);
    expect(() => bind([Topic('bad id', 'A')]), throwsArgumentError);
    expect(() => bind([Topic('x', ' ')]), throwsArgumentError);
    expect(
      () => NgChipData(
        [Topic('x', 'A')],
        value: (x) => x.id,
        text: (x) => x.name,
        appearance: (_) => const NgChipAppearance(size: 'xxl'),
      ),
      throwsArgumentError,
    );
  });
}
