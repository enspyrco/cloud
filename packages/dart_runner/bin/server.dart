import 'dart:convert';

import 'package:dart_runner/typedefs.dart';
import 'package:dart_runner/verify_signature.dart';
import 'package:shelf/shelf.dart' show Request, Response;
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<Response> handler(Request request) async {
  try {
    String body = await request.readAsString();

    if (validSignature(body, request.headers)) {
      // Server should ACK any valid PING
      var json = jsonDecode(body) as JsonMap;
      if (json['type'] == 1) {
        return Response.ok(jsonEncode({'type': 1}),
            headers: {'Content-type': 'application/json'});
      }
      return Response.ok(
          jsonEncode({
            'type': 4,
            'data': {
              'tts': false,
              'content': 'Congrats on sending your command!',
              'embeds': [],
              'allowed_mentions': {'parse': []}
            }
          }),
          headers: {'Content-type': 'application/json'});
    } else {
      return Response(401);
    }
  } catch (e) {
    return Response.internalServerError();
  }
}

void main() {
  shelf_io.serve(handler, '0.0.0.0', 8080).then((server) {
    print('Serving at https://${server.address.host}:${server.port}');
  });
}
