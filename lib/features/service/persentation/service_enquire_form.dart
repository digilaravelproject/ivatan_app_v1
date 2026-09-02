import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/service_controller.dart';

class EnquiryForm extends StatefulWidget {
  final int sellerId;
  final int serviceId;
  const EnquiryForm({super.key, required this.sellerId, required this.serviceId});

  @override
  State<EnquiryForm> createState() => _EnquiryFormState();
}

class _EnquiryFormState extends State<EnquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final ServiceController _controller = Get.find<ServiceController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _controller.submitEnquiry(
        sellerId: widget.sellerId,
        serviceId: widget.serviceId,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        subject: _subjectController.text,
        message: _messageController.text,
        onSuccess: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // For keyboard
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              const Center(
                child: Text(
                  'Service Enquiry',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  'Fill the details to enquire about this service',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.premiumGold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              const Text(
                'Full Name',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 15),

              // Email Field
              const Text(
                'Email Address',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!GetUtils.isEmail(value)) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Phone Number Field
              const Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 15),

              // Subject Field
              const Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _subjectController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Enter your subject',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 15),

              // Message/Query Field
              const Text(
                'Your Message/Query',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell us more about your requirement...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.premiumGold)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                  contentPadding: const EdgeInsets.all(15),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your message';
                  if (value.length < 10) return 'The message field must be at least 10 characters.';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _controller.isLoading.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _controller.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text(
                          'Submit Enquiry',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}



// ---- Seller-side: List of enquiries received ----

class EnquiriesListScreen extends StatefulWidget {
  const EnquiriesListScreen({super.key});

  @override
  State<EnquiriesListScreen> createState() => _EnquiriesListScreenState();
}

class _EnquiriesListScreenState extends State<EnquiriesListScreen> {
  late ServiceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ServiceController>()
        ? Get.find<ServiceController>()
        : Get.put(ServiceController());
    
    // Fetch data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSellerEnquiries();
      controller.fetchSellerEnquiriesStats();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        if (diff.inHours == 0) return '${diff.inMinutes} minutes ago';
        return '${diff.inHours} hours ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumGold.withOpacity(0.1),
      appBar: AppBar(
        title: const Text(
          'Service Enquiries',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Obx(() => (controller.isEnquiriesLoading.value || controller.isStatsLoading.value)
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    controller.fetchSellerEnquiries();
                    controller.fetchSellerEnquiriesStats();
                  },
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isEnquiriesLoading.value && controller.sellerEnquiries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // Stats Cards
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: AppColors.primary,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total',
                      controller.enquiriesTotal.value.toString(),
                      Icons.inbox_outlined,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      'Pending',
                      controller.enquiriesPending.value.toString(),
                      Icons.pending_actions,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      'Replied',
                      controller.enquiriesReplied.value.toString(),
                      Icons.reply_all_outlined,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      'Closed',
                      controller.enquiriesClosed.value.toString(),
                      Icons.done_all_outlined,
                    ),
                  ],
                ),
              ),
            ),

            // Enquiries List
            Expanded(
              child: controller.sellerEnquiries.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: AppColors.premiumGold),
                          SizedBox(height: 16),
                          Text('No enquiries yet', style: TextStyle(color: AppColors.premiumGold, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(color: AppColors.white, 
                      onRefresh: () async {
                        await controller.fetchSellerEnquiries();
                        await controller.fetchSellerEnquiriesStats();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.sellerEnquiries.length,
                        itemBuilder: (context, index) {
                          final enquiry = controller.sellerEnquiries[index];
                          return _buildEnquiryCard(context, enquiry);
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon) {
    return Container(
      width: 110, // Fixed width since it's in a horizontal scroll
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnquiryCard(BuildContext context, Map<String, dynamic> enquiry) {
    final String status = enquiry['status'] ?? 'pending';
    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'contacted':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = AppColors.premiumGold;
    }

    final user = enquiry['user'] as Map<String, dynamic>?;
    final service = enquiry['service'] as Map<String, dynamic>?;
    final String name = user?['name'] ?? 'Unknown';
    final String email = user?['email'] ?? '';
    final String phone = user?['phone'] ?? '';
    final String subject = enquiry['subject'] ?? '';
    final String message = enquiry['message'] ?? '';
    final String serviceTitle = service?['title'] ?? '';
    final String dateStr = _formatDate(enquiry['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEnquiryDetails(context, enquiry),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID + Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${enquiry['id']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.premiumGold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (serviceTitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.premiumGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                serviceTitle,
                                style: TextStyle(fontSize: 11, color: AppColors.premiumGold),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject
                // if (subject.isNotEmpty) ...[
                //   Row(
                //     children: [
                //       Icon(Icons.subject, size: 14, color: AppColors.premiumGold),
                //       const SizedBox(width: 4),
                //       Expanded(
                //         child: Text(
                //           subject,
                //           style: TextStyle(fontSize: 12, color: AppColors.premiumGold, fontWeight: FontWeight.w500),
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ),
                //     ],
                //   ),
                //   const SizedBox(height: 4),
                // ],

                // Contact info
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 14, color: AppColors.premiumGold),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(fontSize: 12, color: AppColors.premiumGold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 14, color: AppColors.premiumGold),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: TextStyle(fontSize: 12, color: AppColors.premiumGold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message preview
                if (subject.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.premiumGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message_outlined, size: 14, color: AppColors.premiumGold),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: AppColors.premiumGold, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Footer: date
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.premiumGold),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 11, color: AppColors.premiumGold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEnquiryDetails(BuildContext context, Map<String, dynamic> enquiry) {
    Get.to(() => EnquiryDetailScreen(enquiry: enquiry));
  }
}

// Full-screen screen showing full enquiry info
class EnquiryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> enquiry;
  const EnquiryDetailScreen({super.key, required this.enquiry});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.premiumGold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = enquiry['user'] as Map<String, dynamic>?;
    final service = enquiry['service'] as Map<String, dynamic>?;
    final String name = user?['name'] ?? 'Unknown';
    final String email = user?['email'] ?? '';
    final String phone = user?['phone'] ?? '';
    final String subject = enquiry['subject'] ?? '';
    final String message = enquiry['message'] ?? '';
    final String serviceTitle = service?['title'] ?? '';
    final String status = enquiry['status'] ?? 'pending';
    final String createdAt = _formatDate(enquiry['created_at']);
    final ServiceController controller = Get.find<ServiceController>();

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'replied':
        statusColor = Colors.blue;
        break;
      case 'closed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = AppColors.premiumGold;
    }

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text('Enquiry Details'),
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.info_outline, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Status',
                        style: TextStyle(fontSize: 12, color: AppColors.premiumGold),
                      ),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Customer Section
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Customer Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.person_outline, 'Full Name', name),
            _infoRow(Icons.email_outlined, 'Email Address', email),
            _infoRow(Icons.phone_outlined, 'Phone Number', phone),

            const SizedBox(height: 16),

            // Enquiry Section
            Row(
              children: [
                const Icon(Icons.description, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Enquiry Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (serviceTitle.isNotEmpty) _infoRow(Icons.design_services_outlined, 'Interested Service', serviceTitle),
            _infoRow(Icons.message_outlined, 'Message/Query', message),
            _infoRow(Icons.calendar_today_outlined, 'Submission Date', createdAt),

            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: phone.isEmpty 
                      ? null 
                      : () async => await launchUrl(Uri.parse('tel:$phone')),
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: email.isEmpty 
                      ? null 
                      : () async => await launchUrl(Uri.parse('mailto:$email?subject=Regarding your enquiry: $subject')),
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Delete Button (Secondary action)
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(
                  context,
                  controller,
                  enquiry['id'],
                ),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Delete Enquiry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _showUpdateBottomSheet(context, enquiry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Update Status & Reply',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ServiceController controller, dynamic id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Enquiry'),
        content: const Text('Are you sure you want to delete this enquiry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.deleteEnquiry(id is int ? id : int.parse(id.toString()));
              Get.back(); // Close detail screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUpdateBottomSheet(BuildContext context, Map<String, dynamic> enquiry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => UpdateEnquirySheet(enquiry: enquiry),
    );
  }
}

// Separate Bottom Sheet for Update form
class UpdateEnquirySheet extends StatefulWidget {
  final Map<String, dynamic> enquiry;
  const UpdateEnquirySheet({super.key, required this.enquiry});

  @override
  State<UpdateEnquirySheet> createState() => _UpdateEnquirySheetState();
}

class _UpdateEnquirySheetState extends State<UpdateEnquirySheet> {
  late String selectedStatus;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.enquiry['status'] ?? 'pending';
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ServiceController controller = Get.find<ServiceController>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.premiumGold, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text(
            'Update Enquiry',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          
          const Text('Select Status', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusRadio('pending', Colors.orange),
              _buildStatusRadio('replied', Colors.blue),
              _buildStatusRadio('closed', Colors.green),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text('Reply Message', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _replyController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your reply message here...',
              filled: true,
              fillColor: AppColors.premiumGold.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.premiumGold),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.premiumGold),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Obx(() => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value 
                ? null 
                : () async {
                    await controller.updateEnquiryStatus(
                      widget.enquiry['id'], 
                      selectedStatus, 
                      replyMessage: _replyController.text
                    );
                    Get.back(); // Close original sheet if needed or it's handled by controller.back()
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isLoading.value
                ? const CircularProgressIndicator(color: AppColors.white)
                : const Text(
                    'Update Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusRadio(String value, Color color) {
    bool isSelected = selectedStatus == value;
    return InkWell(
      onTap: () => setState(() => selectedStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : AppColors.premiumGold),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color : AppColors.premiumGold),
                color: isSelected ? color : AppColors.transparent,
              ),
              child: isSelected 
                ? const Icon(Icons.check, size: 10, color: AppColors.white) 
                : null,
            ),
            const SizedBox(width: 8),
            Text(
              value.capitalizeFirst!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.premiumGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



