import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../models/mock_data.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _savedAchievements.addAll(_seedAchievements);
    for (final achievement in _savedAchievements) {
      _applyAchievementBoosts(achievement);
    }
    _registerVisit(DateTime.now(), notify: false);
    _recalculateLevelProgress();
  }

  static const int _xpPerLevel = 1000;
  static const int _achievementXpMultiplier = 40;

  final List<UserAchievement> _mockAchievements = const [
    UserAchievement(
      id: 'ach_cert_ux',
      title: 'UX & Product Design Bootcamp',
      organization: 'Open Design Lab',
      type: AchievementType.certificate,
      aiWeight: 7.5,
      skillBoosts: {LiftAxes.creativity: 0.45, LiftAxes.communication: 0.20},
      description:
          'Интенсив по пользовательским сценариям, упаковке идей и UX-исследованию.',
      dateLabel: 'Март 2026',
      tags: ['UX-мышление', 'Креативность', 'Сторителлинг'],
    ),
    UserAchievement(
      id: 'ach_vol_tedx',
      title: 'Волонтер TEDx Youth',
      organization: 'TEDx Youth Almaty',
      type: AchievementType.volunteer,
      aiWeight: 8.5,
      skillBoosts: {LiftAxes.communication: 0.45, LiftAxes.organization: 0.30},
      description:
          'Координация гостей, работа с потоком и поддержка event-команды на большом событии.',
      dateLabel: 'Февраль 2026',
      tags: ['Коммуникация', 'Лидерство', 'Организация'],
    ),
    UserAchievement(
      id: 'ach_proj_smm',
      title: 'SMM-проект для приюта животных',
      organization: 'Shelter Impact Team',
      type: AchievementType.project,
      aiWeight: 6.0,
      skillBoosts: {LiftAxes.creativity: 0.50, LiftAxes.communication: 0.25},
      description:
          'Контент-план, съемка stories и запуск кампании для привлечения волонтеров.',
      dateLabel: 'Январь 2026',
      tags: ['Креативность', 'Сторителлинг', 'Коммуникация'],
    ),
    UserAchievement(
      id: 'ach_proj_ecofest',
      title: 'Project Lead школьного Eco Fest',
      organization: 'Green Future School',
      type: AchievementType.project,
      aiWeight: 8.0,
      skillBoosts: {
        LiftAxes.organization: 0.45,
        LiftAxes.communication: 0.25,
        LiftAxes.logic: 0.10,
      },
      description:
          'Собрал(а) партнеров, программу и тайминг эко-фестиваля на 300+ участников.',
      dateLabel: 'Апрель 2026',
      tags: ['Организация', 'Стратегия', 'Лидерство'],
    ),
    UserAchievement(
      id: 'ach_vol_python',
      title: 'Ментор Python-кружка для младших',
      organization: 'Lift Community',
      type: AchievementType.volunteer,
      aiWeight: 7.0,
      skillBoosts: {LiftAxes.technical: 0.35, LiftAxes.communication: 0.35},
      description:
          'Проводил(а) разбор задач и помогал(а) младшим участникам с первыми проектами.',
      dateLabel: 'Декабрь 2025',
      tags: ['Наставничество', 'Техничность', 'Коммуникация'],
    ),
    UserAchievement(
      id: 'ach_cert_data',
      title: 'Data Analytics Foundation',
      organization: 'Insight Academy',
      type: AchievementType.certificate,
      aiWeight: 9.0,
      skillBoosts: {LiftAxes.logic: 0.45, LiftAxes.technical: 0.35},
      description:
          'Курс по аналитике, гипотезам, визуализации данных и принятию решений на основе метрик.',
      dateLabel: 'Май 2026',
      tags: ['Аналитика', 'Логика', 'Техничность'],
    ),
  ];

  final List<UserAchievement> _savedAchievements = [];
  final Map<String, double> _achievementAxisTotals = {
    for (final axis in LiftAxes.all) axis: 0,
  };
  final Map<String, double> _quizAxisTotals = {
    for (final axis in LiftAxes.all) axis: 0,
  };
  final List<int> _quizAnswers = [];

  AchievementFilter _achievementFilter = AchievementFilter.all;
  int _scanCursor = 0;
  int _dailyStreak = 1;
  int _currentXP = 0;
  int _xpToNextLevel = _xpPerLevel;
  int _currentLevel = 1;
  int _quizStep = 0;
  int _bonusXpEarned = 0;
  DateTime? _lastVisit;
  DateTime? _lastDailyQuizClaimAt;
  String? _lastDailyQuizBoostAxis;

  String get userName => 'User';
  List<UserAchievement> get mockAchievements =>
      List.unmodifiable(_mockAchievements);
  List<UserAchievement> get savedAchievements =>
      List.unmodifiable(_savedAchievements);
  AchievementFilter get achievementFilter => _achievementFilter;
  int get dailyStreak => _dailyStreak;
  DateTime? get lastVisit => _lastVisit;
  int get currentXP => _currentXP;
  int get xpToNextLevel => _xpToNextLevel;
  int get currentLevel => _currentLevel;
  int get currentTotalXp => ((_currentLevel - 1) * _xpPerLevel) + _currentXP;
  int get xpNeededForNextLevel =>
      (_xpToNextLevel - _currentXP).clamp(0, _xpToNextLevel);
  int get quizStep => _quizStep;
  List<int> get quizAnswers => List.unmodifiable(_quizAnswers);
  bool get isDailyQuizFinished => _quizStep >= dailyQuizQuestions.length;
  bool get hasActiveDailyQuizSession =>
      _quizStep > 0 && _quizStep < dailyQuizQuestions.length;
  DailyQuizQuestion? get currentDailyQuizQuestion =>
      _quizStep < dailyQuizQuestions.length
      ? dailyQuizQuestions[_quizStep]
      : null;
  bool get canClaimDailyQuizBoost =>
      _lastDailyQuizClaimAt == null ||
      !_isSameDay(_lastDailyQuizClaimAt!, DateTime.now());
  String? get lastDailyQuizBoostAxis => _lastDailyQuizBoostAxis;
  int get dailyQuizXpReward => 30;
  int get overallLiftLevel => _currentLevel;
  double get overallHrValue => _savedAchievements.fold<double>(
    0,
    (sum, achievement) => sum + achievement.aiWeight,
  );

  List<UserAchievement> get sortedAchievements {
    final sorted = List<UserAchievement>.from(_savedAchievements)
      ..sort((a, b) {
        final byWeight = b.aiWeight.compareTo(a.aiWeight);
        if (byWeight != 0) {
          return byWeight;
        }
        return a.title.compareTo(b.title);
      });
    return sorted;
  }

  List<UserAchievement> get filteredAchievements {
    return sortedAchievements
        .where((achievement) => _achievementFilter.matches(achievement))
        .toList();
  }

  double get smartRating {
    final total = _savedAchievements.fold<double>(
      0,
      (sum, achievement) => sum + achievement.aiWeight,
    );
    return double.parse(total.toStringAsFixed(1));
  }

  Map<String, double> get rawAxisTotals {
    return {
      for (final axis in LiftAxes.all)
        axis:
            (_achievementAxisTotals[axis] ?? 0) + (_quizAxisTotals[axis] ?? 0),
    };
  }

  Map<String, double> get bonusRadarScores {
    return {
      for (final axis in LiftAxes.all)
        axis: _normalizeAxisScore(
          raw:
              (_achievementAxisTotals[axis] ?? 0) +
              (_quizAxisTotals[axis] ?? 0),
          max: (defaultAchievementCaps[axis] ?? 12) * 1.7,
          targetScale: 2.8,
        ),
    };
  }

  Map<String, double> composeLiftRadar(Map<String, double> baseScores) {
    final bonus = bonusRadarScores;
    return {
      for (final axis in LiftAxes.all)
        axis: ((baseScores[axis] ?? 0) + (bonus[axis] ?? 0))
            .clamp(0.0, 10.0)
            .toDouble(),
    };
  }

  void registerDailyVisit() {
    _registerVisit(DateTime.now());
  }

  void setAchievementFilter(AchievementFilter filter) {
    if (_achievementFilter == filter) {
      return;
    }
    _achievementFilter = filter;
    notifyListeners();
  }

  void startDailyQuizSession() {
    if (!canClaimDailyQuizBoost) {
      return;
    }
    if (hasActiveDailyQuizSession) {
      notifyListeners();
      return;
    }
    _quizStep = 0;
    _quizAnswers.clear();
    notifyListeners();
  }

  void submitQuizAnswer(int answerIndex) {
    if (answerIndex != 0 && answerIndex != 1) {
      return;
    }
    if (!canClaimDailyQuizBoost && !hasActiveDailyQuizSession) {
      return;
    }
    if (_quizStep >= dailyQuizQuestions.length) {
      return;
    }

    final question = dailyQuizQuestions[_quizStep];
    final boosts = question.boostsFor(answerIndex);

    for (final entry in boosts.entries) {
      _quizAxisTotals[entry.key] =
          (_quizAxisTotals[entry.key] ?? 0) + entry.value;
    }

    _quizAnswers.add(answerIndex);
    _lastDailyQuizBoostAxis = _strongestAxisFromBoosts(boosts);
    _quizStep += 1;

    if (_quizStep >= dailyQuizQuestions.length) {
      _bonusXpEarned += dailyQuizXpReward;
      _lastDailyQuizClaimAt = DateTime.now();
      _recalculateLevelProgress();
    }

    notifyListeners();
  }

  void resetQuizSessionView() {
    if (isDailyQuizFinished || !hasActiveDailyQuizSession) {
      return;
    }
    _quizStep = 0;
    _quizAnswers.clear();
    notifyListeners();
  }

  bool saveAchievementToRegistry(UserAchievement achievement) {
    final alreadyExists = _savedAchievements.any(
      (saved) => saved.id == achievement.id,
    );

    if (alreadyExists) {
      return false;
    }

    _savedAchievements.insert(0, achievement);
    _applyAchievementBoosts(achievement);
    _recalculateLevelProgress();
    notifyListeners();
    return true;
  }

  bool removeAchievementFromRegistry(String achievementId) {
    final index = _savedAchievements.indexWhere(
      (achievement) => achievement.id == achievementId,
    );

    if (index == -1) {
      return false;
    }

    final achievement = _savedAchievements.removeAt(index);
    _revertAchievementBoosts(achievement);
    _recalculateLevelProgress();
    notifyListeners();
    return true;
  }

  Future<UserAchievement> simulateAchievementScan({
    Duration delay = const Duration(milliseconds: 1800),
  }) async {
    await Future<void>.delayed(delay);

    final source = _mockAchievements[_scanCursor % _mockAchievements.length];
    final unique = source.copyWith(id: '${source.id}_${_scanCursor + 1}');

    _scanCursor += 1;
    saveAchievementToRegistry(unique);
    return unique;
  }

  List<UserAchievement> get _seedAchievements =>
      _mockAchievements.take(4).toList();

  void _registerVisit(DateTime now, {bool notify = true}) {
    if (_lastVisit == null) {
      _lastVisit = now;
      _dailyStreak = 1;
      if (notify) {
        notifyListeners();
      }
      return;
    }

    if (_isSameDay(_lastVisit!, now)) {
      return;
    }

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (_isSameDay(_lastVisit!, yesterday)) {
      _dailyStreak += 1;
    } else {
      _dailyStreak = 1;
    }

    _lastVisit = now;
    if (notify) {
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _applyAchievementBoosts(UserAchievement achievement) {
    for (final axis in LiftAxes.all) {
      final bonus = achievement.boostFor(axis);
      if (bonus <= 0) {
        continue;
      }

      _achievementAxisTotals[axis] =
          (_achievementAxisTotals[axis] ?? 0) + bonus;
    }
  }

  void _revertAchievementBoosts(UserAchievement achievement) {
    for (final axis in LiftAxes.all) {
      final bonus = achievement.boostFor(axis);
      if (bonus <= 0) {
        continue;
      }

      _achievementAxisTotals[axis] = math.max(
        0,
        (_achievementAxisTotals[axis] ?? 0) - bonus,
      );
    }
  }

  void _recalculateLevelProgress() {
    final achievementXp = _savedAchievements.fold<int>(
      0,
      (sum, achievement) =>
          sum + (achievement.aiWeight * _achievementXpMultiplier).round(),
    );

    final totalXp = achievementXp + _bonusXpEarned;
    _currentLevel = (totalXp ~/ _xpPerLevel) + 1;
    _currentXP = totalXp % _xpPerLevel;
    _xpToNextLevel = _xpPerLevel;
  }

  String _strongestAxisFromBoosts(Map<String, double> boosts) {
    final sorted = boosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.isEmpty ? LiftAxes.communication : sorted.first.key;
  }

  double _normalizeAxisScore({
    required double raw,
    required double max,
    double targetScale = 10,
  }) {
    if (raw <= 0 || max <= 0) {
      return 0;
    }

    final ratio = (raw / max).clamp(0.0, 1.0).toDouble();
    return double.parse((ratio * targetScale).toStringAsFixed(1));
  }
}
