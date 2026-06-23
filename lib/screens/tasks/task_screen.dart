import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/task.dart';
import '../../services/mock_data_service.dart';
import '../../controllers/crm_controller.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['Todo', 'In Progress', 'Review', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CrmController>().fetchTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog(BuildContext context, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'Medium';
    String assignee = state.employees.isNotEmpty ? state.employees.first.name : "Unassigned";
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> selectDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dueDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setDialogState(() {
                  dueDate = picked;
                });
              }
            }

            final dateText = "${dueDate.day}/${dueDate.month}/${dueDate.year}";

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              title: const Text(
                "Create Workspace Task",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: "Task Title",
                        hint: "e.g., Deliver Wayne proposal feedback",
                        prefixIcon: Icons.title,
                        controller: titleCtrl,
                        validator: (val) => val == null || val.isEmpty ? "Title is required" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Task Description",
                        hint: "Provide clear goals and requirements...",
                        prefixIcon: Icons.description_outlined,
                        controller: descCtrl,
                        validator: (val) => val == null || val.isEmpty ? "Description is required" : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Priority Level",
                                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: priority,
                                      isExpanded: true,
                                      items: ['Low', 'Medium', 'High']
                                          .map((p) => DropdownMenuItem(
                                                value: p,
                                                child: Text(p, style: const TextStyle(fontSize: 14)),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            priority = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Assignee representative",
                                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: assignee,
                                      isExpanded: true,
                                      items: state.employees
                                          .map((e) => DropdownMenuItem(
                                                value: e.name,
                                                child: Text(e.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            assignee = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Deadline Target",
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: selectDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateText, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                              const Icon(Icons.calendar_month, color: AppColors.textSecondary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                ),
                CustomButton(
                  text: "Assign Task",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newTask = CRMTask(
                        id: "TSK-${state.tasks.length + 201}",
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        assignedTo: assignee,
                        dueDate: dueDate,
                        priority: priority,
                        status: 'Todo',
                      );
                      state.addTask(newTask);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskActions(BuildContext context, CRMTask task, MockDataService state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final dateStr = "${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}";

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetaCell("Assignee", task.assignedTo),
                  _buildMetaCell("Due Date", dateStr),
                  _buildMetaCell("Priority", task.priority,
                      color: task.priority == 'High'
                          ? AppColors.danger
                          : (task.priority == 'Medium' ? AppColors.warning : AppColors.info)),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Shift Board Column Stage",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statuses.map((st) {
                  final isCurrent = task.status == st;
                  return InkWell(
                    onTap: () {
                      state.updateTaskStatus(task.id, st);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        st,
                        style: TextStyle(
                          color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaCell(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final controller = Get.find<CrmController>();
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;

    return Obx(
      () {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Task Board",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Manage collaborative checklist tasks and project completions.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: "Create Task",
                    icon: Icons.add,
                    onPressed: () => _showAddTaskDialog(context, state),
                  ),
                ],
              ),
              if (controller.isLoadingTasks.value) ...[
                const SizedBox(height: 16),
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
              if (controller.tasksError.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.tasksError.value!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: AppColors.danger.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text("Retry", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => controller.fetchTasks(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Responsive Columns Layout
              if (isDesktop) ...[
                // Desktop side-by-side columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _statuses.map((status) {
                    final statusTasks = state.tasks.where((t) => t.status == status).toList();

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    "${statusTasks.length}",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // List of tasks inside this column
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: statusTasks.length,
                              itemBuilder: (context, idx) {
                                final task = statusTasks[idx];
                                return _buildTaskCard(context, task, state);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Mobile tabs layout
                Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      isScrollable: true,
                      tabs: _statuses.map((st) {
                        final count = state.tasks.where((t) => t.status == st).length;
                        return Tab(text: "$st ($count)");
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _tabController,
                        children: _statuses.map((st) {
                          final statusTasks = state.tasks.where((t) => t.status == st).toList();
                          if (statusTasks.isEmpty) {
                            return const Center(
                              child: Text(
                                "No tasks in this board section.",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: statusTasks.length,
                            itemBuilder: (context, idx) {
                              final task = statusTasks[idx];
                              return _buildTaskCard(context, task, state);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, CRMTask task, MockDataService state) {
    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = AppColors.danger;
        break;
      case 'Medium':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.info;
    }

    final dateStr = "${task.dueDate.day}/${task.dueDate.month}";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Status actions dot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _showTaskActions(context, task, state),
                child: const Icon(Icons.more_vert, size: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Footer: Priority tag & Assignee + Due Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 6),

          // Assignee details row
          Row(
            children: [
              const Icon(Icons.account_circle_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.assignedTo,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
