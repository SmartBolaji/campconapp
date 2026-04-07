import 'package:campcon/main/constants/vars_constants.dart';

/// Service to automatically extract tags from post content
class PostTaggingService {
  static final UsableData _data = UsableData();

  /// Extract tags from post content based on predefined categories
  static List<String> extractTags(String content) {
    if (content.isEmpty) return [];

    final contentLower = content.toLowerCase();
    final extractedTags = <String>{};

    // Match against interest categories
    for (final interest in _data.interest) {
      if (contentLower.contains(interest.toLowerCase())) {
        extractedTags.add(interest);
      }
    }

    // Match common keywords to categories
    final keywordMap = {
      // Technology
      'tech': 'Technology',
      'coding': 'Technology',
      'programming': 'Technology',
      'software': 'Technology',
      'app': 'Technology',
      'ai': 'Technology',
      'phone': 'Technology',
      'laptop': 'Technology',
      'computer': 'Technology',

      // Sports
      'football': 'Sports',
      'basketball': 'Sports',
      'soccer': 'Sports',
      'gym': 'Sports',
      'workout': 'Sports',
      'match': 'Sports',
      'game': 'Sports',
      'training': 'Sports',

      // Music
      'song': 'Music',
      'album': 'Music',
      'artist': 'Music',
      'concert': 'Music',
      'band': 'Music',
      'playlist': 'Music',
      'listening': 'Music',

      // Education
      'class': 'Education',
      'lecture': 'Education',
      'exam': 'Education',
      'study': 'Education',
      'assignment': 'Education',
      'course': 'Education',
      'professor': 'Education',
      'test': 'Education',
      'homework': 'Education',
      'library': 'Education',

      // Food
      'food': 'Food',
      'eat': 'Food',
      'restaurant': 'Food',
      'lunch': 'Food',
      'dinner': 'Food',
      'breakfast': 'Food',
      'hungry': 'Food',
      'cooking': 'Food',
      'recipe': 'Food',

      // Gaming
      'gaming': 'Gaming',
      'video game': 'Gaming',
      'ps5': 'Gaming',
      'xbox': 'Gaming',
      'nintendo': 'Gaming',
      'streamer': 'Gaming',
      'esports': 'Gaming',

      // Fashion
      'outfit': 'Fashion',
      'clothes': 'Fashion',
      'style': 'Fashion',
      'wearing': 'Fashion',
      'drip': 'Fashion',
      'fit': 'Fashion',

      // Movies
      'movie': 'Movies',
      'film': 'Movies',
      'watching': 'Movies',
      'cinema': 'Movies',
      'netflix': 'Movies',
      'series': 'Movies',
      'show': 'Movies',

      // Fitness
      'fitness': 'Fitness',
      'exercise': 'Fitness',
      'running': 'Fitness',
      'health': 'Fitness',
      'weight': 'Fitness',

      // Travel
      'travel': 'Travel',
      'trip': 'Travel',
      'vacation': 'Travel',
      'journey': 'Travel',
      'explore': 'Travel',

      // Business
      'business': 'Business & Finance',
      'money': 'Business & Finance',
      'invest': 'Business & Finance',
      'startup': 'Business & Finance',
      'entrepreneur': 'Business & Finance',
      'job': 'Business & Finance',
      'career': 'Business & Finance',
      'internship': 'Business & Finance',

      // Art
      'art': 'Art',
      'draw': 'Art',
      'paint': 'Art',
      'design': 'Art',
      'creative': 'Art',

      // Photography
      'photo': 'Photography',
      'camera': 'Photography',
      'shoot': 'Photography',
      'picture': 'Photography',

      // Nature
      'nature': 'Nature',
      'outdoor': 'Nature',
      'environment': 'Nature',
      'trees': 'Nature',
      'park': 'Nature',

      // Health
      'mental health': 'Health & Wellness',
      'wellness': 'Health & Wellness',
      'therapy': 'Health & Wellness',
      'self care': 'Health & Wellness',
    };

    for (final entry in keywordMap.entries) {
      if (contentLower.contains(entry.key)) {
        extractedTags.add(entry.value);
      }
    }

    return extractedTags.toList();
  }

  /// Get all available tag categories
  static List<String> get availableTags => _data.interest;
}
