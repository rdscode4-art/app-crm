import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/mock_data_service.dart';
import '../../models/asset.dart';
import '../../controllers/crm_controller.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<CrmController>()) {
        Get.find<CrmController>().fetchAssets();
      }
    });
  }

  void _showAddAssetDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final serialCtrl = TextEditingController();
    final assignedToCtrl = TextEditingController();
    String category = 'Laptop';
    String status = 'Available';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              title: const Text(
                "Register New Asset",
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
                        label: "Asset Name",
                        hint: "e.g. MacBook Pro 16\", Dell Monitor",
                        prefixIcon: Icons.devices,
                        controller: nameCtrl,
                        validator: (val) => val == null || val.isEmpty
                            ? "Asset name is required"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Serial Number",
                        hint: "e.g. SN-88273AHS, IMEI...",
                        prefixIcon: Icons.qr_code,
                        controller: serialCtrl,
                        validator: (val) => val == null || val.isEmpty
                            ? "Serial number is required"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Category",
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
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: category,
                            isExpanded: true,
                            items: ['Laptop', 'Phone', 'Accessory', 'Other']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  category = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Assigned To (Employee Name)",
                        hint: "Leave empty if unassigned",
                        prefixIcon: Icons.person_outline,
                        controller: assignedToCtrl,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Initial Status",
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
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: status,
                            isExpanded: true,
                            items: ['Available', 'Assigned', 'Maintenance']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  status = val;
                                });
                              }
                            },
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
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                CustomButton(
                  text: "Register Asset",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newAsset = CRMAsset(
                        id: "AST-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                        name: nameCtrl.text,
                        serialNumber: serialCtrl.text,
                        category: category,
                        assignedTo: assignedToCtrl.text.isEmpty
                            ? "Unassigned"
                            : assignedToCtrl.text,
                        status: status,
                        dateAssigned: DateTime.now(),
                      );
                      if (Get.isRegistered<CrmController>()) {
                        Get.find<CrmController>().submitAsset(newAsset);
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

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Obx(() {
      final list = state.assets;
      final controller = Get.isRegistered<CrmController>()
          ? Get.find<CrmController>()
          : null;
      final isLoading = controller?.isLoadingAssets.value ?? false;
      final error = controller?.assetsError.value;

      final filteredList = list.where((asset) {
        if (selectedFilter == 'All') return true;
        return asset.category == selectedFilter;
      }).toList();

      final total = list.length;
      final assigned = list.where((a) => a.status == 'Assigned').length;
      final available = list.where((a) => a.status == 'Available').length;
      final maintenance = list.where((a) => a.status == 'Maintenance').length;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Asset & Hardware Inventory",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Allocate, track, and manage company devices, laptops, and peripheral hardware.",
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
                  text: "Add Asset",
                  icon: Icons.add,
                  onPressed: () => _showAddAssetDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrics Summary Grid
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.35 : 2.0,
              ),
              children: [
                _buildMetricCard(
                  "Total Devices",
                  "$total",
                  Icons.devices,
                  AppColors.info,
                ),
                _buildMetricCard(
                  "Assigned",
                  "$assigned",
                  Icons.person,
                  AppColors.primary,
                ),
                _buildMetricCard(
                  "Available",
                  "$available",
                  Icons.check_circle,
                  Colors.teal,
                ),
                _buildMetricCard(
                  "Maintenance",
                  "$maintenance",
                  Icons.build,
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Laptop', 'Phone', 'Accessory', 'Other'].map((
                  cat,
                ) {
                  final isSelected = selectedFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      onSelected: (val) {
                        setState(() {
                          selectedFilter = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Asset Inventory List Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Text(
                          "Error loading assets: $error",
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    )
                  else if (filteredList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No devices match this category yet",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (context, index) {
                        final asset = filteredList[index];
                        return _buildAssetRow(context, asset);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(BuildContext context, CRMAsset asset) {
    Color badgeColor;
    Color textColor;
    switch (asset.status) {
      case 'Available':
        badgeColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case 'Assigned':
        badgeColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        break;
      case 'Maintenance':
        badgeColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      default:
        badgeColor = AppColors.border;
        textColor = AppColors.textPrimary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Device category icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              asset.category == 'Laptop'
                  ? Icons.laptop_mac
                  : asset.category == 'Phone'
                  ? Icons.phone_android
                  : Icons.device_hub,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Name and Serial
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "S/N: ${asset.serialNumber}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Assigned to
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ASSIGNED TO",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  asset.assignedTo,
                  style: TextStyle(
                    color: asset.assignedTo == 'Unassigned'
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: asset.assignedTo == 'Unassigned'
                        ? FontWeight.normal
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              asset.status.toUpperCase(),
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
