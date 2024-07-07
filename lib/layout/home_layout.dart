import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walletwize/modules/wallet_screen.dart';

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
        listener: (context, state) {
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              leading: IconButton(icon:const Icon(Icons.person),onPressed: (){},),
              title: Center(child: Text('WalletWize',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Quicksand',fontSize: 25),)),
              actions: [IconButton(icon:const Icon(Icons.more_horiz_sharp),onPressed: (){},),],
            ),
            key: scaffoldKey,
            body: cubit.screens[cubit.currentIndex],
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(

              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: BottomNavigationBar(
showUnselectedLabels: false,              currentIndex: cubit.currentIndex,
              onTap: (index){
                cubit.changeBottomNavBarState(index);
              },
              items: const [
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.account_balance_wallet),
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  label:'Wallet',
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.analytics_rounded),
                  icon:Icon(Icons.analytics_outlined),
                  label:'Stats',
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