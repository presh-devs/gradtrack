import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/fx/naira_rates.dart';

void main() {
  final rates = NairaRates.fromJson({
    'result': 'success',
    'time_last_update_unix': 1794528151,
    'rates': {'USD': 1, 'NGN': 1500, 'CAD': 1.5, 'GBP': 0.75},
  });

  test('converts through USD into naira', () {
    expect(rates.toNaira(1, 'USD'), 1500);
    expect(rates.toNaira(150, 'CAD'), closeTo(150000, 1e-6));
    expect(rates.toNaira(10, 'gbp'), closeTo(20000, 1e-6));
    expect(rates.toNaira(5, 'NGN'), 5);
  });

  test('unknown or missing currency gives null', () {
    expect(rates.toNaira(10, 'XYZ'), isNull);
    expect(rates.toNaira(10, null), isNull);
  });

  test('a failed response is an error, not zero rates', () {
    expect(() => NairaRates.fromJson({'result': 'error'}), throwsFormatException);
  });
}
