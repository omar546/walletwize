
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../../modules/stats_screen.dart';
import '../../modules/wallet_screen.dart';

import '../styles/styles.dart';
import 'states.dart';

class AppCubit extends Cubit<AppStates> {

  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);
  var currentIndex = 0;


  List<Widget> screens = [
    const WalletScreen(),
    const StatsScreen(),
  ];

  Future<void> changeBottomNavBarState(index) async {
    if (index > 1) {
      index = 0;
    }
    currentIndex = index;
    emit(AppChangeNavBarState());
  }

  late Database database;
  List<Map> newTransactions = [];
  List<Map> newSources = [];

  void createDatabase() {
    openDatabase(
      'wallet.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, amount INTEGER,source TEXT, date TEXT,time TEXT)');
        await db.execute(
            'CREATE TABLE sources (id INTEGER PRIMARY KEY AUTOINCREMENT, source TEXT,color TEXT,type TEXT,balance REAL)');
      },
      onOpen: (database) {
        getFromDatabase(database);
      },
    ).then(
      (value) {
        database = value;
        emit(AppCreateDatabaseState());
      },
    );
  }

  Future insertIntoDatabase({
    required String title,
    required String ptitle,
    required String date,
    required String time,
  }) {
    return database.transaction(
      (Transaction txn) async {
        txn.rawInsert(
          'INSERT INTO tasks(title,ptitle, date, time,category,color) VALUES(?, ?, ?,?,"uncategorized","#d2d2d2")',
          [
            '[{\"insert\":\"${title.replaceAll("'", "''").replaceAll('"', '""').replaceAll('\n', '\\n')}\\n\"}]',
            ptitle.replaceAll("'", "''").replaceAll('"', '""'),
            date,
            time
          ],
        ).then(
          (value) {
            emit(AppInsertDatabaseState());
            changeBottomNavBarState(0);
            getFromDatabase(database);
          },
        );
      },
    );
  }


  void getFromDatabase(database) {
    newTransactions = [];
    newSources = [];

    emit(AppGetDatabaseLoadingState());

    database.rawQuery('Select * FROM tasks').then(
      (values) {
        values.forEach(
          (element) {
            //sego sort algo :)
            newTransactions.add(element);
            newSources.sort(
              (b, a) => a['id'].compareTo(b['id']),
            );
          },
        );
        emit(AppGetDatabaseState());
      },
    );
    database.rawQuery('Select * FROM categories').then(
      (values) {
        values.forEach(
          (element) {
            //sego sort algo :)
            newSources.add(element);
            newSources.sort(
              (b, a) => a['id'].compareTo(b['id']),
            );
          },
        );
        emit(AppGetDatabaseState());
      },
    );
  }


  void deleteDatabase({required int id}) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then(
      (value) {
        getFromDatabase(database);
        emit(AppDeleteDatabaseState());
      },
    );
  }










  Color sourceColor = Styles.greyColor;
  void changeColor(Color color) {
    sourceColor = color;
    emit(CategoryColor());
  }

  Future insertIntoCategories({
    required String name,
    required String color,
  }) {
    return database.transaction(
      (Transaction txn) async {
        txn.rawInsert(
          'INSERT INTO categories(category,color) VALUES(?, ?)',
          [name, color],
        ).then(
          (value) {
            emit(AppInsertDatabaseState());
            getFromDatabase(database);
          },
        );
      },
    );
  }


}
