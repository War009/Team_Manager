import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../Analytics/AdminAnalytics.dart';

class PayrollDetailView extends StatelessWidget {
  const PayrollDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final analytics = AdminAnalytics.fromEmployeeList(employeeProvider.employees);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Payroll Deep-Dive"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: analytics.totalEmployees == 0
          ? const Center(child: Text("No data available", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(analytics),
            const SizedBox(height: 30),
            const Text(
              "Budget Allocation by Department",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildMainBarChart(analytics),
            const SizedBox(height: 40),
            const Text(
              "Departmental Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildPayrollTable(analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdminAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyanAccent]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TOTAL MONTHLY PAYROLL", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "PKR ${analytics.totalMonthlyPayroll.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildMainBarChart(AdminAnalytics analytics) {
    // Safety check for empty salaries to avoid reduce() error
    double maxVal = analytics.deptSalaries.isEmpty
        ? 100
        : analytics.deptSalaries.values.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.3,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < analytics.deptSalaries.length) {
                    return Padding(
                      // FIXED: Removed the semicolon and ensured proper comma usage
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        analytics.deptSalaries.keys.elementAt(value.toInt()).substring(0, 3).toUpperCase(),
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _generateBarGroups(analytics.deptSalaries),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(Map<String, double> salaries) {
    int index = 0;
    return salaries.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.cyanAccent,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildPayrollTable(AdminAnalytics analytics) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: analytics.deptSalaries.length,
      itemBuilder: (context, index) {
        String dept = analytics.deptSalaries.keys.elementAt(index);
        double amount = analytics.deptSalaries[dept]!;
        // Avoid division by zero
        double percentage = analytics.totalMonthlyPayroll > 0
            ? (amount / analytics.totalMonthlyPayroll) * 100
            : 0;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(dept, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          subtitle: Text("${percentage.toStringAsFixed(1)}% of total budget", style: const TextStyle(color: Colors.grey)),
          trailing: Text(
            "PKR ${amount.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}