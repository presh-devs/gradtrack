import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/features/auth/domain/auth_redirect.dart';

void main() {
  test('no error on a normal load', () {
    expect(AuthRedirect.errorFrom(Uri.parse('https://gradll.pages.dev/?code=abc')), isNull);
    expect(AuthRedirect.errorFrom(Uri.parse('https://gradll.pages.dev/applications')), isNull);
  });

  test('invite-only message from the hook is shown as-is', () {
    final uri = Uri.parse('https://gradll.pages.dev/?error=access_denied&error_code=hook_error'
        '&error_description=gradll+is+invite-only.+Ask+the+person+who+shared+it+with+you+to+add+your+email.');
    expect(AuthRedirect.errorFrom(uri), startsWith('gradll is invite-only.'));
  });

  test('error in the fragment', () {
    final uri = Uri.parse('https://gradll.pages.dev/#error=server_error&error_description=Unsupported+provider');
    expect(AuthRedirect.errorFrom(uri), 'Sign-in didn’t complete: Unsupported provider');
  });

  test('cancelled without a description', () {
    expect(AuthRedirect.errorFrom(Uri.parse('https://gradll.pages.dev/?error=access_denied')),
        'Google sign-in was cancelled.');
  });

  test('error stays until cleared', () {
    final r = AuthRedirect(Uri.parse('https://gradll.pages.dev/?error=access_denied'));
    expect(r.error, isNotNull);
    expect(r.error, isNotNull);
    r.clear();
    expect(r.error, isNull);
  });
}
