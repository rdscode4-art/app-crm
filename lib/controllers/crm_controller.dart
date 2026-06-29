import 'package:get/get.dart';
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
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class CrmController extends GetxController {
  final ApiService _apiService = ApiService();

  // Leaves state
  final RxList<Leave> leaveRequests = <Leave>[].obs;
  final RxBool isLoadingLeaves = false.obs;
  final RxnString leavesError = RxnString();

  // Leads state
  final RxList<Lead> leads = <Lead>[].obs;
  final RxBool isLoadingLeads = false.obs;
  final RxnString leadsError = RxnString();

  // Documents state
  final RxList<CRMDocument> documents = <CRMDocument>[].obs;
  final RxBool isLoadingDocuments = false.obs;
  final RxnString documentsError = RxnString();

  // Tasks state
  final RxList<CRMTask> tasks = <CRMTask>[].obs;
  final RxBool isLoadingTasks = false.obs;
  final RxnString tasksError = RxnString();

  // Assets state
  final RxList<CRMAsset> assets = <CRMAsset>[].obs;
  final RxBool isLoadingAssets = false.obs;
  final RxnString assetsError = RxnString();

  // Daily Reports state
  final RxList<DailyReport> dailyReports = <DailyReport>[].obs;
  final RxBool isLoadingDailyReports = false.obs;
  final RxnString dailyReportsError = RxnString();

  // User Roles state
  final RxList<UserRoleInfo> userRoles = <UserRoleInfo>[].obs;
  final RxBool isLoadingRoles = false.obs;
  final RxnString rolesError = RxnString();

  // Performance state
  final RxList<Performance> performanceReviews = <Performance>[].obs;
  final RxBool isLoadingPerformance = false.obs;
  final RxnString performanceError = RxnString();

  // Payroll state
  final RxList<CRMPayroll> payrolls = <CRMPayroll>[].obs;
  final RxBool isLoadingPayroll = false.obs;
  final RxnString payrollError = RxnString();

  // Attendance state
  final RxList<Attendance> attendanceLogs = <Attendance>[].obs;
  final RxBool isLoadingAttendance = false.obs;
  final RxnString attendanceError = RxnString();

  // Employees state
  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxnString employeesError = RxnString();

  // Dashboard Stats state
  final Rxn<Map<String, dynamic>> dashboardStats = Rxn<Map<String, dynamic>>();
  final RxBool isLoadingDashboardStats = false.obs;
  final RxnString dashboardStatsError = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Load local mock fallbacks initially
    _loadLocalMockData();
    // Auto-fetch remote data if token is already loaded
    if (ApiService.token != null) {
      onTokenLoaded();
    }
  }

  void onTokenLoaded() {
    fetchDashboardStats();
    fetchLeaves();
    fetchLeads();
    fetchDocuments();
    fetchTasks();
    fetchAssets();
    fetchDailyReports();
    fetchRoles();
    fetchPerformanceReviews();
    fetchPayrolls(year: 2026, month: 7);
    
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    fetchAttendance(startDate: '2026-06-01', endDate: todayStr);
    
    fetchEmployees();
  }

  void _loadLocalMockData() {
    leaveRequests.assignAll([
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

    leads.assignAll([
      Lead(
        id: "LD-101",
        name: "Robert Downey",
        company: "Stark Industries",
        email: "tony@stark.com",
        phone: "+1 (555) 911-3000",
        value: 45000.00,
        status: "Converted",
        source: "Website",
        dateCreated: DateTime.now().subtract(const Duration(days: 30)),
        owner: "Sarah Jenkins",
        alternatePhone: "+1 (555) 911-3001",
        salesStage: "Booking",
        probability: 95.0,
        timeline: "Within 1 Month",
        priority: "High",
        requirement: "Premium suite integration with automated email system",
        street: "10880 Wilshire Blvd",
        city: "Los Angeles",
        state: "California",
        pincode: "90024",
      ),
      Lead(
        id: "LD-102",
        name: "Bruce Wayne",
        company: "Wayne Enterprises",
        email: "bruce@wayne.com",
        phone: "+1 (555) 443-1200",
        value: 120000.00,
        status: "Hot",
        source: "Referral",
        dateCreated: DateTime.now().subtract(const Duration(days: 15)),
        owner: "Marcus Aurelius",
        salesStage: "Negotiation",
        probability: 80.0,
        timeline: "Immediate",
        priority: "Critical",
        requirement: "Highly secure private server deployment",
        street: "1007 Mountain Drive",
        city: "Gotham",
        state: "New Jersey",
        pincode: "07001",
      ),
      Lead(
        id: "LD-103",
        name: "Clark Kent",
        company: "Daily Planet",
        email: "clark@dailyplanet.com",
        phone: "+1 (555) 902-8833",
        value: 15000.00,
        status: "Follow-up",
        source: "Website",
        dateCreated: DateTime.now().subtract(const Duration(days: 10)),
        owner: "Sarah Jenkins",
        salesStage: "Demo",
        probability: 50.0,
        timeline: "1-3 Months",
        priority: "Medium",
        requirement: "Cloud CRM with mobile app tracking",
        street: "Metropolis St 40",
        city: "Metropolis",
        state: "New York",
        pincode: "10001",
      ),
      Lead(
        id: "LD-104",
        name: "Steve Rogers",
        company: "Shield Corp",
        email: "steve@shield.gov",
        phone: "+1 (555) 177-6600",
        value: 30000.00,
        status: "New",
        source: "Call",
        dateCreated: DateTime.now().subtract(const Duration(days: 2)),
        owner: "David Chen",
        salesStage: "Inquiry",
        probability: 30.0,
        timeline: "Immediate",
        priority: "Medium",
        requirement: "Standard multi-user license and call tracking support",
        street: "Brooklyn Plaza",
        city: "Brooklyn",
        state: "New York",
        pincode: "11201",
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
        salesStage: "Lost",
        probability: 0.0,
        timeline: "3-6 Months",
        priority: "Low",
        requirement: "Single user setup (cancelled due to budget constraints)",
        street: "Forest Hills",
        city: "Queens",
        state: "New York",
        pincode: "11375",
      ),
    ]);

    documents.assignAll([
      CRMDocument(
        id: "DOC-001",
        title: "Employee Handbook 2026.pdf",
        category: "SOP",
        fileUrl: "https://example.com/handbook.pdf",
        size: "2.4 MB",
        uploadedBy: "Diana Prince",
        uploadDate: DateTime.now().subtract(const Duration(days: 12)),
      ),
      CRMDocument(
        id: "DOC-002",
        title: "Wayne Enterprises Agreement.pdf",
        category: "Contract",
        fileUrl: "https://example.com/wayne-contract.pdf",
        size: "1.8 MB",
        uploadedBy: "Marcus Aurelius",
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CRMDocument(
        id: "DOC-003",
        title: "Stark Tech Invoice-Q2.pdf",
        category: "Invoice",
        fileUrl: "https://example.com/stark-invoice.pdf",
        size: "820 KB",
        uploadedBy: "Sarah Jenkins",
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    tasks.assignAll([
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
    ]);

    assets.assignAll([
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

    dailyReports.assignAll([
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

    userRoles.assignAll([
      UserRoleInfo(id: "EMP-001", name: "Diana Prince", email: "diana.prince@company.com", role: "HR Director"),
      UserRoleInfo(id: "EMP-002", name: "Marcus Aurelius", email: "marcus.aurelius@company.com", role: "VP of Sales"),
      UserRoleInfo(id: "EMP-003", name: "Sarah Jenkins", email: "sarah.jenkins@company.com", role: "Senior Account Executive"),
      UserRoleInfo(id: "EMP-004", name: "David Chen", email: "david.chen@company.com", role: "Customer Success Lead"),
      UserRoleInfo(id: "EMP-005", name: "Elena Rostova", email: "elena.rostova@company.com", role: "HR Generalist"),
    ]);
  }

  // Fetch Leaves
  Future<void> fetchLeaves() async {
    isLoadingLeaves.value = true;
    leavesError.value = null;
    try {
      final data = await _apiService.fetchLeaves();
      leaveRequests.assignAll(data);
    } catch (e) {
      leavesError.value = e.toString();
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  // Submit Leave
  Future<bool> submitLeave(String type, DateTime start, DateTime end, String reason, String employeeId, String employeeName) async {
    final req = Leave(
      id: "LV-${leaveRequests.length + 100}",
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      startDate: start,
      endDate: end,
      reason: reason,
      status: "Pending",
    );

    // Optimistic UI Update
    leaveRequests.insert(0, req);

    try {
      final success = await _apiService.submitLeave(req);
      if (success) {
        await fetchLeaves();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Fetch Leads
  Future<void> fetchLeads() async {
    isLoadingLeads.value = true;
    leadsError.value = null;
    try {
      final data = await _apiService.fetchLeads();
      leads.assignAll(data);
    } catch (e) {
      leadsError.value = e.toString();
    } finally {
      isLoadingLeads.value = false;
    }
  }

  // Submit Lead
  Future<bool> submitLead(Lead lead) async {
    leads.insert(0, lead);
    try {
      final success = await _apiService.submitLead(lead);
      if (success) {
        await fetchLeads();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update Lead
  Future<bool> updateLead(Lead lead) async {
    final idx = leads.indexWhere((l) => l.id == lead.id);
    if (idx != -1) {
      leads[idx] = lead;
      leads.refresh();
    }
    try {
      final success = await _apiService.updateLead(lead);
      if (success) {
        await fetchLeads();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete Lead
  Future<bool> deleteLead(String id) async {
    final deletedLeadIdx = leads.indexWhere((l) => l.id == id);
    Lead? deletedLead;
    if (deletedLeadIdx != -1) {
      deletedLead = leads[deletedLeadIdx];
      leads.removeAt(deletedLeadIdx);
    }
    try {
      final success = await _apiService.deleteLead(id);
      if (success) {
        await fetchLeads();
        return true;
      }
      if (deletedLeadIdx != -1 && deletedLead != null) {
        leads.insert(deletedLeadIdx, deletedLead);
      }
      return false;
    } catch (e) {
      if (deletedLeadIdx != -1 && deletedLead != null) {
        leads.insert(deletedLeadIdx, deletedLead);
      }
      return false;
    }
  }

  // Update Lead Status
  Future<void> updateLeadStatus(String leadId, String newStatus) async {
    final idx = leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final oldLead = leads[idx];
      final updated = oldLead.copyWith(status: newStatus);
      leads[idx] = updated;
      leads.refresh();
      try {
        await _apiService.updateLead(updated);
        await fetchLeads();
      } catch (_) {}
    }
  }

  // Fetch Documents
  Future<void> fetchDocuments({String? documentType}) async {
    isLoadingDocuments.value = true;
    documentsError.value = null;
    try {
      final data = await _apiService.fetchDocuments(documentType: documentType);
      documents.assignAll(data);
    } catch (e) {
      documentsError.value = e.toString();
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  // Submit Document
  Future<bool> submitDocument(CRMDocument document) async {
    documents.insert(0, document);
    try {
      final success = await _apiService.submitDocument(document);
      if (success) {
        await fetchDocuments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Fetch Tasks
  Future<void> fetchTasks() async {
    isLoadingTasks.value = true;
    tasksError.value = null;
    try {
      final data = await _apiService.fetchTasks();
      tasks.assignAll(data);
    } catch (e) {
      tasksError.value = e.toString();
    } finally {
      isLoadingTasks.value = false;
    }
  }

  // Submit Task
  Future<bool> submitTask(CRMTask task) async {
    tasks.insert(0, task);
    try {
      final success = await _apiService.submitTask(task);
      if (success) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update Task Status
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final oldTask = tasks[idx];
      final updated = oldTask.copyWith(status: newStatus);
      tasks[idx] = updated;
      tasks.refresh();
      try {
        await _apiService.submitTask(updated);
        await fetchTasks();
      } catch (_) {}
    }
  }

  // Assets Methods
  Future<void> fetchAssets() async {
    isLoadingAssets.value = true;
    assetsError.value = null;
    try {
      final fetched = await _apiService.fetchAssets();
      assets.assignAll(fetched);
    } catch (e) {
      assetsError.value = e.toString();
    } finally {
      isLoadingAssets.value = false;
    }
  }

  Future<bool> submitAsset(CRMAsset asset) async {
    try {
      final success = await _apiService.submitAsset(asset);
      if (success) {
        assets.insert(0, asset);
        return true;
      }
    } catch (_) {}
    assets.insert(0, asset);
    return true;
  }

  // Daily Reports Methods
  Future<void> fetchDailyReports({String? employeeId, String? from, String? to}) async {
    isLoadingDailyReports.value = true;
    dailyReportsError.value = null;
    try {
      final role = MockDataService().currentRole;
      List<DailyReport> fetched;
      if (role == UserRole.superAdmin || role == UserRole.hr) {
        fetched = await _apiService.fetchAllDailyReports(
          employeeId: employeeId,
          from: from,
          to: to,
        );
      } else {
        fetched = await _apiService.fetchMyDailyReports(
          from: from,
          to: to,
        );
      }
      dailyReports.assignAll(fetched);
    } catch (e) {
      dailyReportsError.value = e.toString();
    } finally {
      isLoadingDailyReports.value = false;
    }
  }

  Future<bool> submitDailyReport(DailyReport report) async {
    try {
      final success = await _apiService.submitDailyReport(report);
      if (success) {
        await fetchDailyReports();
        return true;
      }
    } catch (_) {}
    dailyReports.insert(0, report);
    return true;
  }

  Future<bool> reviewDailyReport(String id, String status, String reviewNote) async {
    try {
      final success = await _apiService.reviewDailyReport(id, status, reviewNote);
      if (success) {
        await fetchDailyReports();
        return true;
      }
    } catch (_) {}
    // Fallback: update locally
    final idx = dailyReports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final oldReport = dailyReports[idx];
      dailyReports[idx] = oldReport.copyWith(
        status: status,
        reviewNote: reviewNote,
        reviewedByName: MockDataService().currentUser?.name ?? "Admin/HR",
      );
      dailyReports.refresh();
    }
    return true;
  }

  // Roles Methods
  Future<void> fetchRoles() async {
    isLoadingRoles.value = true;
    rolesError.value = null;
    try {
      final fetched = await _apiService.fetchRoles();
      userRoles.assignAll(fetched);
    } catch (e) {
      rolesError.value = e.toString();
    } finally {
      isLoadingRoles.value = false;
    }
  }

  Future<bool> submitRole(UserRoleInfo role) async {
    try {
      final success = await _apiService.submitRole(role);
      if (success) {
        final idx = userRoles.indexWhere((r) => r.id == role.id);
        if (idx != -1) {
          userRoles[idx] = role;
        } else {
          userRoles.add(role);
        }
        return true;
      }
    } catch (_) {}
    final idx = userRoles.indexWhere((r) => r.id == role.id);
    if (idx != -1) {
      userRoles[idx] = role;
    } else {
      userRoles.add(role);
    }
    return true;
  }

  // Fetch Performance Reviews
  Future<void> fetchPerformanceReviews() async {
    isLoadingPerformance.value = true;
    performanceError.value = null;
    try {
      final fetched = await _apiService.fetchPerformanceReviews();
      performanceReviews.assignAll(fetched);
    } catch (e) {
      performanceError.value = e.toString();
    } finally {
      isLoadingPerformance.value = false;
    }
  }

  // Submit Performance Review
  Future<bool> submitPerformanceReview(Performance review) async {
    performanceReviews.insert(0, review);
    try {
      final success = await _apiService.submitPerformanceReview(review);
      if (success) {
        await fetchPerformanceReviews();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Fetch Payrolls
  Future<void> fetchPayrolls({int? year, int? month}) async {
    isLoadingPayroll.value = true;
    payrollError.value = null;
    try {
      final fetched = await _apiService.fetchPayrolls(year: year, month: month);
      payrolls.assignAll(fetched);
    } catch (e) {
      payrollError.value = e.toString();
    } finally {
      isLoadingPayroll.value = false;
    }
  }

  // Fetch Attendance
  Future<void> fetchAttendance({String? startDate, String? endDate}) async {
    isLoadingAttendance.value = true;
    attendanceError.value = null;
    try {
      final fetched = await _apiService.fetchAttendance(startDate: startDate, endDate: endDate);
      attendanceLogs.assignAll(fetched);
    } catch (e) {
      attendanceError.value = e.toString();
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  // Punch In/Out API Actions
  Future<bool> punchIn() async {
    try {
      final success = await _apiService.punchIn();
      if (success) {
        final today = DateTime.now();
        final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        await fetchAttendance(startDate: '2026-06-01', endDate: todayStr);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> punchOut() async {
    try {
      final success = await _apiService.punchOut();
      if (success) {
        final today = DateTime.now();
        final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        await fetchAttendance(startDate: '2026-06-01', endDate: todayStr);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Fetch Employees
  Future<void> fetchEmployees() async {
    isLoadingEmployees.value = true;
    employeesError.value = null;
    try {
      final fetched = await _apiService.fetchEmployees();
      employees.assignAll(fetched);
    } catch (e) {
      employeesError.value = e.toString();
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // Submit Employee
  Future<bool> submitEmployee(Employee employee) async {
    employees.insert(0, employee);
    try {
      final success = await _apiService.submitEmployee(employee);
      if (success) {
        await fetchEmployees();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Fetch Dashboard Stats
  Future<void> fetchDashboardStats() async {
    isLoadingDashboardStats.value = true;
    dashboardStatsError.value = null;
    try {
      final data = await _apiService.fetchDashboardStats();
      dashboardStats.value = data;
    } catch (e) {
      dashboardStatsError.value = e.toString();
    } finally {
      isLoadingDashboardStats.value = false;
    }
  }

  // Update Employee
  Future<bool> updateEmployee(String id, Employee employee) async {
    try {
      final success = await _apiService.updateEmployee(id, employee);
      if (success) {
        await fetchEmployees();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete Employee
  Future<bool> deleteEmployee(String id) async {
    final originalList = List<Employee>.from(employees);
    employees.removeWhere((e) => e.id == id || e.employeeId == id);
    try {
      final success = await _apiService.deleteEmployee(id);
      if (success) {
        await fetchEmployees();
        return true;
      }
      employees.assignAll(originalList);
      return false;
    } catch (e) {
      employees.assignAll(originalList);
      return false;
    }
  }
}
