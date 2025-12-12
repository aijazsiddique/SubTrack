import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/data/database.dart';
import 'package:subtrack/src/features/debts/domain/entities/group.dart';

part 'group_service.g.dart';

@riverpod
GroupService groupService(GroupServiceRef ref) {
  return GroupService(ref.watch(appDatabaseProvider));
}

class GroupService {
  final AppDatabase _db;

  GroupService(this._db);

  Future<List<Group>> getGroups() async {
    final groups = await _db.select(_db.groups).get();
    return groups.map((e) => _mapGroupDataToEntity(e)).toList();
  }

  Future<Group> getGroup(int id) async {
    final groupData = await (_db.select(_db.groups)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
    return _mapGroupDataToEntity(groupData);
  }

  Future<void> addGroup(Group group) async {
    await _db.into(_db.groups).insert(
          GroupsCompanion.insert(
            name: group.name,
          ),
        );
  }

  Future<void> updateGroup(Group group) async {
    await (_db.update(_db.groups)..where((tbl) => tbl.id.equals(group.id)))
        .write(
          GroupsCompanion(
            name: Value(group.name),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteGroup(int id) async {
    await (_db.delete(_db.groups)..where((tbl) => tbl.id.equals(id))).go();
  }

  Group _mapGroupDataToEntity(GroupData data) {
    return Group(
      id: data.id,
      name: data.name,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
