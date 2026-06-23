import '../models/employee.dart'; // Ensure this matches your model filename

class AdminAnalytics {
  final int totalEmployees;
  final double averageSalary;
  final double totalMonthlyPayroll;
  final double companyProductivity;
  final double averageQualityScore;

  // --- New High-Detail Metrics ---
  final double avgTenure; // Average years spent in the company
  final Map<String, double> deptEfficiency; // ROI: (Productivity / Dept Salary) * scale

  // Grouped Data for Charts
  final Map<String, int> deptCounts;         // Employees per Dept
  final Map<String, double> deptSalaries;    // Total budget per Dept
  final Map<String, int> topSkills;          // Most common skills
  final Map<String, int> hiringTrends;       // Hires per year
  final Map<String, double> deptProductivity; // Avg productivity by Dept

  AdminAnalytics({
    required this.totalEmployees,
    required this.averageSalary,
    required this.totalMonthlyPayroll,
    required this.companyProductivity,
    required this.averageQualityScore,
    required this.avgTenure,
    required this.deptEfficiency,
    required this.deptCounts,
    required this.deptSalaries,
    required this.topSkills,
    required this.hiringTrends,
    required this.deptProductivity,
  });

  factory AdminAnalytics.fromEmployeeList(List<Employee> list) {
    if (list.isEmpty) {
      return AdminAnalytics(
        totalEmployees: 0,
        averageSalary: 0,
        totalMonthlyPayroll: 0,
        companyProductivity: 0,
        averageQualityScore: 0,
        avgTenure: 0,
        deptEfficiency: {},
        deptCounts: {},
        deptSalaries: {},
        topSkills: {},
        hiringTrends: {},
        deptProductivity: {},
      );
    }

    // Temporary variables for calculation
    double totalSal = 0;
    double totalProd = 0;
    double totalQual = 0;
    double totalTenureDays = 0;

    Map<String, int> dCounts = {};
    Map<String, double> dSalaries = {};
    Map<String, double> dProdSum = {};
    Map<String, int> sFreq = {};
    Map<String, int> hTrends = {};

    for (var emp in list) {
      // Basic Sums
      totalSal += emp.salary;
      totalProd += emp.performance.productivity;
      totalQual += emp.performance.quality;

      // Tenure Calculation (Difference between today and join date)
      totalTenureDays += DateTime.now().difference(emp.joinDate).inDays;

      // Department Logic
      dCounts[emp.department] = (dCounts[emp.department] ?? 0) + 1;
      dSalaries[emp.department] = (dSalaries[emp.department] ?? 0) + emp.salary;
      dProdSum[emp.department] = (dProdSum[emp.department] ?? 0) + emp.performance.productivity;

      // Skill Logic
      for (var skill in emp.skills) {
        sFreq[skill] = (sFreq[skill] ?? 0) + 1;
      }

      // Hiring Trend
      String year = emp.joinDate.year.toString();
      hTrends[year] = (hTrends[year] ?? 0) + 1;
    }

    // Advanced Averages & Efficiency Calculations
    Map<String, double> dAvgProd = {};
    Map<String, double> dEfficiency = {};

    dProdSum.forEach((dept, totalDeptProd) {
      double count = dCounts[dept]?.toDouble() ?? 1.0;
      double avgP = totalDeptProd / count;
      dAvgProd[dept] = avgP;

      // Efficiency Formula:
      // (Average Productivity / Total Dept Salary) * 100,000 (Scaling factor for readability)
      double deptBudget = dSalaries[dept] ?? 1.0;
      dEfficiency[dept] = (avgP / deptBudget) * 100000;
    });

    // Sort skills to get top 10
    var sortedSkills = Map.fromEntries(
        sFreq.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value))
    );

    return AdminAnalytics(
      totalEmployees: list.length,
      averageSalary: totalSal / list.length,
      totalMonthlyPayroll: totalSal,
      companyProductivity: totalProd / list.length,
      averageQualityScore: totalQual / list.length,
      avgTenure: (totalTenureDays / list.length) / 365, // Convert average days to years
      deptEfficiency: dEfficiency,
      deptCounts: dCounts,
      deptSalaries: dSalaries,
      topSkills: Map.fromEntries(sortedSkills.entries.take(10)),
      hiringTrends: hTrends,
      deptProductivity: dAvgProd,
    );
  }
}