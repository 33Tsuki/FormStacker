import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../app_state.dart';
import '../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    Navigator.pop(context);
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    final myAppState = MyApp.of(context);
    final currentLocale = Localizations.localeOf(context);

    showDialog(
      context: context,
      builder: (context) {
        Locale selectedLocale = currentLocale;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                l10n.selectLanguage,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<Locale>(
                    title: Text('English', style: GoogleFonts.poppins()),
                    value: const Locale('en'),
                    groupValue: selectedLocale,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedLocale = val;
                        });
                        myAppState.changeLocale(val);
                        Navigator.pop(context);
                      }
                    },
                    activeColor: const Color(0xFF673AB7),
                  ),
                  RadioListTile<Locale>(
                    title: Text('हिंदी', style: GoogleFonts.poppins()),
                    value: const Locale('hi'),
                    groupValue: selectedLocale,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedLocale = val;
                        });
                        myAppState.changeLocale(val);
                        Navigator.pop(context);
                      }
                    },
                    activeColor: const Color(0xFF673AB7),
                  ),
                  RadioListTile<Locale>(
                    title: Text('বাংলা', style: GoogleFonts.poppins()),
                    value: const Locale('bn'),
                    groupValue: selectedLocale,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedLocale = val;
                        });
                        myAppState.changeLocale(val);
                        Navigator.pop(context);
                      }
                    },
                    activeColor: const Color(0xFF673AB7),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF673AB7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final primaryColor = const Color(0xFF673AB7);
    final accentColor = const Color(0xFF7C4DFF);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Purple gradient header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  accentColor,
                ],
              ),
            ),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.description, color: Colors.white, size: 36),
                const SizedBox(height: 16),
                Text(
                  l10n.formStacker,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.navigationAndSettings,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Navigation items
          ListTile(
            leading: Icon(
              Icons.home,
              color: currentRoute == routeHome ? primaryColor : null,
            ),
            title: Text(
              l10n.home,
              style: GoogleFonts.poppins(),
            ),
            selected: currentRoute == routeHome,
            selectedTileColor: Colors.purple.withValues(alpha: 0.1),
            onTap: () => _navigateTo(context, routeHome),
          ),
          ListTile(
            leading: Icon(
              Icons.edit_note,
              color: (currentRoute == routeUserForm || currentRoute == routeUserLogin) ? primaryColor : null,
            ),
            title: Text(
              l10n.fillForm,
              style: GoogleFonts.poppins(),
            ),
            selected: currentRoute == routeUserForm || currentRoute == routeUserLogin,
            selectedTileColor: Colors.purple.withValues(alpha: 0.1),
            onTap: () => _navigateTo(context, routeUserLogin),
          ),
          ListTile(
            leading: Icon(
              Icons.admin_panel_settings,
              color: currentRoute == routeAdmin ? primaryColor : null,
            ),
            title: Text(
              l10n.administration,
              style: GoogleFonts.poppins(),
            ),
            selected: currentRoute == routeAdmin,
            selectedTileColor: Colors.purple.withValues(alpha: 0.1),
            onTap: () => _navigateTo(context, routeAdmin),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: currentRoute == routeSettings ? primaryColor : null,
            ),
            title: Text(
              l10n.settings,
              style: GoogleFonts.poppins(),
            ),
            selected: currentRoute == routeSettings,
            selectedTileColor: Colors.purple.withValues(alpha: 0.1),
            onTap: () => _navigateTo(context, routeSettings),
          ),
          const Divider(height: 1),
          // Dark mode toggle
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, mode, child) {
              final isDark = mode == ThemeMode.dark;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      key: ValueKey<bool>(isDark),
                      color: isDark ? Colors.amber : Colors.orange,
                    ),
                  ),
                  title: Text(
                    isDark ? l10n.darkMode : l10n.lightMode,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: toggleThemeMode,
                    activeThumbColor: Colors.white,
                    activeTrackColor: primaryColor,
                  ),
                ),
              );
            },
          ),
          // Language selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(Icons.language, color: primaryColor),
              title: Text(
                l10n.language,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () => _showLanguageDialog(context, l10n),
            ),
          ),
        ],
      ),
    );
  }
}
