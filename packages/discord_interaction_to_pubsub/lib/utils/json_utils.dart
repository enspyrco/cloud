// Extract the incoming value from the json in the body
import '../typedefs.dart';

String extractValue(JsonMap json) {
  var data = json['data'] as JsonMap;
  var options = data['options'] as JsonList;
  var option = options.first as JsonMap;
  return option['value'] as String;
}
