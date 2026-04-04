import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'app_strings.dart';

class WeatherService {
  static const double _fallbackLat = 28.6139;
  static const double _fallbackLon = 77.2090;

  static Future<Map<String, dynamic>?> getWeatherForCurrentLocation({
    String languageCode = 'hi',
  }) async {
    final location = await _resolveLocation(languageCode: languageCode);
    final weather = await getWeather(
      lat: location.latitude,
      lon: location.longitude,
      languageCode: languageCode,
    );
    if (weather == null) {
      return null;
    }

    String locationLabel = location.label;
    if (!location.isFallback) {
      final resolvedLabel = await _reverseGeocodeLabel(
        latitude: location.latitude,
        longitude: location.longitude,
        languageCode: languageCode,
      );
      if (resolvedLabel != null && resolvedLabel.isNotEmpty) {
        locationLabel = resolvedLabel;
      }
    }

    return {
      ...weather,
      'locationLabel': locationLabel,
      'isFallback': location.isFallback,
    };
  }

  static Future<Map<String, dynamic>?> getWeather({
    required double lat,
    required double lon,
    String languageCode = 'hi',
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
        'description': AppStrings.weatherDescription(languageCode, weatherCode),
        'emoji': _weatherEmoji(weatherCode),
      };
    } catch (_) {
      return null;
    }
  }

  static Future<_ResolvedLocation> _resolveLocation({
    required String languageCode,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _ResolvedLocation(
          latitude: _fallbackLat,
          longitude: _fallbackLon,
          label: AppStrings.t(languageCode, 'locationOff'),
          isFallback: true,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _ResolvedLocation(
          latitude: _fallbackLat,
          longitude: _fallbackLon,
          label: AppStrings.t(languageCode, 'locationPermissionDenied'),
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
        label: AppStrings.t(languageCode, 'yourLocation'),
        isFallback: false,
      );
    } catch (_) {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return _ResolvedLocation(
          latitude: lastKnownPosition.latitude,
          longitude: lastKnownPosition.longitude,
          label: AppStrings.t(languageCode, 'lastKnownLocation'),
          isFallback: false,
        );
      }

      return _ResolvedLocation(
        latitude: _fallbackLat,
        longitude: _fallbackLon,
        label: AppStrings.t(languageCode, 'defaultLocation'),
        isFallback: true,
      );
    }
  }

  static Future<String?> _reverseGeocodeLabel({
    required double latitude,
    required double longitude,
    required String languageCode,
  }) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '10',
          'addressdetails': '1',
          'accept-language': languageCode,
        },
      );

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'AgriShieldApp/1.0',
        },
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) return null;

      final locality = _firstNonEmpty(<dynamic>[
        address['city'],
        address['town'],
        address['village'],
        address['municipality'],
        address['county'],
        address['state_district'],
        address['suburb'],
      ]);
      final state = _firstNonEmpty(<dynamic>[
        address['state'],
        address['region'],
      ]);

      if (locality != null && state != null && locality != state) {
        return '$locality, $state';
      }
      return locality ?? state;
    } catch (_) {
      return null;
    }
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
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
