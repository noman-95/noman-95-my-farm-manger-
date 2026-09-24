import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import 'report_download.dart';

const green = Color(0xFF167A4A);
const darkGreen = Color(0xFF0B4D31);
const bg = Color(0xFFF4F7F5);

void main() => runApp(const FarmManagerApp());

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String money(double v) =>
    v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);

String safeFile(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'_+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');


// ===== Dashboard decorative helpers (v5) =====
Widget farmDecoratedHeader(BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primaryContainer,
        ],
      ),
      boxShadow: const [
        BoxShadow(
          blurRadius: 18,
          offset: Offset(0, 8),
          color: Color(0x26000000),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.18),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(
                  color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(.88),
                  fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget farmMiniDecoration(BuildContext context, IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: flutter.Border.all(color: Theme.of(context).dividerColor.withOpacity(.55)),
      boxShadow: const [
        BoxShadow(blurRadius: 12, offset: Offset(0, 5), color: Color(0x14000000)),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          child: Icon(icon, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget financeReportTotalCard(BuildContext context, double income, double expense) {
  final net = income - expense;
  return Container(
    margin: const EdgeInsets.only(top: 14, bottom: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primaryContainer,
          Theme.of(context).colorScheme.surface,
        ],
      ),
      boxShadow: const [
        BoxShadow(blurRadius: 16, offset: Offset(0, 7), color: Color(0x18000000)),
      ],
    ),
    child: Column(
      children: [
        const Text("REPORT TOTAL",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _reportTotalItem("Income", income)),
            Expanded(child: _reportTotalItem("Expense", expense)),
            Expanded(child: _reportTotalItem("Balance", net)),
          ],
        ),
      ],
    ),
  );
}

Widget _reportTotalItem(String title, double value) {
  return Column(
    children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(value.toStringAsFixed(2),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
    ],
  );
}


// ===== Ali Goat Farm — Modern UI v6 =====
const Color agfDeep = Color(0xFF12372A);
const Color agfGreen = Color(0xFF1F7A4D);
const Color agfMint = Color(0xFFE8F5EC);
const Color agfGold = Color(0xFFD9A441);

BoxDecoration agfGlassCard(BuildContext context, {bool elevated = true}) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface.withOpacity(.96),
    borderRadius: BorderRadius.circular(24),
    border: flutter.Border.all(
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(.45),
    ),
    boxShadow: elevated
        ? const [
            BoxShadow(
              blurRadius: 22,
              spreadRadius: -6,
              offset: Offset(0, 10),
              color: Color(0x22000000),
            ),
          ]
        : null,
  );
}

Widget agfModernHero(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [agfDeep, agfGreen],
      ),
      boxShadow: const [
        BoxShadow(
          blurRadius: 24,
          offset: Offset(0, 12),
          color: Color(0x33000000),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -20,
          top: -28,
          child: Icon(
            Icons.agriculture_rounded,
            size: 130,
            color: Colors.white.withOpacity(.07),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(17),
                    border: flutter.Border.all(color: Colors.white.withOpacity(.18)),
                  ),
                  child: const Icon(Icons.pets_rounded, color: Colors.white, size: 29),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'ALI GOAT FARM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Color(0xFF7CFFB2), size: 8),
                      SizedBox(width: 6),
                      Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Farm Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              'Manage animals, milk, health and finances in one place.',
              style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget agfQuickAction(BuildContext context, IconData icon, String title, VoidCallback onTap) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(15),
        decoration: agfGlassCard(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Icon(Icons.arrow_forward_rounded, size: 17, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    ),
  );
}


Widget agfAnimatedPage({required Widget child}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: .96, end: 1),
    duration: const Duration(milliseconds: 420),
    curve: Curves.easeOutCubic,
    builder: (context, value, _) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: child,
      ),
    ),
  );
}

class FarmManagerApp extends StatefulWidget {
  const FarmManagerApp({super.key});

  @override
  State<FarmManagerApp> createState() => _FarmManagerAppState();
}

class _FarmManagerAppState extends State<FarmManagerApp> {
  ThemeMode mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Manager',
      themeMode: mode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: bg,
        cardTheme: const CardThemeData(
          elevation: 0.8,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE1E8E3),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
        ),
      ),
      home: FarmShell(
        dark: mode == ThemeMode.dark,
        onThemeChanged: () {
          setState(() {
            mode = mode == ThemeMode.light
                ? ThemeMode.dark
                : ThemeMode.light;
          });
        },
      ),
    );
  }
}

class FarmShell extends StatefulWidget {
  final bool dark;
  final VoidCallback onThemeChanged;

  const FarmShell({
    super.key,
    required this.dark,
    required this.onThemeChanged,
  });

  @override
  State<FarmShell> createState() => _FarmShellState();
}

class _FarmShellState extends State<FarmShell> {
  int index = 0;
  bool loading = true;

  String farmName = 'Ali Goat Farm';

  List<Animal> animals = [];
  List<FinanceRecord> finance = [];
  List<HealthRecord> health = [];
  List<SpecialExpense> specialExpenses = [];
  List<MilkRecord> milkRecords = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();

    final rawAnimals =
        p.getStringList('animals_v5') ??
        p.getStringList('animals_v4') ??
        [];

    final rawFinance =
        p.getStringList('finance_v5') ??
        p.getStringList('finance_v4') ??
        [];

    final rawHealth = p.getStringList('health_v1') ?? [];
    final rawSpecial = p.getStringList('special_expenses_v1') ?? [];
    final rawMilk = p.getStringList('milk_v1') ?? [];

    setState(() {
      farmName = 'Ali Goat Farm';

      animals = rawAnimals
          .map((x) => Animal.fromJson(jsonDecode(x)))
          .toList();

      finance = rawFinance
          .map((x) => FinanceRecord.fromJson(jsonDecode(x)))
          .toList();

      health = rawHealth
          .map((x) => HealthRecord.fromJson(jsonDecode(x)))
          .toList();
      specialExpenses = rawSpecial
          .map((x) => SpecialExpense.fromJson(jsonDecode(x)))
          .toList();
      milkRecords = rawMilk
          .map((x) => MilkRecord.fromJson(jsonDecode(x)))
          .toList();

      loading = false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();

    await p.setString('farm_name_v5', farmName);

    await p.setStringList(
      'animals_v5',
      animals.map((x) => jsonEncode(x.toJson())).toList(),
    );

    await p.setStringList(
      'finance_v5',
      finance.map((x) => jsonEncode(x.toJson())).toList(),
    );

    await p.setStringList(
      'health_v1',
      health.map((x) => jsonEncode(x.toJson())).toList(),
    );
    await p.setStringList(
      'special_expenses_v1',
      specialExpenses.map((x) => jsonEncode(x.toJson())).toList(),
    );
    await p.setStringList(
      'milk_v1',
      milkRecords.map((x) => jsonEncode(x.toJson())).toList(),
    );
  }

  void addAnimal(Animal a) {
    setState(() {
      animals.add(a);

      if (a.parentId.isNotEmpty) {
        Animal? parent;

        for (final x in animals) {
          if (x.tag.toLowerCase() == a.parentId.toLowerCase()) {
            parent = x;
            break;
          }
        }

        if (parent != null && parent.status == 'Pregnant') {
          parent.status = 'Active';
          parent.pregnancyStart = '';
          parent.dueDate = '';
        }
      }
    });

    _save();
  }

  void updateAnimal(Animal a) {
    setState(() {});
    _save();
  }

  void deleteAnimal(Animal a) {
    setState(() => animals.remove(a));
    _save();
  }

  void addFinance(FinanceRecord r) {
    setState(() => finance.insert(0, r));
    _save();
  }

  void addHealth(HealthRecord r) {
    setState(() => health.insert(0, r));
    _save();
  }

  void addSpecialExpense(SpecialExpense r) {
    setState(() {
      specialExpenses.insert(0, r);
      finance.insert(0, FinanceRecord(
        id: 'special-${r.id}', date: r.date, type: 'Expense',
        category: 'Special Expense', amount: r.amount,
        notes: '${r.animalTag.isEmpty ? '' : 'Animal ${r.animalTag}: '}${r.title}${r.notes.isEmpty ? '' : ' • ${r.notes}'}',
      ));
    });
    _save();
  }

  void addMilk(MilkRecord r) {
    setState(() {
      milkRecords.insert(0, r);
      if (r.price > 0) {
        finance.insert(0, FinanceRecord(
          id: 'milk-${r.id}', date: r.date, type: 'Income', category: 'Milk',
          amount: r.price, notes: '${r.liters.toStringAsFixed(1)} L milk${r.animalTag.isEmpty ? '' : ' • ${r.animalTag}'}',
        ));
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pages = [
      DashboardPage(
        animals: animals,
        finance: finance,
        onNavigate: (i) => setState(() => index = i),
        onQuickHealth: () => _openHealth(),
        onQuickBreeding: () => _openBreeding(),
      ),

      AnimalsPage(
        animals: animals,
        onAdd: addAnimal,
        onDelete: deleteAnimal,
        onUpdate: updateAnimal,
        onSale: _sellAnimal,
        health: health,
        onAddHealth: addHealth,
        specialExpenses: specialExpenses,
        onAddSpecialExpense: addSpecialExpense,
      ),

      MilkPage(records: milkRecords, onAdd: addMilk),

      FinancePage(
        records: finance,
        onAdd: addFinance,
      ),

      MorePage(
        animals: animals,
        finance: finance,
        farmName: farmName,
        health: health,
        onFarmNameChanged: (_) {
          setState(() => farmName = 'Ali Goat Farm');
          _save();
        },
        dark: widget.dark,
        onThemeChanged: widget.onThemeChanged,
        onHealth: _openHealth,
        onBreeding: _openBreeding,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: index,
        onDestinationSelected: (v) {
          setState(() => index = v);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Animals',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_drink_outlined),
            selectedIcon: Icon(Icons.local_drink_rounded),
            label: 'Milk',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(
              Icons.account_balance_wallet_rounded,
            ),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Future<void> _openHealth() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HealthPage(
          animals: animals,
          records: health,
          onAdd: addHealth,
        ),
      ),
    );
  }

  Future<void> _openBreeding() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreedingPage(
          animals: animals,
          onUpdate: updateAnimal,
        ),
      ),
    );
  }

  Future<void> _sellAnimal(Animal animal) async {
    final ctl = TextEditingController();

    final price = await showDialog<double>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Sell ${animal.tag}'),
        content: TextField(
          controller: ctl,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Sale amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              c,
              double.tryParse(ctl.text.trim()),
            ),
            child: const Text('Confirm Sale'),
          ),
        ],
      ),
    );

    ctl.dispose();

    if (price == null || price < 0) return;

    setState(() {
      animal.status = 'Sold';
    });

    addFinance(
      FinanceRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: isoDate(DateTime.now()),
        type: 'Income',
        category: 'Sale',
        amount: price,
        notes: 'Animal ${animal.tag} sold',
      ),
    );
  }
}

class Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const Header({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: .94, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [darkGreen, green]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x33167A4A))],
            ),
            child: Row(children: [
              const FarmLogo(size: 48),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
              IconButton(onPressed: () => showSimpleDialog(context, 'Notifications', 'No new notifications.'), icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }
}

class FarmLogo extends StatelessWidget {
  final double size;

  const FarmLogo({
    super.key,
    this.size = 68,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3AC17B),
            darkGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(size * .28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44167A4A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.agriculture_rounded,
            color: Colors.white,
            size: size * .52,
          ),
          Positioned(
            right: size * .12,
            top: size * .10,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white70,
              size: size * .18,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const SectionTitle(
    this.title, {
    super.key,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 7, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withAlpha(30),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<Animal> animals;
  final List<FinanceRecord> finance;
  final ValueChanged<int> onNavigate;
  final VoidCallback onQuickHealth;
  final VoidCallback onQuickBreeding;

  const DashboardPage({
    super.key,
    required this.animals,
    required this.finance,
    required this.onNavigate,
    required this.onQuickHealth,
    required this.onQuickBreeding,
  });

  @override
  Widget build(BuildContext context) {
    final income = finance
        .where((x) => x.type == 'Income')
        .fold<double>(0, (s, x) => s + x.amount);

    final expenses = finance
        .where((x) => x.type == 'Expense')
        .fold<double>(0, (s, x) => s + x.amount);

    final pregnant =
        animals.where((x) => x.status == 'Pregnant').length;

    final active =
        animals.where((x) => x.status == 'Active').length;

    final sold =
        animals.where((x) => x.status == 'Sold').length;

    final dead =
        animals.where((x) => x.status == 'Dead').length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const Header(
          title: 'My Farm',
          subtitle: 'Simple, clear farm control',
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 7, 18, 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  darkGreen,
                  green,
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33167A4A),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const FarmLogo(size: 70),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Animals',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${animals.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$active active  •  $pregnant pregnant',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SectionTitle('Today at a glance'),

        LayoutBuilder(
          builder: (c, box) {
            final w = (box.maxWidth - 36) / 2;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: w,
                    child: const MetricCard(
                      title: "Today's Milk",
                      value: '0 L',
                      icon: Icons.local_drink_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: MetricCard(
                      title: "Today's Income",
                      value: money(income),
                      icon: Icons.trending_up_rounded,
                      color: green,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: MetricCard(
                      title: "Today's Expenses",
                      value: money(expenses),
                      icon: Icons.trending_down_rounded,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: MetricCard(
                      title: 'Pregnant Animals',
                      value: '$pregnant',
                      icon: Icons.favorite_rounded,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        const SectionTitle('Animal status'),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip('Active', active),
                  StatusChip('Pregnant', pregnant),
                  StatusChip('Sold', sold),
                  StatusChip('Dead', dead),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        const SectionTitle('Quick links'),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              QuickAction(
                'Add Animal',
                Icons.add_circle_outline,
                () => onNavigate(1),
              ),
              QuickAction(
                'Finance',
                Icons.account_balance_wallet_outlined,
                () => onNavigate(3),
              ),
              QuickAction(
                'Medical',
                Icons.medical_services_outlined,
                onQuickHealth,
              ),
              QuickAction(
                'Breeding',
                Icons.favorite_border_rounded,
                onQuickBreeding,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final int count;

  const StatusChip(
    this.label,
    this.count, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(
        Icons.circle,
        size: 10,
        color: green,
      ),
      label: Text('$label: $count'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickAction(
    this.label,
    this.icon,
    this.onTap, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: green,
      ),
      label: Text(label),
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 9,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyState({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: green,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Animal {
  String tag;
  String species;
  String breed;
  String gender;
  String weight;
  String status;
  String parentId;
  String age;
  String dob;
  String pregnancyStart;
  String dueDate;
  String purchaseDate;
  double purchaseAmount;
  String purchaseSource;
  bool pregnant;
  String image1;
  String image2;

  Animal(
    this.tag,
    this.species,
    this.breed,
    this.gender,
    this.weight,
    this.status, {
    this.parentId = '',
    this.age = '',
    this.dob = '',
    this.pregnancyStart = '',
    this.dueDate = '',
    this.purchaseDate = '',
    this.purchaseAmount = 0,
    this.purchaseSource = 'Outside Purchase',
    this.pregnant = false,
    this.image1 = '',
    this.image2 = '',
  });

  Map<String, dynamic> toJson() => {
    'tag': tag, 'species': species, 'breed': breed, 'gender': gender,
    'weight': weight, 'status': status, 'parentId': parentId, 'age': age,
    'dob': dob, 'pregnancyStart': pregnancyStart, 'dueDate': dueDate,
    'purchaseDate': purchaseDate, 'purchaseAmount': purchaseAmount,
    'purchaseSource': purchaseSource,
    'pregnant': pregnant, 'image1': image1, 'image2': image2,
  };

  factory Animal.fromJson(Map<String, dynamic> j) => Animal(
    j['tag'] ?? '', j['species'] ?? 'Cow', j['breed'] ?? '',
    j['gender'] ?? 'Female', j['weight'] ?? '—', j['status'] ?? 'Active',
    parentId: j['parentId'] ?? '', age: j['age'] ?? '', dob: j['dob'] ?? '',
    pregnancyStart: j['pregnancyStart'] ?? '', dueDate: j['dueDate'] ?? '',
    purchaseDate: j['purchaseDate'] ?? '',
    purchaseAmount: (j['purchaseAmount'] as num?)?.toDouble() ?? 0,
    purchaseSource: j['purchaseSource'] ?? 'Outside Purchase',
    pregnant: j['pregnant'] == true || j['status'] == 'Pregnant',
    image1: j['image1'] ?? '', image2: j['image2'] ?? '',
  );
}

class AnimalAvatar extends StatelessWidget {
  final String type;
  final double size;

  const AnimalAvatar({
    super.key,
    required this.type,
    this.size = 68,
  });

  IconData get icon {
    if (type == 'Cow') {
      return Icons.agriculture_rounded;
    }

    if (type == 'Buffalo') {
      return Icons.water_rounded;
    }

    if (type == 'Goat') {
      return Icons.pets_rounded;
    }

    if (type == 'Sheep') {
      return Icons.cloud_rounded;
    }

    return Icons.child_care_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            green.withAlpha(18),
            green.withAlpha(55),
          ],
        ),
        borderRadius: BorderRadius.circular(
          size * .28,
        ),
      ),
      child: Icon(
        icon,
        color: green,
        size: size * .48,
      ),
    );
  }
}

class AnimalsPage extends StatefulWidget {
  final List<Animal> animals;
  final ValueChanged<Animal> onAdd;
  final ValueChanged<Animal> onDelete;
  final ValueChanged<Animal> onUpdate;
  final Future<void> Function(Animal) onSale;
  final List<HealthRecord> health;
  final ValueChanged<HealthRecord> onAddHealth;
  final List<SpecialExpense> specialExpenses;
  final ValueChanged<SpecialExpense> onAddSpecialExpense;

  const AnimalsPage({
    super.key,
    required this.animals,
    required this.onAdd,
    required this.onDelete,
    required this.onUpdate,
    required this.onSale,
    required this.health,
    required this.onAddHealth,
    required this.specialExpenses,
    required this.onAddSpecialExpense,
  });

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  String filter = 'All';
  String search = '';

  @override
  Widget build(BuildContext context) {
    final shown = widget.animals.where((a) {
      final f = filter == 'All' || a.species == filter;
      final q = search.toLowerCase();

      return f &&
          (q.isEmpty ||
              a.tag.toLowerCase().contains(q) ||
              a.breed.toLowerCase().contains(q) ||
              a.status.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          const Header(
            title: 'Animals',
            subtitle: 'Tags, status, parents and records',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: TextField(
              onChanged: (v) {
                setState(() => search = v);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search Tag / Breed / Status',
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              children: [
                ...[
                  'All',
                  'Cow',
                  'Buffalo',
                  'Goat',
                  'Sheep',
                  'Baby',
                ].map(
                  (x) => Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      label: Text(x),
                      selected: filter == x,
                      onSelected: (_) {
                        setState(() => filter = x);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Text(
              '${shown.length} animals',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (shown.isEmpty)
            const EmptyState(
              icon: Icons.pets_outlined,
              text: 'No animals added yet.',
            ),

          ...shown.map(
            (a) => AnimalListCard(
              animal: a,
              onDelete: () => widget.onDelete(a),
              onUpdate: widget.onUpdate,
              onSale: () => widget.onSale(a),
              animals: widget.animals,
              health: widget.health,
              onAddHealth: widget.onAddHealth,
              specialExpenses: widget.specialExpenses,
              onAddSpecialExpense: widget.onAddSpecialExpense,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final a = await Navigator.push<Animal>(
            context,
            MaterialPageRoute(
              builder: (_) => AddAnimalPage(
                animals: widget.animals,
              ),
            ),
          );

          if (a != null) {
            widget.onAdd(a);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Animal'),
      ),
    );
  }
}

class AnimalListCard extends StatelessWidget {
  final Animal animal;
  final List<Animal> animals;
  final VoidCallback onDelete;
  final ValueChanged<Animal> onUpdate;
  final VoidCallback onSale;
  final List<HealthRecord> health;
  final ValueChanged<HealthRecord> onAddHealth;
  final List<SpecialExpense> specialExpenses;
  final ValueChanged<SpecialExpense> onAddSpecialExpense;

  const AnimalListCard({
    super.key,
    required this.animal,
    required this.animals,
    required this.onDelete,
    required this.onUpdate,
    required this.onSale,
    required this.health,
    required this.onAddHealth,
    required this.specialExpenses,
    required this.onAddSpecialExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        10,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnimalProfilePage(
              animal: animal,
              animals: animals,
              onUpdate: onUpdate,
              health: health,
              onAddHealth: onAddHealth,
              specialExpenses: specialExpenses,
              onAddSpecialExpense: onAddSpecialExpense,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AnimalAvatar(
                type: animal.species,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.tag,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '${animal.species} • ${animal.gender}',
                    ),
                    if (animal.parentId.isNotEmpty)
                      Text(
                        'Parent: ${animal.parentId}',
                      ),
                    Text(
                      'Breed: ${animal.breed.isEmpty ? '—' : animal.breed}',
                    ),
                    Text(
                      'Weight: ${animal.weight}',
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  StatusPill(animal.status),

                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'sold') {
                        onSale();
                      }

                      if (v == 'dead') {
                        animal.status = 'Dead';
                        onUpdate(animal);
                      }

                      if (v == 'active') {
                        animal.status = 'Active';
                        onUpdate(animal);
                      }

                      if (v == 'pregnant') {
                        animal.status = 'Pregnant';
                        animal.pregnancyStart =
                            isoDate(DateTime.now());

                        animal.dueDate = isoDate(
                          DateTime.now().add(
                            const Duration(days: 283),
                          ),
                        );

                        onUpdate(animal);
                      }

                      if (v == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'active',
                        child: Text('Mark Active'),
                      ),
                      PopupMenuItem(
                        value: 'pregnant',
                        child: Text('Mark Pregnant'),
                      ),
                      PopupMenuItem(
                        value: 'sold',
                        child: Text(
                          'Mark Sold + Sale',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'dead',
                        child: Text('Mark Dead'),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String text;

  const StatusPill(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = text == 'Dead'
        ? Colors.red
        : text == 'Sold'
            ? Colors.orange
            : text == 'Pregnant'
                ? Colors.pink
                : green;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: c.withAlpha(25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AddAnimalPage extends StatefulWidget {
  final List<Animal> animals;
  const AddAnimalPage({super.key, required this.animals});
  @override State<AddAnimalPage> createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  final tag = TextEditingController();
  final breed = TextEditingController();
  final weight = TextEditingController();
  final purchaseAmount = TextEditingController();
  String type='Cow', gender='Female', parent='', purchaseDate='', dob='', purchaseSource='Outside Purchase';
  bool pregnant=false;
  String image1='', image2='';
  final picker=ImagePicker();

  @override void dispose(){ tag.dispose(); breed.dispose(); weight.dispose(); purchaseAmount.dispose(); super.dispose(); }

  Future<void> _pickDate(bool baby) async {
    final d=await showDatePicker(context:context, firstDate:DateTime(1990), lastDate:DateTime(2100), initialDate:DateTime.now());
    if(d!=null) setState(()=>baby ? dob=isoDate(d) : purchaseDate=isoDate(d));
  }
  Future<void> _pickImage(int slot) async {
    final x=await picker.pickImage(source:ImageSource.gallery, imageQuality:75, maxWidth:1400);
    if(x==null)return; final b=await x.readAsBytes(); final encoded=base64Encode(b);
    setState(()=>slot==1 ? image1=encoded : image2=encoded);
  }

  @override Widget build(BuildContext context){
    final parents=widget.animals.where((a)=>a.species!='Baby'&&a.gender=='Female'&&a.status!='Dead'&&a.status!='Sold').toList();
    final isBaby=type=='Baby';
    return Scaffold(appBar:AppBar(title:const Text('Add Animal')),body:SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
      _imageRow(), const SizedBox(height:18),
      TextField(controller:tag,decoration:const InputDecoration(labelText:'Tag / ID *')), const SizedBox(height:12),
      DropdownButtonFormField<String>(initialValue:type,decoration:const InputDecoration(labelText:'Animal Type *'),items:['Cow','Buffalo','Goat','Sheep','Baby'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setState(()=>type=v);}),
      if(isBaby)...[const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:parent.isEmpty?null:parent,decoration:const InputDecoration(labelText:'Baby kis animal ka hai? *'),items:parents.map((x)=>DropdownMenuItem(value:x.tag,child:Text('${x.tag} • ${x.species}'))).toList(),onChanged:(v)=>setState(()=>parent=v??'')),const SizedBox(height:12),_dateField('Date of Birth (DOB) *',dob,()=>_pickDate(true))],
      const SizedBox(height:12),TextField(controller:breed,decoration:const InputDecoration(labelText:'Breed')), const SizedBox(height:12),
      DropdownButtonFormField<String>(initialValue:gender,decoration:const InputDecoration(labelText:'Gender'),items:['Female','Male'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setState(()=>gender=v);}),
      const SizedBox(height:12),TextField(controller:weight,decoration:const InputDecoration(labelText:'Weight')),
      if(!isBaby)...[const SizedBox(height:12),_dateField('Purchase Date',purchaseDate,()=>_pickDate(false)),const SizedBox(height:12),TextField(controller:purchaseAmount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Purchase Amount')),const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:purchaseSource,decoration:const InputDecoration(labelText:'Animal Source'),items:const [DropdownMenuItem(value:'Outside Purchase',child:Text('Outside Purchase')),DropdownMenuItem(value:'Farm Born',child:Text('Farm Born / Own Farm Stock'))],onChanged:(v){if(v!=null)setState(()=>purchaseSource=v);}),const SizedBox(height:4),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Pregnant?'),value:pregnant,onChanged:(v)=>setState(()=>pregnant=v))],
      const SizedBox(height:16),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save),label:const Text('Save Animal'))),
    ])));
  }
  Widget _dateField(String label,String value,VoidCallback onTap)=>InkWell(onTap:onTap,child:InputDecorator(decoration:InputDecoration(labelText:label),child:Text(value.isEmpty?'Select date':fmtDate(DateTime.parse(value)))));
  Widget _imageRow()=>Row(mainAxisAlignment:MainAxisAlignment.center,children:[_photo(image1,1),const SizedBox(width:14),_photo(image2,2)]);
  Widget _photo(String data,int slot)=>GestureDetector(onTap:()=>_pickImage(slot),child:Container(width:105,height:105,decoration:BoxDecoration(color:green.withAlpha(18),borderRadius:BorderRadius.circular(22)),child:data.isEmpty?Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.add_a_photo_outlined,color:green,size:30),Text('Photo $slot')]):ClipRRect(borderRadius:BorderRadius.circular(22),child:Image.memory(base64Decode(data),fit:BoxFit.cover))));
  void _save(){final t=tag.text.trim(); if(t.isEmpty){showSimpleDialog(context,'Tag required','Please enter a Tag / ID.');return;} if(widget.animals.any((a)=>a.tag.trim().toLowerCase()==t.toLowerCase())){showSimpleDialog(context,'Duplicate Tag','This Tag / ID is already assigned to another animal.');return;} if(type=='Baby'&&(parent.isEmpty||dob.isEmpty)){showSimpleDialog(context,'Baby details required','Select the parent and Date of Birth.');return;} final amount=double.tryParse(purchaseAmount.text.trim())??0; Navigator.pop(context,Animal(t,type,breed.text.trim(),gender,weight.text.trim().isEmpty?'—':weight.text.trim(),type!='Baby'&&pregnant?'Pregnant':'Active',parentId:parent,dob:dob,purchaseDate:purchaseDate,purchaseAmount:amount,purchaseSource:purchaseSource,pregnant:pregnant,image1:image1,image2:image2));}
}

class AnimalProfilePage extends StatelessWidget {
  final Animal animal; final List<Animal> animals; final ValueChanged<Animal> onUpdate;
  final List<HealthRecord> health; final ValueChanged<HealthRecord> onAddHealth;
  final List<SpecialExpense> specialExpenses; final ValueChanged<SpecialExpense> onAddSpecialExpense;
  const AnimalProfilePage({super.key,required this.animal,required this.animals,required this.onUpdate,required this.health,required this.onAddHealth,required this.specialExpenses,required this.onAddSpecialExpense});

  @override Widget build(BuildContext context){
    final h=health.where((x)=>x.animalTag==animal.tag).toList();
    final e=specialExpenses.where((x)=>x.animalTag==animal.tag).toList();
    return Scaffold(appBar:AppBar(title:Text('${animal.tag} — ${animal.species}'),actions:[IconButton(icon:const Icon(Icons.edit_rounded),tooltip:'Edit Animal',onPressed:() async {final r=await Navigator.push<Animal>(context,MaterialPageRoute(builder:(_)=>EditAnimalPage(animal:animal,animals:animals))); if(r!=null)onUpdate(r);})]),body:ListView(padding:const EdgeInsets.all(18),children:[
      _photos(), const SizedBox(height:12),Text(animal.tag,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900),textAlign:TextAlign.center),const SizedBox(height:10),
      const SectionTitle('Animal Information'), InfoRow('Type',animal.species),InfoRow('Breed',animal.breed),InfoRow('Gender',animal.gender),InfoRow('Weight',animal.weight),InfoRow('Status',animal.status),
      if(animal.parentId.isNotEmpty)InfoRow('Parent',animal.parentId), if(animal.dob.isNotEmpty)InfoRow('Date of Birth',animal.dob),
      if(animal.purchaseDate.isNotEmpty)InfoRow('Purchase Date',animal.purchaseDate), if(animal.species!='Baby')InfoRow('Purchase Amount',money(animal.purchaseAmount)), if(animal.species!='Baby')InfoRow('Source',animal.purchaseSource),
      if(animal.dueDate.isNotEmpty)InfoRow('Pregnancy due',animal.dueDate),
      if(animal.status=='Pregnant')Padding(padding:const EdgeInsets.only(top:12),child:FilledButton.icon(onPressed:(){animal.status='Active';animal.pregnant=false;animal.pregnancyStart='';animal.dueDate='';onUpdate(animal);},icon:const Icon(Icons.check_circle_outline),label:const Text('Mark Pregnancy Completed'))),
      const SizedBox(height:18),
      _childrenHistory(context),
      if(animal.status!='Sold' && animal.status!='Dead') ...[
        _sectionTitle(context,'Health & Medical',Icons.medical_services_outlined,()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>HealthPage(animals:[animal],records:h,onAdd:onAddHealth)))),
        if(h.isEmpty)const EmptyState(icon:Icons.medical_services_outlined,text:'No medical records for this animal.') else ...h.map((r)=>Card(child:ListTile(leading:const Icon(Icons.medical_services_outlined,color:green),title:Text(r.type,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${fmtDate(DateTime.tryParse(r.date)??DateTime.now())}${r.notes.isEmpty?'':' • ${r.notes}'}')))),
      ],
      const SizedBox(height:18), _sectionTitle(context,'Special Expenses',Icons.payments_outlined,()=>_addExpense(context)),
      if(e.isEmpty)const EmptyState(icon:Icons.payments_outlined,text:'No special expenses for this animal.') else ...e.map((r)=>Card(child:ListTile(leading:const Icon(Icons.payments_outlined),title:Text('${r.title} • ${money(r.amount)}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${fmtDate(DateTime.tryParse(r.date)??DateTime.now())}${r.notes.isEmpty?'':' • ${r.notes}'}')))),
    ]));
  }
  Widget _childrenHistory(BuildContext context) {
    final children = animals.where((x) => x.parentId.toLowerCase() == animal.tag.toLowerCase()).toList();
    final total = children.length;
    final sold = children.where((x) => x.status == 'Sold').length;
    final dead = children.where((x) => x.status == 'Dead').length;
    final active = children.where((x) => x.status != 'Sold' && x.status != 'Dead').length;
    final farmBorn = children.where((x) => x.purchaseSource == 'Farm Born').length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('Offspring / Family History'),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total children: $total', style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Active / remaining: $active  •  Sold: $sold  •  Dead: $dead'),
        Text('Farm-born children added with their own tag: $farmBorn'),
      ]))),
      if (children.isNotEmpty) ...children.map((c) => Card(child: ListTile(leading: const Icon(Icons.child_care_outlined), title: Text(c.tag, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${c.species} • ${c.gender} • ${c.status}${c.dob.isEmpty ? '' : ' • DOB ${c.dob}'}${c.purchaseSource == 'Farm Born' ? ' • Farm Born' : ''}')))),
    ]);
  }

  Widget _photos()=>Row(mainAxisAlignment:MainAxisAlignment.center,children:[_onePhoto(animal.image1,1),const SizedBox(width:12),_onePhoto(animal.image2,2)]);
  Widget _onePhoto(String d,int n)=>Container(width:125,height:125,decoration:BoxDecoration(color:green.withAlpha(18),borderRadius:BorderRadius.circular(24)),child:d.isEmpty?Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.pets_outlined,color:green,size:34),Text('Photo $n')]):ClipRRect(borderRadius:BorderRadius.circular(24),child:Image.memory(base64Decode(d),fit:BoxFit.cover)));
  Widget _sectionTitle(BuildContext c,String title,IconData icon,VoidCallback add)=>Row(children:[Expanded(child:SectionTitle(title)),IconButton(onPressed:add,icon:Icon(Icons.add_circle_rounded,color:green),tooltip:'Add $title')]);
  Future<void> _addExpense(BuildContext context) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    final notes = TextEditingController();
    DateTime date = dateOnly(DateTime.now());

    final result = await showDialog<SpecialExpense>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Add Special Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Expense title *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notes,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(fmtDate(date)),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) {
                        setDialogState(() => date = dateOnly(picked));
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final parsedAmount = double.tryParse(amount.text.trim());
                  if (title.text.trim().isEmpty || parsedAmount == null) return;
                  Navigator.pop(
                    dialogContext,
                    SpecialExpense(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      animalTag: animal.tag,
                      date: isoDate(date),
                      title: title.text.trim(),
                      amount: parsedAmount,
                      notes: notes.text.trim(),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    title.dispose();
    amount.dispose();
    notes.dispose();
    if (result != null) onAddSpecialExpense(result);
  }
}

class EditAnimalPage extends StatefulWidget {
  final Animal animal; final List<Animal> animals;
  const EditAnimalPage({super.key,required this.animal,required this.animals});
  @override State<EditAnimalPage> createState()=>_EditAnimalPageState();
}
class _EditAnimalPageState extends State<EditAnimalPage>{
  late TextEditingController tag,breed,weight,purchaseAmount; late String type,gender,parent,purchaseDate,dob,purchaseSource; late bool pregnant; late String image1,image2; final picker=ImagePicker();
  @override void initState(){super.initState();final a=widget.animal;tag=TextEditingController(text:a.tag);breed=TextEditingController(text:a.breed);weight=TextEditingController(text:a.weight);purchaseAmount=TextEditingController(text:a.purchaseAmount==0?'':money(a.purchaseAmount));type=a.species;gender=a.gender;parent=a.parentId;purchaseDate=a.purchaseDate;dob=a.dob;purchaseSource=a.purchaseSource;pregnant=a.pregnant||a.status=='Pregnant';image1=a.image1;image2=a.image2;}
  @override void dispose(){tag.dispose();breed.dispose();weight.dispose();purchaseAmount.dispose();super.dispose();}
  Future<void> _pickDate(bool baby)async{final d=await showDatePicker(context:context,firstDate:DateTime(1990),lastDate:DateTime(2100),initialDate:DateTime.tryParse(baby?dob:purchaseDate)??DateTime.now());if(d!=null)setState(()=>baby?dob=isoDate(d):purchaseDate=isoDate(d));}
  Future<void> _pickImage(int slot)async{final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:75,maxWidth:1400);if(x==null)return;final b=await x.readAsBytes();setState(()=>slot==1?image1=base64Encode(b):image2=base64Encode(b));}
  @override Widget build(BuildContext context){final parents=widget.animals.where((a)=>a.tag!=widget.animal.tag&&a.species!='Baby'&&a.gender=='Female'&&a.status!='Dead'&&a.status!='Sold').toList();final isBaby=type=='Baby';return Scaffold(appBar:AppBar(title:const Text('Edit Animal')),body:ListView(padding:const EdgeInsets.all(18),children:[Row(mainAxisAlignment:MainAxisAlignment.center,children:[_photo(image1,1),const SizedBox(width:12),_photo(image2,2)]),const SizedBox(height:16),TextField(controller:tag,decoration:const InputDecoration(labelText:'Tag / ID *')),const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:type,decoration:const InputDecoration(labelText:'Animal Type *'),items:['Cow','Buffalo','Goat','Sheep','Baby'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setState(()=>type=v);}),if(isBaby)...[const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:parent.isEmpty?null:parent,decoration:const InputDecoration(labelText:'Parent'),items:parents.map((x)=>DropdownMenuItem(value:x.tag,child:Text('${x.tag} • ${x.species}'))).toList(),onChanged:(v)=>setState(()=>parent=v??'')),const SizedBox(height:12),_date('Date of Birth',dob,()=>_pickDate(true))],const SizedBox(height:12),TextField(controller:breed,decoration:const InputDecoration(labelText:'Breed')),const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:gender,decoration:const InputDecoration(labelText:'Gender'),items:['Female','Male'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setState(()=>gender=v);}),const SizedBox(height:12),TextField(controller:weight,decoration:const InputDecoration(labelText:'Weight')),if(!isBaby)...[const SizedBox(height:12),_date('Purchase Date',purchaseDate,()=>_pickDate(false)),const SizedBox(height:12),TextField(controller:purchaseAmount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Purchase Amount')),const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:purchaseSource,decoration:const InputDecoration(labelText:'Animal Source'),items:const [DropdownMenuItem(value:'Outside Purchase',child:Text('Outside Purchase')),DropdownMenuItem(value:'Farm Born',child:Text('Farm Born / Own Farm Stock'))],onChanged:(v){if(v!=null)setState(()=>purchaseSource=v);}),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Pregnant?'),value:pregnant,onChanged:(v)=>setState(()=>pregnant=v))],const SizedBox(height:16),FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save),label:const Text('Save Changes'))]));}
  Widget _date(String l,String v,VoidCallback f)=>InkWell(onTap:f,child:InputDecorator(decoration:InputDecoration(labelText:l),child:Text(v.isEmpty?'Select date':fmtDate(DateTime.parse(v)))));
  Widget _photo(String d,int n)=>GestureDetector(onTap:()=>_pickImage(n),child:Container(width:105,height:105,decoration:BoxDecoration(color:green.withAlpha(18),borderRadius:BorderRadius.circular(22)),child:d.isEmpty?Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.add_a_photo_outlined,color:green),Text('Photo $n')]):ClipRRect(borderRadius:BorderRadius.circular(22),child:Image.memory(base64Decode(d),fit:BoxFit.cover))));
  void _save(){final t=tag.text.trim();if(t.isEmpty)return;if(widget.animals.any((a)=>a!=widget.animal&&a.tag.trim().toLowerCase()==t.toLowerCase())){showSimpleDialog(context,'Duplicate Tag','This Tag / ID is already assigned to another animal.');return;}final amount=double.tryParse(purchaseAmount.text.trim())??0;widget.animal.tag=t;widget.animal.species=type;widget.animal.breed=breed.text.trim();widget.animal.gender=gender;widget.animal.weight=weight.text.trim().isEmpty?'—':weight.text.trim();widget.animal.parentId=parent;widget.animal.dob=dob;widget.animal.purchaseDate=purchaseDate;widget.animal.purchaseAmount=amount;widget.animal.purchaseSource=purchaseSource;widget.animal.image1=image1;widget.animal.image2=image2;widget.animal.pregnant=pregnant;if(type!='Baby'&&widget.animal.status!='Sold'&&widget.animal.status!='Dead'){widget.animal.status=pregnant?'Pregnant':'Active';if(pregnant){widget.animal.pregnancyStart=isoDate(DateTime.now());widget.animal.dueDate=isoDate(DateTime.now().add(const Duration(days:283)));}else{widget.animal.pregnancyStart='';widget.animal.dueDate='';}}Navigator.pop(context,widget.animal);}
}

class InfoRow extends StatelessWidget {
  final String a;
  final String b;

  const InfoRow(
    this.a,
    this.b, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(a),
        trailing: Flexible(
          child: Text(
            b.isEmpty ? '—' : b,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class MilkPage extends StatefulWidget {
  final List<MilkRecord> records;
  final ValueChanged<MilkRecord> onAdd;
  const MilkPage({super.key, required this.records, required this.onAdd});
  @override State<MilkPage> createState() => _MilkPageState();
}

class _MilkPageState extends State<MilkPage> {
  final liters = TextEditingController();
  final price = TextEditingController();
  final animal = TextEditingController();
  DateTime date = dateOnly(DateTime.now());
  String session = 'Morning';
  @override void dispose(){ liters.dispose(); price.dispose(); animal.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final total = widget.records.fold<double>(0,(s,r)=>s+r.liters);
    final today = widget.records.where((r)=>r.date==isoDate(DateTime.now())).fold<double>(0,(s,r)=>s+r.liters);
    return Scaffold(body: ListView(padding: const EdgeInsets.only(bottom:30), children:[
      const Header(title:'Milk Management',subtitle:'Live daily production & milk income'),
      Padding(padding:const EdgeInsets.symmetric(horizontal:18),child:Row(children:[
        Expanded(child:MetricCard(title:"Today's",value:'${today.toStringAsFixed(1)} L',icon:Icons.local_drink_rounded,color:green)),
        const SizedBox(width:12),Expanded(child:MetricCard(title:'Total',value:'${total.toStringAsFixed(1)} L',icon:Icons.water_drop_rounded,color:Colors.blue)),
      ])),
      const SectionTitle('Add milk record'),
      Padding(padding:const EdgeInsets.symmetric(horizontal:18),child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
        TextField(controller:liters,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Milk quantity (litres) *')),
        const SizedBox(height:10),
        TextField(controller:price,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Milk income amount (optional)')),
        const SizedBox(height:10),
        TextField(controller:animal,decoration:const InputDecoration(labelText:'Animal tag (optional)')),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(initialValue:session,decoration:const InputDecoration(labelText:'Session'),items:const [DropdownMenuItem(value:'Morning',child:Text('Morning')),DropdownMenuItem(value:'Evening',child:Text('Evening')),DropdownMenuItem(value:'Other',child:Text('Other'))],onChanged:(v){if(v!=null)setState(()=>session=v);}),
        const SizedBox(height:10),
        ListTile(contentPadding:EdgeInsets.zero,title:const Text('Date'),subtitle:Text(fmtDate(date)),trailing:const Icon(Icons.calendar_month),onTap:()async{final d=await showDatePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime(2100),initialDate:date);if(d!=null)setState(()=>date=dateOnly(d));}),
        const SizedBox(height:6),
        SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:(){final l=double.tryParse(liters.text.trim());if(l==null||l<=0)return;final a=double.tryParse(price.text.trim())??0;widget.onAdd(MilkRecord(id:DateTime.now().microsecondsSinceEpoch.toString(),date:isoDate(date),liters:l,price:a,animalTag:animal.text.trim(),session:session));liters.clear();price.clear();animal.clear();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Milk record added and linked to Finance')));},icon:const Icon(Icons.add_chart_rounded),label:const Text('Add Milk'))),
      ]))),),
      const SectionTitle('Live milk records'),
      ...widget.records.map((r)=>Card(margin:const EdgeInsets.symmetric(horizontal:18,vertical:5),child:ListTile(leading:const CircleAvatar(child:Icon(Icons.local_drink_rounded)),title:Text('${r.liters.toStringAsFixed(1)} L • ${r.session}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${fmtDate(DateTime.tryParse(r.date)??DateTime.now())}${r.animalTag.isEmpty?'':' • ${r.animalTag}'}'),trailing:r.price>0?Text(money(r.price),style:const TextStyle(fontWeight:FontWeight.w900)):null))),
    ]));
  }
}

class MilkRecord {
  final String id,date,animalTag,session; final double liters,price;
  MilkRecord({required this.id,required this.date,required this.liters,required this.price,required this.animalTag,required this.session});
  Map<String,dynamic> toJson()=>{'id':id,'date':date,'liters':liters,'price':price,'animalTag':animalTag,'session':session};
  factory MilkRecord.fromJson(Map<String,dynamic> j)=>MilkRecord(id:j['id']??'',date:j['date']??isoDate(DateTime.now()),liters:(j['liters'] as num?)?.toDouble()??0,price:(j['price'] as num?)?.toDouble()??0,animalTag:j['animalTag']??'',session:j['session']??'Morning');
}

const incomeCategories = [
  'Milk',
  'Sale',
];

const expenseCategories = [
  'Feed',
  'Medicine',
  'Purchase',
  'Petty Cash',
  'Utility',
  'Salary',
  'Special Expense',
];

class FinanceRecord {
  final String id;
  final String date;
  final String type;
  final String category;
  final double amount;
  final String notes;

  FinanceRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.notes,
  });

  DateTime get dateTime =>
      DateTime.tryParse(date) ?? DateTime(2000);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'category': category,
      'amount': amount,
      'notes': notes,
    };
  }

  factory FinanceRecord.fromJson(
    Map<String, dynamic> j,
  ) {
    return FinanceRecord(
      id: j['id'] ?? '',
      date: j['date'] ??
          isoDate(DateTime.now()),
      type: j['type'] ?? 'Expense',
      category: j['category'] ?? 'Feed',
      amount: (j['amount'] as num?)
              ?.toDouble() ??
          0,
      notes: j['notes'] ?? '',
    );
  }
}

class FinancePage extends StatefulWidget {
  final List<FinanceRecord> records;
  final ValueChanged<FinanceRecord> onAdd;

  const FinancePage({
    super.key,
    required this.records,
    required this.onAdd,
  });

  @override
  State<FinancePage> createState() =>
      _FinancePageState();
}

class _FinancePageState
    extends State<FinancePage> {
  String type = 'Expense';
  String category = 'Feed';

  final amount = TextEditingController();
  final notes = TextEditingController();

  DateTime date = dateOnly(DateTime.now());

  @override
  void dispose() {
    amount.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final income = widget.records
        .where((x) => x.type == 'Income')
        .fold<double>(
          0,
          (s, x) => s + x.amount,
        );

    final expense = widget.records
        .where((x) => x.type == 'Expense')
        .fold<double>(
          0,
          (s, x) => s + x.amount,
        );

    final cats = type == 'Income'
        ? incomeCategories
        : expenseCategories;

    if (!cats.contains(category)) {
      category = cats.first;
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          const Header(
            title: 'Finance',
            subtitle:
                'Income, expenses, sales and purchases',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: LayoutBuilder(
              builder: (c, b) {
                final w =
                    (b.maxWidth - 24) / 3;

                return Row(
                  children: [
                    SizedBox(
                      width: w,
                      child: MetricCard(
                        title: 'Income',
                        value: money(income),
                        icon:
                            Icons.arrow_upward_rounded,
                        color: green,
                      ),
                    ),

                    const SizedBox(width: 12),

                    SizedBox(
                      width: w,
                      child: MetricCard(
                        title: 'Expenses',
                        value: money(expense),
                        icon:
                            Icons.arrow_downward_rounded,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(width: 12),

                    SizedBox(
                      width: w,
                      child: MetricCard(
                        title: 'Net',
                        value:
                            money(income - expense),
                        icon: Icons
                            .account_balance_wallet_rounded,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          const SectionTitle(
            'Add transaction',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration:
                          const InputDecoration(
                        labelText: 'Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Income',
                          child: Text('Income'),
                        ),
                        DropdownMenuItem(
                          value: 'Expense',
                          child: Text('Expense'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            type = v;
                            category = v == 'Income'
                                ? 'Milk'
                                : 'Feed';
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration:
                          const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: cats
                          .map(
                            (x) => DropdownMenuItem(
                              value: x,
                              child: Text(x),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(
                            () => category = v,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: amount,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Amount *',
                      ),
                    ),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () async {
                        final d =
                            await showDatePicker(
                          context: context,
                          firstDate:
                              DateTime(2000),
                          lastDate:
                              DateTime(2100),
                          initialDate: date,
                        );

                        if (d != null) {
                          setState(
                            () => date =
                                dateOnly(d),
                          );
                        }
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText: 'Date',
                        ),
                        child:
                            Text(fmtDate(date)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: notes,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(
                        labelText: 'Notes',
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed: _saveRecord,
                        icon: const Icon(
                          Icons.save_rounded,
                        ),
                        label: const Text(
                          'Save Transaction',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          SectionTitle(
            'Saved transactions',
            action:
                '${widget.records.length}',
          ),

          if (widget.records.isEmpty)
            const EmptyState(
              icon:
                  Icons.receipt_long_outlined,
              text:
                  'No finance records saved yet.',
            )
          else
            ...widget.records.map(
              (r) => RecordTile(
                icon: r.type == 'Income'
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                title: r.category,
                subtitle:
                    '${r.type} • ${fmtDate(r.dateTime)}${r.notes.isEmpty ? '' : ' • ${r.notes}'}',
                trailing:
                    '${r.type == 'Income' ? '+' : '-'} ${money(r.amount)}',
              ),
            ),
        ],
      ),
    );
  }

  void _saveRecord() {
    final v =
        double.tryParse(amount.text.trim());

    if (v == null || v <= 0) {
      showSimpleDialog(
        context,
        'Amount required',
        'Enter a valid amount.',
      );
      return;
    }

    final r = FinanceRecord(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      date: isoDate(date),
      type: type,
      category: category,
      amount: v,
      notes: notes.text.trim(),
    );

    widget.onAdd(r);

    amount.clear();
    notes.clear();

    setState(() {
      date = dateOnly(DateTime.now());
    });

    showSimpleDialog(
      context,
      'Saved',
      '${r.type} • ${r.category} • ${money(r.amount)} saved successfully.',
    );
  }
}

class RecordTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  const RecordTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: green.withAlpha(25),
          child: Icon(
            icon,
            color: green,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          trailing,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class SpecialExpense {
  final String id, animalTag, date, title, notes;
  final double amount;
  SpecialExpense({required this.id,required this.animalTag,required this.date,required this.title,required this.amount,required this.notes});
  Map<String,dynamic> toJson()=>{'id':id,'animalTag':animalTag,'date':date,'title':title,'amount':amount,'notes':notes};
  factory SpecialExpense.fromJson(Map<String,dynamic> j)=>SpecialExpense(id:j['id']??'',animalTag:j['animalTag']??'',date:j['date']??isoDate(DateTime.now()),title:j['title']??'Expense',amount:(j['amount'] as num?)?.toDouble()??0,notes:j['notes']??'');
}

class HealthRecord {
  final String id;
  final String animalTag;
  final String date;
  final String type;
  final String notes;

  HealthRecord({
    required this.id,
    required this.animalTag,
    required this.date,
    required this.type,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalTag': animalTag,
      'date': date,
      'type': type,
      'notes': notes,
    };
  }

  factory HealthRecord.fromJson(
    Map<String, dynamic> j,
  ) {
    return HealthRecord(
      id: j['id'] ?? '',
      animalTag: j['animalTag'] ?? '',
      date: j['date'] ??
          isoDate(DateTime.now()),
      type: j['type'] ?? 'Checkup',
      notes: j['notes'] ?? '',
    );
  }
}

class HealthPage extends StatefulWidget {
  final List<Animal> animals;
  final List<HealthRecord> records;
  final ValueChanged<HealthRecord> onAdd;

  const HealthPage({
    super.key,
    required this.animals,
    required this.records,
    required this.onAdd,
  });

  @override
  State<HealthPage> createState() =>
      _HealthPageState();
}

class _HealthPageState
    extends State<HealthPage> {
  String animal = '';
  String type = 'Checkup';

  final notes = TextEditingController();

  DateTime date = dateOnly(DateTime.now());

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical & Health',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Add a health record',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue:
                animal.isEmpty ? null : animal,
            decoration: const InputDecoration(
              labelText: 'Animal Tag *',
            ),
            items: widget.animals
                .where((a) => a.status != 'Sold' && a.status != 'Dead')
                .map(
                  (a) => DropdownMenuItem(
                    value: a.tag,
                    child: Text(
                      '${a.tag} • ${a.species}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(
                () => animal = v ?? '',
              );
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(
              labelText: 'Record type',
            ),
            items: const [
              'Checkup',
              'Vaccination',
              'Medicine',
              'Injury',
              'Other',
            ]
                .map(
                  (x) => DropdownMenuItem(
                    value: x,
                    child: Text(x),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => type = v);
              }
            },
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: date,
              );

              if (d != null) {
                setState(
                  () => date = dateOnly(d),
                );
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
              ),
              child: Text(fmtDate(date)),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText:
                  'Notes / medicine / vaccine',
            ),
          ),

          const SizedBox(height: 14),

          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(
              Icons.save_rounded,
            ),
            label: const Text(
              'Save Health Record',
            ),
          ),

          const SizedBox(height: 22),

          const SectionTitle(
            'Health history',
          ),

          if (widget.records.isEmpty)
            const EmptyState(
              icon: Icons
                  .medical_services_outlined,
              text:
                  'No medical records yet.',
            )
          else
            ...widget.records.where((r) {
              final a = widget.animals.cast<Animal?>().firstWhere((a) => a?.tag == r.animalTag, orElse: () => null);
              return a == null || (a.status != 'Sold' && a.status != 'Dead');
            }).map(
              (r) => Card(
                margin: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.medical_services_outlined,
                    color: green,
                  ),
                  title: Text(
                    '${r.animalTag} • ${r.type}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${fmtDate(DateTime.tryParse(r.date) ?? DateTime.now())}${r.notes.isEmpty ? '' : ' • ${r.notes}'}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _save() {
    if (animal.isEmpty) {
      showSimpleDialog(
        context,
        'Animal required',
        'Select an animal first.',
      );
      return;
    }

    widget.onAdd(
      HealthRecord(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        animalTag: animal,
        date: isoDate(date),
        type: type,
        notes: notes.text.trim(),
      ),
    );

    notes.clear();

    showSimpleDialog(
      context,
      'Saved',
      'Health record saved successfully.',
    );
  }
}

class BreedingPage extends StatefulWidget {
  final List<Animal> animals;
  final ValueChanged<Animal> onUpdate;

  const BreedingPage({
    super.key,
    required this.animals,
    required this.onUpdate,
  });

  @override
  State<BreedingPage> createState() =>
      _BreedingPageState();
}

class _BreedingPageState
    extends State<BreedingPage> {
  @override
  Widget build(BuildContext context) {
    final females = widget.animals
        .where(
          (a) =>
              a.gender == 'Female' &&
              a.species != 'Baby' &&
              a.status != 'Dead' &&
              a.status != 'Sold',
        )
        .toList();

    final pregnant =
        females.where(
          (a) => a.status == 'Pregnant',
        ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Breeding & Pregnancy',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Pregnancy tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Mark a female as pregnant and the expected date is calculated automatically.',
          ),

          const SizedBox(height: 18),

          if (pregnant.isEmpty)
            const EmptyState(
              icon:
                  Icons.favorite_border_rounded,
              text:
                  'No pregnant animals right now.',
            ),

          ...pregnant.map(
            (a) => Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.favorite,
                  color: Colors.pink,
                ),
                title: Text(
                  a.tag,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  'Due: ${a.dueDate.isEmpty ? '—' : a.dueDate}',
                ),
                trailing: IconButton(
                  tooltip: 'Complete',
                  onPressed: () {
                    a.status = 'Active';
                    a.pregnancyStart = '';
                    a.dueDate = '';

                    widget.onUpdate(a);

                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const SectionTitle(
            'Start pregnancy',
          ),

          ...females
              .where(
                (a) => a.status != 'Pregnant',
              )
              .map(
                (a) => Card(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: ListTile(
                    title: Text(a.tag),
                    subtitle: Text(a.species),
                    trailing: FilledButton(
                      onPressed: () {
                        a.status = 'Pregnant';
                        a.pregnancyStart =
                            isoDate(
                          DateTime.now(),
                        );

                        a.dueDate = isoDate(
                          DateTime.now().add(
                            const Duration(
                              days: 283,
                            ),
                          ),
                        );

                        widget.onUpdate(a);

                        setState(() {});
                      },
                      child: const Text(
                        'Pregnant',
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final List<Animal> animals;
  final List<FinanceRecord> finance;
  final List<HealthRecord> health;
  final String farmName;
  final ValueChanged<String> onFarmNameChanged;
  final bool dark;
  final VoidCallback onThemeChanged;
  final VoidCallback onHealth;
  final VoidCallback onBreeding;

  const MorePage({
    super.key,
    required this.animals,
    required this.finance,
    required this.health,
    required this.farmName,
    required this.onFarmNameChanged,
    required this.dark,
    required this.onThemeChanged,
    required this.onHealth,
    required this.onBreeding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        bottom: 30,
      ),
      children: [
        const Header(
          title: 'More',
          subtitle:
              'Reports, medical, breeding and settings',
        ),

        const SectionTitle(
          'Farm tools',
        ),

        ReportCard(
          title: 'Medical & Health',
          subtitle:
              '${health.length} saved health records',
          icon:
              Icons.medical_services_outlined,
          onTap: onHealth,
        ),

        ReportCard(
          title: 'Breeding & Pregnancy',
          subtitle:
              'Track pregnancy and expected dates',
          icon:
              Icons.favorite_border_rounded,
          onTap: onBreeding,
        ),

        const SectionTitle(
          'Reports',
        ),

        ReportCard(
          title: 'Finance Report',
          subtitle:
              'Income and expense transactions',
          icon: Icons
              .account_balance_wallet_rounded,
          onTap: () =>
              _report(context, 'finance'),
        ),

        ReportCard(
          title: 'Sales Report',
          subtitle:
              'Sales / income records',
          icon: Icons.sell_rounded,
          onTap: () =>
              _report(context, 'sales'),
        ),

        ReportCard(
          title: 'Purchase Report',
          subtitle:
              'Purchase expense records',
          icon:
              Icons.shopping_cart_rounded,
          onTap: () =>
              _report(context, 'purchases'),
        ),

        ReportCard(
          title: 'Animals Report',
          subtitle:
              'Tags, status, parents and details',
          icon: Icons.pets_rounded,
          onTap: () =>
              _report(context, 'animals'),
        ),

        const SectionTitle(
          'Settings',
        ),

        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: ListTile(
            leading: const Icon(
              Icons.business_rounded,
            ),
            title: const Text(
              'Farm name',
            ),
            subtitle: Text(
              farmName.isEmpty
                  ? 'Not set'
                  : farmName,
            ),
            trailing: const Icon(
              Icons.edit_rounded,
            ),
            onTap: () =>
                _editFarmName(context),
          ),
        ),

        const SizedBox(height: 10),

        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: SwitchListTile(
            secondary: Icon(
              dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            title: const Text(
              'Dark mode',
            ),
            subtitle: const Text(
              'Switch the app appearance',
            ),
            value: dark,
            onChanged: (_) =>
                onThemeChanged(),
          ),
        ),
      ],
    );
  }

  Future<void> _editFarmName(
    BuildContext c,
  ) async {
    final ctl =
        TextEditingController(text: farmName);

    await showDialog(
      context: c,
      builder: (d) => AlertDialog(
        title: const Text(
          'Farm name',
        ),
        content: TextField(
          controller: ctl,
          decoration:
              const InputDecoration(
            labelText: 'Farm name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(d),
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () {
              onFarmNameChanged(
                ctl.text.trim(),
              );
              Navigator.pop(d);
            },
            child: const Text(
              'Save',
            ),
          ),
        ],
      ),
    );

    ctl.dispose();
  }

  Future<void> _report(
    BuildContext c,
    String kind,
  ) async {
    final range =
        await pickReportRange(c);

    if (range == null) return;

    final rows = kind == 'animals'
        ? animalRows(animals)
        : financeRows(
            finance,
            kind,
            range.start,
            range.end,
          );

    final title = kind == 'sales'
        ? 'Sales Report'
        : kind == 'purchases'
            ? 'Purchase Report'
            : kind == 'animals'
                ? 'Animals Report'
                : 'Finance Report';

    if (!c.mounted) return;

    await showReportOptions(
      c,
      title,
      rows,
      farmName,
      range,
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              green.withAlpha(25),
          child: Icon(
            icon,
            color: green,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
        onTap: onTap,
      ),
    );
  }
}

class DateRangeValue {
  final DateTime start;
  final DateTime end;

  DateRangeValue(
    this.start,
    this.end,
  );
}

Future<DateRangeValue?> pickReportRange(
  BuildContext context,
) async {
  final today =
      dateOnly(DateTime.now());

  final start = await showDatePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: today,
    initialDate: today,
  );

  if (start == null ||
      !context.mounted) {
    return null;
  }

  final end = await showDatePicker(
    context: context,
    firstDate: start,
    lastDate: DateTime(2100),
    initialDate: start,
  );

  if (end == null) return null;

  return DateRangeValue(
    start,
    end,
  );
}

List<List<String>> financeRows(
  List<FinanceRecord> all,
  String kind,
  DateTime start,
  DateTime end,
) {
  final e = dateOnly(end);

  final rows = <List<String>>[
    [
      'Date',
      'Type',
      'Category',
      'Amount',
      'Notes',
    ],
  ];

  for (final r in all) {
    final d = dateOnly(r.dateTime);

    if (d.isBefore(dateOnly(start)) ||
        d.isAfter(e)) {
      continue;
    }

    if (kind == 'sales' &&
        !(r.type == 'Income' &&
            r.category == 'Sale')) {
      continue;
    }

    if (kind == 'purchases' &&
        !(r.type == 'Expense' &&
            r.category == 'Purchase')) {
      continue;
    }

    rows.add([
      fmtDate(r.dateTime),
      r.type,
      r.category,
      money(r.amount),
      r.notes,
    ]);
  }

  return rows;
}

List<List<String>> animalRows(
  List<Animal> a,
) {
  return [
    [
      'Tag',
      'Type',
      'Breed',
      'Gender',
      'Weight',
      'Status',
      'Parent',
      'Age',
      'Pregnancy Due',
    ],
    ...a.map(
      (x) => [
        x.tag,
        x.species,
        x.breed,
        x.gender,
        x.weight,
        x.status,
        x.parentId,
        x.age,
        x.dueDate,
      ],
    ),
  ];
}

Future<void> showReportOptions(
  BuildContext context,
  String title,
  List<List<String>> rows,
  String farmName,
  DateRangeValue range,
) async {
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(c)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 6),

            Text(
              'From ${fmtDate(range.start)} to ${fmtDate(range.end)}',
            ),

            const SizedBox(height: 14),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(c);

                exportExcel(
                  title,
                  rows,
                  farmName,
                  range,
                );
              },
              icon: const Icon(
                Icons.table_chart_rounded,
              ),
              label: const Text(
                'Generate Excel',
              ),
            ),

            const SizedBox(height: 9),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(c);

                exportPdf(
                  title,
                  rows,
                  farmName,
                  range,
                );
              },
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
              ),
              label: const Text(
                'Generate PDF',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> exportExcel(
  String title,
  List<List<String>> rows,
  String farmName,
  DateRangeValue range,
) async {
  final excel = Excel.createExcel();
  final sheet = excel['Report'];

  final header = <String>[
    farmName.isEmpty
        ? 'My Farm'
        : farmName,
    title,
    'Period: ${fmtDate(range.start)} to ${fmtDate(range.end)}',
    'Generated: ${fmtDate(DateTime.now())}',
  ];

  for (var i = 0;
      i < header.length;
      i++) {
    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: i,
          ),
        )
        .value = TextCellValue(
      header[i],
    );
  }

  for (var r = 0;
      r < rows.length;
      r++) {
    for (var c = 0;
        c < rows[r].length;
        c++) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: c,
              rowIndex: r + 5,
            ),
          )
          .value = TextCellValue(
        rows[r][c],
      );
    }
  }

  final bytes = excel.encode();

  if (bytes == null) return;

  await downloadBytes(
    Uint8List.fromList(bytes),
    '${safeFile(title)}.xlsx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
}

Future<void> exportPdf(
  String title,
  List<List<String>> rows,
  String farmName,
  DateRangeValue range,
) async {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat:
            PdfPageFormat.a4.landscape,
        margin:
            const pw.EdgeInsets.all(24),
      ),
      build: (_) => [
        pw.Text(
          farmName.isEmpty
              ? 'My Farm'
              : farmName,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 4),

        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),

        pw.Text(
          'From: ${fmtDate(range.start)}    To: ${fmtDate(range.end)}',
        ),

        pw.Text(
          'Generated: ${fmtDate(DateTime.now())}',
        ),

        pw.SizedBox(height: 12),

        if (rows.length == 1)
          pw.Text(
            'No records found for this period.',
          )
        else
          pw.Table.fromTextArray(
            headers: rows.first,
            data: rows.skip(1).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 7,
              fontWeight:
                  pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(
              fontSize: 7,
            ),
            cellPadding:
                const pw.EdgeInsets.all(4),
            border:
                pw.TableBorder.all(
              color: PdfColors.grey300,
            ),
          ),
      ],
    ),
  );

  final bytes = await doc.save();

  await downloadBytes(
    Uint8List.fromList(bytes),
    '${safeFile(title)}.pdf',
    'application/pdf',
  );
}

Future<void> showSimpleDialog(
  BuildContext context,
  String title,
  String message,
) =>
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () =>
                Navigator.pop(c),
            child: const Text('OK'),
          ),
        ],
      ),
    );
