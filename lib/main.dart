
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walletwize/shared/components/constants.dart';
import 'package:walletwize/shared/network/local/cache_helper.dart';
import 'package:walletwize/shared/network/remote/dio_helper.dart';
import 'package:walletwize/shared/styles/Themes.dart';
import 'layout/home_layout.dart';
import 'modules/login/login_screen.dart';
import 'modules/onboarding/onboarding_screen.dart';
import 'shared/bloc_observer.dart';
import 'shared/cubit/cubit.dart';

void main() async {
  // just to show branding
  // await Future.delayed(const Duration(milliseconds: 750));
  // if main() is async and there is await down here it will wait for it to finish before launching app
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();
  DioHelper.init();
  DioHelper2.init();

  await CacheHelper.init();
  Widget widget;
  bool onBoarding = CacheHelper.getData(key: 'onBoarding') ?? false;
  token = CacheHelper.getData(key: 'token') ?? 'null';
  if (kDebugMode) {
    print(token);
  }
  if (onBoarding != false) {
    if (token != 'null') {
      widget = BlocProvider(
        create: (context) => AppCubit()..createDatabase(),
        child: HomeLayout(),
      );
    } else {
      widget = BlocProvider(
        create: (context) => AppCubit()..createDatabase(),
        child: LoginScreen(),
      );
    }
  } else {
    widget = const OnBoardingScreen();
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp(widget)));
}

class MyApp extends StatelessWidget {
  final Widget startWidget;
  const MyApp(this.startWidget, {super.key});
  // constructor
  // build
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: startWidget,
          );
        },
      ),
    );
  }
}
