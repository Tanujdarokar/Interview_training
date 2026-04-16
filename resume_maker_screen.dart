import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumeMakerScreen extends StatefulWidget {
  const ResumeMakerScreen({super.key});

  @override
  State<ResumeMakerScreen> createState() => _ResumeMakerScreenState();
}

class _ResumeMakerScreenState extends State<ResumeMakerScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _internshipController = TextEditingController();
  final _projectController = TextEditingController();
  final _certificationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _internshipController.dispose();
    _projectController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  _nameController.text.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(_emailController.text, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(_phoneController.text, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 20),

                // Sections
                _buildPdfSection('PROFESSIONAL SUMMARY', _aboutController.text),
                
                if (_experienceController.text.isNotEmpty)
                  _buildPdfSection('WORK EXPERIENCE', _experienceController.text),

                if (_internshipController.text.isNotEmpty)
                  _buildPdfSection('INTERNSHIPS', _internshipController.text),

                if (_projectController.text.isNotEmpty)
                  _buildPdfSection('KEY PROJECTS', _projectController.text),

                _buildPdfSection('EDUCATION', _educationController.text),

                _buildPdfSection('TECHNICAL SKILLS', _skillsController.text),

                if (_certificationController.text.isNotEmpty)
                  _buildPdfSection('CERTIFICATIONS', _certificationController.text),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.indigo700,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          content,
          style: const pw.TextStyle(fontSize: 11),
        ),

        pw.SizedBox(height: 18),
      ],
    );
  }

  List<Step> _getSteps(bool isDark) {
    return [
      _buildStep(
        title: 'Personal Info',
        index: 0,
        isDark: isDark,
        content: [
          _buildTextField(_nameController, 'Full Name', Icons.person_outline, isRequired: true, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress, isRequired: true, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField(_phoneController, 'Phone Number', Icons.phone_android_outlined, keyboardType: TextInputType.phone, isRequired: true, isDark: isDark),
        ],
      ),
      _buildStep(
        title: 'Summary',
        index: 1,
        isDark: isDark,
        content: [
          _buildTextField(_aboutController, 'Professional Summary', Icons.description_outlined, maxLines: 5, isRequired: true, isDark: isDark, hint: 'High-level overview of your career and goals...'),
        ],
      ),
      _buildStep(
        title: 'Education',
        index: 2,
        isDark: isDark,
        content: [
          _buildTextField(_educationController, 'Academic History', Icons.school_outlined, maxLines: 4, hint: 'Degree, University, Year, GPA...', isRequired: true, isDark: isDark),
        ],
      ),
      _buildStep(
        title: 'Experience',
        index: 3,
        isDark: isDark,
        content: [
          _buildTextField(_experienceController, 'Work History', Icons.business_center_outlined, maxLines: 6, hint: 'Company, Role, Key achievements...', isRequired: false, isDark: isDark),
        ],
      ),
      _buildStep(
        title: 'Projects',
        index: 4,
        isDark: isDark,
        content: [
          _buildTextField(_projectController, 'Key Projects', Icons.rocket_launch_outlined, maxLines: 5, hint: 'Project name, Tech stack, Impact...', isRequired: true, isDark: isDark),
        ],
      ),
      _buildStep(
        title: 'Skills',
        index: 5,
        isDark: isDark,
        content: [
          _buildTextField(_skillsController, 'Technical Skills', Icons.psychology_outlined, maxLines: 4, hint: 'Languages, Tools, Frameworks...', isRequired: true, isDark: isDark),
        ],
      ),
      _buildStep(
        title: 'Extras',
        index: 6,
        isDark: isDark,
        content: [
          _buildTextField(_internshipController, 'Internships', Icons.handshake_outlined, maxLines: 3, isRequired: false, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField(_certificationController, 'Certifications', Icons.verified_outlined, maxLines: 3, isRequired: false, isDark: isDark),
        ],
      ),
    ];
  }

  Step _buildStep({
    required String title,
    required int index,
    required bool isDark,
    required List<Widget> content,
  }) {
    return Step(
      state: _currentStep > index ? StepState.complete : StepState.indexed,
      isActive: _currentStep >= index,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: _currentStep == index ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
          color: _currentStep >= index 
            ? (isDark ? Colors.white : Colors.black87) 
            : Colors.grey,
        ),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: content),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
    required bool isRequired,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.indigo.shade400,
            fontWeight: FontWeight.w500,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.indigo.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  void _submitResume() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all required fields'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade400, size: 28),
            const SizedBox(width: 12),
            const Text('Resume Ready!'),
          ],
        ),
        content: const Text(
          'Your professional resume has been compiled. You can now preview and save it as a PDF.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Edit More', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generatePdf();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Generate PDF', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = _getSteps(isDark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Resume Architect',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Colors.indigo.shade900, Colors.indigo.shade700] 
                      : [Colors.indigo.shade600, Colors.indigo.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_rounded,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.indigo,
                    secondary: Colors.indigoAccent,
                    onSurface: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Stepper(
                    physics: const NeverScrollableScrollPhysics(),
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep < steps.length - 1) {
                        setState(() => _currentStep++);
                      } else {
                        _submitResume();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    steps: steps,
                    controlsBuilder: (context, controls) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controls.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  _currentStep == steps.length - 1
                                      ? 'Finish & Review'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            if (_currentStep > 0) ...[
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: controls.onStepCancel,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                ),
                                child: Text(
                                  'Back',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0),
          ),
        ],
      ),
    );
  }
}
