import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../shared/components/components.dart';
import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';
import '../shared/styles/styles.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({super.key});
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          AppCubit cubit = BlocProvider.of<AppCubit>(context);
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
              title: const Center(
                  child: Text(
                'WalletWize',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Quicksand',
                    fontSize: 25),
              )),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_horiz_sharp),
                  onPressed: () {},
                ),
              ],
            ),
            key: scaffoldKey,
            body: cubit.screens[cubit.currentIndex],
            floatingActionButtonLocation: cubit.visibleSheet
                ? FloatingActionButtonLocation.miniEndDocked
                : FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Visibility(
              visible: !cubit.visibleSheet,
              child: FloatingActionButton(
                onPressed: () {
                    if (cubit.newSources.isNotEmpty) {
                      cubit.changeBottomNavBarState(0);
                      cubit.showSources();
                      cubit.SheetChange();
                      scaffoldKey.currentState!
                          .showBottomSheet((context) => StatefulBuilder(
                                builder:
                                    (BuildContext context, StateSetter setState) {
                                  return Container(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.3,
                                    width: double.infinity,
                                    color:
                                        Theme.of(context).scaffoldBackgroundColor,
                                    child: Form(
                                      key: formKey,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height:
                                                MediaQuery.sizeOf(context).height *
                                                    0.1,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: cubit.newSources.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                    onTap: () {
                                                      cubit.updateSelectedIndex(
                                                          index);
                                                      setState(
                                                          () {}); // Force rebuild inside StatefulBuilder
                                                    },
                                                    child: buildSourceSelectionItem(
                                                      model:
                                                          cubit.newSources[index],
                                                      index: 0,
                                                      isSelected:
                                                          cubit.selectedSource ==
                                                              index,
                                                    ));
                                              },
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context)
                                                        .width *
                                                    0.35,
                                                child: customForm(
                                                  context: context,
                                                  controller: cubit
                                                      .addTransactionAmountController,
                                                  type: TextInputType.number,
                                                  label: 'amount',
                                                  suffix: Icons
                                                      .currency_exchange_rounded,
                                                  validate: (String? value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please type a balance';
                                                    }
                                                    return null; // Return null to indicate the input is valid
                                                  },
                                                  onSubmit: (v){
                                                    if (cubit.selectedSource != -1 &&
                                                        formKey.currentState!.validate()) {
                                                      cubit.newTransaction();
                                                    }
                                                  }
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              ToggleSwitch(
                                                customWidths: [50.0, 50.0],
                                                cornerRadius: 15.0,
                                                activeBgColors: [
                                                  [Styles.positive],
                                                  [Styles.negative]
                                                ],
                                                activeFgColor: Styles.whiteColor,
                                                inactiveBgColor: Styles.greyColor,
                                                inactiveFgColor: Styles.blackColor,
                                                totalSwitches: 2,
                                                icons: [Icons.add, Icons.remove],
                                                onToggle: (index) {
                                                  if (index == 1) {
                                                    cubit.positiveTrans = false;
                                                  } else {
                                                    cubit.positiveTrans = true;
                                                  }
                                                },
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              IconButton(onPressed: (){
                                                if (cubit.selectedSource != -1 &&
                                                    formKey.currentState!.validate()) {
                                                  cubit.newTransaction();
                                                  Navigator.of(context).pop();
                                                  cubit.positiveTrans = true;
                                                }
                                              }, icon: Icon(Icons.check_circle_rounded,color: Styles.pacific,size: 40,))
                                            ],
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ))
                          .closed
                          .then((value) => cubit.SheetChange());
                    } else {
                      showToast(
                          message: 'please add sources',
                          state: ToastStates.WARNING);
                    }
                },
                child: const Icon(Icons.add),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              showUnselectedLabels: false,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeBottomNavBarState(index);
              },
              items: const [
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.account_balance_wallet_rounded),
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.analytics_rounded),
                  icon: Icon(Icons.analytics_outlined),
                  label: 'Stats',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
//tasks
