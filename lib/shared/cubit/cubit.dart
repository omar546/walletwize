import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toggle_switch/toggle_switch.dart';
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
  var currentIndex = 0;
  bool visibleSources = false;
  bool isDark = true;
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
            title: Text(
              'Edit Source',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
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
                    initialLabelIndex: 0,
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
                    inactiveFgColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    totalSwitches: 3,
                    icons: [
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
                ],
              ),
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
                            'balance': 0.0,
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
                icons: [Icons.account_balance, Icons.credit_card, Icons.money],
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
  void changeTransType(){
    positiveTrans = false;
    emit(AppChangeTransactionType());
  }
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
        if(newSources.isEmpty){
          changePercentage=0.0;
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
    changePercentage =
    double.parse((((newTotal - oldTotal) / oldTotal) * 100).toStringAsFixed(2));
    if(changePercentage == double.infinity){
      changePercentage = 0.0;
    }
    CacheHelper.saveData(key: 'changeP', value: changePercentage);

  }
  void newTransaction(String time) async {
    double oldTotal = await getBalanceSum();

    // Log the values for debugging


    double transactionAmount = double.parse(addTransactionAmountController.text);
    double newBalance = newSources[selectedSource]['balance'];

    if (positiveTrans) {
      newBalance += transactionAmount;
    } else {
      newBalance -= transactionAmount;
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
    );

    double newTotal = await getBalanceSum(); // Get the new total balance
    calculateChangePercentage(oldTotal, newTotal);
    print(changePercentage);

    positiveTrans = true;
// Calculate the change percentage

    emit(AppChangePercentageState(changePercentage)); // Emit a new state with the change percentage
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
              SizedBox(
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
}
