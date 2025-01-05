import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class BackblazeService {
  final String keyId;
  final String applicationKey;
  final String bucketId;
  final String bucketName;

  BackblazeService({
    required this.keyId,
    required this.applicationKey,
    required this.bucketId,
    required this.bucketName,
  });

  // Authorize with Backblaze
  Future<Map<String, String>> authorizeAccount() async {
    final String credentials = base64Encode(utf8.encode('$keyId:$applicationKey'));
    final response = await http.get(
      Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
      headers: {'Authorization': 'Basic $credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'apiUrl': data['apiUrl'],
        'authorizationToken': data['authorizationToken'],
      };
    } else {
      throw Exception('Failed to authorize account: ${response.body}');
    }
  }

  // Upload Image
  Future<String> uploadFile(File file) async {
    final auth = await authorizeAccount();
    final uploadUrlResponse = await http.post(
      Uri.parse('${auth['apiUrl']}/b2api/v2/b2_get_upload_url'),
      headers: {
        'Authorization': auth['authorizationToken']!,
      },
      body: jsonEncode({'bucketId': bucketId}),
    );

    if (uploadUrlResponse.statusCode == 200) {
      final uploadData = jsonDecode(uploadUrlResponse.body);
      final uploadUrl = uploadData['uploadUrl'];
      final uploadAuthToken = uploadData['authorizationToken'];

      final uploadResponse = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Authorization': uploadAuthToken!,
          'X-Bz-File-Name': file.uri.pathSegments.last,
          'Content-Type': 'b2/x-auto',
          'X-Bz-Content-Sha1': 'do_not_verify',
        },
        body: file.readAsBytesSync(),
      );

      if (uploadResponse.statusCode == 200) {
        final fileData = jsonDecode(uploadResponse.body);
        return '${auth['apiUrl']}/file/$bucketName/${fileData['fileName']}';
      } else {
        throw Exception('File upload failed: ${uploadResponse.body}');
      }
    } else {
      throw Exception('Failed to get upload URL: ${uploadUrlResponse.body}');
    }
  }
}
