import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('SongEntry')
class Songs extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get key => text().nullable()();
  IntColumn get capo => integer().nullable()();
  IntColumn get keyboardTranspose => integer().nullable()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Songs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'choird',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
