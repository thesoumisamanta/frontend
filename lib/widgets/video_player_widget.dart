import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnail;
  final bool autoPlay;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnail,
    this.autoPlay = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _shouldAutoPlay = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller!.initialize();
      
      _controller!.setLooping(true);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!widget.autoPlay || _controller == null || !_isInitialized) return;

    // Auto-play when 70% visible for 5 seconds
    if (info.visibleFraction >= 0.7) {
      if (!_shouldAutoPlay) {
        _shouldAutoPlay = true;
        // Start auto-play after 5 seconds of visibility
        Future.delayed(const Duration(seconds: 5), () {
          if (_shouldAutoPlay && mounted && _isInitialized) {
            _controller?.play();
          }
        });
      }
    } else {
      // Pause when less than 50% visible
      if (info.visibleFraction < 0.5) {
        _shouldAutoPlay = false;
        if (_controller?.value.isPlaying == true) {
          _controller?.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_${widget.videoUrl}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail or black background
          if (!_isInitialized || _hasError)
            Container(
              color: Colors.black,
              child: widget.thumbnail != null
                  ? Image.network(
                      widget.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.video_library,
                            size: 64,
                            color: Colors.white54,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.video_library,
                        size: 64,
                        color: Colors.white54,
                      ),
                    ),
            ),

          // Video player
          if (_isInitialized && !_hasError)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (!_isInitialized && !_hasError)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          // Error message
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isInitialized = false;
                      });
                      _initializeVideo();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Play/Pause overlay
          if (_isInitialized && !_hasError)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Mute/Unmute button (bottom right)
          if (_isInitialized && !_hasError)
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _controller!.setVolume(
                      _controller!.value.volume > 0 ? 0.0 : 1.0,
                    );
                  });
                },
                icon: Icon(
                  _controller!.value.volume > 0
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}