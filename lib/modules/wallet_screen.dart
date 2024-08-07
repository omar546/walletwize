import 'dart:math';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walletwize/shared/styles/styles.dart';

import '../shared/components/components.dart';
import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AppCubit.get(context);

          return Scaffold(
              body: SingleChildScrollView(
            physics: cubit.visibleSheet
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (!cubit.visibleSheet) {
                        AppCubit.get(context).showSources();
                      }
                    },
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: ConditionalBuilder(
                            condition: AppCubit.get(context).visibleSources,
                            builder: (context) => Container(
                                decoration: BoxDecoration(
                                    color: Styles.greyColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15)),
                                width: MediaQuery.sizeOf(context).width * 0.8,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 15.0, right: 15.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Total Balance',
                                                  style: TextStyle(
                                                    fontFamily: 'Quicksand',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                FutureBuilder<double>(
                                                  future: cubit.getBalanceSum(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const SizedBox(
                                                        height: 100,
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          'Error: ${snapshot.error}');
                                                    } else {
                                                      return Text(
                                                        '${cubit.currency} ${snapshot.data?.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Quicksand',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                (cubit.changePercentage > 0)
                                                    ? Icons
                                                        .arrow_circle_up_rounded
                                                    : Icons
                                                        .arrow_circle_down_rounded,
                                                color:
                                                    (cubit.changePercentage > 0)
                                                        ? Styles.positive
                                                        : Styles.negative,
                                                size: 25,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                '${cubit.changePercentage} %',
                                                style: const TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: SizedBox(
                                              height: AppCubit.get(context)
                                                      .newSources
                                                      .isNotEmpty
                                                  ? (MediaQuery.sizeOf(context).height *
                                                      min(
                                                          AppCubit.get(context)
                                                                  .newSources
                                                                  .length /
                                                              8,
                                                          0.3))
                                                  : 30,
                                              child: ConditionalBuilder(
                                                  condition: AppCubit.get(context)
                                                      .newSources
                                                      .isNotEmpty,
                                                  fallback: (context) =>
                                                      const Text('add sources'),
                                                  builder: (context) =>
                                                      ListView.separated(
                                                          physics:
                                                              const BouncingScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemBuilder: (context,
                                                                  index) =>
                                                              buildSourceItem(
                                                                  context: context,
                                                                  model: AppCubit.get(context).newSources[index],
                                                                  index: 0),
                                                          separatorBuilder: (context, index) => const SizedBox(
                                                                height: 1,
                                                              ),
                                                          itemCount: AppCubit.get(context).newSources.length)))),
                                      Visibility(
                                        visible: !cubit.visibleSheet,
                                        replacement: const SizedBox(
                                          height: 30,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.add_box,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            AppCubit.get(context)
                                                .showSourcePrompt(context);
                                            cubit.addSourceTypeController.text =
                                                'Bank';
                                          },
                                        ),
                                      ),
                                      Visibility(
                                        visible: !cubit.visibleSheet,
                                        child: const Icon(
                                          Icons.arrow_drop_up,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            fallback: (context) => Container(
                                decoration: BoxDecoration(
                                    color: Styles.greyColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15)),
                                width: MediaQuery.sizeOf(context).width * 0.8,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 15.0, right: 15.0),
                                  child: Column(
                                    children: [
                                      ClipRect(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          widthFactor:
                                              MediaQuery.sizeOf(context).width *
                                                  0.4,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Total Balance',
                                                      style: TextStyle(
                                                        fontFamily: 'Quicksand',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    FutureBuilder<double>(
                                                      future:
                                                          cubit.getBalanceSum(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const SizedBox(
                                                            height: 100,
                                                          );
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Error: ${snapshot.error}');
                                                        } else {
                                                          return Text(
                                                            '${cubit.currency} ${snapshot.data?.toStringAsFixed(2)}',
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  'Quicksand',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 25,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Icon(
                                                    (cubit.changePercentage > 0)
                                                        ? Icons
                                                            .arrow_circle_up_rounded
                                                        : Icons
                                                            .arrow_circle_down_rounded,
                                                    color:
                                                        (cubit.changePercentage >
                                                                0)
                                                            ? Styles.positive
                                                            : Styles.negative,
                                                    size: 30,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    '${cubit.changePercentage} %',
                                                    style: const TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: ConditionalBuilder(
                      condition: cubit.newTransactions.isNotEmpty,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: ListView.separated(
                            reverse: true,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => Container(
                                  child: buildHistoryItem(
                                      model: cubit.newTransactions[index],
                                      index: 0,
                                      context: context),
                                ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                  height: 1,
                                ),
                            itemCount: cubit.newTransactions.length),
                      ),
                      fallback: (context) => const Opacity(
                        opacity: 0.3,
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: 50,
                            ),
                            Text('no data')
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ));
        });
  }
}
