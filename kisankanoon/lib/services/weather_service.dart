import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Free Open-Meteo API — no key needed
  static Future<Map<String, dynamic>?> getWeather({
    double lat = 28.6139, // Default: Delhi
    double lon = 77.2090,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m'
        '&timezone=Asia/Kolkata',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final data = json.decode(resp.body);
      final current = data['current'] as Map<String, dynamic>;
      return {
        'temp': current['temperature_2m'],
        'windspeed': current['windspeed_10m'],
        'humidity': current['relativehumidity_2m'],
        'code': current['weathercode'],
        'description': _weatherDesc(current['weathercode'] as int),
        'emoji': _weatherEmoji(current['weathercode'] as int),
      };
    } catch (_) {
      return null;
    }
  }

  static String _weatherDesc(int code) {
    if (code == 0) return 'साफ आसमान';
    if (code <= 3) return 'आंशिक बादल';
    if (code <= 48) return 'धुंध';
    if (code <= 67) return 'बारिश';
    if (code <= 77) return 'बर्फबारी';
    if (code <= 82) return 'भारी बारिश';
    return 'तूफ़ान';
  }

  static String _weatherEmoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '⛈️';
    return '🌪️';
  }
}
