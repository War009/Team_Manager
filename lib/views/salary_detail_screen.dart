import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../Analytics/AdminAnalytics.dart';

class SalaryDetailScreen extends StatelessWidget {
  const SalaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final analytics = AdminAnalytics.fromEmployeeList(employeeProvider.employees);

    return Scaffold(
      appBar: AppBar(title: const Text("Payroll Detail")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) => Text(analytics.deptSalaries.keys.elementAt(v.toInt()).substring(0,3)),
              )),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: _buildGroups(analytics.deptSalaries),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups(Map<String, double> data) {
    int i = 0;
    return data.entries.map((e) => BarChartGroupData(
      x: i++,
      barRods: [
        BarChartRodData(
          toY: e.value,
          color: Colors.cyanAccent,
          width: 20,
          borderRadius: BorderRadius.circular(4),
          // FIXED: Removed the problematic background rod and simplified
        ),
      ],
    )).toList();
  }
}