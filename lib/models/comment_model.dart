class Comment {
  final String commentId;
  final String commenterName;
  final String commentText;
  final String commentTime;
  final List<Map<String, String>> taggedUsers;
  final List<Reply> replies;
  bool showReplies = false;

  Comment({
    required this.commentId,
    required this.commenterName,
    required this.commentText,
    required this.commentTime,
    required this.taggedUsers,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> taggedUsers = (json['tagged'] as List<dynamic>)
        .map((taggedUserMap) => Map<String, String>.from(taggedUserMap))
        .toList();

    List<dynamic> repliesData = json['replies'] as List<dynamic>;
    List<Reply> replies = repliesData.map((replyMap) => Reply.fromJson(replyMap)).toList();

    return Comment(
      commentId: json['comment_id'] as String,
      commenterName: json['name'] as String,
      commentText: json['comment'] as String,
      commentTime: json['time'] as String,
      taggedUsers: taggedUsers,
      replies: replies,
    );
  }
}

class Reply {
  final String replyId;
  final String replierName;
  final String replyText;
  final String replyTime;
  final List<Map<String, String>> taggedUsers;
  final List<Reply> replyOfReply;

  Reply({
    required this.replyId,
    required this.replierName,
    required this.replyText,
    required this.replyTime,
    required this.taggedUsers,
    required this.replyOfReply,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> taggedUsers = (json['tagged'] as List<dynamic>)
        .map((taggedUserMap) => Map<String, String>.from(taggedUserMap))
        .toList();

    List<dynamic> replyOfReplyData = json['replyOfReply'] as List<dynamic>;
    List<Reply> replyOfReply = replyOfReplyData.map((replyMap) => Reply.fromJson(replyMap)).toList();

    return Reply(
      replyId: json['comment_id'] as String,
      replierName: json['name'] as String,
      replyText: json['comment'] as String,
      replyTime: json['time'] as String,
      taggedUsers: taggedUsers,
      replyOfReply: replyOfReply,
    );
  }
}