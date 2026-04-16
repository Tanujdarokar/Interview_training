import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final xp = ref.watch(xpProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'System Core',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [Colors.indigo.shade900, const Color(0xFF0F172A)]
                        : [Colors.indigo.shade700, Colors.indigo.shade500],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: 40,
                      child: Icon(
                        Icons.settings_suggest_rounded,
                        size: 180,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildUserCard(authState, xp, isDark),
                    const SizedBox(height: 24),

                    _buildSettingsGroup("PREFERENCES", [
                      _buildThemeSelector(themeMode, ref, isDark),
                    ], isDark),

                    const SizedBox(height: 24),

                    _buildSettingsGroup("SUPPORT & FEEDBACK", [
                      _buildSettingTile(
                        icon: Icons.auto_awesome_rounded,
                        title: "Send Feedback",
                        subtitle: "Help us refine the experience",
                        onTap: () => _showFeedbackDialog(context, isDark),
                        isDark: isDark,
                      ),
                      _buildSettingTile(
                        icon: Icons.help_center_outlined,
                        title: "Help Center",
                        subtitle: "Guides and tactical support",
                        onTap: () => _showHelpCenter(context, isDark),
                        isDark: isDark,
                      ),
                      _buildSettingTile(
                        icon: Icons.info_outline_rounded,
                        title: "About Core",
                        subtitle: "System Version 2.0.4",
                        onTap: () => _showAboutApp(context, isDark),
                        isDark: isDark,
                      ),
                    ], isDark),

                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                          onPressed: () =>
                              ref.read(authProvider.notifier).logout(),
                          icon: const Icon(Icons.power_settings_new_rounded),
                          label: const Text(
                            "TERMINATE SESSION",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            foregroundColor: Colors.redAccent,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AuthState auth, int xp, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.indigo.shade50,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blue.shade400],
              ),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 40, color: Colors.indigo),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.username ?? "Agent Alpha",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.email ?? "Offline Identity",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "LEVEL ${XPNotifier.calculateLevel(xp)} • ${XPNotifier.getLevelTitle(xp)}",
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSettingsGroup(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.indigo.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.indigo.shade50,
            ),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 20,
                      color: isDark ? Colors.white10 : Colors.indigo.shade50,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildThemeSelector(
    ThemeMode currentMode,
    WidgetRef ref,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.palette_rounded, color: Colors.amber, size: 20),
      ),
      title: Text(
        "Interface Mode",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.indigo.shade900,
        ),
      ),
      trailing: DropdownButton<ThemeMode>(
        value: currentMode,
        underline: const SizedBox(),
        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        onChanged: (mode) {
          if (mode != null) {
            ref.read(themeProvider.notifier).setTheme(mode);
          }
        },
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
          DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
          DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.indigo, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.indigo.shade900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
    );
  }

  void _showFeedbackDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Intelligence Feedback",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Transmission details...",
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ABORT"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feedback transmitted to base.")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("TRANSMIT"),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.rocket_launch, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Interview Pro",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "System OS v2.0.4",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "The ultimate tactical companion for mastery. Refine your logic, optimize your profile, and conquer the technical horizon.",
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE DATA STREAM"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenter(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tactical Briefing",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpItem(
                    "Deployment: ATS Checker",
                    "Upload PDF intel and synchronize with job descriptions for match analysis.",
                  ),
                  _buildHelpItem(
                    "Operation: Daily Streaks",
                    "Maintain daily connectivity to maximize XP gains and streak stability.",
                  ),
                  _buildHelpItem(
                    "Terminal: Code Execution",
                    "Validate logic via the mock execution environment across 150+ challenges.",
                  ),
                  _buildHelpItem(
                    "Export: Resume Maker",
                    "Compile your operational history into a standardized PDF format.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("ACKNOWLEDGED"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            a,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
