import 'package:bulsa/game/models/game_models.dart';

const demoScenario = <GameEvent>[
  GameEvent(
    day: 1,
    title: 'Lunch break',
    description: 'You forgot to prepare food before work.',
    choices: [
      GameChoice(
        label: 'Carinderia — ₱120',
        amount: -120,
        category: 'Food',
        description: 'Carinderia lunch',
      ),
      GameChoice(
        label: 'Convenience meal — ₱220',
        amount: -220,
        category: 'Food',
        description: 'Convenience-store lunch',
      ),
      GameChoice(
        label: 'Packed snack — ₱0',
        amount: 0,
        category: 'Food',
        description: 'Packed snack',
      ),
    ],
  ),
  GameEvent(
    day: 2,
    title: 'Rainy commute',
    description: 'Heavy rain makes your usual route slower today.',
    choices: [
      GameChoice(
        label: 'Jeepney — ₱15',
        amount: -15,
        category: 'Transport',
        description: 'Jeepney fare',
      ),
      GameChoice(
        label: 'Ride-hailing — ₱250',
        amount: -250,
        category: 'Transport',
        description: 'Ride-hailing fare',
      ),
    ],
  ),
  GameEvent(
    day: 3,
    title: 'Project review',
    description: 'Your team celebrates a successful review.',
    choices: [
      GameChoice(
        label: 'Join merienda — ₱180',
        amount: -180,
        category: 'Social',
        description: 'Team merienda',
      ),
      GameChoice(
        label: 'Head home — ₱0',
        amount: 0,
        category: 'Social',
        description: 'Skipped team merienda',
      ),
    ],
  ),
  GameEvent(
    day: 4,
    title: 'Grocery top-up',
    description: 'Your pantry is running low before the weekend.',
    choices: [
      GameChoice(
        label: 'Essentials — ₱450',
        amount: -450,
        category: 'Food',
        description: 'Grocery essentials',
      ),
      GameChoice(
        label: 'Quick snacks — ₱180',
        amount: -180,
        category: 'Food',
        description: 'Quick snacks',
      ),
    ],
  ),
  GameEvent(
    day: 5,
    title: 'Utility bill',
    description: 'Your mobile data add-on needs renewal.',
    choices: [
      GameChoice(
        label: 'Renew data — ₱299',
        amount: -299,
        category: 'Bills',
        description: 'Mobile data renewal',
      ),
      GameChoice(
        label: 'Use Wi-Fi only — ₱0',
        amount: 0,
        category: 'Bills',
        description: 'Deferred mobile data renewal',
      ),
    ],
  ),
  GameEvent(
    day: 6,
    title: 'Freelance opportunity',
    description: 'A small bug fix is available after work.',
    choices: [
      GameChoice(
        label: 'Accept job +₱500',
        amount: 500,
        category: 'Income',
        description: 'Freelance bug fix',
      ),
      GameChoice(
        label: 'Rest tonight — ₱0',
        amount: 0,
        category: 'Income',
        description: 'Declined freelance bug fix',
      ),
    ],
  ),
  GameEvent(
    day: 7,
    title: 'Payday eve',
    description: 'One last choice before your next payday.',
    choices: [
      GameChoice(
        label: 'Cook at home — ₱100',
        amount: -100,
        category: 'Food',
        description: 'Home-cooked dinner ingredients',
      ),
      GameChoice(
        label: 'Order dinner — ₱300',
        amount: -300,
        category: 'Food',
        description: 'Dinner delivery',
      ),
    ],
  ),
];
