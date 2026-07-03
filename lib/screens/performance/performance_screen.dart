import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/performance.dart';
import '../../models/employee.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../controllers/crm_controller.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchControllerCallLogs =
      TextEditingController();
  String _searchQuery = "";
  String _searchQueryCallLogs = "";
  String _selectedCategory = "All";
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {"label": "All", "color": AppColors.primary},
    {"label": "Exemplary", "color": Colors.green},
    {"label": "Achiever", "color": AppColors.info},
    {"label": "Needs Improvement", "color": Colors.orange},
    {"label": "Unsatisfactory", "color": Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CrmController>().fetchPerformanceReviews();
      Get.find<CrmController>().fetchCallLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchControllerCallLogs.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showAddReviewModal(BuildContext context, MockDataService state) {
    Employee? selectedEmployee;
    String period = "Q2 2026";
    double kpiScore = 80.0;
    int ratingStars = 4;
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final availableEmployees = state.employees;
    if (availableEmployees.isNotEmpty) {
      selectedEmployee = availableEmployees[0];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "New Performance Review",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.border),

                      // Employee Dropdown
                      const Text(
                        "Select Employee",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Employee>(
                            value: selectedEmployee,
                            isExpanded: true,
                            items: availableEmployees.map((emp) {
                              return DropdownMenuItem<Employee>(
                                value: emp,
                                child: Text("${emp.name} (${emp.role})"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                selectedEmployee = val;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Period / Quarter
                      const Text(
                        "Evaluation Period",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: period,
                        decoration: InputDecoration(
                          hintText: "e.g., Q2 2026",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a period";
                          }
                          return null;
                        },
                        onChanged: (val) {
                          period = val;
                        },
                      ),
                      const SizedBox(height: 16),

                      // KPI Score Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "KPI Performance Score",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${kpiScore.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: kpiScore,
                        min: 0,
                        max: 100,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        divisions: 100,
                        onChanged: (val) {
                          setModalState(() {
                            kpiScore = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Rating Stars Picker
                      const Text(
                        "Overall Rating",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                ratingStars = index + 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                index < ratingStars
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      // Manager Feedback
                      const Text(
                        "Manager Feedback",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: feedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Write constructive review and summary...",
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter manager feedback";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      CustomButton(
                        text: "Submit Performance Review",
                        width: double.infinity,
                        onPressed: () {
                          if (formKey.currentState!.validate() &&
                              selectedEmployee != null) {
                            final newRecord = Performance(
                              id: "PERF-10${state.performanceRecords.length + 4}",
                              employeeId: selectedEmployee!.id,
                              employeeName: selectedEmployee!.name,
                              period: period,
                              kpiScore: double.parse(
                                kpiScore.toStringAsFixed(1),
                              ),
                              managerFeedback: feedbackController.text.trim(),
                              ratingStars: ratingStars,
                            );
                            Get.find<CrmController>().submitPerformanceReview(
                              newRecord,
                            );
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Performance review added for ${selectedEmployee!.name}",
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final controller = Get.find<CrmController>();
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final records = controller.performanceReviews;

      // KPI Summary Calculations
      final totalEvaluations = records.length;
      double avgKpiScore = 0.0;
      double avgRating = 0.0;
      String topPerformer = "N/A";
      double highestScore = -1.0;

      if (records.isNotEmpty) {
        double sumKpi = 0.0;
        double sumRating = 0.0;
        for (var r in records) {
          sumKpi += r.kpiScore;
          sumRating += r.ratingStars;
          if (r.kpiScore > highestScore) {
            highestScore = r.kpiScore;
            topPerformer = r.employeeName;
          }
        }
        avgKpiScore = sumKpi / records.length;
        avgRating = sumRating / records.length;
      }

      final canAddReview =
          state.currentRole == UserRole.superAdmin ||
          state.currentRole == UserRole.hr;

      // Filter list logic
      final filteredRecords = records.where((record) {
        final matchQuery =
            record.employeeName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            record.period.toLowerCase().contains(_searchQuery.toLowerCase());

        if (_selectedCategory == "All") return matchQuery;
        if (_selectedCategory == "Exemplary")
          return matchQuery && record.kpiScore >= 90;
        if (_selectedCategory == "Achiever")
          return matchQuery && record.kpiScore >= 75 && record.kpiScore < 90;
        if (_selectedCategory == "Needs Improvement")
          return matchQuery && record.kpiScore >= 50 && record.kpiScore < 75;
        if (_selectedCategory == "Unsatisfactory")
          return matchQuery && record.kpiScore < 50;

        return matchQuery;
      }).toList();

      // Stats layout responsiveness
      final statsCrossAxisCount = width < 600 ? 1 : (width < 1200 ? 2 : 4);
      final double cardHeight = width < 600 ? 135 : 135;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Performance & Analytics",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Monitor company KPIs, rating scorecards, and call analytics.",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canAddReview)
                  CustomButton(
                    text: width < 600 ? "Add" : "Add Evaluation",
                    icon: Icons.add,
                    onPressed: () => _showAddReviewModal(context, state),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Performance Reviews"),
              Tab(text: "Call Analytics"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Reviews
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview statistics dashboard
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: statsCrossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: cardHeight,
                        ),
                        children: [
                          MetricCard(
                            title: "Average KPI Score",
                            value: "${avgKpiScore.toStringAsFixed(1)}%",
                            changeText: "Active tracking",
                            isPositive: true,
                            icon: Icons.speed,
                            iconBgColor: const Color(0xFFECFDF5),
                            iconColor: AppColors.primary,
                          ),
                          MetricCard(
                            title: "Completed Reviews",
                            value: "$totalEvaluations logs",
                            changeText: "All quarters",
                            isPositive: true,
                            icon: Icons.assignment_turned_in_outlined,
                            iconBgColor: const Color(0xFFEFF6FF),
                            iconColor: AppColors.info,
                          ),
                          MetricCard(
                            title: "Top Performer",
                            value: topPerformer,
                            changeText: "Highest KPI Score",
                            isPositive: true,
                            icon: Icons.emoji_events_outlined,
                            iconBgColor: const Color(0xFFFEF3C7),
                            iconColor: AppColors.warning,
                          ),
                          MetricCard(
                            title: "Average Rating",
                            value: "${avgRating.toStringAsFixed(1)} Stars",
                            changeText: "Out of 5.0",
                            isPositive: true,
                            icon: Icons.star_border_purple500_rounded,
                            iconBgColor: const Color(0xFFFDF2F2),
                            iconColor: Colors.deepOrange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Search and Filters layout
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText:
                                      "Search by employee name or period...",
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: AppColors.textSecondary,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _categories.map((cat) {
                                  final isSelected =
                                      _selectedCategory == cat["label"];
                                  final chipColor = cat["color"] as Color;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(
                                        cat["label"] == "Achiever"
                                            ? "Successful Achiever"
                                            : cat["label"],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: chipColor,
                                      checkmarkColor: Colors.white,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : AppColors.border,
                                        ),
                                      ),
                                      onSelected: (val) {
                                        setState(() {
                                          _selectedCategory = cat["label"];
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main Responsive Grid/Row Layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Employee Evaluation Logs",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (filteredRecords.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.feed_outlined,
                                    size: 48,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "No matching performance records cataloged.",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: filteredRecords.map((record) {
                                // Find detailed info of employee
                                final employee = state.employees.firstWhere(
                                  (e) => e.id == record.employeeId,
                                  orElse: () => Employee(
                                    id: record.employeeId,
                                    name: record.employeeName,
                                    email: '',
                                    role: 'Employee',
                                    department: 'General',
                                    status: 'Active',
                                    salary: 0,
                                    performanceRating: 0.0,
                                    dateJoined: '',
                                    phone: '',
                                    avatarUrl: '',
                                  ),
                                );

                                return _buildPerformanceCard(record, employee);
                              }).toList(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // TAB 2: Call Analytics
                _buildCallAnalyticsTab(
                  context,
                  width,
                  ResponsiveLayout.isMobile(context),
                  state,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPerformanceCard(Performance record, Employee employee) {
    Color categoryColor;
    String categoryLabel;

    if (record.kpiScore >= 90) {
      categoryColor = Colors.green;
      categoryLabel = "EXEMPLARY";
    } else if (record.kpiScore >= 75) {
      categoryColor = AppColors.primary;
      categoryLabel = "ACHIEVER";
    } else if (record.kpiScore >= 50) {
      categoryColor = Colors.orange;
      categoryLabel = "NEEDS IMPROVEMENT";
    } else {
      categoryColor = Colors.red;
      categoryLabel = "UNSATISFACTORY";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Side Accent Color-coding Bar
              Container(width: 6, color: categoryColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(employee),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.employeeName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${employee.role} • ${employee.department}",
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: categoryColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        categoryLabel,
                                        style: TextStyle(
                                          color: categoryColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Period: ${record.period}",
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildKpiProgressIndicator(
                            record.kpiScore,
                            categoryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Rating stars section
                      Row(
                        children: [
                          const Text(
                            "Rating: ",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < record.ratingStars
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Manager Feedback Comment Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: 18,
                              color: AppColors.textSecondary.withOpacity(0.4),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                record.managerFeedback,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallAnalyticsTab(
    BuildContext context,
    double width,
    bool isMobile,
    MockDataService state,
  ) {
    final controller = Get.find<CrmController>();
    return Obx(() {
      if (controller.isLoadingCallLogs.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final logs = controller.callLogs.where((log) {
        final search = _searchQueryCallLogs.toLowerCase();
        return log.employeeName.toLowerCase().contains(search) ||
            log.leadName.toLowerCase().contains(search) ||
            log.outcome.toLowerCase().contains(search);
      }).toList();

      final today = DateTime.now();
      final callsToday = controller.callLogs
          .where(
            (l) =>
                l.timestamp.year == today.year &&
                l.timestamp.month == today.month &&
                l.timestamp.day == today.day,
          )
          .length;

      final totalDuration = controller.callLogs.fold<int>(
        0,
        (sum, log) => sum + log.durationMinutes,
      );
      final connectedCalls = controller.callLogs
          .where((l) => l.outcome.toLowerCase() == 'connected')
          .length;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Call Analytics Dashboard",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await controller.fetchCallLogs(); // This will also sync native call logs
                    Get.snackbar(
                      "Success", 
                      "Call logs synced from device", 
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text("Sync Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricsRow(
              callsToday,
              totalDuration,
              connectedCalls,
              isMobile,
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchControllerCallLogs,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textSecondary),
                  hintText: "Search by Employee, Lead, or Outcome...",
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQueryCallLogs = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Data Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: logs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text("No call logs found.")),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      itemCount: logs.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final t = log.timestamp;
                        final dateStr =
                            "${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} • ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

                        Color outcomeColor = AppColors.textSecondary;
                        if (log.outcome.toLowerCase() == 'connected')
                          outcomeColor = Colors.green;
                        if (log.outcome.toLowerCase() == 'no answer')
                          outcomeColor = Colors.orange;
                        if (log.outcome.toLowerCase() == 'busy')
                          outcomeColor = Colors.red;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.call,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  log.leadName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                "${log.durationMinutes} min",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.employeeName,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (log.notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  log.notes,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: outcomeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              log.outcome,
                              style: TextStyle(
                                color: outcomeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricsRow(
    int callsToday,
    int totalDuration,
    int connectedCalls,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "Calls Today",
                  callsToday.toString(),
                  Icons.phone_callback,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "Total Minutes",
                  totalDuration.toString(),
                  Icons.timer,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            "Connected Calls",
            connectedCalls.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            "Calls Today",
            callsToday.toString(),
            Icons.phone_callback,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "Total Minutes",
            totalDuration.toString(),
            Icons.timer,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "Connected Calls",
            connectedCalls.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Employee employee) {
    final initials = employee.name.isNotEmpty
        ? employee.name
              .trim()
              .split(' ')
              .map((l) => l[0])
              .take(2)
              .join()
              .toUpperCase()
        : '??';

    final colors = [
      [const Color(0xFF6366F1), const Color(0xFF4F46E5)], // Indigo
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald
      [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Amber
      [const Color(0xFFEF4444), const Color(0xFFDC2626)], // Red
      [const Color(0xFFEC4899), const Color(0xFFDB2777)], // Pink
      [const Color(0xFF3B82F6), const Color(0xFF2563EB)], // Blue
    ];

    final colorPair = colors[employee.name.length % colors.length];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colorPair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child:
          employee.avatarUrl.isNotEmpty && employee.avatarUrl.startsWith("http")
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                employee.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
    );
  }

  Widget _buildKpiProgressIndicator(double score, Color badgeColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            value: score / 100,
            backgroundColor: badgeColor.withOpacity(0.08),
            color: badgeColor,
            strokeWidth: 4.5,
          ),
        ),
        Text(
          "${score.toStringAsFixed(0)}%",
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
