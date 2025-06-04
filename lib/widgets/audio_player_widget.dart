import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/language_provider.dart';

class AudioPlayerWidget extends StatelessWidget {
  final String audioUrl;
  final String storyId;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, LanguageProvider>(
      builder: (context, audioProvider, languageProvider, child) {
        final isCurrentStory = audioProvider.currentStoryId == storyId;
        final isPlaying = isCurrentStory && audioProvider.isPlaying;
        final isLoading = isCurrentStory && audioProvider.isLoading;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Play/Pause button
                    IconButton(
                      onPressed: isLoading ? null : () {
                        if (isPlaying) {
                          audioProvider.pauseAudio();
                        } else {
                          audioProvider.playAudio(audioUrl, storyId);
                        }
                      },
                      icon: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 32,
                            ),
                    ),
                    
                    // Progress slider
                    Expanded(
                      child: Column(
                        children: [
                          if (isCurrentStory)
                            Slider(
                              value: audioProvider.position.inMilliseconds.toDouble(),
                              max: audioProvider.duration.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                audioProvider.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            )
                          else
                            Slider(
                              value: 0,
                              max: 100,
                              onChanged: null,
                            ),
                          
                          // Time display
                          if (isCurrentStory)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(audioProvider.position),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    _formatDuration(audioProvider.duration),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Stop button
                    IconButton(
                      onPressed: isCurrentStory ? () {
                        audioProvider.stopAudio();
                      } : null,
                      icon: const Icon(Icons.stop),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Audio controls label
                Row(
                  children: [
                    Icon(
                      Icons.headphones,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      languageProvider.translate('listen'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}