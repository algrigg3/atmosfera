import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // To detect file type
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dlvll78b';
  static const String uploadPreset = 'atmosfera_upload';

  //Uploads an image to Cloudinary
  static Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    imageUploadRequest.fields['upload_preset'] = uploadPreset;

    //Attach the image file
    imageUploadRequest.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : MediaType('image', 'jpeg'), //fallback
      ),
    );

    try {
      final response = await imageUploadRequest.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decoded = json.decode(responseData);
        print('Upload successful: $decoded');
        return decoded;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }
}
