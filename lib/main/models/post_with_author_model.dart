import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';

/// Model combining a post with its author information
class PostWithAuthor {
  final PostModel post;
  final UserModel? author;

  PostWithAuthor({
    required this.post,
    this.author,
  });
}
