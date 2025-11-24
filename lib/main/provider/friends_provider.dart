import 'package:campcon/main/models/story_model.dart';
import 'package:flutter/widgets.dart';

class FriendsTabProvider extends ChangeNotifier {
  int _selectedTabIndex = 1;
  
  final List<Story> _stories = [];
  final List<Post> _posts = [];

  int get selectedTabIndex => _selectedTabIndex;
  List<Story> get stories => _stories;
  List<Post> get posts => _posts;

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void addStory(Story story) {
    _stories.add(story);
    notifyListeners();
  }

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void setStories(List<Story> stories) {
    _stories.clear();
    _stories.addAll(stories);
    notifyListeners();
  }

  void setPosts(List<Post> posts) {
    _posts.clear();
    _posts.addAll(posts);
    notifyListeners();
  }
}