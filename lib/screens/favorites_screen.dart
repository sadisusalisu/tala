import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/story_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<StoryProvider, LanguageProvider>(
      builder: (context, storyProvider, languageProvider, child) {
        final favoriteStories = storyProvider.getFavoriteStories();

        if (favoriteStories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  languageProvider.translate('no_favorites'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: storyProvider.fetchStories,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteStories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StoryCard(story: favoriteStories[index]),
              );
            },
          ),
        );
      },
    );
  }
}