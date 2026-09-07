class CommandChange {
  final String target;
  final String description;
  final dynamic before;
  final dynamic after;

  const CommandChange({
    required this.target,
    required this.description,
    this.before,
    this.after,
  });

  factory CommandChange.fromJson(Map<String, dynamic> json) {
    return CommandChange(
      target: json['target']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      before: json['before'],
      after: json['after'],
    );
  }

  Map<String, dynamic> toJson() => {
    'target': target,
    'description': description,
    if (before != null) 'before': before,
    if (after != null) 'after': after,
  };
}

class CommandPreview {
  final String commandName;
  final String category; // 'workout', 'nutrition', 'recovery', 'profile'
  final String risk; // 'low', 'high'
  final String summary;
  final String? title;
  final String? inverseCommand;
  final List<CommandChange> changes;
  final List<String> warnings;
  final String? pendingActionId;

  const CommandPreview({
    required this.commandName,
    required this.category,
    required this.risk,
    required this.summary,
    this.title,
    this.inverseCommand,
    this.changes = const [],
    this.warnings = const [],
    this.pendingActionId,
  });

  bool get isHighRisk => risk == 'high';
  String get displayTitle => title ?? summary;

  factory CommandPreview.fromJson(Map<String, dynamic> json) {
    final rawChanges = json['changes'] as List? ?? [];
    final changesList = rawChanges.map((c) {
      if (c is Map) {
        return CommandChange.fromJson(Map<String, dynamic>.from(c));
      }
      return CommandChange(target: '', description: c.toString());
    }).toList();

    final rawWarnings = json['warnings'] as List? ?? [];
    final warningsList = rawWarnings.map((w) => w.toString()).toList();

    return CommandPreview(
      commandName: json['commandName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'workout',
      risk: json['risk']?.toString() ?? 'low',
      summary: json['summary']?.toString() ?? '',
      title: json['title']?.toString() ?? json['summary']?.toString(),
      inverseCommand: json['inverseCommand']?.toString(),
      changes: changesList,
      warnings: warningsList,
      pendingActionId: json['pendingActionId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'commandName': commandName,
    'category': category,
    'risk': risk,
    'summary': summary,
    if (title != null) 'title': title,
    if (inverseCommand != null) 'inverseCommand': inverseCommand,
    'changes': changes.map((c) => c.toJson()).toList(),
    'warnings': warnings,
    if (pendingActionId != null) 'pendingActionId': pendingActionId,
  };
}
