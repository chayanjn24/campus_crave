import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

/// Google and phone-OTP sign-in. Both are simulated until Firebase Auth is
/// wired in: Google goes straight through, and any 6-digit code passes OTP.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  var _codeSent = false;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  bool get _phoneValid => _phone.text.length == 10;
  bool get _otpValid => _otp.text.length == 6;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Hungry?\nLet\'s get you in.', style: text.headlineLarge),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => context.push('/onboarding'),
                  icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or use your phone', style: text.bodySmall?.copyWith(color: AppColors.muted)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _phone,
                  enabled: !_codeSent,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Mobile number', prefixText: '+91  '),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: _codeSent
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextField(
                            controller: _otp,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: (_) => setState(() {}),
                            style: text.titleLarge?.copyWith(letterSpacing: 8),
                            decoration: const InputDecoration(
                              labelText: '6-digit code',
                              helperText: 'Demo mode: any 6 digits work',
                            ),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _codeSent
                      ? (_otpValid ? () => context.push('/onboarding?phone=${_phone.text}') : null)
                      : (_phoneValid ? () => setState(() => _codeSent = true) : null),
                  child: Text(_codeSent ? 'Verify' : 'Send code'),
                ),
                if (_codeSent)
                  TextButton(
                    onPressed: () => setState(() {
                      _codeSent = false;
                      _otp.clear();
                    }),
                    child: const Text('Change number'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
