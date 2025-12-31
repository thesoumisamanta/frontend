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
  bool _isDisposed = false;
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    // Don't auto-initialize - wait for visibility
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    // Only initialize when video is prominently visible (70% or more)
    if (!_isDisposed && info.visibleFraction >= 0.7) {
      if (_controller == null && !_hasError) {
        _initializeVideo();
      } else if (_controller != null && _isInitialized) {
        _safePlay();
      }
    } else if (info.visibleFraction < 0.3) {
      // Pause and dispose when not visible
      _safePause();
      _disposeController();
    }
  }

  void _initializeVideo() async {
    if (_isDisposed || _controller != null) return;

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller!.initialize();

      if (_isDisposed) {
        _controller?.dispose();
        _controller = null;
        return;
      }

      // Add listener for play/pause state changes
      _listener = () {
        if (!_isDisposed && mounted && _controller != null) {
          final isPlaying = _controller!.value.isPlaying;
          if (_isPlaying != isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        }
      };

      _controller!.addListener(_listener!);
      _controller!.setLooping(true);

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        // Auto-play if enabled
        if (widget.autoPlay) {
          _safePlay();
        }
      }
    } catch (e) {
      print('Video initialization error: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
      _disposeController();
    }
  }

  void _disposeController() {
    if (_controller != null) {
      if (_listener != null) {
        _controller!.removeListener(_listener!);
        _listener = null;
      }
      _controller!.dispose();
      _controller = null;
    }
    
    if (!_isDisposed && mounted) {
      setState(() {
        _isInitialized = false;
        _isPlaying = false;
      });
    }
  }

  void _safePlay() {
    if (!_isDisposed && _controller != null && _isInitialized && mounted) {
      try {
        _controller!.play();
      } catch (e) {
        print('Play error: $e');
      }
    }
  }

  void _safePause() {
    if (!_isDisposed && _controller != null && _isInitialized && mounted) {
      try {
        _controller!.pause();
      } catch (e) {
        print('Pause error: $e');
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized || _isDisposed) return;

    if (_controller!.value.isPlaying) {
      _safePause();
    } else {
      _safePlay();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeController();
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
          if (_isInitialized && !_hasError && _controller != null)
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

          // Loading indicator (only show when initializing, not on thumbnail)
          if (!_isInitialized && !_hasError && _controller != null)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Error message
          if (_hasError)
            Container(
              color: Colors.black87,
              child: Center(
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
                      'Unable to play video',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Video format may not be supported',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                        });
                        _initializeVideo();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
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
                    opacity: _isPlaying ? 0.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
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
          if (_isInitialized && !_hasError && _controller != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {
                    if (_controller != null && !_isDisposed) {
                      setState(() {
                        _controller!.setVolume(
                          _controller!.value.volume > 0 ? 0.0 : 1.0,
                        );
                      });
                    }
                  },
                  icon: Icon(
                    _controller!.value.volume > 0
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}