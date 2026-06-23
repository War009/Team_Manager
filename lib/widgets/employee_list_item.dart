import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeListItem extends StatelessWidget {
  final Employee employee;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const EmployeeListItem({
    Key? key,
    required this.employee,
    required this.isSelected,
    required this.isMultiSelect,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected ? Colors.blue[50] : null,
      child: ListTile(
        leading: _buildLeading(context),
        title: Text(
          employee.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.blue[800] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.position),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDepartmentColor(
                      employee.department,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getDepartmentColor(
                        employee.department,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    employee.department,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getDepartmentColor(employee.department),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${employee.salary.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildTrailing(),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _getDepartmentColor(
            employee.department,
          ).withOpacity(0.2),
          child: Text(
            employee.firstName[0] + employee.lastName[0],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getDepartmentColor(employee.department),
            ),
          ),
        ),
        if (isMultiSelect)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: employee.performance.overallScore / 5.0,
            child: Container(
              decoration: BoxDecoration(
                color: _getPerformanceColor(employee.performance.overallScore),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${employee.performance.overallScore.toStringAsFixed(1)}/5.0',
          style: TextStyle(
            fontSize: 10,
            color: _getPerformanceColor(employee.performance.overallScore),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getDepartmentColor(String department) {
    final colors = {
      'Mobile Development': Colors.blue,
      'Web Development': Colors.green,
      'Backend Development': Colors.orange,
      'UI/UX Design': Colors.purple,
      'Quality Assurance': Colors.red,
      'DevOps': Colors.teal,
      'Project Management': Colors.pink,
      'Business Analysis': Colors.brown,
      'Data Science': Colors.indigo,
      'AI/ML Engineering': Colors.cyan,
      'Technical Support': Colors.amber,
      'Sales & Marketing': Colors.lime,
    };
    return colors[department] ?? Colors.grey;
  }

  Color _getPerformanceColor(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 4.0) return Colors.lightGreen;
    if (score >= 3.5) return Colors.orange;
    return Colors.red;
  }
}
