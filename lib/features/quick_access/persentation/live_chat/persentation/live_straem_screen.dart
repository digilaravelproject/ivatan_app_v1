import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:video_player/video_player.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late VideoPlayerController _videoController;
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  final ScrollController _scrollController = ScrollController();
  bool _isMuted = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _addSampleComments();
  }

  void _initializeVideo() {
    // Sample video URL - HD quality, loopable
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
    )..initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
      _videoController.setLooping(true);
      _videoController.setVolume(0); // Mute by default
      _videoController.play();
    }).catchError((e) {
      print('Video loading error: $e');
      // Fallback video
      _videoController = VideoPlayerController.asset(
        'assets/sample_video.mp4', // Agar asset ho to
      )..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _videoController.setLooping(true);
        _videoController.play();
      });
    });
  }

  void _addSampleComments() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _comments.addAll([
          Comment(
            username: 'aarav_sharma',
            text: '🔥 Great live session!',
            timeAgo: 'now',
          ),
          Comment(
            username: 'priya_patel',
            text: 'Flutter is awesome 🚀',
            timeAgo: 'now',
          ),
          Comment(
            username: 'rahul_verma',
            text: 'When is next part?',
            timeAgo: '1m',
          ),
          Comment(
            username: 'ananya_singh',
            text: 'Loving this content ❤️',
            timeAgo: '2m',
          ),
          Comment(
            username: 'vikram_aditya',
            text: 'Super helpful!',
            timeAgo: '2m',
          ),
        ]);
      });
      _scrollToBottom();
    });

    // Simulate incoming comments
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _comments.add(
            Comment(
              username: 'neha_gupta',
              text: 'First time here, looks good!',
              timeAgo: 'now',
            ),
          );
        });
        _scrollToBottom();
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _comments.add(
            Comment(
              username: 'rohit_kumar',
              text: '🔥🔥🔥',
              timeAgo: 'now',
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _sendComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.add(
          Comment(
            username: 'you',
            text: _commentController.text.trim(),
            timeAgo: 'now',
            isCurrentUser: true,
          ),
        );
        _commentController.clear();
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Stack(
        children: [
          // Video Player Background
          if (_isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Container(
              color: AppColors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.white,
                ),
              ),
            ),

          // Dark Overlay for better UI visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.transparent,
                  AppColors.white.withOpacity(0.3),
                  AppColors.white.withOpacity(0.7),
                ],
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
          ),

          // Live Badge & Info
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Row(
              children: [
                // Live Indicator with Pulse
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600.withOpacity(0.9 + (value * 0.1)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade600.withOpacity(0.3 + (value * 0.2)),
                            blurRadius: 8 + (value * 4),
                            spreadRadius: 1 + (value * 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        color: AppColors.white.withOpacity(0.9),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '1.2k watching',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Right Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Row(
              children: [
                // Mute/Unmute Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: AppColors.white,
                      size: 20,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
                const SizedBox(width: 8),
                // Close Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      _videoController.pause();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Host Info
          Positioned(
            bottom: 140,
            left: 16,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.premiumGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'JD',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Host',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flutter Developer • 2h',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Comments Section
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Comments List
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return _buildCommentBubble(comment);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom Input Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.white.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
              child: Row(
                children: [
                  // Comment Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.premiumGold,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.premiumGold,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: TextStyle(
                                  color: AppColors.premiumGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendComment(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: AppColors.premiumGold,
                              size: 22,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  GestureDetector(
                    onTap: _sendComment,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.white, Color(0xFFE0E0E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.white.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side Action Buttons
          Positioned(
            bottom: 140,
            right: 16,
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.favorite,
                  label: '1.2k',
                  isActive: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Liked!'),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '48',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.more_horiz,
                  label: '',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBubble(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: comment.isCurrentUser
                  ? const LinearGradient(
                colors: [AppColors.white, Color(0xFFE0E0E0)],
              )
                  : LinearGradient(
                colors: [AppColors.premiumGold, AppColors.premiumGold],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: comment.isCurrentUser
                    ? AppColors.white
                    : AppColors.premiumGold,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                comment.username[0].toUpperCase(),
                style: TextStyle(
                  color: comment.isCurrentUser ? AppColors.white : AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: comment.isCurrentUser
                    ? AppColors.white
                    : AppColors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(18),
                border: comment.isCurrentUser
                    ? null
                    : Border.all(
                  color: AppColors.premiumGold,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.username,
                        style: TextStyle(
                          color: comment.isCurrentUser
                              ? AppColors.white
                              : AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        comment.timeAgo,
                        style: TextStyle(
                          color: comment.isCurrentUser
                              ? AppColors.premiumGold
                              : AppColors.premiumGold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment.text,
                    style: TextStyle(
                      color: comment.isCurrentUser
                          ? AppColors.white
                          : AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.red.shade500
                  : AppColors.white.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.white
                    : AppColors.premiumGold,
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: Colors.red.shade500.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.white : AppColors.white,
              size: 22,
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Comment Model
class Comment {
  final String username;
  final String text;
  final String timeAgo;
  final bool isCurrentUser;

  Comment({
    required this.username,
    required this.text,
    required this.timeAgo,
    this.isCurrentUser = false,
  });
}