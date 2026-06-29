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
  final List<String> _stages = ['New', 'Hot', 'Cold', 'Converted', 'Lost', 'Follow-up'];

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

  void _showLeadDialog(BuildContext context, MockDataService state, {Lead? lead}) {
    final formKey = GlobalKey<FormState>();
    final isDesktop = MediaQuery.of(context).size.width >= 750;

    // Controllers
    final nameCtrl = TextEditingController(text: lead?.name);
    final phoneCtrl = TextEditingController(text: lead?.phone);
    final emailCtrl = TextEditingController(text: lead?.email);
    final altPhoneCtrl = TextEditingController(text: lead?.alternatePhone);
    final valueCtrl = TextEditingController(text: lead != null ? lead.value.toStringAsFixed(0) : "");
    final probabilityCtrl = TextEditingController(text: lead != null ? lead.probability.toStringAsFixed(0) : "0");
    final productInterestCtrl = TextEditingController(text: lead?.company);
    final requirementCtrl = TextEditingController(text: lead?.requirement);
    final streetCtrl = TextEditingController(text: lead?.street);
    final cityCtrl = TextEditingController(text: lead?.city);
    final pincodeCtrl = TextEditingController(text: lead?.pincode);
    final stateCtrl = TextEditingController(text: lead?.state);

    // Dropdown Items Lists
    final List<String> sources = ['WhatsApp', 'Facebook', 'Instagram', 'Call', 'Walk-in', 'Referral', 'Other', 'Website'];
    final List<String> statuses = ['New', 'Hot', 'Cold', 'Converted', 'Lost', 'Follow-up'];
    final List<String> stages = ['Inquiry', 'Demo', 'Negotiation', 'Closed', 'Booking', 'Lost'];
    final List<String> priorities = ['High', 'Medium', 'Low', 'Critical'];
    final List<String> timelines = ['Immediate', 'Within 1 Month', '1-3 Months', '3-6 Months'];

    // Safe parsed dropdown values
    String source = sources.firstWhere((s) => s.toLowerCase() == (lead?.source ?? 'Call').toLowerCase(), orElse: () => 'Call');
    String status = statuses.firstWhere((s) => s.toLowerCase() == (lead?.status ?? 'New').toLowerCase(), orElse: () => 'New');
    String salesStage = stages.firstWhere((s) => s.toLowerCase() == (lead?.salesStage ?? 'Inquiry').toLowerCase(), orElse: () => 'Inquiry');
    String priority = priorities.firstWhere((p) => p.toLowerCase() == (lead?.priority ?? 'Medium').toLowerCase(), orElse: () => 'Medium');
    String timeline = timelines.firstWhere((t) => t.toLowerCase() == (lead?.timeline ?? 'Immediate').toLowerCase(), orElse: () => 'Immediate');

    Widget _buildResponsiveRow(List<Widget> children) {
      if (isDesktop && children.length > 1) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: c,
              ),
            )).toList(),
          ),
        );
      } else {
        return Column(
          children: children.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: c,
          )).toList(),
        );
      }
    }

    Widget _buildDropdown({
      required String label,
      required String value,
      required List<String> items,
      required void Function(String?) onChanged,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 1.5),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items.map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              title: Text(
                lead == null ? "Create Sales Lead" : "Edit Sales Lead",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: isDesktop ? 750 : MediaQuery.of(context).size.width * 0.9,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResponsiveRow([
                          CustomTextField(
                            label: "Customer Name *",
                            hint: "e.g., Raminder Mittal",
                            prefixIcon: Icons.person_outline,
                            controller: nameCtrl,
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          CustomTextField(
                            label: "Mobile *",
                            hint: "e.g., +919915006927",
                            prefixIcon: Icons.phone_outlined,
                            controller: phoneCtrl,
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                        ]),
                        _buildResponsiveRow([
                          CustomTextField(
                            label: "Email",
                            hint: "raminder@ashoka.com",
                            prefixIcon: Icons.email_outlined,
                            controller: emailCtrl,
                          ),
                          CustomTextField(
                            label: "Alternate Phone",
                            hint: "e.g., +919915006900",
                            prefixIcon: Icons.phone_android_outlined,
                            controller: altPhoneCtrl,
                          ),
                        ]),
                        _buildResponsiveRow([
                          _buildDropdown(
                            label: "Lead Source *",
                            value: source,
                            items: sources,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => source = val);
                              }
                            },
                          ),
                          _buildDropdown(
                            label: "Lead Status",
                            value: status,
                            items: statuses,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => status = val);
                              }
                            },
                          ),
                        ]),
                        _buildResponsiveRow([
                          _buildDropdown(
                            label: "Sales Stage",
                            value: salesStage,
                            items: stages,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => salesStage = val);
                              }
                            },
                          ),
                          _buildDropdown(
                            label: "Priority",
                            value: priority,
                            items: priorities,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => priority = val);
                              }
                            },
                          ),
                        ]),
                        _buildResponsiveRow([
                          CustomTextField(
                            label: "Deal Value (₹)",
                            hint: "e.g., 50000",
                            prefixIcon: Icons.currency_rupee_outlined,
                            controller: valueCtrl,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return null;
                              return double.tryParse(val) == null ? "Number required" : null;
                            },
                          ),
                          CustomTextField(
                            label: "Probability (%)",
                            hint: "e.g., 80",
                            prefixIcon: Icons.percent_outlined,
                            controller: probabilityCtrl,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return null;
                              final n = double.tryParse(val);
                              if (n == null) return "Number required";
                              if (n < 0 || n > 100) return "Must be 0-100%";
                              return null;
                            },
                          ),
                        ]),
                        _buildResponsiveRow([
                          _buildDropdown(
                            label: "Timeline",
                            value: timeline,
                            items: timelines,
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => timeline = val);
                              }
                            },
                          ),
                          CustomTextField(
                            label: "Product Interest",
                            hint: "e.g., CRM Application",
                            prefixIcon: Icons.shopping_bag_outlined,
                            controller: productInterestCtrl,
                          ),
                        ]),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomTextField(
                            label: "Requirement",
                            hint: "e.g., CRM with calling feature and auto dialer",
                            prefixIcon: Icons.description_outlined,
                            controller: requirementCtrl,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "Address Details",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomTextField(
                            label: "Street Address",
                            hint: "e.g., Sector 17, SCO 24",
                            prefixIcon: Icons.home_outlined,
                            controller: streetCtrl,
                          ),
                        ),
                        _buildResponsiveRow([
                          CustomTextField(
                            label: "City",
                            hint: "e.g., Chandigarh",
                            prefixIcon: Icons.location_city_outlined,
                            controller: cityCtrl,
                          ),
                          CustomTextField(
                            label: "Pincode",
                            hint: "e.g., 160017",
                            prefixIcon: Icons.pin_drop_outlined,
                            controller: pincodeCtrl,
                          ),
                        ]),
                        _buildResponsiveRow([
                          CustomTextField(
                            label: "State",
                            hint: "e.g., Punjab",
                            prefixIcon: Icons.map_outlined,
                            controller: stateCtrl,
                          ),
                          const SizedBox(), // Empty spacer for layout alignment
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                ),
                CustomButton(
                  text: lead == null ? "Save Lead" : "Update Lead",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final parsedValue = double.tryParse(valueCtrl.text) ?? 0.0;
                      final parsedProb = double.tryParse(probabilityCtrl.text) ?? 0.0;

                      if (lead == null) {
                        final newLead = Lead(
                          id: "LD-${state.leads.length + 101}",
                          name: nameCtrl.text,
                          company: productInterestCtrl.text,
                          email: emailCtrl.text,
                          phone: phoneCtrl.text,
                          value: parsedValue,
                          status: status,
                          source: source,
                          dateCreated: DateTime.now(),
                          owner: state.currentUser?.name ?? "Sales Agent",
                          alternatePhone: altPhoneCtrl.text,
                          salesStage: salesStage,
                          probability: parsedProb,
                          timeline: timeline,
                          priority: priority,
                          requirement: requirementCtrl.text,
                          street: streetCtrl.text,
                          city: cityCtrl.text,
                          state: stateCtrl.text,
                          pincode: pincodeCtrl.text,
                        );
                        state.addLead(newLead);
                      } else {
                        final updatedLead = lead.copyWith(
                          name: nameCtrl.text,
                          company: productInterestCtrl.text,
                          email: emailCtrl.text,
                          phone: phoneCtrl.text,
                          value: parsedValue,
                          status: status,
                          source: source,
                          alternatePhone: altPhoneCtrl.text,
                          salesStage: salesStage,
                          probability: parsedProb,
                          timeline: timeline,
                          priority: priority,
                          requirement: requirementCtrl.text,
                          street: streetCtrl.text,
                          city: cityCtrl.text,
                          state: stateCtrl.text,
                          pincode: pincodeCtrl.text,
                        );
                        state.updateLead(updatedLead);
                      }
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

  void _showDeleteConfirmation(BuildContext context, Lead lead, MockDataService state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Delete Lead", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete lead '${lead.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                state.deleteLead(lead.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Deleting lead '${lead.name}'...")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primary, size: 22),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showLeadDialog(context, state, lead: lead);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showDeleteConfirmation(context, lead, state);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹${lead.value.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                        case 'Hot':
                          chipColor = Colors.red;
                          break;
                        case 'Cold':
                          chipColor = Colors.cyan;
                          break;
                        case 'Converted':
                          chipColor = AppColors.success;
                          break;
                        case 'Lost':
                          chipColor = AppColors.danger;
                          break;
                        case 'Follow-up':
                          chipColor = Colors.orange;
                          break;
                        default:
                          chipColor = Colors.grey;
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
                    onPressed: () => _showLeadDialog(context, state),
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
                              "₹${stageTotalValue.toStringAsFixed(0)} value",
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
                "₹${lead.value.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    onPressed: () => _showLeadDialog(context, state, lead: lead),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    onPressed: () => _showDeleteConfirmation(context, lead, state),
                  ),
                  const SizedBox(width: 8),
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
        ],
      ),
    );
  }
}
