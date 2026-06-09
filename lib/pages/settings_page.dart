import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../app_state.dart';
import '../widgets/app_drawer.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = false;

  String _getLanguageName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'bn':
        return 'বাংলা (Bengali)';
      case 'en':
      default:
        return 'English';
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
    final primaryColor = const Color(0xFF673AB7);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(l10n.appearance),
          const SizedBox(height: 12),
          _buildCard([
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeNotifier,
              builder: (context, mode, child) {
                final isDark = mode == ThemeMode.dark;
                return SwitchListTile(
                  title: Text(
                    l10n.darkTheme,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? l10n.savesBattery : l10n.brightAndClear,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber : Colors.orange,
                  ),
                  value: isDark,
                  onChanged: toggleThemeMode,
                  activeColor: primaryColor,
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.language, color: primaryColor),
              title: Text(
                l10n.language,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _getLanguageName(context),
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, l10n),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.notifications),
          const SizedBox(height: 12),
          _buildCard([
            SwitchListTile(
              title: Text(
                l10n.pushNotifications,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.receiveAlerts,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              secondary: Icon(Icons.notifications_active, color: primaryColor),
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
              activeColor: primaryColor,
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: Text(
                l10n.emailDigests,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.receiveDigests,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              secondary: Icon(Icons.email, color: primaryColor),
              value: _emailUpdatesEnabled,
              onChanged: (val) {
                setState(() {
                  _emailUpdatesEnabled = val;
                });
              },
              activeColor: primaryColor,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.about),
          const SizedBox(height: 12),
          _buildCard([
            ListTile(
              leading: Icon(Icons.info_outline, color: primaryColor),
              title: Text(
                l10n.formStackerApp,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.appVersion,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.code, color: primaryColor),
              title: Text(
                l10n.developerTools,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.showAdvanced,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.devModeEnabled),
                    backgroundColor: primaryColor,
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF673AB7),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
