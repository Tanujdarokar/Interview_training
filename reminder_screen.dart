import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  static final _timeFormat = DateFormat("HH:mm");
  static final _dateFormat = DateFormat("MMM dd, yyyy");

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reminders = ref.watch(reminderProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(reminders.isNotEmpty),
          if (reminders.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildReminderCard(reminders[index], index),
                  childCount: reminders.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReminderDialog(),
        backgroundColor: Colors.indigo,
        elevation: 4,
        child: const Icon(Icons.add_alarm, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(bool hasReminders) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.indigo,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Active Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade800, Colors.indigo.shade500],
            ),
          ),
        ),
      ),
      actions: [
        if (hasReminders)
          IconButton(
            icon: const Icon(Icons.notifications_off_outlined, color: Colors.white),
            onPressed: _showClearAllDialog,
          ),
      ],
    );
  }

  void _showReminderDialog([Reminder? reminder]) {
    final bool isEdit = reminder != null;
    final labelController = TextEditingController(text: reminder?.label);
    DateTime selectedDate = reminder?.dateTime ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(
      reminder?.dateTime ?? DateTime.now().add(const Duration(minutes: 5)),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(isEdit ? Icons.edit_notifications : Icons.alarm_add, color: Colors.indigo),
              const SizedBox(width: 12),
              Text(isEdit ? "Edit Reminder" : "New Reminder", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel("Label"),
                TextField(
                  controller: labelController,
                  decoration: _inputDecoration("e.g. Solve LeetCode", Icons.label_outline),
                ),
                const SizedBox(height: 20),
                _buildFieldLabel("When?"),
                Row(
                  children: [
                    _buildPicker(
                      icon: Icons.calendar_today,
                      text: DateFormat('dd/MM').format(selectedDate),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setDialogState(() => selectedDate = date);
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildPicker(
                      icon: Icons.access_time,
                      text: selectedTime.format(context),
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: selectedTime);
                        if (time != null) setDialogState(() => selectedTime = time);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final label = labelController.text.trim().isEmpty ? "Reminder" : labelController.text.trim();
                final scheduledDateTime = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  selectedTime.hour, selectedTime.minute,
                );

                if (scheduledDateTime.isBefore(DateTime.now()) && !isEdit) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot set reminder in the past")));
                  return;
                }

                if (isEdit) {
                  ref.read(reminderProvider.notifier).update(reminder.id, label, scheduledDateTime);
                } else {
                  final newReminder = Reminder(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    label: label,
                    dateTime: scheduledDateTime,
                  );
                  ref.read(reminderProvider.notifier).add(newReminder);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? "Reminder updated" : "Reminder set for ${DateFormat('HH:mm').format(scheduledDateTime)}"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              child: Text(isEdit ? "Update" : "Add"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
  );

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.withValues(alpha: 0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    prefixIcon: Icon(icon, size: 20),
  );

  Widget _buildPicker({required IconData icon, required String text, required VoidCallback onTap}) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(icon, size: 16, color: Colors.indigo), const SizedBox(width: 8), Text(text)]),
      ),
    ),
  );

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All?"),
        content: const Text("This will remove all active reminders."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(reminderProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.notifications_paused_outlined, size: 80, color: Colors.indigo.withValues(alpha: 0.2))
          .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
      const SizedBox(height: 24),
      const Text("All Clear!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text("Use the + button to set a new task reminder.", style: TextStyle(color: Colors.grey.shade600)),
    ],
  );

  Widget _buildReminderCard(Reminder reminder, int index) {
    final isExpired = reminder.dateTime.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isExpired ? Colors.redAccent.withValues(alpha: 0.1) : Colors.indigo.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: _buildCardLeading(isExpired),
        title: Text(reminder.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: _buildCardSubtitle(reminder),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.indigo), onPressed: () => _showReminderDialog(reminder)),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => ref.read(reminderProvider.notifier).remove(reminder.id)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildCardLeading(bool isExpired) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: isExpired ? Colors.redAccent.withValues(alpha: 0.1) : Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle),
    child: Icon(isExpired ? Icons.history : Icons.alarm_on, color: isExpired ? Colors.redAccent : Colors.indigo, size: 24),
  );

  Widget _buildCardSubtitle(Reminder reminder) => Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Wrap(
      spacing: 12,
      children: [
        _buildInfoRow(Icons.calendar_today, _dateFormat.format(reminder.dateTime)),
        _buildInfoRow(Icons.access_time, _timeFormat.format(reminder.dateTime), isPrimary: true),
      ],
    ),
  );

  Widget _buildInfoRow(IconData icon, String text, {bool isPrimary = false}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: isPrimary ? Colors.indigo : Colors.grey.shade500),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal, color: isPrimary ? Colors.indigo : null)),
    ],
  );
}
