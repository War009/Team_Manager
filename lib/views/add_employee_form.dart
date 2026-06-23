// lib/views/add_employee_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';

class AddEmployeeForm extends StatefulWidget {
  final Employee? employee; // Add this
  const AddEmployeeForm({super.key, this.employee});

  @override
  State<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  // Basic Information
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Work Details
  final _salaryController = TextEditingController(text: "50000");
  final _positionController = TextEditingController(text: "Junior Flutter Developer");
  final _managerIdController = TextEditingController();
  final _skillsController = TextEditingController();

  // 🔥 Performance Metrics Controllers
  final _productivityController = TextEditingController(text: "3.0");
  final _qualityController = TextEditingController(text: "3.0");
  final _perfAttendanceScoreController = TextEditingController(text: "5.0");
  final _reviewNotesController = TextEditingController(text: "New Hire - Probation");

  // 🔥 Attendance Record Controllers
  final _presentDaysController = TextEditingController(text: "0");
  final _absentDaysController = TextEditingController(text: "0");
  final _lateDaysController = TextEditingController(text: "0");
  final _leaveDaysController = TextEditingController(text: "0");

  String _department = 'Mobile Development';
  bool _isLoading = false;

  final List<String> _departments = [
    'Mobile Development', 'Web Development', 'Backend Development',
    'UI/UX Design', 'Quality Assurance', 'DevOps',
    'Project Management', 'Sales & Marketing',
  ];

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _skillsController.dispose();
    _managerIdController.dispose();
    _productivityController.dispose();
    _qualityController.dispose();
    _perfAttendanceScoreController.dispose();
    _reviewNotesController.dispose();
    _presentDaysController.dispose();
    _absentDaysController.dispose();
    _lateDaysController.dispose();
    _leaveDaysController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      List<String> skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (skillsList.isEmpty) skillsList = ['General'];

      final newEmployee = Employee(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? 'N/A' : _phoneController.text.trim(),
        department: _department,
        position: _positionController.text.trim(),
        salary: double.tryParse(_salaryController.text) ?? 50000.0,
        joinDate: DateTime.now(),
        managerId: _managerIdController.text.trim().isEmpty ? 'None' : _managerIdController.text.trim(),
        skills: skillsList,

        // 🔥 Performance Metrics (Using user input)
        performance: PerformanceMetrics(
          productivity: double.tryParse(_productivityController.text) ?? 3.0,
          quality: double.tryParse(_qualityController.text) ?? 3.0,
          attendanceScore: double.tryParse(_perfAttendanceScoreController.text) ?? 5.0,
          lastReviewDate: DateTime.now(),
          reviewNotes: _reviewNotesController.text.trim(),
        ),

        // 🔥 Attendance Record (Using user input)
        attendance: AttendanceRecord(
          presentDays: int.tryParse(_presentDaysController.text) ?? 0,
          absentDays: int.tryParse(_absentDaysController.text) ?? 0,
          lateDays: int.tryParse(_lateDaysController.text) ?? 0,
          leaveDays: int.tryParse(_leaveDaysController.text) ?? 0,
        ),
        profileImage: null,
      );

      await Provider.of<EmployeeProvider>(context, listen: false).addEmployee(newEmployee);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionTitle('Basic Information'),
              _buildTextField(_firstNameController, 'First Name', Icons.person),
              _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
              _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone),

              const SizedBox(height: 10),
              _buildSectionTitle('Work Details'),
              _buildDepartmentDropdown(),
              _buildTextField(_positionController, 'Job Position', Icons.work),
              _buildTextField(_salaryController, 'Annual Salary', Icons.attach_money, isNumber: true),
              _buildTextField(_managerIdController, 'Manager ID', Icons.supervisor_account),

              const SizedBox(height: 10),
              _buildSectionTitle('Skills'),
              _buildTextField(_skillsController, 'Skills (comma separated)', Icons.bolt, hint: 'e.g. Flutter, Dart'),

              const SizedBox(height: 20),

              // 🔥 NEW: Performance Metrics Expansion
              ExpansionTile(
                leading: const Icon(Icons.speed, color: Colors.blue),
                title: const Text('Performance Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  _buildTextField(_productivityController, 'Productivity (1-5)', Icons.trending_up, isNumber: true),
                  _buildTextField(_qualityController, 'Quality (1-5)', Icons.check_circle_outline, isNumber: true),
                  _buildTextField(_perfAttendanceScoreController, 'Attendance Score (1-5)', Icons.fact_check, isNumber: true),
                  _buildTextField(_reviewNotesController, 'Review Notes', Icons.note_add),
                ],
              ),

              // 🔥 NEW: Attendance Record Expansion
              ExpansionTile(
                leading: const Icon(Icons.calendar_month, color: Colors.green),
                title: const Text('Attendance Record', style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  _buildTextField(_presentDaysController, 'Present Days', Icons.today, isNumber: true),
                  _buildTextField(_absentDaysController, 'Absent Days', Icons.event_busy, isNumber: true),
                  _buildTextField(_lateDaysController, 'Late Days', Icons.more_time, isNumber: true),
                  _buildTextField(_leaveDaysController, 'Leave Days', Icons.beach_access, isNumber: true),
                ],
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Add Employee to System'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets (Same as yours, just updated for reuse)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isEmail = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: _department,
        decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business)),
        items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: (val) => setState(() => _department = val!),
      ),
    );
  }
}