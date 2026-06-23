import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../Analytics/AdminAnalytics.dart';

// Detail Screens
import 'payroll_detail_view.dart';
import 'performance_view_matrix.dart';
import 'skill_analysis_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for real-time data updates
    final employeeProvider = context.watch<EmployeeProvider>();
    final analytics = AdminAnalytics.fromEmployeeList(employeeProvider.employees);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        title: const Text('Executive Command Center'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Operations Summary"),
            const SizedBox(height: 12),
            _buildMetricsGrid(analytics),

            const SizedBox(height: 24),
            _buildSectionTitle("Staffing Trends (Growth Index)"),
            _buildLineChartCard(analytics),

            const SizedBox(height: 24),
            _buildSectionTitle("Departmental Efficiency (Click for Matrix)"),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerformanceMatrixView())
              ),
              child: _buildEfficiencyHeatmap(analytics),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Resource Allocation (Click for Payroll)"),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PayrollDetailView())
              ),
              child: _buildBudgetPie(analytics),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Skill Inventory (Click to Analyze)"),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SkillAnalysisView())
              ),
              child: _buildSkillPreview(analytics),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(AdminAnalytics analytics) {
    return Row(
      children: [
        _miniStat(
            "Avg Tenure",
            "${analytics.avgTenure.toStringAsFixed(1)} Yrs",
            Colors.purpleAccent
        ),
        const SizedBox(width: 12),
        _miniStat(
            "Efficiency Score",
            analytics.companyProductivity.toStringAsFixed(1),
            Colors.tealAccent
        ),
      ],
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16)
        ),
        child: Column(
          children: [
            Text(
                val,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)
            ),
            Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard(AdminAnalytics analytics) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20)
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true, // Ensure titles are enabled
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 0.5, // Force the chart to calculate labels every 0.5 units
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toStringAsFixed(1), // Use this to keep the .5 decimal
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _generateHiringSpots(analytics.hiringTrends),
              isCurved: true,
              color: Colors.cyanAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true,
                  color: Colors.cyanAccent.withOpacity(0.1)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyHeatmap(AdminAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: analytics.deptEfficiency.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(e.key, style: const TextStyle(fontSize: 11, color: Colors.white70))
                ),
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: e.value / 10,
                      backgroundColor: Colors.white10,
                      color: e.value > 6 ? Colors.greenAccent : Colors.orangeAccent,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                    e.value.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetPie(AdminAnalytics analytics) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: analytics.deptSalaries.entries.map((e) {
            final index = analytics.deptSalaries.keys.toList().indexOf(e.key);
            return PieChartSectionData(
              color: Colors.primaries[index % Colors.primaries.length],
              value: e.value,
              title: '${(e.value / analytics.totalMonthlyPayroll * 100).toStringAsFixed(0)}%',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSkillPreview(AdminAnalytics analytics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: analytics.topSkills.keys.take(6).map((s) => Chip(
          label: Text(s, style: const TextStyle(fontSize: 10, color: Colors.cyanAccent)),
          backgroundColor: Colors.cyan.shade900,
          side: BorderSide(color: Colors.tealAccent.shade400),
          padding: EdgeInsets.zero,
        )).toList(),
      ),
    );
  }

  // --- Logic Helpers ---

  List<FlSpot> _generateHiringSpots(Map<String, int> trends) {
    List<FlSpot> spots = [];
    var sortedYears = trends.keys.toList()..sort();
    for (int i = 0; i < sortedYears.length; i++) {
      spots.add(FlSpot(i.toDouble(), trends[sortedYears[i]]!.toDouble()));
    }
    return spots;
  }
}