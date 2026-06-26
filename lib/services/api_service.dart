import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leave.dart';
import '../models/lead.dart';
import '../models/document.dart';
import '../models/task.dart';
import '../models/asset.dart';
import '../models/daily_report.dart';
import '../models/user_role_info.dart';
import '../models/performance.dart';
import '../models/payroll.dart';
import '../models/attendance.dart';
import '../models/employee.dart';

class ApiService {
  static const String baseUrl = 'https://crmb.ridealmobility.com/api';
  static String? token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Auth API
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData['success'] == true && responseData['data'] != null) {
        token = responseData['data']['token'];
        return responseData['data'];
      }
      throw Exception(responseData['message'] ?? 'Login failed');
    } else {
      throw Exception(responseData['message'] ?? 'Login failed with status code ${response.statusCode}');
    }
  }

  // Leaves API
  Future<List<Leave>> fetchLeaves() async {
    final response = await http.get(Uri.parse('$baseUrl/leaves'), headers: _headers);
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
      headers: _headers,
      body: json.encode(leave.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Leads API
  Future<List<Lead>> fetchLeads() async {
    final response = await http.get(Uri.parse('$baseUrl/leads'), headers: _headers);
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
      headers: _headers,
      body: json.encode(lead.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Documents API
  Future<List<CRMDocument>> fetchDocuments({String? documentType}) async {
    String url = '$baseUrl/documents';
    if (documentType != null && documentType != 'All' && documentType.isNotEmpty) {
      url += '?documentType=${Uri.encodeComponent(documentType)}';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
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
      headers: _headers,
      body: json.encode(document.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Tasks API
  Future<List<CRMTask>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'), headers: _headers);
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
      headers: _headers,
      body: json.encode(task.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Assets API
  Future<List<CRMAsset>> fetchAssets() async {
    final response = await http.get(Uri.parse('$baseUrl/assets'), headers: _headers);
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
      headers: _headers,
      body: json.encode(asset.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Daily Reports API
  Future<List<DailyReport>> fetchDailyReports() async {
    return fetchAllDailyReports();
  }

  Future<List<DailyReport>> fetchMyDailyReports({String? from, String? to, int page = 1, int limit = 20}) async {
    final queryParams = 'page=$page&limit=$limit${from != null && from.isNotEmpty ? "&from=$from" : ""}${to != null && to.isNotEmpty ? "&to=$to" : ""}';
    final response = await http.get(Uri.parse('$baseUrl/daily-reports/my?$queryParams'), headers: _headers);
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

  Future<DailyReport> fetchDailyReportDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/daily-reports/$id'), headers: _headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) {
        return DailyReport.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<List<DailyReport>> fetchAllDailyReports({String? employeeId, String? from, String? to, int page = 1, int limit = 20}) async {
    final queryParams = 'page=$page&limit=$limit${employeeId != null && employeeId.isNotEmpty ? "&employeeId=$employeeId" : ""}${from != null && from.isNotEmpty ? "&from=$from" : ""}${to != null && to.isNotEmpty ? "&to=$to" : ""}';
    final response = await http.get(Uri.parse('$baseUrl/daily-reports?$queryParams'), headers: _headers);
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
      headers: _headers,
      body: json.encode(report.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> reviewDailyReport(String id, String status, String reviewNote) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/daily-reports/$id/review'),
      headers: _headers,
      body: json.encode({
        'status': status,
        'reviewNote': reviewNote,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Roles API
  Future<List<UserRoleInfo>> fetchRoles() async {
    final response = await http.get(Uri.parse('$baseUrl/roles'), headers: _headers);
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
      headers: _headers,
      body: json.encode(role.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Performance API
  Future<List<Performance>> fetchPerformanceReviews() async {
    final response = await http.get(Uri.parse('$baseUrl/performance'), headers: _headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Performance.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> submitPerformanceReview(Performance review) async {
    final response = await http.post(
      Uri.parse('$baseUrl/performance'),
      headers: _headers,
      body: json.encode(review.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Payroll API
  Future<List<CRMPayroll>> fetchPayrolls({int? year, int? month}) async {
    String url = '$baseUrl/payroll';
    List<String> params = [];
    if (year != null) params.add('year=$year');
    if (month != null) params.add('month=$month');
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => CRMPayroll.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  // Attendance API
  Future<List<Attendance>> fetchAttendance({String? startDate, String? endDate}) async {
    String url = '$baseUrl/attendance';
    List<String> params = [];
    if (startDate != null) params.add('startDate=$startDate');
    if (endDate != null) params.add('endDate=$endDate');
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Attendance.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid API response structure');
    }
    throw Exception('Server returned status code ${response.statusCode}');
  }

  Future<bool> punchIn() async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance/checkin'),
      headers: _headers,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> punchOut() async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance/checkout'),
      headers: _headers,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Employees API
  Future<List<Employee>> fetchEmployees() async {
    int retries = 3;
    while (retries > 0) {
      final client = http.Client();
      try {
        final response = await client.get(
          Uri.parse('$baseUrl/employees'),
          headers: {
            ..._headers,
            'Connection': 'close',
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['success'] == true && data['data'] is List) {
            return (data['data'] as List)
                .map((item) => Employee.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          throw Exception('Invalid API response structure');
        }
        throw Exception('Server returned status code ${response.statusCode}');
      } catch (e) {
        retries--;
        if (retries == 0) {
          rethrow;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      } finally {
        client.close();
      }
    }
    throw Exception('Failed to fetch employees');
  }

  Future<bool> submitEmployee(Employee employee) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employees'),
      headers: _headers,
      body: json.encode({
        'name': employee.name,
        'email': employee.email,
        'role': employee.role,
        'department': employee.department,
        'status': employee.status.toLowerCase(),
        'salary': employee.salary,
        'phone': employee.phone,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
