import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';
import '../models/lead.dart';
import '../models/attendance.dart';
import '../models/leave.dart';
import '../models/task.dart';
import '../models/performance.dart';
import '../models/notification.dart';
import '../models/asset.dart';
import '../models/daily_report.dart';
import '../models/user_role_info.dart';
import '../controllers/crm_controller.dart';
import 'api_service.dart';

enum UserRole { superAdmin, hr, employee }

class MockDataService extends ChangeNotifier {
  // Global Singleton
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _initializeData();
  }

  // App State Flags
  bool _isOnboarded = false;
  bool _isLoggedIn = false;
  int _currentMenuIndex = 0; // Sidebar navigation index
  bool _isLoadingLeaves = false;
  String? _leavesError;

  // Auth User Session (Simulated)
  Employee? _currentUser;

  // CRM Data tables
  final List<Employee> _employees = [];
  final List<Lead> _leads = [];
  final List<Attendance> _attendanceLogs = [];
  final List<Leave> _leaveRequests = [];
  final List<CRMTask> _tasks = [];
  final List<Performance> _performanceRecords = [];
  final List<CRMNotification> _notifications = [];
  final List<CRMAsset> _assets = [];
  final List<DailyReport> _dailyReports = [];
  final List<UserRoleInfo> _userRoles = [];

  // Getters
  bool get isOnboarded => _isOnboarded;
  bool get isLoggedIn => _isLoggedIn;
  int get currentMenuIndex => _currentMenuIndex;
  Employee? get currentUser => _currentUser;
  bool get isLoadingLeaves => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().isLoadingLeaves.value
      : _isLoadingLeaves;
  String? get leavesError => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().leavesError.value
      : _leavesError;

  List<Employee> get employees => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().employees
      : List.unmodifiable(_employees);
  List<Lead> get leads => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().leads
      : List.unmodifiable(_leads);
  List<Attendance> get attendanceLogs => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().attendanceLogs
      : List.unmodifiable(_attendanceLogs);
  List<Leave> get leaveRequests => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().leaveRequests
      : List.unmodifiable(_leaveRequests);
  List<CRMTask> get tasks => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().tasks
      : List.unmodifiable(_tasks);
  List<Performance> get performanceRecords => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().performanceReviews
      : List.unmodifiable(_performanceRecords);
  List<CRMNotification> get notifications => List.unmodifiable(_notifications);

  List<CRMAsset> get assets => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().assets
      : List.unmodifiable(_assets);

  List<DailyReport> get dailyReports => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().dailyReports
      : List.unmodifiable(_dailyReports);

  List<UserRoleInfo> get userRoles => Get.isRegistered<CrmController>()
      ? Get.find<CrmController>().userRoles
      : List.unmodifiable(_userRoles);

  UserRole get currentRole {
    if (_currentUser == null) return UserRole.employee;
    final email = _currentUser!.email.toLowerCase();
    final role = _currentUser!.role.toLowerCase();
    final name = _currentUser!.name.toLowerCase();

    if (email.contains("superadmin") || role.contains("super admin") || name.contains("marcus") || email == "marcus.aurelius@company.com") {
      return UserRole.superAdmin;
    } else if (email.contains("admin") || role.contains("hr") || role.contains("director") || name.contains("diana") || email == "diana.prince@company.com") {
      return UserRole.hr;
    } else {
      return UserRole.employee;
    }
  }

  // Computed state for current user
  bool get isPunchedIn {
    if (_currentUser == null) return false;
    final today = DateTime.now();
    return attendanceLogs.any((a) =>
        a.employeeId == _currentUser!.id &&
        a.date.year == today.year &&
        a.date.month == today.month &&
        a.date.day == today.day &&
        a.checkOutTime == null);
  }

  Attendance? get todayAttendance {
    if (_currentUser == null) return null;
    final today = DateTime.now();
    try {
      return attendanceLogs.firstWhere((a) =>
          a.employeeId == _currentUser!.id &&
          a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day &&
          a.checkOutTime == null);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('is_onboarded') ?? false;
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userEmail = prefs.getString('user_email');
    if (_isLoggedIn && userEmail != null) {
      try {
        final user = _employees.firstWhere(
          (e) => e.email.toLowerCase() == userEmail.toLowerCase(),
        );
        _currentUser = user;
      } catch (_) {
        if (userEmail.toLowerCase() == "admin@crm.com") {
          _currentUser = Employee(
            id: "EMP-001",
            name: "Diana Prince",
            email: "admin@crm.com",
            role: "HR Director",
            department: "Human Resources",
            status: "Active",
            salary: 120000,
            performanceRating: 4.9,
            dateJoined: "2024-01-15",
            phone: "+1 555-0199",
            avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
          );
        } else {
          _currentUser = Employee(
            id: prefs.getString('user_id') ?? "EMP-999",
            name: prefs.getString('user_name') ?? "Employee",
            email: userEmail,
            role: prefs.getString('user_role') ?? "Employee",
            department: prefs.getString('user_department') ?? "Ecosystem",
            status: "Active",
            salary: 80000,
            performanceRating: 5.0,
            dateJoined: DateTime.now().toString().split(' ')[0],
            phone: "",
            avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
          );
        }
      }

      final token = prefs.getString('api_token');
      if (token != null) {
        ApiService.token = token;
        if (Get.isRegistered<CrmController>()) {
          Get.find<CrmController>().onTokenLoaded();
        }
      }
    }
    notifyListeners();
  }

  // Setters & Navigation
  void setOnboarded(bool value) async {
    _isOnboarded = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', value);
    notifyListeners();
  }

  void setMenuIndex(int index) {
    _currentMenuIndex = index;
    notifyListeners();
  }

  // Auth Actions
  Future<String?> login(String email, String password) async {
    try {
      final authData = await ApiService().login(email, password);
      final employeeJson = authData['employee'] as Map<String, dynamic>;
      _currentUser = Employee.fromJson(employeeJson);
      _isLoggedIn = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_email', email);
      await prefs.setString('user_id', _currentUser!.id);
      await prefs.setString('user_name', _currentUser!.name);
      await prefs.setString('user_role', _currentUser!.role);
      await prefs.setString('user_department', _currentUser!.department);
      if (ApiService.token != null) {
        await prefs.setString('api_token', ApiService.token!);
        if (Get.isRegistered<CrmController>()) {
          Get.find<CrmController>().onTokenLoaded();
        }
      }
      
      addNotification("Welcome Back!", "You have successfully signed in as ${_currentUser!.name}.");
      notifyListeners();
      return null;
    } catch (e) {
      // Try mock fallback login if the email/password matches a mock employee OR is the admin credentials
      try {
        final user = _employees.firstWhere(
          (e) => e.email.toLowerCase() == email.toLowerCase(),
        );
        _currentUser = user;
        _isLoggedIn = true;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);
        await prefs.setString('user_id', _currentUser!.id);
        await prefs.setString('user_name', _currentUser!.name);
        await prefs.setString('user_role', _currentUser!.role);
        await prefs.setString('user_department', _currentUser!.department);
        if (ApiService.token != null) {
          await prefs.setString('api_token', ApiService.token!);
        }
        
        addNotification("Welcome Back!", "You have successfully signed in as ${user.name} (Mock).");
        notifyListeners();
        return null;
      } catch (_) {
        if (email.toLowerCase() == "admin@crm.com" && password == "admin123") {
          _currentUser = Employee(
            id: "EMP-001",
            name: "Diana Prince",
            email: "admin@crm.com",
            role: "HR Director",
            department: "Human Resources",
            status: "Active",
            salary: 120000,
            performanceRating: 4.9,
            dateJoined: "2024-01-15",
            phone: "+1 555-0199",
            avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
          );
          _isLoggedIn = true;
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('user_email', email);
          await prefs.setString('user_id', _currentUser!.id);
          await prefs.setString('user_name', _currentUser!.name);
          await prefs.setString('user_role', _currentUser!.role);
          await prefs.setString('user_department', _currentUser!.department);
          if (ApiService.token != null) {
            await prefs.setString('api_token', ApiService.token!);
          }
          
          addNotification("Welcome Back!", "Signed in as Diana Prince (HR Director) (Mock).");
          notifyListeners();
          return null;
        }
      }

      String errorMsg = e.toString();
      if (errorMsg.startsWith("Exception: ")) {
        errorMsg = errorMsg.replaceFirst("Exception: ", "");
      }
      return errorMsg;
    }
  }

  void signup(String name, String email, String role, String department, String phone) async {
    final newId = "EMP-00${_employees.length + 1}";
    final newUser = Employee(
      id: newId,
      name: name,
      email: email,
      role: role,
      department: department,
      status: "Active",
      salary: 75000,
      performanceRating: 5.0,
      dateJoined: DateTime.now().toString().split(' ')[0],
      phone: phone,
      avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
    );
    _employees.add(newUser);
    _currentUser = newUser;
    _isLoggedIn = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', newUser.id);
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_role', newUser.role);
    await prefs.setString('user_department', newUser.department);
    
    addNotification("Account Created", "Welcome to CRM, $name! Your profile is ready.");
    notifyListeners();
  }

  void logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _currentMenuIndex = 0;
    ApiService.token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await prefs.remove('user_department');
    await prefs.remove('api_token');
    
    notifyListeners();
  }

  // Employee Actions
  void addEmployee(Employee emp) {
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().submitEmployee(emp);
      addNotification("New Employee Boarded", "${emp.name} has been added to the ${emp.department} department.");
      return;
    }
    _employees.insert(0, emp);
    addNotification("New Employee Boarded", "${emp.name} has been added to the ${emp.department} department.");
    // Auto-create initial performance record
    _performanceRecords.add(Performance(
      id: "PERF-0${_performanceRecords.length + 1}",
      employeeId: emp.id,
      employeeName: emp.name,
      period: "Q2 2026",
      kpiScore: 80.0,
      managerFeedback: "Newly onboarded. Under training.",
      ratingStars: 4,
    ));
    notifyListeners();
  }

  void updateEmployee(Employee updated) {
    final idx = _employees.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _employees[idx] = updated;
      notifyListeners();
    }
  }

  // Lead Actions
  void addLead(Lead lead) {
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().submitLead(lead);
      addNotification("New Sales Lead", "New prospect ${lead.name} from ${lead.company} registered.");
    } else {
      _leads.insert(0, lead);
      addNotification("New Sales Lead", "New prospect ${lead.name} from ${lead.company} registered.");
      notifyListeners();
    }
  }

  void updateLeadStatus(String leadId, String newStatus) {
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().updateLeadStatus(leadId, newStatus);
      addNotification("Lead Progressed", "Lead status updated to: $newStatus.");
    } else {
      final idx = _leads.indexWhere((l) => l.id == leadId);
      if (idx != -1) {
        final oldLead = _leads[idx];
        _leads[idx] = oldLead.copyWith(status: newStatus);
        addNotification("Lead Progressed", "${oldLead.name}'s deal status updated to: $newStatus.");
        notifyListeners();
      }
    }
  }

  // Attendance Actions
  void punchIn() {
    if (_currentUser == null) return;
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().punchIn();
      return;
    }
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 30);

    final log = Attendance(
      id: "ATT-${_attendanceLogs.length + 1}",
      employeeId: _currentUser!.id,
      employeeName: _currentUser!.name,
      date: now,
      checkInTime: timeStr,
      status: isLate ? "Late" : "On Time",
    );
    _attendanceLogs.insert(0, log);
    addNotification("Clock-In Successful", "Punched in at $timeStr. Status: ${log.status}.");
    notifyListeners();
  }

  void punchOut() {
    if (_currentUser == null) return;
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().punchOut();
      return;
    }
    final now = DateTime.now();
    final today = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final idx = _attendanceLogs.indexWhere((a) =>
        a.employeeId == _currentUser!.id &&
        a.date.year == today.year &&
        a.date.month == today.month &&
        a.date.day == today.day &&
        a.checkOutTime == null);

    if (idx != -1) {
      final inLog = _attendanceLogs[idx];
      final inParts = inLog.checkInTime.split(':');
      final inHour = int.parse(inParts[0]);
      final inMin = int.parse(inParts[1]);
      final duration = (now.hour - inHour) + ((now.minute - inMin) / 60.0);

      _attendanceLogs[idx] = inLog.copyWith(
        checkOutTime: timeStr,
        durationHours: double.parse(duration.toStringAsFixed(1)),
      );
      addNotification("Clock-Out Successful", "Punched out at $timeStr. Worked for ${duration.toStringAsFixed(1)} hours.");
      notifyListeners();
    }
  }

  // Leave Actions
  Future<void> fetchLeavesFromApi() async {
    if (Get.isRegistered<CrmController>()) {
      await Get.find<CrmController>().fetchLeaves();
    }
  }

  Future<void> submitLeaveRequest(String type, DateTime start, DateTime end, String reason) async {
    if (_currentUser == null) return;
    if (Get.isRegistered<CrmController>()) {
      await Get.find<CrmController>().submitLeave(
        type,
        start,
        end,
        reason,
        _currentUser!.id,
        _currentUser!.name,
      );
    } else {
      final req = Leave(
        id: "LV-${_leaveRequests.length + 100}",
        employeeId: _currentUser!.id,
        employeeName: _currentUser!.name,
        type: type,
        startDate: start,
        endDate: end,
        reason: reason,
        status: "Pending",
      );
      _leaveRequests.insert(0, req);
      notifyListeners();
    }
  }

  void updateLeaveStatus(String id, String status) {
    final idx = _leaveRequests.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final oldReq = _leaveRequests[idx];
      _leaveRequests[idx] = oldReq.copyWith(status: status);
      addNotification("Leave Request Update", "Your $status status for leave has been updated: $status.");
      notifyListeners();
    }
  }

  // Task Actions
  void addTask(CRMTask task) {
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().submitTask(task);
      addNotification("Task Assigned", "New task '${task.title}' assigned to ${task.assignedTo}.");
    } else {
      _tasks.insert(0, task);
      addNotification("Task Assigned", "New task '${task.title}' assigned to ${task.assignedTo}.");
      notifyListeners();
    }
  }

  void updateTaskStatus(String id, String newStatus) {
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().updateTaskStatus(id, newStatus);
    } else {
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final oldTask = _tasks[idx];
        _tasks[idx] = oldTask.copyWith(status: newStatus);
        notifyListeners();
      }
    }
  }

  // Performance Actions
  void addPerformanceRecord(Performance record) {
    _performanceRecords.insert(0, record);
    addNotification("Performance Review", "A new performance review was added for ${record.employeeName}.");
    notifyListeners();
  }

  // Notifications helper
  void addNotification(String title, String message) {
    _notifications.insert(
      0,
      CRMNotification(
        id: "NOTIF-${_notifications.length + 1}",
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
      ),
    );
    notifyListeners();
  }

  void markNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Initialize Dummy Data
  void _initializeData() {
    // 1. Core Employees
    _employees.addAll([
      Employee(
        id: "EMP-001",
        name: "Diana Prince",
        email: "diana.prince@company.com",
        role: "HR Director",
        department: "Human Resources",
        status: "Active",
        salary: 120000,
        performanceRating: 4.9,
        dateJoined: "2024-01-15",
        phone: "+1 (555) 010-9921",
        avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
      ),
      Employee(
        id: "EMP-002",
        name: "Marcus Aurelius",
        email: "marcus.aurelius@company.com",
        role: "VP of Sales",
        department: "Sales & Marketing",
        status: "Active",
        salary: 110000,
        performanceRating: 4.7,
        dateJoined: "2024-02-10",
        phone: "+1 (555) 014-4421",
        avatarUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150",
      ),
      Employee(
        id: "EMP-003",
        name: "Sarah Jenkins",
        email: "sarah.jenkins@company.com",
        role: "Senior Account Executive",
        department: "Sales & Marketing",
        status: "Active",
        salary: 85000,
        performanceRating: 4.8,
        dateJoined: "2024-05-20",
        phone: "+1 (555) 018-9932",
        avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150",
      ),
      Employee(
        id: "EMP-004",
        name: "David Chen",
        email: "david.chen@company.com",
        role: "Customer Success Lead",
        department: "Customer Relations",
        status: "Active",
        salary: 80000,
        performanceRating: 4.4,
        dateJoined: "2024-08-11",
        phone: "+1 (555) 021-9988",
        avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
      ),
      Employee(
        id: "EMP-005",
        name: "Elena Rostova",
        email: "elena.rostova@company.com",
        role: "HR Generalist",
        department: "Human Resources",
        status: "Active",
        salary: 70000,
        performanceRating: 4.5,
        dateJoined: "2025-01-08",
        phone: "+1 (555) 032-4411",
        avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
      ),
    ]);

    // Initial default user session
    _currentUser = _employees[0];

    // 2. Sales Leads
    _leads.addAll([
      Lead(
        id: "LD-101",
        name: "Robert Downey",
        company: "Stark Industries",
        email: "tony@stark.com",
        phone: "+1 (555) 911-3000",
        value: 45000.00,
        status: "Won",
        source: "Website",
        dateCreated: DateTime.now().subtract(const Duration(days: 30)),
        owner: "Sarah Jenkins",
      ),
      Lead(
        id: "LD-102",
        name: "Bruce Wayne",
        company: "Wayne Enterprises",
        email: "bruce@wayne.com",
        phone: "+1 (555) 443-1200",
        value: 120000.00,
        status: "Proposal",
        source: "Referral",
        dateCreated: DateTime.now().subtract(const Duration(days: 15)),
        owner: "Marcus Aurelius",
      ),
      Lead(
        id: "LD-103",
        name: "Clark Kent",
        company: "Daily Planet",
        email: "clark@dailyplanet.com",
        phone: "+1 (555) 902-8833",
        value: 15000.00,
        status: "Contacted",
        source: "LinkedIn",
        dateCreated: DateTime.now().subtract(const Duration(days: 10)),
        owner: "Sarah Jenkins",
      ),
      Lead(
        id: "LD-104",
        name: "Steve Rogers",
        company: "Shield Corp",
        email: "steve@shield.gov",
        phone: "+1 (555) 177-6600",
        value: 30000.00,
        status: "New",
        source: "Cold Call",
        dateCreated: DateTime.now().subtract(const Duration(days: 2)),
        owner: "David Chen",
      ),
      Lead(
        id: "LD-105",
        name: "Peter Parker",
        company: "Daily Bugle",
        email: "peter@bugle.com",
        phone: "+1 (555) 232-1100",
        value: 5000.00,
        status: "Lost",
        source: "Website",
        dateCreated: DateTime.now().subtract(const Duration(days: 40)),
        owner: "David Chen",
      ),
    ]);

    // 3. Tasks
    _tasks.addAll([
      CRMTask(
        id: "TSK-201",
        title: "Send Proposal to Bruce Wayne",
        description: "Draft Enterprise SLA package for Wayne Enterprises smart grid integration and email PDF.",
        assignedTo: "Marcus Aurelius",
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: "High",
        status: "In Progress",
      ),
      CRMTask(
        id: "TSK-202",
        title: "Onboard Elena Rostova",
        description: "Arrange orientation session, workspace setup, and system login credentials.",
        assignedTo: "Diana Prince",
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        priority: "Medium",
        status: "Done",
      ),
      CRMTask(
        id: "TSK-203",
        title: "Schedule Call with Clark Kent",
        description: "Initial introductory call to understand Daily Planet CRM scalability needs.",
        assignedTo: "Sarah Jenkins",
        dueDate: DateTime.now().add(const Duration(days: 5)),
        priority: "Low",
        status: "Todo",
      ),
      CRMTask(
        id: "TSK-204",
        title: "Review Quarterly Leave Reports",
        description: "HR alignment check on casual/annual leave balances before the end of the half-year.",
        assignedTo: "Diana Prince",
        dueDate: DateTime.now().add(const Duration(days: 3)),
        priority: "High",
        status: "Review",
      ),
    ]);

    // 4. Attendance
    _attendanceLogs.addAll([
      Attendance(
        id: "ATT-10",
        employeeId: "EMP-001",
        employeeName: "Diana Prince",
        date: DateTime.now().subtract(const Duration(days: 1)),
        checkInTime: "08:45",
        checkOutTime: "17:30",
        durationHours: 8.8,
        status: "On Time",
      ),
      Attendance(
        id: "ATT-11",
        employeeId: "EMP-002",
        employeeName: "Marcus Aurelius",
        date: DateTime.now().subtract(const Duration(days: 1)),
        checkInTime: "09:42",
        checkOutTime: "18:00",
        durationHours: 8.3,
        status: "Late",
      ),
      Attendance(
        id: "ATT-12",
        employeeId: "EMP-003",
        employeeName: "Sarah Jenkins",
        date: DateTime.now().subtract(const Duration(days: 1)),
        checkInTime: "08:55",
        checkOutTime: "17:00",
        durationHours: 8.1,
        status: "On Time",
      ),
    ]);

    // 5. Leaves
    _leaveRequests.addAll([
      Leave(
        id: "LV-100",
        employeeId: "EMP-003",
        employeeName: "Sarah Jenkins",
        type: "Annual",
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        reason: "Family summer vacation cruise",
        status: "Approved",
      ),
      Leave(
        id: "LV-101",
        employeeId: "EMP-004",
        employeeName: "David Chen",
        type: "Sick",
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().subtract(const Duration(days: 4)),
        reason: "Dental wisdom teeth surgery extraction",
        status: "Approved",
      ),
      Leave(
        id: "LV-102",
        employeeId: "EMP-005",
        employeeName: "Elena Rostova",
        type: "Casual",
        startDate: DateTime.now().add(const Duration(days: 4)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        reason: "Moving house/apartment settling",
        status: "Pending",
      ),
    ]);

    // 6. Performance Records
    _performanceRecords.addAll([
      Performance(
        id: "PERF-101",
        employeeId: "EMP-001",
        employeeName: "Diana Prince",
        period: "Q1 2026",
        kpiScore: 98.0,
        managerFeedback: "Excellent HR administration, managed onboarding of 3 key additions seamlessly.",
        ratingStars: 5,
      ),
      Performance(
        id: "PERF-102",
        employeeId: "EMP-002",
        employeeName: "Marcus Aurelius",
        period: "Q1 2026",
        kpiScore: 92.5,
        managerFeedback: "Exceeded team sales revenue goals by 15%. Exemplary leadership.",
        ratingStars: 5,
      ),
      Performance(
        id: "PERF-103",
        employeeId: "EMP-003",
        employeeName: "Sarah Jenkins",
        period: "Q1 2026",
        kpiScore: 89.0,
        managerFeedback: "Consistent performer, excellent lead conversion speed. Keep it up.",
        ratingStars: 4,
      ),
    ]);

    // 7. Initial notifications
    _notifications.addAll([
      CRMNotification(
        id: "NOTIF-1",
        title: "App Initialized",
        message: "CRM database and structures have successfully loaded.",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      CRMNotification(
        id: "NOTIF-2",
        title: "Leave Pending Approval",
        message: "Elena Rostova requested 1-day Casual leave. Check Leaves screen.",
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
    ]);

    // 8. Assets
    _assets.addAll([
      CRMAsset(
        id: "AST-101",
        name: "MacBook Pro 16\"",
        serialNumber: "C02DF123Q05D",
        category: "Laptop",
        assignedTo: "Diana Prince",
        status: "Assigned",
        dateAssigned: DateTime.now().subtract(const Duration(days: 120)),
      ),
      CRMAsset(
        id: "AST-102",
        name: "iPhone 15 Pro",
        serialNumber: "IMEI88273618",
        category: "Phone",
        assignedTo: "Marcus Aurelius",
        status: "Assigned",
        dateAssigned: DateTime.now().subtract(const Duration(days: 90)),
      ),
      CRMAsset(
        id: "AST-103",
        name: "Dell UltraSharp 27\"",
        serialNumber: "CN-0F142D-728",
        category: "Accessory",
        assignedTo: "Sarah Jenkins",
        status: "Assigned",
        dateAssigned: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ]);

    // 9. Daily Reports
    _dailyReports.addAll([
      DailyReport(
        id: "REP-001",
        employeeName: "Diana Prince",
        date: DateTime.now().subtract(const Duration(days: 1)),
        summary: "Completed HR onboarding guidelines draft and reviewed leave approval queues.",
        tasksCompleted: "Onboarded Elena, Reviewed Leave balance reports",
        blocks: "None",
        status: "approved",
        hoursWorked: 8.5,
        reviewNote: "Great progress, guidelines look ready.",
        reviewedByName: "Marcus Aurelius",
      ),
      DailyReport(
        id: "REP-002",
        employeeName: "Marcus Aurelius",
        date: DateTime.now().subtract(const Duration(days: 1)),
        summary: "Conducted sales alignment meetings and updated the proposal pipelines.",
        tasksCompleted: "Stark Proposal draft, Wayne proposal sent",
        blocks: "Awaiting legal signature from Stark team",
        status: "reviewed",
        hoursWorked: 9.0,
        reviewNote: "Good work. Keep pressure on Stark's team.",
        reviewedByName: "Diana Prince",
      ),
      DailyReport(
        id: "REP-003",
        employeeName: "Sarah Jenkins",
        date: DateTime.now().subtract(const Duration(days: 1)),
        summary: "Followed up with Kent regarding CRM customization scope.",
        tasksCompleted: "Kent call completed, CRM scopes documented",
        blocks: "Waiting on Clark's confirmation on user count",
        status: "submitted",
        hoursWorked: 7.5,
      ),
    ]);

    // 10. User Roles Listing
    _userRoles.addAll([
      UserRoleInfo(id: "EMP-001", name: "Diana Prince", email: "diana.prince@company.com", role: "HR Director"),
      UserRoleInfo(id: "EMP-002", name: "Marcus Aurelius", email: "marcus.aurelius@company.com", role: "VP of Sales"),
      UserRoleInfo(id: "EMP-003", name: "Sarah Jenkins", email: "sarah.jenkins@company.com", role: "Senior Account Executive"),
      UserRoleInfo(id: "EMP-004", name: "David Chen", email: "david.chen@company.com", role: "Customer Success Lead"),
      UserRoleInfo(id: "EMP-005", name: "Elena Rostova", email: "elena.rostova@company.com", role: "HR Generalist"),
    ]);
  }
}
