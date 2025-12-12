import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/data/database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}
