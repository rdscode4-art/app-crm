import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/lead.dart';
import '../../models/call_log.dart';
import '../../services/mock_data_service.dart';
import '../../controllers/crm_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:call_log/call_log.dart' as call_log_plugin;
import 'package:permission_handler/permission_handler.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final List<String> _stages = ['New', 'Assigned', 'Hot', 'Cold', 'Converted', 'Lost', 'Follow-up'];

  bool _callInitiated = false;
  Lead? _lastCalledLead;
  DateTime? _callStartTime;

  bool _isBulkAssignMode = false;
  Set<String> _selectedLeadIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: _stages.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CrmController>().fetchLeads();
    });
  }

  bool _isAssigned(Lead l) {
    return l.owner.isNotEmpty && l.owner.toLowerCase() != 'sales agent' && l.owner.toLowerCase() != 'unassigned';
  }

  List<Lead> _getStageLeads(List<Lead> allLeads, String stage) {
    if (stage == 'New') {
      return allLeads.where((l) => l.status == 'New' && !_isAssigned(l)).toList();
    }
    if (stage == 'Assigned') {
      return allLeads.where((l) => (l.status == 'New' || l.status == 'Assigned') && _isAssigned(l)).toList();
    }
    return allLeads.where((l) => l.status == stage).toList();
  }

  String _getDisplayOwner(String owner, MockDataService state) {
    if (owner.isEmpty || owner == 'Sales Agent') return "Unassigned";
    final emp = state.employees.where((e) => e.id == owner).firstOrNull;
    if (emp != null) return emp.name;
    return owner; // fallback to raw string if it was already the name
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _callInitiated) {
      _callInitiated = false;
      if (_lastCalledLead != null && _callStartTime != null) {
        _checkCallLogAndSave(_lastCalledLead!, _callStartTime!);
      }
    }
  }

  Future<void> _checkCallLogAndSave(Lead lead, DateTime startTime) async {
    // Wait a short moment for native call logs to update
    await Future.delayed(const Duration(seconds: 2));

    int durationMinutes = 0;
    String outcome = 'Connected';
    bool logFound = false;

    try {
      if (await Permission.phone.request().isGranted) {
        Iterable<call_log_plugin.CallLogEntry> entries = await call_log_plugin.CallLog.query(
          dateFrom: startTime.millisecondsSinceEpoch,
        );

        if (entries.isNotEmpty) {
          final entry = entries.firstWhere(
            (e) => e.number != null && (e.number!.contains(lead.phone) || lead.phone.contains(e.number!)),
            orElse: () => call_log_plugin.CallLogEntry(),
          );

          if (entry.number != null) {
            logFound = true;
            int durationSeconds = entry.duration ?? 0;
            durationMinutes = (durationSeconds / 60).ceil();
            
            if (entry.callType == call_log_plugin.CallType.missed) outcome = 'No Answer';
            if (entry.callType == call_log_plugin.CallType.rejected) outcome = 'Busy';
          }
        }
      }
    } catch (e) {
      debugPrint("Error reading call logs: $e");
    }

    if (mounted) {
      final notesCtrl = TextEditingController();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          void saveLog(String notes) {
            final state = MockDataService();
            final log = CallLog(
              id: "CALL-${DateTime.now().millisecondsSinceEpoch}",
              leadId: lead.id,
              leadName: lead.name,
              employeeId: state.currentUser?.id ?? "EMP-000",
              employeeName: state.currentUser?.name ?? "Sales Agent",
              durationMinutes: durationMinutes,
              outcome: outcome,
              notes: notes.isEmpty ? "Auto-logged from phone dialer." : notes,
              timestamp: DateTime.now(),
            );
            state.addCallLog(log);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Logged call with ${lead.name} ($durationMinutes mins)")),
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.white,
            title: const Text("Follow-up Details", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (logFound)
                  Text("Call with ${lead.name} ended ($durationMinutes mins).", style: const TextStyle(fontWeight: FontWeight.w500))
                else
                  Text("Call with ${lead.name} finished.", style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: "Add description or remarks",
                    hintText: "What was discussed?",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  saveLog("Auto-logged from phone dialer.");
                  Navigator.pop(dialogContext);
                },
                child: const Text("Skip", style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  saveLog(notesCtrl.text);
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Save Notes"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _initiateCall(Lead lead) async {
    final Uri url = Uri.parse('tel:${lead.phone}');
    if (await canLaunchUrl(url)) {
      _callInitiated = true;
      _lastCalledLead = lead;
      _callStartTime = DateTime.now();
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch phone dialer.")),
        );
      }
    }
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

    // Owner logic
    final Set<String> employeeNamesSet = state.employees
        .where((e) => e.department.toLowerCase() == 'sales')
        .map((e) => e.name)
        .toSet();
    if (state.currentUser != null) {
      employeeNamesSet.add(state.currentUser!.name);
    }
    if (employeeNamesSet.isEmpty) employeeNamesSet.add("Sales Agent");

    String owner = lead?.owner ?? state.currentUser?.name ?? "Sales Agent";
    employeeNamesSet.add(owner);
    
    final List<String> employeeNames = employeeNamesSet.toList();

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
      Map<String, String>? itemLabels,
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
              fontSize: 15,
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
                  child: Text(itemLabels?[item] ?? item, style: const TextStyle(fontSize: 14)),
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
                          if (state.currentRole != UserRole.employee)
                            _buildDropdown(
                              label: "Assign To",
                              value: owner,
                              items: employeeNames,
                              itemLabels: {
                                for (var name in employeeNames)
                                  name: state.employees.any((e) => e.name == name)
                                      ? "$name (${state.employees.firstWhere((e) => e.name == name).department})"
                                      : name
                              },
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => owner = val);
                                }
                              },
                            ),
                        ]),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomTextField(
                            label: "Product Interest",
                            hint: "e.g., CRM Application",
                            prefixIcon: Icons.shopping_bag_outlined,
                            controller: productInterestCtrl,
                          ),
                        ),
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
                              fontSize: 16,
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
                          owner: owner,
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
                          owner: owner,
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

  void _showCallHistoryDialog(BuildContext context, Lead lead, MockDataService state) {
    final calls = state.callLogs.where((log) => log.leadId == lead.id).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          title: Text("Call History: ${lead.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            height: 400,
            child: calls.isEmpty
                ? const Center(child: Text("No calls logged for this lead yet.", style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    itemCount: calls.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final log = calls[index];
                      final dateStr = "${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}";
                      final timeStr = "${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}";
                      
                      Color outcomeColor = AppColors.success;
                      if (log.outcome == 'No Answer' || log.outcome == 'Voicemail') outcomeColor = AppColors.warning;
                      if (log.outcome == 'Busy') outcomeColor = AppColors.danger;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: outcomeColor.withValues(alpha: 0.1),
                          child: Icon(Icons.phone_in_talk, color: outcomeColor, size: 18),
                        ),
                        title: Text(log.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("$dateStr at $timeStr • ${log.durationMinutes} min", style: const TextStyle(fontSize: 12)),
                            if (log.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(log.notes, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: outcomeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(log.outcome, style: TextStyle(color: outcomeColor, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
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

  void _showLogCallDialog(BuildContext context, Lead lead, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final durationCtrl = TextEditingController(text: "5");
    final notesCtrl = TextEditingController();
    String outcome = 'Connected';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              title: const Text("Log a Call", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Lead: ${lead.name}", style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Duration (minutes)",
                        hint: "e.g., 5",
                        prefixIcon: Icons.timer,
                        controller: durationCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Required";
                          if (int.tryParse(val) == null) return "Must be a number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Outcome",
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: outcome,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['Connected', 'Voicemail', 'Busy', 'No Answer']
                            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => outcome = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Notes",
                        hint: "Discussion summary...",
                        prefixIcon: Icons.notes,
                        controller: notesCtrl,
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
                  text: "Save Call",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final log = CallLog(
                        id: "CALL-${DateTime.now().millisecondsSinceEpoch}",
                        leadId: lead.id,
                        leadName: lead.name,
                        employeeId: state.currentUser?.id ?? "EMP-000",
                        employeeName: state.currentUser?.name ?? "Sales Agent",
                        durationMinutes: int.parse(durationCtrl.text),
                        outcome: outcome,
                        notes: notesCtrl.text,
                        timestamp: DateTime.now(),
                      );
                      state.addCallLog(log);
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String? selectedRole;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
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
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 0,
                          runSpacing: 0,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.green, size: 22),
                              tooltip: "Call Now",
                              onPressed: () {
                                Navigator.of(context).pop();
                                _initiateCall(lead);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone, color: AppColors.primary, size: 22),
                              tooltip: "Log Call Manually",
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showLogCallDialog(context, lead, state);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.history, color: AppColors.info, size: 22),
                              tooltip: "View Call History",
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showCallHistoryDialog(context, lead, state);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary, size: 22),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showLeadDialog(context, state, lead: lead);
                              },
                            ),
                            if (state.currentRole == UserRole.superAdmin)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showDeleteConfirmation(context, lead, state);
                                },
                              ),
                          ],
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
                      fontSize: 16,
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (state.currentRole != UserRole.employee) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Quick Assign",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      hint: const Text("Select Agent to Assign"),
                      items: state.employees.where((e) => e.department.toLowerCase() == 'sales').map((e) => e.id).toSet().map((id) {
                        final emp = state.employees.firstWhere((e) => e.id == id);
                        return DropdownMenuItem(value: emp.id, child: Text("${emp.name} (${emp.department})"));
                      }).toList(),
                      onChanged: (empId) {
                        if (empId != null && Get.isRegistered<CrmController>()) {
                          Get.find<CrmController>().assignLead(lead.id, empId);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Assigning lead to agent...")),
                          );
                        }
                      },
                    ),
                  ],
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
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_isBulkAssignMode) ...[
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isBulkAssignMode = false;
                          _selectedLeadIds.clear();
                        });
                      },
                      child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text("Assign (${_selectedLeadIds.length})"),
                      onPressed: _selectedLeadIds.isEmpty
                          ? null
                          : () => _showBulkAssignDialog(context, state),
                    ),
                  ] else ...[
                    if (state.currentRole != UserRole.employee) ...[
                      CustomButton(
                        text: "Bulk Assign",
                        icon: Icons.checklist,
                        backgroundColor: AppColors.info,
                        onPressed: () {
                          setState(() {
                            _isBulkAssignMode = true;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (state.currentRole == UserRole.superAdmin)
                      CustomButton(
                        text: "Create Lead",
                        icon: Icons.add,
                        onPressed: () => _showLeadDialog(context, state),
                      ),
                  ],
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
                            fontSize: 15,
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
                        label: const Text("Retry", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                    final stageLeads = _getStageLeads(controller.leads, stage);
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
                                    fontSize: 14,
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
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${stageTotalValue.toStringAsFixed(0)} value",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
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
                        final count = _getStageLeads(controller.leads, st).length;
                        return Tab(text: "$st ($count)");
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _tabController,
                        children: _stages.map((st) {
                          final stageLeads = _getStageLeads(controller.leads, st);
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
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isBulkAssignMode)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _selectedLeadIds.contains(lead.id),
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedLeadIds.add(lead.id);
                        } else {
                          _selectedLeadIds.remove(lead.id);
                        }
                      });
                    },
                  ),
                )
              else
                const Icon(Icons.star, color: Colors.amber, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            lead.company,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${lead.value.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (_isAssigned(lead))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Agent: ${_getDisplayOwner(lead.owner, state)}",
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, size: 16, color: Colors.green),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    onPressed: () => _initiateCall(lead),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    onPressed: () => _showLeadDialog(context, state, lead: lead),
                  ),
                  const SizedBox(width: 8),
                  if (state.currentRole == UserRole.superAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 16,
                      onPressed: () => _showDeleteConfirmation(context, lead, state),
                    ),
                    const SizedBox(width: 8),
                  ],
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

  void _showBulkAssignDialog(BuildContext context, MockDataService state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bulk Assign ${_selectedLeadIds.length} Leads",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                hint: const Text("Select Agent to Assign"),
                items: state.employees.where((e) => e.department.toLowerCase() == 'sales').map((e) => e.id).toSet().map((id) {
                  final emp = state.employees.firstWhere((e) => e.id == id);
                  return DropdownMenuItem(value: emp.id, child: Text("${emp.name} (${emp.department})"));
                }).toList(),
                onChanged: (empId) {
                  if (empId != null && Get.isRegistered<CrmController>()) {
                    Get.find<CrmController>().bulkAssignLeads(_selectedLeadIds.toList(), empId);
                    setState(() {
                      _isBulkAssignMode = false;
                      _selectedLeadIds.clear();
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Assigning leads to agent...")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
