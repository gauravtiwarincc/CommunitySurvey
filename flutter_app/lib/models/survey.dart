class SurveyOption {
  final String id;
  final String text;

  SurveyOption({
    required this.id,
    required this.text,
  });

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['optionId'] as String? ?? json['_id'] as String? ?? json['id'] as String? ?? '',
      text: json['text'] as String? ?? json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}

class SurveyQuestion {
  final String id;
  final String text;
  final String type; // e.g. "single", "multiple"
  final List<SurveyOption> options;

  SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    return SurveyQuestion(
      id: json['questionId'] as String? ?? json['_id'] as String? ?? json['id'] as String? ?? '',
      text: json['text'] as String? ?? json['question'] as String? ?? '',
      type: json['type'] as String? ?? 'single',
      options: optionsList.map((o) => SurveyOption.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class Survey {
  final String id;
  final String title;
  final String? description;
  final int rewardPoints;
  final bool isActive;
  final bool isCompleted;
  final String? organizationId;
  final List<SurveyQuestion> questions;
  final DateTime? expiresAt;

  Survey({
    required this.id,
    required this.title,
    this.description,
    this.rewardPoints = 0,
    this.isActive = true,
    this.isCompleted = false,
    this.organizationId,
    required this.questions,
    this.expiresAt,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    final idString = json['_id'] as String? ?? json['id'] as String? ?? '';
    
    // Deterministic countdown duration between 2 and 20 hours based on survey ID
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final hashVal = idString.hashCode;
    final dynamicHours = (hashVal.abs() % 18) + 2;
    var mockExpiresAt = todayStart.add(Duration(hours: dynamicHours + 12));
    if (mockExpiresAt.isBefore(now)) {
      mockExpiresAt = mockExpiresAt.add(const Duration(hours: 24));
    }

    return Survey(
      id: idString,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isCompleted: json['isCompleted'] as bool? ?? false,
      organizationId: json['organizationId'] as String?,
      questions: questionsList.map((q) => SurveyQuestion.fromJson(q as Map<String, dynamic>)).toList(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : mockExpiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'rewardPoints': rewardPoints,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'organizationId': organizationId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

class DashboardStats {
  final int availableCount;
  final int completedCount;
  final int rewardPoints;
  final int walletBalance;

  DashboardStats({
    required this.availableCount,
    required this.completedCount,
    required this.rewardPoints,
    required this.walletBalance,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      availableCount: json['availableCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      walletBalance: json['walletBalance'] as int? ?? 0,
    );
  }
}
