import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.light,
);

const String routeHome = '/';
const String routeUserLogin = '/login';
const String routeUserForm = '/form';
const String routeAdmin = '/admin';
const String routeSettings = '/settings';

void toggleThemeMode(bool useDarkMode) {
  themeModeNotifier.value = useDarkMode ? ThemeMode.dark : ThemeMode.light;
}
