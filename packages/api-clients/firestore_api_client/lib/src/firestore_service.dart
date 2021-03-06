import 'package:firestore_api_client/src/extensions/json_map_extension.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:json_utils/json_utils.dart';

/// If [api] is omitted, [client] is used to create one, so [client] must be present.
/// If [api] is present, [client] will be ignored and should be ommited.
class FirestoreService {
  FirestoreService(
      {required String projectId,
      AutoRefreshingAuthClient? client,
      FirestoreApi? api})
      : _databaseName = 'projects/' + projectId + '/databases/(default)' {
    _api = api ?? FirestoreApi(client!);
    _docs = _api.projects.databases.documents;
  }

  final String _databaseName;
  late final FirestoreApi _api;
  late final ProjectsDatabasesDocumentsResource _docs;

  Future<Document> setDocument(
          {required String at, required JsonMap to}) async =>
      _docs.createDocument(
        to.toDocument(),
        _databaseName + '/documents',
        at,
      );
}
