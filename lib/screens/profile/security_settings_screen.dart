import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/app_strings.dart';
import 'change_password_screen.dart';
import 'login_preferences_screen.dart';
import '../welcome_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isDarkMode = true;
  String _selectedLanguage = 'Türkçe';

  @override
  void initState() {
    super.initState();
    _isDarkMode =
        AppTheme.themeModeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Güvenlik bölümü
            Text(
              strings.settingsSecuritySection,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _settingsCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.lock_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  title: Text(
                    'Şifreyi değiştir',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Hesabının giriş şifresini güncelle',
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.login,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  title: Text(
                    'Giriş tercihleri',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Güvenlik ve giriş ile ilgili ayarları yönet',
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPreferencesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Genel bölüm
            Text(
              strings.settingsGeneralSection,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _settingsCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.language,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  title: Text(
                    strings.settingsLanguage,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    _selectedLanguage,
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onTap: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: Theme.of(context).cardColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: Text(
                                strings.settingsLanguageTurkish,
                              ),
                              onTap: () => Navigator.pop(
                                  context, strings.settingsLanguageTurkish),
                            ),
                            if (isDark)
                              const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: Text(
                                strings.settingsLanguageEnglish,
                              ),
                              onTap: () => Navigator.pop(
                                  context, strings.settingsLanguageEnglish),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    );

                    if (selected != null) {
                      setState(() {
                        _selectedLanguage = selected;
                      });

                      if (selected == strings.settingsLanguageTurkish) {
                        AppLanguageController.languageNotifier.value =
                            AppLanguage.tr;
                      } else {
                        AppLanguageController.languageNotifier.value =
                            AppLanguage.en;
                      }
                    }
                  },
                ),
                const Divider(color: Colors.white24, height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    Icons.dark_mode,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  title: Text(
                    'Tema',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    _isDarkMode ? 'Karanlık mod' : 'Aydınlık mod',
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    AppTheme.themeModeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Destek bölümü
            Text(
              strings.settingsSupportSection,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _settingsCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.feedback_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  title: Text(
                    'Geri bildirim gönder',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Uygulama hakkındaki görüşlerini bizimle paylaş',
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  title: Text(
                    'Gizlilik ve kullanım koşulları',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Veri gizliliği ve kullanım şartları hakkında bilgi al',
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Çıkış yap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
