import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';
import '../../core/theme/app_theme.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final int nextStairIndex;
  const AddTaskDialog({super.key, required this.nextStairIndex});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedPriority = 'Medium';
  String _selectedAssignee = 'Nadil Sandaruwan';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(taskControllerProvider.notifier).addTask(
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            priority: _selectedPriority,
            assignedTo: _selectedAssignee,
            stairIndex: widget.nextStairIndex,
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assigneesAsync = ref.watch(assigneeListProvider);

    return Dialog(
      backgroundColor: AppTheme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Step',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.colorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                
                // Priority Select
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority Level'),
                  dropdownColor: AppTheme.cardBg,
                  items: ['Easy', 'Medium', 'Hard'].map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPriority = val);
                  },
                ),
                const SizedBox(height: 16),

                // Assignee Select
                assigneesAsync.when(
                  data: (list) {
                    if (!list.contains(_selectedAssignee) && list.isNotEmpty) {
                      _selectedAssignee = list.first;
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAssignee,
                      decoration: const InputDecoration(labelText: 'Assign To'),
                      dropdownColor: AppTheme.cardBg,
                      items: list.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedAssignee = val);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => TextFormField(
                    initialValue: _selectedAssignee,
                    decoration: const InputDecoration(labelText: 'Assign To'),
                    onChanged: (val) => _selectedAssignee = val,
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('ADD TASK TO STAIRS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
