import 'package:cloud_firestore/cloud_firestore.dart';

class PollOption {
  final String id;
  final String text;
  final int votes;
  final List<String> votedBy; // List of user IDs who voted for this option

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.votedBy = const [],
  });

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      votes: map['votes'] ?? 0,
      votedBy: List<String>.from(map['votedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
      'votedBy': votedBy,
    };
  }

  PollOption copyWith({
    String? id,
    String? text,
    int? votes,
    List<String>? votedBy,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
      votedBy: votedBy ?? this.votedBy,
    );
  }
}

class PollModel {
  final String pollId;
  final String question;
  final List<PollOption> options;
  final DateTime startDate;
  final DateTime endDate;
  final int totalVotes;
  final bool isMultiChoice;
  final bool isClosed;
  final String createdBy;
  final DateTime createdAt;

  PollModel({
    required this.pollId,
    required this.question,
    required this.options,
    required this.startDate,
    required this.endDate,
    this.totalVotes = 0,
    this.isMultiChoice = false,
    this.isClosed = false,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !isClosed;
  }

  bool get hasEnded {
    return DateTime.now().isAfter(endDate) || isClosed;
  }

  Duration get timeRemaining {
    final remaining = endDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory PollModel.fromMap(Map<String, dynamic> map) {
    return PollModel(
      pollId: map['pollId'] ?? '',
      question: map['question'] ?? '',
      options: (map['options'] as List?)
              ?.map((opt) => PollOption.fromMap(opt as Map<String, dynamic>))
              .toList() ??
          [],
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.parse(
              map['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.parse(map['endDate'] ?? DateTime.now().toIso8601String()),
      totalVotes: map['totalVotes'] ?? 0,
      isMultiChoice: map['isMultiChoice'] ?? false,
      isClosed: map['isClosed'] ?? false,
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pollId': pollId,
      'question': question,
      'options': options.map((opt) => opt.toMap()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalVotes': totalVotes,
      'isMultiChoice': isMultiChoice,
      'isClosed': isClosed,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PollModel copyWith({
    String? pollId,
    String? question,
    List<PollOption>? options,
    DateTime? startDate,
    DateTime? endDate,
    int? totalVotes,
    bool? isMultiChoice,
    bool? isClosed,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return PollModel(
      pollId: pollId ?? this.pollId,
      question: question ?? this.question,
      options: options ?? this.options,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalVotes: totalVotes ?? this.totalVotes,
      isMultiChoice: isMultiChoice ?? this.isMultiChoice,
      isClosed: isClosed ?? this.isClosed,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
