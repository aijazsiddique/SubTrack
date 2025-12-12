import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/features/debts/data/services/group_service.dart';
import 'package:subtrack/src/features/debts/domain/entities/group.dart';
import 'package:subtrack/src/features/debts/domain/repositories/group_repository.dart';

part 'group_repository_impl.g.dart';

@riverpod
GroupRepository groupRepository(GroupRepositoryRef ref) {
  return GroupRepositoryImpl(ref.watch(groupServiceProvider));
}

class GroupRepositoryImpl implements GroupRepository {
  final GroupService _groupService;

  GroupRepositoryImpl(this._groupService);

  @override
  Future<void> addGroup(Group group) {
    return _groupService.addGroup(group);
  }

  @override
  Future<void> deleteGroup(int id) {
    return _groupService.deleteGroup(id);
  }

  @override
  Future<Group> getGroup(int id) {
    return _groupService.getGroup(id);
  }

  @override
  Future<List<Group>> getGroups() {
    return _groupService.getGroups();
  }

  @override
  Future<void> updateGroup(Group group) {
    return _groupService.updateGroup(group);
  }
}
