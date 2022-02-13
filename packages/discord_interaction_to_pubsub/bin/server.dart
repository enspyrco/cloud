import 'dart:convert';

import 'package:discord_interaction_to_pubsub/typedefs.dart';
import 'package:discord_interaction_to_pubsub/utils/json_utils.dart';
import 'package:discord_interaction_to_pubsub/utils/logging_utils.dart';
import 'package:discord_interaction_to_pubsub/utils/response_utils.dart';
import 'package:discord_interaction_to_pubsub/verify_signature.dart';
import 'package:gcloud/pubsub.dart';
import 'package:shelf/shelf.dart' show Request, Response;
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<Response> handler(Request request) async {
  try {
    String body = await request.readAsString();

    printRequestInfo(request, body);

    if (validSignature(body, request.headers)) {
      var json = jsonDecode(body) as JsonMap;
      print('decoded json:\n$json');

      if (json['type'] == 1) return ackResponse(); // ACK any valid PING

      var expression = extractValue(json);

      var topic = await pubsubService.lookupTopic('dart-code-strings');
      await topic.publishString(expression);

      return respondWait();
    } else {
      return Response(401);
    }
  } catch (e, s) {
    print('Exception:\n$e\n\nTrace:\n$s');
    return Response.internalServerError();
  }
}

void main() {
  shelf_io.serve(handler, '0.0.0.0', 8080).then((server) {
    print('Serving at https://${server.address.host}:${server.port}');
  });
}
