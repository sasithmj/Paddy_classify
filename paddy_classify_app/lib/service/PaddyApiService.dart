import 'dart:convert';
import 'package:http/http.dart' as http;

class PaddyApiService {
  static const String baseUrl = 'https://paddykbs-production.up.railway.app';

  // 1. Submit user input (POST)
  static Future<Map<String, dynamic>> submitUserInput({
    required String disease,
    required int budget,
    required String location,
    required String controlMethod,
  }) async {
    final url = Uri.parse('$baseUrl/submit-input');

    final body = {
      "disease": disease,
      "budget": budget,
      "location": location,
      "controlMethod": controlMethod,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit user input: ${response.statusCode}');
    }
  }

  // 2. Get general treatments for a user input (GET)
  static Future<List<dynamic>> getUserGeneralTreatments(
      String instanceId) async {
    final url = Uri.parse('$baseUrl/user/$instanceId/general-treatments');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to get general treatments: ${response.statusCode}');
    }
  }

  // 3. Get disease agent info (GET)
  static Future<List<dynamic>> getDiseaseAgent(String disease) async {
    final url = Uri.parse('$baseUrl/disease-agent/$disease');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get disease agent: ${response.statusCode}');
    }
  }

  // 4. Get disease details for user input (GET)
  static Future<List<dynamic>> getUserDiseaseDetails(String instanceId) async {
    final url = Uri.parse('$baseUrl/user/$instanceId/disease-details');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to get user disease details: ${response.statusCode}');
    }
  }

  // 5. Get disease environment info (GET)
  static Future<List<dynamic>> getDiseaseEnvironment(String disease) async {
    final url = Uri.parse('$baseUrl/disease-environment/$disease');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to get disease environment: ${response.statusCode}');
    }
  }

  // 6. Get suitable treatments for user input (GET)
  static Future<List<dynamic>> getSuitableTreatments(String instanceId) async {
    final url = Uri.parse('$baseUrl/user/$instanceId/r-treatments-suitable');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      // Return empty list if no treatments are available
      return [];
    }
  }

  // 7. Get general guidelines (GET)
  static Future<List<dynamic>> getGeneralGuidelines() async {
    final url = Uri.parse('$baseUrl/general-guidelines');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to get general guidelines: ${response.statusCode}');
    }
  }
}
