import 'package:dart_runner/evaluate.dart';
import 'package:shelf/shelf.dart' show Request, Response;
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<Response> handler(Request request) async {
  try {
    String expression = '...'; // get this from pubsub message

    String result = await evaluate(expression);

    // send a  pubsub message
    print(result);

    return Response.ok('...');
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
