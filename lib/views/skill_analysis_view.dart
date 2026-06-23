import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../Analytics/AdminAnalytics.dart';

class SkillAnalysisView extends StatelessWidget {
  const SkillAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = AdminAnalytics.fromEmployeeList(
      context.watch<EmployeeProvider>().employees,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Skill Cloud Analysis"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Technology Stack Frequency",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              "Distribution of expertise across the engineering team.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildSkillChart(analytics),
            const SizedBox(height: 30),
            const Text(
              "Inventory Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),
            _buildSkillList(analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChart(AdminAnalytics analytics) {
    return Container(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          // Fixed the padding error here
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < analytics.topSkills.length) {
                    return Text(
                      analytics.topSkills.keys.elementAt(value.toInt()),
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _buildGroups(analytics.topSkills),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups(Map<String, int> skills) {
    int i = 0;
    return skills.entries.map((e) {
      return BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            color: Colors.purpleAccent,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildSkillList(AdminAnalytics analytics) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: analytics.topSkills.length,
      itemBuilder: (context, index) {
        String skill = analytics.topSkills.keys.elementAt(index);
        int count = analytics.topSkills[skill]!;

        return Card(
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.2),
              child: Text("${index + 1}", style: const TextStyle(color: Colors.purpleAccent)),
            ),
            title: Text(skill, style: const TextStyle(color: Colors.white)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$count Devs",
                style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}