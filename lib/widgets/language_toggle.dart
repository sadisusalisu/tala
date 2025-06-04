import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageProvider.isHausa ? '🇳🇬' : '🇬🇧',
                style: const TextStyle(fontSize: 20),
              ),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
          onSelected: (String language) {
            languageProvider.setLanguage(language);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  const Text('🇬🇧', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(languageProvider.translate('english')),
                  if (languageProvider.isEnglish)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, size: 16),
                    ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ha',
              child: Row(
                children: [
                  const Text('🇳🇬', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(languageProvider.translate('hausa')),
                  if (languageProvider.isHausa)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, size: 16),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}