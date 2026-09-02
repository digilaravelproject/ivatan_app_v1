import 'package:flutter/material.dart';

/*
class CreatorAnalysisScreen extends StatelessWidget {
  const CreatorAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumGold.withOpacity(0.1),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 16),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '₹1,25,000',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              color: AppColors.white,
                              size: 16,
                            ),
                            Text(
                              '+12%',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'vs last month ₹1,11,000',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildMetricCard(
                    'Total Views',
                    '2.5M',
                    Icons.visibility,
                    Colors.purple,
                    '+18%',
                  ),
                  _buildMetricCard(
                    'Total Interactions',
                    '1.2M',
                    Icons.favorite,
                    Colors.red,
                    '+25%',
                  ),
                  _buildMetricCard(
                    'Total Followers',
                    '156K',
                    Icons.people,
                    Colors.blue,
                    '+8%',
                  ),
                  _buildMetricCard(
                    'Content Shared',
                    '342',
                    Icons.share,
                    Colors.orange,
                    '+15%',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Detailed Stats Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.premiumGold.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Content Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProgressStat('Videos', 78, Colors.blue),
                  _buildProgressStat('Articles', 45, Colors.green),
                  _buildProgressStat('Images', 92, Colors.orange),
                  _buildProgressStat('Live Streams', 34, Colors.purple),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recent Content Shared
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.premiumGold.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recently Shared Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContentItem(
                    'iPhone 15 Review',
                    '2 days ago',
                    '45K views',
                    Icons.video_collection,
                  ),
                  _buildContentItem(
                    'Tech Tips 2024',
                    '4 days ago',
                    '32K views',
                    Icons.article,
                  ),
                  _buildContentItem(
                    'Studio Tour',
                    '1 week ago',
                    '78K views',
                    Icons.image,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String label,
      String value,
      IconData icon,
      Color color,
      String growth,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.premiumGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.premiumGold,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentItem(
      String title,
      String time,
      String views,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.premiumGold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.premiumGold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.premiumGold,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(color: AppColors.premiumGold),
                    ),
                    Text(
                      views,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.premiumGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: AppColors.premiumGold),
        ],
      ),
    );
  }
}*/


import 'package:i_vatan_app/core/theme/app_colors.dart';

class CreatorAnalysisScreen extends StatelessWidget {
  const CreatorAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.premiumGold.withOpacity(0.1),
            AppColors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Summary Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary,
                      AppColors.neutralGray,
                      // Color(0xFFC850C0),
                      // Color(0xFFFFCC70),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 3,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priya Sharma',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@priyacreates • 2 years',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Lifestyle & Fashion',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats Cards Row
              Row(
                children: [
                  _buildStatCard(
                    'Total Followers',
                    '2.4M',
                    Icons.people,
                    Colors.blue,
                    '+12.5%',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Total Views',
                    '15.8M',
                    Icons.visibility,
                    Colors.orange,
                    '+8.2%',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatCard(
                    'Total Likes',
                    '892K',
                    Icons.favorite,
                    Colors.red,
                    '+15.3%',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Total Earnings',
                    '₹4.2L',
                    Icons.currency_rupee,
                    Colors.green,
                    '+22.1%',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Engagement Rate Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Engagement Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEngagementItem('4.8%', 'Engagement Rate', AppColors.primary),
                        Container(
                          height: 30,
                          width: 1,
                          color: AppColors.premiumGold,
                        ),
                        _buildEngagementItem('2.3K', 'Avg Likes', AppColors.primary),
                        Container(
                          height: 30,
                          width: 1,
                          color: AppColors.premiumGold,
                        ),
                        _buildEngagementItem('156', 'Avg Comments', AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),

              // const SizedBox(height: 20),
              //
              // // Recent Videos Section
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       'Recent Videos',
              //       style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     TextButton(
              //       onPressed: () {},
              //       child: const Text('View All'),
              //     ),
              //   ],
              // ),

              // const SizedBox(height: 12),
              //
              // // Video List
              // _buildVideoItem(
              //   'Summer Lookbook 2024',
              //   '245K views',
              //   '12.5K likes',
              //   '2 days ago',
              //   Icons.play_circle_fill,
              // ),
              // _buildVideoItem(
              //   'My Morning Routine',
              //   '189K views',
              //   '8.9K likes',
              //   '5 days ago',
              //   Icons.play_circle_fill,
              // ),
              // _buildVideoItem(
              //   'Q&A with followers',
              //   '98K views',
              //   '4.2K likes',
              //   '1 week ago',
              //   Icons.play_circle_fill,
              // ),

              const SizedBox(height: 20),

              // Performance Graph Section
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildGraphBar('Mon', 0.6, AppColors.primary),
                          _buildGraphBar('Tue', 0.8, AppColors.primary),
                          _buildGraphBar('Wed', 0.4, AppColors.primary),
                          _buildGraphBar('Thu', 0.9, AppColors.primary),
                          _buildGraphBar('Fri', 0.7, AppColors.primary),
                          _buildGraphBar('Sat', 0.5, AppColors.primary),
                          _buildGraphBar('Sun', 0.3, AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Earnings Breakdown
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Earnings Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEarningRow('Brand Deals', '₹2.8L', 0.65),
                    _buildEarningRow('Ad Revenue', '₹1.2L', 0.25),
                    _buildEarningRow('Affiliate', '₹0.2L', 0.10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, String growth) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    growth,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.premiumGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.premiumGold,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(String title, String views, String likes, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.purple, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Text(views),
            const SizedBox(width: 8),
            Text('•'),
            const SizedBox(width: 8),
            Text(likes),
          ],
        ),
        trailing: Text(
          time,
          style: TextStyle(
            color: AppColors.premiumGold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGraphBar(String day, double heightFactor, Color color) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.7)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.premiumGold,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningRow(String source, String amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              source,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 100 * percentage,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}





class CreatorAnalysisScreen1 extends StatelessWidget {
  const CreatorAnalysisScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Summary Card - Black & White Style
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priya Sharma',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@priyacreates',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.premiumGold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Lifestyle Creator',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats Cards Row - Monochrome
              Row(
                children: [
                  _buildStatCard(
                    'Followers',
                    '2.4M',
                    Icons.people_outline,
                    '+12.5%',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Views',
                    '15.8M',
                    Icons.visibility_outlined,
                    '+8.2%',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatCard(
                    'Likes',
                    '892K',
                    Icons.favorite_border,
                    '+15.3%',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Earnings',
                    '₹4.2L',
                    Icons.trending_up,
                    '+22.1%',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Engagement Card - Minimal
              Container(
                decoration: BoxDecoration(
                  color: AppColors.premiumGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.premiumGold),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ENGAGEMENT METRICS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSimpleMetric('4.8%', 'Engagement'),
                        Container(
                          height: 30,
                          width: 1,
                          color: AppColors.premiumGold,
                        ),
                        _buildSimpleMetric('2.3K', 'Avg Likes'),
                        Container(
                          height: 30,
                          width: 1,
                          color: AppColors.premiumGold,
                        ),
                        _buildSimpleMetric('156', 'Comments'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content Performance Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT POSTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.premiumGold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Video List - Clean Design
              _buildPostItem(
                'Summer Collection 2024',
                '245K views • 12.5K likes',
                '2 days ago',
              ),
              _buildPostItem(
                'Morning Routine',
                '189K views • 8.9K likes',
                '5 days ago',
              ),
              _buildPostItem(
                'Q&A Session',
                '98K views • 4.2K likes',
                '1 week ago',
              ),

              const SizedBox(height: 20),

              // Performance Graph - Black & White
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.premiumGold),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY VIEWS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMinimalBar('Mon', 0.7),
                          _buildMinimalBar('Tue', 0.9),
                          _buildMinimalBar('Wed', 0.5),
                          _buildMinimalBar('Thu', 0.8),
                          _buildMinimalBar('Fri', 0.6),
                          _buildMinimalBar('Sat', 0.4),
                          _buildMinimalBar('Sun', 0.3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Income Sources - Monochrome
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.premiumGold),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INCOME SOURCES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildIncomeRow('Brand Collaborations', '₹2.8L', 0.65),
                    _buildIncomeRow('Ad Revenue', '₹1.2L', 0.25),
                    _buildIncomeRow('Affiliate Marketing', '₹0.2L', 0.10),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Stats Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFooterStat('Posts', '156'),
                    _buildFooterStat('Avg Time', '2.4 min'),
                    _buildFooterStat('Countries', '23'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, String growth) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.premiumGold),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.white, size: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    growth,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.premiumGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.premiumGold,
          ),
        ),
      ],
    );
  }

  Widget _buildPostItem(String title, String stats, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.premiumGold),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.premiumGold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_arrow, color: AppColors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.white,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          stats,
          style: TextStyle(color: AppColors.premiumGold, fontSize: 11),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            color: AppColors.premiumGold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBar(String day, double heightFactor) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.premiumGold,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeRow(String source, String amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              source,
              style: const TextStyle(fontSize: 13, color: AppColors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  width: 100 * percentage,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.premiumGold,
          ),
        ),
      ],
    );
  }
}