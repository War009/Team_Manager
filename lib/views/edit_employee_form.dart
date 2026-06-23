import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';

class EditEmployeeForm extends StatefulWidget {
  final Employee employee;
  const EditEmployeeForm({super.key, required this.employee});

  @override
  State<EditEmployeeForm> createState() => _EditEmployeeFormState();
}

class _EditEmployeeFormState extends State<EditEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers (Initialized with existing data)
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _salaryController;
  late final TextEditingController _positionController;
  late final TextEditingController _managerIdController;
  late final TextEditingController _skillsController;
  late final TextEditingController _productivityController;
  late final TextEditingController _qualityController;
  late final TextEditingController _perfAttendanceScoreController;
  late final TextEditingController _reviewNotesController;
  late final TextEditingController _presentDaysController;
  late final TextEditingController _absentDaysController;
  late final TextEditingController _lateDaysController;
  late final TextEditingController _leaveDaysController;

  String _department = '';

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _department = e.department;

    _firstNameController = TextEditingController(text: e.firstName);
    _lastNameController = TextEditingController(text: e.lastName);
    _emailController = TextEditingController(text: e.email);
    _phoneController = TextEditingController(text: e.phone);
    _salaryController = TextEditingController(text: e.salary.toString());
    _positionController = TextEditingController(text: e.position);
    _managerIdController = TextEditingController(text: e.managerId);
    _skillsController = TextEditingController(text: e.skills.join(', '));
    _productivityController = TextEditingController(text: e.performance.productivity.toString());
    _qualityController = TextEditingController(text: e.performance.quality.toString());
    _perfAttendanceScoreController = TextEditingController(text: e.performance.attendanceScore.toString());
    _reviewNotesController = TextEditingController(text: e.performance.reviewNotes);
    _presentDaysController = TextEditingController(text: e.attendance.presentDays.toString());
    _absentDaysController = TextEditingController(text: e.attendance.absentDays.toString());
    _lateDaysController = TextEditingController(text: e.attendance.lateDays.toString());
    _leaveDaysController = TextEditingController(text: e.attendance.leaveDays.toString());
  }

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

  Future<void> _updateForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedEmployee = Employee(
      id: widget.employee.id, // Keep the same ID
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _department,
      position: _positionController.text.trim(),
      salary: double.tryParse(_salaryController.text) ?? 0.0,
      joinDate: widget.employee.joinDate, // Preserve original join date
      managerId: _managerIdController.text.trim(),
      skills: _skillsController.text.split(',').map((s) => s.trim()).toList(),
      performance: PerformanceMetrics(
        productivity: double.tryParse(_productivityController.text) ?? 0.0,
        quality: double.tryParse(_qualityController.text) ?? 0.0,
        attendanceScore: double.tryParse(_perfAttendanceScoreController.text) ?? 0.0,
        lastReviewDate: DateTime.now(),
        reviewNotes: _reviewNotesController.text.trim(),
      ),
      attendance: AttendanceRecord(
        presentDays: int.tryParse(_presentDaysController.text) ?? 0,
        absentDays: int.tryParse(_absentDaysController.text) ?? 0,
        lateDays: int.tryParse(_lateDaysController.text) ?? 0,
        leaveDays: int.tryParse(_leaveDaysController.text) ?? 0,
      ),
      profileImage: widget.employee.profileImage,
    );

    await Provider.of<EmployeeProvider>(context, listen: false).updateEmployee(updatedEmployee);
    if (mounted) Navigator.pop(context);
  }@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Employee')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                onPressed: _updateForm,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
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

// Make sure these helper methods are included in the same class
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
        controller: controller, // THIS IS WHAT LINKS THE DATA
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
        items: ['Mobile Development', 'Web Development', 'Backend Development', 'UI/UX Design', 'Quality Assurance', 'DevOps', 'Project Management', 'Sales & Marketing']
            .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: (val) => setState(() => _department = val!),
      ),
    );
  }
}

