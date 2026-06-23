import 'package:employee_management/models/employee.dart';
import 'package:employee_management/services/filter_manager.dart';
import 'package:employee_management/views/employee_card_view.dart';
import 'package:employee_management/views/employee_table_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/employee_list_item.dart';
import '../widgets/search_debounce.dart';

class EmployeeListView extends StatefulWidget {
  const EmployeeListView({Key? key}) : super(key: key);

  @override
  State<EmployeeListView> createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends State<EmployeeListView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SearchDebounce _searchDebounce = SearchDebounce(milliseconds: 500);
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Keeping the listener but removing the logic inside _onScroll
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      if (provider.employees.isEmpty) {
        provider.initializeData();
      }
    });
  }

  // 🔥 SIMPLIFIED: Removed pagination check
  void _onScroll() {
    // Logic removed as loadMoreEmployees is no longer used.
  }

  void _onSearchChanged() {
    _searchDebounce.run(() {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      provider.searchEmployees(_searchController.text);
    });
  }

  void _onSearchSubmitted(String value) {
    final provider = Provider.of<EmployeeProvider>(context, listen: false);
    provider.searchEmployees(value);
    // Hide keyboard after search
    _searchFocusNode.unfocus();
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<EmployeeProvider>(context, listen: false);
    await provider.refreshData();
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // AuthWrapper should handle navigation back to LoginView
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to log out.')));
      }
    }
  }

  // NOTE: The AppBar actions now only contain the MultiSelect controls and Logout,
  // as per your previous instruction.

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = Provider.of<EmployeeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Search Bar
          _buildSearchBar(provider),

          // Employee List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildEmployeeList(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(EmployeeProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search employees (name, department, skills)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchEmployees('');
                        },
                      )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              onSubmitted: _onSearchSubmitted,

              onChanged: (value) {
                _searchDebounce.run(() {
                  provider.searchEmployees(value);
                });
              },
            ),
          ),

          const SizedBox(width: 8),

          // Add a search button for additional clarity
          IconButton(
            icon: const Icon(Icons.search),

            onPressed: () {
              _onSearchSubmitted(_searchController.text);
            },

            tooltip: 'Search',
          ),
        ],
      ),
    );
  }

  String _buildFilterDescription(EmployeeFilter filter) {
    final List<String> filters = [];

    if (filter.department != null) filters.add('Dept: ${filter.department}');

    if (filter.minSalary != null) filters.add('Min: \$${filter.minSalary}');

    if (filter.maxSalary != null) filters.add('Max: \$${filter.maxSalary}');

    if (filter.skills != null && filter.skills!.isNotEmpty) {
      filters.add('Skills: ${filter.skills!.take(2).join(', ')}');
    }

    if (filter.position != null) filters.add('Position: ${filter.position}');

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      filters.add('Search: "${filter.searchQuery}"');
    }
    return 'Filters: ${filters.join(' • ')}';
  }

  Widget _buildEmployeeList(EmployeeProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.filteredEmployees.isEmpty) {
      return _buildEmptyState(provider);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.filteredEmployees.length,
      itemBuilder: (context, index) {

        final employee = provider.filteredEmployees[index];
        final isSelected = provider.selectedEmployees.contains(employee);

        return EmployeeListItem(
          key: ValueKey(employee.id),
          employee: employee,
          isSelected: isSelected,
          isMultiSelect: provider.isMultiSelect,
          onTap: () {
            if (provider.isMultiSelect) {
              provider.toggleEmployeeSelection(employee);
            } else {
              _showEmployeeDetails(context, employee);
            }
          },
          onLongPress: () {
            if (!provider.isMultiSelect) {
              provider.toggleMultiSelect();
            }
            provider.toggleEmployeeSelection(employee);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(EmployeeProvider provider) {
    final hasSearch =
        provider.currentFilter.searchQuery != null &&
        provider.currentFilter.searchQuery!.isNotEmpty;

    final hasOtherFilters = provider.currentFilter.hasActiveFilters;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.people_outline,

            size: 64,

            color: Colors.grey,
          ),

          const SizedBox(height: 16),

          Text(
            hasSearch ? 'No employees found' : 'No employees available',

            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 8),

          Text(
            hasSearch
                ? 'Try different search terms or clear filters'
                : (hasOtherFilters
                      ? 'Try clearing your filters'
                      : 'Employees will appear here'),

            style: const TextStyle(color: Colors.grey),

            textAlign: TextAlign.center,
          ),

          if (hasSearch || hasOtherFilters) ...[
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                _searchController.clear();

                provider.updateFilter(EmployeeFilter());
              },

              child: const Text('Clear Search & Filters'),
            ),
          ],
        ],
      ),
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      builder: (context) => EmployeeDetailSheet(employee: employee),
    );
  }

  // ℹ️ ADDED _handleViewChange method that was missing in the provided code block
  void _handleViewChange(String value, EmployeeProvider provider) {
    switch (value) {
      case 'list':
        // Current view, no navigation needed
        break;
      case 'table':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeTableView()),
        );
        break;
      case 'grid':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeCardView()),
        );
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

class EmployeeDetailSheet extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailSheet({Key? key, required this.employee})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _getDepartmentColor(
                  employee.department,
                ).withOpacity(0.2),
                child: Text(
                  employee.firstName[0] + employee.lastName[0],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getDepartmentColor(employee.department),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      employee.position,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      employee.department,
                      style: TextStyle(
                        color: _getDepartmentColor(employee.department),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          _buildDetailRow('Email', employee.email),
          _buildDetailRow('Phone', employee.phone),
          _buildDetailRow(
            'Join Date',
            '${employee.joinDate.day}/${employee.joinDate.month}/${employee.joinDate.year}',
          ),
          _buildDetailRow('Salary', '\$${employee.salary.toStringAsFixed(0)}'),
          _buildDetailRow(
            'Performance',
            '${employee.performance.overallScore.toStringAsFixed(1)}/5.0',
          ),
          const SizedBox(height: 16),
          const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: employee.skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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
}
