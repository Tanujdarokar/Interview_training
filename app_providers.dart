import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

// --- Auth Provider ---

@immutable
class AuthState {
  final bool isAuthenticated;
  final bool isGuest;
  final String? username;
  final String? email;

  const AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.username,
    this.email,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isGuest,
    String? username,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    final username = prefs.getString('username');
    final email = prefs.getString('email');

    if (isAuthenticated) {
      state = AuthState(
        isAuthenticated: true,
        username: username,
        email: email,
      );
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    if (users.containsKey(email) && users[email]['password'] == password) {
      final username = users[email]['username'];
      state = AuthState(
        isAuthenticated: true,
        username: username,
        email: email,
      );

      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('username', username);
      await prefs.setString('email', email);
    } else {
      throw 'Invalid email or password';
    }
  }

  Future<void> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    if (users.containsKey(email)) {
      throw 'User already exists';
    }

    final username = email.split('@')[0];
    users[email] = {'username': username, 'password': password};

    await prefs.setString('registered_users', jsonEncode(users));
    await login(email, password);
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users') ?? '{}';
    final Map<String, dynamic> users = Map<String, dynamic>.from(
      jsonDecode(usersJson),
    );

    if (!users.containsKey(email)) {
      throw 'Email not found';
    }

    users[email]['password'] = newPassword;
    await prefs.setString('registered_users', jsonEncode(users));
  }

  void loginAsGuest() {
    state = const AuthState(
      isAuthenticated: true,
      isGuest: true,
      username: 'Guest User',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('username');
    await prefs.remove('email');
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// --- Attendance & Streak Providers ---

class AttendanceNotifier extends StateNotifier<List<DateTime>> {
  AttendanceNotifier() : super([]) {
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList('attendance_dates') ?? [];
    state = dates.map((d) => DateTime.parse(d)).toList();
  }

  Future<void> checkIn() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!state.any((date) => isSameDay(date, today))) {
      state = [...state, today];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'attendance_dates',
        state.map((d) => d.toIso8601String()).toList(),
      );
    }
  }

  bool isCheckedInToday() {
    final now = DateTime.now();
    return state.any((date) => isSameDay(date, now));
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, List<DateTime>>(
      (ref) => AttendanceNotifier(),
    );

final streakProvider = Provider<int>((ref) {
  final history = ref.watch(attendanceProvider);
  if (history.isEmpty) return 0;

  final sortedHistory = [...history]..sort((a, b) => b.compareTo(a));
  int streak = 0;
  DateTime current = DateTime.now();
  DateTime today = DateTime(current.year, current.month, current.day);

  bool active = false;
  if (sortedHistory.any(
    (d) => d.year == today.year && d.month == today.month && d.day == today.day,
  )) {
    active = true;
  } else {
    DateTime yesterday = today.subtract(const Duration(days: 1));
    if (sortedHistory.any(
      (d) =>
          d.year == yesterday.year &&
          d.month == yesterday.month &&
          d.day == yesterday.day,
    )) {
      active = true;
    }
  }

  if (!active) return 0;

  DateTime checkDate = sortedHistory.first;
  streak = 1;

  for (int i = 1; i < sortedHistory.length; i++) {
    if (checkDate.subtract(const Duration(days: 1)).year ==
            sortedHistory[i].year &&
        checkDate.subtract(const Duration(days: 1)).month ==
            sortedHistory[i].month &&
        checkDate.subtract(const Duration(days: 1)).day ==
            sortedHistory[i].day) {
      streak++;
      checkDate = sortedHistory[i];
    } else {
      break;
    }
  }
  return streak;
});

// --- Theme Provider ---

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> toggleTheme() async {
    ThemeMode next;
    if (state == ThemeMode.light) {
      next = ThemeMode.dark;
    } else if (state == ThemeMode.dark) {
      next = ThemeMode.system;
    } else {
      next = ThemeMode.light;
    }
    await setTheme(next);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

// --- Todo Provider ---

class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final String category;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'Daily',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'],
    category: json['category'] ?? 'Daily',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString('user_todos') ?? '[]';
    final List<dynamic> decoded = jsonDecode(todosJson);
    List<Todo> loadedTodos = decoded
        .map((item) => Todo.fromJson(item))
        .toList();

    // Check for expired todos on load
    state = _filterOldDailyTodos(loadedTodos);
    _saveTodos();
  }

  List<Todo> _filterOldDailyTodos(List<Todo> todos) {
    final now = DateTime.now();
    // Keep daily tasks for 30 days for history viewing
    final expireCutoff = DateTime(now.year, now.month, now.day, 0)
        .subtract(const Duration(days: 30));

    return todos.where((todo) {
      if (todo.category == 'Daily') {
        return todo.createdAt.isAfter(expireCutoff);
      }
      return true;
    }).toList();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user_todos',
      jsonEncode(state.map((t) => t.toJson()).toList()),
    );
  }

  void addTodo(String title, String category) {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
      category: category,
      createdAt: DateTime.now(),
    );
    state = [...state, newTodo];
    _saveTodos();
  }

  void toggleTodo(String id) {
    state = state
        .map(
          (todo) => todo.id == id
              ? todo.copyWith(isCompleted: !todo.isCompleted)
              : todo,
        )
        .toList();
    _saveTodos();
  }

  void updateTodo(String id, String newTitle, String category) {
    state = state
        .map(
          (todo) => todo.id == id
              ? todo.copyWith(title: newTitle, category: category)
              : todo,
        )
        .toList();
    _saveTodos();
  }

  void deleteTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
    _saveTodos();
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>(
  (ref) => TodoNotifier(),
);

// --- Computed Stats Providers ---

final todoStatsProvider = Provider((ref) {
  final todos = ref.watch(todoProvider);
  final completed = todos.where((t) => t.isCompleted).length;
  return (
    completed: completed,
    pending: todos.length - completed,
    total: todos.length,
  );
});

final pendingWorkStatsProvider = Provider((ref) {
  final items = ref.watch(pendingWorkProvider);
  final completed = items.where((t) => t.isDone).length;
  return (
    completed: completed,
    pending: items.length - completed,
    total: items.length,
  );
});

final overallStatsProvider = Provider((ref) {
  final todoStats = ref.watch(todoStatsProvider);
  final workStats = ref.watch(pendingWorkStatsProvider);

  final totalCompleted = todoStats.completed + workStats.completed;
  final totalPending = todoStats.pending + workStats.pending;
  final total = totalCompleted + totalPending;
  final progress = total > 0 ? totalCompleted / total : 0.0;

  return (
    totalCompleted: totalCompleted,
    totalPending: totalPending,
    total: total,
    progress: progress,
  );
});

// --- Pending Work Provider (Simpler CRUD) ---

class PendingWorkItem {
  final String id;
  final String task;
  final bool isDone;

  PendingWorkItem({required this.id, required this.task, this.isDone = false});

  Map<String, dynamic> toJson() => {'id': id, 'task': task, 'isDone': isDone};
  factory PendingWorkItem.fromJson(Map<String, dynamic> json) =>
      PendingWorkItem(
        id: json['id'],
        task: json['task'],
        isDone: json['isDone'] ?? false,
      );

  PendingWorkItem copyWith({String? task, bool? isDone}) => PendingWorkItem(
    id: id,
    task: task ?? this.task,
    isDone: isDone ?? this.isDone,
  );
}

class PendingWorkNotifier extends StateNotifier<List<PendingWorkItem>> {
  PendingWorkNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('pending_work') ?? '[]';
    final List decoded = jsonDecode(json);
    state = decoded.map((e) => PendingWorkItem.fromJson(e)).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pending_work',
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void add(String task) {
    state = [
      ...state,
      PendingWorkItem(id: DateTime.now().toString(), task: task),
    ];
    _save();
  }

  void toggle(String id) {
    state = state
        .map((e) => e.id == id ? e.copyWith(isDone: !e.isDone) : e)
        .toList();
    _save();
  }

  void update(String id, String task) {
    state = state.map((e) => e.id == id ? e.copyWith(task: task) : e).toList();
    _save();
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
    _save();
  }
}

final pendingWorkProvider =
    StateNotifierProvider<PendingWorkNotifier, List<PendingWorkItem>>(
      (ref) => PendingWorkNotifier(),
    );

// --- Note Provider ---

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NoteNotifier extends StateNotifier<List<Note>> {
  NoteNotifier() : super([]) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('user_notes') ?? '[]';
    final List<dynamic> decoded = jsonDecode(notesJson);
    state = decoded.map((item) => Note.fromJson(item)).toList();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user_notes',
      jsonEncode(state.map((n) => n.toJson()).toList()),
    );
  }

  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    state = [newNote, ...state];
    _saveNotes();
  }

  void updateNote(String id, String title, String content) {
    state = state
        .map(
          (note) => note.id == id
              ? note.copyWith(title: title, content: content)
              : note,
        )
        .toList();
    _saveNotes();
  }

  void deleteNote(String id) {
    state = state.where((note) => note.id != id).toList();
    _saveNotes();
  }
}

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>(
  (ref) => NoteNotifier(),
);

final xpProvider = StateNotifierProvider<XPNotifier, int>(
  (ref) => XPNotifier(),
);

class XPNotifier extends StateNotifier<int> {
  XPNotifier() : super(0) {
    _loadXP();
  }

  Future<void> _loadXP() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('user_xp') ?? 0;
  }

  Future<void> addXP(int amount) async {
    state += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_xp', state);
  }

  static int calculateLevel(int xp) => (xp / 100).floor() + 1;
  static double calculateLevelProgress(int xp) => (xp % 100) / 100;

  static String getLevelTitle(int xp) {
    int level = calculateLevel(xp);
    if (level < 5) return "Novice";
    if (level < 15) return "Specialist";
    if (level < 30) return "Expert";
    if (level < 50) return "Master";
    return "Legend";
  }
}

// --- Reminder Provider ---

class Reminder {
  final String id;
  final String label;
  final DateTime dateTime;

  Reminder({required this.id, required this.label, required this.dateTime});

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'dateTime': dateTime.toIso8601String(),
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'],
    label: json['label'],
    dateTime: DateTime.parse(json['dateTime']),
  );

  Reminder copyWith({String? id, String? label, DateTime? dateTime}) {
    return Reminder(
      id: id ?? this.id,
      label: label ?? this.label,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}

class ReminderNotifier extends StateNotifier<List<Reminder>> with WidgetsBindingObserver {
  final Ref ref;
  ReminderNotifier(this.ref) : super([]) {
    _load();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload state when app comes to foreground to catch background deletions
      _load();
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user_reminders') ?? '[]';
    final List decoded = jsonDecode(json);
    state = decoded.map((e) => Reminder.fromJson(e)).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user_reminders',
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void add(Reminder reminder) {
    state = [...state, reminder];
    _save();
    _scheduleNotification(reminder);
  }

  void update(String id, String label, DateTime dateTime) {
    state = state
        .map(
          (e) => e.id == id ? e.copyWith(label: label, dateTime: dateTime) : e,
        )
        .toList();
    _save();
    final updated = state.firstWhere((e) => e.id == id);
    _scheduleNotification(updated);
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _save();
    _cancelNotification(id);
  }

  void clearAll() {
    state = [];
    _save();
    ref.read(notificationServiceProvider).cancelAll();
  }

  void _scheduleNotification(Reminder reminder) {
    final now = DateTime.now();
    if (reminder.dateTime.isAfter(now)) {
      // Safely derive an integer ID from the string ID.
      // We use the last 9 digits as an int ID for notifications, with a fallback.
      int notificationId;
      try {
        final idStr = reminder.id;
        final start = idStr.length > 9 ? idStr.length - 9 : 0;
        notificationId = int.parse(idStr.substring(start));
      } catch (e) {
        notificationId = reminder.hashCode.abs() % 1000000000;
      }

      ref.read(notificationServiceProvider).scheduleNotification(
        id: notificationId,
        title: "Reminder: ${reminder.label}",
        body: "Your scheduled task is due now!",
        scheduledDate: reminder.dateTime,
      );
    }
  }

  void _cancelNotification(String stringId) {
    try {
      final start = stringId.length > 9 ? stringId.length - 9 : 0;
      final int id = int.parse(stringId.substring(start));
      ref.read(notificationServiceProvider).cancelNotification(id);
    } catch (_) {
      // If parsing fails, we can't easily cancel by ID unless we stored the mapping.
      // But hashCode was used as fallback in schedule, so we might try that too if needed.
    }
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, List<Reminder>>(
      (ref) => ReminderNotifier(ref),
    );
