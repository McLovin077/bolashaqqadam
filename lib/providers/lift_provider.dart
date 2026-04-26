import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/analytics_profile_model.dart';
import '../models/certificate_model.dart';
import '../models/job_match_result_model.dart';
import '../models/job_model.dart';
import '../models/lift_taxonomy.dart';
import '../models/question_model.dart';

class LiftProvider extends ChangeNotifier {
  LiftProvider() {
    _certificates.addAll(_seedCertificates);
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
    const QuestionModel(
      id: 'q11',
      questionText:
          'В новой команде ты скорее быстро познакомишь всех между собой или сразу разложишь роли и дедлайны?',
      optionA_Text: 'Быстро познакомлю и соберу общий вайб',
      optionB_Text: 'Сразу разложу роли и дедлайны',
      tagA: 'Лидерство',
      tagB: 'Организация',
      axisScoresA: {LiftAxes.communication: 1.0, LiftAxes.organization: 0.5},
      axisScoresB: {LiftAxes.organization: 1.1, LiftAxes.logic: 0.5},
    ),
    const QuestionModel(
      id: 'q12',
      questionText:
          'Что тебе ближе: придумать механику вирусного челленджа или построить таблицу, которая покажет, где теряется аудитория?',
      optionA_Text: 'Придумать вирусный челлендж',
      optionB_Text: 'Построить таблицу и найти узкое место',
      tagA: 'Креативность',
      tagB: 'Аналитика',
      axisScoresA: {LiftAxes.creativity: 1.1, LiftAxes.communication: 0.5},
      axisScoresB: {LiftAxes.logic: 1.0, LiftAxes.technical: 0.6},
    ),
    const QuestionModel(
      id: 'q13',
      questionText:
          'Если младший участник застрял, ты скорее объяснишь ему шаг за шагом или напишешь маленький инструмент для ускорения работы?',
      optionA_Text: 'Объясню шаг за шагом',
      optionB_Text: 'Соберу инструмент для ускорения',
      tagA: 'Наставничество',
      tagB: 'Автоматизация',
      axisScoresA: {LiftAxes.communication: 0.9, LiftAxes.organization: 0.4},
      axisScoresB: {LiftAxes.technical: 1.2, LiftAxes.logic: 0.6},
    ),
    const QuestionModel(
      id: 'q14',
      questionText:
          'Что тебе интереснее: договориться с партнером о поддержке проекта или выстроить pipeline, чтобы команда выпускала контент без хаоса?',
      optionA_Text: 'Договориться с партнером',
      optionB_Text: 'Выстроить pipeline для команды',
      tagA: 'Коммуникация',
      tagB: 'Системность',
      axisScoresA: {LiftAxes.communication: 1.0, LiftAxes.creativity: 0.4},
      axisScoresB: {LiftAxes.organization: 1.0, LiftAxes.technical: 0.5},
    ),
    const QuestionModel(
      id: 'q15',
      questionText:
          'Что для тебя сильнее драйвит: ночью собрать рабочий MVP или определить 3 метрики, которые докажут жизнеспособность идеи?',
      optionA_Text: 'Собрать рабочий MVP',
      optionB_Text: 'Определить ключевые метрики успеха',
      tagA: 'Прототипирование',
      tagB: 'Стратегия',
      axisScoresA: {LiftAxes.technical: 1.1, LiftAxes.logic: 0.5},
      axisScoresB: {LiftAxes.logic: 1.0, LiftAxes.organization: 0.7},
    ),
    const QuestionModel(
      id: 'q16',
      questionText:
          'Перед большим ивентом ты скорее придумаешь яркое открытие или возьмешь на себя координационный штаб и контроль тайминга?',
      optionA_Text: 'Придумаю яркое открытие',
      optionB_Text: 'Возьму координацию и тайминг',
      tagA: 'Сторителлинг',
      tagB: 'Организация',
      axisScoresA: {LiftAxes.creativity: 1.0, LiftAxes.communication: 0.6},
      axisScoresB: {LiftAxes.organization: 1.1, LiftAxes.communication: 0.5},
    ),
    const QuestionModel(
      id: 'q17',
      questionText:
          'Во время спора в команде ты скорее поможешь всем услышать друг друга или разобьешь проблему на логические блоки и приоритеты?',
      optionA_Text: 'Помогу всем услышать друг друга',
      optionB_Text: 'Разобью проблему на блоки и приоритеты',
      tagA: 'Медиатор',
      tagB: 'Логика',
      axisScoresA: {LiftAxes.communication: 1.0, LiftAxes.organization: 0.5},
      axisScoresB: {LiftAxes.logic: 1.1, LiftAxes.organization: 0.5},
    ),
    const QuestionModel(
      id: 'q18',
      questionText:
          'Что тебе ближе в долгом проекте: развивать сообщество вокруг идеи или строить систему, которая масштабируется без ручного контроля?',
      optionA_Text: 'Развивать сообщество вокруг идеи',
      optionB_Text: 'Строить масштабируемую систему',
      tagA: 'Лидерство',
      tagB: 'Системность',
      axisScoresA: {LiftAxes.communication: 0.9, LiftAxes.creativity: 0.5},
      axisScoresB: {LiftAxes.technical: 0.9, LiftAxes.logic: 0.8},
    ),
    const QuestionModel(
      id: 'q19',
      questionText:
          'Если нужно запустить школьную инициативу за неделю, ты скорее сделаешь сильную презентацию для участников или соберешь операционный план по ролям?',
      optionA_Text: 'Сделаю сильную презентацию и подачу',
      optionB_Text: 'Соберу операционный план по ролям',
      tagA: 'Сторителлинг',
      tagB: 'Дисциплина',
      axisScoresA: {LiftAxes.creativity: 0.9, LiftAxes.communication: 0.7},
      axisScoresB: {LiftAxes.organization: 1.0, LiftAxes.logic: 0.6},
    ),
    const QuestionModel(
      id: 'q20',
      questionText:
          'Что заряжает сильнее: находить неожиданные концепции для кампании или доводить сложный функционал до стабильного релиза?',
      optionA_Text: 'Находить неожиданные концепции',
      optionB_Text: 'Доводить функционал до стабильного релиза',
      tagA: 'Креативность',
      tagB: 'Техничность',
      axisScoresA: {LiftAxes.creativity: 1.1, LiftAxes.communication: 0.4},
      axisScoresB: {LiftAxes.technical: 1.1, LiftAxes.organization: 0.5},
    ),
  ];

  final List<CertificateModel> _seedCertificates = const [
    CertificateModel(
      id: 'cert_1',
      title: 'Республиканская олимпиада по математике',
      type: 'Олимпиада',
      hrWeight: 10,
      issuer: 'Минобразования',
    ),
    CertificateModel(
      id: 'cert_2',
      title: 'Городской курс по Python-разработке',
      type: 'Курс',
      hrWeight: 8,
      issuer: 'Tech Hub',
    ),
    CertificateModel(
      id: 'cert_3',
      title: 'Национальный STEM-хакатон',
      type: 'Олимпиада',
      hrWeight: 7,
      issuer: 'STEM Alliance',
    ),
    CertificateModel(
      id: 'cert_4',
      title: 'Карьерный вебинар от индустриального партнера',
      type: 'Вебинар',
      hrWeight: 4,
      issuer: 'Career Lab',
    ),
    CertificateModel(
      id: 'cert_5',
      title: 'Школьный вебинар по soft skills',
      type: 'Вебинар',
      hrWeight: 1,
      issuer: 'School Club',
    ),
  ];

  final List<CertificateModel> _scannerPool = const [
    CertificateModel(
      id: 'scan_1',
      title: 'TEDx Youth Volunteer Certificate',
      type: 'Волонтерство',
      hrWeight: 9,
      issuer: 'TEDx',
      isScanned: true,
    ),
    CertificateModel(
      id: 'scan_2',
      title: 'Eco Festival Operations Team',
      type: 'Проект',
      hrWeight: 8,
      issuer: 'Green Future',
      isScanned: true,
    ),
    CertificateModel(
      id: 'scan_3',
      title: 'Junior AI Bootcamp Completion',
      type: 'Курс',
      hrWeight: 9,
      issuer: 'Lift Academy',
      isScanned: true,
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

  final Map<String, int> _userTags = {};
  final Map<String, double> _axisTotals = {
    for (final axis in LiftAxes.all) axis: 0,
  };
  final List<CertificateModel> _certificates = [];
  final List<QuestionChoice> _answerHistory = [];
  final Set<String> _appliedJobIds = {};

  int _currentQuestionIndex = 0;
  int _assessmentSessionId = 0;
  int _scanCounter = 0;
  bool _isAnalyzing = false;
  bool _analysisReady = false;
  bool _portfolioSaved = false;

  List<QuestionModel> get questions => List.unmodifiable(_questions);
  List<JobModel> get jobs => List.unmodifiable(_jobs);
  List<CertificateModel> get certificates => List.unmodifiable(_certificates);
  Map<String, int> get userTags => Map.unmodifiable(_userTags);
  Map<String, double> get rawAxisTotals => Map.unmodifiable(_axisTotals);
  List<QuestionChoice> get answerHistory => List.unmodifiable(_answerHistory);
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

  List<CertificateModel> get sortedCertificates {
    final sorted = List<CertificateModel>.from(_certificates);
    sorted.sort((a, b) => b.hrWeight.compareTo(a.hrWeight));
    return sorted;
  }

  Map<String, double> get radarScores {
    if (_answerHistory.isEmpty) {
      return {for (final axis in LiftAxes.all) axis: 0};
    }

    final maxTotals = _maxAxisTotals;

    return {
      for (final axis in LiftAxes.all)
        axis: _normalizeAxisScore(
          raw: _axisTotals[axis] ?? 0,
          max: maxTotals[axis] ?? 1,
        ),
    };
  }

  List<String> get dominantTags {
    final sortedEntries = _userTags.entries.toList()
      ..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        if (byScore != 0) {
          return byScore;
        }

        return a.key.compareTo(b.key);
      });

    return sortedEntries.take(4).map((entry) => entry.key).toList();
  }

  List<MapEntry<String, double>> get dominantAxes {
    final entries = radarScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String get archetype {
    if (_answerHistory.isEmpty) {
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
        return 'У тебя ярко выражен инженерный склад ума. Ты силен в сложных системах, любишь точность и умеешь превращать хаос в работающие механики.';
      case LiftArchetypes.creativeVisionary:
        return 'Ты умеешь соединять идею, эмоцию и подачу. Твоя суперсила — создавать концепции, которые люди запоминают и хотят поддержать.';
      case LiftArchetypes.empatheticLeader:
        return 'Ты естественно чувствуешь людей и умеешь вести их за собой. У тебя высокий потенциал к лидерству, фасилитации и работе с сообществами.';
      case LiftArchetypes.strategicArchitect:
        return 'Ты хорошо видишь риски, строишь логику и принимаешь взрослые решения. В тебе сочетаются системность, приоритизация и управленческое мышление.';
      case LiftArchetypes.operationalEngineer:
        return 'Ты силен там, где нужно не просто придумать, а собрать, отладить и довести до результата. Твоя ценность — в надежности и скорости исполнения.';
      case LiftArchetypes.adaptiveHybrid:
        return 'У тебя гибкий профиль с потенциалом к междисциплинарным ролям. Ты быстро адаптируешься и можешь усиливать команду сразу в нескольких направлениях.';
    }

    return 'Твой профиль пока формируется, но уже видно сильное сочетание адаптивности, любознательности и потенциала к росту.';
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

  void answerCurrentQuestion(QuestionChoice choice) {
    if (_isAnalyzing || currentQuestion == null) {
      return;
    }

    final question = currentQuestion!;
    final tag = question.tagFor(choice);

    _userTags[tag] = (_userTags[tag] ?? 0) + 1;

    final axisScores = question.axisScoresFor(choice);
    for (final entry in axisScores.entries) {
      _axisTotals[entry.key] = (_axisTotals[entry.key] ?? 0) + entry.value;
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

  Future<CertificateModel> simulateScannerDiscovery({
    Duration delay = const Duration(seconds: 2),
  }) async {
    await Future<void>.delayed(delay);

    final certificate = _scannerPool[_scanCounter % _scannerPool.length];
    final uniqueCertificate = CertificateModel(
      id: '${certificate.id}_${_scanCounter + 1}',
      title: certificate.title,
      type: certificate.type,
      hrWeight: certificate.hrWeight,
      issuer: certificate.issuer,
      isScanned: true,
    );

    _scanCounter++;
    _certificates.insert(0, uniqueCertificate);
    notifyListeners();
    return uniqueCertificate;
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
      _axisTotals[axis] = 0;
    }

    notifyListeners();
  }

  JobMatchResultModel calculateMatchFor(JobModel job) {
    if (_answerHistory.isEmpty) {
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

  Map<String, double> get _maxAxisTotals {
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
    final maxTotals = _maxAxisTotals;

    return {
      for (final axis in LiftAxes.all)
        axis: _safeRatio(
          numerator: _axisTotals[axis] ?? 0,
          denominator: maxTotals[axis] ?? 1,
        ),
    };
  }

  Set<String> get _strengthTokens {
    final tokens = <String>{..._userTags.keys};
    final axisRatios = _axisRatios;

    if ((axisRatios[LiftAxes.communication] ?? 0) >= 0.55) {
      tokens.addAll(['Коммуникация', 'Лидерство', 'Эмпатия', 'Сторителлинг']);
    }

    if ((axisRatios[LiftAxes.logic] ?? 0) >= 0.55) {
      tokens.addAll(['Логика', 'Аналитика', 'Стратегия', 'Системность']);
    }

    if ((axisRatios[LiftAxes.creativity] ?? 0) >= 0.55) {
      tokens.addAll(['Креативность', 'Сторителлинг', 'UX-мышление']);
    }

    if ((axisRatios[LiftAxes.organization] ?? 0) >= 0.55) {
      tokens.addAll(['Организация', 'Дисциплина', 'Системность']);
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
}
