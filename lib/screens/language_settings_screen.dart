import 'package:flutter/material.dart';
import 'package:rooted/services/language_service.dart';
import 'package:rooted/l10n/app_localizations.dart';

/// Screen for language selection
class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final LanguageService _languageService = LanguageService();
  String _currentLanguageCode = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final locale = await _languageService.getCurrentLocale();
    setState(() {
      _currentLanguageCode = locale.languageCode;
      _isLoading = false;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _isLoading = true;
    });

    await _languageService.changeLanguage(languageCode);

    setState(() {
      _currentLanguageCode = languageCode;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.changeLanguage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header card
                Card(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: Theme.of(context).primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.currentLanguage,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_languageService.getLanguageFlag(_currentLanguageCode)} ${_languageService.getNativeLanguageName(_currentLanguageCode)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
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

                const SizedBox(height: 24),

                // Language selection title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    l10n.selectLanguage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Language options
                ...LanguageService.supportedLanguages.map((language) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        language.nativeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        language.name,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: _currentLanguageCode == language.code
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 28,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: Colors.grey.shade400,
                              size: 28,
                            ),
                      selected: _currentLanguageCode == language.code,
                      selectedTileColor: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () => _changeLanguage(language.code),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Info card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Language Support',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rooted supports multiple languages to help you grow spiritually in your native language.',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
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

