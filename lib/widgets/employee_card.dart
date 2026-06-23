import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../utils/predictors.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const EmployeeCard({
    Key? key,
    required this.employee,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔥 The Prediction Logic
    // This should be a synchronous call to avoid "loading" flickers
    final analysis = PerformancePredictor.predict(
      attendance: employee.performance.attendanceScore,
      skillsCount: employee.skills.length,
      quality: employee.performance.quality,
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 10)] : [],
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(context),
                    const SizedBox(height: 12),
                    _buildSkillsCloud(theme),
                    const Divider(height: 24),
                    _buildAIInsightPanel(analysis, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.primaryColor.withOpacity(0.05),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  employee.position,
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildDepartmentBadge(),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMiniStat(Icons.payments_outlined, "\$${employee.salary.toStringAsFixed(0)}", "Salary"),
        _buildMiniStat(Icons.star_outline, "${employee.performance.overallScore}/5", "Rating"),
        _buildMiniStat(Icons.calendar_today_outlined, "${employee.performance.attendanceScore}%", "Attendance"),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.blueGrey),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSkillsCloud(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: employee.skills.take(4).map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(skill, style: const TextStyle(fontSize: 10)),
      )).toList(),
    );
  }

  Widget _buildAIInsightPanel(PerformanceAnalysis analysis, bool isDark) {
    final result = analysis.result;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: result.color.withOpacity(isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: result.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: result.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "AI FORECAST: ${result.label}",
                      style: TextStyle(color: result.color, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    Text(
                      "${(analysis.confidence * 100).toInt()}% Match",
                      style: TextStyle(color: result.color.withOpacity(0.7), fontSize: 9),
                    ),
                  ],
                ),
                Text(
                  result.desc,
                  style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Helpers (Avatar & Badge) remain similar to your original code
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      child: Text(employee.firstName[0] + employee.lastName[0]),
    );
  }

  Widget _buildDepartmentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        employee.department,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}