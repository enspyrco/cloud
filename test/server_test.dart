import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';

  setUp(() async {
    await TestProcess.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );
  });
  test('...', () async {
    final response = await get(
      Uri.parse(host + '/?pageId=8da7e92d9c4947db9d0ba0e39437b33e'),
    );
    expect(response.statusCode, 200);
  });
// headers: {'pageId': '7b890cc846504444b48cb9533c096de6'}
  test('Echo', () async {
    final response = await get(Uri.parse(host + '/echo/hello'));
    expect(response.statusCode, 200);
    expect(response.body, 'hello\n');
  });
  test('404', () async {
    final response = await get(Uri.parse(host + '/foobar'));
    expect(response.statusCode, 404);
  });
}
