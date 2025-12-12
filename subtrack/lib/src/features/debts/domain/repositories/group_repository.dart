import '../entities/group.dart';

abstract class GroupRepository {
  Future<List<Group>> getGroups();
  Future<Group> getGroup(int id);
  Future<void> addGroup(Group group);
  Future<void> updateGroup(Group group);
  Future<void> deleteGroup(int id);
}
