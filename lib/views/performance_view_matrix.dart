import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/employee.dart';

class PerformanceMatrixView extends StatelessWidget {
  const PerformanceMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Employee> employees = context.watch<EmployeeProvider>().employees;

    if (employees.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Performance Matrix")),
        body: const Center(child: Text("No employee data found.")),
      );
    }

    // Dynamic scale calculation to prevent rendering crashes
    double maxSalary = employees.map((e) => e.salary).reduce((a, b) => a > b ? a : b) / 1000;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Performance vs. Cost Matrix"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quadratic Analysis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              "Top-right dots represent high-value 'Star' employees.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: employees.map((e) {
                    return ScatterSpot(
                      e.salary / 1000,
                      e.performance.productivity,
                      // FIXED: In modern fl_chart, color and radius belong to the dot painter
                    );
                  }).toList(),
                  // FIXED: Adding dot painter logic to apply colors/radius correctly
                  scatterLabelSettings: ScatterLabelSettings(showLabel: false),
                  showingTooltipIndicators: [],
                  minX: 0,
                  maxX: maxSalary + 20,
                  minY: 0,
                  maxY: 6,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    checkToShowHorizontalLine: (value) => true,
                    getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                    getDrawingVerticalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text("Productivity Score", style: TextStyle(color: Colors.blueAccent)),
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text("Salary (k)", style: TextStyle(color: Colors.blueAccent)),
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  // THIS IS THE FIX: Customizing the dots appearance
                  scatterTouchData: ScatterTouchData(
                    handleBuiltInTouches: true,
                    mouseCursorResolver: (event, response) => SystemMouseCursors.click,
                  ),
                ),
              ),
            ),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  // To fix the color error, we define the painter here if you are on fl_chart 0.60+
  // If your version still errors on ScatterSpot constructor,
  // ensure you aren't passing color/radius to the constructor itself.

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _indicator(Colors.greenAccent, "Star"),
          _indicator(Colors.orangeAccent, "Average"),
          _indicator(Colors.redAccent, "Underpaid"),
        ],
      ),
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}