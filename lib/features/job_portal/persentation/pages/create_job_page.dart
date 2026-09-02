import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/network/app_urls.dart';
import '../controller/job_controller.dart';

class JobCreateScreen extends GetView<JobController> {
  const JobCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          controller.clearForm();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.white),
          title: Obx(() => Text(
            controller.isEditing.value ? 'Update Job Posting' : 'Create Job Posting',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          )),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo Upload
              Text('Company Logo', style: _labelStyle()),
              const SizedBox(height: 6),
              Obx(() {
                final hasLocalFile = controller.companyLogoFile.value != null;
                final hasNetworkLogo = controller.editingJobLogoUrl.value != null &&
                    controller.editingJobLogoUrl.value!.isNotEmpty;
                final hasAnyLogo = hasLocalFile || hasNetworkLogo;

                return GestureDetector(
                  onTap: () => _pickImage(),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: hasAnyLogo ? AppColors.white : AppColors.premiumGold.withOpacity(0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.premiumGold.withOpacity(0.1),
                        ),
                        child: hasLocalFile
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  controller.companyLogoFile.value!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : hasNetworkLogo
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      AppUrls.getFullImageUrl(controller.editingJobLogoUrl.value),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _logoPlaceholder(),
                                    ),
                                  )
                                : _logoPlaceholder(),
                      ),
                      if (hasAnyLogo)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, size: 12, color: AppColors.white),
                                SizedBox(width: 4),
                                Text('Change', style: TextStyle(color: AppColors.white, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              Text('Company/Individual Name', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.companyNameController,
                decoration: _inputDecoration('Enter company here'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.companyNameError),
              const SizedBox(height: 16),

              Text('Title', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.titleFormController,
                decoration: _inputDecoration('Enter Title'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.titleError),
              const SizedBox(height: 16),

              Text('Company Website', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.companyWebsiteController,
                decoration: _inputDecoration('Enter Company Website'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.websiteError),
              const SizedBox(height: 16),

              Text('Job Description', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.descriptionFormController,
                maxLines: 4,
                decoration: _inputDecoration('Enter description here'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.descriptionError),
              const SizedBox(height: 16),

              Text('Responsibilities (comma separated)', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.responsibilitiesController,
                maxLines: 3,
                decoration: _inputDecoration('Develop APIs, Database design...'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.responsibilitiesError),
              const SizedBox(height: 16),

              Text('Requirements (comma separated)', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.requirementsController,
                maxLines: 3,
                decoration: _inputDecoration('PHP, Laravel, MySQL...'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.requirementsError),
              const SizedBox(height: 16),

              Text('Location', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.locationController,
                decoration: _inputDecoration('Enter City/Location'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.locationError),
              const SizedBox(height: 16),

              Text('Country', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: controller.countryController,
                decoration: _inputDecoration('Enter Country'),
                onChanged: (_) => controller.validateForm(),
              ),
              _buildErrorText(controller.countryError),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Minimum Salary', style: _labelStyle()),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.minSalaryController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Enter Min'),
                          onChanged: (_) => controller.validateForm(),
                        ),
                        _buildErrorText(controller.minSalaryError),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maximum Salary', style: _labelStyle()),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.maxSalaryController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Enter Max'),
                          onChanged: (_) => controller.validateForm(),
                        ),
                        _buildErrorText(controller.maxSalaryError),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Currency', style: _labelStyle()),
              const SizedBox(height: 6),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCurrency.value,
                items: ['INR', 'USD', 'EUR']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(fontSize: 14)),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedCurrency.value = val;
                },
                decoration: _inputDecoration('Select Currency type'),
              )),
              const SizedBox(height: 16),

              Text('Status', style: _labelStyle()),
              const SizedBox(height: 6),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedStatus.value,
                items: ['published', 'draft', 'closed']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(fontSize: 14)),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedStatus.value = val;
                },
                decoration: _inputDecoration('Select Status type'),
              )),
              const SizedBox(height: 16),

              Text('Employment Type', style: _labelStyle()),
              const SizedBox(height: 6),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedEmploymentType.value,
                items: [
                  {'label': 'Full Time', 'value': 'full_time'},
                  {'label': 'Part Time', 'value': 'part_time'},
                  {'label': 'Remote', 'value': 'remote'},
                  {'label': 'Contract', 'value': 'contract'},
                ].map((type) => DropdownMenuItem(
                  value: type['value'] as String,
                  child: Text(type['label'] as String, style: const TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedEmploymentType.value = val;
                },
                decoration: _inputDecoration('Select Employment type'),
              )),
              const SizedBox(height: 16),

              Text('Work Mode & Priority', style: _labelStyle()),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  _buildToggleCard(
                   // emoji: '🏠',
                    label: 'Remote Job',
                    isActive: controller.isRemote.value,
                    activeColor:  AppColors.primary,
                    onTap: () => controller.isRemote.value = !controller.isRemote.value,
                  ),
                  const SizedBox(width: 12),
                  _buildToggleCard(
                   // emoji: '🔥',
                    label: 'Urgent Hire',
                    isActive: controller.isUrgent.value,
                    activeColor:  AppColors.primary,
                    onTap: () => controller.isUrgent.value = !controller.isUrgent.value,
                  ),
                ],
              )),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isCreating.value || !controller.isFormValid.value
                      ? null
                      : () => controller.createJob(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    disabledBackgroundColor: AppColors.premiumGold.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isCreating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : Text(
                          controller.isEditing.value ? 'Update Job' : 'Create Job',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                )),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      controller.companyLogoFile.value = File(image.path);
    }
  }

  Widget _buildErrorText(RxString error) {
    return Obx(() => error.value.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error.value,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox.shrink());
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.premiumGold.withOpacity(0.5)),
      filled: true,
      fillColor: AppColors.premiumGold.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  TextStyle _labelStyle() {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    );
  }

  Widget _logoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.business, size: 40, color: AppColors.premiumGold.withOpacity(0.4)),
        const SizedBox(height: 8),
        Text(
          'Tap to upload logo',
          style: TextStyle(
            color: AppColors.premiumGold.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.08) : AppColors.premiumGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? activeColor : AppColors.premiumGold.withOpacity(0.3),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
             // Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? activeColor : AppColors.premiumGold.withOpacity(0.7),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : AppColors.transparent,
                  border: Border.all(
                    color: isActive ? activeColor : AppColors.premiumGold.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: isActive
                    ? const Icon(Icons.check, size: 13, color: AppColors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
