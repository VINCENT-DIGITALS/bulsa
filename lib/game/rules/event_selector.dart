import 'package:bulsa/game/data/demo_scenario.dart';
import 'package:bulsa/game/models/game_models.dart';

/// Selects a deterministic event while giving work-relevant cards one extra
/// entry in the pool. The game remains reproducible without treating possible
/// incentives as predicted or confirmed income.
GameEvent eventForProfileDay({
  required int day,
  required PlayerProfile profile,
  int seed = 0,
}) {
  final relevant = demoScenario
      .where((event) => event.audienceTags.any(profile.workTags.contains))
      .toList();
  final weightedPool = [...demoScenario, ...relevant];
  return weightedPool[(seed + day - 1) % weightedPool.length];
}
