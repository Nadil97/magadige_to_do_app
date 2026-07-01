import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final int nextStairIndex;
  final TaskModel? taskToEdit;
  const AddTaskDialog({super.key, required this.nextStairIndex, this.taskToEdit});

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
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _selectedPriority = widget.taskToEdit!.priority;
      _selectedAssignee = widget.taskToEdit!.assignedTo;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.taskToEdit != null) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          priority: _selectedPriority,
          assignedTo: _selectedAssignee,
        );
        ref.read(taskControllerProvider.notifier).updateTask(updatedTask);
      } else {
        ref.read(taskControllerProvider.notifier).addTask(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              priority: _selectedPriority,
              assignedTo: _selectedAssignee,
              stairIndex: widget.nextStairIndex,
            );
      }
      Navigator.pop(context);
    }
  }

  Widget _build3DContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(4, 4)),
          BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-4, -4)),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final assigneesAsync = ref.watch(assigneeListProvider);
    final isEditing = widget.taskToEdit != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppTheme.lightBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Step' : 'Add New Step',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.colorPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightBg,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
                          BoxShadow(color: Colors.white, blurRadius: 5, offset: Offset(-2, -2)),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _build3DContainer(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                _build3DContainer(
                  child: TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Priority Select
                _build3DContainer(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority Level',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    dropdownColor: AppTheme.lightBg,
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
                ),
                const SizedBox(height: 16),

                // Assignee Select
                _build3DContainer(
                  child: assigneesAsync.when(
                    data: (list) {
                      if (!list.contains(_selectedAssignee) && list.isNotEmpty) {
                        _selectedAssignee = list.first;
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedAssignee,
                        decoration: const InputDecoration(
                          labelText: 'Assign To',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        dropdownColor: AppTheme.lightBg,
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
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => TextFormField(
                      initialValue: _selectedAssignee,
                      decoration: const InputDecoration(labelText: 'Assign To'),
                      onChanged: (val) => _selectedAssignee = val,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                GestureDetector(
                  onTap: _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.colorPrimary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.colorPrimary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEditing ? 'SAVE CHANGES' : 'ADD TASK TO STAIRS',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
