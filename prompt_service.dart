class PromptService {
  /// The prompt used to analyze a resume's ATS friendliness.
  /// It instructs the AI to look for formatting issues, standard headings,
  /// and contact information while ignoring complex graphics.
  static const String atsFriendlinessPrompt = """
Analyze the following resume for ATS (Applicant Tracking System) friendliness.
Check for:
1. File format compatibility.
2. Presence of standard headings (Education, Experience, Skills).
3. Contact information visibility.
4. Use of complex graphics or icons that might confuse parsers.
5. Font readability and use of standard system fonts.

Provide a structured JSON response with:
- score: An integer from 0-100.
- checks: A list of objects with 'label' (string), 'status' (boolean), and 'desc' (string).
""";

  /// The prompt used to compare a resume against a job description.
  /// It helps identify missing keywords and overall match percentage.
  static const String keywordMatchPrompt = """
Compare the provided Resume Skills against the Job Description.
1. Identify matching keywords.
2. Identify missing critical keywords.
3. Calculate a match percentage based on the relevance of matched skills.

Resume Skills: {resume_skills}
Job Description: {job_description}

Provide a structured JSON response with:
- match_score: An integer from 0-100.
- matched_keywords: List of strings.
- missing_keywords: List of strings.
- advice: A brief summary of how to improve the match.
""";

  /// The prompt for the Resume Maker to generate professional bullet points.
  static const String resumeBulletPointPrompt = """
You are a professional resume writer. Rewrite the following task into a high-impact,
action-oriented bullet point for a resume using the "Action Verb + Task + Result" formula.

Task: {user_task}

Generated Bullet Point:
""";

  /// The prompt for the Coding Interview Assistant.
  /// It helps users understand complex algorithms by providing analogies and step-by-step logic.
  static const String codingInterviewAssistantPrompt = """
You are a senior technical interviewer. Explain the following coding problem and its optimal solution.
Use a simple analogy, explain the time and space complexity, and provide a step-by-step logical approach.

Problem: {problem_title}
Description: {problem_description}

Explanation:
""";
}
