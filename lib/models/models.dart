export 'analytics_profile_model.dart';
export 'job_match_result_model.dart';
export 'job_model.dart';
export 'lift_taxonomy.dart';
export 'question_model.dart';

import 'lift_taxonomy.dart';

enum AchievementType { certificate, volunteer, project }

extension AchievementTypeX on AchievementType {
  String get label {
    switch (this) {
      case AchievementType.certificate:
        return 'Сертификаты';
      case AchievementType.volunteer:
        return 'Волонтерство';
      case AchievementType.project:
        return 'Проекты';
    }
  }

  String get shortLabel {
    switch (this) {
      case AchievementType.certificate:
        return 'Сертификат';
      case AchievementType.volunteer:
        return 'Волонтерство';
      case AchievementType.project:
        return 'Проект';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementType.certificate:
        return '🎓';
      case AchievementType.volunteer:
        return '🤝';
      case AchievementType.project:
        return '🚀';
    }
  }
}

enum AchievementFilter { all, certificates, volunteering, projects }

extension AchievementFilterX on AchievementFilter {
  String get label {
    switch (this) {
      case AchievementFilter.all:
        return 'Все';
      case AchievementFilter.certificates:
        return 'Сертификаты';
      case AchievementFilter.volunteering:
        return 'Волонтерство';
      case AchievementFilter.projects:
        return 'Проекты';
    }
  }

  bool matches(UserAchievement achievement) {
    switch (this) {
      case AchievementFilter.all:
        return true;
      case AchievementFilter.certificates:
        return achievement.type == AchievementType.certificate;
      case AchievementFilter.volunteering:
        return achievement.type == AchievementType.volunteer;
      case AchievementFilter.projects:
        return achievement.type == AchievementType.project;
    }
  }
}

class UserAchievement {
  const UserAchievement({
    required this.id,
    required this.title,
    required this.organization,
    required this.type,
    required this.aiWeight,
    required this.skillBoosts,
    this.description = '',
    this.dateLabel = '',
    this.tags = const [],
    this.isVerified = true,
  });

  final String id;
  final String title;
  final String organization;
  final AchievementType type;
  final double aiWeight;
  final Map<String, double> skillBoosts;
  final String description;
  final String dateLabel;
  final List<String> tags;
  final bool isVerified;

  String get typeLabel => type.shortLabel;
  String get typeEmoji => type.emoji;
  bool get isTopTier => aiWeight >= 8.0;
  List<String> get boostedAxes => List.unmodifiable(skillBoosts.keys);

  double boostFor(String axis) {
    return (skillBoosts[axis] ?? 0) * aiWeight;
  }

  UserAchievement copyWith({
    String? id,
    String? title,
    String? organization,
    AchievementType? type,
    double? aiWeight,
    Map<String, double>? skillBoosts,
    String? description,
    String? dateLabel,
    List<String>? tags,
    bool? isVerified,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      type: type ?? this.type,
      aiWeight: aiWeight ?? this.aiWeight,
      skillBoosts: skillBoosts ?? this.skillBoosts,
      description: description ?? this.description,
      dateLabel: dateLabel ?? this.dateLabel,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

const Map<String, double> defaultAchievementCaps = {
  LiftAxes.communication: 12.0,
  LiftAxes.logic: 12.0,
  LiftAxes.creativity: 12.0,
  LiftAxes.organization: 12.0,
  LiftAxes.technical: 12.0,
};
