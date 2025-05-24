import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dqlvshdhp';
  static const String uploadPreset = 'algrinova_upload';

  static Future<String?> uploadImageToCloudinary(File imageFile) async {
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final jsonResponse = json.decode(res);
      return jsonResponse['secure_url'];
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }
}

