import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/d_chart.dart';
import 'package:d_chart/ordinal/pie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AppCubit.get(context);
          return Scaffold(
            body: Column(

              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
                AspectRatio(
                  aspectRatio: 16/9,
                  child: DChartPieO(
                    configRenderPie:  ConfigRenderPie(arcWidth: 50,arcLabelDecorator: ArcLabelDecorator(labelPosition: ArcLabelPosition.outside)),
                    data: [
                      OrdinalData(
                          domain: 'Must',
                          measure: cubit.mustCount,
                          color: Colors.orange),
                      OrdinalData(
                          domain: 'Need',
                          measure: cubit.needCount,
                          color: Colors.blue),
                      OrdinalData(
                          domain: 'Want',
                          measure: cubit.wantCount,
                          color: Colors.yellow),

                    ],
                  ),
                ),
                const SizedBox(height: 20,),

              ],
            ),
          );
        });
  }
}
