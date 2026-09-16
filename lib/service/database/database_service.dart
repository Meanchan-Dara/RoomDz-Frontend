import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:roomdz_frontend/model/user_model.dart';

/// Singleton SQLite service.
/// Stores the logged-in user (id, name, email, phone, avatar, role name)
/// so the app can auto-navigate to the correct screen on next launch.
class DatabaseService {
  // --- Singleton ---
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _db;

  // --- Constants ---
  static const _dbName = 'roomdz.db';
  static const _dbVersion = 1;
  static const _table = 'session';

  // --- Init ---
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $_table (
          id        INTEGER PRIMARY KEY,
          name      TEXT NOT NULL,
          email     TEXT NOT NULL,
          phone     TEXT,
          avatar    TEXT,
          role_id   INTEGER,
          role_name TEXT
        )
      ''');
      },
    );
  }

  // --- Save ---
  /// Persists the user (and their role) after a successful login.
  /// Only one session row is ever kept (id = 1).
  Future<void> saveUser(UserModel user) async {
    final db = await database;
    await db.insert(_table, {
      'id': 1,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'avatar': user.avatar,
      'role_id': user.role?.id,
      'role_name': user.role?.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Load ---
  /// Returns the saved [UserModel] or null if no session exists.
  Future<UserModel?> getSavedUser() async {
    final db = await database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;

    final row = rows.first;
    return UserModel(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      phone: row['phone'] as String?,
      avatar: row['avatar'] as String?,
      role: (row['role_name'] != null)
          ? RoleModel(
              id: row['role_id'] as int,
              name: row['role_name'] as String,
            )
          : null,
    );
  }

  // --- Clear ---
  /// Removes the session row – call this on logout.
  Future<void> clearUser() async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [1]);
  }

  // --- Helper ---
  /// Maps a role name to one of: 'admin' | 'owner' | 'customer'
  /// Returns 'customer' as the safe fallback.
  static String normalizeRole(String? roleName) {
    switch (roleName?.toLowerCase()) {
      case 'admin':
        return 'admin';
      case 'owner':
        return 'owner';
      default:
        return 'customer';
    }
  }
}
