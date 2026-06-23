import 'package:employee_management/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/employee_card.dart'; // Ensure CardLayoutType is exported here
import '../utils/predictors.dart';

// 1. Move the Enum here if it's not exported from employee_card.dart
enum CardLayoutType { grid, masonry }

class EmployeeCardView extends StatefulWidget {
  const EmployeeCardView({Key? key}) : super(key: key);

  @override
  State<EmployeeCardView> createState() => _EmployeeCardViewState();
}

// 1. Add this variable at the top of your _EmployeeCardViewState class
PerformanceAnalysis? _cachedAnalysis;

class _EmployeeCardViewState extends State<EmployeeCardView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  CardLayoutType _layoutType = CardLayoutType.grid;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = Provider.of<EmployeeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Performance Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: "Switch Layout",
            icon: Icon(_layoutType == CardLayoutType.grid ? Icons.grid_view_rounded : Icons.view_quilt_rounded),
            onPressed: () => setState(() => _layoutType =
            _layoutType == CardLayoutType.grid ? CardLayoutType.masonry : CardLayoutType.grid),
          ),
          IconButton(
            tooltip: "Selection Mode",
            icon: Icon(provider.isMultiSelect ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: provider.toggleMultiSelect,
          ),
        ],
      ),
      body: _buildCardView(provider),
    );
  }

  // --- Main View Logic ---

  Widget _buildCardView(EmployeeProvider provider) {
    if (provider.isLoading && provider.filteredEmployees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.filteredEmployees.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: _layoutType == CardLayoutType.grid
          ? _buildGridView(provider)
          : _buildMasonryView(provider),
    );
  }

  Widget _buildGridView(EmployeeProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(MediaQuery.of(context).size.width),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: provider.filteredEmployees.length,
      itemBuilder: (context, index) => _buildEmployeeItem(provider, provider.filteredEmployees[index]),
    );
  }

  Widget _buildMasonryView(EmployeeProvider provider) {
    return MasonryGridView.count(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      crossAxisCount: _getCrossAxisCount(MediaQuery.of(context).size.width),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: provider.filteredEmployees.length,
      itemBuilder: (context, index) => _buildEmployeeItem(provider, provider.filteredEmployees[index]),
    );
  }

  Widget _buildEmployeeItem(EmployeeProvider provider, Employee employee) {
    return EmployeeCard(
      key: ValueKey(employee.id),
      employee: employee,
      isSelected: provider.selectedEmployees.contains(employee),
      onTap: () {
        if (provider.isMultiSelect) {
          provider.toggleEmployeeSelection(employee);
        } else {
          _showEmployeeDetails(context, employee);
        }
      },
    );
  }

  // --- MISSING UI HELPERS ADDED BELOW ---

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            _buildDialogHeader(employee, theme),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _runPerformanceAnalysis(context, employee);
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text("GENERATE AI INSIGHTS"),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailSection('Core Metrics', [
              _buildPerformanceItem('Productivity', employee.performance.productivity),
              _buildPerformanceItem('Work Quality', employee.performance.quality),
              _buildPerformanceItem('Attendance', employee.performance.attendanceScore),
            ], theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(Employee employee, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Text(employee.firstName[0], style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(employee.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(employee.position, style: TextStyle(color: theme.hintColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("${score.toStringAsFixed(1)}/5.0"),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: score / 5.0,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const Divider(),
        ...children,
      ],
    );
  }


// 2. The Updated Analysis Function
  void _runPerformanceAnalysis(BuildContext context, Employee employee) {
    // Reset cache before starting
    _cachedAnalysis = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            // Trigger the calculation if it hasn't run yet
            if (_cachedAnalysis == null) {
              _performLogic(employee).then((analysis) {
                if (context.mounted) {
                  // This updates only the internal dialog UI
                  setDialogState(() => _cachedAnalysis = analysis);
                }
              });
            }

            final bool isLoading = _cachedAnalysis == null;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading) ...[
                      // --- LOADING STATE ---
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(color: Colors.deepPurple),
                      const SizedBox(height: 24),
                      const Text("AI Deep Analysis in progress...",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                    ] else ...[
                      // --- RESULT STATE ---
                      Icon(Icons.auto_awesome, color: _cachedAnalysis!.result.color, size: 50),
                      const SizedBox(height: 16),
                      Text(
                        _cachedAnalysis!.result.label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _cachedAnalysis!.result.color
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _cachedAnalysis!.result.desc,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(),
                      ),
                      const Text("RECOMMENDED ACTION",
                          style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cachedAnalysis!.result.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _cachedAnalysis!.result.recommendation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CLOSE"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

// 3. Helper method to handle the async math
  Future<PerformanceAnalysis> _performLogic(Employee employee) async {
    // Artificial delay so the user sees the professional loading animation
    await Future.delayed(const Duration(milliseconds: 1200));

    return PerformancePredictor.predict(
      attendance: employee.performance.attendanceScore,
      skillsCount: employee.skills.length,
      quality: employee.performance.quality,
    );
  }
  void _showAnalysisResult(BuildContext context, PerformanceAnalysis analysis) {
    if (!mounted) return;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: analysis.result.color, size: 24),
            const SizedBox(width: 12),
            const Text("AI Deep Analysis"),
          ],
        ),
        content: SizedBox(
          // 🔥 FIX 1: Provide a minimum width so the dialog doesn't shrink to zero
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              // 🔥 FIX 2: Ensure Column only takes as much space as its children need
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ensure this helper doesn't use 'Expanded' or 'Spacer'
                _buildAISection(analysis.result, theme),

                const SizedBox(height: 24),

                Text(
                  "RECOMMENDED ACTION",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Using a slightly more visible background
                    color: analysis.result.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: analysis.result.color.withOpacity(0.2)),
                  ),
                  child: Text(
                    analysis.result.recommendation,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("CLOSE"),
          ),
        ],
      ),
    );
  }

  Widget _buildAISection(PredictionResult result, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Essential!
      children: [
        Icon(Icons.insights, color: result.color, size: 48),
        const SizedBox(height: 12),
        Text(
          result.label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: result.color),
        ),
        const SizedBox(height: 8),
        Text(
          result.desc,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("No employees found."));

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  } }
