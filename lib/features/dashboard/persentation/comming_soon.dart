import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ComingSoonScreen extends StatelessWidget {
  final bool enableBack;
  const ComingSoonScreen({super.key, this.enableBack = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: enableBack ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ) : null,
      body: CustomEmptyState(
        title: "Coming Soon!",
        subTitle: "We are currently crafting this feature.\nIt will be available in the next update.",
        icon: Icons.rocket_launch_rounded,
      ),
    );
  }
}

class CustomEmptyState extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final bool isSmall;

  const CustomEmptyState({
    super.key,
    required this.title,
    required this.subTitle,
    this.icon = Icons.rocket_launch_rounded,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Reduced strict padding
        child: FittedBox( // Scales content to avoid overflow
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: isSmall ? 60 : 100, // Reduced small size slightly
                width: isSmall ? 60 : 100,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: isSmall ? 30 : 50,
                    color: Colors.purple.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Reduced spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmall ? 16 : 28, // Reduced font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (subTitle.isNotEmpty) ...[ // Only show subtitle and spacer if not empty
                const SizedBox(height: 8),
                Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Coming Soon Dialog Function
void showComingSoonDialog(BuildContext context, {required String title, required String message}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 40,
                  color: Colors.purple.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Got it!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
