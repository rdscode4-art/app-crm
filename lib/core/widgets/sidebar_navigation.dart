import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../services/mock_data_service.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final MockDataService state;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final List<_SidebarItem> allItems = [
      _SidebarItem(index: 0, title: "Dashboard", icon: Icons.dashboard_outlined),
      _SidebarItem(index: 1, title: "Employees", icon: Icons.people_outline),
      _SidebarItem(index: 2, title: "Leads", icon: Icons.trending_up),
      _SidebarItem(index: 3, title: "Attendance", icon: Icons.fact_check_outlined),
      _SidebarItem(index: 4, title: "Leaves", icon: Icons.beach_access_outlined),
      _SidebarItem(index: 5, title: "Payroll", icon: Icons.payments_outlined),
      _SidebarItem(index: 6, title: "Tasks", icon: Icons.task_alt_outlined),
      _SidebarItem(index: 7, title: "Performance", icon: Icons.insights_outlined),
      _SidebarItem(index: 8, title: "Calendar", icon: Icons.calendar_month_outlined),
      _SidebarItem(index: 10, title: "Documents", icon: Icons.folder_open_outlined),
      _SidebarItem(index: 9, title: "Settings", icon: Icons.settings_outlined),
      _SidebarItem(index: 11, title: "Asset Management", icon: Icons.devices_other_outlined),
      _SidebarItem(index: 12, title: "Daily Report", icon: Icons.note_alt_outlined),
      _SidebarItem(index: 13, title: "Role Management", icon: Icons.admin_panel_settings_outlined),
    ];

    final role = state.currentRole;
    final List<_SidebarItem> menuItems;

    if (role == UserRole.superAdmin) {
      menuItems = allItems.where((item) => [0, 1, 13, 2, 3, 4, 5, 6, 7, 8, 10, 12, 9].contains(item.index)).toList();
    } else if (role == UserRole.hr) {
      menuItems = allItems.where((item) => [0, 4, 6, 7, 11, 10, 12, 9].contains(item.index)).toList();
    } else {
      menuItems = allItems.where((item) => [0, 3, 4, 6, 10, 12, 9].contains(item.index)).toList();
    }

    return Container(
      width: 260,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "RidealCRM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),

          // Menu List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == item.index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => onItemSelected(item.index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer User Profile info
          if (state.currentUser != null) ...[
            const Divider(color: Colors.white10, height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(state.currentUser!.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.currentUser!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.currentUser!.role,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () {
                      state.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    tooltip: "Logout",
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarItem {
  final int index;
  final String title;
  final IconData icon;

  _SidebarItem({
    required this.index,
    required this.title,
    required this.icon,
  });
}
