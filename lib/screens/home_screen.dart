import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/story_provider.dart';
import '../models/story.dart';
import '../widgets/story_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/language_toggle.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/featured_story_widget.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'dart:math'; // Added for Random
import 'dart:async'; // Added for Timer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  int _featuredStoryIndex = 0; // Added to track featured story index
  late Timer _featuredStoryTimer; // Added for timer

  late AnimationController _tabAnimationController;
  late AnimationController _chipAnimationController;
  late AnimationController _greetingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _greetingAnimation;

  final List<String> _categories = [
    'all',
    'folktales',
    'religious',
    'bedtime',
    'educational',
  ];

  final Map<String, Color> _categoryColors = {
    'all': const Color(0xFFFFC1CC),
    'folktales': const Color(0xFFFFE4B5),
    'religious': const Color(0xFFDDEEFF),
    'bedtime': const Color(0xFFB6E5D8),
    'educational': const Color(0xFFFFF4CC),
  };

  final Map<String, IconData> _categoryIcons = {
    'all': Icons.auto_stories_rounded,
    'folktales': Icons.castle_rounded,
    'religious': Icons.menu_book_rounded, // Fixed: Replaced StoriesScreen() with Icons.menu_book_rounded
    'bedtime': Icons.bedtime_rounded,
    'educational': Icons.school_rounded,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Initialize timer to change featured story every 6 seconds
    _featuredStoryTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      setState(() {
        // Randomly select a new story index
        final stories = Provider.of<StoryProvider>(context, listen: false).stories;
        if (stories.isNotEmpty) {
          _featuredStoryIndex = Random().nextInt(stories.length);
        }
      });
    });
  }

  void _initializeAnimations() {
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _chipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _greetingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _greetingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _greetingAnimationController,
      curve: Curves.easeOutBack,
    ));

    _tabAnimationController.forward();
    _greetingAnimationController.forward();
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    _chipAnimationController.dispose();
    _greetingAnimationController.dispose();
    _featuredStoryTimer.cancel(); // Dispose the timer
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! 🌞';
    if (hour < 17) return 'Good Afternoon! 🌈';
    return 'Good Evening! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: _buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: IndexedStack(
                key: ValueKey(_currentIndex),
                index: _currentIndex,
                children: [
                  _buildStoriesTab(constraints),
                  const FavoritesScreen(),
                  const SettingsScreen(),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButton() : null,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        return FloatingActionButton(
          onPressed: () => storyProvider.fetchStories(),
          backgroundColor: const Color(0xFF6B73FF),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.refresh_rounded, size: 28),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return Row(
            children: [
              ScaleTransition(
                scale: _greetingAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: const Color(0xFF6B73FF),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('app_name'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2A44),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const LanguageToggle(),
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 64,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F0FF),
              Color(0xFFF8FBFF),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _tabAnimationController.reset();
                _tabAnimationController.forward();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF6B73FF),
              unselectedItemColor: const Color(0xFF9CA3AF),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.auto_stories_rounded, 0),
                  label: languageProvider.translate('stories'),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.favorite_rounded, 1),
                  label: languageProvider.translate('favorites'),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.settings_rounded, 2),
                  label: languageProvider.translate('settings'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6B73FF).withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: isSelected ? 26 : 24,
      ),
    );
  }

  Widget _buildStoriesTab(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar at the top
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SearchBarWidget(
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
              ),

              // Featured story section
              Consumer<StoryProvider>(
                builder: (context, storyProvider, child) {
                  final stories = storyProvider.stories;
                  return stories.isNotEmpty
                      ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6B73FF).withOpacity(0.15),
                                    const Color(0xFF6B73FF).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                color: const Color(0xFF6B73FF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Featured Story',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2A44),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 1000),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: StoryCard(
                            key: ValueKey(stories[_featuredStoryIndex].id),
                            story: stories[_featuredStoryIndex],
                          ),
                        ),
                      ],
                    ),
                  )
                      : const SizedBox.shrink();
                },
              ),

              // Category chips section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6B73FF).withOpacity(0.15),
                            const Color(0xFF6B73FF).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: const Color(0xFF6B73FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Categories',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A44),
                      ),
                    ),
                  ],
                ),
              ),

              // Category chips
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildCompactCategoryChip(
                            category: category,
                            isSelected: isSelected,
                            languageProvider: languageProvider,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Stories section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6B73FF).withOpacity(0.15),
                            const Color(0xFF6B73FF).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.library_books_rounded,
                        color: const Color(0xFF6B73FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedCategory == 'all'
                          ? 'All Stories'
                          : _selectedCategory.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A44),
                      ),
                    ),
                    const Spacer(),
                    Consumer<StoryProvider>(
                      builder: (context, storyProvider, child) {
                        final count = _searchQuery.isNotEmpty
                            ? storyProvider.searchStories(_searchQuery).length
                            : _selectedCategory == 'all'
                            ? storyProvider.stories.length
                            : storyProvider.getStoriesByCategory(_selectedCategory).length;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6B73FF).withOpacity(0.15),
                                const Color(0xFF6B73FF).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B73FF),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Stories grid
              Consumer<StoryProvider>(
                builder: (context, storyProvider, child) {
                  if (storyProvider.isLoading) {
                    return _buildLoadingState();
                  }

                  if (storyProvider.errorMessage != null) {
                    return _buildErrorState(storyProvider);
                  }

                  List<Story> stories;

                  if (_searchQuery.isNotEmpty) {
                    stories = storyProvider.searchStories(_searchQuery);
                  } else if (_selectedCategory == 'all') {
                    stories = storyProvider.stories;
                  } else {
                    stories = storyProvider.getStoriesByCategory(_selectedCategory);
                  }

                  if (stories.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildProminentStoriesList(stories, storyProvider, constraints);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCategoryChip({
    required String category,
    required bool isSelected,
    required LanguageProvider languageProvider,
  }) {
    final color = _categoryColors[category] ?? const Color(0xFFE5E7EB);
    final icon = _categoryIcons[category] ?? Icons.category_rounded;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        _chipAnimationController.forward().then((_) {
          _chipAnimationController.reverse();
        });
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: isSelected ? 1.05 : 1.0).animate(
          CurvedAnimation(
            parent: _chipAnimationController,
            curve: Curves.easeInOut,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.6) : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? color.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 10 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? const Color(0xFF1F2A44)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                category == 'all'
                    ? languageProvider.translate('all_categories')
                    : languageProvider.translate(category),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1F2A44)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B73FF)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading magical stories...',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(StoryProvider storyProvider) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFEE2E2),
                  const Color(0xFFFFF1F2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A44),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            storyProvider.errorMessage!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              storyProvider.clearError();
              storyProvider.fetchStories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B73FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      languageProvider.translate('try_again'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF0F9FF),
                      const Color(0xFFE8F0FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: const Color(0xFF6B73FF),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No stories found'
                    : languageProvider.translate('no_stories'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2A44),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try searching for something else'
                    : 'Check back later for new stories',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProminentStoriesList(
      List<Story> stories, StoryProvider storyProvider, BoxConstraints constraints) {
    return RefreshIndicator(
      onRefresh: storyProvider.fetchStories,
      color: const Color(0xFF6B73FF),
      backgroundColor: Colors.white,
      child: Container(
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: stories.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              curve: Curves.easeOutCubic,
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _tabAnimationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                  ),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: _tabAnimationController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0),
                      ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  )),
                  child: StoryCard(story: stories[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}