import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ResumeFormScreen extends StatefulWidget {
  const ResumeFormScreen({super.key});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final TextEditingController _resumeHeadlineController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobProfileController = TextEditingController();
  final TextEditingController _newSkillController = TextEditingController();

  // File upload variables
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Dropdown values
  String? _selectedLanguage;
  String? _selectedUniversity;
  String? _selectedCourse;
  String? _selectedDuration;
  String? _selectedGradingSystem;
  String? _selectedCurrentEmployment;

  // Radio button values
  String _courseType = 'full_time';
  String _currentEmployment = 'no';

  // Date values
  DateTime? _joiningDate;
  DateTime? _workedTillDate;

  // Grade value
  double? _gradeValue;

  // Lists
  List<String> languages = ['English', 'Hindi', 'Spanish', 'French', 'German'];
  List<String> universities = ['Delhi University', 'Mumbai University', 'Stanford University', 'MIT', 'IIT Delhi', 'IIT Bombay'];
  List<String> courses = ['B.Tech', 'B.Sc', 'M.Tech', 'MBA', 'MCA', 'BCA', 'BBA'];
  List<String> durations = ['1 Year', '2 Years', '3 Years', '4 Years', '5 Years'];
  List<String> gradingSystems = ['Percentage', 'CGPA', 'GPA', 'Grade'];
  List<String> _selectedSkills = [];
  List<String> _availableSkills = [
    'Flutter', 'Dart', 'Firebase', 'REST API', 'UI/UX Design',
    'React Native', 'JavaScript', 'Python', 'Java', 'Swift'
  ];

  // Education list
  List<Map<String, dynamic>> _educationList = [];

  // Employment list
  List<Map<String, dynamic>> _employmentList = [];

  // Step management
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Resume Upload & Basic Info',
    'Education Details',
    'Employment Details',
    'Key Skills'
  ];

  // File upload method
  Future<void> _pickAndUploadFile() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        // Simulate upload progress
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {
            _uploadProgress = i / 100;
          });
        }

        setState(() {
          _selectedFile = result.files.first;
          _isUploading = false;
        });

        _showUploadSuccessSnackbar();
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackbar('Error uploading file: $e');
    }
  }

  void _showUploadSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedFile!.name} uploaded successfully!',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      default:
        return '📎';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Occupation',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: Colors.grey[200],
                  color: Colors.black,
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  _stepTitles[_currentStep],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildCurrentStep(),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: _previousStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
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

                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('Next', style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        )),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resume Upload Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_upload, color: Colors.grey[700]),
                  const SizedBox(width: 10),
                  Text(
                    'Upload Resume',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // File Types Info
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

              // Upload Area
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[400]!,
                      style: BorderStyle.solid,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      if (_isUploading) ...[
                        CircularProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                          ),
                        ),
                      ] else if (_selectedFile != null) ...[
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'File Uploaded!',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to change file',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to upload resume',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PDF, DOC, JPG, PNG supported',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Selected File Details
              if (_selectedFile != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getFileIcon(_selectedFile!.extension ?? ''),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFile!.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatFileSize(_selectedFile!.size),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                          });
                        },
                        icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Resume Headline
        // Text('Resume Headline', style: _labelStyle()),
        // const SizedBox(height: 6),
        // TextField(
        //   controller: _resumeHeadlineController,
        //   decoration: _inputDecoration('e.g., Senior Flutter Developer'),
        // ),
        // const SizedBox(height: 16),

        // Cover Letter
        Text('Resume Headline', style: _labelStyle()),
        const SizedBox(height: 6),
        TextField(
          controller: _coverLetterController,
          maxLines: 4,
          decoration: _inputDecoration('Enter Resume Headline here...'),
        ),

        const SizedBox(height: 16),

        // Additional Upload Section (Optional)
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: Colors.grey[50],
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.grey[300]!),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Text(
        //             'Additional Documents',
        //             style: GoogleFonts.poppins(
        //               fontWeight: FontWeight.w600,
        //               fontSize: 14,
        //             ),
        //           ),
        //           Text(
        //             'Portfolio, Certificates, etc.',
        //             style: GoogleFonts.poppins(
        //               fontSize: 12,
        //               color: Colors.grey[600],
        //             ),
        //           ),
        //         ],
        //       ),
        //       ElevatedButton.icon(
        //         onPressed: () {
        //           // Additional upload logic
        //           _showAdditionalUploadDialog();
        //         },
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.white,
        //           foregroundColor: Colors.black,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(6),
        //             side: BorderSide(color: Colors.grey[300]!),
        //           ),
        //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //         ),
        //         icon: const Icon(Icons.add, size: 18),
        //         label: Text('Add', style: GoogleFonts.poppins(fontSize: 12)),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Education Form
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school, color: Colors.grey[700]),
                  const SizedBox(width: 10),
                  Text(
                    'Education Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Language
              Text('Language', style: _labelStyle()),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: _inputDecoration('Select Language'),
                items: languages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                )).toList(),
                onChanged: (val) => setState(() => _selectedLanguage = val),
              ),
              const SizedBox(height: 16),

              // University
              Text('University/Institute', style: _labelStyle()),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedUniversity,
                decoration: _inputDecoration('Select University'),
                items: universities.map((uni) => DropdownMenuItem(
                  value: uni,
                  child: Text(uni),
                )).toList(),
                onChanged: (val) => setState(() => _selectedUniversity = val),
              ),
              const SizedBox(height: 16),

              // Course
              Text('Course', style: _labelStyle()),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: _inputDecoration('Select Course'),
                items: courses.map((course) => DropdownMenuItem(
                  value: course,
                  child: Text(course),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCourse = val),
              ),
              const SizedBox(height: 16),

              // Course Type Radio Buttons
              Text('Course Type', style: _labelStyle()),
              const SizedBox(height: 8),
              Column(
                children: [
                  // Expanded(
                  //   child:
                    _radioButton('Full Time', 'full_time'),
                  //),
                //  Expanded(
                   // child:
                    _radioButton('Part Time', 'part_time'),
                 // ),
                //  Expanded(
                  //  child:
                    _radioButton('Distance', 'distance'),
                 // ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration
              Text('Course Duration', style: _labelStyle()),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: _inputDecoration('Select Duration'),
                items: durations.map((duration) => DropdownMenuItem(
                  value: duration,
                  child: Text(duration),
                )).toList(),
                onChanged: (val) => setState(() => _selectedDuration = val),
              ),
              const SizedBox(height: 16),

              // Grading System
              Text('Grading System', style: _labelStyle()),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedGradingSystem,
                decoration: _inputDecoration('Select Grading System'),
                items: gradingSystems.map((system) => DropdownMenuItem(
                  value: system,
                  child: Text(system),
                )).toList(),
                onChanged: (val) => setState(() => _selectedGradingSystem = val),
              ),
              const SizedBox(height: 16),

              // Grade/CGPA
              Text('Grade/CGPA/Percentage', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                decoration: _inputDecoration('e.g., 8.5 or 85%'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _gradeValue = double.tryParse(value);
                },
              ),
              const SizedBox(height: 16),

              // Description
              Text('Description', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Add description about your education...'),
              ),
              const SizedBox(height: 20),

              // Add Education Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addEducation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Education',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Added Education List
        if (_educationList.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Added Education', style: _labelStyle()),
          const SizedBox(height: 10),
          ..._educationList.asMap().entries.map((entry) {
            final index = entry.key;
            final edu = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(Icons.school, color: Colors.blue[700]),
                title: Text(
                  '${edu['course']} - ${edu['university']}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${edu['courseType']} • ${edu['duration']} • ${edu['gradingSystem']}: ${edu['grade']}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeEducation(index),
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employment Form
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work, color: Colors.grey[700]),
                  const SizedBox(width: 10),
                  Text(
                    'Employment Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current Employment Radio
              Text('Is this your current employment?', style: _labelStyle()),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _employmentRadioButton('Yes', 'yes'),
                  ),
                  Expanded(
                    child: _employmentRadioButton('No', 'no'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Company Name
              Text('Company Name', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: _companyNameController,
                decoration: _inputDecoration('Enter company name'),
              ),
              const SizedBox(height: 16),

              // Job Title
              Text('Job Title', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: _jobTitleController,
                decoration: _inputDecoration('Enter job title'),
              ),
              const SizedBox(height: 16),

              // Dates Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Joining Date', style: _labelStyle()),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _pickDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _joiningDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_joiningDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _joiningDate != null ? Colors.black : Colors.grey[500],
                                  ),
                                ),
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Worked Till', style: _labelStyle()),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _pickDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _workedTillDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_workedTillDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _workedTillDate != null ? Colors.black : Colors.grey[500],
                                  ),
                                ),
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Job Profile
              Text('Job Profile', style: _labelStyle()),
              const SizedBox(height: 6),
              TextField(
                controller: _jobProfileController,
                maxLines: 3,
                decoration: _inputDecoration('Describe your job profile...'),
              ),
              const SizedBox(height: 20),

              // Add Employment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addEmployment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Employment',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Added Employment List
        if (_employmentList.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Added Employment', style: _labelStyle()),
          const SizedBox(height: 10),
          ..._employmentList.asMap().entries.map((entry) {
            final index = entry.key;
            final emp = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(Icons.business, color: Colors.green[700]),
                title: Text(
                  emp['jobTitle'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${emp['companyName']} • ${emp['isCurrent'] == 'yes' ? 'Current' : 'Previous'}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeEmployment(index),
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: Colors.grey[700]),
                  const SizedBox(width: 10),
                  Text(
                    'Key Skills',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Available Skills Grid
              Text('Select Skills', style: _labelStyle()),
              const SizedBox(height: 10),
              /*Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableSkills.map((skill) {
                  bool isSelected = _selectedSkills.contains(skill);
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),*/

              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  bool isSelected = _selectedSkills.contains(skill);
                  bool isMaxReached = _selectedSkills.length >= 10 && !isSelected;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                          : null,
                    ),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          Text(
                            skill,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : isMaxReached
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: !isMaxReached
                          ? (selected) {
                        setState(() {
                          if (selected) {
                            if (_selectedSkills.length < 10) {
                              _selectedSkills.add(skill);
                            }
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      }
                          : null,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey.shade50,
                      disabledColor: Colors.grey.shade50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : isMaxReached
                            ? Colors.grey.shade200
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                      elevation: 0,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Add Custom Skill
              Text('Add Custom Skill', style: _labelStyle()),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSkillController,
                      decoration: _inputDecoration('Enter new skill'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addNewSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outlined,color: Colors.white,),
                        SizedBox(width: 5,),
                        Text(
                          'Add',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

        // Selected Skills List
        if (_selectedSkills.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 18,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected Skills',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _selectedSkills.map((skill) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Chip(
                  label: Text(
                    skill,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white70,
                  ),
                  onDeleted: () {
                    setState(() {
                      _selectedSkills.remove(skill);
                    });
                  },
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }


  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Gradient
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.code,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Skills & Expertise',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Main Skills Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade50,
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Skills Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Skills',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${_selectedSkills.length}/10 selected',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _selectedSkills.length >= 10
                          ? Colors.red.shade600
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Available Skills Grid
              Wrap(
                spacing: 10,
                runSpacing: 12,
                children: _availableSkills.map((skill) {
                  bool isSelected = _selectedSkills.contains(skill);
                  bool isMaxReached = _selectedSkills.length >= 10 && !isSelected;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                          : null,
                    ),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          Text(
                            skill,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : isMaxReached
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: !isMaxReached
                          ? (selected) {
                        setState(() {
                          if (selected) {
                            if (_selectedSkills.length < 10) {
                              _selectedSkills.add(skill);
                            }
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      }
                          : null,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey.shade50,
                      disabledColor: Colors.grey.shade50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : isMaxReached
                            ? Colors.grey.shade200
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                      elevation: 0,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Divider
              Divider(
                color: Colors.grey.shade400,
                thickness: 1,
              ),

              const SizedBox(height: 24),

              // Add Custom Skill Section
              Text(
                'Add Custom Skill',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSkillController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Flutter, Python, UI/UX',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _addNewSkill(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.black, Color(0xFF2C3E50)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _selectedSkills.length >= 10
                            ? null
                            : _addNewSkill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Add',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_selectedSkills.length >= 10) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Maximum 10 skills allowed',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Selected Skills Section
        if (_selectedSkills.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Skills',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedSkills.length} skills',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: _selectedSkills.map((skill) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Chip(
                        label: Text(
                          skill,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white70,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedSkills.remove(skill);
                          });
                        },
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],

        // Empty State
        if (_selectedSkills.isEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.code_off,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No skills selected',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select skills from above or add custom skills',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Helper Methods
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  TextStyle _labelStyle() {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
  }

  Widget _radioButton(String title, String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _courseType,
          onChanged: (val) => setState(() => _courseType = val!),
          fillColor: MaterialStateColor.resolveWith((states) => Colors.black),
        ),
        Text(title, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  Widget _employmentRadioButton(String title, String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _currentEmployment,
          onChanged: (val) => setState(() => _currentEmployment = val!),
          fillColor: MaterialStateColor.resolveWith((states) => Colors.black),
        ),
        Text(title, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  // Business Logic Methods
  void _addEducation() {
    if (_selectedCourse != null && _selectedUniversity != null) {
      setState(() {
        _educationList.add({
          'language': _selectedLanguage ?? languages.first,
          'university': _selectedUniversity!,
          'course': _selectedCourse!,
          'courseType': _courseType,
          'duration': _selectedDuration ?? durations.first,
          'gradingSystem': _selectedGradingSystem ?? gradingSystems.first,
          'grade': _gradeValue?.toString() ?? 'N/A',
          'description': _descriptionController.text,
        });

        // Reset fields
        _selectedLanguage = null;
        _selectedUniversity = null;
        _selectedCourse = null;
        _selectedDuration = null;
        _selectedGradingSystem = null;
        _gradeValue = null;
        _descriptionController.clear();
      });
    }
  }

  void _removeEducation(int index) {
    setState(() {
      _educationList.removeAt(index);
    });
  }

  void _addEmployment() {
    if (_companyNameController.text.isNotEmpty && _jobTitleController.text.isNotEmpty) {
      setState(() {
        _employmentList.add({
          'isCurrent': _currentEmployment,
          'companyName': _companyNameController.text,
          'jobTitle': _jobTitleController.text,
          'joiningDate': _joiningDate != null ? DateFormat('dd/MM/yyyy').format(_joiningDate!) : 'Not specified',
          'workedTill': _workedTillDate != null ? DateFormat('dd/MM/yyyy').format(_workedTillDate!) : 'Present',
          'jobProfile': _jobProfileController.text,
        });

        // Reset fields
        _currentEmployment = 'no';
        _companyNameController.clear();
        _jobTitleController.clear();
        _jobProfileController.clear();
        _joiningDate = null;
        _workedTillDate = null;
      });
    }
  }

  void _removeEmployment(int index) {
    setState(() {
      _employmentList.removeAt(index);
    });
  }

  void _addNewSkill() {
    if (_newSkillController.text.isNotEmpty) {
      setState(() {
        _selectedSkills.add(_newSkillController.text);
        _newSkillController.clear();
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isJoiningDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            colorScheme: const ColorScheme.light(primary: Colors.black),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isJoiningDate) {
          _joiningDate = picked;
        } else {
          _workedTillDate = picked;
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitForm() {
    // Form validation
    if (_selectedFile == null) {
      _showErrorSnackbar('Please upload your resume');
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    if (_resumeHeadlineController.text.isEmpty) {
      _showErrorSnackbar('Please enter resume headline');
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    // Form submission logic
    print('Form Submitted!');
    print('Resume File: ${_selectedFile!.name}');
    print('Resume Headline: ${_resumeHeadlineController.text}');
    print('Education Entries: ${_educationList.length}');
    print('Employment Entries: ${_employmentList.length}');
    print('Skills: $_selectedSkills');

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text('Your resume has been created successfully!',
                style: GoogleFonts.poppins()),
            const SizedBox(height: 8),
            Text(
              'File: ${_selectedFile!.name}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showAdditionalUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Additional Documents',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload portfolio, certificates, or other supporting documents.',
                style: GoogleFonts.poppins()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pickAndUploadFile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text('Upload Documents',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}