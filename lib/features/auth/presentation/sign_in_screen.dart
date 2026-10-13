import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/icons.dart';
import '../../../app/shell.dart';
import '../../../core/env.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import 'auth_controllers.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= GtBreakpoints.expanded;
    return Scaffold(
      body: wide
          ? const Row(
              children: [
                Expanded(flex: 5, child: _BrandPanel()),
                Expanded(flex: 4, child: Center(child: _SignInForm())),
              ],
            )
          : const SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(GtSpace.lg),
                  child: Column(
                    children: [BrandMark(), SizedBox(height: GtSpace.xxl), _SignInForm()],
                  ),
                ),
              ),
            ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const features = [
      (GtIcons.deadline, 'Deadlines shown in the university’s time zone and yours'),
      (GtIcons.checklist, 'A checklist and recommendation letters for every programme'),
      (GtIcons.followUp, 'Professor outreach with follow-up reminders'),
      (GtIcons.digest, 'One email each morning with what needs you today'),
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [GtBrand.indigo, GtBrand.ink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(onDark: true),
          const Spacer(),
          Text(
            'Every deadline, letter and follow-up in one place.',
            style: t.displaySmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: GtSpace.xxl),
          for (final (icon, text) in features)
            Padding(
              padding: const EdgeInsets.only(bottom: GtSpace.lg),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: Color(0x1FFFFFFF), shape: BoxShape.circle),
                    child: Center(child: GtIcon(icon, color: GtBrand.sky, size: 18)),
                  ),
                  const SizedBox(width: GtSpace.md),
                  Expanded(
                    child: Text(text, style: t.bodyLarge?.copyWith(color: const Color(0xFFD9D6EA))),
                  ),
                ],
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm();

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(signInControllerProvider.notifier).sendLink(_email.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInControllerProvider);
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final sent = state.value == true;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: sent
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GtIcon(GtIcons.emailSent, size: 40, color: gt.primary),
                  const SizedBox(height: GtSpace.lg),
                  Text('Check your inbox', style: t.headlineSmall),
                  const SizedBox(height: GtSpace.sm),
                  Text('We sent a sign-in link to ${_email.text.trim()}. Open it on this device.'),
                  const SizedBox(height: GtSpace.xl),
                  TextButton(
                    onPressed: () => ref.read(signInControllerProvider.notifier).reset(),
                    child: const Text('Use a different email'),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Sign in', style: t.headlineMedium),
                    const SizedBox(height: GtSpace.sm),
                    Text("We'll email you a link. No password needed.", style: t.bodyMedium),
                    const SizedBox(height: GtSpace.xl),
                    TextFormField(
                      controller: _email,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email address'),
                      validator: (v) =>
                          v != null && v.contains('@') && v.contains('.') ? null : 'Enter a valid email address',
                      onFieldSubmitted: (_) => _submit(),
                      enabled: !state.isLoading,
                    ),
                    if (state.hasError) ...[
                      const SizedBox(height: GtSpace.md),
                      Text(describeError(state.error!), style: TextStyle(color: gt.danger.fg)),
                    ],
                    const SizedBox(height: GtSpace.lg),
                    FilledButton(
                      onPressed: state.isLoading ? null : _submit,
                      child: state.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Send sign-in link'),
                    ),
                    if (Env.demo) ...[
                      const SizedBox(height: GtSpace.md),
                      Text(
                        'Demo mode: any email signs you in with sample data.',
                        style: t.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
