import 'package:get/get.dart';
import '../models/leave.dart';
import '../models/lead.dart';
import '../models/document.dart';
import '../models/task.dart';
import '../models/asset.dart';
import '../models/daily_report.dart';
import '../models/user_role_info.dart';
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

  @override
  void onInit() {
    super.onInit();
    // Load local mock fallbacks initially
    _loadLocalMockData();
    // Auto-fetch remote data when the controller initializes
    fetchLeaves();
    fetchLeads();
    fetchDocuments();
    fetchTasks();
    fetchAssets();
    fetchDailyReports();
    fetchRoles();
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

  // Update Lead Status
  Future<void> updateLeadStatus(String leadId, String newStatus) async {
    final idx = leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final oldLead = leads[idx];
      final updated = oldLead.copyWith(status: newStatus);
      leads[idx] = updated;
      leads.refresh();
      try {
        await _apiService.submitLead(updated);
        await fetchLeads();
      } catch (_) {}
    }
  }

  // Fetch Documents
  Future<void> fetchDocuments() async {
    isLoadingDocuments.value = true;
    documentsError.value = null;
    try {
      final data = await _apiService.fetchDocuments();
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
}
