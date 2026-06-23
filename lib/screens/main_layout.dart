import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/responsive_layout.dart';
import '../core/widgets/sidebar_navigation.dart';
import '../services/mock_data_service.dart';

// Screens imports
import 'dashboard/dashboard_screen.dart';
import 'employees/employee_screen.dart';
import 'leads/lead_screen.dart';
import 'attendance/attendance_screen.dart';
import 'leaves/leave_screen.dart';
import 'payroll/payroll_screen.dart';
import 'tasks/task_screen.dart';
import 'performance/performance_screen.dart';
import 'calendar/calendar_screen.dart';
import 'settings/settings_screen.dart';
import 'documents/document_screen.dart';
import 'assets/asset_screen.dart';
import 'daily_reports/daily_report_screen.dart';
import 'role_management/role_management_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = [
    "RidealCRM Analytics",
    "Employee Portal",
    "Sales Lead Pipeline",
    "Time & Attendance",
    "Time-Off Management",
    "Compensation & Payroll",
    "Workspace Task Board",
    "Performance Tracker",
    "Calendar Schedule",
    "Account Settings",
    "Document Management Hub",
    "Asset Management Tracker",
    "Daily Report Logger",
    "Role Management Console",
  ];

  Widget _getCurrentScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const EmployeeScreen();
      case 2:
        return const LeadScreen();
      case 3:
        return const AttendanceScreen();
      case 4:
        return const LeaveScreen();
      case 5:
        return const PayrollScreen();
      case 6:
        return const TaskScreen();
      case 7:
        return const PerformanceScreen();
      case 8:
        return const CalendarScreen();
      case 9:
        return const SettingsScreen();
      case 10:
        return const DocumentScreen();
      case 11:
        return const AssetScreen();
      case 12:
        return const DailyReportScreen();
      case 13:
        return const RoleManagementScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _showNotificationsPanel(BuildContext context, MockDataService state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AnimatedBuilder(
          animation: state,
          builder: (context, child) {
            final unreadCount = state.notifications.where((n) => !n.isRead).length;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Workspace Alerts",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "$unreadCount new",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          state.markNotificationsAsRead();
                        },
                        child: const Text(
                          "Mark all as read",
                          style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 320,
                    child: state.notifications.isEmpty
                        ? const Center(
                            child: Text(
                              "No notifications logged yet.",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.notifications.length,
                            separatorBuilder: (context, idx) => const Divider(color: AppColors.border, height: 1),
                            itemBuilder: (context, idx) {
                              final notif = state.notifications[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: notif.isRead ? Colors.transparent : AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notif.title,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            notif.message,
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
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

    return AnimatedBuilder(
      animation: state,
      builder: (context, child) {
        final activeIndex = state.currentMenuIndex;
        final isMobile = ResponsiveLayout.isMobile(context);

        // Sidebar content used both in desktop frame and mobile drawer
        final sidebar = SidebarNavigation(
          selectedIndex: activeIndex,
          onItemSelected: (index) {
            state.setMenuIndex(index);
            if (isMobile) {
              _scaffoldKey.currentState?.closeDrawer();
            }
          },
          state: state,
        );

        final unreadNotifCount = state.notifications.where((n) => !n.isRead).length;

        // Custom Header Bar
        final appBarHeader = AppBar(
          key: const Key('CRMAppBar'),
          backgroundColor: AppColors.cardBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: isMobile
              ? IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                )
              : null,
          title: Text(
            _titles[activeIndex],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: AppColors.border, height: 1),
          ),
          actions: [
            // Floating Punch-Status Pill
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  if (state.isPunchedIn) {
                    state.punchOut();
                  } else {
                    state.punchIn();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: state.isPunchedIn
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: state.isPunchedIn ? AppColors.primary.withOpacity(0.3) : Colors.red[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: state.isPunchedIn ? AppColors.primary : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        Text(
                          state.isPunchedIn ? "PUNCHED IN" : "PUNCHED OUT",
                          style: TextStyle(
                            color: state.isPunchedIn ? AppColors.primary : Colors.red[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Alert bell Badge icon
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                  onPressed: () => _showNotificationsPanel(context, state),
                ),
                if (unreadNotifCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$unreadNotifCount",
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
          ],
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: isMobile ? Drawer(child: sidebar) : null,
          body: Row(
            children: [
              if (!isMobile) sidebar, // Desktop Side panel
              Expanded(
                child: Scaffold(
                  backgroundColor: AppColors.background,
                  appBar: appBarHeader,
                  body: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.01, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(activeIndex),
                      child: _getCurrentScreen(activeIndex),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
