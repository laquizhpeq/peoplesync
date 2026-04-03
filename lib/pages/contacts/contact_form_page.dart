import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/contacts/contact_form_viewmodel.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_manual_form.dart';

class ContactFormPage extends StatelessWidget {
  const ContactFormPage({super.key});

  Future<void> _submit(BuildContext context) async {
    final viewModel = context.read<ContactFormViewModel>();
    final error = await viewModel.saveContact();

    if (!context.mounted || error == 'invalid') return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacto guardado correctamente')),
    );
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactFormViewModel>(
      create: (_) => getIt<ContactFormViewModel>(),
      child: Builder(
        builder: (context) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: ContactManualForm(
              onCancel: () => context.go(Routes.home),
              onSubmit: () => _submit(context),
            ),
          );
        },
      ),
    );
  }
}
