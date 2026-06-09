import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../store/response_store.dart';
import '../widgets/app_drawer.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = ResponseStore().init();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF673AB7);
    final statCardBg = const Color(0xFFF3E5F5);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.overview,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          final totalResponses = ResponseStore().responses.length;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.overview,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.reviewMetrics,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.keyMetrics,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCard(
                      icon: Icons.description_outlined,
                      number: totalResponses.toString(),
                      label: l10n.totalResponses,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      statCardBg: statCardBg,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.list,
                      number: (totalResponses * 15).toString(),
                      label: l10n.questionsAnswered,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      statCardBg: statCardBg,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.schedule,
                      number: '0',
                      label: l10n.pendingResponses,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      statCardBg: statCardBg,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryColor, size: 26),
            const SizedBox(height: 12),
            Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
