import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/story_provider.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LanguageProvider>(
      builder: (context, authProvider, languageProvider, child) {
        return AlertDialog(
          title: Text(
            _isLogin
                ? languageProvider.translate('login')
                : languageProvider.translate('register'),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.translate('login_message'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('email'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('password'),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    authProvider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(languageProvider.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
                authProvider.clearError();
              },
              child: Text(
                _isLogin
                    ? languageProvider.translate('register')
                    : languageProvider.translate('login'),
              ),
            ),
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  bool success;
                  if (_isLogin) {
                    success = await authProvider.signIn(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                  } else {
                    success = await authProvider.signUp(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                  }

                  if (success && mounted) {
                    // Sync local favorites to user account
                    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
                    if (authProvider.user != null) {
                      await storyProvider.syncLocalFavoritesToUser(authProvider.user!.id);
                    }
                    Navigator.pop(context);
                  }
                }
              },
              child: authProvider.isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(
                _isLogin
                    ? languageProvider.translate('login')
                    : languageProvider.translate('register'),
              ),
            ),
          ],
        );
      },
    );
  }
}