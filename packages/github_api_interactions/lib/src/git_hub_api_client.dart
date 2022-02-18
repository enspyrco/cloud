import 'dart:convert';

import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:googleapis/secretmanager/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

const githubAppInstallationId = '23353229';
const gcpProjectId = '1052081684914';
const githubAppId = '173221';
const secretName = 'adventures-in-github-app-private-key';
const defaultOrg = 'adventures-in';

typedef JsonMap = Map<String, Object?>;

class GitHubApiClient {
  late final Client _authClient;
  String _installationToken;
  DateTime _tokenExpiry;

  GitHubApiClient._(
    this._installationToken,
    this._authClient,
    this._tokenExpiry,
  );

  static Future<GitHubApiClient> create({Client? authClient}) async {
    var _authClient =
        authClient ?? await clientViaApplicationDefaultCredentials(scopes: []);
    var installationTokenJson = await _requestToken(_authClient);

    return GitHubApiClient._(
      installationTokenJson['token'] as String,
      _authClient,
      DateTime.parse(installationTokenJson['expires_at'] as String),
    );
  }

  static Future<JsonMap> _requestToken(Client authClient) async {
    // Retrieve the GitHub App private key from the SecretManager
    var secretManager = SecretManagerApi(authClient);
    var secretResponse = await secretManager.projects.secrets.versions
        .access('projects/$gcpProjectId/secrets/$secretName/versions/latest');
    var secretValue = secretResponse.payload!.data!;
    var privateKey = utf8.decode(base64.decode(secretValue));

    var builder = JWTBuilder()
      // GitHub App's identifier
      ..issuer = githubAppId
      // issued at time, 60 seconds in the past to allow for clock drift
      ..issuedAt = DateTime.now().subtract(Duration(seconds: 60))
      // JWT expiration time (10 minute maximum)
      ..expiresAt = DateTime.now().add(Duration(minutes: 10));

    var signer = JWTRsaSha256Signer(privateKey: privateKey);
    var signedJWT = builder.getSignedToken(signer);

    // Use the JWT to request an installation token
    var installationTokenResponse = await post(
        Uri.parse(
            'https://api.github.com/app/installations/$githubAppInstallationId/access_tokens'),
        headers: {
          "Accept": "application/vnd.github.v3+json",
          "Authorization": "Bearer $signedJWT",
        });

    return jsonDecode(installationTokenResponse.body);
  }

  Future<void> validateToken() async {
    if (_tokenExpiry.isBefore(DateTime.now())) {
      var installationTokenJson = await _requestToken(_authClient);
      _installationToken = installationTokenJson['token'] as String;
      _tokenExpiry =
          DateTime.parse(installationTokenJson['expires_at'] as String);
    }
  }

  Future<JsonMap> createRepo(
      {String org = defaultOrg, required String name}) async {
    await validateToken();
    final response =
        await post(Uri.parse('https://api.github.com/orgs/$org/repos'),
            headers: {
              "Accept": "application/vnd.github.v3+json",
              "Authorization": "token $_installationToken",
            },
            body: '{"name":"$name"}');
    return jsonDecode(response.body);
  }

  void dispose() {
    _authClient.close();
  }
}
