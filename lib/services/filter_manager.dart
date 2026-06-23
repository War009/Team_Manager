class EmployeeFilter {
  String? department;
  double? minSalary;
  double? maxSalary;
  List<String>? skills;
  String? searchQuery;
  String sortBy;
  bool sortAscending;
  String? position;
  DateTime? joinDateFrom;
  DateTime? joinDateTo;

  EmployeeFilter({
    this.department,
    this.minSalary,
    this.maxSalary,
    this.skills,
    this.searchQuery,
    this.sortBy = 'name',
    this.sortAscending = true,
    this.position,
    this.joinDateFrom,
    this.joinDateTo,
  });

  EmployeeFilter copyWith({
    String? department,
    double? minSalary,
    double? maxSalary,
    List<String>? skills,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    String? position,
    DateTime? joinDateFrom,
    DateTime? joinDateTo,
  }) {
    return EmployeeFilter(
      department: department ?? this.department,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      skills: skills ?? this.skills,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      position: position ?? this.position,
      joinDateFrom: joinDateFrom ?? this.joinDateFrom,
      joinDateTo: joinDateTo ?? this.joinDateTo,
    );
  }

  bool get hasActiveFilters {
    return department != null ||
        minSalary != null ||
        maxSalary != null ||
        (skills != null && skills!.isNotEmpty) ||
        position != null ||
        joinDateFrom != null ||
        joinDateTo != null;
  }
}

class FilterManager {
  EmployeeFilter _currentFilter = EmployeeFilter();

  EmployeeFilter get currentFilter => _currentFilter;

  void updateFilter(EmployeeFilter newFilter) {
    _currentFilter = newFilter;
  }

  void resetFilter() {
    _currentFilter = EmployeeFilter();
  }
}
