import 'lift_taxonomy.dart';

class JobOffer {
  const JobOffer({
    required this.id,
    required this.title,
    required this.company,
    required this.matchPercentage,
    required this.requiredSkills,
  });

  final String id;
  final String title;
  final String company;
  final int matchPercentage;
  final List<String> requiredSkills;
}

class AnonymousCandidate {
  const AnonymousCandidate({
    required this.id,
    required this.archetype,
    required this.matchPercentage,
    required this.topSkills,
    required this.isUnlocked,
  });

  final String id;
  final String archetype;
  final int matchPercentage;
  final List<String> topSkills;
  final bool isUnlocked;

  String get displayName => 'Аноним #$id';

  String get contactEmail => 'candidate$id@liftup.ai';

  AnonymousCandidate copyWith({
    String? id,
    String? archetype,
    int? matchPercentage,
    List<String>? topSkills,
    bool? isUnlocked,
  }) {
    return AnonymousCandidate(
      id: id ?? this.id,
      archetype: archetype ?? this.archetype,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      topSkills: topSkills ?? this.topSkills,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class InterviewQuestion {
  const InterviewQuestion({
    required this.questionText,
    required this.optionA,
    required this.optionB,
  });

  final String questionText;
  final String optionA;
  final String optionB;
}

class DailyQuizQuestion {
  const DailyQuizQuestion({
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionAAxisBoosts,
    required this.optionBAxisBoosts,
  });

  final String questionText;
  final String optionA;
  final String optionB;
  final Map<String, double> optionAAxisBoosts;
  final Map<String, double> optionBAxisBoosts;

  Map<String, double> boostsFor(int answerIndex) {
    return answerIndex == 0 ? optionAAxisBoosts : optionBAxisBoosts;
  }
}

const List<JobOffer> mockJobs = [
  JobOffer(
    id: 'job_001',
    title: 'Junior Product Manager',
    company: 'Jasa Future Lab',
    matchPercentage: 84,
    requiredSkills: ['Коммуникация', 'Аналитика', 'Организация', 'Презентации'],
  ),
  JobOffer(
    id: 'job_002',
    title: 'AI Content Intern',
    company: 'Neuron Stories',
    matchPercentage: 76,
    requiredSkills: [
      'Сторителлинг',
      'AI-инструменты',
      'Креативность',
      'Редактура',
    ],
  ),
  JobOffer(
    id: 'job_003',
    title: 'Operations Assistant',
    company: 'Lift Events',
    matchPercentage: 71,
    requiredSkills: [
      'Системность',
      'Дедлайны',
      'Организация',
      'Кризис-менеджмент',
    ],
  ),
  JobOffer(
    id: 'job_004',
    title: 'Media Producer Intern',
    company: 'Campus Wave',
    matchPercentage: 89,
    requiredSkills: ['Съемка', 'Монтаж', 'Сторителлинг', 'Командная работа'],
  ),
];

const List<AnonymousCandidate> mockCandidates = [
  AnonymousCandidate(
    id: '402',
    archetype: 'Лидер-Креатор',
    matchPercentage: 98,
    topSkills: ['Коммуникация', 'Flutter', 'Английский'],
    isUnlocked: false,
  ),
  AnonymousCandidate(
    id: '517',
    archetype: 'Системный Интегратор',
    matchPercentage: 94,
    topSkills: ['Аналитика', 'Python', 'SQL'],
    isUnlocked: false,
  ),
  AnonymousCandidate(
    id: '631',
    archetype: 'Эмпатичный Координатор',
    matchPercentage: 92,
    topSkills: ['Фасилитация', 'Организация', 'Public Speaking'],
    isUnlocked: false,
  ),
  AnonymousCandidate(
    id: '849',
    archetype: 'Операционный Архитектор',
    matchPercentage: 97,
    topSkills: ['Project Ops', 'Excel', 'Кризис-менеджмент'],
    isUnlocked: false,
  ),
];

const List<InterviewQuestion> mockQuestions = [
  InterviewQuestion(
    questionText:
        'Привет! Перед откликом давай проверим смекалку. Мини-кейс: дедлайн горит, а дизайнер пропал. Что делаешь?',
    optionA: 'Соберу базовый макет сам(а), чтобы команда не потеряла темп',
    optionB:
        'Быстро найду замену и пересоберу приоритеты, чтобы спасти дедлайн',
  ),
  InterviewQuestion(
    questionText:
        'Пользователь резко раскритиковал ваш продукт прямо на демо. Как реагируешь?',
    optionA: 'Спокойно уточню детали и переведу критику в список улучшений',
    optionB: 'Сразу покажу альтернативный сценарий и защищу решение данными',
  ),
  InterviewQuestion(
    questionText:
        'Два участника команды спорят, и из-за этого стопорится запуск. Твое действие?',
    optionA: 'Проведу быструю фасилитацию и соберу общее решение за 15 минут',
    optionB:
        'Разделю спор на факты и риски, а потом приму ответственное решение',
  ),
];

const List<DailyQuizQuestion> dailyQuizQuestions = [
  DailyQuizQuestion(
    questionText:
        'Ситуация: дедлайн завтра, но критический баг все еще не исправлен. Что выберешь?',
    optionA: 'Запустить как есть и фиксить на ходу, чтобы не сорвать релиз',
    optionB:
        'Честно сказать команде о рисках и попросить перенос с объяснением',
    optionAAxisBoosts: {LiftAxes.technical: 1.0, LiftAxes.organization: 0.7},
    optionBAxisBoosts: {LiftAxes.communication: 0.9, LiftAxes.logic: 1.0},
  ),
  DailyQuizQuestion(
    questionText:
        'Во время школьного проекта два участника спорят, и команда теряет темп. Как действуешь?',
    optionA: 'Проведу быструю фасилитацию и верну фокус команды на общую цель',
    optionB:
        'Разложу конфликт по фактам и соберу четкий план действий по шагам',
    optionAAxisBoosts: {
      LiftAxes.communication: 1.1,
      LiftAxes.organization: 0.6,
    },
    optionBAxisBoosts: {LiftAxes.logic: 1.0, LiftAxes.organization: 0.8},
  ),
  DailyQuizQuestion(
    questionText:
        'Тебе нужно защитить идею перед партнером. Что подготовишь в первую очередь?',
    optionA:
        'Эмоциональный сторителлинг и сильную подачу, чтобы заразить идеей',
    optionB: 'Цифры, аргументы и риски, чтобы убедить через логику и факты',
    optionAAxisBoosts: {LiftAxes.creativity: 1.0, LiftAxes.communication: 0.9},
    optionBAxisBoosts: {LiftAxes.logic: 1.1, LiftAxes.technical: 0.6},
  ),
];
