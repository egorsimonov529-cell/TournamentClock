import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_clock/core/utils/form_validators.dart';

void main() {
  group('FormValidators', () {
    test('accepts valid login credentials', () {
      expect(FormValidators.login('player_1'), isNull);
      expect(FormValidators.password('secret1'), isNull);
    });

    test('rejects invalid login credentials', () {
      expect(FormValidators.login('ab'), isNotNull);
      expect(FormValidators.login('bad login'), isNotNull);
      expect(FormValidators.password('123'), isNotNull);
    });

    test('validates email addresses', () {
      expect(FormValidators.email('player@example.com'), isNull);
      expect(FormValidators.email('invalid-email'), isNotNull);
    });
  });
}