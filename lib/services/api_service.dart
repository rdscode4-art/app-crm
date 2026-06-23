import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leave.dart';
import '../models/lead.dart';
import '../models/document.dart';
import '../models/task.dart';
import '../models/asset.dart';
import '../models/daily_report.dart';
import '../models/user_role_info.dart';

class ApiService {
  static const String baseUrl = 'https://crmb.ridealmobility.com/api';

  // Leaves API
  Future<List<Leave>> fetchLeaves() async {
    final response = await http.get(Uri.parse('$baseUrl/leaves'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Leave.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitLeave(Leave leave) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leaves'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(leave.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Leads API
  Future<List<Lead>> fetchLeads() async {
    final response = await http.get(Uri.parse('$baseUrl/leads'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Lead.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitLead(Lead lead) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leads'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(lead.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Documents API
  Future<List<CRMDocument>> fetchDocuments() async {
    final response = await http.get(Uri.parse('$baseUrl/documents'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => CRMDocument.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitDocument(CRMDocument document) async {
    final response = await http.post(
      Uri.parse('$baseUrl/documents'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(document.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Tasks API
  Future<List<CRMTask>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => CRMTask.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitTask(CRMTask task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Assets API
  Future<List<CRMAsset>> fetchAssets() async {
    final response = await http.get(Uri.parse('$baseUrl/assets'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => CRMAsset.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitAsset(CRMAsset asset) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assets'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(asset.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Daily Reports API
  Future<List<DailyReport>> fetchDailyReports() async {
    final response = await http.get(Uri.parse('$baseUrl/daily-reports'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => DailyReport.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitDailyReport(DailyReport report) async {
    final response = await http.post(
      Uri.parse('$baseUrl/daily-reports'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(report.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Roles API
  Future<List<UserRoleInfo>> fetchRoles() async {
    final response = await http.get(Uri.parse('$baseUrl/roles'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => UserRoleInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitRole(UserRoleInfo role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/roles'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(role.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
