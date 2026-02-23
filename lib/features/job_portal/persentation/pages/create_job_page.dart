import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class JobCreateScreen extends StatefulWidget {
  const JobCreateScreen({super.key});

  @override
  State<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends State<JobCreateScreen> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedJobRole;
  String? selectedWorkType;
  DateTime selectedDate = DateTime.now();

  final List<String> jobRoles = [
    'Software Engineer',
    'Designer',
    'Product Manager',
    'Marketing',
  ];

  final List<String> workTypes = [
    'Full Time',
    'Part Time',
    'Remote',
    'Contract',
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            colorScheme: ColorScheme.light(primary: Colors.black),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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
          'Create Job Posting',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company/Individual Name
            Text('Company/Individual Name', style: _labelStyle()),
            const SizedBox(height: 6),
            TextField(
              controller: companyController,
              decoration: _inputDecoration('Enter company here'),
            ),
            const SizedBox(height: 16),

            // Job Description
            Text('Job Description', style: _labelStyle()),
            const SizedBox(height: 6),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration('Enter description here'),
            ),
            const SizedBox(height: 16),

            // Job Role Dropdown
            Text('Job Role', style: _labelStyle()),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedJobRole,
              items: jobRoles
                  .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role, style: const TextStyle(fontSize: 14)),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedJobRole = val;
                });
              },
              decoration: _inputDecoration('Select Job Role'),
            ),
            const SizedBox(height: 16),

            // Time & Duration
            Text('Time & Duration', style: _labelStyle()),
            const SizedBox(height: 6),
            TextField(
              decoration: _inputDecoration('Enter time & duration'),
            ),
            const SizedBox(height: 16),

            // Work Type Dropdown
            Text('Work Type', style: _labelStyle()),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedWorkType,
              items: workTypes
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type, style: const TextStyle(fontSize: 14)),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedWorkType = val;
                });
              },
              decoration: _inputDecoration('Select work type'),
            ),
            const SizedBox(height: 16),

            // Date Picker
            Text('Select Date', style: _labelStyle()),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
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
                    Text(DateFormat('MMMM dd, yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 14)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Job Create
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Create Job',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Label TextStyle
  TextStyle _labelStyle() {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
  }
}
