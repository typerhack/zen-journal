class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.body,
    required this.wordCount,
    this.prompt,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? prompt;
  final String body;
  final int wordCount;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'prompt': prompt,
      'body': body,
      'word_count': wordCount,
    };
  }

  factory JournalEntry.fromMap(Map<String, Object?> map) {
    return JournalEntry(
      id: map['id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']! as int),
      prompt: map['prompt'] as String?,
      body: map['body']! as String,
      wordCount: map['word_count']! as int,
    );
  }
}
