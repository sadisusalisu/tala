import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/language_provider.dart';
import '../providers/story_provider.dart';
import '../screens/story_detail_screen.dart';

class StoryCard extends StatelessWidget {
  final Story story;

  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, StoryProvider>(
      builder: (context, languageProvider, storyProvider, child) {
        final isFavorite = storyProvider.isFavorite(story.id);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.lightBlue.shade50,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryDetailScreen(story: story),
                ),
              );
            },
            child: SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Image or Icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.pink.shade100,
                        child: story.imageUrl != null
                            ? Image.network(
                          story.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.auto_stories, size: 30, color: Colors.deepPurple),
                        )
                            : Icon(Icons.auto_stories, size: 30, color: Colors.deepPurple),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      story.getTitle(languageProvider.currentLanguage),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        languageProvider.translate(story.category),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Short Summary
                    Text(
                      story.getSummary(languageProvider.currentLanguage),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Listen Button (visible only if audio exists)
                    if (story.getAudioUrl(languageProvider.currentLanguage) != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Optionally auto-play or go to detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryDetailScreen(story: story),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: Text(languageProvider.translate("listen")),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
