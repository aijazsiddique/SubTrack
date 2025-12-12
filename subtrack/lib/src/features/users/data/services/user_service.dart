import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/data/database.dart';
import 'package:subtrack/src/features/users/domain/entities/user.dart';

part 'user_service.g.dart';

@riverpod
UserService userService(UserServiceRef ref) {
  return UserService(ref.watch(appDatabaseProvider));
}

class UserService {
  final AppDatabase _db;

  UserService(this._db);

  Future<List<User>> getUsers() async {
    final users = await _db.select(_db.users).get();
    return users.map((e) => _mapUserDataToEntity(e)).toList();
  }

  Future<User> getUser(int id) async {
    final userData = await (_db.select(_db.users)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
    return _mapUserDataToEntity(userData);
  }

  Future<void> addUser(User user) async {
    await _db.into(_db.users).insert(
          UsersCompanion.insert(
            name: user.name,
            email: Value(user.email),
          ),
        );
  }

  Future<void> updateUser(User user) async {
    await (_db.update(_db.users)..where((tbl) => tbl.id.equals(user.id)))
        .write(
          UsersCompanion(
            name: Value(user.name),
            email: Value(user.email),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteUser(int id) async {
    await (_db.delete(_db.users)..where((tbl) => tbl.id.equals(id))).go();
  }

  User _mapUserDataToEntity(UserData data) {
    return User(
      id: data.id,
      name: data.name,
      email: data.email,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
