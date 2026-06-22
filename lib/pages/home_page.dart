import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../app_state.dart';
import '../pages/notifications.dart';
import '../pages/overview.dart';
import '../store/response_store.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sync_status_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = ResponseStore().init();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF673AB7);
    final lightPurpleTint = const Color(0xFFEDE7F6);
    final statCardBg = const Color(0xFFF3E5F5);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          l10n.formStacker,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Notifications(),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SyncStatusBar(),
          Expanded(
            child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              color: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeBackWaving,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.formStacker,
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.fillAndManage,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(
                      Icons.description_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
            // Action Cards Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fill Form Card
                  _buildActionCard(
                    context: context,
                    icon: Icons.edit_note,
                    title: l10n.fillForm,
                    subtitle: l10n.createAndSubmit,
                    backgroundColor: lightPurpleTint,
                    onTap: () async {
                      await Navigator.pushNamed(context, routeUserLogin);
                      if (mounted) setState(() {});
                    },
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  // Administration Card
                  _buildActionCard(
                    context: context,
                    icon: Icons.shield_outlined,
                    title: l10n.administration,
                    subtitle: l10n.manageFormsAndUsers,
                    backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                    borderColor: primaryColor,
                    onTap: () => Navigator.pushNamed(context, routeAdmin),
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
            // Overview Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.overview,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OverviewPage(),
                          ),
                        ),
                        child: Text(
                          l10n.viewAll,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<void>(
                    future: _initFuture,
                    builder: (context, snapshot) {
                      final totalResponses = ResponseStore().responses.length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard(
                            icon: Icons.description_outlined,
                            number: totalResponses.toString(),
                            label: l10n.totalResponses,
                            isDarkMode: isDarkMode,
                            primaryColor: primaryColor,
                            statCardBg: statCardBg,
                          ),
                          _buildStatCard(
                            icon: Icons.list,
                            number: (totalResponses * 15).toString(),
                            label: l10n.questionsAnswered,
                            isDarkMode: isDarkMode,
                            primaryColor: primaryColor,
                            statCardBg: statCardBg,
                          ),
                          _buildStatCard(
                            icon: Icons.schedule,
                            number: '0',
                            label: l10n.pendingResponses,
                            isDarkMode: isDarkMode,
                            primaryColor: primaryColor,
                            statCardBg: statCardBg,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Bottom Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF3D2D5C) : lightPurpleTint,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 32,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.keepTrackBanner,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildFooter(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    Color? borderColor,
    required VoidCallback onTap,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String number,
    required String label,
    required bool isDarkMode,
    required Color primaryColor,
    required Color statCardBg,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D2D2D) : statCardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white54 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        children: [
          Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'Built with Flutter & Firebase',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Powered by SQLite & Provider',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://github.com/33tsuki/FormStacker');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.code, size: 18, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    'View on GitHub',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
