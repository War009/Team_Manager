import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../services/filter_manager.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();
  final FilterManager _filterManager = FilterManager();

  List<Employee> _employees = []; // Master list of employees (now holds all fetched data)
  List<Employee> _filteredEmployees = [];
  List<Employee> _selectedEmployees = [];

  bool _isLoading = false;

  // View state
  ViewType _currentView = ViewType.list;
  bool _isMultiSelect = false;
  String _currentTheme = 'light';

  // Getters
  List<Employee> get employees => _employees;
  List<Employee> get filteredEmployees => _filteredEmployees;
  List<Employee> get selectedEmployees => _selectedEmployees;
  bool get isLoading => _isLoading;
  bool get hasMore => false; // Always false since we load all
  ViewType get currentView => _currentView;
  bool get isMultiSelect => _isMultiSelect;
  String get currentTheme => _currentTheme;
  EmployeeFilter get currentFilter => _filterManager.currentFilter;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners(); // Start the spinner

    try {
      // 1. Try to fetch the data
      await _employeeService.initializeData();
      _employees = List.from(_employeeService.employees);
      _applyFilters();

      debugPrint("Data initialized successfully");
    } catch (e) {
      debugPrint("FATAL ERROR during initialization: $e");

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtering
  void updateFilter(EmployeeFilter newFilter) {
    _filterManager.updateFilter(newFilter);
    _applyFilters();
  }

  Future<void> addEmployee(Employee newEmployee) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _employeeService.addEmployeeToRealtimeDB(newEmployee);
      // 2. Add to the Master List
      _employees.add(newEmployee);

      // 3. THE FORCE SYNC: Manually update the filtered list too
      // This ensures that even if a filter is active, we attempt to show the new data
      _filteredEmployees = List.from(_employees);
      _applyFilters();

      debugPrint("Employee synced locally");
    } catch (e) {
      debugPrint("Add Employee Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- UPDATED: Edit Employee ---
  Future<void> updateEmployee(Employee updatedEmployee) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Update in Service/Database
      await _employeeService.updateEmployeeInDB(updatedEmployee);

      // 2. Update in Local Master List
      final index = _employees.indexWhere((e) => e.id == updatedEmployee.id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }

      // 3. Re-apply filters to refresh the view
      _applyFilters();
      debugPrint("Employee updated locally");
    } catch (e) {
      debugPrint("Update Employee Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NEW: Delete Employee ---
  Future<void> deleteEmployee(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Delete from Service/Database
      await _employeeService.deleteEmployeeFromDB(id);

      // 2. Remove from Local Master List
      _employees.removeWhere((e) => e.id == id);

      // 3. Re-apply filters to refresh the view
      _applyFilters();
      debugPrint("Employee deleted locally");
    } catch (e) {
      debugPrint("Delete Employee Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    final filter = _filterManager.currentFilter;

    List<Employee> filtered = List.from(_employees);

    // 2. Search Query
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered.where((emp) =>
      emp.fullName.toLowerCase().contains(query) ||
          emp.department.toLowerCase().contains(query)
      ).toList();
    }

    // 3. Attribute Filters (Ensure this method accepts and returns the list)
    filtered = _employeeService.filterEmployees(
      listToFilter: filtered,
      department: filter.department,
      minSalary: filter.minSalary,
      maxSalary: filter.maxSalary,
      skills: filter.skills,
      position: filter.position,
    );

    // 4. Sorting
    _sortEmployees(filtered, filter.sortBy, filter.sortAscending);

    // 5. Update the UI state
    _filteredEmployees = filtered;
    notifyListeners();
  }

  void _sortEmployees(List<Employee> employees, String sortBy, bool ascending) {
    employees.sort((a, b) {
      int comparison;
      switch (sortBy) {
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
        case 'joinDate':
          comparison = a.joinDate.compareTo(b.joinDate);
          break;
        default:
          comparison = a.fullName.compareTo(b.fullName);
      }
      return ascending ? comparison : -comparison;
    });
  }

  void searchEmployees(String query) {
    final newFilter = _filterManager.currentFilter.copyWith(searchQuery: query);
    _filterManager.updateFilter(newFilter);
    _applyFilters();
  }

  // Selection management (remains the same)
  void toggleEmployeeSelection(Employee employee) {
    if (_selectedEmployees.contains(employee)) {
      _selectedEmployees.remove(employee);
    } else {
      _selectedEmployees.add(employee);
    }
    notifyListeners();
  }

  void selectAllEmployees() {
    _selectedEmployees = List.from(_filteredEmployees);
    notifyListeners();
  }

  void clearSelection() {
    _selectedEmployees.clear();
    notifyListeners();
  }

  // View management (remains the same)
  void setViewType(ViewType viewType) {
    _currentView = viewType;
    notifyListeners();
  }

  void toggleMultiSelect() {
    _isMultiSelect = !_isMultiSelect;
    if (!_isMultiSelect) {
      clearSelection();
    }
    notifyListeners();
  }

  // Theme management (remains the same)
  void setTheme(String theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _employees.clear();
    _filteredEmployees.clear();
    clearSelection();

    await initializeData(); // Re-initialize pulls fresh data
  }

  // Export simulation (remains the same)
  Future<void> exportData(String format) async {
    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));
    // In real app, this would generate and download the file
  }

  // Batch operations (remains the same)
  void updateSelectedEmployeesSalary(double newSalary) {
    // ... (logic to update employee in _employees list) ...
    for (final employee in _selectedEmployees) {
      final updatedEmployee = Employee(
        id: employee.id,
        firstName: employee.firstName,
        lastName: employee.lastName,
        email: employee.email,
        phone: employee.phone,
        department: employee.department,
        position: employee.position,
        salary: newSalary,
        joinDate: employee.joinDate,
        managerId: employee.managerId,
        skills: employee.skills,
        performance: employee.performance,
        attendance: employee.attendance,
        profileImage: employee.profileImage, // Ensure this is included
      );

      final index = _employees.indexWhere((e) => e.id == employee.id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }
    }
    _applyFilters();
    clearSelection();
  }
}
enum ViewType { list, table, card, grid, masonry }