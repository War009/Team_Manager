import 'package:flutter/material.dart';

enum PredictionResult {
  star(
    label: "High Potential",
    color: Colors.green,
    desc: "Ready for leadership. High impact contributor.",
    recommendation: "Consider for promotion or lead roles in upcoming sprints.",
  ),
  steady(
    label: "Steady Performer",
    color: Colors.blue, // Changed to Blue for a professional "Steady" look
    desc: "Consistent output. Reliable for core projects.",
    recommendation: "Maintain current workload. Provide specialized skill training.",
  ),
  improving(
    label: "Rising Talent",
    color: Colors.teal,
    desc: "Showing significant growth in quality and reliability.",
    recommendation: "Assign a mentor to accelerate their transition to 'Star' status.",
  ),
  atRisk(
    label: "Performance Risk",
    color: Colors.red,
    desc: "Declining metrics. Needs immediate review.",
    recommendation: "Schedule a 1-on-1 performance review. Check for burnout.",
  );

  final String label;
  final Color color;
  final String desc;
  final String recommendation;

  const PredictionResult({
    required this.label,
    required this.color,
    required this.desc,
    required this.recommendation,
  });
}

class PerformanceAnalysis {
  final PredictionResult result;
  final double confidence; // 0.0 to 1.0
  final double internalScore;

  PerformanceAnalysis({
    required this.result,
    required this.confidence,
    required this.internalScore,
  });
}

class PerformancePredictor {
  static PerformanceAnalysis predict({
    required double attendance,   // 0.0 - 5.0
    required int skillsCount,      // Total count
    required double quality,      // 0.0 - 5.0
  }) {
    // 1. Normalize Skill Score (Cap at 5 skills for max points)
    double skillScore = (skillsCount / 5.0).clamp(0.0, 1.0) * 5.0;

    // 2. Define Weights (Quality is most important, then Attendance, then Skills)
    // Total weight must equal 1.0
    const wQuality = 0.50;
    const wAttendance = 0.30;
    const wSkills = 0.20;

    // 3. Calculate Weighted Total (0.0 - 5.0 scale)
    double finalScore = (quality * wQuality) +
        (attendance * wAttendance) +
        (skillScore * wSkills);

    // 4. Determine Result based on Weighted Score
    PredictionResult result;
    if (finalScore >= 4.2) {
      result = PredictionResult.star;
    } else if (finalScore >= 3.5) {
      // Logic for "Improving": High quality but maybe lower attendance/skills
      result = (quality >= 4.0) ? PredictionResult.improving : PredictionResult.steady;
    } else if (finalScore >= 2.8) {
      result = PredictionResult.steady;
    } else {
      result = PredictionResult.atRisk;
    }

    // 5. Calculate Confidence Level
    // Confidence is higher if the metrics are consistent with each other
    double variance = (quality - attendance).abs();
    double confidence = (1.0 - (variance / 5.0)).clamp(0.5, 0.98);

    return PerformanceAnalysis(
      result: result,
      confidence: confidence,
      internalScore: finalScore,
    );
  }
}