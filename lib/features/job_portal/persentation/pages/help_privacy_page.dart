

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPrivacyPage extends StatefulWidget {
  const HelpPrivacyPage({super.key});

  @override
  State<HelpPrivacyPage> createState() => _HelpPrivacyPageState();
}

class _HelpPrivacyPageState extends State<HelpPrivacyPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Privacy'),
        backgroundColor: AppColors.black,
        foregroundColor: isDarkMode ? AppColors.white : AppColors.white,
        elevation: 1,
        shadowColor: AppColors.premiumGold.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeaderSection(context),
              const SizedBox(height: 24),

              // Privacy Policy Section with Expandable Text
              _buildPrivacyPolicySection(context),
              const SizedBox(height: 24),

              // Contact Section
              _buildContactSection(context),
              const SizedBox(height: 32),

              // Footer
              _buildFooterSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help & Privacy',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicySection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Document Privacy Policy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expandable Text Section
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _privacyText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                      maxLines: _isExpanded ? null : 10, 
                      overflow:
                      _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? 'Show Less' : 'Learn More',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                );



                /*Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Initial visible text
                    Text(
                      _getVisibleText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                      maxLines: _isExpanded ? null : 15,
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),

                    // "Learn More" button
                    if (!_isExpanded) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Learn More',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Additional text that appears when expanded
                    if (_isExpanded) ...[
                      const SizedBox(height: 16),
                      Text(
                        _getAdditionalText(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Show Less',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );*/
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getVisibleText() {
    return 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
        'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, '
        'when an unknown printer took a galley of type and scrambled it to make a type specimen book. '
        'It has survived not only five centuries, but also leap into electronic typesetting, '
        'remaining essentially unchanged. It was popularised in the 1960s with the release of '
        'Letraset sheets containing Lorem Ipsum passages.';
  }

  String _getAdditionalText() {
    return 'More recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n'
        'It is a long established fact that a reader will be distracted by the readable content '
        'of a page when looking at its layout. The point of using Lorem Ipsum is that it has a '
        'more-or-less normal distribution of letters, as opposed to using \'Content here, content here.\'\n\n'
        'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece '
        'of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, '
        'a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure '
        'Latin words, consectetur, from a Lorem Ipsum passage.\n\n'
        'There are many variations of passages of Lorem Ipsum available, but the majority have suffered '
        'alteration in some form, by injected humour, or randomised words which don\'t look even slightly '
        'believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn\'t '
        'anything embarrassing hidden in the middle of text.';
  }


  String _privacyText = '''
Lorem Ipsum is simply dummy text of the printing and typesetting industry.
Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
when an unknown printer took a galley of type and scrambled it to make a type specimen book.

It has survived not only five centuries, but also leap into electronic typesetting,
remaining essentially unchanged.

More recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

It is a long established fact that a reader will be distracted by the readable content
of a page when looking at its layout.

Contrary to popular belief, Lorem Ipsum is not simply random text...
''';


  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 40,
          color: Colors.blue.withOpacity(0.7),
        ),
        const SizedBox(height: 20),

        // Phone Numbers
        _buildContactCard(
          context,
          icon: Icons.phone_outlined,
          title: 'Contact Number',
          items: [
            _buildContactItem(
              context,
              icon: Icons.phone_android_outlined,
              text: '+91 9536475221',
              onTap: () => _launchPhoneCall('+919536475221'),
            ),
            _buildContactItem(
              context,
              icon: Icons.phone_outlined,
              text: '022 2513569814',
              onTap: () => _launchPhoneCall('0222513569814'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Email
        _buildContactCard(
          context,
          icon: Icons.email_outlined,
          title: 'Email Id',
          items: [
            _buildContactItem(
              context,
              icon: Icons.email_outlined,
              text: 'info@infosys.com',
              onTap: () => _launchEmail('info@infosys.com'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<Widget> items,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: items,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.premiumGold.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            height: 1,
            width: double.infinity,
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 8),
          Text(
            '© ${DateTime.now().year} i_app . All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for actions
  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}