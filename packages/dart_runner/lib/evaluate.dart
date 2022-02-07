import 'dart:isolate';

dynamic evaluate(String codeString) async {
  final uri = Uri.dataFromString(
    '''
    import "dart:isolate";

    void main(_, SendPort port) {
      
      port.send($codeString);
    }
    ''',
    mimeType: 'application/dart',
  );

  final port = ReceivePort();
  final isolate = await Isolate.spawnUri(uri, [], port.sendPort);
  final dynamic response = await port.first;

  port.close();
  isolate.kill();

  return response;
}
