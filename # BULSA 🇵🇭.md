# BULSA 🇵🇭 — Game Design Reference

## Documentation map

This file describes the product and gameplay. The following files are the rules for implementation:

- [Design system](docs/DESIGN_SYSTEM.md) — mandatory colors, radii, spacing, and component behavior.
- [Feature roadmap](docs/FEATURE_ROADMAP.md) — phased feature order and the current continuation point.
- [Agent working rules](AGENTS.md) — instructions that apply to future implementation work.

## Product decision: make a game first

**BULSA is a single-player Filipino budgeting survival game**, not a banking or expense-tracking app.

The player has one configurable in-game pay cycle to make their salary last, cover necessities, build savings, and respond to life events. It should feel like a compact strategy game with relatable Philippine day-to-day choices—not a spreadsheet with game badges.

### Recommended first game: *BULSA: Survive the Month*

**One-line pitch:** Configure a pay period, start on the next payday, and finish the cycle with your bills paid and a savings target met.

**Why this is a good first Flame project**

- A complete session has a clear beginning, middle, and ending.
- It works fully offline with fictional money and scenarios.
- The core is UI/state/game rules, which Flutter does well; Flame can add polish, transitions, particles, and a small animated room/map later.
- It is small enough to ship before adding cards, QR codes, user accounts, or real transaction tracking.

### Core loop

```text
PAYDAY → allocate money → advance a calendar day → choose spending/event response
       → update cash, needs, savings, and stress → next scheduled payday / run result
```

### Win / lose conditions

| Outcome | Condition |
| --- | --- |
| Great month | All bills paid, no debt, and savings target reached |
| Survived | All bills paid and cash is at or above ₱0 |
| Struggling | Month ends with unpaid bills or debt |
| Game over | Cash falls below a selected debt limit before payday |

### Player resources (MVP)

- **Cash** — spendable money.
- **Savings** — protected progress toward a goal; can be withdrawn in an emergency.
- **Energy** — optional; low energy makes work choices weaker.
- **Stress** — optional; high stress limits or worsens choices.
- **Calendar** — uses real dates, including 28–31-day months and weekends.

Keep the first prototype to **cash, savings, and calendar date**. Add energy/stress only once the basic loop is fun.

### Calendar and pay schedule (required)

A run is a **pay cycle**, not a fixed 30-day month. Players choose a start date and configure their own pay schedule.

| Setting | Example |
| --- | --- |
| Run start | 15 September 2026, first cutoff/payday |
| Regular paydays | 15th and last calendar day of each month |
| Month-end rule | Automatically uses 28, 29, 30, or 31 as appropriate |
| Weekend/holiday policy | Pay on the previous workday, next workday, or keep the date |
| Pay adjustment | Scheduled, paid early, paid late, or pending |
| Cycle end | Next payday, end of month, or player-selected date |

For a player paid on the **15th and the last day of the month**, a cycle can begin on 15 September and aim toward 30 September. If payday lands on a weekend, its selected rule can advance it to Friday or delay it to Monday. February automatically uses the correct end date for its year.

Always show the **expected payday** and its status: `Expected`, `Early`, `Late`, `Received`, or `Pending`. A late payday becomes a deliberate gameplay challenge—not a calendar bug.

### Income types

Income must distinguish money that is guaranteed from money that is only possible.

| Type | Example | Rule |
| --- | --- | --- |
| Fixed salary | ₱15,000 every 15th and month-end | Scheduled, with an optional early/late adjustment |
| Recurring allowance | ₱1,000 every payday | Optional repeating income |
| Project incentive | App-release incentive | Possible event; never included in the base budget |
| Bonus / 13th-month pay | December bonus | One-time or seasonal scheduled income |
| Freelance / side work | Small client project | Player-triggered opportunity with a trade-off |

Forecasts must display **confirmed income** separately from **possible income**. An incentive is only added once it is awarded.

### Player profile and work context

Profiles make scenarios feel personal without turning the app into a financial-data service. Store this locally by default and make every field optional.

- Display name and avatar
- Job title / job description (for example, *mobile app developer*)
- Employment type: salaried, contractual, freelance, business owner, or student
- Industry / company nickname and work location (optional)
- Regular pay schedule and weekend/holiday policy
- Typical fixed bills, savings goal, and preferred currency
- Optional narrative tags such as `remote work`, `commuter`, or `supports family`, which can select relevant event cards

Do not require legal name, employer address, employee ID, bank credentials, or payslips for the game.

### What gameplay feels like

This is a **choice-driven resource-management game**. The player is not controlling a character with a joystick or fighting enemies. Instead, they make a few difficult money decisions each in-game day, then immediately see what those choices change.

A short play session should feel like this:

1. The player opens the game and sees today’s date, cash, savings, next bill, and next payday.
2. They receive a situation card: lunch, a commute problem, an invitation, a bill, or a work opportunity.
3. They choose one response. Each response has a visible money cost and may have a hidden or later effect.
4. The game adds a ledger entry, updates the calendar, and reveals the next day or event.
5. At the end of the pay cycle, the player gets a result: did they cover necessities and move closer to their goal?

The fun comes from trade-offs, not from always picking the cheapest option. A zero-cost option can cost energy or increase the chance of a later problem; spending money can protect the player from a worse outcome.

### One example turn

```text
Tuesday, 22 September — 8 days until payday
Cash: ₱4,280     Savings: ₱1,700 / ₱3,000
Next bill: Utilities, ₱1,500 on 30 September

LUNCH BREAK
You forgot to prepare food before work.

[ Carinderia — ₱120 ]
[ Convenience meal — ₱220 ]
[ Skip / packed snack — ₱0 ]
```

After the choice, show a tiny consequence such as `−₱120 · Food` in the ledger. Do not overwhelm the player with several menus at once.

### Look and feel

Aim for a warm, clean, **mobile-first Filipino everyday-life** look:

- A small calendar/status strip at the top—not a dense finance dashboard.
- Large event cards in the center; this is where the player spends most of their time.
- Cash and savings are always visible but calm and readable.
- Use a friendly palette: deep teal/green for stability, warm cream backgrounds, and amber/red only for warnings or urgent bills.
- Start with icons, simple shapes, and subtle motion. You do not need character sprites or detailed background art for the first build.
- Later, Flame can animate a simple room, commute route, rain, coin movement, or celebrations behind the Flutter event card.

### Flutter versus Flame, in plain language

Flutter builds the app-like parts: buttons, text, forms, calendar, profile setup, and cards. Flame is a Flutter game toolkit; use it for the parts that make the game feel alive: animation, tiny visual effects, and an optional playable scene.

For the first version, it is completely valid for **90% of the game to be Flutter UI** and for Flame to animate only the background and rewards. Do not begin with a map, character movement, or physics system. First prove that selecting an option, losing/gaining money, and reaching payday feels satisfying.

### First visual milestone

Build one screen that contains only:

- Current date and days until payday
- Cash, savings goal, and next bill
- One event card with two or three big choices
- A one-line result/ledger update after a choice

If that screen feels clear and satisfying, you have the heart of BULSA.

### First playable scenario

```text
Role: Junior app developer living in Metro Manila
Run starts: 15 September 2026 (first cutoff)
Starting cash: ₱22,000
Regular pay: ₱15,000 on the 15th and month-end
Pay policy: Move weekend payday to the preceding Friday
Savings target: ₱3,000 by the next month-end payday
Fixed bills: Rent ₱6,000 (20 September), utilities ₱1,500 (30 September)
Possible income: ₱2,500 project incentive (not guaranteed)
Daily needs: Food and commute
```

Each day, show 1–2 choices. Examples:

| Situation | Choices | Meaningful trade-off |
| --- | --- | --- |
| Lunch | Carinderia ₱120 / Convenience meal ₱220 / Packed lunch ₱0 | Cash vs. convenience |
| Commute | Jeep ₱15 / Ride-hailing ₱250 / Walk ₱0 | Cash vs. time/energy later |
| Friend invite | Go out ₱600 / Decline ₱0 | Social reward later vs. savings now |
| Phone repair | Pay ₱1,800 / Delay repair / Use savings | Immediate cost vs. future risk |
| Freelance gig | Rest / Take gig (+₱500, costs energy) | Short-term money vs. player condition |

### Events for the initial content pack

- Salary / freelance bonus
- Surprise family contribution
- Motorcycle or phone repair
- Utility bill higher than expected
- Grocery discount
- Friend’s birthday invitation
- Rainy-day transport disruption
- Small emergency medical expense

Use fictional situations and values. The game must not request bank credentials, card numbers, PINs, CVVs, or real payment access.

---

## MVP: build this before anything else

### Screens

1. **Title / New Game** — choose one scenario.
2. **Payday allocation** — drag/tap money into Cash and Savings.
3. **Daily decision** — event card, choices, visible consequences.
4. **Calendar overview** — date, cash, savings, next bill, next expected payday/status, and history.
5. **Pay-cycle report** — result, score, and one lesson based on player behavior.

### Rules

- Advancing a calendar day may trigger a fixed bill, a need, a payday, or a random event.
- Regular pay follows the selected calendar/weekend policy; possible income is only added after its event awards it.
- Choices change cash and, later, energy/stress.
- Savings cannot be spent without an explicit “withdraw savings” confirmation.
- Every money change writes a short in-game ledger entry.
- Score uses: bills paid, savings target, ending cash, and debt avoided.

### Explicitly out of scope for v1

- Real bank/payment integration, real cards, and payment QR codes
- Accounts, cloud sync, multiplayer, or money transfer between users
- Custom user-uploaded card art
- Full budgeting categories, analytics, store, avatar system, and unlimited goals

These are possible expansions after the game proves fun, but including them now would delay the first playable build substantially.

---

## Flutter + Flame architecture recommendation

Use **Flutter for screens, menus, forms, and accessibility**. Use **Flame only where it adds game feel**: a `GameWidget` scene, animated event transitions, particles/coins, and optional character/map visuals.

```text
lib/
├── main.dart
├── app.dart
├── game/
│   ├── bulsa_game.dart          # Flame game root and overlays
│   ├── game_state.dart          # date, cash, savings, income, bills, results
│   ├── models/                  # profile, event, choice, bill, income schedule, ledger item
│   ├── rules/                   # calendar, payday, event selection, outcome logic
│   └── data/                    # first scenario and event definitions
├── screens/                     # title, allocation, overview, results
└── widgets/                     # reusable money/event UI
```

Suggested implementation order:

1. Make one hard-coded 7-day scenario in plain Flutter, including a start date and payday.
2. Add calendar logic, cash, savings, fixed bills, confirmed income, ledger, and a result screen.
3. Add 8–10 event cards, possible-income events, and seedable random selection for testing.
4. Support user-configured pay cycles and tune the values until choices are genuinely difficult.
5. Add Flame presentation: transitions, animated background, and celebration/failure effects.
6. Only then add progression, new scenarios, achievements, or cosmetic cards.

### Definition of a successful vertical slice

A new player can choose a start date and payday rule, start a 7-day run, make at least five meaningful choices, encounter a bill and a random event, see all money changes in a ledger, and reach a clear end screen in under five minutes.

---

## Future ideas (not MVP)

The following original ideas are worth retaining as a backlog. Reintroduce them only when they reinforce the central loop: **earn → choose → survive → save**.

### Original feature backlog (unprioritized)

The notes below capture later possibilities. Treat the payment- and card-related items as **fictional game systems only** unless the product is deliberately redesigned as a regulated financial application.

#### 🎮 1. Main Game

- Start with an initial **cash balance**
- Receive **salary / income**
- Manage money throughout the month
- Pay recurring bills
- Buy food
- Pay transportation
- Handle unexpected expenses
- Make lifestyle purchases
- Save money
- Set financial goals
- Different choices affect the player's remaining budget
- End-of-month financial summary
- Score/reward based on how well the player managed their money
- Increasing difficulty as the player progresses
- Random events:
  - Emergency
  - Bonus
  - Discount
  - Lost money
  - Unexpected bill
  - Extra income

---

#### 💰 2. Budget System

Players can create budgets such as:

- Food
- Transportation
- Bills
- Shopping
- Entertainment
- Savings
- Emergency
- Other

Features:

- Set monthly budget
- Set weekly budget
- Track spending
- Remaining budget
- Budget percentage used
- Spending history
- Budget warnings
- Budget exceeded notification
- Move money between budgets
- Create custom budget categories

Example:

```text
Monthly Income
₱30,000

Food              ₱5,000
Transportation    ₱3,000
Bills             ₱8,000
Entertainment     ₱2,000
Savings           ₱7,000
Other             ₱5,000
```

---

#### 💳 3. BULSA Digital Cards

This could be one of the main features of the app.

Users can create their own **digital cards** inside BULSA.

### Card list

```text
My Cards

[ BDO Card ]
₱8,500

[ My Savings ]
₱15,200

[ Travel Card ]
₱3,500

[ Emergency ]
₱10,000
```

### Card customization

Users can:

- Create unlimited/custom number of cards
- Choose card name
- Choose card type
- Choose card color
- Choose background
- Add card logo
- Add nickname
- Add card description
- Customize text
- Upload a **full card image**
- Position/fit uploaded image inside the card
- Add an icon
- Show/hide balance
- Lock/unlock card
- Delete card

The uploaded image could essentially become the **visual design of the card**.

---

#### 📷 4. QR Code on Cards

Each digital card can have a QR code.

For now, the QR code is specifically for:

### **Receiving money**

Example:

```text
MY BULSA CARD

[ CARD IMAGE ]

John's Savings
₱15,500

       [ QR ]

     RECEIVE
```

Other user scans the QR → sees the receiving information → sends money.

Later you could expand this into:

- Receive money
- Request money
- Pay another BULSA user
- Merchant payments
- QR payment history

---

#### 💸 5. Card Transactions

Every card can have its own transaction history.

Example:

```text
BDO Card

Balance
₱8,500

Transactions

+ ₱10,000   Salary
- ₱2,500    Rent
- ₱500      Food
- ₱200      Transportation
+ ₱1,000    Transfer

Current Balance
₱7,800
```

Transaction types:

- Income
- Expense
- Transfer
- Receive
- Send
- Refund
- Adjustment

---

#### 🔗 6. Cards ↔ Budget Integration

This is where your **game + budgeting + cards** can connect.

When the user makes a card transaction, they can assign it to a budget.

Example:

```text
Card Transaction

₱450

Food
↓
Budget: Food

Food Budget
₱5,000 → ₱4,550
```

So the card automatically affects the budget.

### Example

User spends:

**₱1,000 using Travel Card**

They select:

```text
Category:
Transportation

Budget:
September Transportation
```

Then:

```text
Transportation Budget

₱3,000
- ₱1,000

Remaining
₱2,000
```

This makes the **Cards feature directly useful to the budgeting game**.

---

#### 🔄 7. Money Transfer Between Cards

Users can move money between their own cards.

Example:

```text
From:
Main Card
₱10,000

To:
Savings Card

Amount:
₱2,000

[ TRANSFER ]
```

Result:

```text
Main Card
₱8,000

Savings Card
₱2,000
```

The transfer itself should **not count as an expense**, otherwise the budget would become incorrect.

---

#### 🏦 8. Savings

Players can create savings goals.

Examples:

- New Phone — ₱50,000
- Emergency Fund — ₱30,000
- Vacation — ₱20,000
- Nintendo Switch 2 — ₱30,000 😄

Features:

- Goal amount
- Current savings
- Target date
- Progress %
- Add money
- Withdraw money
- Goal milestones
- Rewards

---

#### 📊 9. Financial Dashboard

Main dashboard could show:

```text
Good morning, John 👋

Total Money
₱28,500

Monthly Income
₱30,000

Spent
₱12,400

Saved
₱7,000

Remaining
₱10,600
```

Then:

**Budget Health**

```text
Food           ███████░░░ 70%
Transport      █████░░░░░ 50%
Entertainment  █████████░ 90%
Savings        ████████░░ 80%
```

---

#### 📜 10. Transaction History

Central transaction history across **all cards**.

Filters:

- All
- Income
- Expenses
- Transfers
- Card
- Category
- Date
- Amount

Search:

```text
Search transactions...
```

---

#### 🎯 11. Financial Goals

Gamify saving.

Examples:

```text
🎯 Emergency Fund
₱12,000 / ₱30,000

████████░░░░ 40%

+ ₱500
```

Possible rewards:

- Coins
- XP
- New card designs
- Avatars
- Themes
- Decorations
- Achievements

---

#### 🏆 12. Achievements

Examples:

- 🪙 **First Ipon** — Save your first ₱1,000
- 💰 **₱10K Club** — Reach ₱10,000 savings
- 🛡️ **Emergency Ready** — Complete emergency fund
- 📊 **Budget Master** — Stay within all budgets for a month
- 💳 **Card Collector** — Create 5 cards
- 🔥 **30-Day Saver** — Save money for 30 consecutive days
- 🧾 **No Overspending** — Finish a month without exceeding a budget

---

#### 🛍️ 13. In-Game Store

Players can spend **game currency**, not real money, on:

- Card designs
- Card backgrounds
- Themes
- Avatars
- Profile frames
- Decorations
- Unlockable content

This gives you another progression system.

---

#### 🎲 14. Random Life Events

This is important for making BULSA actually feel like a **game**, rather than just a budgeting tracker.

Example:

> 🚗 **Your motorcycle broke down!**
>
> Repair cost: **₱2,500**
>
> What will you do?

**A. Pay from emergency fund**

**B. Borrow money**

**C. Skip the repair**

Each decision affects the player's game.

---

#### 📅 15. Monthly Challenge

Each month can have a different objective.

Examples:

### September Challenge

> Start with ₱30,000.
>
> Survive 30 days.
>
> Save at least ₱5,000.

Or:

> **No-Spend Weekend**
>
> Don't spend money for 2 consecutive days.

This makes players come back.

---

#### 👤 16. Player Profile

- Username
- Avatar
- Level
- XP
- Total savings
- Current balance
- Achievements
- Financial streak
- Cards
- Goals
- Game statistics

---

#### 🧠 17. Financial Education Through Gameplay

Instead of making BULSA feel like a school app, teach concepts through gameplay:

- Needs vs wants
- Emergency funds
- Saving
- Budget allocation
- Debt
- Interest
- Impulse buying
- Recurring expenses
- Financial goals
- Opportunity cost

Example:

> You have ₱1,000 left.
>
> 🎮 Buy a new game — ₱1,000
> 🍱 Buy groceries — ₱700
> 💰 Save — ₱1,000

The player chooses.

---

#### 🔐 18. Security / Privacy

For the **digital cards**, I would make an important distinction:

The card should be a **BULSA virtual representation**, not a fake copy of an actual bank card.

Avoid requiring users to enter:

- Real card number
- CVV
- PIN
- Online banking password

The user can upload their own **card artwork/image**, but BULSA doesn't need to store actual payment-card credentials.

For QR, initially keep it strictly as a **BULSA receiving QR**, rather than trying to make it compatible with actual bank/payment QR systems.

---

#### 🧩 Suggested Main Navigation

I'd keep the first version simple:

```text
HOME
│
├── Balance
├── Budgets
├── Recent Transactions
├── Goals
└── Daily Challenge


CARDS
│
├── My Cards
├── Create Card
├── Card Details
├── QR Receive
└── Card Transactions


BUDGET
│
├── Monthly Budget
├── Categories
├── Spending
└── Budget History


GAME
│
├── Current Challenge
├── Life Events
├── Missions
├── Achievements
└── Rewards


PROFILE
│
├── Player Profile
├── Statistics
├── Achievements
├── Settings
└── Help
```

### The core BULSA loop

The strongest part of the concept would be:

**Earn → Budget → Spend → Card Transaction → Budget updates → Save → Encounter life events → Complete challenges → Earn rewards → Level up**

That makes the **budgeting system part of the actual gameplay**, rather than having a game and a separate budgeting tracker sitting beside each other.
