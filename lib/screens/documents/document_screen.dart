import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/document.dart';
import '../../controllers/crm_controller.dart';
import '../../services/mock_data_service.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final List<String> _categories = [
    'All',
    'Agreement',
    'Offer Letter',
    'Payslip',
    'Other',
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CrmController>().fetchDocuments();
    });
  }

  void _showUploadDialog(BuildContext context, CrmController controller) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController(
      text: "https://crmb.ridealmobility.com/uploads/doc.pdf",
    );
    final sizeCtrl = TextEditingController(text: "1.2 MB");
    String category = 'Agreement';

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
                "Upload Document Record",
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
                        label: "Document Title",
                        hint: "e.g., Q3 Project Proposal.pdf",
                        prefixIcon: Icons.description_outlined,
                        controller: titleCtrl,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Document Category",
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
                            items:
                                [
                                      'Agreement',
                                      'Offer Letter',
                                      'Payslip',
                                      'Other',
                                    ]
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
                        label: "File Storage Link / URL",
                        hint: "e.g., https://...",
                        prefixIcon: Icons.link_outlined,
                        controller: urlCtrl,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Estimated File Size",
                        hint: "e.g., 2.5 MB",
                        prefixIcon: Icons.data_usage_outlined,
                        controller: sizeCtrl,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Required" : null,
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
                  text: "Submit File",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final mockData = MockDataService();
                      final doc = CRMDocument(
                        id: "DOC-${controller.documents.length + 100}",
                        title: titleCtrl.text,
                        category: category,
                        fileUrl: urlCtrl.text,
                        size: sizeCtrl.text,
                        uploadedBy: mockData.currentUser?.name ?? "Admin User",
                        uploadDate: DateTime.now(),
                      );
                      controller.submitDocument(doc);
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
    final controller = Get.find<CrmController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Obx(() {
      final filteredDocs = _selectedCategory == 'All'
          ? controller.documents
          : controller.documents.where((d) {
              final cat = d.category.toLowerCase();
              final sel = _selectedCategory.toLowerCase();
              if (cat == sel) return true;
              if (sel == 'agreement' &&
                  (cat == 'contract' || cat == 'agreement'))
                return true;
              if (sel == 'offer letter' &&
                  (cat == 'offer-letter' || cat == 'offer letter'))
                return true;
              if (sel == 'payslip' && (cat == 'invoice' || cat == 'payslip'))
                return true;
              return false;
            }).toList();

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
                        "Document Management Hub",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Access secure cloud resources, store contracts, and upload operations files.",
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
                  text: "Upload File",
                  icon: Icons.upload_file_outlined,
                  onPressed: () => _showUploadDialog(context, controller),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Loading indicator
            if (controller.isLoadingDocuments.value) ...[
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error display
            if (controller.documentsError.value != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.documentsError.value!,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        backgroundColor: AppColors.danger.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        "Retry",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => controller.fetchDocuments(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Categories Selector Scrollbar
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSel = _selectedCategory == cat;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: isSel ? AppColors.primary : AppColors.border,
                      ),
                      labelStyle: TextStyle(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                          String? docType;
                          if (cat != 'All') {
                            docType = cat.toLowerCase();
                          }
                          controller.fetchDocuments(documentType: docType);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Documents Grid / List Table
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Secure Cloud Files & Records",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredDocs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No document records listed.",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 110,
                      ),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, idx) {
                        final doc = filteredDocs[idx];
                        final formattedDate =
                            "${doc.uploadDate.day}/${doc.uploadDate.month}/${doc.uploadDate.year}";

                        IconData fileIcon;
                        Color iconColor;
                        final normalizedCat = doc.category.toLowerCase();
                        switch (normalizedCat) {
                          case 'agreement':
                          case 'contract':
                            fileIcon = Icons.gavel_outlined;
                            iconColor = Colors.purple;
                            break;
                          case 'offer letter':
                          case 'offer-letter':
                          case 'resume':
                            fileIcon = Icons.badge_outlined;
                            iconColor = Colors.orange;
                            break;
                          case 'payslip':
                          case 'invoice':
                            fileIcon = Icons.receipt_long_outlined;
                            iconColor = Colors.green;
                            break;
                          case 'sop':
                            fileIcon = Icons.rule_folder_outlined;
                            iconColor = Colors.blue;
                            break;
                          default:
                            fileIcon = Icons.article_outlined;
                            iconColor = Colors.grey;
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: iconColor.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  fileIcon,
                                  color: iconColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      doc.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${doc.size} • $formattedDate",
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "By: ${doc.uploadedBy}",
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.download_for_offline_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Get.snackbar(
                                    "Downloading File",
                                    "Downloading ${doc.title} from cloud servers...",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.white,
                                    colorText: AppColors.textPrimary,
                                    borderWidth: 1,
                                    borderColor: AppColors.border,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
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
}
