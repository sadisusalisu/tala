class Story {
  final String id;
  final String titleHa;
  final String titleEn;
  final String summaryHa;
  final String summaryEn;
  final String textHa;
  final String textEn;
  final String? audioUrlHa;
  final String? audioUrlEn;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.titleHa,
    required this.titleEn,
    required this.summaryHa,
    required this.summaryEn,
    required this.textHa,
    required this.textEn,
    this.audioUrlHa,
    this.audioUrlEn,
    required this.category,
    this.imageUrl,
    required this.createdAt,
  });

  String getTitle(String language) {
    return language == 'ha' ? titleHa : titleEn;
  }

  String getSummary(String language) {
    return language == 'ha' ? summaryHa : summaryEn;
  }

  String getText(String language) {
    return language == 'ha' ? textHa : textEn;
  }

  String? getAudioUrl(String language) {
    return language == 'ha' ? audioUrlHa : audioUrlEn;
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      titleHa: json['title_ha'] ?? '',
      titleEn: json['title_en'] ?? '',
      summaryHa: json['summary_ha'] ?? '',
      summaryEn: json['summary_en'] ?? '',
      textHa: json['text_ha'] ?? '',
      textEn: json['text_en'] ?? '',
      audioUrlHa: json['audio_url_ha'],
      audioUrlEn: json['audio_url_en'],
      category: json['category'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ha': titleHa,
      'title_en': titleEn,
      'summary_ha': summaryHa,
      'summary_en': summaryEn,
      'text_ha': textHa,
      'text_en': textEn,
      'audio_url_ha': audioUrlHa,
      'audio_url_en': audioUrlEn,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}