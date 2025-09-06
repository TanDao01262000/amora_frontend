import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoutineProvider>(context, listen: false).loadRoutines();
    });
  }

  Future<void> _showCreateRoutineDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Routine'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Routine Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Routine name is required';
                  }
                  if (value.trim().length > 100) {
                    return 'Name must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.trim().length > 500) {
                    return 'Description must be 500 characters or less';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
      await routineProvider.createRoutine(
        nameController.text.trim(),
        descriptionController.text.trim(),
      );
    }

    nameController.dispose();
    descriptionController.dispose();
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Routines'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.getThemeModeIcon()),
                onPressed: () => Navigator.pushNamed(context, '/theme-settings'),
              ),
            ],
          ),
          body: Consumer<RoutineProvider>(
            builder: (context, routineProvider, child) {
              if (routineProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final routines = routineProvider.routines;
              final completedRoutines = routines.where((r) => r.state == 'completed').length;
              final totalRoutines = routines.length;

              return Column(
                children: [
                  // Progress Header
                  if (totalRoutines > 0)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '$completedRoutines / $totalRoutines',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              LinearProgressIndicator(
                                value: totalRoutines > 0 ? completedRoutines / totalRoutines : 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'All',
                            routineProvider.currentFilter == RoutineFilter.all,
                            () => routineProvider.setFilter(RoutineFilter.all),
                          ),
                          const SizedBox(width: 8.0),
                          _buildFilterChip(
                            'Pending',
                            routineProvider.currentFilter == RoutineFilter.pending,
                            () => routineProvider.setFilter(RoutineFilter.pending),
                          ),
                          const SizedBox(width: 8.0),
                          _buildFilterChip(
                            'Completed',
                            routineProvider.currentFilter == RoutineFilter.completed,
                            () => routineProvider.setFilter(RoutineFilter.completed),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Routines List
                  Expanded(
                    child: routines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.checklist,
                                  size: 64.0,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'No routines yet',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Create your first routine to get started',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                                ElevatedButton.icon(
                                  onPressed: _showCreateRoutineDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create Routine'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: routines.length,
                            itemBuilder: (context, index) {
                              final routine = routines[index];
                              final isCompleted = routine.state == 'completed';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isCompleted
                                        ? Colors.green
                                        : Theme.of(context).primaryColor,
                                    child: Icon(
                                      isCompleted
                                          ? Icons.check
                                          : Icons.schedule,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    routine.title,
                                    style: TextStyle(
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isCompleted
                                          ? Colors.grey[600]
                                          : null,
                                    ),
                                  ),
                                  subtitle: routine.description.isNotEmpty
                                      ? Text(
                                          routine.description,
                                          style: TextStyle(
                                            color: isCompleted
                                                ? Colors.grey[500]
                                                : null,
                                          ),
                                        )
                                      : null,
                                  trailing: IconButton(
                                    icon: Icon(
                                      isCompleted
                                          ? Icons.undo
                                          : Icons.check_circle_outline,
                                    ),
                                    onPressed: () {
                                      if (isCompleted) {
                                        routineProvider.uncompleteRoutine(routine.id);
                                      } else {
                                        routineProvider.completeRoutine(routine.id);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    // TODO: Navigate to routine details
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateRoutineDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}