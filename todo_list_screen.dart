import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';


class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _todoController = TextEditingController();
  late TabController _tabController;
  String _selectedCategory = 'Daily';
  final List<String> _categories = ['Daily', 'Short Term', 'Long Term'];
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  DateTime _selectedDailyDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startTimer();
  }

  @override
  void dispose() {
    _todoController.dispose();
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = _calculateTimeUntilReset();
        });
      }
    });
  }

  Duration _calculateTimeUntilReset() {
    final now = DateTime.now();
    DateTime resetTime = DateTime(now.year, now.month, now.day, 5);
    if (now.hour >= 5) {
      resetTime = resetTime.add(const Duration(days: 1));
    }
    return resetTime.difference(now);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _checkMilestones(String category) {
    if (category != 'Daily') return;

    final allTodos = ref.read(todoProvider);
    final dailyTodos = allTodos.where((t) => t.category == 'Daily').toList();
    if (dailyTodos.isEmpty) return;

    final completedCount = dailyTodos.where((t) => t.isCompleted).length;
    final totalCount = dailyTodos.length;
    final progress = completedCount / totalCount;

    if (completedCount == totalCount) {
      _showMilestoneSnackbar("your 100% task will done", Colors.green);
    } else if (progress >= 0.5 && (completedCount - 1) / totalCount < 0.5) {
      _showMilestoneSnackbar("your 50% task will done", Colors.orange);
    }
  }

  void _showMilestoneSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddTodoDialog({Todo? existingTodo}) {
    if (existingTodo != null) {
      _todoController.text = existingTodo.title;
      _selectedCategory = existingTodo.category;
    } else {
      _todoController.clear();
      _selectedCategory = _categories[_tabController.index];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            existingTodo == null ? 'New Objective' : 'Edit Objective',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoController,
                autofocus: true,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  labelText: 'Task Title',
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Horizon',
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setDialogState(() => _selectedCategory = newValue);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_todoController.text.isNotEmpty) {
                  if (existingTodo == null) {
                    ref.read(todoProvider.notifier).addTodo(_todoController.text, _selectedCategory);
                  } else {
                    ref.read(todoProvider.notifier).updateTodo(
                          existingTodo.id,
                          _todoController.text,
                          _selectedCategory,
                        );
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(existingTodo == null ? 'Deploy' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 62),
              title: const Text(
                'Mission Control',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Colors.indigo.shade900, Colors.blue.shade900] 
                      : [Colors.indigo.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: 40,
                      child: Icon(
                        Icons.rocket_launch_rounded,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white24,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  tabs: const [
                    Tab(text: 'Daily'),
                    Tab(text: 'Short'),
                    Tab(text: 'Long'),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodoList('Daily', isDark),
                _buildTodoList('Short Term', isDark),
                _buildTodoList('Long Term', isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTodoDialog(),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Goal', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildTodoList(String category, bool isDark) {
    final allTodos = ref.watch(todoProvider);
    
    List<Todo> todos;
    if (category == 'Daily') {
      todos = allTodos.where((t) {
        if (t.category != 'Daily') return false;
        final todoDate = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
        final selectedDate = DateTime(_selectedDailyDate.year, _selectedDailyDate.month, _selectedDailyDate.day);
        return todoDate.isAtSameMomentAs(selectedDate);
      }).toList();
    } else {
      todos = allTodos.where((t) => t.category == category).toList();
    }

    return Column(
      children: [
        if (category == 'Daily')
          _buildDailyHeader(allTodos, isDark),
        if (category == 'Daily' && todos.isNotEmpty)
          _buildDailyProgress(todos, isDark),
        Expanded(
          child: todos.isEmpty
              ? _buildEmptyState(category, isDark)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return _buildTodoCard(todo, isDark, index, category);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDailyHeader(List<Todo> allTodos, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(3, (index) {
                  final date = DateTime.now().subtract(Duration(days: index));
                  final isSelected = isSameDay(date, _selectedDailyDate);
                  final label = index == 0 ? "Today" : (index == 1 ? "Yesterday" : "Previous");

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedDailyDate = date);
                        }
                      },
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.indigo.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                  );
                }).reversed.toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton.filledTonal(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDailyDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: Colors.indigo,
                          brightness: isDark ? Brightness.dark : Brightness.light,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _selectedDailyDate = picked);
                }
              },
              icon: const Icon(Icons.calendar_month_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                foregroundColor: Colors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDailyProgress(List<Todo> todos, bool isDark) {
    final stats = ref.watch(todoStatsProvider);
    final completedCount = stats.completed;
    final totalCount = stats.total;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.indigo.shade50),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Next Reset In",
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(_timeLeft),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.indigo.shade900,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.orange, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Operational Progress",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white10 : Colors.indigo.shade50,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState(String category, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              size: 80,
              color: Colors.indigo.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Clear Horizon",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.indigo.shade900, 
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No $category objectives identified yet.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTodoCard(Todo todo, bool isDark, int index, String category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark 
            ? (todo.isCompleted ? Colors.green.withValues(alpha: 0.2) : Colors.white10)
            : (todo.isCompleted ? Colors.green.shade100 : Colors.grey.shade100),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: GestureDetector(
            onTap: () {
              final wasCompleted = todo.isCompleted;
              ref.read(todoProvider.notifier).toggleTodo(todo.id);
              if (!wasCompleted) {
                ref.read(xpProvider.notifier).addXP(10);
                _checkMilestones(category);
              }
            },
            child: AnimatedContainer(
              duration: 300.ms,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: todo.isCompleted ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isCompleted ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: todo.isCompleted 
                ? const Icon(Icons.check, size: 18, color: Colors.white) 
                : null,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted
                  ? Colors.grey
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'edit') {
                setState(() => _selectedCategory = category);
                _showAddTodoDialog(existingTodo: todo);
              } else if (value == 'delete') {
                ref.read(todoProvider.notifier).deleteTodo(todo.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate(target: todo.isCompleted ? 1 : 0)
    .shimmer(duration: 800.ms, color: Colors.green.withValues(alpha: 0.1))
    .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.02, 1.02),
      duration: 150.ms,
      curve: Curves.easeOut,
    )
    .then()
    .scale(begin: const Offset(1.02, 1.02), end: const Offset(1, 1))
    .animate()
    .fadeIn(delay: (50 * index).ms)
    .slideX(begin: 0.05, end: 0);
  }
}
