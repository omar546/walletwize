import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walletwize/shared/styles/styles.dart';

import '../network/local/cache_helper.dart';

enum AppTheme { Light, Dark }

class ThemeCubit extends Cubit<ThemeData> {
  static const String themeKey = 'theme';
  ThemeCubit() : super(lightTheme) {

    final themeIndex =
        CacheHelper.getData(key: themeKey) ?? AppTheme.Dark.index;
    if (themeIndex == AppTheme.Dark.index) {
      emit(darkTheme);
    } else {
      emit(lightTheme);
    }
  }

  void toggleTheme() {
    if (state == lightTheme) {
      CacheHelper.saveData(key: themeKey, value: AppTheme.Dark.index);
      emit(darkTheme);
    } else {
      CacheHelper.saveData(key: themeKey, value: AppTheme.Light.index);
      emit(lightTheme);
    }
  }
  bool get isDarkTheme => state == darkTheme;
}

MaterialColor customGum = const MaterialColor(0xFF22AED1, {
  50: Color(0xFFE0F5FB),
  100: Color(0xFFB3E4F4),
  200: Color(0xFF80D2ED),
  300: Color(0xFF4DBFE6),
  400: Color(0xFF26B0E0),
  500: Color(0xFF22AED1),
  600: Color(0xFF1F9FC8),
  700: Color(0xFF1A8EBD),
  800: Color(0xFF157DB3),
  900: Color(0xFF0C64A0),
});


ThemeData lightTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: customGum,selectionHandleColor: customGum ,selectionColor: Styles.positive

    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Styles.greyColor; // Color when button is disabled
                }
                return Styles.prussian; // Color when button is enabled
              },
            ),),),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 30,
      backgroundColor: Styles.whiteColor,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Styles.prussian,
      unselectedItemColor: Styles.greyColor,
      selectedLabelStyle: TextStyle(fontFamily: 'quicksand'),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Styles.prussian),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Styles.whiteColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      backgroundColor: Styles.whiteColor,
      elevation: 0.0,
      titleTextStyle: TextStyle(color: Styles.blackColor),
    ),
    scaffoldBackgroundColor: Styles.whiteColor,
    primarySwatch: customGum,
    textTheme: TextTheme(
      bodyMedium: const TextStyle(
        color: Styles.blackColor,
      ),
      bodySmall: TextStyle(
          color: Styles.blackColor.withOpacity(0.5), fontFamily: 'quicksand'),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: Styles.prussian,
      suffixIconColor: Styles.greyColor.withOpacity(0.5),
      labelStyle: const TextStyle(color: Styles.blackColor),
    ));
ThemeData darkTheme = ThemeData(
  textSelectionTheme: TextSelectionThemeData(
      cursorColor: customGum,selectionHandleColor: customGum ,selectionColor: Styles.positive
  ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Styles.greyColor; // Color when button is disabled
            }
            return Styles.pacific; // Color when button is enabled
          },
        ),),),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 30,
      backgroundColor: Styles.prussian,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Styles.pacific,
      unselectedItemColor: Styles.greyColor,
      selectedLabelStyle: TextStyle(fontFamily: 'quicksand'),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Styles.whiteColor),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Styles.prussian,
        statusBarIconBrightness: Brightness.light,
      ),
      backgroundColor: Styles.prussian,
      elevation: 0.0,
      titleTextStyle: TextStyle(color: Styles.whiteColor),
    ),
    scaffoldBackgroundColor: Styles.prussian,
    primarySwatch: customGum,
    textTheme: TextTheme(
      bodyMedium: const TextStyle(
        color: Styles.whiteColor,
      ),
      bodySmall: TextStyle(
          color: Styles.greyColor.withOpacity(0.5), fontFamily: 'quicksand'),
    ),
    iconTheme: const IconThemeData(color: Styles.greyColor),
    inputDecorationTheme: const InputDecorationTheme(
        prefixIconColor: Styles.greyColor,
        suffixIconColor: Styles.prussian,
        labelStyle: TextStyle(color: Styles.greyColor)));
