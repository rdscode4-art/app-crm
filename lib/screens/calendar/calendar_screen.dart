import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mock_data_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(2026, 6); // Mock starts in June 2026 matching current timestamp year/month
    _selectedDay = DateTime(2026, 6, 22); // Pre-select today
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  // Helper calculation for calendar grids
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getStartWeekday(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday; // 1 = Monday, 7 = Sunday
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final width = MediaQuery.of(context).size.width;

    final daysInMonth = _getDaysInMonth(_selectedMonth);
    // Grid starts on weekday offset. e.g. if start weekday is Wed (3), offset is 2 spaces.
    // Sunday is 7, so offset is (weekday % 7) (e.g. Wed is 3, Mon is 1, Sun is 0 if we start Sunday)
    // Let's standardise starting on Monday (Offset = weekday - 1)
    final startOffset = _getStartWeekday(_selectedMonth) - 1;
    final totalCells = daysInMonth + startOffset;

    final monthsList = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return AnimatedBuilder(
      animation: state,
      builder: (context, child) {
        // Collect tasks & leaves for currently selected day
        final dayTasks = state.tasks.where((t) {
          return _selectedDay != null &&
              t.dueDate.year == _selectedDay!.year &&
              t.dueDate.month == _selectedDay!.month &&
              t.dueDate.day == _selectedDay!.day;
        }).toList();

        final dayLeaves = state.leaveRequests.where((l) {
          if (_selectedDay == null || l.status != 'Approved') return false;
          return !_selectedDay!.isBefore(l.startDate) && !_selectedDay!.isAfter(l.endDate);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Calendar Integration",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track team deadlines, task checkouts, and approved employee leaves.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calendar Layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Calendar Grid Container
                  Expanded(
                    flex: width < 1000 ? 1 : 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          // Month Selector row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${monthsList[_selectedMonth.month - 1]} ${_selectedMonth.year}",
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                                    onPressed: _prevMonth,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                                    onPressed: _nextMonth,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Days of Week labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _WeekdayLabel("Mon"),
                              _WeekdayLabel("Tue"),
                              _WeekdayLabel("Wed"),
                              _WeekdayLabel("Thu"),
                              _WeekdayLabel("Fri"),
                              _WeekdayLabel("Sat"),
                              _WeekdayLabel("Sun"),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: AppColors.border, height: 1),
                          const SizedBox(height: 10),

                          // Grid Days Builder
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: totalCells,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              if (index < startOffset) {
                                return const SizedBox.shrink(); // Empty space offset
                              }

                              final dayNum = index - startOffset + 1;
                              final cellDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNum);
                              final isSelected = _selectedDay != null &&
                                  _selectedDay!.year == cellDate.year &&
                                  _selectedDay!.month == cellDate.month &&
                                  _selectedDay!.day == cellDate.day;

                              // Check if there are tasks or leaves on this day for dots indicators
                              final hasTasks = state.tasks.any((t) =>
                                  t.dueDate.year == cellDate.year &&
                                  t.dueDate.month == cellDate.month &&
                                  t.dueDate.day == cellDate.day);

                              final hasLeaves = state.leaveRequests.any((l) =>
                                  l.status == 'Approved' &&
                                  !cellDate.isBefore(l.startDate) &&
                                  !cellDate.isAfter(l.endDate));

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDay = cellDate;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (cellDate.day == DateTime.now().day && cellDate.month == DateTime.now().month
                                            ? AppColors.primary.withOpacity(0.08)
                                            : Colors.transparent),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? null
                                        : (cellDate.day == DateTime.now().day && cellDate.month == DateTime.now().month
                                            ? Border.all(color: AppColors.primary.withOpacity(0.3))
                                            : null),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$dayNum",
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Indicator dots row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (hasTasks)
                                            Container(
                                              width: 5,
                                              height: 5,
                                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                              decoration: BoxDecoration(
                                                color: isSelected ? Colors.white : AppColors.info,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          if (hasLeaves)
                                            Container(
                                              width: 5,
                                              height: 5,
                                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                              decoration: BoxDecoration(
                                                color: isSelected ? Colors.white : AppColors.warning,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Section: Schedule Agenda for selected date
                  if (width >= 1000) ...[
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 500,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDay != null
                                  ? "Agenda: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}"
                                  : "Select a Date",
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: dayTasks.isEmpty && dayLeaves.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No tasks or absences scheduled on this day.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                    )
                                  : ListView(
                                      children: [
                                        // Task items list
                                        if (dayTasks.isNotEmpty) ...[
                                          const Text(
                                            "DEADLINE CHECKLIST",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 8),
                                          ...dayTasks.map((task) => _buildAgendaItem(
                                                task.title,
                                                "Assignee: ${task.assignedTo}",
                                                AppColors.info,
                                                Icons.assignment_outlined,
                                              )),
                                          const SizedBox(height: 16),
                                        ],

                                        // Leave items list
                                        if (dayLeaves.isNotEmpty) ...[
                                          const Text(
                                            "EMPLOYEE OUT-OF-OFFICE",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 8),
                                          ...dayLeaves.map((leave) => _buildAgendaItem(
                                                "${leave.employeeName} Out",
                                                "Approved ${leave.type} Leave",
                                                AppColors.warning,
                                                Icons.flight_takeoff_outlined,
                                              )),
                                        ],
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgendaItem(String title, String subtitle, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
