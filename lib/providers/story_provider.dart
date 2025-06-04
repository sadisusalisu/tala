import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';

class StoryProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Story> _stories = [];
  List<String> _localFavorites = [];
  List<String> _userFavorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Story> get stories => _stories;
  List<String> get favorites => _userFavorites.isNotEmpty ? _userFavorites : _localFavorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StoryProvider() {
    _loadLocalFavorites();
    fetchStories();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _localFavorites = prefs.getStringList('local_favorites') ?? [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load local favorites';
      notifyListeners();
    }
  }

  Future<void> _saveLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('local_favorites', _localFavorites);
    } catch (e) {
      _errorMessage = 'Failed to save favorites';
      notifyListeners();
    }
  }

  Future<void> fetchStories() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase
          .from('stories')
          .select()
          .order('created_at', ascending: false);

      _stories = (response as List)
          .map((story) => Story.fromJson(story))
          .toList();

      // Load user favorites if authenticated
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _loadUserFavorites(user.id);
      }
    } on PostgrestException catch (e) {
      _errorMessage = 'Database error: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load stories. Please check your internet connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserFavorites(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('story_id')
          .eq('user_id', userId);

      _userFavorites = (response as List)
          .map((fav) => fav['story_id'] as String)
          .toList();
    } on PostgrestException catch (e) {
      _errorMessage = 'Failed to load user favorites: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load user favorites';
    }
  }

  List<Story> getStoriesByCategory(String category) {
    return _stories.where((story) => story.category == category).toList();
  }

  List<Story> getFavoriteStories() {
    final favoriteIds = favorites;
    return _stories.where((story) => favoriteIds.contains(story.id)).toList();
  }

  bool isFavorite(String storyId) {
    return favorites.contains(storyId);
  }

  Future<void> toggleFavorite(String storyId) async {
    final user = _supabase.auth.currentUser;

    if (user != null) {
      // User is authenticated, sync with Supabase
      if (_userFavorites.contains(storyId)) {
        await _removeFromUserFavorites(storyId, user.id);
      } else {
        await _addToUserFavorites(storyId, user.id);
      }
    } else {
      // Guest user, store locally
      if (_localFavorites.contains(storyId)) {
        _localFavorites.remove(storyId);
      } else {
        _localFavorites.add(storyId);
      }
      await _saveLocalFavorites();
    }

    notifyListeners();
  }

  Future<void> _addToUserFavorites(String storyId, String userId) async {
    try {
      await _supabase.from('favorites').insert({
        'user_id': userId,
        'story_id': storyId,
      });
      _userFavorites.add(storyId);
    } on PostgrestException catch (e) {
      _errorMessage = 'Failed to add to favorites: ${e.message}';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add to favorites';
      notifyListeners();
    }
  }

  Future<void> _removeFromUserFavorites(String storyId, String userId) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('story_id', storyId);
      _userFavorites.remove(storyId);
    } on PostgrestException catch (e) {
      _errorMessage = 'Failed to remove from favorites: ${e.message}';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove from favorites';
      notifyListeners();
    }
  }

  Future<void> syncLocalFavoritesToUser(String userId) async {
    // Sync local favorites to user account when they log in
    for (String storyId in _localFavorites) {
      await _addToUserFavorites(storyId, userId);
    }
    _localFavorites.clear();
    await _saveLocalFavorites();
  }

  // Search functionality
  List<Story> searchStories(String query) {
    if (query.isEmpty) return _stories;

    return _stories.where((story) {
      return story.titleEn.toLowerCase().contains(query.toLowerCase()) ||
          story.titleHa.toLowerCase().contains(query.toLowerCase()) ||
          story.summaryEn.toLowerCase().contains(query.toLowerCase()) ||
          story.summaryHa.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get random story for featured content
  Story? getRandomStory() {
    if (_stories.isEmpty) return null;
    final shuffledStories = List<Story>.from(_stories);
    shuffledStories.shuffle();
    return shuffledStories.first;
  }
}