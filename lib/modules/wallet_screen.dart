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
         var categories = cubit.newSources;

         categories.sort((a, b) => a['id'].compareTo(b['id']));

         return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            Center(
              child: GestureDetector(
                onTap: (){AppCubit.get(context).showSources();},
                child: ConditionalBuilder(
                  condition: AppCubit.get(context).visibleSources,
                  builder:(context) => Container(decoration:BoxDecoration(color:Styles.greyColor.withOpacity(0.2),borderRadius: BorderRadius.circular(15)),width:MediaQuery.sizeOf(context).width*0.8,child: Padding(
                    padding: const EdgeInsets.only(top: 20,left: 15.0,right: 15.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Balance',style: TextStyle(fontFamily: 'Quicksand',fontWeight: FontWeight.bold,fontSize: 12,),),
                                const SizedBox(height: 10,),
                      FutureBuilder<double>(
                        future: cubit.getBalanceSum(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              '\$ ${snapshot.data?.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            );
                          }
                        },
                      ),],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(Icons.arrow_circle_up_rounded,color: Styles.positive,size: 25,),
                                SizedBox(height: 10,),
                                Text('+30.33%',style: TextStyle(fontFamily: 'Quicksand',fontWeight: FontWeight.bold,fontSize: 12,),),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(height:AppCubit.get(context).newSources.isNotEmpty?150:5,child: ConditionalBuilder(condition:AppCubit.get(context).newSources.isNotEmpty,fallback: (context) => const SizedBox(
                          ),builder:(context)=> ListView.separated(physics:const BouncingScrollPhysics(),shrinkWrap:true,itemBuilder:(context, index)=> buildSourceItem(context: context,model: AppCubit.get(context).newSources[index],index: 0) , separatorBuilder: (context, index)=>SizedBox(height: 1,), itemCount: AppCubit.get(context).newSources.length)))
                        ),
                        IconButton(icon: Icon(Icons.add_box,size: 30,),onPressed: (){AppCubit.get(context).showCategoryPrompt(context);},),
                        Icon(Icons.arrow_drop_up,)
                      ],
                    ),
                  )),
                  fallback: (context) => Container(decoration:BoxDecoration(color:Styles.greyColor.withOpacity(0.2),borderRadius: BorderRadius.circular(15)),width:MediaQuery.sizeOf(context).width*0.8,child: Padding(
                    padding: const EdgeInsets.only(top: 20,left: 15.0,right: 15.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Balance',style: TextStyle(fontFamily: 'Quicksand',fontWeight: FontWeight.bold,fontSize: 15,),),
                                const SizedBox(height: 10,),
                                FutureBuilder<double>(
                                  future: cubit.getBalanceSum(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        '\$ ${snapshot.data?.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      );
                                    }
                                  },
                                ),                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(Icons.arrow_circle_up_rounded,color: Styles.positive,size: 30,),
                                 SizedBox(height: 10,),
                                Text('+30.33%',style: TextStyle(fontFamily: 'Quicksand',fontWeight: FontWeight.bold,fontSize: 15,),),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_drop_down,)
                      ],
                    ),
                  )),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(child: ListView.separated(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemBuilder:(context, index)=> Container(color: Styles.whiteColor,width: MediaQuery.sizeOf(context).width*0.5,height: 50,) , separatorBuilder: (context, index)=>SizedBox(height: 1,), itemCount: 100))
            ),

          ],
        ),
      )
    );
  });
}}
