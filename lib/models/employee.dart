class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;
  final String position;
  final double salary;
  final DateTime joinDate;
  final String managerId;
  final List<String> skills;
  final PerformanceMetrics performance;
  final AttendanceRecord attendance;
  final String? profileImage;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    required this.salary,
    required this.joinDate,
    required this.managerId,
    required this.skills,
    required this.performance,
    required this.attendance,
    this.profileImage,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'salary': salary,
      'joinDate': joinDate.toIso8601String(),
      'managerId': managerId,
      'skills': skills,
      'performance': performance.toMap(),
      'attendance': attendance.toMap(),
      'profileImage': profileImage,
    };
  }

  factory Employee.fromMap(String id, Map<dynamic, dynamic> map) {
    return Employee(
      id: id,
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      position: map['position']?.toString() ?? '',
      // Use (num).toDouble() to handle both 5000 and 5000.0 safely
      salary: (map['salary'] as num? ?? 0).toDouble(),
      joinDate: map['joinDate'] != null
          ? DateTime.parse(map['joinDate'] as String)
          : DateTime.now(),
      managerId: map['managerId']?.toString() ?? '',
      skills: map['skills'] != null ? List<String>.from(map['skills'] as List) : [],
      performance: PerformanceMetrics.fromMap(
        Map<String, dynamic>.from(map['performance'] as Map),
      ),
      attendance: AttendanceRecord.fromMap(
        Map<String, dynamic>.from(map['attendance'] as Map),
      ),
      profileImage: map['profileImage']?.toString(),
    );
  }
}

class PerformanceMetrics {
  final double productivity;
  final double quality;
  final double attendanceScore;
  final DateTime lastReviewDate;
  final String reviewNotes;

  PerformanceMetrics({
    required this.productivity,
    required this.quality,
    required this.attendanceScore,
    required this.lastReviewDate,
    required this.reviewNotes,
  });

  double get overallScore => (productivity + quality + attendanceScore) / 3;

  factory PerformanceMetrics.fromMap(Map<String, dynamic> map) {
    return PerformanceMetrics(
      productivity: (map['productivity'] as num? ?? 0).toDouble(),
      quality: (map['quality'] as num? ?? 0).toDouble(),
      attendanceScore: (map['attendanceScore'] as num? ?? 0).toDouble(),
      lastReviewDate: map['lastReviewDate'] != null
          ? DateTime.parse(map['lastReviewDate'] as String)
          : DateTime.now(),
      reviewNotes: map['reviewNotes']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'productivity': productivity,
      'quality': quality,
      'attendanceScore': attendanceScore,
      // Convert DateTime to String
      'lastReviewDate': lastReviewDate.toIso8601String(),
      'reviewNotes': reviewNotes,
    };
  }
}
class AttendanceRecord {
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int leaveDays;

  AttendanceRecord({
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.leaveDays,
  });
  Map<String, dynamic> toMap() {
    return {
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'leaveDays': leaveDays,
    };
  }
  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      presentDays: (map['presentDays'] as num? ?? 0).toInt(),
      absentDays: (map['absentDays'] as num? ?? 0).toInt(),
      lateDays: (map['lateDays'] as num? ?? 0).toInt(),
      leaveDays: (map['leaveDays'] as num? ?? 0).toInt(),
    );
  }
  }

class Department {
  final String id;
  final String name;
  final String managerId;
  final int employeeCount;
  final double totalBudget;

  Department({
    required this.id,
    required this.name,
    required this.managerId,
    required this.employeeCount,
    required this.totalBudget,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'managerId': managerId,
      'employeeCount': employeeCount,
      'totalBudget': totalBudget,
    };
  }
  factory Department.fromMap(Map<dynamic, dynamic> map) {
    return Department(
      // Use .toString() and null-coalescing for safety
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      managerId: map['managerId']?.toString() ?? '',

      employeeCount: (map['employeeCount'] as num? ?? 0).toInt(),
      totalBudget: (map['totalBudget'] as num? ?? 0.0).toDouble(),
    );
  }
}
