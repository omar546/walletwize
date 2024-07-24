import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walletwize/modules/register/cubit/register_states.dart';

import '../../../shared/network/end_points.dart';
import '../../../shared/network/remote/dio_helper.dart';

class RegisterCubit extends Cubit<WalletRegisterStates> {
  RegisterCubit(super.initialState);

  static RegisterCubit get(context) => BlocProvider.of(context);

  void userRegister({
    required String email,
    required String password,
  }) async {
    emit(WalletRegisterLoadingState());

    try {
      final response = await DioHelper.postData(
        url: REGISTER,
        data: {"email": email, "password": password},
      );
      log('Response data: ${response.data}');
      emit(WalletRegisterSuccessState(response.data['message']));
    } catch (error) {
      if (error is DioException) {
        emit(WalletRegisterErrorState(error.response!.data.toString()));
      } else {
        emit(WalletRegisterErrorState(error.toString()));
      }
    }
  }

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;

    emit(WalletRegChangePasswordVisibilityState());
  }
}
