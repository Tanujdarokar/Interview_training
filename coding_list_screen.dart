import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'challenge_detail_screen.dart';

class CodingListScreen extends ConsumerStatefulWidget {
  const CodingListScreen({super.key});

  @override
  ConsumerState<CodingListScreen> createState() => _CodingListScreenState();
}

class _CodingListScreenState extends ConsumerState<CodingListScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, String>> _allChallenges = [
    // Phase 1 - Conditional Thinking (50 Questions)
    {
      'title': 'Check if positive, negative, or zero',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Check if even or odd',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Check if divisible by 5',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Check if divisible by both 3 and 5',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Check if leap year',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Find larger of two numbers',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Find largest of three numbers',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Temperature Status (Cold/Warm/Hot)',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Check if vowel or consonant',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Check Upper/Lower/Digit/Special char',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Valid Triangle Check (Sides)',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Equilateral, Isosceles, or Scalene',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Calculate Grade (A-F)',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Multiple of each other check',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Time-based Greeting (0-23)',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Voting Eligibility (Age 18+)',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Both even, both odd, or mixed',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Alphabet range check (a-m or n-z)',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Day number to Day name',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': 'Month number to Number of days',
      'difficulty': 'Basic',
      'category': 'Conditions',
    },
    {
      'title': '3-Digit Number: Distinct digits check',
      'difficulty': 'Medium',
      'category': 'Math Logic',
    },
    {
      'title': '3-Digit Number: Middle digit relation',
      'difficulty': 'Medium',
      'category': 'Math Logic',
    },
    {
      'title': '4-Digit Number: First and last digit equality',
      'difficulty': 'Medium',
      'category': 'Math Logic',
    },
    {
      'title': 'Check single, double, or multi-digit',
      'difficulty': 'Basic',
      'category': 'Math Logic',
    },
    {
      'title': 'Multiple of 7 or ends with 7',
      'difficulty': 'Basic',
      'category': 'Math Logic',
    },
    {
      'title': 'Find Coordinate Quadrant (x, y)',
      'difficulty': 'Medium',
      'category': 'Math Logic',
    },
    {
      'title': 'Currency Note Division (2000, 500, 100)',
      'difficulty': 'Medium',
      'category': 'Math Logic',
    },
    {
      'title': 'Number Range check [100, 999]',
      'difficulty': 'Basic',
      'category': 'Math Logic',
    },
    {
      'title': 'Calculate 3rd angle of triangle',
      'difficulty': 'Basic',
      'category': 'Math Logic',
    },
    {
      'title': 'Check Perfect Square (No sqrt func)',
      'difficulty': 'Hard',
      'category': 'Math Logic',
    },
    {
      'title': 'Letter, Digit, or Neither',
      'difficulty': 'Basic',
      'category': 'Logic',
    },
    {'title': 'FizzBuzz Challenge', 'difficulty': 'Basic', 'category': 'Logic'},
    {
      'title': 'Find Median of Three Numbers',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'AM or PM Check (24-hour time)',
      'difficulty': 'Basic',
      'category': 'Logic',
    },
    {
      'title': 'Tax Eligibility (Age & Income)',
      'difficulty': 'Basic',
      'category': 'Logic',
    },
    {
      'title': 'Both positive and sum < 100',
      'difficulty': 'Basic',
      'category': 'Logic',
    },
    {
      'title': 'Digit to Word Form (0-9)',
      'difficulty': 'Basic',
      'category': 'Logic',
    },
    {
      'title': 'Weekday or Weekend check',
      'difficulty': 'Basic',
      'category': 'Logic',
    },
    {
      'title': 'Electricity Bill Calculation',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'Password Rule Validation',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'X-axis, Y-axis, or Origin Check',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'Pythagorean Triplet Check',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'Valid Calendar Date Check',
      'difficulty': 'Hard',
      'category': 'Logic',
    },
    {
      'title': 'Clock Hands Angle Calculation',
      'difficulty': 'Hard',
      'category': 'Logic',
    },
    {
      'title': 'Arithmetic Progression Check',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'Geometric Progression Check',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': '3-Digit: Sum of First & Last == Middle',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'Digit Sum > Digit Product (1-9999)',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'Compare two Dates (Which comes first)',
      'difficulty': 'Medium',
      'category': 'Logic',
    },
    {
      'title': 'Year to Century conversion',
      'difficulty': 'Medium',
      'category': 'Logic',
    },

    // Phase 2 - Looping & Patterns (50 Questions)
    {
      'title': 'Print numbers 1 to 10',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Print even numbers 1 to 100',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Print odd numbers 1 to 100',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Print numbers 10 down to 1',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Print Multiplication Table',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Sum of first n natural numbers',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Sum of even numbers up to n',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Sum of odd numbers up to n',
      'difficulty': 'Basic',
      'category': 'Loops',
    },
    {
      'title': 'Factorial of a number',
      'difficulty': 'Medium',
      'category': 'Loops',
    },
    {
      'title': 'Product of digits of a number',
      'difficulty': 'Medium',
      'category': 'Loops',
    },
    {
      'title': 'Count number of digits',
      'difficulty': 'Basic',
      'category': 'Number Logic',
    },
    {
      'title': 'Reverse a given number',
      'difficulty': 'Medium',
      'category': 'Number Logic',
    },
    {
      'title': 'Check if Palindrome number',
      'difficulty': 'Medium',
      'category': 'Number Logic',
    },
    {
      'title': 'Sum of digits of a number',
      'difficulty': 'Basic',
      'category': 'Number Logic',
    },
    {
      'title': 'Check Armstrong Number',
      'difficulty': 'Medium',
      'category': 'Number Logic',
    },
    {
      'title': 'Check Perfect Number',
      'difficulty': 'Medium',
      'category': 'Number Logic',
    },
    {
      'title': 'Print Prime numbers between 1-100',
      'difficulty': 'Hard',
      'category': 'Number Logic',
    },
    {
      'title': 'Check if number is Prime',
      'difficulty': 'Medium',
      'category': 'Number Logic',
    },
    {
      'title': 'Fibonacci series up to n terms',
      'difficulty': 'Medium',
      'category': 'Loops',
    },
    {
      'title': 'Sum of n Fibonacci terms',
      'difficulty': 'Hard',
      'category': 'Loops',
    },
    {
      'title': 'Print squares from 1 to n',
      'difficulty': 'Basic',
      'category': 'Math Loops',
    },
    {
      'title': 'Print cubes from 1 to n',
      'difficulty': 'Basic',
      'category': 'Math Loops',
    },
    {
      'title': 'Numbers divisible by 7 in range [a, b]',
      'difficulty': 'Basic',
      'category': 'Math Loops',
    },
    {
      'title': 'HCF (GCD) using loops',
      'difficulty': 'Medium',
      'category': 'Math Loops',
    },
    {
      'title': 'LCM using loops',
      'difficulty': 'Medium',
      'category': 'Math Loops',
    },
    {
      'title': 'Print all factors of a number',
      'difficulty': 'Basic',
      'category': 'Math Loops',
    },
    {
      'title': 'Sum of all factors',
      'difficulty': 'Medium',
      'category': 'Math Loops',
    },
    {
      'title': 'Check Strong Number',
      'difficulty': 'Hard',
      'category': 'Math Loops',
    },
    {
      'title': 'Print AP terms (a, d)',
      'difficulty': 'Medium',
      'category': 'Math Loops',
    },
    {
      'title': 'Print GP terms (a, r)',
      'difficulty': 'Medium',
      'category': 'Math Loops',
    },
    {
      'title': 'Numbers with even sum of digits (1-100)',
      'difficulty': 'Medium',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Divisible by 7 but not 5 (1-500)',
      'difficulty': 'Medium',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Palindromes between 1-500',
      'difficulty': 'Hard',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Sum of digits multiple of 3 (1-100)',
      'difficulty': 'Medium',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Smallest and Largest digit in number',
      'difficulty': 'Medium',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Binary even parity count (1-n)',
      'difficulty': 'Hard',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Print row i as i*i pattern',
      'difficulty': 'Medium',
      'category': 'Patterns',
    },
    {
      'title': 'Factorial of each number 1 to n',
      'difficulty': 'Medium',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Separate Odd and Even digit sums',
      'difficulty': 'Medium',
      'category': 'Mixed Loops',
    },
    {
      'title': 'Sum non-zero inputs (Skip 0)',
      'difficulty': 'Medium',
      'category': 'Mixed Loops',
    },

    // Phase 3 - Recursion (40 Questions)
    {
      'title': 'Print 1 to n (Recursion)',
      'difficulty': 'Basic',
      'category': 'Recursion',
    },
    {
      'title': 'Print n down to 1 (Recursion)',
      'difficulty': 'Basic',
      'category': 'Recursion',
    },
    {
      'title': 'Even numbers 1 to n (Recursion)',
      'difficulty': 'Basic',
      'category': 'Recursion',
    },
    {
      'title': 'Odd numbers 1 to n (Recursion)',
      'difficulty': 'Basic',
      'category': 'Recursion',
    },
    {
      'title': 'Natural Sum up to n (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Factorial calculation (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Power calculation x^n (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Nth Fibonacci (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Fibonacci series up to n (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Sum of digits (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Count digits (Recursion)',
      'difficulty': 'Basic',
      'category': 'Recursion',
    },
    {
      'title': 'Reverse a number (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Palindrome check (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Product of digits (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'GCD Euclid\'s Algorithm (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Decimal to Binary (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Digits to Words (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Sum of first n even numbers (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Sum of first n odd numbers (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Pascal\'s nCr calculation (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Print n stars line (Recursion)',
      'difficulty': 'Basic',
      'category': 'Patterns Rec',
    },
    {
      'title': 'Print nxn stars square (Recursion)',
      'difficulty': 'Medium',
      'category': 'Patterns Rec',
    },
    {
      'title': 'Print top-down triangle (Recursion)',
      'difficulty': 'Medium',
      'category': 'Patterns Rec',
    },
    {
      'title': 'Print bottom-up triangle (Recursion)',
      'difficulty': 'Medium',
      'category': 'Patterns Rec',
    },
    {
      'title': 'Print number triangle (Recursion)',
      'difficulty': 'Hard',
      'category': 'Patterns Rec',
    },
    {
      'title': 'Reverse triangle pattern (Recursion)',
      'difficulty': 'Hard',
      'category': 'Patterns Rec',
    },
    {
      'title': 'Multiplication table (Recursion)',
      'difficulty': 'Medium',
      'category': 'Recursion',
    },
    {
      'title': 'Increasing-Decreasing order same func',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Display steps of series sum',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'A, AB, ABC... pattern (Recursion)',
      'difficulty': 'Hard',
      'category': 'Recursion',
    },
    {
      'title': 'Reverse a string (Recursion)',
      'difficulty': 'Hard',
      'category': 'String Rec',
    },
    {
      'title': 'String Palindrome check (Recursion)',
      'difficulty': 'Hard',
      'category': 'String Rec',
    },
    {
      'title': 'Count vowels in string (Recursion)',
      'difficulty': 'Medium',
      'category': 'String Rec',
    },
    {
      'title': 'Remove spaces from string (Recursion)',
      'difficulty': 'Hard',
      'category': 'String Rec',
    },
    {
      'title': 'Replace char occurrences (Recursion)',
      'difficulty': 'Hard',
      'category': 'String Rec',
    },
    {
      'title': 'Remove char occurrences (Recursion)',
      'difficulty': 'Hard',
      'category': 'String Rec',
    },
    {
      'title': 'Print chars one by one (Recursion)',
      'difficulty': 'Basic',
      'category': 'String Rec',
    },
    {
      'title': 'Print string reversed order (Recursion)',
      'difficulty': 'Medium',
      'category': 'String Rec',
    },
    {
      'title': 'String to Uppercase (Recursion)',
      'difficulty': 'Medium',
      'category': 'String Rec',
    },
    {
      'title': 'Count Consonants and Vowels (Recursion)',
      'difficulty': 'Hard',
      'category': 'String Rec',
    },

    // Phase 4 - Basic Arrays (50 Questions)
    {
      'title': 'Input and print array',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Sum of all array elements',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Find average of array',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Find maximum in array',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Find minimum in array',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Count Pos/Neg/Zero in array',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Count Even and Odd in array',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Find index of maximum element',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Find index of minimum element',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Print elements > k',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Check if element x exists',
      'difficulty': 'Basic',
      'category': 'Searching',
    },
    {
      'title': 'Count occurrences of element',
      'difficulty': 'Basic',
      'category': 'Searching',
    },
    {
      'title': 'Find first occurrence of number',
      'difficulty': 'Basic',
      'category': 'Searching',
    },
    {
      'title': 'Find last occurrence of number',
      'difficulty': 'Basic',
      'category': 'Searching',
    },
    {
      'title': 'Check if all elements unique',
      'difficulty': 'Medium',
      'category': 'Arrays',
    },
    {
      'title': 'Sum of even elements only',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Sum of odd elements only',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Count prime numbers in array',
      'difficulty': 'Medium',
      'category': 'Arrays',
    },
    {
      'title': 'Divisible by 3 and 5 count',
      'difficulty': 'Basic',
      'category': 'Arrays',
    },
    {
      'title': 'Count perfect squares in array',
      'difficulty': 'Medium',
      'category': 'Arrays',
    },
    {
      'title': 'Squares of all numbers (New array)',
      'difficulty': 'Basic',
      'category': 'Transformation',
    },
    {
      'title': 'Even elements only (New array)',
      'difficulty': 'Basic',
      'category': 'Transformation',
    },
    {
      'title': 'Replace negative with 0',
      'difficulty': 'Basic',
      'category': 'Transformation',
    },
    {
      'title': 'Map even to 1, odd to 0',
      'difficulty': 'Basic',
      'category': 'Transformation',
    },
    {
      'title': 'Swap first and last elements',
      'difficulty': 'Basic',
      'category': 'Transformation',
    },
    {
      'title': 'Reverse an array manually',
      'difficulty': 'Medium',
      'category': 'Transformation',
    },
    {
      'title': 'Rotate array left by 1',
      'difficulty': 'Medium',
      'category': 'Transformation',
    },
    {
      'title': 'Rotate array right by 1',
      'difficulty': 'Medium',
      'category': 'Transformation',
    },
    {
      'title': 'Swap alternate elements',
      'difficulty': 'Medium',
      'category': 'Transformation',
    },
    {
      'title': 'Manually copy array',
      'difficulty': 'Basic',
      'category': 'Transformation',
    },
    {
      'title': 'Check if two arrays are equal',
      'difficulty': 'Medium',
      'category': 'Aggregate',
    },
    {
      'title': 'Same elements (Ignore order)',
      'difficulty': 'Hard',
      'category': 'Aggregate',
    },
    {
      'title': 'Merge two arrays',
      'difficulty': 'Basic',
      'category': 'Aggregate',
    },
    {
      'title': 'Find common elements',
      'difficulty': 'Medium',
      'category': 'Aggregate',
    },
    {
      'title': 'Elements in A not in B',
      'difficulty': 'Medium',
      'category': 'Aggregate',
    },
    {
      'title': 'Count common elements',
      'difficulty': 'Medium',
      'category': 'Aggregate',
    },
    {
      'title': 'Element-wise sum (A + B)',
      'difficulty': 'Basic',
      'category': 'Aggregate',
    },
    {
      'title': 'Element-wise product (A * B)',
      'difficulty': 'Basic',
      'category': 'Aggregate',
    },
    {
      'title': 'Create frequency array',
      'difficulty': 'Hard',
      'category': 'Aggregate',
    },
    {
      'title': 'Print duplicate elements',
      'difficulty': 'Medium',
      'category': 'Aggregate',
    },
    {
      'title': 'Check if sorted (Ascending)',
      'difficulty': 'Medium',
      'category': 'Applied',
    },
    {
      'title': 'Check if sorted (Descending)',
      'difficulty': 'Medium',
      'category': 'Applied',
    },
    {
      'title': 'Find second largest element',
      'difficulty': 'Hard',
      'category': 'Applied',
    },
    {
      'title': 'Find second smallest element',
      'difficulty': 'Hard',
      'category': 'Applied',
    },
    {
      'title': 'Max-Min difference',
      'difficulty': 'Basic',
      'category': 'Applied',
    },
    {
      'title': 'Sum except Max and Min',
      'difficulty': 'Medium',
      'category': 'Applied',
    },
    {
      'title': 'Count pairs with sum == k',
      'difficulty': 'Hard',
      'category': 'Applied',
    },
    {
      'title': 'Elements > Average count',
      'difficulty': 'Medium',
      'category': 'Applied',
    },
    {
      'title': 'Frequency of each distinct element',
      'difficulty': 'Hard',
      'category': 'Applied',
    },
    {
      'title': 'Print all unique elements',
      'difficulty': 'Hard',
      'category': 'Applied',
    },

    // Phase 5 - Strings (50 Questions)
    {
      'title': 'Print string length',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'First and last character',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'Convert to Uppercase',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'Convert to Lowercase',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'Char count (No spaces)',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'Word count in sentence',
      'difficulty': 'Medium',
      'category': 'String Basic',
    },
    {
      'title': 'Concatenate two strings',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'Lexicographical comparison',
      'difficulty': 'Medium',
      'category': 'String Basic',
    },
    {
      'title': 'ASCII value of each char',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'Empty string check',
      'difficulty': 'Basic',
      'category': 'String Basic',
    },
    {
      'title': 'Vowel and Consonant count',
      'difficulty': 'Basic',
      'category': 'Counting',
    },
    {
      'title': 'Digit/Letter/Special char count',
      'difficulty': 'Basic',
      'category': 'Counting',
    },
    {
      'title': 'Upper and Lower case count',
      'difficulty': 'Basic',
      'category': 'Counting',
    },
    {
      'title': 'Char frequency (No map)',
      'difficulty': 'Hard',
      'category': 'Counting',
    },
    {
      'title': 'Space count in sentence',
      'difficulty': 'Basic',
      'category': 'Counting',
    },
    {
      'title': 'Target char occurrence count',
      'difficulty': 'Basic',
      'category': 'Counting',
    },
    {
      'title': 'Alphabets before and after \'m\'',
      'difficulty': 'Medium',
      'category': 'Counting',
    },
    {
      'title': 'Start/End same char substring count',
      'difficulty': 'Hard',
      'category': 'Counting',
    },
    {
      'title': 'Words starting with vowel count',
      'difficulty': 'Medium',
      'category': 'Counting',
    },
    {
      'title': 'Words ending with \'s\' count',
      'difficulty': 'Medium',
      'category': 'Counting',
    },
    {
      'title': 'Reverse string (No built-in)',
      'difficulty': 'Medium',
      'category': 'Reversing',
    },
    {
      'title': 'Reverse each word in sentence',
      'difficulty': 'Hard',
      'category': 'Reversing',
    },
    {
      'title': 'Reverse word order in sentence',
      'difficulty': 'Hard',
      'category': 'Reversing',
    },
    {
      'title': 'Palindrome check',
      'difficulty': 'Medium',
      'category': 'Reversing',
    },
    {
      'title': 'Check if strings are reverse of each',
      'difficulty': 'Medium',
      'category': 'Reversing',
    },
    {
      'title': 'Print middle character(s)',
      'difficulty': 'Basic',
      'category': 'Reversing',
    },
    {
      'title': 'Second half in reverse',
      'difficulty': 'Medium',
      'category': 'Reversing',
    },
    {
      'title': 'Remove first and last char',
      'difficulty': 'Basic',
      'category': 'Reversing',
    },
    {
      'title': 'Reverse chars only (Keep digits)',
      'difficulty': 'Hard',
      'category': 'Reversing',
    },
    {
      'title': 'Reverse string skip spaces',
      'difficulty': 'Hard',
      'category': 'Reversing',
    },
    {
      'title': 'Remove all vowels',
      'difficulty': 'Basic',
      'category': 'Manipulation',
    },
    {
      'title': 'Remove all spaces',
      'difficulty': 'Basic',
      'category': 'Manipulation',
    },
    {
      'title': 'Replace vowels with \'*\'',
      'difficulty': 'Basic',
      'category': 'Manipulation',
    },
    {
      'title': 'Replace spaces with \'_\'',
      'difficulty': 'Basic',
      'category': 'Manipulation',
    },
    {
      'title': 'Remove all digits',
      'difficulty': 'Basic',
      'category': 'Manipulation',
    },
    {
      'title': 'Remove duplicate characters',
      'difficulty': 'Hard',
      'category': 'Manipulation',
    },
    {
      'title': 'Keep only first occurrence',
      'difficulty': 'Hard',
      'category': 'Manipulation',
    },
    {
      'title': 'Remove consecutive duplicates',
      'difficulty': 'Medium',
      'category': 'Manipulation',
    },
    {
      'title': 'Swap case: Upper <-> Lower',
      'difficulty': 'Medium',
      'category': 'Manipulation',
    },
    {
      'title': 'Shift each character by 1',
      'difficulty': 'Medium',
      'category': 'Manipulation',
    },
    {
      'title': 'Print words on new lines',
      'difficulty': 'Basic',
      'category': 'Words',
    },
    {
      'title': 'Words with even length count',
      'difficulty': 'Basic',
      'category': 'Words',
    },
    {'title': 'Find longest word', 'difficulty': 'Medium', 'category': 'Words'},
    {
      'title': 'Find shortest word',
      'difficulty': 'Medium',
      'category': 'Words',
    },
    {
      'title': 'Swap first and last words',
      'difficulty': 'Medium',
      'category': 'Words',
    },
    {
      'title': 'Words with same start/end letter',
      'difficulty': 'Medium',
      'category': 'Words',
    },
    {
      'title': 'Words containing letter \'a\' count',
      'difficulty': 'Basic',
      'category': 'Words',
    },
    {
      'title': 'Capitalize first letter each word',
      'difficulty': 'Medium',
      'category': 'Words',
    },
    {
      'title': 'Title Case: Capital/Lower rest',
      'difficulty': 'Medium',
      'category': 'Words',
    },
    {
      'title': 'Normalize spacing (Remove extra)',
      'difficulty': 'Hard',
      'category': 'Words',
    },

    // Phase 6 - Mixed Logical Challenges (40 Questions)
    {
      'title': 'Divisible by 3 and 5 (1 to N)',
      'difficulty': 'Basic',
      'category': 'Number Mix',
    },
    {
      'title': 'Sum of digits (Loop)',
      'difficulty': 'Basic',
      'category': 'Number Mix',
    },
    {
      'title': 'Check Armstrong (Loop)',
      'difficulty': 'Medium',
      'category': 'Number Mix',
    },
    {
      'title': 'Armstrong numbers 1-1000',
      'difficulty': 'Hard',
      'category': 'Number Mix',
    },
    {
      'title': 'Factorial (Recursion Mix)',
      'difficulty': 'Medium',
      'category': 'Number Mix',
    },
    {
      'title': 'Even digit count in number',
      'difficulty': 'Basic',
      'category': 'Number Mix',
    },
    {
      'title': 'All primes up to N',
      'difficulty': 'Hard',
      'category': 'Number Mix',
    },
    {
      'title': 'Reverse of number (123 -> 321)',
      'difficulty': 'Medium',
      'category': 'Number Mix',
    },
    {
      'title': 'Palindrome check (Number)',
      'difficulty': 'Medium',
      'category': 'Number Mix',
    },
    {
      'title': 'Perfect Number check',
      'difficulty': 'Medium',
      'category': 'Number Mix',
    },
    {
      'title': 'Check Anagrams (No collection)',
      'difficulty': 'Hard',
      'category': 'String Mix',
    },
    {
      'title': 'Vowel count each word',
      'difficulty': 'Medium',
      'category': 'String Mix',
    },
    {
      'title': 'Reverse even length words',
      'difficulty': 'Hard',
      'category': 'String Mix',
    },
    {
      'title': 'Vowel position replacement (a=1..)',
      'difficulty': 'Hard',
      'category': 'String Mix',
    },
    {
      'title': 'Print chars appearing > once',
      'difficulty': 'Hard',
      'category': 'String Mix',
    },
    {
      'title': 'Same start/end letter word count',
      'difficulty': 'Medium',
      'category': 'String Mix',
    },
    {
      'title': 'Toggle case alternate words',
      'difficulty': 'Hard',
      'category': 'String Mix',
    },
    {
      'title': 'Rotation check (Two strings)',
      'difficulty': 'Hard',
      'category': 'String Mix',
    },
    {
      'title': 'Word with max vowels',
      'difficulty': 'Medium',
      'category': 'String Mix',
    },
    {
      'title': 'Remove duplicate words',
      'difficulty': 'Hard',
      'category': 'String Mix',
    },
    {
      'title': 'Find Max and Min in Array',
      'difficulty': 'Basic',
      'category': 'Array Mix',
    },
    {
      'title': 'Count Pos/Neg/Zero',
      'difficulty': 'Basic',
      'category': 'Array Mix',
    },
    {
      'title': 'Print Unique Elements',
      'difficulty': 'Medium',
      'category': 'Array Mix',
    },
    {
      'title': 'Reverse Array In-place',
      'difficulty': 'Medium',
      'category': 'Array Mix',
    },
    {
      'title': 'Shift all zeros to end',
      'difficulty': 'Hard',
      'category': 'Array Mix',
    },
    {
      'title': 'Even values at even indices count',
      'difficulty': 'Medium',
      'category': 'Array Mix',
    },
    {
      'title': 'Merge Two Arrays',
      'difficulty': 'Basic',
      'category': 'Array Mix',
    },
    {
      'title': 'Find Second Largest',
      'difficulty': 'Hard',
      'category': 'Array Mix',
    },
    {
      'title': 'Rotate Array Right by 1',
      'difficulty': 'Medium',
      'category': 'Array Mix',
    },
    {
      'title': 'Sum elements at odd indices',
      'difficulty': 'Basic',
      'category': 'Array Mix',
    },
    {
      'title': 'Multiplication Table Grid (10x10)',
      'difficulty': 'Medium',
      'category': 'Nested Flow',
    },
    {
      'title': 'Pairs with sum == Target',
      'difficulty': 'Hard',
      'category': 'Nested Flow',
    },
    {
      'title': 'Print all subarrays',
      'difficulty': 'Hard',
      'category': 'Nested Flow',
    },
    {
      'title': 'Sorted Check (Asc or Desc)',
      'difficulty': 'Medium',
      'category': 'Nested Flow',
    },
    {
      'title': 'Consecutive count of number',
      'difficulty': 'Hard',
      'category': 'Nested Flow',
    },
    {
      'title': 'Find same char pairs (Nested)',
      'difficulty': 'Hard',
      'category': 'Nested Flow',
    },
    {
      'title': 'Increasing chars pattern (A, AB..)',
      'difficulty': 'Medium',
      'category': 'Nested Flow',
    },
    {
      'title': 'Pascal\'s Triangle (N rows)',
      'difficulty': 'Hard',
      'category': 'Nested Flow',
    },
    {
      'title': 'Fibonacci up to N (Recursion)',
      'difficulty': 'Hard',
      'category': 'Nested Flow',
    },
    {
      'title': 'Spiral Pattern Number Print',
      'difficulty': 'Hard',
      'category': 'Nested Flow',
    },
    {
      'title': 'Count students passed (>= 40)',
      'difficulty': 'Basic',
      'category': 'Applied Logic',
    },
    {
      'title': 'Count Adults/Minors/Seniors',
      'difficulty': 'Basic',
      'category': 'Applied Logic',
    },
    {
      'title': 'Password Complexity Validation',
      'difficulty': 'Hard',
      'category': 'Applied Logic',
    },
    {
      'title': 'Calculator (Switch-case)',
      'difficulty': 'Basic',
      'category': 'Applied Logic',
    },
    {
      'title': 'Heads/Tails count (Random)',
      'difficulty': 'Medium',
      'category': 'Applied Logic',
    },
    {
      'title': 'Digit frequency in number',
      'difficulty': 'Hard',
      'category': 'Applied Logic',
    },
    {
      'title': 'Common Elements (2 Arrays)',
      'difficulty': 'Medium',
      'category': 'Applied Logic',
    },
    {
      'title': 'Common Chars (2 Strings)',
      'difficulty': 'Medium',
      'category': 'Applied Logic',
    },
    {
      'title': 'Prime count in Array',
      'difficulty': 'Hard',
      'category': 'Applied Logic',
    },
    {
      'title': 'All palindromic words in sentence',
      'difficulty': 'Hard',
      'category': 'Applied Logic',
    },
  ];

  Color _getDifficultyColor(String diff) {
    switch (diff) {
      case 'Basic':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _getCount(String difficulty) {
    if (difficulty == 'All') return _allChallenges.length;
    return _allChallenges.where((c) => c['difficulty'] == difficulty).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, String>> filteredChallenges =
        _selectedFilter == 'All'
        ? _allChallenges
        : _allChallenges
              .where((c) => c['difficulty'] == _selectedFilter)
              .toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Coding Challenges',
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
              ),
            ),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // --- Top Filter Section ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFilterChip('All', Colors.indigo, isDark),
                      _buildFilterChip('Basic', Colors.green, isDark),
                      _buildFilterChip('Medium', Colors.orange, isDark),
                      _buildFilterChip('Hard', Colors.red, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredChallenges[index];
                  final difficulty = item['difficulty']!;
                  final diffColor = _getDifficultyColor(difficulty);

                  return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey.shade100,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChallengeDetailScreen(challenge: item),
                                ),
                              );
                              
                              if (result == true) {
                                ref.read(xpProvider.notifier).addXP(25);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Challenge Completed! +25 XP Earned'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: diffColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.code_rounded,
                                      color: diffColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              difficulty,
                                              style: TextStyle(
                                                color: diffColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade400,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              item['category']!,
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (20 * index).ms)
                      .slideX(begin: 0.05, end: 0);
                },
                childCount: filteredChallenges.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, bool isDark) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_getCount(label)} Qs',
              style: TextStyle(
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
