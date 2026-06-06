import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:i_vatan_app/route/app_pages.dart';

// Top-level helper to dynamically mask the current logged-in user's email
String _getMaskedEmail() {
  final email = SharedPrefManager().user?.email ?? "";
  if (email.isEmpty) return "your email";
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final name = parts[0];
  final domain = parts[1];
  if (name.length <= 2) {
    return "${name}***@$domain";
  }
  return "${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain";
}

class AccountDeleteReasonScreen extends StatefulWidget {
  const AccountDeleteReasonScreen({super.key});

  @override
  State<AccountDeleteReasonScreen> createState() => _AccountDeleteReasonScreenState();
}

class _AccountDeleteReasonScreenState extends State<AccountDeleteReasonScreen> {
  // Checkbox states
  bool isNotUsing = false;
  bool isBetterAlternative = false;
  bool isTooManyAds = false;
  bool isMissingFeatures = false;
  bool isNotSatisfied = false;
  bool isDifficultNavigate = false;
  bool isOther = false;

  TextEditingController otherController = TextEditingController();

  String _getJoinedReasons() {
    List<String> selected = [];
    if (isNotUsing) selected.add("I'm not using the app.");
    if (isBetterAlternative) selected.add("I found a better alternative.");
    if (isTooManyAds) selected.add("The app contains too many ads.");
    if (isMissingFeatures) selected.add("The app didn't have the features or functionality I was looking for.");
    if (isNotSatisfied) selected.add("I'm not satisfied with the quality of content.");
    if (isDifficultNavigate) selected.add("The app was difficult to navigate.");
    if (isOther) {
      String otherText = otherController.text.trim();
      selected.add(otherText.isNotEmpty ? otherText : "Other");
    }
    return selected.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Request Received',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Delete Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Delete Request',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.orange[800],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '12:30 • Request Received',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirmation email sent',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getMaskedEmail(),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'We\'ll notify you when your account is deleted',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Feedback Section
            Text(
              'Why did you decide to leave this app?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Give us optional feedback to help us improve',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Professional Checkboxes
            _buildModernCheckbox(
              title: 'I\'m not using the app.',
              value: isNotUsing,
              onChanged: (value) => setState(() => isNotUsing = value),
            ),

            _buildModernCheckbox(
              title: 'I found a better alternative.',
              value: isBetterAlternative,
              onChanged: (value) => setState(() => isBetterAlternative = value),
            ),

            _buildModernCheckbox(
              title: 'The app contains too many ads.',
              value: isTooManyAds,
              onChanged: (value) => setState(() => isTooManyAds = value),
            ),

            _buildModernCheckbox(
              title: 'The app didn\'t have the features or functionality I was looking for.',
              value: isMissingFeatures,
              onChanged: (value) => setState(() => isMissingFeatures = value),
            ),

            _buildModernCheckbox(
              title: 'I\'m not satisfied with the quality of content.',
              value: isNotSatisfied,
              onChanged: (value) => setState(() => isNotSatisfied = value),
            ),

            _buildModernCheckbox(
              title: 'The app was difficult to navigate.',
              value: isDifficultNavigate,
              onChanged: (value) => setState(() => isDifficultNavigate = value),
            ),

            _buildModernCheckbox(
              title: 'Other',
              value: isOther,
              onChanged: (value) => setState(() => isOther = value),
            ),

            // Other Text Field
            if (isOther) ...[
              Container(
                margin: const EdgeInsets.only(left: 44),
                child: TextField(
                  controller: otherController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Please tell us more...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildCustomButton(
                    text: 'Go Back',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCustomButton(
                    text: 'Done',
                    isOutlined: false,
                    isDelete: true,
                    onPressed: () {
                      final reasons = _getJoinedReasons();
                      if (reasons.trim().isEmpty) {
                        CustomSnackBar.showError(message: "Please select at least one reason.");
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountDeleteConfirmationScreen(reason: reasons),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCheckbox({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Custom Animated Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: value ? Colors.black : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                  color: value ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required bool isOutlined,
    bool isDelete = false,
    required VoidCallback onPressed,
  }) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete ? Colors.red[700] : Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Screen 2: Account Delete Confirmation Screen
class AccountDeleteConfirmationScreen extends StatefulWidget {
  final String reason;
  const AccountDeleteConfirmationScreen({super.key, required this.reason});

  @override
  State<AccountDeleteConfirmationScreen> createState() => _AccountDeleteConfirmationScreenState();
}

class _AccountDeleteConfirmationScreenState extends State<AccountDeleteConfirmationScreen> {
  bool isConfirmed = false;
  final ApiServices _api = Get.put(ApiServices());

  Future<void> _deleteAccount(BuildContext context) async {
    print("Delete Account API triggered! Reason: ${widget.reason}");
    
    // Show loading indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ),
    );

    try {
      final response = await _api.callPost(
        AppUrls.deleteAccount,
        data: {
          "reason": widget.reason,
        },
        showErrorToast: true,
      );

      // Dismiss loading dialog
      Navigator.pop(context);

      if (response != null && response['status'] == true) {
        // Clear local user credentials
        await SharedPrefManager().userLogOut();
        
        CustomSnackBar.showSuccess(
          message: response['message'] ?? "Your account has been scheduled for deletion."
        );
        
        // Directly navigate to login screen
        Future.delayed(const Duration(milliseconds: 200), () {
          Get.offAllNamed(AppRoutes.login);
        });
      } else {
        CustomSnackBar.showError(
          message: response?['message'] ?? "Account deletion failed. Please try again."
        );
      }
    } catch (e) {
      // Dismiss loading dialog
      Navigator.pop(context);
      print("Error deleting account: $e");
      CustomSnackBar.showError(message: "An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Icon and Time
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red[700],
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Delete Account Title
            Center(
              child: Text(
                'Delete Account',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Confirmation Question
            Center(
              child: Text(
                'Are you sure you want to delete your account?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 22),

            // Warning Message Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: Colors.red[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'This action cannot be undone',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Once you delete your account, it cannot be undone. All your data will be permanently erased from this app including your profile information, preferences, saved content, and any activity history.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'We\'re sad to see you go, but we understand that sometimes it\'s necessary.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.red[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Confirmation Checkbox
            _buildConfirmationCheckbox(),

            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildCustomButton(
                    text: 'Go Back',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCustomButton(
                    text: 'Delete account',
                    isOutlined: false,
                    isDelete: true,
                    isEnabled: isConfirmed,
                    onPressed: isConfirmed ? () => _deleteAccount(context) : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isConfirmed ? Colors.green[200]! : Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => setState(() => isConfirmed = !isConfirmed),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Custom Animated Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isConfirmed ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isConfirmed ? Colors.green : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isConfirmed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I understand the consequences',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'I confirm that I want to permanently delete my account',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required bool isOutlined,
    bool isDelete = false,
    bool isEnabled = true,
    required VoidCallback? onPressed,
  }) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete
            ? (isEnabled ? Colors.red[700] : Colors.grey[400])
            : (isEnabled ? Colors.black : Colors.grey[400]),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
