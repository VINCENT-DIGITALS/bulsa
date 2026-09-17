class GameRun {
  const GameRun({
    required this.currentDay,
    required this.totalDays,
    required this.startDate,
    required this.paydayDate,
    required this.cash,
    required this.savings,
    required this.confirmedSalary,
    required this.recurringAllowance,
    required this.debtLimit,
    required this.eventSeed,
    required this.completed,
    required this.failed,
  });

  final int currentDay;
  final int totalDays;
  final DateTime startDate;
  final DateTime paydayDate;
  final int cash;
  final int savings;
  final int confirmedSalary;
  final int recurringAllowance;
  final int debtLimit;
  final int eventSeed;
  final bool completed;
  final bool failed;

  int get daysRemaining => completed ? 0 : totalDays - currentDay + 1;

  DateTime get currentDate => startDate.add(Duration(days: currentDay - 1));

  bool get isClosed => completed || failed;
}

class FixedBill {
  const FixedBill({
    required this.day,
    required this.title,
    required this.amount,
  });

  final int day;
  final String title;
  final int amount;
}

enum EmploymentType { salaried, contractual, freelance, businessOwner, student }

enum ProfileAvatar { circle, square, triangle }

class PlayerProfile {
  const PlayerProfile({
    required this.displayName,
    required this.jobTitle,
    required this.jobDescription,
    required this.companyName,
    required this.employmentType,
    required this.workTags,
    required this.avatar,
  });

  const PlayerProfile.empty()
    : displayName = '',
      jobTitle = '',
      jobDescription = '',
      companyName = '',
      employmentType = EmploymentType.salaried,
      workTags = const {},
      avatar = ProfileAvatar.circle;

  final String displayName;
  final String jobTitle;
  final String jobDescription;
  final String companyName;
  final EmploymentType employmentType;
  final Set<String> workTags;
  final ProfileAvatar avatar;

  String get greetingName =>
      displayName.trim().isEmpty ? 'Player' : displayName;

  PlayerProfile copyWith({
    String? displayName,
    String? jobTitle,
    String? jobDescription,
    String? companyName,
    EmploymentType? employmentType,
    Set<String>? workTags,
    ProfileAvatar? avatar,
  }) => PlayerProfile(
    displayName: displayName ?? this.displayName,
    jobTitle: jobTitle ?? this.jobTitle,
    jobDescription: jobDescription ?? this.jobDescription,
    companyName: companyName ?? this.companyName,
    employmentType: employmentType ?? this.employmentType,
    workTags: workTags ?? this.workTags,
    avatar: avatar ?? this.avatar,
  );
}

class LedgerEntry {
  const LedgerEntry({
    required this.day,
    required this.amount,
    required this.category,
    required this.description,
  });

  final int day;
  final int amount;
  final String category;
  final String description;
}

class GameChoice {
  const GameChoice({
    required this.label,
    required this.amount,
    required this.category,
    required this.description,
  });

  final String label;
  final int amount;
  final String category;
  final String description;
}

class GameEvent {
  const GameEvent({
    required this.day,
    required this.title,
    required this.description,
    required this.choices,
    this.audienceTags = const [],
    this.isPossibleIncome = false,
  });

  final int day;
  final String title;
  final String description;
  final List<GameChoice> choices;
  final List<String> audienceTags;
  final bool isPossibleIncome;
}
