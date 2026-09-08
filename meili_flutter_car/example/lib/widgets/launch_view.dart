import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meili_flutter/meili_flutter.dart';
import 'package:meili_flutter_example/launch_view_model.dart';
import 'package:meili_flutter_example/meili_settings.dart';

/// The single "configure & launch" screen.
///
/// Inline settings (matching the iOS Sample App, MPD-10696) sit directly above
/// the launch button — tweak, then launch, no separate settings page.
class LaunchView extends StatefulWidget {
  /// Creates the launch view bound to [viewModel].
  const LaunchView({required this.viewModel, super.key});

  /// The view model holding the editable settings.
  final LaunchViewModel viewModel;

  @override
  State<LaunchView> createState() => _LaunchViewState();
}

class _LaunchViewState extends State<LaunchView> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late final TextEditingController _ptidController;
  late final TextEditingController _currencyController;
  late final TextEditingController _confirmationIdController;
  late final TextEditingController _lastNameController;
  StreamSubscription<String>? _toastSubscription;

  LaunchViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    final settings = _vm.settings;
    _ptidController = TextEditingController(text: settings.ptid);
    _currencyController = TextEditingController(text: settings.currency);
    _confirmationIdController =
        TextEditingController(text: settings.confirmationId);
    _lastNameController = TextEditingController(text: settings.lastName);
    _toastSubscription = _vm.toasts.listen(_showSnack);
  }

  @override
  void dispose() {
    _toastSubscription?.cancel();
    _ptidController.dispose();
    _currencyController.dispose();
    _confirmationIdController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetToDefaults() {
    _vm.resetToDefaults();
    final settings = _vm.settings;
    _ptidController.text = settings.ptid;
    _currencyController.text = settings.currency;
    _confirmationIdController.text = settings.confirmationId;
    _lastNameController.text = settings.lastName;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meili Sample'),
          actions: [
            TextButton(
              onPressed: _resetToDefaults,
              child: const Text('Reset'),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => _buildForm(_vm.settings),
        ),
      ),
    );
  }

  Widget _buildForm(MeiliSettings settings) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const _SectionHeader('General'),
        _FieldPadding(
          child: TextField(
            controller: _ptidController,
            decoration: const InputDecoration(
              labelText: 'PTID',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _vm.update(settings.copyWith(ptid: value)),
          ),
        ),
        ListTile(
          title: const Text('Environment'),
          trailing: DropdownButton<MeiliEnv>(
            value: settings.env,
            onChanged: (value) {
              if (value != null) {
                _vm.update(settings.copyWith(env: value));
              }
            },
            items: [
              for (final env in MeiliEnv.values)
                DropdownMenuItem<MeiliEnv>(
                  value: env,
                  child: Text(env.label),
                ),
            ],
          ),
        ),
        _FieldPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flow', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              SegmentedButton<FlowType>(
                segments: const [
                  ButtonSegment<FlowType>(
                    value: FlowType.direct,
                    label: Text('Direct'),
                  ),
                  ButtonSegment<FlowType>(
                    value: FlowType.bookingManager,
                    label: Text('Booking Manager'),
                  ),
                ],
                selected: {settings.flow},
                onSelectionChanged: (selection) =>
                    _vm.update(settings.copyWith(flow: selection.first)),
              ),
            ],
          ),
        ),
        const _SectionHeader('Currency'),
        SwitchListTile(
          title: const Text('Override currency'),
          value: settings.overrideCurrency,
          onChanged: (value) =>
              _vm.update(settings.copyWith(overrideCurrency: value)),
        ),
        if (settings.overrideCurrency)
          _FieldPadding(
            child: TextField(
              controller: _currencyController,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  _vm.update(settings.copyWith(currency: value)),
            ),
          ),
        // The booking lookup fields only apply to the Booking Manager flow,
        // so hide the whole section for the Direct flow to avoid confusion.
        if (settings.flow == FlowType.bookingManager) ...[
          const _SectionHeader('Manage My Booking'),
          _FieldPadding(
            child: TextField(
              controller: _confirmationIdController,
              decoration: const InputDecoration(
                labelText: 'Confirmation Id',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  _vm.update(settings.copyWith(confirmationId: value)),
            ),
          ),
          _FieldPadding(
            child: TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  _vm.update(settings.copyWith(lastName: value)),
            ),
          ),
          SwitchListTile(
            title: const Text('Prefill only'),
            value: settings.prefillOnly,
            onChanged: (value) =>
                _vm.update(settings.copyWith(prefillOnly: value)),
          ),
        ],
        const _SectionHeader('Notifications'),
        SwitchListTile(
          title: const Text('Show booking toast'),
          subtitle: const Text(
            'Show a snackbar when a booking flow ends. The native event '
            'carries no booking id yet, so the message is generic (MPD-10696).',
          ),
          value: settings.showBookingToast,
          onChanged: (value) =>
              _vm.update(settings.copyWith(showBookingToast: value)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: FilledButton(
            onPressed: _vm.isLaunching ? null : _vm.launch,
            child: _vm.isLaunching
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Launch Meili'),
          ),
        ),
      ],
    );
  }
}

/// Consistent horizontal padding for the boxed form fields.
class _FieldPadding extends StatelessWidget {
  const _FieldPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: child,
    );
  }
}

/// A primary-coloured section heading for the settings groups.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
