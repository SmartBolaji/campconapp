import 'package:campcon/main/models/post_model.dart';
import 'package:flutter/widgets.dart';

class FriendsTabProvider extends ChangeNotifier {
  int _selectedTabIndex = 1;

  // Posts use real PostModel instead of old story_model placeholders.
  final List<PostModel> _posts = [];

  int get selectedTabIndex => _selectedTabIndex;
  List<PostModel> get posts => _posts;

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void setPosts(List<PostModel> posts) {
    _posts.clear();
    _posts.addAll(posts);
    notifyListeners();
  }

  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}
