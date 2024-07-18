import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../layout/home_layout.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/local/cache_helper.dart';
import 'cubit/register_cubit.dart';
import 'cubit/register_states.dart';


class RegisterScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var nameController = TextEditingController();

  var passwordController = TextEditingController();
  var passwordController2 = TextEditingController();

  var phoneController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => RegisterCubit(ShopRegisterInitialState()),
      child: BlocConsumer<RegisterCubit, ShopRegisterStates>(
        listener: (context, state) {
          if (state is ShopRegisterSuccessState) {
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
                token = state.loginModel.data?.token ?? '';
                navigateAndFinish(context,HomeLayout());
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
                            const Text(
                              'REGISTER',
                              style: TextStyle(
                                fontSize: 30.0,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            const Text(
                              'Leverage your Expense tracking taking experience!',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                            customForm(
                              context: context,
                              label: 'User Name',
                              controller: nameController,
                              type: TextInputType.name,
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
                                  return "name..please!";
                                } else {
                                  return null;
                                }
                              },
                              prefix: Icons.person_outline,
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            customForm(
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
                            const SizedBox(
                              height: 15.0,
                            ),
                            customForm(
                              context: context,
                              label: 'Password',
                              controller: passwordController,
                              type: TextInputType.visiblePassword,
                              suffix: RegisterCubit.get(context).suffix,
                              onChange: (String value) {
                                if (kDebugMode) {
                                  print(value);
                                }
                              },
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return "forgot the password!";
                                } else {
                                  return null;
                                }
                              },
                              prefix: Icons.password_rounded,
                              isPassword:
                                  RegisterCubit.get(context).isPassword,
                              suffixPressed: () {
                                RegisterCubit.get(context)
                                    .changePasswordVisibility();
                              },
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            customForm(
                              context: context,
                              label: 'Re-enter Password',
                              controller: passwordController,
                              type: TextInputType.visiblePassword,
                              onSubmit: (value) {
                                if (formKey.currentState!.validate()) {
                                  if(passwordController2.text==passwordController.text){
                                  RegisterCubit.get(context).userRegister(

                                    email: emailController.text,
                                    name: nameController.text,
                                    phone: phoneController.text,
                                    password: passwordController.text,
                                  );}
                                  else{showToast(message: 'password mismatch', state: ToastStates.ERROR);}
                                }
                              },
                              onChange: (String value) {
                                if (kDebugMode) {
                                  print(value);
                                }
                              },
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return "please re-enter your password!";
                                } else {
                                  return null;
                                }
                              },
                              prefix: Icons.password_rounded,
                              isPassword:
                              RegisterCubit.get(context).isPassword,
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),

                            // customForm(
                            //   context: context,
                            //   label: 'Phone Number',
                            //   controller: phoneController,
                            //   type: TextInputType.phone,
                            //   onSubmit: (String value) {
                            //     if (kDebugMode) {
                            //       print(value);
                            //     }
                            //   },
                            //   onChange: (String value) {
                            //     if (kDebugMode) {
                            //       print(value);
                            //     }
                            //   },
                            //   validate: (value) {
                            //     if (value!.isEmpty) {
                            //       return "phone..please!";
                            //     } else {
                            //       return null;
                            //     }
                            //   },
                            //   prefix: Icons.phone_android_rounded,
                            // ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Center(
                              child: ConditionalBuilder(
                                  condition: state is! ShopRegisterLoadingState,
                                  builder: (context) => customButton(
                                      widthRatio: 0.6,
                                      context: context,
                                      text: "REGISTER",
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          RegisterCubit.get(context).userRegister(

                                              name: nameController.text,
                                              email: emailController.text,
                                              phone: phoneController.text,
                                              password:
                                                  passwordController.text);
                                        }
                                      }),
                                  fallback: (context) =>
                                      const CircularProgressIndicator()),
                            ),
                          ]),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
