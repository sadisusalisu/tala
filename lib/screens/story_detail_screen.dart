import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/language_provider.dart';
import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/login_dialog.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void dispose() {
    // Clean up any resources when the screen is disposed
    super.dispose();
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LoginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(
              widget.story.getTitle(languageProvider.currentLanguage),
              style: const TextStyle(fontSize: 18),
            );
          },
        ),
        actions: [
          Consumer2<StoryProvider, LanguageProvider>(
            builder: (context, storyProvider, languageProvider, child) {
              final isFavorite = storyProvider.isFavorite(widget.story.id);
              return IconButton(
                onPressed: () {
                  storyProvider.toggleFavorite(widget.story.id);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                tooltip: isFavorite
                    ? languageProvider.translate('remove_from_favorites')
                    : languageProvider.translate('add_to_favorites'),
              );
            },
          ),
          Consumer2<AuthProvider, LanguageProvider>(
            builder: (context, authProvider, languageProvider, child) {
              return PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      if (authProvider.requiresLogin()) {
                        Future.delayed(Duration.zero, () => _showLoginDialog(context));
                      } else {
                        // Implement download functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              languageProvider.translate('download_offline'),
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.download),
                        const SizedBox(width: 8),
                        Text(languageProvider.translate('download_offline')),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          final audioUrl = widget.story.getAudioUrl(languageProvider.currentLanguage);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story image with improved loading and error handling
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: widget.story.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.story.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        );
                      },
                    ),
                  )
                      : Icon(
                    Icons.book,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // Story title with better text scaling
                Text(
                  widget.story.getTitle(languageProvider.currentLanguage),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Category chip with visual feedback
                GestureDetector(
                  onTap: () {
                    // Could implement category filtering here
                  },
                  child: Chip(
                    label: Text(languageProvider.translate(widget.story.category)),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),

                const SizedBox(height: 16),

                // Audio player with state management
                if (audioUrl != null)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AudioPlayerWidget(
                        audioUrl: audioUrl,
                        storyId: widget.story.id,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Story text with improved readability
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      widget.story.getText(languageProvider.currentLanguage),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Guest mode notice with better visibility
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isGuestMode) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                languageProvider.translate('login_message'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.login),
                                label: Text(languageProvider.translate('login')),
                                onPressed: () => _showLoginDialog(context),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}