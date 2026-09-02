import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionsDialog extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  const TermsConditionsDialog({
    super.key,
    required this.onAccept,
    required this.onCancel,
  });

  @override
  State<TermsConditionsDialog> createState() => _TermsConditionsDialogState();
}

class _TermsConditionsDialogState extends State<TermsConditionsDialog> {
  bool _isChecked = false;
  bool _isExpanded = false;

  final List<String> _topPoints = [
    "Age 15+ or Parental Supervision Required",
    "All Activity may partially analyze for Recommendations & Moderation",
    "Strict Prohibition Rules for content use / process / compose without author's written Consent",
  ];

  final List<String> _remainingPoints = [
    "App Use Traction for Experience & Safety",
    "No third party Responsibility for User Posts or Transactions & in app moderate through flow only valid in support of any liability of users / official bodies.",
    "Strict Rules Applies Against Misuse, Fraud & Harassment in iVatan (iApp) Application / environment.",
    "User Data Stored Securely Within India & Indian certified data centers",
    "Violations Can Lead to Suspension or Legal Action",
    "All Rules Governed by Indian IT & E-Commerce Law",
    "By Logging In, You Accept All Above Terms",
  ];

  Future<void> _openUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      bool launched = false;
      if (await canLaunchUrl(url)) {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        launched = await launchUrl(url, mode: LaunchMode.platformDefault);
      }
      if (!launched) {
        Get.snackbar(
          "Notice",
          "Could not open link directly. Opening defaults.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      try {
        bool launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        if (!launched) {
          Get.snackbar(
            "Error",
            "Unable to load link.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e2) {
        Get.snackbar(
          "Error",
          "Unable to load link.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget _buildPointItem(int number, String text, {required bool isHighlighted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHighlighted ? AppColors.white : const Color(0xFFE5E7EB),
            ),
            alignment: Alignment.center,
            child: Text(
              "$number",
              style: TextStyle(
                color: isHighlighted ? AppColors.white : AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen height and width for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 10,
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth > 500 ? 450 : screenWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fixed Header with Close button and Shield icon
            Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 12.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white, size: 24),
                      onPressed: widget.onCancel,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: const [
                          Icon(
                            Icons.shield_outlined,
                            color: AppColors.white,
                            size: 26,
                          ),
                          Positioned(
                            top: 15,
                            child: Icon(
                              Icons.check,
                              color: AppColors.white,
                              size: 13,
                              weight: 800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Title and Subtitle
            const SizedBox(height: 16),
            const Text(
              "Terms & Conditions Summary",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Please review the key points below",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.premiumGold,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Top 3 points in a light-grey container
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          _buildPointItem(1, _topPoints[0], isHighlighted: true),
                          const SizedBox(height: 8),
                          _buildPointItem(2, _topPoints[1], isHighlighted: true),
                          const SizedBox(height: 8),
                          _buildPointItem(3, _topPoints[2], isHighlighted: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Expandable "Read more" toggle
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE5E7EB),
                            thickness: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isExpanded ? "Read less" : "Read more",
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE5E7EB),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    // Collapsible remaining points
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: List.generate(_remainingPoints.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildPointItem(
                                index + 4,
                                _remainingPoints[index],
                                isHighlighted: false,
                              ),
                            );
                          }),
                        ),
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),

                    const SizedBox(height: 20),

                    // Checkbox container
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isChecked = !_isChecked;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 12, top: 1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isChecked ? AppColors.white : const Color(0xFFD1D5DB),
                                  width: 1.5,
                                ),
                                color: _isChecked ? AppColors.white : AppColors.white,
                              ),
                              alignment: Alignment.center,
                              child: _isChecked
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 13,
                                    height: 1.5,
                                    fontFamily: 'DMSans', // Use project fontFamily standard
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "I have read and agree to the iVatan (iApp) ",
                                    ),
                                    TextSpan(
                                      text: "Terms & Conditions",
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _openUrl("https://ivatan.in/terms");
                                        },
                                    ),
                                    const TextSpan(text: " and "),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _openUrl("https://ivatan.in/privacy-policy");
                                        },
                                    ),
                                    const TextSpan(text: "."),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Solid "I Agree & Continue" Button at the bottom
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked ? AppColors.white : const Color(0xFFE5E7EB),
                  foregroundColor: _isChecked ? AppColors.white : AppColors.premiumGold,
                  elevation: 0,
                  shadowColor: AppColors.transparent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _isChecked ? widget.onAccept : null,
                child: const Text(
                  "I Agree & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
