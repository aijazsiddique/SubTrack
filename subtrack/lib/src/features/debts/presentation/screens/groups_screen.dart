import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/debts/data/repositories/group_repository_impl.dart';
import 'package:subtrack/src/features/debts/domain/entities/group.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  Future<void> _addGroup() async {
    if (_groupNameController.text.isNotEmpty) {
      final newGroup = Group(
        id: 0, // Will be ignored by Drift, auto-incremented
        name: _groupNameController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(groupRepositoryProvider).addGroup(newGroup);
      _groupNameController.clear();
      if (mounted) {
        // Refresh the list
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsyncValue = ref.watch(groupRepositoryProvider).getGroups();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Groups'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'New Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addGroup,
                  child: const Text('Add Group'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Group>>(
              future: groupsAsyncValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No groups created yet.'));
                } else {
                  final groups = snapshot.data!;
                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(group.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await ref.read(groupRepositoryProvider).deleteGroup(group.id);
                              if (mounted) {
                                setState(() {}); // Refresh list
                              }
                            },
                          ),
                          onTap: () {
                            // TODO: Navigate to Group details/members screen
                            print('Tapped on group: ${group.name}');
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
