import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/service_controller.dart';
import '../model/enquiry_model_user.dart';

class MyEnquiryListScreen extends StatefulWidget {
  const MyEnquiryListScreen({Key? key}) : super(key: key);

  @override
  State<MyEnquiryListScreen> createState() => _MyEnquiryListScreenState();
}

class _MyEnquiryListScreenState extends State<MyEnquiryListScreen> {
  final ServiceController controller = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyEnquiries(isRefresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        controller.fetchMyEnquiries();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumGold.withOpacity(0.1),
      appBar: AppBar(
        title: const Text(
          'My Enquiries',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (controller.isMyEnquiriesLoading.value && controller.myEnquiries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myEnquiries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message_outlined, size: 64, color: AppColors.premiumGold),
                const SizedBox(height: 16),
                Text(
                  'No enquiries found',
                  style: TextStyle(color: AppColors.premiumGold, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(color: AppColors.white, 
          onRefresh: () => controller.fetchMyEnquiries(isRefresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.myEnquiries.length + (controller.hasMoreMyEnquiries.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < controller.myEnquiries.length) {
                final enquiry = controller.myEnquiries[index];
                return EnquiryCard(enquiry: enquiry);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      }),
    );
  }
}

class EnquiryCard extends StatelessWidget {
  final EnquiryUserModel enquiry;

  const EnquiryCard({Key? key, required this.enquiry}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'replied':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      default:
        return AppColors.premiumGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.premiumGold, width: 1),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EnquiryDetailScreen(enquiry: enquiry),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Service Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        enquiry.service?.title ?? 'Service',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(enquiry.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        enquiry.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(enquiry.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.subject, size: 16, color: AppColors.premiumGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        enquiry.subject.isEmpty ? 'No Subject' : enquiry.subject,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.premiumGold,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message Preview
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.message_outlined, size: 16, color: AppColors.premiumGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        enquiry.message.isEmpty ? 'No message' : enquiry.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.premiumGold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer with Seller and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_outline, size: 14, color: AppColors.premiumGold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          enquiry.seller?.name ?? 'Seller',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.premiumGold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.premiumGold),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(enquiry.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.premiumGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Reply Indicator
                if (enquiry.replyMessage != null &&
                    enquiry.replyMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reply, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Reply received',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class EnquiryDetailScreen extends StatelessWidget {
  final EnquiryUserModel enquiry;

  const EnquiryDetailScreen({Key? key, required this.enquiry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: Text(
          enquiry.service?.title ?? 'Enquiry Details',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image (if available)
            if (enquiry.service?.coverImage != null)
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage('${AppUrls.imageurl}${enquiry.service!.coverImage}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (enquiry.service?.coverImage != null)
              const SizedBox(height: 20),

            // Service Title and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enquiry.service?.title ?? 'Service',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enquiry.service?.description ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.premiumGold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '₹${enquiry.service?.price ?? '0'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Seller Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.premiumGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.premiumGold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.store, size: 20, color: AppColors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seller',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.premiumGold,
                            ),
                          ),
                          Text(
                            enquiry.seller?.name ?? 'Unknown Seller',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Enquiry Section
            const Text(
              'Your Enquiry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.premiumGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.premiumGold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enquiry.subject.isEmpty ? 'No Subject' : enquiry.subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    enquiry.message.isEmpty ? 'No message' : enquiry.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.premiumGold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.premiumGold),
                      const SizedBox(width: 6),
                      Text(
                        'Sent on ${_formatDate(enquiry.createdAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.premiumGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Reply Section (if available)
            if (enquiry.replyMessage != null &&
                enquiry.replyMessage!.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Seller Reply',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.reply, size: 18, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          enquiry.seller?.name ?? 'Seller',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      enquiry.replyMessage!,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.premiumGold,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}