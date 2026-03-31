import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const double _fallbackLat = 28.6139;
  static const double _fallbackLon = 77.2090;
  static const String _fallbackLabel = 'डिफ़ॉल्ट स्थान';

  static Future<Map<String, dynamic>?> getWeatherForCurrentLocation() async {
    final location = await _resolveLocation();
    final weather = await getWeather(
      lat: location.latitude,
      lon: location.longitude,
    );
    if (weather == null) {
      return null;
    }

    return {
      ...weather,
      'locationLabel': location.label,
      'isFallback': location.isFallback,
    };
  }

  static Future<Map<String, dynamic>?> getWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m'
        '&timezone=Asia/Kolkata',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>;
      final weatherCode = (current['weathercode'] as num).toInt();

      return {
        'temp': (current['temperature_2m'] as num).toDouble(),
        'windspeed': (current['windspeed_10m'] as num).toDouble(),
        'humidity': current['relativehumidity_2m'],
        'code': weatherCode,
        'description': _weatherDesc(weatherCode),
        'emoji': _weatherEmoji(weatherCode),
      };
    } catch (_) {
      return null;
    }
  }

  static Future<_ResolvedLocation> _resolveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const _ResolvedLocation(
          latitude: _fallbackLat,
          longitude: _fallbackLon,
          label: 'लोकेशन बंद है',
          isFallback: true,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const _ResolvedLocation(
          latitude: _fallbackLat,
          longitude: _fallbackLon,
          label: 'लोकेशन अनुमति नहीं मिली',
          isFallback: true,
        );
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));

      return _ResolvedLocation(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        label: 'आपकी लोकेशन',
        isFallback: false,
      );
    } catch (_) {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return _ResolvedLocation(
          latitude: lastKnownPosition.latitude,
          longitude: lastKnownPosition.longitude,
          label: 'पिछली लोकेशन',
          isFallback: false,
        );
      }

      return const _ResolvedLocation(
        latitude: _fallbackLat,
        longitude: _fallbackLon,
        label: _fallbackLabel,
        isFallback: true,
      );
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

class _ResolvedLocation {
  final double latitude;
  final double longitude;
  final String label;
  final bool isFallback;

  const _ResolvedLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.isFallback,
  });
}
