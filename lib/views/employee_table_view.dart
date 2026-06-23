import 'package:employee_management/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import 'add_employee_form.dart';
import 'edit_employee_form.dart';

class EmployeeTableView extends StatefulWidget {
  const EmployeeTableView({Key? key}) : super(key: key);

  @override
  State<EmployeeTableView> createState() => _EmployeeTableViewState();
}

class _EmployeeTableViewState extends State<EmployeeTableView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _pageSize = 50;
  String _sortColumn = 'name';
  bool _sortAscending = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    setState(() {
      _currentPage++;
    });
  }

  void _sortTable(String columnName, bool ascending) {
    setState(() {
      _sortColumn = columnName;
      _sortAscending = ascending;
    });
  }

  List<Employee> _getSortedEmployees(List<Employee> employees) {
    employees.sort((a, b) {
      int comparison;
      switch (_sortColumn) {
        case 'name':
          comparison = a.fullName.compareTo(b.fullName);
          break;
        case 'salary':
          comparison = a.salary.compareTo(b.salary);
          break;
        case 'performance':
          comparison = a.performance.overallScore.compareTo(
            b.performance.overallScore,
          );
          break;
        case 'department':
          comparison = a.department.compareTo(b.department);
          break;
        case 'position':
          comparison = a.position.compareTo(b.position);
          break;
        default:
          comparison = a.fullName.compareTo(b.fullName);
      }
      return _sortAscending ? comparison : -comparison;
    });
    return employees;
  }

  List<Employee> _getPaginatedEmployees(List<Employee> employees) {
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;
    return employees.sublist(
      0,
      end > employees.length ? employees.length : end,
    );
  }

  void _showAddEmployeeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const AddEmployeeForm(),
          ),
        );
      },
    );
  }

  void _handleEdit(Employee employee) {
    // Pass the existing employee object to your AddEmployeeForm
    // (You may need to update AddEmployeeForm to accept an optional 'employee' parameter)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditEmployeeForm(employee: employee),
    );
  }

  void _handleDelete(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<EmployeeProvider>(context, listen: false).deleteEmployee(employee.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = Provider.of<EmployeeProvider>(context);
    final theme = Theme.of(context);

    final sortedEmployees = _getSortedEmployees(
      List.from(provider.filteredEmployees),
    );
    final displayedEmployees = _getPaginatedEmployees(sortedEmployees);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: const Text('Employee Directory', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showExportDialog(context, provider),
            tooltip: 'Export Data',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildMetricHeader(provider),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return _buildMobileTable(displayedEmployees);
                  } else {
                    return _buildDesktopTable(displayedEmployees, theme);
                  }
                },
              ),
            ),
          ),
          _buildPaginationFooter(sortedEmployees.length),
        ],
      ),
// In your Scaffold
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30.0), // Adds 20px of space from the bottom
        child: FloatingActionButton.extended(
          onPressed: _showAddEmployeeForm,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Employee'),
        ),
      ),
    );
  }

  Widget _buildMetricHeader(EmployeeProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _buildMetricCard(
            'Total Staff',
            provider.filteredEmployees.length.toString(),
            Icons.group_outlined,
            Colors.blue,
          ),
          _buildMetricCard(
            'Avg Salary',
            '\$${_getAverageSalary(provider.filteredEmployees).toStringAsFixed(0)}',
            Icons.payments_outlined,
            Colors.green,
          ),
          _buildMetricCard(
            'Avg Perf',
            '${_getAveragePerformance(provider.filteredEmployees)}/5.0',
            Icons.insights_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<Employee> employees, ThemeData theme) {
    return Theme(
      data: theme.copyWith(dividerColor: theme.dividerColor.withOpacity(0.05)),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.4)),
            dataRowMaxHeight: 70,
            columnSpacing: 20,
            sortColumnIndex: _getSortColumnIndex(),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(label: const Text('EMPLOYEE'), onSort: (i, a) => _sortTable('name', a)),
              DataColumn(label: const Text('DEPT & ROLE'), onSort: (i, a) => _sortTable('department', a)),
              DataColumn(label: const Text('SALARY'), numeric: true, onSort: (i, a) => _sortTable('salary', a)),
              DataColumn(label: const SizedBox(width: 140, child: Text('PERFORMANCE')), onSort: (i, a) => _sortTable('performance', a)),
              const DataColumn(label: Text('SKILLS')),
              const DataColumn(label: Text('ACTIONS')),
            ],
            rows: employees.map((employee) => DataRow(
              cells: [
                DataCell(_buildEmployeeCell(employee)),
                DataCell(_buildRoleBadge(employee)),
                DataCell(Text('\$${employee.salary.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    width: 150, // Explicitly set width to ensure the Row (bar + text) fits
                    alignment: Alignment.centerLeft,
                    child: _buildPerformanceCell(employee.performance.overallScore),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      employee.skills.take(3).join(', '),
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _handleEdit(employee)),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _handleDelete(context, employee)),
                    ],
                  ),
                ),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(Employee employee) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(employee.position, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            employee.department.toUpperCase(),
            style: const TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTable(List<Employee> employees) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                      child: Text(employee.firstName[0] + employee.lastName[0]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(employee.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(employee.position, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('\$${employee.salary.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const Divider(height: 24),
                // Inside _buildMobileTable's ListView.builder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPerformanceIndicator(employee.performance.overallScore),

                    // --- NEW: Edit/Delete Buttons ---
                    Row(
                      children: [
                        Text(employee.department, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _handleEdit(employee),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _handleDelete(context, employee),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeCell(Employee employee) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Text(
            employee.firstName[0] + employee.lastName[0],
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(employee.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCell(double score) {
    return SizedBox( // Explicit size for the cell content
      width: 140,
      child: Row(
        children: [
          _buildPerformanceIndicator(score),
          const SizedBox(width: 8),
          Text(
            '${score.toStringAsFixed(1)}/5.0',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator(double score) {
    // Clamp the score to ensure it never goes above 5.0 or below 0.0
    final double validScore = score.clamp(0.0, 5.0);

    return Container(
      width: 80, // Fixed width for the track
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(3),
      ),
      // Use Align with a widthFactor calculation instead of FractionallySizedBox
      // It is more robust inside Rows/Tables
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: validScore / 5.0,
          child: Container(
            decoration: BoxDecoration(
              color: _getPerformanceColor(validScore),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Text(
            'Showing ${_pageSize * _currentPage + 1} to ${(_pageSize * (_currentPage + 1)).clamp(0, total)} of $total',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Spacer(),
          TextButton(
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            child: const Text('Previous'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: (_currentPage + 1) * _pageSize < total ? _loadMoreData : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  // --- Utility Methods ---

  int _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'name': return 0;
      case 'department': return 1;
      case 'salary': return 2;
      case 'performance': return 3;
      default: return 0;
    }
  }

  double _getAverageSalary(List<Employee> employees) {
    if (employees.isEmpty) return 0;
    return employees.map((e) => e.salary).reduce((a, b) => a + b) / employees.length;
  }

  String _getAveragePerformance(List<Employee> employees) {
    if (employees.isEmpty) return '0.0';
    final avg = employees.map((e) => e.performance.overallScore).reduce((a, b) => a + b) / employees.length;
    return avg.toStringAsFixed(1);
  }

  Color _getPerformanceColor(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 3.5) return Colors.orange;
    return Colors.red;
  }

  void _showExportDialog(BuildContext context, EmployeeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Workforce Data'),
        content: const Text('Select your preferred file format for export.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(context);
              provider.exportData('csv');
            },
            child: const Text('CSV'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              provider.exportData('pdf');
            },
            child: const Text('PDF Report'),
          ),
        ],
      ),
    );
  }
}