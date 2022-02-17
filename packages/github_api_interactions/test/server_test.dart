import 'dart:convert';
import 'dart:io';

import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

final appUri = Uri.parse('https://api.github.com/app');
final installationsUri = Uri.parse('https://api.github.com/app/installations');

void main() {
  final local = 'http://0.0.0.0:8080';
  final live = '';

  test('Echo', () async {
    final response = await get(Uri.parse(local + '/echo/hello'));
    expect(response.statusCode, 200);
    expect(response.body, 'hello\n');
  });

  test('Create JWT for authenticated call to GitHub API', () async {
    var builder = JWTBuilder()
      // GitHub App's identifier
      ..issuer = '173221'
      // issued at time, 60 seconds in the past to allow for clock drift
      ..issuedAt = DateTime.now().subtract(Duration(seconds: 60))
      // JWT expiration time (10 minute maximum)
      ..expiresAt = DateTime.now().add(Duration(minutes: 10));

    var pemString = File('test/data/adventures-in.2022-02-16.private-key.pem')
        .readAsStringSync();
    var signer = JWTRsaSha256Signer(privateKey: pemString);
    var signedJWT = builder.getSignedToken(signer);

    // Use the JWT to request info on the GitHub app
    // final response = await get(installationsUri, headers: {
    //   "Accept": "application/vnd.github.v3+json",
    //   "Authorization": "Bearer $signedToken",
    // });
    // print(response.body);

    // Use the JWT to request an installation token
    final installationTokenResponse = await post(
        Uri.parse(
            'https://api.github.com/app/installations/23353229/access_tokens'),
        headers: {
          "Accept": "application/vnd.github.v3+json",
          "Authorization": "Bearer $signedJWT",
        });
    print(installationTokenResponse.body);

    var installationTokenJson = jsonDecode(installationTokenResponse.body);
    // var expString = json['expires_at'];
    // var date = DateTime.parse(expString);
    // print(date.difference(DateTime.now()));
    var installationToken = installationTokenJson['token'];

    final response =
        await post(Uri.parse('https://api.github.com/orgs/adventures-in/repos'),
            headers: {
              "Accept": "application/vnd.github.v3+json",
              "Authorization": "token $installationToken",
            },
            body: '{"name":"testerooniroo"}');
    print(response.body);

    // var decodedToken = JWT.parse('$stringToken');
    // // Verify signature:
    // print(decodedToken.verify(signer)); // true

    // // Validate claims:
    // var validator = JWTValidator() // uses DateTime.now() by default
    //   ..issuer = '173221'; // set claims you wish to validate
    // Set<String> errors = validator.validate(decodedToken);
    // print(errors); // (empty list)
  });
}
