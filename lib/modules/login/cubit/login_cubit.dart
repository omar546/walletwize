import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/login_model.dart';
import '../../../shared/network/end_points.dart';
import '../../../shared/network/remote/dio_helper.dart';
import 'login_states.dart';

class WalletLoginCubit extends Cubit<WalletLoginStates> {
  WalletLoginCubit(super.initialState);

  static WalletLoginCubit get(context) => BlocProvider.of(context);

  late LoginModel loginModel;

  void userLogin({
    required String email,
    required String password,
  }) {
    emit(WalletLoginLoadingState());

    DioHelper.postData(url: LOGIN, data: {
      "email": email,
      "password": password,
    }).then((value) {
      if (kDebugMode) {
        print(value.data);
      }
      loginModel = LoginModel.fromJson(value.data);
      emit(WalletLoginSuccessState(loginModel));
    }).catchError((error) {
      if (error is DioException) {
        emit(WalletLoginErrorState(error.response!.data.toString()));
      } else {
        emit(WalletLoginErrorState(error.toString()));
      }
    });
  }

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;

    emit(NoteChangePasswordVisibilityState());
  }
}
