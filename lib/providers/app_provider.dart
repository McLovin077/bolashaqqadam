import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _savedAchievements.addAll(_seedAchievements);
    for (final achievement in _savedAchievements) {
      _applyAchievementBoosts(achievement);
    }
  }

  final List<QuestionModel> _questions = [
    const QuestionModel(
      id: 'q1',
      questionText:
          'Что ты выберешь: защищать проект перед 100 людьми или написать идеальный код в тишине?',
      optionA_Text: 'Защищать проект перед 100 людьми',
      optionB_Text: 'Написать идеальный код в тишине',
      tagA: 'Коммуникация',
      tagB: 'Техничность',
      axisScoresA: {LiftAxes.communication: 1.2, LiftAxes.creativity: 0.4},
      axisScoresB: {LiftAxes.technical: 1.2, LiftAxes.logic: 0.6},
    ),
    const QuestionModel(
      id: 'q2',
      questionText:
          'Что тебе ближе: собрать команду и провести школьный фестиваль или выстроить идеальный чек-лист и тайминг для закулисья?',
      optionA_Text: 'Собрать команду и провести фестиваль',
      optionB_Text: 'Выстроить идеальный чек-лист и тайминг',
      tagA: 'Лидерство',
      tagB: 'Организация',
      axisScoresA: {LiftAxes.communication: 0.9, LiftAxes.organization: 0.7},
      axisScoresB: {LiftAxes.organization: 1.2, LiftAxes.logic: 0.5},
    ),
    const QuestionModel(
      id: 'q3',
      questionText:
          'Что интереснее: придумать смелую идею кампании или разложить по полочкам, почему прошлый запуск не сработал?',
      optionA_Text: 'Придумать смелую идею кампании',
      optionB_Text: 'Разобрать причины неудачи прошлого запуска',
      tagA: 'Креативность',
      tagB: 'Аналитика',
      axisScoresA: {LiftAxes.creativity: 1.2, LiftAxes.communication: 0.3},
      axisScoresB: {LiftAxes.logic: 1.1, LiftAxes.organization: 0.4},
    ),
    const QuestionModel(
      id: 'q4',
      questionText:
          'Что ты сделаешь раньше: успокоишь команду и вернешь всех в рабочий ритм или сам(а) за ночь соберешь прототип?',
      optionA_Text: 'Соберу команду и верну всех в рабочий ритм',
      optionB_Text: 'Сам(а) за ночь соберу прототип',
      tagA: 'Эмпатия',
      tagB: 'Прототипирование',
      axisScoresA: {LiftAxes.communication: 0.9, LiftAxes.organization: 0.6},
      axisScoresB: {LiftAxes.technical: 1.1, LiftAxes.logic: 0.7},
    ),
    const QuestionModel(
      id: 'q5',
      questionText:
          'Что тебе ближе: вести волонтеров на эко-фестивале или выстроить логистику так, чтобы событие прошло без сбоев?',
      optionA_Text: 'Вести волонтеров и быть лицом события',
      optionB_Text: 'Настроить логистику и процессы',
      tagA: 'Лидерство',
      tagB: 'Системность',
      axisScoresA: {LiftAxes.communication: 0.8, LiftAxes.organization: 0.8},
      axisScoresB: {LiftAxes.organization: 0.9, LiftAxes.logic: 0.8},
    ),
    const QuestionModel(
      id: 'q6',
      questionText:
          'Что ты выберешь: снять вдохновляющий промо-ролик или собрать дашборд, который покажет реальный эффект проекта?',
      optionA_Text: 'Снять вдохновляющий промо-ролик',
      optionB_Text: 'Собрать дашборд с метриками',
      tagA: 'Сторителлинг',
      tagB: 'Аналитика',
      axisScoresA: {LiftAxes.creativity: 1.1, LiftAxes.communication: 0.6},
      axisScoresB: {LiftAxes.logic: 1.0, LiftAxes.technical: 0.7},
    ),
    const QuestionModel(
      id: 'q7',
      questionText:
          'Что тебе комфортнее: продавать идею партнеру вживую или заранее просчитать риски и сценарии запуска?',
      optionA_Text: 'Продавать идею партнеру вживую',
      optionB_Text: 'Просчитать риски и сценарии запуска',
      tagA: 'Коммуникация',
      tagB: 'Стратегия',
      axisScoresA: {LiftAxes.communication: 1.1, LiftAxes.creativity: 0.4},
      axisScoresB: {LiftAxes.logic: 0.9, LiftAxes.organization: 0.7},
    ),
    const QuestionModel(
      id: 'q8',
      questionText:
          'Что больше твое: объяснить младшим сложную тему простым языком или автоматизировать скучный повторяющийся процесс?',
      optionA_Text: 'Объяснить и научить',
      optionB_Text: 'Автоматизировать процесс',
      tagA: 'Наставничество',
      tagB: 'Автоматизация',
      axisScoresA: {LiftAxes.communication: 0.8, LiftAxes.organization: 0.4},
      axisScoresB: {LiftAxes.technical: 1.2, LiftAxes.logic: 0.6},
    ),
    const QuestionModel(
      id: 'q9',
      questionText:
          'Что тебе ближе: придумать пользовательский путь в приложении или настроить систему так, чтобы она выдержала рост в 10 раз?',
      optionA_Text: 'Придумать пользовательский путь',
      optionB_Text: 'Настроить систему под масштабирование',
      tagA: 'UX-мышление',
      tagB: 'Системность',
      axisScoresA: {LiftAxes.creativity: 0.9, LiftAxes.communication: 0.4},
      axisScoresB: {LiftAxes.technical: 0.9, LiftAxes.logic: 0.9},
    ),
    const QuestionModel(
      id: 'q10',
      questionText:
          'Что ты выберешь в дедлайн: модерировать спор двух команд или остаться допоздна и довести финальный релиз до идеала?',
      optionA_Text: 'Модерировать спор и собрать всех в единое решение',
      optionB_Text: 'Довести финальный релиз до идеала',
      tagA: 'Медиатор',
      tagB: 'Дисциплина',
      axisScoresA: {LiftAxes.communication: 1.0, LiftAxes.organization: 0.7},
      axisScoresB: {LiftAxes.organization: 0.8, LiftAxes.technical: 0.8},
    ),
  ];

  final List<JobModel> _jobs = const [
    JobModel(
      id: 'job_1',
      companyName: 'Green Future',
      title: 'Координатор эко-фестиваля',
      tagsNeeded: ['Организация', 'Коммуникация', 'Лидерство'],
      isJasaVerified: true,
      preferredArchetypes: [
        LiftArchetypes.empatheticLeader,
        LiftArchetypes.strategicArchitect,
      ],
      axisAffinity: {LiftAxes.organization: 1.0, LiftAxes.communication: 0.9},
    ),
    JobModel(
      id: 'job_2',
      companyName: 'Animal Shelter Media',
      title: 'СММ для приюта животных',
      tagsNeeded: ['Креативность', 'Коммуникация', 'Эмпатия'],
      isJasaVerified: true,
      preferredArchetypes: [
        LiftArchetypes.creativeVisionary,
        LiftArchetypes.empatheticLeader,
      ],
      axisAffinity: {LiftAxes.creativity: 1.0, LiftAxes.communication: 0.8},
    ),
    JobModel(
      id: 'job_3',
      companyName: 'TEDx Almaty Youth',
      title: 'Ассистент на TEDx',
      tagsNeeded: ['Коммуникация', 'Организация', 'Сторителлинг'],
      isJasaVerified: true,
      preferredArchetypes: [
        LiftArchetypes.empatheticLeader,
        LiftArchetypes.creativeVisionary,
      ],
      axisAffinity: {
        LiftAxes.communication: 1.0,
        LiftAxes.organization: 0.8,
        LiftAxes.creativity: 0.6,
      },
    ),
    JobModel(
      id: 'job_4',
      companyName: 'Insight Lab',
      title: 'Junior Data Analyst',
      tagsNeeded: ['Логика', 'Аналитика', 'Техничность'],
      isJasaVerified: true,
      preferredArchetypes: [
        LiftArchetypes.systemsIntegrator,
        LiftArchetypes.strategicArchitect,
      ],
      axisAffinity: {
        LiftAxes.logic: 1.0,
        LiftAxes.technical: 0.9,
        LiftAxes.organization: 0.4,
      },
    ),
  ];

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
          'Координация гостей, работа с гостевым потоком и поддержка event-команды.',
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
  final Map<String, int> _userTags = {};
  final Map<String, double> _swipeAxisTotals = {
    for (final axis in LiftAxes.all) axis: 0,
  };
  final Map<String, double> _achievementAxisTotals = {
    for (final axis in LiftAxes.all) axis: 0,
  };
  final List<QuestionChoice> _answerHistory = [];
  final Set<String> _appliedJobIds = {};

  AchievementFilter _achievementFilter = AchievementFilter.all;
  int _currentQuestionIndex = 0;
  int _assessmentSessionId = 0;
  int _scanCursor = 0;
  bool _isAnalyzing = false;
  bool _analysisReady = false;
  bool _portfolioSaved = false;

  List<QuestionModel> get questions => List.unmodifiable(_questions);
  List<JobModel> get jobs => List.unmodifiable(_jobs);
  List<UserAchievement> get mockAchievements =>
      List.unmodifiable(_mockAchievements);
  List<UserAchievement> get savedAchievements =>
      List.unmodifiable(_savedAchievements);
  Map<String, int> get userTags => Map.unmodifiable(_userTags);
  List<QuestionChoice> get answerHistory => List.unmodifiable(_answerHistory);
  AchievementFilter get achievementFilter => _achievementFilter;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get assessmentSessionId => _assessmentSessionId;
  int get totalQuestions => _questions.length;
  bool get isAnalyzing => _isAnalyzing;
  bool get hasAnalysisResult => _analysisReady;
  bool get isPortfolioSaved => _portfolioSaved;

  double get progress {
    if (_questions.isEmpty) {
      return 0;
    }

    return (_currentQuestionIndex / _questions.length).clamp(0.0, 1.0);
  }

  bool get isAssessmentCompleted => _currentQuestionIndex >= _questions.length;

  QuestionModel? get currentQuestion {
    if (isAssessmentCompleted) {
      return null;
    }

    return _questions[_currentQuestionIndex];
  }

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
            (_swipeAxisTotals[axis] ?? 0) + (_achievementAxisTotals[axis] ?? 0),
    };
  }

  Map<String, double> get radarScores {
    final swipeCaps = _maxSwipeAxisTotals;

    return {
      for (final axis in LiftAxes.all)
        axis: _normalizeAxisScore(
          raw:
              (_swipeAxisTotals[axis] ?? 0) +
              (_achievementAxisTotals[axis] ?? 0),
          max: (swipeCaps[axis] ?? 1) + (defaultAchievementCaps[axis] ?? 10),
        ),
    };
  }

  List<String> get dominantTags {
    final combined = <String, double>{
      for (final entry in _userTags.entries) entry.key: entry.value.toDouble(),
    };

    for (final achievement in _savedAchievements) {
      for (final tag in achievement.tags) {
        combined[tag] = (combined[tag] ?? 0) + achievement.aiWeight;
      }
    }

    final sorted = combined.entries.toList()
      ..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        if (byScore != 0) {
          return byScore;
        }

        return a.key.compareTo(b.key);
      });

    return sorted.take(4).map((entry) => entry.key).toList();
  }

  List<MapEntry<String, double>> get dominantAxes {
    final entries = radarScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String get archetype {
    if (_answerHistory.isEmpty && _savedAchievements.isEmpty) {
      return LiftArchetypes.adaptiveHybrid;
    }

    final topAxes = dominantAxes.take(2).map((entry) => entry.key).toSet();

    if (topAxes.contains(LiftAxes.logic) &&
        topAxes.contains(LiftAxes.technical)) {
      return LiftArchetypes.systemsIntegrator;
    }

    if (topAxes.contains(LiftAxes.creativity) &&
        topAxes.contains(LiftAxes.communication)) {
      return LiftArchetypes.creativeVisionary;
    }

    if (topAxes.contains(LiftAxes.communication) &&
        topAxes.contains(LiftAxes.organization)) {
      return LiftArchetypes.empatheticLeader;
    }

    if (topAxes.contains(LiftAxes.logic) &&
        topAxes.contains(LiftAxes.organization)) {
      return LiftArchetypes.strategicArchitect;
    }

    if (topAxes.contains(LiftAxes.technical) &&
        topAxes.contains(LiftAxes.organization)) {
      return LiftArchetypes.operationalEngineer;
    }

    return LiftArchetypes.adaptiveHybrid;
  }

  String get aiVerdict {
    switch (archetype) {
      case LiftArchetypes.systemsIntegrator:
        return 'У тебя ярко выражен инженерный склад ума. Ты любишь точность, быстро собираешь систему и усиливаешь профиль аналитическими достижениями.';
      case LiftArchetypes.creativeVisionary:
        return 'Ты умеешь соединять идею, смысл и подачу. Проекты и инициативы добавляют тебе сильный сигнал на роли в медиа, продукте и коммуникациях.';
      case LiftArchetypes.empatheticLeader:
        return 'Ты естественно работаешь с людьми и умеешь вести за собой. Волонтерство и проектная активность усиливают твой профиль как лидера сообщества.';
      case LiftArchetypes.strategicArchitect:
        return 'Ты хорошо видишь риски, строишь логику и принимаешь зрелые решения. Такой профиль силен в управлении, аналитике и координации команд.';
      case LiftArchetypes.operationalEngineer:
        return 'Ты силен там, где нужно не просто придумать, а довести до результата. В тебе сочетаются дисциплина, процессное мышление и технический драйв.';
      case LiftArchetypes.adaptiveHybrid:
        return 'У тебя гибкий, междисциплинарный профиль. Сочетание учебных, волонтерских и проектных сигналов делает тебя универсальным кандидатом для первых стажировок.';
    }

    return 'Твой профиль пока формируется, но уже видно сильное сочетание адаптивности и потенциала к росту.';
  }

  AnalyticsProfileModel get analyticsProfile {
    return AnalyticsProfileModel(
      archetype: archetype,
      aiVerdict: aiVerdict,
      dominantTags: dominantTags,
      radarScores: radarScores,
    );
  }

  Map<String, JobMatchResultModel> get jobMatches {
    return {for (final job in _jobs) job.id: calculateMatchFor(job)};
  }

  bool isJobApplied(String jobId) {
    return _appliedJobIds.contains(jobId);
  }

  void setAchievementFilter(AchievementFilter filter) {
    if (_achievementFilter == filter) {
      return;
    }

    _achievementFilter = filter;
    notifyListeners();
  }

  void answerCurrentQuestion(QuestionChoice choice) {
    if (_isAnalyzing || currentQuestion == null) {
      return;
    }

    final question = currentQuestion!;
    final tag = question.tagFor(choice);

    _userTags[tag] = (_userTags[tag] ?? 0) + 1;

    final axisScores = question.axisScoresFor(choice);
    for (final entry in axisScores.entries) {
      _swipeAxisTotals[entry.key] =
          (_swipeAxisTotals[entry.key] ?? 0) + entry.value;
    }

    _answerHistory.add(choice);
    _currentQuestionIndex++;
    _analysisReady = false;
    notifyListeners();
  }

  Future<void> runLiftAnalysis({
    Duration delay = const Duration(milliseconds: 2600),
  }) async {
    if (!isAssessmentCompleted || _isAnalyzing) {
      return;
    }

    _isAnalyzing = true;
    notifyListeners();

    await Future<void>.delayed(delay);

    _isAnalyzing = false;
    _analysisReady = true;
    notifyListeners();
  }

  void savePortfolio() {
    if (_portfolioSaved) {
      return;
    }

    _portfolioSaved = true;
    notifyListeners();
  }

  void applyToJob(String jobId) {
    if (_appliedJobIds.contains(jobId)) {
      return;
    }

    _appliedJobIds.add(jobId);
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
    notifyListeners();
    return true;
  }

  Future<UserAchievement> simulateAchievementScan({
    Duration delay = const Duration(milliseconds: 1800),
  }) async {
    await Future<void>.delayed(delay);

    final source = _mockAchievements[_scanCursor % _mockAchievements.length];
    final unique = source.copyWith(id: '${source.id}_${_scanCursor + 1}');

    _scanCursor++;
    saveAchievementToRegistry(unique);
    return unique;
  }

  void resetAssessment() {
    _userTags.clear();
    _answerHistory.clear();
    _currentQuestionIndex = 0;
    _assessmentSessionId++;
    _isAnalyzing = false;
    _analysisReady = false;
    _portfolioSaved = false;

    for (final axis in LiftAxes.all) {
      _swipeAxisTotals[axis] = 0;
    }

    notifyListeners();
  }

  JobMatchResultModel calculateMatchFor(JobModel job) {
    if (_answerHistory.isEmpty && _savedAchievements.isEmpty) {
      return const JobMatchResultModel(
        percentage: 50,
        matchedTags: [],
        isPerfectFit: false,
        isArchetypeAligned: false,
      );
    }

    final strengthTokens = _strengthTokens;
    final matchedTags = job.tagsNeeded
        .where((tag) => strengthTokens.contains(tag))
        .toList();

    final tagCoverage = job.tagsNeeded.isEmpty
        ? 0
        : matchedTags.length / job.tagsNeeded.length;

    double axisWeightedScore = 0;
    double axisWeightTotal = 0;
    final axisRatios = _axisRatios;

    for (final entry in job.axisAffinity.entries) {
      axisWeightedScore += (axisRatios[entry.key] ?? 0) * entry.value;
      axisWeightTotal += entry.value;
    }

    final axisScore = axisWeightTotal == 0
        ? 0.5
        : axisWeightedScore / axisWeightTotal;

    final archetypeAligned = job.preferredArchetypes.contains(archetype);
    final archetypeScore = archetypeAligned
        ? 1.0
        : _softArchetypeAlignment(job);

    final rawScore =
        (tagCoverage * 0.55) + (axisScore * 0.30) + (archetypeScore * 0.15);

    final percentage = (rawScore * 100).round().clamp(52, 99);

    return JobMatchResultModel(
      percentage: percentage,
      matchedTags: matchedTags,
      isPerfectFit: percentage >= 90,
      isArchetypeAligned: archetypeAligned,
    );
  }

  List<UserAchievement> get _seedAchievements =>
      _mockAchievements.take(4).toList();

  Map<String, double> get _maxSwipeAxisTotals {
    final totals = {for (final axis in LiftAxes.all) axis: 0.0};

    for (final question in _questions) {
      for (final axis in LiftAxes.all) {
        final optionA = question.axisScoresA[axis] ?? 0;
        final optionB = question.axisScoresB[axis] ?? 0;
        totals[axis] = totals[axis]! + math.max(optionA, optionB);
      }
    }

    return totals;
  }

  Map<String, double> get _axisRatios {
    final swipeCaps = _maxSwipeAxisTotals;

    return {
      for (final axis in LiftAxes.all)
        axis: _safeRatio(
          numerator:
              (_swipeAxisTotals[axis] ?? 0) +
              (_achievementAxisTotals[axis] ?? 0),
          denominator:
              (swipeCaps[axis] ?? 1) + (defaultAchievementCaps[axis] ?? 10),
        ),
    };
  }

  Set<String> get _strengthTokens {
    final tokens = <String>{...dominantTags};
    final axisRatios = _axisRatios;

    if ((axisRatios[LiftAxes.communication] ?? 0) >= 0.55) {
      tokens.addAll(['Коммуникация', 'Лидерство', 'Эмпатия', 'Сторителлинг']);
    }

    if ((axisRatios[LiftAxes.logic] ?? 0) >= 0.55) {
      tokens.addAll(['Логика', 'Аналитика', 'Стратегия', 'Системность']);
    }

    if ((axisRatios[LiftAxes.creativity] ?? 0) >= 0.55) {
      tokens.addAll(['Креативность', 'Сторителлинг', 'UX-мышление', 'SMM']);
    }

    if ((axisRatios[LiftAxes.organization] ?? 0) >= 0.55) {
      tokens.addAll([
        'Организация',
        'Дисциплина',
        'Системность',
        'Координация',
      ]);
    }

    if ((axisRatios[LiftAxes.technical] ?? 0) >= 0.55) {
      tokens.addAll([
        'Техничность',
        'Автоматизация',
        'Прототипирование',
        'Python',
      ]);
    }

    return tokens;
  }

  double _softArchetypeAlignment(JobModel job) {
    if (job.axisAffinity.isEmpty) {
      return 0.45;
    }

    final topAxes = dominantAxes.take(2).map((entry) => entry.key).toSet();
    final targetAxes = job.axisAffinity.entries
        .where((entry) => entry.value >= 0.8)
        .map((entry) => entry.key)
        .toSet();

    if (targetAxes.isEmpty) {
      return 0.45;
    }

    final overlap = topAxes.intersection(targetAxes).length;
    return (overlap / targetAxes.length).clamp(0.25, 0.8).toDouble();
  }

  double _normalizeAxisScore({required double raw, required double max}) {
    if (raw <= 0 || max <= 0) {
      return 0;
    }

    final ratio = _safeRatio(numerator: raw, denominator: max);
    return double.parse((ratio * 10).toStringAsFixed(1));
  }

  double _safeRatio({required double numerator, required double denominator}) {
    if (denominator == 0) {
      return 0;
    }

    return (numerator / denominator).clamp(0.0, 1.0).toDouble();
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
}
