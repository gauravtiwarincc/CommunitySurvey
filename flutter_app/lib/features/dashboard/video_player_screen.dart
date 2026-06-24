import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/advertisement_service.dart';
import 'package:community_survey/models/advertisement.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Advertisement ad;

  const VideoPlayerScreen({super.key, required this.ad});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isCompleted = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _countdown = widget.ad.durationSeconds > 0 ? widget.ad.durationSeconds : 5;
    
    // Fallback to a test video if mediaUrl is missing or invalid
    final url = (widget.ad.mediaUrl != null && widget.ad.mediaUrl!.isNotEmpty)
        ? widget.ad.mediaUrl!
        : 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.addListener(_videoListener);
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to load video';
        });
      });
  }

  void _videoListener() {
    if (_controller.value.isInitialized) {
      final position = _controller.value.position;
      final duration = _controller.value.duration;
      
      final remaining = (duration - position).inSeconds;
      if (remaining != _countdown && remaining >= 0) {
        setState(() {
          _countdown = remaining;
        });
      }

      if (position >= duration && !_isCompleted && !_isSubmitting) {
        setState(() {
          _isCompleted = true;
        });
        _submitCompletion();
      }
    }
  }

  Future<void> _submitCompletion() async {
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final result = await ref.read(advertisementServiceProvider).submitView(widget.ad.id);
      if (mounted) {
        _showRewardDialog(result['message'], result['rewardPoints']);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  void _showRewardDialog(String message, int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white12),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(
              'Reward Earned!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter( fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // close video screen
            },
            child: Text(
              'Awesome',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),

            // Top bar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      if (!_isCompleted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  if (_controller.value.isInitialized && !_isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Video finishes in $_countdown s',
                        style: const TextStyle( fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            
            // Loading overlay for submission
            if (_isSubmitting)
              Container(
                color: Colors.white54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
