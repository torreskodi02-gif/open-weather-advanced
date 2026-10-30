import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _geocodeBase = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>?> searchCity(String name) async {
    final uri = Uri.parse(
      '$_geocodeBase?name=${Uri.encodeComponent(name)}&count=1&language=en&format=json',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    if (data['results'] == null || (data['results'] as List).isEmpty) {
      return null;
    }
    return data['results'][0] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    final params = {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,uv_index',
      'hourly': 'temperature_2m,weather_code,precipitation_probability',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '7',
    };
    final uri = Uri.parse(_forecastBase).replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load weather');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
