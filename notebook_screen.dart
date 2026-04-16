import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';

class NotebookScreen extends ConsumerStatefulWidget {
  const NotebookScreen({super.key});

  @override
  ConsumerState<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends ConsumerState<NotebookScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _showNoteDialog({Note? existingNote}) {
    if (existingNote != null) {
      _titleController.text = existingNote.title;
      _contentController.text = existingNote.content;
    } else {
      _titleController.clear();
      _contentController.clear();
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                existingNote == null ? 'New Inspiration' : 'Refine Thought',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                          color: Colors.indigo.withValues(alpha: 0.7),
                        ),
                        hintText: 'Give your idea a name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.indigo.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        labelStyle: TextStyle(
                          color: Colors.indigo.withValues(alpha: 0.7),
                        ),
                        hintText: 'Start pouring your thoughts...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.indigo.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Discard',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty ||
                        _contentController.text.isNotEmpty) {
                      if (existingNote == null) {
                        ref
                            .read(noteProvider.notifier)
                            .addNote(
                              _titleController.text,
                              _contentController.text,
                            );
                        ref.read(xpProvider.notifier).addXP(5);
                      } else {
                        ref
                            .read(noteProvider.notifier)
                            .updateNote(
                              existingNote.id,
                              _titleController.text,
                              _contentController.text,
                            );
                      }
                      Navigator.pop(context);
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(existingNote == null ? 'Preserve' : 'Update'),
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
    final notes = ref.watch(noteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);

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
                'Thought Vault',
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
                            ? [Colors.indigo.shade900, const Color(0xFF0F172A)]
                            : [Colors.indigo.shade600, Colors.indigo.shade400],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (notes.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                          Icons.auto_stories_rounded,
                          size: 100,
                          color: Colors.indigo.withValues(alpha: 0.2),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2.seconds,
                          color: Colors.indigo.withValues(alpha: 0.1),
                        ),
                    const SizedBox(height: 24),
                    Text(
                      "Your vault is empty",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.indigo.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Capture fleeting inspirations before they vanish.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final note = notes[index];
                  return Hero(
                    tag: 'note_${note.id}',
                    child:
                        Card(
                              elevation: 4,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () =>
                                    _showNoteDialog(existingNote: note),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.indigo.withValues(
                                              alpha: 0.05,
                                            ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              note.title.isEmpty
                                                  ? "Untitled"
                                                  : note.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.indigo.shade900,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => ref
                                                .read(noteProvider.notifier)
                                                .deleteNote(note.id),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.1,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: Text(
                                          note.content,
                                          maxLines: 6,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 10,
                                            color: Colors.indigo.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.indigo.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (50 * index).ms)
                            .scale(
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                              begin: const Offset(0.8, 0.8),
                            ),
                  );
                }, childCount: notes.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Capture Idea"),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
    );
  }
}
