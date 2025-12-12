import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/features/users/data/services/user_service.dart';
import 'package:subtrack/src/features/users/domain/entities/user.dart';
import 'package:subtrack/src/features/users/domain/repositories/user_repository.dart';

part 'user_repository_impl.g.dart';

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepositoryImpl(ref.watch(userServiceProvider));
}

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<void> addUser(User user) {
    return _userService.addUser(user);
  }

  @override
  Future<void> deleteUser(int id) {
    return _userService.deleteUser(id);
  }

  @override
  Future<User> getUser(int id) {
    return _userService.getUser(id);
  }

  @override
  Future<List<User>> getUsers() {
    return _userService.getUsers();
  }

  @override
  Future<void> updateUser(User user) {
    return _userService.updateUser(user);
  }
}
