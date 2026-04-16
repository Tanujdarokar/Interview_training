import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';

class PendingWorkScreen extends ConsumerStatefulWidget {
  const PendingWorkScreen({super.key});

  @override
  ConsumerState<PendingWorkScreen> createState() => _PendingWorkScreenState();
}

class _PendingWorkScreenState extends ConsumerState<PendingWorkScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showTaskDialog({PendingWorkItem? existingItem}) {
    if (existingItem != null) {
      _taskController.text = existingItem.task;
    } else {
      _taskController.clear();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                existingItem == null ? 'New Objective' : 'Refine Objective',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
              ),
              content: TextField(
                controller: _taskController,
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'What needs attention?',
                  labelText: 'Task Brief',
                  labelStyle: TextStyle(color: Colors.orangeAccent.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Stand Down', style: TextStyle(color: Colors.grey.shade600)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      if (existingItem == null) {
                        ref.read(pendingWorkProvider.notifier).add(_taskController.text);
                      } else {
                        ref.read(pendingWorkProvider.notifier).update(existingItem.id, _taskController.text);
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(existingItem == null ? 'Deploy' : 'Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(pendingWorkProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Backlog Ops',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [Colors.orange.shade900, const Color(0xFF0F172A)]
                            : [Colors.orange.shade700, Colors.orange.shade400],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.priority_high_rounded,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (tasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 100,
                      color: Colors.orangeAccent.withValues(alpha: 0.2),
                    ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2.seconds, color: Colors.orangeAccent.withValues(alpha: 0.1)),
                    const SizedBox(height: 24),
                    Text(
                      "Radar is clear",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "No pending objectives in the backlog.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.orange.withValues(alpha: 0.05),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.isDone ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              ),
                              child: Checkbox(
                                value: item.isDone,
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                                side: BorderSide(color: Colors.orange.withValues(alpha: 0.5), width: 2),
                                shape: const CircleBorder(),
                                onChanged: (val) {
                                  ref.read(pendingWorkProvider.notifier).toggle(item.id);
                                  if (!item.isDone) {
                                    ref.read(xpProvider.notifier).addXP(15);
                                  }
                                },
                              ),
                            ),

                            title: Text(
                              item.task,
                              style: TextStyle(
                                decoration: item.isDone ? TextDecoration.lineThrough : null,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: item.isDone
                                    ? Colors.grey
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                                  onPressed: () => _showTaskDialog(existingItem: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                                  onPressed: () => ref.read(pendingWorkProvider.notifier).delete(item.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    );
                  },
                  childCount: tasks.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text("Add Objective"),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
    );
  }
}

