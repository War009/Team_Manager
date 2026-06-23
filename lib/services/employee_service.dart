import '../models/employee.dart';
import 'package:firebase_database/firebase_database.dart'; // Import RTDB

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('employees');

  List<Employee> _employees = [];
  bool _isInitialized = false;

  List<Employee> get employees => _employees;

  Future<List<Employee>> _fetchEmployeesFromRTDB() async {
    try {
      // 1. Get the snapshot
      final dataSnapshot = await _dbRef.get();

      if (!dataSnapshot.exists || dataSnapshot.value == null) {
        return [];
      }

      // 2. Cast the top-level value to a Map first
      final Map<dynamic, dynamic> employeesData = dataSnapshot.value as Map;
      final List<Employee> fetchedEmployees = [];

      // 3. Iterate and convert each entry
      employeesData.forEach((key, value) {
        fetchedEmployees.add(
          Employee.fromMap(key.toString(), value as Map),
        );
      });
      return fetchedEmployees;
    } catch (e) {
      print('Error fetching data from Firebase RTDB: $e');
      return [];
    }
  }
  Future<void> initializeData() async {
    if (!_isInitialized) {
      _employees = await _fetchEmployeesFromRTDB();
      _isInitialized = true;
    }
  }
  Future<void> addEmployeeToRealtimeDB(Employee newEmployee) async {
    try {
      final employeeMap = newEmployee.toMap();
      await _dbRef.child(newEmployee.id).set(employeeMap);

      print('Employee added to Realtime Database with ID: ${newEmployee.id}');

      if (!_employees.any((e) => e.id == newEmployee.id)) {
        _employees.add(newEmployee);}

      }catch(e) {
        print('Error adding employee to RTDB: $e');
        rethrow;
    }
  }

  // --- UPDATED: Sync Update to Firebase ---
  Future<void> updateEmployeeInDB(Employee updatedEmployee) async {
    try {
      // 1. Update in Firebase RTDB
      await _dbRef.child(updatedEmployee.id).update(updatedEmployee.toMap());

      // 2. Update local cache
      final index = _employees.indexWhere((e) => e.id == updatedEmployee.id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }
      print('Employee ${updatedEmployee.id} updated in database');
    } catch (e) {
      print('Error updating employee in RTDB: $e');
      rethrow;
    }
  }

  // --- NEW: Sync Delete to Firebase ---
  Future<void> deleteEmployeeFromDB(String id) async {
    try {
      // 1. Remove from Firebase RTDB
      await _dbRef.child(id).remove();

      // 2. Remove from local cache
      _employees.removeWhere((e) => e.id == id);
      print('Employee $id deleted from database');
    } catch (e) {
      print('Error deleting employee from RTDB: $e');
      rethrow;
    }
  }

  // Fixed Search Method
  List<Employee> searchEmployees(String query) {
    if (query.isEmpty) return _employees;

    final lowercaseQuery = query.toLowerCase().trim();

    return _employees.where((employee) {
      // Search in name
      if (employee.fullName.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      if (employee.email.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      if (employee.department.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      if (employee.position.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      for (final skill in employee.skills) {
        if (skill.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  // Rest of your existing methods...
  Future<List<Employee>> getEmployeesPaginated(int page, int pageSize) async {
    final start = page * pageSize;
    final end = start + pageSize;

    if (start >= _employees.length) {
      return [];
    }

    await Future.delayed(const Duration(milliseconds: 500));

    return _employees.sublist(
      start,
      end > _employees.length ? _employees.length : end,
    );
  }

    List<Employee> filterEmployees({
    List<Employee>? listToFilter, // 🔥 ADD THIS PARAMETER
    String? department,
    double? minSalary,
    double? maxSalary,
    List<String>? skills,
    String? position,
  }) {
    // 🔥 Start filtering with the provided list or the full internal list
    List<Employee> workingList = listToFilter ?? _employees;

    return workingList.where((employee) { // <-- Filter the working list
      bool matches = true;
      if (department != null && department.isNotEmpty) {
        matches = matches && employee.department == department;
      }
      if (minSalary != null) {
        matches = matches && employee.salary >= minSalary;
      }
      if (maxSalary != null) {
        matches = matches && employee.salary <= maxSalary;
      }
      if (skills != null && skills.isNotEmpty) {
        matches =
            matches && skills.any((skill) => employee.skills.contains(skill));
      }
      if (position != null && position.isNotEmpty) {
        matches =
            matches &&
                employee.position.toLowerCase().contains(position.toLowerCase());
      }
      return matches;
    }).toList();
  }

  List<String> getDepartments() {
    return _employees.map((e) => e.department).toSet().toList()..sort();
  }

  List<String> getAllSkills() {
    return _employees.expand((e) => e.skills).toSet().toList()..sort();
  }

  Map<String, int> getDepartmentStats() {
    final Map<String, int> stats = {};
    for (var employee in _employees) {
      stats[employee.department] = (stats[employee.department] ?? 0) + 1;
    }
    return stats;
  }

  double getAverageSalary() {
    if (_employees.isEmpty) return 0;
    return _employees.map((e) => e.salary).reduce((a, b) => a + b) /
        _employees.length;
  }

  double getDepartmentAverageSalary(String department) {
    final deptEmployees = _employees
        .where((e) => e.department == department)
        .toList();
    if (deptEmployees.isEmpty) return 0;
    return deptEmployees.map((e) => e.salary).reduce((a, b) => a + b) /
        deptEmployees.length;
  }

  Map<String, double> getSalarySummaryByDepartment() {
    final Map<String, double> summary = {};
    for (var department in getDepartments()) {
      summary[department] = getDepartmentAverageSalary(department);
    }
    return summary;
  }


}