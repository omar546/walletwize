import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:d_chart/d_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../shared/cubit/cubit.dart';
import '../shared/network/local/cache_helper.dart';
import '../shared/styles/styles.dart';
import '../shared/styles/themes.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {


    Map<String, int> sourceCounts = {};
    for (var transaction in AppCubit.get(context).newTransactions) {
      String source = transaction['source'];
      if (sourceCounts.containsKey(source)) {
        sourceCounts[source] = sourceCounts[source]! + 1;
      } else {
        sourceCounts[source] = 1;
      }
    }

    List<DChartBarDataCustom> listData = sourceCounts.entries.map((entry) {
      return DChartBarDataCustom(color:const Color(0xFFCFBAE1),value: entry.value.toDouble(), label: entry.key);
    }).toList();

    Map<String, int> dayCounts = {};
    for (var transaction in AppCubit.get(context).newTransactions) {
      DateTime date = DateFormat.yMMMd().parse(transaction['date']);
      String day = DateFormat.E().format(date);
      if (dayCounts.containsKey(day)) {
        dayCounts[day] = dayCounts[day]! + 1;
      } else {
        dayCounts[day] = 1;
      }
    }

    List<DChartBarDataCustom> dayData = dayCounts.entries.map((entry) {
      return DChartBarDataCustom(color:Styles.pacific,value: entry.value.toDouble(), label: entry.key);
    }).toList();


    return BlocConsumer<ThemeCubit, ThemeData>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AppCubit.get(context);
          return Scaffold(
            body:
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40,),
                      Text('You spend your money on:',style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),),
                      const SizedBox(height: 10,),
                      ConditionalBuilder(
                        condition: cubit.mustCount !=0 || cubit.needCount !=0 ||cubit.wantCount !=0,
                        fallback: (context)=> Opacity(opacity:0.3,child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_empty_rounded,size: 50),
                            Text('no data')
                          ],
                        )),
                        builder:(context)=> AspectRatio(
                          aspectRatio: 16/9,
                          child: DChartPieO(
                            configRenderPie:  ConfigRenderPie(arcWidth: 40,arcLabelDecorator: ArcLabelDecorator(leaderLineStyle:ArcLabelLeaderLineStyle(color: CacheHelper.getData(key: ThemeCubit.themeKey) == 0 ?Styles.prussian:Styles.whiteColor, length: 25, thickness: 2),outsideLabelStyle:LabelStyle(color:CacheHelper.getData(key: ThemeCubit.themeKey) == 0 ?Styles.prussian:Styles.whiteColor),labelPosition: ArcLabelPosition.outside)),
                            data: [
                              OrdinalData(
                                  domain: 'Musts',
                                  measure: cubit.mustCount,
                                  color: Colors.orange),
                              OrdinalData(
                                  domain: 'Needs',
                                  measure: cubit.needCount,
                                  color: Colors.yellow),
                              OrdinalData(
                                  domain: 'Wants',
                                  measure: cubit.wantCount,
                                  color: Styles.pacific),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40,),
                      Text('This is the Trend:',style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),),
                      const SizedBox(height: 10,),
                      ConditionalBuilder(
                        condition: cubit.newTransactions.isNotEmpty,
                        fallback: (context)=> Opacity(opacity:0.3,child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_empty_rounded,size: 50),
                            Text('no data')
                          ],
                        )),

                        builder:(context)=> Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0),
                          child: AspectRatio(
                              aspectRatio: 16/9,
                              child: DChartBarCustom(

                                verticalDirection: true,
                                  spaceDomainLabeltoChart: 10,
                                  radiusBar: const BorderRadius.only(
                                    bottomRight: Radius.circular(8),
                                    topRight: Radius.circular(8),),
                                  showDomainLabel: true,
                                  spaceMeasureLabeltoChart: 10,


                                  listData: dayData
                              )
                          ),
                        ),
                      ),
                      const SizedBox(height: 60,),
                      Text('You use those sources often:',style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),),
                      const SizedBox(height: 20,),
                      ConditionalBuilder(
                        condition: cubit.newSources.isNotEmpty,
                        fallback: (context)=> Opacity(opacity:0.3,child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_empty_rounded,size: 50),
                            Text('no data')
                          ],
                        )),
                    builder:(context)=> Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0),
                          child: AspectRatio(
                            aspectRatio: 16/9,
                            child: DChartBarCustom(
                              spaceDomainLabeltoChart: 10,
                                radiusBar: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),),
                              showDomainLabel: true,
                                listData: listData
                            )
                    ),
                          ),
                  ),
                      const SizedBox(height: 150,),
                    ],
                  ),
                ),));

        });
  }
}
