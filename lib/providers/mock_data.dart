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

  String get displayName => 'Анонимный Кандидат #$id';

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

class InterviewOption {
  const InterviewOption({
    required this.id,
    required this.label,
    required this.skillSignal,
    required this.coverLetterSnippet,
  });

  final String id;
  final String label;
  final String skillSignal;
  final String coverLetterSnippet;
}

class InterviewScenario {
  const InterviewScenario({
    required this.id,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String prompt;
  final List<InterviewOption> options;
}

const List<JobOffer> mockJobOffers = [
  JobOffer(
    id: 'job_pm_001',
    title: 'Junior Product Manager',
    company: 'Jasa Future Lab',
    matchPercentage: 96,
    requiredSkills: ['Коммуникация', 'Аналитика', 'Организация', 'Презентации'],
  ),
  JobOffer(
    id: 'job_ai_002',
    title: 'AI Content Intern',
    company: 'Neuron Stories',
    matchPercentage: 91,
    requiredSkills: [
      'Сторителлинг',
      'AI-инструменты',
      'Креативность',
      'Редактура',
    ],
  ),
  JobOffer(
    id: 'job_ops_003',
    title: 'Operations Assistant',
    company: 'Lift Events',
    matchPercentage: 88,
    requiredSkills: [
      'Системность',
      'Дедлайны',
      'Организация',
      'Кризис-менеджмент',
    ],
  ),
  JobOffer(
    id: 'job_media_004',
    title: 'Media Producer Intern',
    company: 'Campus Wave',
    matchPercentage: 84,
    requiredSkills: ['Съемка', 'Монтаж', 'Сторителлинг', 'Командная работа'],
  ),
];

const List<AnonymousCandidate> mockAnonymousCandidates = [
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
  AnonymousCandidate(
    id: '915',
    archetype: 'Креативный Исследователь',
    matchPercentage: 89,
    topSkills: ['UX', 'Интервью', 'Контент-стратегия'],
    isUnlocked: false,
  ),
];

const List<InterviewScenario> mockInterviewScenarios = [
  InterviewScenario(
    id: 'scenario_deadline',
    prompt:
        'Привет! Перед откликом давай проверим смекалку. Мини-кейс: дедлайн горит, а дизайнер пропал. Что делаешь?',
    options: [
      InterviewOption(
        id: 'deadline_option_a',
        label: 'Соберу базовый макет сам(а), чтобы команда не потеряла темп',
        skillSignal: 'Кризис-менеджмент',
        coverLetterSnippet:
            'умею брать ответственность в кризисе и быстро собирать рабочее решение',
      ),
      InterviewOption(
        id: 'deadline_option_b',
        label:
            'Быстро найду замену и пересоберу приоритеты, чтобы спасти дедлайн',
        skillSignal: 'Координация',
        coverLetterSnippet:
            'сохраняю темп команды, быстро договариваюсь и выстраиваю антикризисный план',
      ),
    ],
  ),
  InterviewScenario(
    id: 'scenario_feedback',
    prompt:
        'AI-HR: представь, что пользователь раскритиковал ваш продукт прямо на демо. Как реагируешь?',
    options: [
      InterviewOption(
        id: 'feedback_option_a',
        label: 'Спокойно уточню детали и переведу критику в список улучшений',
        skillSignal: 'Клиентская эмпатия',
        coverLetterSnippet:
            'спокойно работаю с обратной связью и превращаю критику в понятный план улучшений',
      ),
      InterviewOption(
        id: 'feedback_option_b',
        label: 'Сразу покажу альтернативный сценарий и защищу решение данными',
        skillSignal: 'Аргументация',
        coverLetterSnippet:
            'умею защищать решение данными и быстро перестраивать подачу под ситуацию',
      ),
    ],
  ),
  InterviewScenario(
    id: 'scenario_team_conflict',
    prompt:
        'AI-HR: два участника команды спорят, и из-за этого стопорится запуск. Твое действие?',
    options: [
      InterviewOption(
        id: 'conflict_option_a',
        label: 'Проведу быструю фасилитацию и соберу общее решение на 15 минут',
        skillSignal: 'Фасилитация',
        coverLetterSnippet:
            'умею гасить конфликт, фасилитировать команду и возвращать всех к общему результату',
      ),
      InterviewOption(
        id: 'conflict_option_b',
        label:
            'Разделю спор на факты и риски, а потом приму ответственное решение',
        skillSignal: 'Стратегическое мышление',
        coverLetterSnippet:
            'умею разложить спор по фактам, быстро оценить риски и принять взрослое решение',
      ),
    ],
  ),
];

InterviewScenario interviewScenarioForJob(String jobId) {
  if (mockInterviewScenarios.isEmpty) {
    throw StateError('mockInterviewScenarios must not be empty');
  }

  final index = jobId.hashCode.abs() % mockInterviewScenarios.length;
  return mockInterviewScenarios[index];
}
