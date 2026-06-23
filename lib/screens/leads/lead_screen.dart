import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/lead.dart';
import '../../services/mock_data_service.dart';
import '../../controllers/crm_controller.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _stages = ['New', 'Contacted', 'Proposal', 'Won', 'Lost'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _stages.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CrmController>().fetchLeads();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddLeadDialog(BuildContext context, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    String source = 'Website';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              title: const Text(
                "Create Sales Lead",
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
                    children: [
                      CustomTextField(
                        label: "Prospect Name",
                        hint: "e.g., Bruce Banner",
                        prefixIcon: Icons.person_outline,
                        controller: nameCtrl,
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Company Name",
                        hint: "e.g., Stark Industries",
                        prefixIcon: Icons.business_outlined,
                        controller: companyCtrl,
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: "Email",
                              hint: "name@company.com",
                              prefixIcon: Icons.email_outlined,
                              controller: emailCtrl,
                              validator: (val) => val == null || !val.contains('@') ? "Valid email required" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: "Phone",
                              hint: "+1 555-0199",
                              prefixIcon: Icons.phone_outlined,
                              controller: phoneCtrl,
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: "Deal Value (\$)",
                              hint: "e.g., 50000",
                              prefixIcon: Icons.monetization_on_outlined,
                              controller: valueCtrl,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || double.tryParse(val) == null ? "Number required" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Lead Source",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
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
                                      value: source,
                                      isExpanded: true,
                                      items: ['Website', 'Referral', 'LinkedIn', 'Cold Call']
                                          .map((s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s, style: const TextStyle(fontSize: 14)),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            source = val;
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
                  text: "Save Lead",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newLead = Lead(
                        id: "LD-${state.leads.length + 101}",
                        name: nameCtrl.text,
                        company: companyCtrl.text,
                        email: emailCtrl.text,
                        phone: phoneCtrl.text,
                        value: double.parse(valueCtrl.text),
                        status: 'New',
                        source: source,
                        dateCreated: DateTime.now(),
                        owner: state.currentUser?.name ?? "Sales Agent",
                      );
                      state.addLead(newLead);
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

  void _showLeadActions(BuildContext context, Lead lead, MockDataService state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lead.company,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "\$${lead.value.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  _buildLeadDetailRow(Icons.email_outlined, "Email", lead.email),
                  _buildLeadDetailRow(Icons.phone_outlined, "Phone", lead.phone),
                  _buildLeadDetailRow(Icons.source_outlined, "Source", lead.source),
                  _buildLeadDetailRow(Icons.person_pin_outlined, "Assigned Agent", lead.owner),
                  const SizedBox(height: 16),
                  const Text(
                    "Move Stage",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _stages.map((st) {
                      final isCurrent = lead.status == st;
                      Color chipColor;
                      switch (st) {
                        case 'New':
                          chipColor = Colors.blue;
                          break;
                        case 'Contacted':
                          chipColor = Colors.orange;
                          break;
                        case 'Proposal':
                          chipColor = Colors.purple;
                          break;
                        case 'Won':
                          chipColor = AppColors.success;
                          break;
                        default:
                          chipColor = AppColors.danger;
                      }

                      return InkWell(
                        onTap: () {
                          state.updateLeadStatus(lead.id, st);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCurrent ? chipColor.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrent ? chipColor : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            st,
                            style: TextStyle(
                              color: isCurrent ? chipColor : AppColors.textSecondary,
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
      },
    );
  }

  Widget _buildLeadDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
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
              // Header & Add Lead Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sales Lead Pipeline",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Manage sales client opportunities, stages, values, and tracking.",
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
                    text: "Create Lead",
                    icon: Icons.add,
                    onPressed: () => _showAddLeadDialog(context, state),
                  ),
                ],
              ),
              if (controller.isLoadingLeads.value) ...[
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
              if (controller.leadsError.value != null) ...[
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
                          controller.leadsError.value!,
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
                        onPressed: () => controller.fetchLeads(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Responsive Pipeline Container
              if (isDesktop) ...[
                // Desktop Web Columns Sidebar view
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _stages.map((stage) {
                    final stageLeads = state.leads.where((l) => l.status == stage).toList();
                    final stageTotalValue = stageLeads.fold<double>(0, (sum, l) => sum + l.value);

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
                                  stage.toUpperCase(),
                                  style: TextStyle(
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
                                    "${stageLeads.length}",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${stageTotalValue.toStringAsFixed(0)} value",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Leads Cards list in stage
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: stageLeads.length,
                              itemBuilder: (context, idx) {
                                final lead = stageLeads[idx];
                                return _buildLeadCard(context, lead, state);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Mobile Tabbar View
                Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      isScrollable: true,
                      tabs: _stages.map((st) {
                        final count = state.leads.where((l) => l.status == st).length;
                        return Tab(text: "$st ($count)");
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _tabController,
                        children: _stages.map((st) {
                          final stageLeads = state.leads.where((l) => l.status == st).toList();
                          if (stageLeads.isEmpty) {
                            return const Center(
                              child: Text(
                                "No leads in this stage.",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: stageLeads.length,
                            itemBuilder: (context, idx) {
                              final lead = stageLeads[idx];
                              return _buildLeadCard(context, lead, state);
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

  Widget _buildLeadCard(BuildContext context, Lead lead, MockDataService state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lead.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            lead.company,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${lead.value.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              InkWell(
                onTap: () => _showLeadActions(context, lead, state),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    "Actions",
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
