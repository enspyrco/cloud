import 'package:dart_runner/evaluate.dart';
import 'package:test/test.dart';

void main() {
  test('', () async {
    dynamic result = await evaluate('3+4');
    expect(result, 7);
  });
}
