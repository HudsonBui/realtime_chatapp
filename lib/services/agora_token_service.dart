import 'package:http/http.dart' as http;

Future<String> getAgoraToken(channelName, uid) async {
  print(
      ' (agora_token_services - getAgoraToken) channelName: $channelName, uid: $uid');
  //For android emulator
  final response = await http.get(Uri.parse(
      'http://10.0.2.2:8080/rtcToken?channelName=$channelName&uid=$uid'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    print('Failed to get token: ${response.statusCode}, ${response.body}');
    throw Exception('Failed to get token: ${response.statusCode}');
  }
}
