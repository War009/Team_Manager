import 'package:employee_management/views/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/employee_provider.dart';
import 'views/employee_list_view.dart';
import 'views/employee_table_view.dart';
import 'views/employee_card_view.dart';
import 'views/admin_dashboard_view.dart'; // 1. Import your new Dashboard
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EmployeeManagementApp());
}

class EmployeeManagementApp extends StatelessWidget {
  const EmployeeManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 2. Trigger initializeData() immediately upon creation
      create: (context) => EmployeeProvider()..initializeData(),
      child: MaterialApp(
        title: 'Software House Employee Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData.dark().copyWith(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  // 3. Add the Dashboard to the view list
  final List<Widget> _views = [
    const EmployeeListView(),
    const EmployeeTableView(),
    const EmployeeCardView(),
    const AdminDashboardView(), // New Analytics Tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the state of your lists/filters when switching tabs
      body: IndexedStack(index: _currentIndex, children: _views),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // Set type to fixed if you have 4 or more items to keep labels visible
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Table',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Cards'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}