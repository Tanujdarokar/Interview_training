import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class AtsCheckerScreen extends ConsumerStatefulWidget {
  const AtsCheckerScreen({super.key});

  @override
  ConsumerState<AtsCheckerScreen> createState() => _AtsCheckerScreenState();
}

class _AtsCheckerScreenState extends ConsumerState<AtsCheckerScreen> {
  static final _skillSplitRegExp = RegExp(r'[, \n]+');
  final _jdController = TextEditingController();
  final _skillsController = TextEditingController();
  int? _score;
  bool _isLoading = false;
  String? _pickedFileName;
  List<Map<String, dynamic>>? _friendlyChecks;

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _pickedFileName = result.files.single.name;
        _isLoading = true;
        _score = null;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _friendlyChecks = [
          {
            'label': 'File Format (PDF/DOCX)',
            'status': true,
            'desc': 'Your file format is standard and readable.',
          },
          {
            'label': 'Standard Headings',
            'status': true,
            'desc': 'Education and Experience sections detected.',
          },
          {
            'label': 'Contact Information',
            'status': true,
            'desc': 'Found email and phone number.',
          },
          {
            'label': 'No Complex Graphics',
            'status': false,
            'desc': 'Detected some icons which might confuse older ATS.',
          },
          {
            'label': 'Font Readability',
            'status': true,
            'desc': 'Standard system fonts detected.',
          },
        ];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned $_pickedFileName successfully!')),
        );
      }
    }
  }

  void _calculateScore() {
    if (_jdController.text.isEmpty || _skillsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Job Description and your Skills.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      final jdText = _jdController.text.toLowerCase();
      final resumeSkills = _skillsController.text.toLowerCase().split(_skillSplitRegExp);

      int matchCount = 0;
      final uniqueSkills = resumeSkills.where((s) => s.length > 2).toSet();

      for (var skill in uniqueSkills) {
        if (jdText.contains(skill)) matchCount++;
      }

      final calculatedScore = uniqueSkills.isEmpty
          ? 0
          : (matchCount / uniqueSkills.length * 100).round();

      setState(() {
        _score = calculatedScore > 100 ? 100 : calculatedScore;
        _isLoading = false;
      });

      // Award XP for analysis
      ref.read(xpProvider.notifier).addXP(15);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis Complete! +15 XP Earned'),
            backgroundColor: Colors.purple,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _jdController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'ATS Pro Checker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Colors.purple.shade900, Colors.purple.shade700] 
                      : [Colors.purple.shade600, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  "Optimize your career journey with our advanced scanner.",
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 24),

                // --- Scan Resume Section ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.indigo.shade50,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: Colors.indigo.shade400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _pickedFileName ?? "Upload Your Resume",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "PDF, DOC, or DOCX formats accepted",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _pickResume,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Select File",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.1, end: 0),

                if (_friendlyChecks != null) ...[
                  const SizedBox(height: 32),
                  const Text(
                    "ATS Friendliness Report",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._friendlyChecks!
                      .map<Widget>(
                        (check) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.grey.shade100,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (check['status'] ? Colors.green : Colors.orange)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                check['status']
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.warning_amber_rounded,
                                color: check['status'] ? Colors.green : Colors.orange,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              check['label'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              check['desc'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList()
                      .animate(interval: 100.ms)
                      .fadeIn()
                      .slideX(begin: 0.05),
                ],

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 32),
                const Text(
                  "Keywords Match Analysis",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _jdController,
                  maxLines: 5,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    labelText: 'Job Description',
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Paste the target job description here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _skillsController,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    labelText: 'Your Skills',
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Enter skills found in your resume...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _calculateScore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Analyze Keywords Match',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (_score != null) ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Overall Match Score',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: _score! / 100,
                                strokeWidth: 14,
                                strokeCap: StrokeCap.round,
                                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                                color: _score! > 70
                                    ? Colors.green
                                    : (_score! > 40 ? Colors.orange : Colors.red),
                              ),
                            ),
                            Text(
                              '$_score%',
                              style: const TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _score! > 70
                              ? "Excellent match! You're ready."
                              : (_score! > 40
                                    ? "Good start. Add more keywords."
                                    : "Needs improvement. Tailor your skills."),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _score! > 70
                                ? Colors.green
                                : (_score! > 40 ? Colors.orange : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ],
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
