
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../modules/stats_screen.dart';
import '../../modules/wallet_screen.dart';
import '../components/components.dart';
import '../styles/styles.dart';
import 'states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);
  var currentIndex = 0;
  bool visibleSources = false;
  bool visibleSheet = false;
  void showSources() {
    visibleSources = !visibleSources;
    emit(AppShowSourcesState());
  }

  List<Widget> screens = [
    const WalletScreen(),
    const StatsScreen(),
  ];

  Future<void> changeBottomNavBarState(index) async {
    if (index > 1) {
      index = 0;
    }
    currentIndex = index;
    visibleSources = false;
    emit(AppChangeNavBarState());
  }

  void SheetChange() {
    visibleSheet = !visibleSheet;
    emit(SheetChangeState());
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
            'CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL,type TEXT,source TEXT, date TEXT,time TEXT)');
        await db.execute(
            'CREATE TABLE sources (id INTEGER PRIMARY KEY AUTOINCREMENT, source TEXT,type TEXT,balance REAL)');
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

  var addSourceController = TextEditingController();
  var addSourceBalanceController = TextEditingController();
  var addSourceTypeController = TextEditingController();
  var addTransactionAmountController = TextEditingController();
  Future<double> getBalanceSum() async {
    const double maxBalance = 9999999999.0; // Define the maximum balance sum

    List<Map<String, dynamic>> result = await database
        .rawQuery('SELECT SUM(balance) as totalBalance FROM sources');

    if (result.isNotEmpty && result[0]['totalBalance'] != null) {
      double totalBalance = result[0]['totalBalance'];
      return totalBalance > maxBalance ? maxBalance : totalBalance;
    } else {
      return 0.0;
    }
  }

  var formKey = GlobalKey<FormState>();
  void showSourceValueUpdatePrompt(
      {required int id,
      required String source,
      required double balance,
      required String type,
      required BuildContext context}) {
    addSourceController.text = source;
    addSourceTypeController.text = type;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            title: const Text(
              'Edit Source',
              style: TextStyle(color: Styles.pacific),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  customForm(
                    context: context,
                    controller: addSourceController,
                    type: TextInputType.text,
                    label: 'Name *',
                    suffix: Icons.title_rounded,
                    validate: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please type a name';
                      }
                      return null; // Return null to indicate the input is valid
                    },
                  ),
                  // const SizedBox(height: 15),
                  // customForm(
                  //   context: context,
                  //   controller: addSourceBalanceController,
                  //   type: TextInputType.number,
                  //   label: 'balance *',
                  //   suffix: Icons.monetization_on_outlined,
                  //   validate: (String? value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please type a balance';
                  //     }
                  //     return null; // Return null to indicate the input is valid
                  //   },
                  // ),
                  const SizedBox(height: 15),
                  ToggleSwitch(
                    cornerRadius: 15.0,
                    activeBgColors: [
                      [Styles.pacific],
                      [Styles.pacific],
                      [Styles.pacific],
                    ],
                    initialLabelIndex: 0,
                    activeFgColor: Styles.blackColor,
                    inactiveBgColor: Styles.prussian,
                    inactiveFgColor: Styles.whiteColor,
                    totalSwitches: 3,
                    icons: [Icons.account_balance, Icons.credit_card,Icons.monetization_on_outlined],
                    onToggle: (index) {
                      switch (index) {
                        case 0:
                          addSourceTypeController.text = 'bank';
                          break;
                        case 1:
                          addSourceTypeController.text = 'card';
                          break;
                        case 2:
                          addSourceTypeController.text = 'cash';
                          break;
                        default:
                          addSourceTypeController.text = 'bank';
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.pacific,
                      foregroundColor: Styles.whiteColor),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      database.update(
                          'transactions',
                          {
                            'source': addSourceController.text,
                          },
                          where: 'source = ?',
                          whereArgs: [source]);
                      database.update(
                          'sources',
                          {
                            'source': addSourceController.text,
                            'type': addSourceTypeController.text.toLowerCase(),
                            'balance':
                                0.0,
                          },
                          where: 'id = ?',
                          whereArgs: [id]);
                      emit(AppInsertDatabaseState());
                      getFromDatabase(database);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Ok!'))
            ],
          );
        });
  }

  void showSourcePrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          title: const Text(
            'Add Source',
            style: TextStyle(color: Styles.pacific),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                customForm(
                  context: context,
                  controller: addSourceController,
                  type: TextInputType.text,
                  label: 'Name *',
                  suffix: Icons.title_rounded,
                  validate: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please type a name';
                    }
                    return null; // Return null to indicate the input is valid
                  },
                ),
                // const SizedBox(height: 15),
                // customForm(
                //   context: context,
                //   controller: addSourceBalanceController,
                //   type: TextInputType.number,
                //   label: 'balance *',
                //   suffix: Icons.monetization_on_outlined,
                //   validate: (String? value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please type a balance';
                //     }
                //     return null; // Return null to indicate the input is valid
                //   },
                // ),
                const SizedBox(height: 15),
            ToggleSwitch(
              cornerRadius: 15.0,
              activeBgColors: [
                [Styles.pacific],
                [Styles.pacific],
                [Styles.pacific],
              ],
              activeFgColor: Styles.blackColor,
              inactiveBgColor: Styles.prussian,
              inactiveFgColor: Styles.whiteColor,
              totalSwitches: 3,
              initialLabelIndex: 0,
              icons: [Icons.account_balance, Icons.credit_card,Icons.monetization_on_outlined],
              onToggle: (index) {
                switch (index) {
                  case 0:
                    addSourceTypeController.text = 'bank';
                    break;
                  case 1:
                    addSourceTypeController.text = 'card';
                    break;
                  case 2:
                    addSourceTypeController.text = 'cash';
                    break;
                  default:
                    addSourceTypeController.text = 'bank';
                }
              },
            ),]
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.pacific,
                    foregroundColor: Styles.whiteColor),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    insertIntoSources(
                      source: addSourceController.text,
                      balance: 0.0,
                      type: addSourceTypeController.text.toLowerCase(),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Ok!'))
          ],
        );
      },
    );
  }

  Future insertIntoSources({
    required String source,
    required String type,
    required double balance,
  }) {
    return database.transaction(
      (Transaction txn) async {
        txn.rawInsert(
          'INSERT INTO sources ( source,type,balance) VALUES(?,?,?)',
          [source, type, balance],
        ).then(
          (value) {
            emit(AppInsertDatabaseState());
            getFromDatabase(database);
          },
        );
      },
    );
  }

  bool positiveTrans = true;
  int selectedSource = -1;

  void updateSelectedIndex(int index) {
    selectedSource = index;
    emit(AppChangeSelectedIndexState());
  }

  Future insertIntoTransactions({
    required double amount,
    required String type,
    required String source,
    required String date,
    required String time,
  }) {
    return database.transaction(
      (Transaction txn) async {
        txn.rawInsert(
          'INSERT INTO transactions (amount,type,source,date,time) VALUES(?,?,?,?,?)',
          [amount, type, source, date, time],
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

    database.rawQuery('Select * FROM transactions').then(
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
    database.rawQuery('Select * FROM sources').then(
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

  void deleteAllTransaction() {
    database.rawDelete('DELETE FROM transactions').then(
          (value) {
        getFromDatabase(database);
        emit(AppDeleteDatabaseState());
      },
    );
  }

  void deleteSource({required int id}) {
    database.rawDelete('DELETE FROM sources WHERE id = ?', [id]).then(
      (value) {
        getFromDatabase(database);
        emit(AppDeleteDatabaseState());
      },
    );
  }


  void newTransaction(String time){
    if(positiveTrans){database.update(
        'sources',
        {
          'balance':
          newSources[selectedSource]['balance'] + double.parse(addTransactionAmountController.text)
        },
        where: 'id = ?',
        whereArgs: [newSources[selectedSource]['id']]);
    insertIntoTransactions(amount: double.parse(addTransactionAmountController.text),source:newSources[selectedSource]['source'], type: 'increase', date: DateFormat.yMMMd()
        .format(DateTime.now()),time: time);}else{
      database.update(
          'sources',
          {
            'balance':
            newSources[selectedSource]['balance'] - double.parse(addTransactionAmountController.text)
          },
          where: 'id = ?',
          whereArgs: [newSources[selectedSource]['id']]);
      insertIntoTransactions(amount: double.parse(addTransactionAmountController.text),source:newSources[selectedSource]['source'], type: 'decrease', date: DateFormat.yMMMd()
          .format(DateTime.now()),time: time);
    }

  }
}
