import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../cubit/cubit.dart';
import '../network/local/cache_helper.dart';
import '../styles/styles.dart';
import '../styles/themes.dart';

Widget buildHistoryItem({required Map model, context, required index}) =>
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${model['time']}\n${model['date']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                model['source'].length > 4
                    ? '${model['source'].substring(0, 4)}...'
                    : '${model['source']}',
                style: const TextStyle(
                    fontFamily: 'Quicksand', fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                model['amount'].toString().length > 9
                    ? '${AppCubit.get(context).currency} ${model['amount'].toString().substring(0, 4)}...'
                    : '${AppCubit.get(context).currency} ${model['amount']}',
                style: const TextStyle(
                    fontFamily: 'Quicksand', fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Visibility(
                  replacement: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Styles.negative,
                  ),
                  visible: model['type'] == 'increase',
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Styles.positive,
                  )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            color: Styles.leather,
            height: 1,
          ),
        )
      ],
    );

Widget buildSourceItem({required Map model, context, required index}) =>
    GestureDetector(
      onTap: () {
        // if (!AppCubit.get(context).visibleSheet) {
        //   AppCubit.get(context).showSourceValueUpdatePrompt(
        //       id: model['id'],
        //       context: context,
        //       source: model['source'],
        //       balance: model['balance'],
        //       type: model['type']);
        // }
      },
      child: Dismissible(
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          color: Styles.greyColor.withOpacity(0),
          child: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.delete_forever_rounded,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ),
        confirmDismiss: (DismissDirection direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                title: Text(
                  "Confirm Delete",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Delete"),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          AppCubit.get(context).deleteSource(id: model['id']);
        },
        key: Key(model['id'].toString()),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context)
                                .inputDecorationTheme
                                .prefixIconColor
                                ?.withOpacity(0.5) ??
                            Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      color: Styles.whiteColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              model['source'].length > 9
                                                  ? '${model['source'].substring(0, 9)}...'
                                                  : '${model['source']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Quicksand',
                                                fontSize: 20,
                                                color: Styles.prussian,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              '${AppCubit.get(context).currency} ${model['balance']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Quicksand',
                                                fontSize: 20,
                                                color: Styles.prussian,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Visibility(
                                              visible: model['type']
                                                      .contains('bank') ||
                                                  model['type']
                                                      .contains('account'),
                                              child: const Padding(
                                                padding: EdgeInsets.only(
                                                    right: 10.0),
                                                child: Icon(
                                                  Icons.account_balance,
                                                  color: Styles.prussian,
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: model['type']
                                                  .contains('card'),
                                              child: const Padding(
                                                padding: EdgeInsets.only(
                                                    right: 10.0),
                                                child: Icon(
                                                  Icons.credit_card,
                                                  color: Styles.prussian,
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: model['type']
                                                  .contains('cash'),
                                              child: const Padding(
                                                padding: EdgeInsets.only(
                                                    right: 10.0),
                                                child: Icon(
                                                  Icons.money,
                                                  color: Styles.prussian,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

Widget buildSourceSelectionItem(
        {required Map model,
        context,
        required index,
        required bool isSelected}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: model['type'] == '',
            child: Icon(
              Icons.account_balance,
              color: isSelected
                  ? (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                      ? Styles.prussian
                      : Styles.pacific)
                  : Styles.greyColor,
            ),
          ),
          Visibility(
            visible: model['type'].contains('bank') ||
                model['type'].contains('account'),
            child: Icon(
              Icons.account_balance,
              color: isSelected
                  ? (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                      ? Styles.prussian
                      : Styles.pacific)
                  : Styles.greyColor,
            ),
          ),
          Visibility(
            visible: model['type'].contains('card') ||
                model['type'].contains('credit'),
            child: Icon(
              Icons.credit_card,
              color: isSelected
                  ? (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                      ? Styles.prussian
                      : Styles.pacific)
                  : Styles.greyColor,
            ),
          ),
          Visibility(
            visible: model['type'].contains('cash'),
            child: Icon(
              Icons.money,
              color: isSelected
                  ? (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                      ? Styles.prussian
                      : Styles.pacific)
                  : Styles.greyColor,
            ),
          ),
          Text(
            model['source'].length > 5
                ? '${model['source'].substring(0, 5)}...'
                : '${model['source']}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: 'Quicksand',
              fontSize: 20,
              color: isSelected
                  ? (CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                      ? Styles.prussian
                      : Styles.pacific)
                  : Styles.greyColor,
            ),
          ),
        ],
      ),
    );

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
          shape: const StadiumBorder(),
          backgroundColor: CacheHelper.getData(key: ThemeCubit.themeKey) == 0
              ? Styles.prussian
              : Styles.pacific),
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
      errorStyle: const TextStyle(color: Styles.negative),
      labelText: label,
      prefixIcon: Icon(
        prefix,
      ),
      suffixIcon: suffix != null
          ? IconButton(
              onPressed: suffixPressed,
              icon: Icon(suffix,
                  color: CacheHelper.getData(key: ThemeCubit.themeKey) == 0
                      ? Styles.prussian
                      : Styles.pacific),
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
