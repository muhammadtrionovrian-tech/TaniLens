import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/analysis_result.dart';
import '../theme/app_colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final AnalysisResult result;

  const VideoPlayerScreen({super.key, required this.result});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _controller;
  late AnimationController _waveController;

  /// Extracts YouTube video ID from various URL formats
  String _extractVideoId(String url) {
    final patterns = [
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) return match.group(1)!;
    }
    return 'KLuTLF3x9sA'; // fallback
  }

  @override
  void initState() {
    super.initState();

    final videoId = _extractVideoId(widget.result.videoUrl);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false, // Hide YouTube native controls
        showFullscreenButton: false, // Hide fullscreen button
        mute: false,
        loop: false,
        strictRelatedVideos: true,
        privacyEnhancedMode:
            true, // Use youtube-nocookie.com (avoids restrictions)
        playsInline: true,
        enableCaption: false,
      ),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.close();
    _waveController.dispose();
    super.dispose();
  }

  String _fmt(double s, {bool forceHours = false}) {
    final h = (s / 3600).floor();
    final m = ((s % 3600) / 60).floor();
    final sec = (s % 60).floor();
    if (h > 0 || forceHours) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    } else {
      return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tutorial: Penanganan ${widget.result.diseaseName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ── Video area ─────────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: YoutubeValueBuilder(
                        controller: _controller,
                        builder: (context, value) {
                          final isPlaying =
                              value.playerState == PlayerState.playing;
                          final isReady =
                              value.playerState != PlayerState.unknown &&
                              value.playerState != PlayerState.unStarted;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // YouTube player widget (hidden native controls)
                              YoutubePlayer(
                                controller: _controller,
                                aspectRatio: 16 / 9,
                              ),

                              // Transparent tap overlay (blocks YouTube native UI)
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (isPlaying) {
                                      _controller.pauseVideo();
                                    } else {
                                      _controller.playVideo();
                                    }
                                  },
                                  child: Container(color: Colors.transparent),
                                ),
                              ),

                              // Loading spinner
                              if (!isReady)
                                const CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),

                              // Pulsing wave while playing
                              if (isPlaying && isReady)
                                AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) => IgnorePointer(
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: (1.0 - _waveController.value)
                                                .clamp(0.0, 1.0),
                                          ),
                                          width:
                                              2.0 +
                                              (_waveController.value * 8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // Paused overlay icon
                              if (isReady)
                                AnimatedOpacity(
                                  opacity: isPlaying ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: IgnorePointer(
                                    ignoring: isPlaying,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),

                              // Caption badge
                              if (isReady)
                                Positioned(
                                  bottom: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xB2000000),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: AppColors.primary,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isPlaying
                                              ? 'Memutar Materi Penanganan...'
                                              : 'Video Dijeda',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // ── Custom controls ────────────────────────────────────────────
              YoutubeValueBuilder(
                controller: _controller,
                builder: (context, value) {
                  final isPlaying = value.playerState == PlayerState.playing;
                  final isReady =
                      value.playerState != PlayerState.unknown &&
                      value.playerState != PlayerState.unStarted;
                  final rawDuration = value.metaData.duration.inSeconds
                      .toDouble();
                  final duration = rawDuration > 0 ? rawDuration : 165.0;

                  return StreamBuilder<YoutubeVideoState>(
                    stream: _controller.videoStateStream,
                    initialData: const YoutubeVideoState(),
                    builder: (context, snapshot) {
                      final position =
                          snapshot.data?.position.inSeconds.toDouble() ?? 0.0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        color: Colors.black,
                        child: Column(
                          children: [
                            // Progress slider
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                              ),
                              child: Slider(
                                value: position.clamp(0.0, duration),
                                min: 0.0,
                                max: duration,
                                onChanged: isReady
                                    ? (v) => _controller.seekTo(
                                        seconds: v,
                                        allowSeekAhead: true,
                                      )
                                    : null,
                              ),
                            ),

                            // Time labels
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fmt(position, forceHours: duration >= 3600),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _fmt(duration, forceHours: duration >= 3600),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Play controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Replay 10s
                                IconButton(
                                  icon: const Icon(
                                    Icons.replay_10,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: isReady
                                      ? () => _controller.seekTo(
                                          seconds: (position - 10).clamp(
                                            0.0,
                                            duration,
                                          ),
                                          allowSeekAhead: true,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 32),

                                // Play/Pause button
                                GestureDetector(
                                  onTap: isReady
                                      ? () {
                                          if (isPlaying) {
                                            _controller.pauseVideo();
                                          } else {
                                            _controller.playVideo();
                                          }
                                        }
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isReady
                                          ? Colors.white
                                          : Colors.white38,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),

                                // Forward 10s
                                IconButton(
                                  icon: const Icon(
                                    Icons.forward_10,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: isReady
                                      ? () => _controller.seekTo(
                                          seconds: (position + 10).clamp(
                                            0.0,
                                            duration,
                                          ),
                                          allowSeekAhead: true,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
