import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/game/rules/event_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const remoteProfile = PlayerProfile(
    displayName: '',
    jobTitle: '',
    jobDescription: '',
    companyName: '',
    employmentType: EmploymentType.salaried,
    workTags: {'Remote work'},
    avatar: ProfileAvatar.circle,
  );

  test(
    'gives tagged project-incentive events an additional deterministic slot',
    () {
      expect(
        eventForProfileDay(day: 11, profile: remoteProfile).title,
        'Project incentive',
      );
    },
  );

  test('does not treat a possible incentive as a fixed payday forecast', () {
    final event = eventForProfileDay(day: 11, profile: remoteProfile);

    expect(event.isPossibleIncome, isTrue);
    expect(event.choices.map((choice) => choice.amount), contains(2500));
  });

  test('returns the same event sequence for the same seed', () {
    final first = List.generate(
      6,
      (index) => eventForProfileDay(
        day: index + 1,
        profile: remoteProfile,
        seed: 42,
      ).title,
    );
    final second = List.generate(
      6,
      (index) => eventForProfileDay(
        day: index + 1,
        profile: remoteProfile,
        seed: 42,
      ).title,
    );

    expect(second, first);
  });
}
