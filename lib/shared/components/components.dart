import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../cubit/cubit.dart';
import '../styles/Themes.dart';
import '../styles/styles.dart';

Widget buildTextField({
  double widthRit = 0.6,
  required BuildContext context,
  required String labelText,
  required TextEditingController controller,
  IconData? prefix,
  bool isClickable = true,
  var onTap,
  var validate,
  required TextInputType type,
  var onSubmit,
  var onChange,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(
        right: 40,
      ),
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: TextFormField(
          enabled: isClickable,
          validator: validate,
          keyboardType: type,
          minLines: 1,
          maxLines: double.maxFinite.toInt(),
          onFieldSubmitted: onSubmit,
          onChanged: onChange,
          onTap: onTap,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16),
          cursorColor: Styles.pacific,
          controller: controller,
          // Set the validator function
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 45.0),
            prefixIcon: Icon(prefix, color: Styles.pacific),
            hintText: labelText,
            hintStyle: TextStyle(
              color: Styles.pacific.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            // contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
            border: InputBorder.none,
          ),
        ),
      ),
    ),
  );
}

void navigateTo(context, widget) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ));

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
    (Route<dynamic> route) => false);

Widget customButton(
    {required final String text,
    required BuildContext context,
    double widthRatio = double.infinity,
    double height = 50.0,
    required final VoidCallback onPressed}) {
  return SizedBox(
    height: height,
    width: MediaQuery.sizeOf(context).width * widthRatio,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(), backgroundColor: Styles.pacific),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'bitter-bold',
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    ),
  );
}

Widget customForm({
  required BuildContext context,
  required TextEditingController controller,
  required TextInputType type,
  dynamic onSubmit,
  dynamic onChange,
  dynamic onTap,
  bool isPassword = false,
  dynamic validate,
  required String label,
  IconData? prefix,
  IconData? suffix,
  dynamic suffixPressed,
  bool isClickable = true,
  IconButton? suffixIcon,
}) {
  return TextFormField(
    enabled: isClickable,
    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
    controller: controller,
    keyboardType: type,
    obscureText: isPassword,
    onFieldSubmitted: onSubmit,
    onChanged: onChange,
    validator: validate,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        prefix,
      ),
      suffixIcon: suffix != null
          ? IconButton(
              onPressed: suffixPressed,
              icon: Icon(
                suffix,
                color: Styles.pacific,
              ),
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(
          color: Styles.greyColor,
          width: 2.0,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Styles.pacific,
        ),
      ),
    ),
  );
}

Widget customTextButton({
  required String text,
  required dynamic onPressed,
  Color color = Styles.pacific,
}) {
  return TextButton(
    onPressed: onPressed,
    child: Text(
      text,
      style: TextStyle(color: color),
    ),
  );
}

void showToast({
  required String message,
  required ToastStates state,
}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0);
}

// enum
enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Styles.pacific;
      break;
  }

  return color;
}
