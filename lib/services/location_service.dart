import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static const String _apiKey = 'AIzaSyDJAJbvBBkiUSglgMQlStEUHvBQ1nwMfGQ';

  static Future<Map<String, String>> reverseGeocode(LatLng coords) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coords.latitude},${coords.longitude}&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      if (results != null && results.isNotEmpty) {
        final formattedAddress = results[0]['formatted_address'];
        final components = results[0]['address_components'];

        String city = '';
        String country = '';

        for (var comp in components) {
          if (comp['types'].contains('locality')) {
            city = comp['long_name'];
          }
          if (comp['types'].contains('country')) {
            country = comp['long_name'];
          }
        }

        return {
          'locationName': city.isNotEmpty && country.isNotEmpty
              ? '$city, $country'
              : formattedAddress,
          'address': formattedAddress,
        };
      }
    }

    throw Exception("Failed to reverse geocode location");
  }
}
