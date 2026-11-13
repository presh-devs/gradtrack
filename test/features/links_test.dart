import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/backend.dart';
import 'package:gradll/features/links/domain/application_link.dart';
import 'package:gradll/features/links/presentation/links_controller.dart';

void main() {
  group('parseLinkInput', () {
    test('adds https:// to bare addresses and drops an empty name', () {
      final r = parseLinkInput('  csc.edu.cn/apply ', '  ');
      expect(r.error, isNull);
      expect(r.input, (url: 'https://csc.edu.cn/apply', label: null));
    });

    test('keeps http(s) links and trims the name', () {
      expect(parseLinkInput('http://x.edu', ' FAQ ').input, (url: 'http://x.edu', label: 'FAQ'));
    });

    test('rejects empty and non-web links', () {
      expect(parseLinkInput('', 'x').error, 'Enter the link');
      expect(parseLinkInput('not a link', '').error, isNotNull);
      expect(parseLinkInput('mailto:a@b.edu', '').error, isNotNull);
      expect(parseLinkInput('javascript:alert(1)', '').error, isNotNull);
      expect(parseLinkInput('example.edu:8080/x', '').input?.url, 'https://example.edu:8080/x');
    });
  });

  test('display label falls back to the site address', () {
    const l = ApplicationLink(id: '1', applicationId: 'a', url: 'https://www.daad.de/en/scholarships');
    expect(l.displayLabel, 'daad.de');
    expect(l.copyWith(label: 'DAAD').displayLabel, 'DAAD');
  });

  test('add, edit and delete links (demo backend)', () async {
    final container = ProviderContainer.test(overrides: [backendProvider.overrideWithValue(Backend.demo)]);
    final provider = applicationLinksProvider('a2');
    container.listen(provider, (_, _) {}); // as the links card does
    expect(await container.read(provider.future), isEmpty);

    await container.read(provider.notifier).add((url: 'https://ethz.ch/faq', label: null));
    final link = container.read(provider).value!.single;
    expect(link.displayLabel, 'ethz.ch');

    await container.read(provider.notifier).edit(link, (url: 'https://ethz.ch/faq', label: 'Admissions FAQ'));
    expect(container.read(provider).value!.single.label, 'Admissions FAQ');

    // Survives a reload from the repository.
    container.invalidate(provider);
    expect((await container.read(provider.future)).single.label, 'Admissions FAQ');

    await container.read(provider.notifier).delete(container.read(provider).value!.single);
    expect(container.read(provider).value, isEmpty);
  });
}
