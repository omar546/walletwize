abstract class WalletRegisterStates {}

class WalletRegisterInitialState extends WalletRegisterStates {
  WalletRegisterInitialState();
}

class WalletRegisterLoadingState extends WalletRegisterStates {}

class WalletRegisterSuccessState extends WalletRegisterStates {
  final String message;

  WalletRegisterSuccessState(this.message);
}

class WalletRegisterErrorState extends WalletRegisterStates {
  final String error;

  WalletRegisterErrorState(this.error);
}

class WalletRegChangePasswordVisibilityState extends WalletRegisterStates {}
