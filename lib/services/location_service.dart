import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service để detect location của user dựa trên IP address
/// Đơn giản, không cần permissions, chỉ cần internet
class LocationService {
  /// API endpoint để lấy thông tin IP
  static const String _apiUrl = 'http://ip-api.com/json';

  /// Timeout cho API request (10 giây)
  static const Duration _timeout = Duration(seconds: 10);

  /// Kiểm tra user có ở Việt Nam không (dựa trên IP)
  ///
  /// Returns:
  /// - true: User ở Việt Nam
  /// - false: User ở nước ngoài hoặc không detect được
  ///
  /// Example:
  /// ```dart
  /// bool isInVN = await LocationService.isUserInVietnam();
  /// if (isInVN) {
  ///   print('User ở Việt Nam');
  /// }
  /// ```
  static Future<bool> isUserInVietnam() async {
    try {
      print('🌍 Đang detect location...');

      // Gọi API để lấy thông tin country
      final response = await http.get(Uri.parse(_apiUrl)).timeout(_timeout);

      // Check response status
      if (response.statusCode == 200) {
        // Parse JSON response
        final data = jsonDecode(response.body);

        // Lấy country code
        final String? countryCode = data['countryCode'] as String?;
        final String? country = data['country'] as String?;
        final String? city = data['city'] as String?;

        // Log thông tin
        print('📍 Country: $country ($countryCode)');
        print('🏙️ City: $city');

        // Kiểm tra nếu country code là VN
        final bool isVietnam = countryCode == 'VN';
        // print('✅ Ở Việt Nam: $isVietnam');

        return isVietnam;
      } else {
        // print('⚠️ API error: Status ${response.statusCode}');
        return false; // Default: không phải VN
      }
    } catch (e) {
      // print('❌ Error detecting location: $e');
      return false; // Default: không phải VN nếu có lỗi
    }
  }

  /// Lấy country code của user
  ///
  /// Returns:
  /// - String: Country code (VN, US, JP, etc.)
  /// - 'UNKNOWN': Nếu không detect được
  ///
  /// Example:
  /// ```dart
  /// String code = await LocationService.getCountryCode();
  /// print('Country code: $code'); // VN, US, JP, etc.
  /// ```
  static Future<String> getCountryCode() async {
    try {
      // print('🌍 Đang lấy country code...');

      final response = await http.get(Uri.parse(_apiUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String countryCode = data['countryCode'] as String? ?? 'UNKNOWN';

        // print('✅ Country code: $countryCode');
        return countryCode;
      }

      // print('⚠️ Không lấy được country code');
      return 'UNKNOWN';
    } catch (e) {
      // print('❌ Error getting country code: $e');
      return 'UNKNOWN';
    }
  }

  /// Lấy thông tin location đầy đủ
  ///
  /// Returns Map với các thông tin:
  /// - country: Tên quốc gia
  /// - countryCode: Mã quốc gia (VN, US, etc.)
  /// - city: Thành phố
  /// - regionName: Tên vùng
  /// - isp: Nhà mạng
  /// - query: IP address
  ///
  /// Example:
  /// ```dart
  /// Map<String, dynamic> info = await LocationService.getFullLocationInfo();
  /// print('Country: ${info['country']}');
  /// print('City: ${info['city']}');
  /// ```
  static Future<Map<String, dynamic>> getFullLocationInfo() async {
    try {
      // print('🌍 Đang lấy thông tin location đầy đủ...');

      final response = await http.get(Uri.parse(_apiUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // print('✅ Location info:');
        // print('   Country: ${data['country']}');
        // print('   City: ${data['city']}');
        // print('   Region: ${data['regionName']}');
        // print('   ISP: ${data['isp']}');

        return data;
      }

      return {'error': 'Failed to get location info'};
    } catch (e) {
      // print('❌ Error getting location info: $e');
      return {'error': e.toString()};
    }
  }

  /// Check user có ở một list các quốc gia không
  ///
  /// Parameters:
  /// - countryCodes: List các country code cần check (VD: ['VN', 'TH', 'LA'])
  ///
  /// Returns:
  /// - true: User ở trong list
  /// - false: User không ở trong list
  ///
  /// Example:
  /// ```dart
  /// bool isInSEA = await LocationService.isUserInCountries(['VN', 'TH', 'LA', 'KH']);
  /// if (isInSEA) {
  ///   print('User ở Đông Nam Á');
  /// }
  /// ```
  static Future<bool> isUserInCountries(List<String> countryCodes) async {
    try {
      final String currentCountry = await getCountryCode();
      return countryCodes.contains(currentCountry);
    } catch (e) {
      // print('❌ Error checking countries: $e');
      return false;
    }
  }
}
