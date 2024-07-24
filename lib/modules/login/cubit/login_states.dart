import '../../../models/login_model.dart';

abstract class WalletLoginStates {}

class WalletLoginInitialState extends WalletLoginStates {}

class WalletLoginLoadingState extends WalletLoginStates {}

class WalletLoginSuccessState extends WalletLoginStates {
  final LoginModel loginModel;

  WalletLoginSuccessState(this.loginModel);
}

class WalletLoginErrorState extends WalletLoginStates {
  final String error;

  WalletLoginErrorState(this.error);
}

class NoteChangePasswordVisibilityState extends WalletLoginStates {}

class NoteChangeAgreement extends WalletLoginStates {}
