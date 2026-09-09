import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/helper/custom_date_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/job_application_controller.dart';
import '../../repository/job_repository.dart';
import '../../data/model/job_application_request_model.dart';

class ResumeFormScreen extends GetView<JobApplicationController> {
  const ResumeFormScreen({super.key});

  // Re-defining the lists for UI use (can be moved to controller if needed, but keeping here for UI consistency as requested)
  static const List<String> languages = ['English', 'Hindi', 'Spanish', 'French', 'German'];
  static const List<String> universities = ['Delhi University', 'Mumbai University', 'Stanford University', 'MIT', 'IIT Delhi', 'IIT Bombay'];
  static const List<String> courses = ['B.Tech', 'B.Sc', 'M.Tech', 'MBA', 'MCA', 'BCA', 'BBA'];
  static const List<String> durations = ['1 Year', '2 Years', '3 Years', '4 Years', '5 Years'];
  static const List<String> gradingSystems = ['Percentage', 'CGPA', 'GPA', 'Grade'];
  static const List<String> availableSkills = [
    'Flutter', 'Dart', 'Firebase', 'REST API', 'UI/UX Design',
    'React Native', 'JavaScript', 'Python', 'Java', 'Swift'
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already present
    if (!Get.isRegistered<JobApplicationController>()) {
      final Map<String, dynamic> args = Get.arguments ?? {};
      final int jobId = args['jobId'] ?? 0;
      Get.put(JobApplicationController(
        repository: Get.find<JobRepository>(),
        jobId: jobId,
      ));
    }

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          'Occupation',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Obx(() => Container(
            color: AppColors.premiumGold.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (controller.currentStep.value + 1) / 4,
                  backgroundColor: AppColors.premiumGold.withOpacity(0.2),
                  color: AppColors.white,
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  _getStepTitle(controller.currentStep.value),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          )),

          Expanded(
            child: Obx(() {
              if (controller.isProfileLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.white));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildCurrentStep(context),
              );
            }),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.black,
              border: Border(top: BorderSide(color: AppColors.premiumGold.withOpacity(0.3))),
            ),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (controller.currentStep.value > 0)
                  ElevatedButton(
                    onPressed: controller.previousStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.premiumGold.withOpacity(0.3),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 18),
                        const SizedBox(width: 8),
                        Text('Back', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 100),

                if (controller.currentStep.value < 3)
                  ElevatedButton(
                    onPressed: controller.nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('Next', style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        )),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18, color: AppColors.white),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                      : Text(
                          'Apply',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                  ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Resume Upload & Basic Info';
      case 1: return 'Education Details';
      case 2: return 'Employment Details';
      case 3: return 'Key Skills';
      default: return '';
    }
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (controller.currentStep.value) {
      case 0: return _buildStep1(context);
      case 1: return _buildStep2(context);
      case 2: return _buildStep3(context);
      case 3: return _buildStep4(context);
      default: return const SizedBox();
    }
  }

  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.premiumGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_upload, color: AppColors.premiumGold.withOpacity(0.7)),
                  const SizedBox(width: 10),
                  Text(
                    'Upload Resume',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Supported formats: PDF, DOC, DOCX, JPG, PNG (Max 10MB)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => controller.isUploading.value ? null : controller.pickFile(),
                child: Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.premiumGold.withOpacity(0.4),
                      style: BorderStyle.solid,
                    ),
                    color: AppColors.white,
                  ),
                  child: Column(
                    children: [
                      if (controller.isUploading.value) ...[
                        CircularProgressIndicator(
                          value: controller.uploadProgress.value,
                          backgroundColor: AppColors.premiumGold.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Uploading... ${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(color: AppColors.premiumGold.withOpacity(0.7)),
                        ),
                      ] else if (controller.selectedFile.value != null) ...[
                        const Icon(Icons.check_circle, size: 48, color: Colors.green),
                        const SizedBox(height: 12),
                        Text(
                          'File Uploaded!',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        Text('Tap to change file', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.premiumGold)),
                      ] else ...[
                        Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.premiumGold.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text('Tap to upload resume', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.premiumGold.withOpacity(0.7))),
                      ],
                    ],
                  ),
                )),
              ),
              Obx(() => controller.selectedFile.value != null ? Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(_getFileIcon(controller.selectedFile.value!.extension ?? ''), style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(controller.selectedFile.value!.name, style: GoogleFonts.poppins(fontSize: 14), overflow: TextOverflow.ellipsis),
                              Text(_formatFileSize(controller.selectedFile.value!.size), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.premiumGold.withOpacity(0.6))),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => controller.selectedFile.value = null, icon: const Icon(Icons.delete_outline, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ) : const SizedBox()),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Resume Headline', style: _labelStyle()),
        const SizedBox(height: 6),
        TextField(controller: controller.resumeHeadlineController, decoration: _inputDecoration('e.g., Senior Flutter Developer')),
        const SizedBox(height: 16),
        Text('Cover Letter', style: _labelStyle()),
        const SizedBox(height: 6),
        TextField(controller: controller.coverMessageController, maxLines: 4, decoration: _inputDecoration('Enter your cover message...')),
        const SizedBox(height: 16),
        Text('Contact Number', style: _labelStyle()),
        const SizedBox(height: 6),
        TextField(controller: controller.phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration('Enter your Phone')),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.premiumGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school, color: AppColors.premiumGold.withOpacity(0.7)),
                  const SizedBox(width: 10),
                  Text(
                    'Education Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('University/Institute', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(controller: controller.universityController, decoration: _inputDecoration('e.g. University of Mumbai')),
              const SizedBox(height: 16),
              Text('Course', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(controller: controller.courseController, decoration: _inputDecoration('e.g. B.Tech CS')),
              const SizedBox(height: 16),
              Text('Course Type', style: _labelStyle()),
              const SizedBox(height: 6),
              Obx(() => Column(
                children: [
                  _radioButton('Full Time', 'full_time', controller.courseType.value, (val) => controller.courseType.value = val!),
                  _radioButton('Part Time', 'part_time', controller.courseType.value, (val) => controller.courseType.value = val!),
                  _radioButton('Distance', 'distance', controller.courseType.value, (val) => controller.courseType.value = val!),
                ],
              )),
              const SizedBox(height: 16),
              Text('Course Duration', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(controller: controller.durationController, decoration: _inputDecoration('e.g. 2020-2024')),
              const SizedBox(height: 16),
              Text('Grade/Percent', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(controller: controller.gradeController, decoration: _inputDecoration('e.g. 8.5')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.addEducation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Add Education', style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Obx(() => controller.educationList.isEmpty ? const SizedBox() : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Added Education', style: _labelStyle()),
            const SizedBox(height: 12),
            ...controller.educationList.asMap().entries.map((entry) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(Icons.school, color: Colors.blue[700]),
                title: Text(entry.value.courseName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('${entry.value.universityName} • ${entry.value.courseDuration}'),
                trailing: IconButton(onPressed: () => controller.removeEducation(entry.key), icon: const Icon(Icons.delete, color: Colors.red, size: 20)),
              ),
            )),
          ],
        )),
      ],
    );
  }

  Widget _buildStep3(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.premiumGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work, color: AppColors.premiumGold.withOpacity(0.7)),
                  const SizedBox(width: 10),
                  Text(
                    'Employment Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Currently working here?', style: _labelStyle()),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  Expanded(child: _buildRadioOption('Yes', true, controller.isCurrentEmployment.value, (val) => controller.isCurrentEmployment.value = val!)),
                  Expanded(child: _buildRadioOption('No', false, controller.isCurrentEmployment.value, (val) => controller.isCurrentEmployment.value = val!)),
                ],
              )),
              const SizedBox(height: 16),
              Text('Company Name', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(controller: controller.companyNameController, decoration: _inputDecoration('Enter company name')),
              const SizedBox(height: 16),
              Text('Job Title', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(controller: controller.jobTitleController, decoration: _inputDecoration('Enter job title')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDatePicker(context, 'Joining Date', controller.joiningDate)),
                  const SizedBox(width: 16),
                  Obx(() => controller.isCurrentEmployment.value ? const SizedBox() : Expanded(child: _buildDatePicker(context, 'Worked Till', controller.workedTillDate))),
                ],
              ),
              const SizedBox(height: 16),
              Text('Job Description', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(controller: controller.jobDescriptionController, maxLines: 3, decoration: _inputDecoration('Describe your role...')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.addEmployment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Add Employment', style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Obx(() => controller.employmentList.isEmpty ? const SizedBox() : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Added Employment', style: _labelStyle()),
            const SizedBox(height: 12),
            ...controller.employmentList.asMap().entries.map((entry) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(Icons.business, color: Colors.green[700]),
                title: Text(entry.value.jobTitle ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('${entry.value.companyName} • ${entry.value.isCurrentEmployment == true ? 'Current' : 'Previous'}'),
                trailing: IconButton(onPressed: () => controller.removeEmployment(entry.key), icon: const Icon(Icons.delete, color: Colors.red, size: 20)),
              ),
            )),
          ],
        )),
      ],
    );
  }

  Widget _buildStep4(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.premiumGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Skills', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  Obx(() => Text('${controller.selectedSkills.length}/10 selected', style: GoogleFonts.poppins(fontSize: 12, color: controller.selectedSkills.length >= 10 ? Colors.red : AppColors.premiumGold))),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 12,
                children: availableSkills.map((skill) {
                  return Obx(() {
                    bool isSelected = controller.selectedSkills.contains(skill);
                    return ChoiceChip(
                      label: Text(skill, style: GoogleFonts.poppins(fontSize: 13, color: isSelected ? AppColors.black : AppColors.white)),
                      selected: isSelected,
                      selectedColor: AppColors.premiumGold,
                      onSelected: (val) {
                        if (val) {
                          if (controller.selectedSkills.length < 10) controller.selectedSkills.add(skill);
                        } else {
                          controller.selectedSkills.remove(skill);
                        }
                      },
                    );
                  });
                }).toList(),
              ),
              const SizedBox(height: 32),
              Divider(color: AppColors.premiumGold.withOpacity(0.4), thickness: 1),
              const SizedBox(height: 24),
              Text('Add Custom Skill', style: _labelStyle()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: controller.skillController, decoration: _inputDecoration('e.g. Flutter, Python'))),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.white, Color(0xFF2C3E50)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () => controller.addSkill(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.transparent, shadowColor: AppColors.transparent),
                      child: Text('Add', style: GoogleFonts.poppins(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Obx(() => controller.selectedSkills.isEmpty ? _buildEmptySkillsState() : Wrap(
          spacing: 10,
          runSpacing: 12,
          children: controller.selectedSkills.map((skill) => Chip(
            label: Text(skill, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.white)),
            backgroundColor: AppColors.transparent,
            onDeleted: () => controller.removeSkill(skill),
            deleteIconColor: AppColors.white,
          )).toList(),
        )),
      ],
    );
  }

  Widget _buildEmptySkillsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.premiumGold.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(Icons.code_off, size: 32, color: AppColors.premiumGold.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text('No skills selected', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.premiumGold.withOpacity(0.7))),
      ]),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, Rxn<DateTime> date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        Obx(() => InkWell(
          onTap: () async {
            DateTime? picked = await CustomDatePicker.show(
              context: context,
              initialDate: date.value ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) date.value = picked;
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(date.value == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(date.value!), style: TextStyle(color: date.value == null ? AppColors.premiumGold : AppColors.white)),
              const Icon(Icons.calendar_today, size: 18),
            ]),
          ),
        )),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: AppColors.premiumGold.withOpacity(0.5), fontSize: 13),
      filled: true,
      fillColor: AppColors.black,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold.withOpacity(0.3))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white);

  Widget _radioButton(String title, String value, String groupValue, Function(String?) onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(value: value, groupValue: groupValue, onChanged: onChanged, activeColor: AppColors.white),
      Text(title, style: GoogleFonts.poppins(fontSize: 13)),
    ]);
  }

  Widget _buildRadioOption<T>(String title, T value, T groupValue, Function(T?) onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<T>(value: value, groupValue: groupValue, onChanged: onChanged, activeColor: AppColors.white),
      Text(title, style: GoogleFonts.poppins(fontSize: 13)),
    ]);
  }

  String _getFileIcon(String ext) {
    if (ext == 'pdf') return '📄';
    if (ext.contains('doc')) return '📝';
    if (['jpg', 'jpeg', 'png'].contains(ext)) return '🖼️';
    return '📎';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}