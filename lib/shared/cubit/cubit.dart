import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:walletwize/shared/components/constants.dart';
import 'package:walletwize/shared/network/remote/dio_helper.dart';
import '../../modules/login/login_screen.dart';
import '../../modules/stats_screen.dart';
import '../../modules/wallet_screen.dart';
import '../components/components.dart';
import '../network/local/cache_helper.dart';
import '../styles/styles.dart';
import '../styles/themes.dart';
import 'states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  //VARS
  var addSourceController = TextEditingController();
  var addSourceBalanceController = TextEditingController();
  var addSourceTypeController = TextEditingController();
  var addTransactionAmountController = TextEditingController();
  var currentIndex = 0;
  bool visibleSources = false;
  bool isDark = true;
  bool visibleSheet = false;
  //UI FUNCTIONS
  void showSources() {
    visibleSources = !visibleSources;
    emit(AppShowSourcesState());
  }

  List<Widget> screens = [
    const WalletScreen(),
    const StatsScreen(),
  ];
  void showSettingPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Preferences',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleSwitch(
                cornerRadius: 15.0,
                activeBgColors: [
                  [
                    (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.prussian
                        : Styles.pacific)
                  ],
                  [
                    (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.prussian
                        : Styles.pacific)
                  ],
                  [
                    (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.prussian
                        : Styles.pacific)
                  ]
                ],
                activeFgColor:
                    CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.whiteColor
                        : Styles.blackColor,
                inactiveBgColor:
                    CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.greyColor
                        : Styles.prussian,
                inactiveFgColor: Theme.of(context).textTheme.bodyMedium?.color,
                totalSwitches: 3,
                icons: const [
                  Icons.attach_money_rounded,
                  Icons.euro_rounded,
                  Icons.currency_pound_rounded
                ],
                initialLabelIndex: currencyIndex,
                onToggle: (index) {
                  switch (index) {
                    case 0:
                      currency = '\$';
                      emit(AppChangeSelectedCurrency());
                      break;
                    case 1:
                      currency = '€';
                      currencyIndex = 1;
                      saveCurrencyPreference();
                      emit(AppChangeSelectedCurrency());
                      break;
                    case 2:
                      currency = '£';
                      currencyIndex = 2;
                      saveCurrencyPreference();
                      emit(AppChangeSelectedCurrency());
                      break;
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: "Theme",
                    onPressed: () {
                      isDark = !isDark;
                      context.read<ThemeCubit>().toggleTheme();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.mode_night_rounded,
                        color:
                            CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                                ? Styles.prussian
                                : Styles.pacific),
                  ),
                  IconButton(
                    tooltip: "Logout",
                    onPressed: () {
                      DioHelper.postData(
                        url: 'logout',
                        token: token,
                      ).then((value) {
                        token = null;
                        CacheHelper.removeData(key: 'token');
                      });

                      navigateAndFinish(context, LoginScreen());
                    },
                    icon: Icon(Icons.logout_rounded,
                        color:
                            CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                                ? Styles.prussian
                                : Styles.pacific),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showActivityPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Type',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleSwitch(
                cornerRadius: 15.0,
                initialLabelIndex: 1,
                activeBgColors: [
                  const [(Colors.orange)],
                  const [Colors.yellow],
                  const [Colors.blue],
                  [
                    (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.prussian
                        : Styles.pacific)
                  ],
                ],
                activeFgColor: Styles.blackColor,
                inactiveBgColor:
                    CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.greyColor
                        : Styles.prussian,
                inactiveFgColor: Theme.of(context).textTheme.bodyMedium?.color,
                totalSwitches: 3,
                labels: const ['Must', 'Need', 'Want'],
                onToggle: (index) {
                  switch (index) {
                    case 0:
                      setActivityType('Must');
                      Navigator.of(context).pop();
                      break;

                    case 1:
                      setActivityType('Need');
                      Navigator.of(context).pop();

                      break;
                    case 2:
                      setActivityType('Want');
                      Navigator.of(context).pop();

                      break;
                    default:
                      setActivityType('Need');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> changeBottomNavBarState(index) async {
    if (index > 1) {
      index = 0;
    }
    currentIndex = index;
    visibleSources = false;
    emit(AppChangeNavBarState());
  }

  void sheetChange() {
    visibleSheet = !visibleSheet;
    emit(SheetChangeState());
  }

  void showSourcePrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          title: Text(
            'Add Source',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
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
              const SizedBox(height: 15),
              ToggleSwitch(
                cornerRadius: 15.0,
                activeBgColors: [
                  [
                    (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.prussian
                        : Styles.pacific)
                  ],
                  [
                    (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.prussian
                        : Styles.pacific)
                  ],
                  [
                    (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.prussian
                        : Styles.pacific)
                  ]
                ],
                activeFgColor:
                    CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.whiteColor
                        : Styles.blackColor,
                inactiveBgColor:
                    CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                        ? Styles.greyColor
                        : Styles.prussian,
                inactiveFgColor: Theme.of(context).textTheme.bodyMedium?.color,
                totalSwitches: 3,
                initialLabelIndex: 0,
                icons: const [
                  Icons.account_balance,
                  Icons.credit_card,
                  Icons.money
                ],
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
                  }
                },
              ),
            ]),
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                            ? Styles.prussian
                            : Styles.pacific,
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

  //API FUNCTIONS

  Future<void> sendSyncData(Database db, IO.Socket socket) async {
    final List<Map<String, dynamic>> changes =
        await db.query('change_log', where: 'sync_time IS NULL');

    for (Map<String, dynamic> change in changes) {
      final String tableName = change['table_name'];
      final int rowId = change['row_id'];
      final String operation = change['operation'];

      final List<Map<String, dynamic>> records =
          await db.query(tableName, where: 'id = ?', whereArgs: [rowId]);

      if (records.isNotEmpty) {
        final Map<String, dynamic> record = records.first;
        final Map<String, dynamic> payload = {
          "log_id": change['id'],
          "table_name": tableName,
          "operation": operation,
          "timestamp": change['change_time'],
          "data": record,
        };

        socket.emit('save_data', json.encode(payload));

        await db.update(
            'change_log', {'sync_time': DateTime.now().toIso8601String()},
            where: 'id = ?', whereArgs: [change['id']]);
      }
    }
  }

  //DATA FUNCTIONS

  Future<void> createTriggersForSqliteTable(Database db) async {
    final List<String> tables = ["sources", "transactions"];

    for (String tableName in tables) {
      final List<Map<String, dynamic>> existingTriggers = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE ?",
          ["before_%_$tableName"]);

      final List<Map<String, dynamic>> triggerDefinitions = [
        {
          "name": "before_insert_$tableName",
          "timing": "BEFORE INSERT",
          "body": """
          INSERT INTO change_log (table_name, row_id, operation)
          VALUES ('$tableName', NEW.id, 'I');
        """
        },
        {
          "name": "before_update_$tableName",
          "timing": "BEFORE UPDATE",
          "body": """
          INSERT INTO change_log (table_name, row_id, operation)
          VALUES ('$tableName', NEW.id, 'U');
        """
        },
        {
          "name": "before_delete_$tableName",
          "timing": "BEFORE DELETE",
          "body": """
          INSERT INTO change_log (table_name, row_id, operation)
          VALUES ('$tableName', OLD.id, 'D');
        """
        },
      ];

      for (Map<String, dynamic> trigger in triggerDefinitions) {
        final String createTriggerSql = """
          CREATE TRIGGER ${trigger['name']}
          ${trigger['timing']} ON $tableName
          FOR EACH ROW
          BEGIN
            ${trigger['body']}
          END;
        """;

        await db.execute(createTriggerSql);
      }
    }
  }

  late Database database;
  List<Map> newTransactions = [];
  List<Map> newSources = [];
  List<Map> changelog = [];
  final Socket socket = GetIt.I<Socket>();
  double mustCount = CacheHelper.getData(key: 'musts') ?? 0.0;
  double needCount = CacheHelper.getData(key: 'needs') ?? 0.0;
  double wantCount = CacheHelper.getData(key: 'wants') ?? 0.0;
  void createDatabase() {
    openDatabase(
      'wallet.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL,type TEXT,source TEXT, date TEXT,time TEXT,activity TEXT)');
        await db.execute(
            'CREATE TABLE sources (id INTEGER PRIMARY KEY AUTOINCREMENT, source TEXT,type TEXT,balance REAL)');
        await db.execute(
            'CREATE TABLE change_log (id INTEGER PRIMARY KEY AUTOINCREMENT, table_name TEXT not null,row_id INTEGER not null,operation CHAR(1) not null,change_time TIMESTAMP default CURRENT_TIMESTAMP,sync_time TIMESTAMP)');
      },
      onOpen: (database) {
        getFromDatabase(database);
        if (CacheHelper.getData(key: 'triggers') != 'true') {
          createTriggersForSqliteTable(database);
          CacheHelper.saveData(key: 'triggers', value: 'true');
        }
      },
    ).then(
      (value) {
        database = value;
        emit(AppCreateDatabaseState());
      },
    );
  }

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

  Future insertIntoSources({
    required String source,
    required String type,
    required double balance,
  }) {
    return database.transaction(
      (Transaction txn) async {
        txn.rawInsert(
          'INSERT INTO sources (source,type,balance) VALUES(?,?,?)',
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

  void changeTransType() {
    positiveTrans = false;
    emit(AppChangeActivityType());
  }

  int selectedSource = -1;

  void updateSelectedIndex(int index) {
    selectedSource = index;
    // emit(AppChangeSelectedIndexState());
  }

  Future insertIntoTransactions({
    required double amount,
    required String type,
    required String source,
    required String date,
    required String time,
    required String activity,
  }) {
    return database.transaction(
      (Transaction txn) async {
        txn.rawInsert(
          'INSERT INTO transactions (amount,type,source,date,time,activity) VALUES(?,?,?,?,?,?)',
          [amount, type, source, date, time, activity],
        ).then(
          (value) {
            emit(AppInsertDatabaseState());
            sendSyncData(database, socket);
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
    loadCurrencyPreference();

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
        if (newSources.isEmpty) {
          changePercentage = 0.0;
          CacheHelper.saveData(key: 'changeP', value: 0.0);
        }
        emit(AppDeleteDatabaseState());
      },
    );
  }

  double changePercentage = CacheHelper.getData(key: 'changeP') ?? 0.0;

  void calculateChangePercentage(double oldTotal, double newTotal) {
    if (oldTotal == 0.0) {
      changePercentage = 0.0;
      CacheHelper.saveData(key: 'changeP', value: changePercentage);
    }
    changePercentage = double.parse(
        (((newTotal - oldTotal) / oldTotal) * 100).toStringAsFixed(2));
    if (changePercentage == double.infinity ||
        changePercentage == double.negativeInfinity) {
      changePercentage = 0.0;
    }
    CacheHelper.saveData(key: 'changeP', value: changePercentage);
  }

  String activityType = '';
  void setActivityType(String activity) {
    activityType = activity;
    emit(AppChangeTransactionType());
  }

  void newTransaction(String time) async {
    double oldTotal = await getBalanceSum();

    // Log the values for debugging

    double transactionAmount =
        double.parse(addTransactionAmountController.text);
    double newBalance = newSources[selectedSource]['balance'];

    if (positiveTrans) {
      newBalance += transactionAmount;
    } else {
      transactionAmount = -transactionAmount;
      newBalance += transactionAmount;
      if (activityType == 'Must') {
        mustCount += 1;
        CacheHelper.saveData(key: 'musts', value: mustCount);
      } else {
        if (activityType == 'Want') {
          wantCount += 1;
          CacheHelper.saveData(key: 'wants', value: wantCount);
        } else {
          needCount += 1;
          CacheHelper.saveData(key: 'needs', value: needCount);
        }
      }
    }

    await database.update(
      'sources',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [newSources[selectedSource]['id']],
    );

    await insertIntoTransactions(
        amount: transactionAmount,
        source: newSources[selectedSource]['source'],
        type: positiveTrans ? 'increase' : 'decrease',
        date: DateFormat.yMMMd().format(DateTime.now()),
        time: time,
        activity: activityType);

    double newTotal = await getBalanceSum(); // Get the new total balance
    calculateChangePercentage(oldTotal, newTotal);

    positiveTrans = true;
// Calculate the change percentage

    emit(AppChangePercentageState(
        changePercentage)); // Emit a new state with the change percentage
  }

  String currency = '\$';
  var currencyIndex = 0;
  Future<void> saveCurrencyPreference() async {
    await CacheHelper.saveData(key: 'currency', value: currency);
    await CacheHelper.saveData(key: 'currencyIndex', value: currencyIndex);
  }

  // Method to load currency preferences using CacheHelper
  Future<void> loadCurrencyPreference() async {
    currency = await CacheHelper.getData(key: 'currency') ?? '\$';
    currencyIndex = await CacheHelper.getData(key: 'currencyIndex') ?? 0;
    emit(AppChangeSelectedCurrency());
  }
}
