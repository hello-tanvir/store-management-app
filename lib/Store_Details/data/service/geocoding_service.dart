import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<String?> getAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?lat=$latitude'
            '&lon=$longitude'
            '&format=json'
            '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'StoreManagementApp/1.0',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      final address = data['address'];

      if (address == null) {
        return null;
      }

      final parts = <String>[];

      void addPart(dynamic value) {
        if (value != null &&
            value.toString().trim().isNotEmpty) {
          parts.add(value.toString().trim());
        }
      }

      addPart(address['quarter']);
      addPart(address['suburb']);
      addPart(address['city']);
      addPart(address['state']);
      addPart(address['postcode']);
      addPart(address['country']);

      if (parts.isEmpty) {
        return data['display_name']?.toString();
      }

      return parts.join(', ');
    } catch (e) {
      return null;
    }
  }
}