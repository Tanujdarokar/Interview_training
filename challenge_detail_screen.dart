import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Map<String, String> challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _selectedLanguage = 'Dart';
  String _output = "";
  bool _isExecuting = false;

  final Map<String, String> _boilerplates = {
    'Dart':
        "void main() {\n  // Write your logic here\n  print('Hello World');\n}",
    'Python':
        "def solve():\n    # Write your logic here\n    print(\"Hello World\")\n\nif __name__ == \"__main__\":\n    solve()",
    'Java':
        "public class Main {\n    public static void main(String[] args) {\n        // Write your logic here\n        System.out.println(\"Hello World\");\n    }\n}",
    'C++':
        "#include <iostream>\nusing namespace std;\n\nint main() {\n    // Write your logic here\n    cout << \"Hello World\" << endl;\n    return 0;\n}",
    'C':
        "#include <stdio.h>\n\nint main() {\n    // Write your logic here\n    printf(\"Hello World\\n\");\n    return 0;\n}",
  };

  @override
  void initState() {
    super.initState();
    _codeController.text = _boilerplates[_selectedLanguage]!;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _runCode() {
    setState(() {
      _isExecuting = true;
      _output = "Compiling and running...";
    });

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      setState(() {
        _isExecuting = false;
        _output = "Output:\n> Hello World\n\nProgram finished with exit code 0";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.challenge['category']!,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              icon: const Icon(Icons.language, color: Colors.indigo, size: 20),
              items: _boilerplates.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                    _codeController.text = _boilerplates[newValue]!;
                  });
                }
              },
            ),
          ),
          IconButton(
            icon: _isExecuting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                  )
                : const Icon(Icons.play_arrow, color: Colors.green),
            onPressed: _isExecuting ? null : _runCode,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            onPressed: () {
              Navigator.pop(context, true);
            },
            tooltip: 'Complete Challenge',
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress saved successfully.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Section: Question ---
            Text(
              widget.challenge['title']!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.indigo.shade300 : Colors.indigo,
              ),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 12),
            Text(
              "Problem Statement:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
            ),
            Text(
              "Implement the logical solution for this problem using your preferred programming constructs. Focus on clean logic and efficiency.",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            // --- Mid Section: Examples ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.indigo.withValues(alpha: 0.1) : const Color(0x0D3F51B5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.indigo.withValues(alpha: 0.2) : const Color(0x1A3F51B5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Example Case:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Input: n = 5",
                    style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                  const Text(
                    "Output: result = 120",
                    style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                  Text(
                    "Explanation: 5 * 4 * 3 * 2 * 1 = 120",
                    style: TextStyle(
                      fontSize: 12, 
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // --- Last Section: Constraints ---
            Text(
              "Constraints:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                _ConstraintItem(text: "Time Complexity: O(n)", isDark: isDark),
                _ConstraintItem(text: "Space Complexity: O(1)", isDark: isDark),
                _ConstraintItem(text: "Input Range: 1 <= n <= 10^5", isDark: isDark),
              ],
            ),

            const SizedBox(height: 32),

            // --- Bottom Section: Code Editor ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Write Your Solution:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.indigo.withValues(alpha: 0.2) : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedLanguage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Dark VS Code theme
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33000000),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "solution.${_getFileExtension()}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.code, color: Colors.blue, size: 16),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _codeController,
                    maxLines: 12,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, end: 0, delay: 400.ms),

            const SizedBox(height: 24),

            // --- Output Section ---
            if (_output.isNotEmpty) ...[
              const Text(
                "Terminal Output:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _output,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getFileExtension() {
    switch (_selectedLanguage) {
      case 'Dart':
        return 'dart';
      case 'Python':
        return 'py';
      case 'Java':
        return 'java';
      case 'C++':
        return 'cpp';
      case 'C':
        return 'c';
      default:
        return 'txt';
    }
  }
}

class _ConstraintItem extends StatelessWidget {
  final String text;
  final bool isDark;
  const _ConstraintItem({required this.text, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13, 
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
