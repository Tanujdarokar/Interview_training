import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_providers.dart';
import 'ats_checker_screen.dart';
import 'coding_list_screen.dart';
import 'resume_maker_screen.dart';
import 'todo_list_screen.dart';
import 'settings_screen.dart';
import 'notebook_screen.dart';
import 'pending_work_screen.dart';
import 'reminder_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [const DashboardView(), const SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.indigo.shade50,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, "Dashboard"),
              _buildNavItem(1, Icons.settings_rounded, "Settings"),
            ],
          ),
        ),
      ).animate().slideY(
            begin: 1,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOutQuint,
          ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.indigo : Colors.grey.shade400,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedProgressPeriod = 'Day'; // 'Day', 'Month', 'Year'
  int _trendOffset = 0; // 0 for current week, 1 for previous, etc.

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  static const List<Map<String, dynamic>> _features = [
    {'title': 'Coding Challenges', 'icon': Icons.code, 'color': Colors.orange},
    {'title': 'Resume Maker', 'icon': Icons.description, 'color': Colors.green},
    {'title': 'ATS Checker', 'icon': Icons.analytics, 'color': Colors.purple},
    {
      'title': 'To-Do List',
      'icon': Icons.checklist_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'Notebook',
      'icon': Icons.note_alt_outlined,
      'color': Colors.teal,
    },
    {
      'title': 'Feedback',
      'icon': Icons.feedback_outlined,
      'color': Colors.amber,
    },
    {
      'title': 'Pending Work',
      'icon': Icons.pending_actions_rounded,
      'color': Colors.redAccent,
    },
    {'title': 'Reminders', 'icon': Icons.alarm, 'color': Colors.blueGrey},
  ];

  bool _isDayActive(DateTime day, List<DateTime> history) {
    return history.any((d) => isSameDay(d, day));
  }

  void _showReminderPicker() async {
    final TextEditingController labelController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    // Default to 5 minutes from now to avoid "past time" error on immediate submit
    DateTime nowPlusFive = DateTime.now().add(const Duration(minutes: 5));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(nowPlusFive);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.alarm_add, color: Colors.indigo),
              SizedBox(width: 12),
              Text(
                "Set Reminder",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What should we remind you about?",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    hintText: "e.g. Solve LeetCode, Review Notes",
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.label_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "When?",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setDialogState(() => selectedDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${selectedDate.day}/${selectedDate.month}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(
                                  context,
                                ).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setDialogState(() => selectedTime = time);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final label = labelController.text.trim().isEmpty
                    ? "Practice Reminder"
                    : labelController.text.trim();
                final scheduledDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                if (scheduledDateTime.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a future time"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

                ref.read(reminderProvider.notifier).add(
                      Reminder(
                        id: id.toString(),
                        label: label,
                        dateTime: scheduledDateTime,
                      ),
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Reminder set: $label (Local only)"),
                      backgroundColor: Colors.indigo,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Schedule"),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Share Your Feedback",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "How is your experience so far?",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Maybe Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thank you! Your feedback helps us grow."),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text("Send Feedback"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(overallStatsProvider);
    final streak = ref.watch(streakProvider);
    final authState = ref.watch(authProvider);
    final history = ref.watch(attendanceProvider);
    final xp = ref.watch(xpProvider);
    final isCheckedIn = ref
        .read(attendanceProvider.notifier)
        .isCheckedInToday();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalCompleted = stats.totalCompleted;
    final totalPending = stats.totalPending;
    final progressPercentage = stats.progress;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // --- Modern Header ---
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: Colors.indigo,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo.shade800, Colors.indigo.shade500],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Level ${XPNotifier.calculateLevel(xp)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        authState.username ?? 'Explorer',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Notifications coming soon!"),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => ref
                                          .read(authProvider.notifier)
                                          .logout(),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Level Progress Bar
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  height: 8,
                                  width: 200 * XPNotifier.calculateLevelProgress(xp),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ).animate().shimmer(duration: 2.seconds),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // --- Quick Stats Cards ---
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildQuickStatCard(
                                  "Streak",
                                  "$streak Days",
                                  Icons.local_fire_department,
                                  Colors.orange,
                                  isDark,
                                )
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child:
                            _buildQuickStatCard(
                                  "Rank",
                                  XPNotifier.getLevelTitle(xp),
                                  Icons.workspace_premium,
                                  Colors.blue,
                                  isDark,
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Daily Activity ---
                  _buildSectionContainer(
                    context: context,
                    title: "Daily Activity",
                    action: !isCheckedIn
                        ? ElevatedButton(
                            onPressed: () {
                              ref.read(attendanceProvider.notifier).checkIn();
                              ref.read(xpProvider.notifier).addXP(20);
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Check In",
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Active",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      headerVisible: false,
                      daysOfWeekVisible: true,
                      rowHeight: 45,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          if (_isDayActive(day, history)) {
                            return Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green, Colors.teal],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),

                  // --- Progress Analysis ---
                  _buildSectionContainer(
                    context: context,
                    title: "Progress Analysis",
                    action: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProgressPeriod,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        items: ['Day', 'Month', 'Year'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedProgressPeriod = val);
                          }
                        },
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 110,
                              width: 110,
                              child: Stack(
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 38,
                                      startDegreeOffset: 270,
                                      sections: [
                                        PieChartSectionData(
                                          color: Colors.indigo,
                                          value:
                                              (_selectedProgressPeriod == 'Day'
                                              ? progressPercentage
                                              : (streak % 30 / 30)) * 100,
                                          radius: 12,
                                          showTitle: false,
                                        ),
                                        PieChartSectionData(
                                          color: Colors.indigo.withValues(
                                            alpha: 0.1,
                                          ),
                                          value:
                                              (1 - (_selectedProgressPeriod == 'Day'
                                              ? progressPercentage
                                              : (streak % 30 / 30))) * 100,
                                          radius: 8,
                                          showTitle: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selectedProgressPeriod == 'Day'
                                              ? "${(progressPercentage * 100).toInt()}%"
                                              : "${streak}d",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          _selectedProgressPeriod == 'Day'
                                              ? "Done"
                                              : "Streak",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildModernStatRow(
                                    "Completed",
                                    "$totalCompleted",
                                    Colors.green,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildModernStatRow(
                                    "Pending",
                                    "$totalPending",
                                    Colors.orange,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildModernStatRow(
                                    "Goal",
                                    "${totalCompleted + totalPending}",
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Weekly Activity",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                _TrendNavBtn(
                                  icon: Icons.chevron_left,
                                  onTap: () => setState(() => _trendOffset++),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Text(
                                    _trendOffset == 0
                                        ? "Current"
                                        : "${_trendOffset}w ago",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ),
                                _TrendNavBtn(
                                  icon: Icons.chevron_right,
                                  onTap: _trendOffset > 0
                                      ? () => setState(() => _trendOffset--)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 1.2,
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final date = DateTime.now().subtract(
                                        Duration(
                                          days:
                                              (6 - value.toInt()) +
                                              (_trendOffset * 7),
                                        ),
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          "${date.day}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(7, (i) {
                                final date = DateTime.now().subtract(
                                  Duration(days: (6 - i) + (_trendOffset * 7)),
                                );
                                final isDone = history.any(
                                  (d) => isSameDay(d, date),
                                );
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: isDone ? 1.0 : 0.1,
                                      gradient: isDone
                                          ? const LinearGradient(
                                              colors: [
                                                Colors.indigo,
                                                Colors.blueAccent,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            )
                                          : null,
                                      color: isDone
                                          ? null
                                          : Colors.grey.withValues(alpha: 0.1),
                                      width: 14,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),
                  const Row(
                    children: [
                      Text(
                        "Practice Hub",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                    ],
                  ),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      final item = _features[index];
                      return _buildFeatureCard(item, index, isDark);
                    },
                  ),

                  const SizedBox(height: 32),
                  _buildFeedbackBanner(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (action != null) ...[const SizedBox(width: 8), action],
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildModernStatRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> item, int index, bool isDark) {
    final color = item['color'] as Color;
    final title = item['title'] as String;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Theme.of(context).cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _handleFeatureTap(title),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(item['icon'] as IconData, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      delay: (400 + (50 * index)).ms,
      curve: Curves.easeOutBack,
    );
  }

  void _handleFeatureTap(String title) {
    if (title == 'Coding Challenges') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const CodingListScreen()),
      );
    } else if (title == 'ATS Checker') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const AtsCheckerScreen()),
      );
    } else if (title == 'Resume Maker') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const ResumeMakerScreen()),
      );
    } else if (title == 'To-Do List') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const TodoListScreen()),
      );
    } else if (title == 'Notebook') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const NotebookScreen()),
      );
    } else if (title == 'Feedback') {
      _showFeedbackDialog();
    } else if (title == 'Pending Work') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const PendingWorkScreen()),
      );
    } else if (title == 'Reminders') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const ReminderScreen()),
      );
    }
  }

  Widget _buildFeedbackBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Help us improve!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Share your thoughts and shape the future of the app.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showFeedbackDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Give Feedback",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.rocket_launch, color: Colors.white24, size: 80),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).scale();
  }
}

class _TrendNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _TrendNavBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? Colors.grey : Colors.indigo,
          ),
        ),
      ),
    );
  }
}
