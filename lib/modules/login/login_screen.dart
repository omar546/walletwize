import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../layout/home_layout.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/local/cache_helper.dart';
import '../../shared/styles/styles.dart';
import '../../shared/styles/themes.dart';
import '../register/register_screen.dart';
import 'cubit/login_cubit.dart';
import 'cubit/login_states.dart';

class LoginScreen extends StatelessWidget {
  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  bool isPassword = true;

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => NoteLoginCubit(NoteLoginInitialState()),
      child: BlocConsumer<NoteLoginCubit, NoteLoginStates>(
        listener: (context, state) {
          if (state is NoteLoginSuccessState) {
            if (state.loginModel.status ?? false) {
              if (kDebugMode) {
                print(state.loginModel.message);
              }
              if (kDebugMode) {
                print(state.loginModel.data?.token);
              }
              CacheHelper.saveData(
                      key: 'token', value: state.loginModel.data?.token)
                  .then((value) {
                    token = state.loginModel.data?.token??'';
                    if (kDebugMode) {
                      print(token);
                    }
                    if (kDebugMode) {
                      print('after log in ');
                    }
                navigateAndFinish(context, HomeLayout());
              });
            } else {
              if (kDebugMode) {
                print(state.loginModel.message);
              }
              showToast(
                  message: state.loginModel.message ?? '',
                  state: ToastStates.ERROR);
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment:MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallet',textAlign: TextAlign.center,
                                  style: TextStyle(height:1,fontSize: 50, fontFamily: 'quicksand',fontWeight: FontWeight.w900,color: CacheHelper.getData(key: ThemeCubit.themeKey) == 0 ?Styles.prussian:Styles.pacific),
                                ),
                                Text(
                                  'Wize',textAlign: TextAlign.center,
                                  style: TextStyle(height:1,fontSize: 50, fontFamily: 'quicksand',fontWeight: FontWeight.w900,color: CacheHelper.getData(key: ThemeCubit.themeKey) == 0 ?Styles.prussian:Styles.pacific),
                                ),
                                const SizedBox(height: 70,)
                              ],
                            ),
                          ],
                        ),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        const Text(
                          'Join now to take notes!',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            height: 55,
                            child: customForm(
                              context: context,
                              label: 'Email Address',
                              controller: emailController,
                              type: TextInputType.emailAddress,
                              onSubmit: (String value) {
                                if (kDebugMode) {
                                  print(value);
                                }
                              },
                              onChange: (String value) {
                                if (kDebugMode) {
                                  print(value);
                                }
                              },
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return "email..please!";
                                } else {
                                  return null;
                                }
                              },
                              prefix: Icons.alternate_email_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            height: 55,
                            child: customForm(
                              context: context,
                              label: 'Password',
                              controller: passwordController,
                              type: TextInputType.visiblePassword,
                              suffix: NoteLoginCubit.get(context).suffix,
                              onSubmit: (value) {
                                if (formKey.currentState!.validate()) {
                                  NoteLoginCubit.get(context).userLogin(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                }
                              },
                              onChange: (String value) {
                                if (kDebugMode) {
                                  print(value);
                                }
                              },
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return "forgot your password!";
                                } else {
                                  return null;
                                }
                              },
                              prefix: Icons.password_rounded,
                              isPassword: NoteLoginCubit.get(context).isPassword,
                              suffixPressed: () {
                                NoteLoginCubit.get(context)
                                    .changePasswordVisibility();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Center(
                          child: ConditionalBuilder(
                              condition: state is! NoteLoginLoadingState,
                              builder: (context) => customButton(
                                  widthRatio: 0.6,
                                  context: context,
                                  text: "LOGIN",
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      NoteLoginCubit.get(context).userLogin(
                                          email: emailController.text,
                                          password: passwordController.text);
                                    }
                                    CacheHelper.saveData(key: 'token', value: 'faketoken');
                                    navigateAndFinish(context, HomeLayout());
                                  }),
                              fallback: (context) =>
                              const CircularProgressIndicator()),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account?'),
                            customTextButton(
                              onPressed: () {
                                navigateTo(context, RegisterScreen());
                              },
                              text: 'REGISTER',
                              color: Colors.lightBlue,
                            ),
                          ],
                        ),
                        // Row(mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     Checkbox(shape:const CircleBorder(),onChanged: (f){NoteLoginCubit.get(context).changeAgreement();}, value: NoteLoginCubit.get(context).agreement,),
                        //     const Expanded(child: Text('By checking, you agree on using your data to improve our model',softWrap: true,maxLines: 4,))
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
