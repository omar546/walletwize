import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:d_chart/d_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/cubit/cubit.dart';
import '../shared/network/local/cache_helper.dart';
import '../shared/styles/styles.dart';
import '../shared/styles/themes.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    List<TimeData> timeList = AppCubit.get(context).newTransactions.map((transaction) {
      DateTime date = AppCubit.get(context).parseDate(transaction['date']);
      double amount = transaction['amount'].toDouble();
      return TimeData(domain: date, measure: amount);
    }).toList();

    Map<String, int> sourceCounts = {};
    for (var transaction in AppCubit.get(context).newTransactions) {
      String source = transaction['source'];
      if (sourceCounts.containsKey(source)) {
        sourceCounts[source] = sourceCounts[source]! + 1;
      } else {
        sourceCounts[source] = 1;
      }
    }

    // Step 3: Create the list of DChartBarDataCustom objects
    List<DChartBarDataCustom> listData = sourceCounts.entries.map((entry) {
      return DChartBarDataCustom(color:Color(0xFFCFBAE1),value: entry.value.toDouble(), label: entry.key);
    }).toList();
    return BlocConsumer<ThemeCubit, ThemeData>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AppCubit.get(context);
          return Scaffold(
            body: ConditionalBuilder(
              condition: cubit.mustCount!=0,
              fallback: (context)=> const Icon(Icons.hourglass_empty_rounded),
              builder:(context)=> SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40,),
                    Text('You spend your money on:',style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    AspectRatio(
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
                    const SizedBox(height: 40,),
                    Text('And this is the Trend:',style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),),

                    Padding(
                      padding: const EdgeInsets.only(left: 35.0),
                      child: AspectRatio(
                        aspectRatio: 16/9,
                        child: DChartLineT(measureAxis: MeasureAxis(labelStyle: LabelStyle(color: CacheHelper.getData(key: ThemeCubit.themeKey) == 0 ?Styles.prussian:Styles.whiteColor)),domainAxis: DomainAxis(labelStyle: LabelStyle(color: CacheHelper.getData(key: ThemeCubit.themeKey) == 0 ?Styles.prussian:Styles.whiteColor)),allowSliding:true,groupList: [TimeGroup(
                          id: '1',
                          chartType: ChartType.line,
                          color:CacheHelper.getData(key: ThemeCubit.themeKey) == 0 ?Styles.prussian:Styles.pacific ,
                          data: timeList,

                        ),
                          ]),
                      ),
                    ),
                    const SizedBox(height: 60,),
                    Text('You use those sources often:',style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),),
                    const SizedBox(height: 20,),
                Padding(
                      padding: const EdgeInsets.only(left: 35.0),
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
                    const SizedBox(height: 100,),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
