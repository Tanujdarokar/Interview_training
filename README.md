# Interview Pro 🚀

**Interview Pro** is an AI-powered personal companion designed to help developers bridge the gap between preparation and professional performance. Built for the **Prompt War** challenge, it leverages advanced prompt engineering to provide critical feedback and automated assistance for the modern job seeker.

---

## 💡 The Problem

The path from "learning to code" to "landing the job" is filled with invisible hurdles:
1. **ATS Rejection:** 75% of resumes are never read by a human because they fail Applicant Tracking System (ATS) scans.
2. **Generic Prep:** Developers often practice coding without knowing how to explain their logic effectively to an interviewer.
3. **Task Management:** Balancing interview prep, coding challenges, and daily life is a cognitive burden.

**Interview Pro** solves this by providing a suite of tools that act as a personal career coach, ensuring you are not just "ready" but "optimized."

---

## 🪄 The "Prompt" Magic

This project is built around high-performance **Google Gemini** prompts. We treat prompts as first-class citizens in our architecture (see `lib/services/prompt_service.dart`).

### 1. ATS Pro Checker
**The Goal:** Detect formatting "landmines" and keyword gaps that cause automatic rejection.
**Key Prompt:**
> *"Analyze the following resume for ATS friendliness. Check for: File format compatibility, standard headings, contact visibility, complex graphics, and font readability. Provide a structured JSON response..."*

### 2. Resume Maker (Bullet Point Optimizer)
**The Goal:** Transform boring tasks into high-impact achievements using the "Action Verb + Task + Result" formula.
**Key Prompt:**
> *"You are a professional resume writer. Rewrite the following task into a high-impact, action-oriented bullet point for a resume using the Action Verb + Task + Result formula."*

### 3. Coding Interview Assistant
**The Goal:** Moving beyond code to "Communication."
**Key Prompt:**
> *"You are a senior technical interviewer. Explain the following coding problem using a simple analogy, explain time/space complexity, and provide a step-by-step logical approach."*

---

## 🛠 Technical Stack

- **Framework:** [Flutter](https://flutter.dev) (Multi-platform UI)
- **State Management:** [Riverpod](https://riverpod.dev) (Robust, testable, and reactive)
- **Background Services:** [Flutter Background Service](https://pub.dev/packages/flutter_background_service) (Ensures reminders trigger silently even when the app is closed)
- **Notifications:** [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) (High-priority Android alarms with persistent vibration)
- **AI Integration:** Google AI Dart SDK (Gemini)
- **Animations:** [Flutter Animate](https://pub.dev/packages/flutter_animate)

---

## 🚀 Key Features

- **ATS Scanner:** Real-time feedback on resume "friendliness" and keyword matching.
- **Smart Reminders:** A "Silent Background" service that triggers urgent notifications with persistent sound and vibration—never miss an interview.
- **Coding Lab:** A curated list of challenges with AI-powered logical explanations.
- **Modern Dashboard:** A high-performance UI with custom animations and level-based XP tracking to gamify your preparation.

---

## 🏁 How to Run

1. Clone the repository.
2. Ensure you have the Flutter SDK installed.
3. Run `flutter pub get`.
4. Add your Gemini API Key in the relevant service file.
5. Run `flutter run`.

---

*Built with ❤️ for the Prompt War Challenge.*
