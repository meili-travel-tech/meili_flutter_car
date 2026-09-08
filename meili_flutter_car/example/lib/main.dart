import 'package:flutter/material.dart';

import 'package:meili_flutter_example/events_view_model.dart';
import 'package:meili_flutter_example/launch_view_model.dart';
import 'package:meili_flutter_example/settings_repository.dart';
import 'package:meili_flutter_example/widgets/events_panel.dart';
import 'package:meili_flutter_example/widgets/launch_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(repository: SettingsRepository(prefs)));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.repository, super.key});

  /// Settings store loaded before the app starts so the UI can read it
  /// synchronously.
  final SettingsRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meili Sample',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E88E5),
      ),
      home: HomePage(repository: repository),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({required this.repository, super.key});

  /// The settings store passed to the launch view model.
  final SettingsRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LaunchViewModel _launchViewModel;
  late final EventsViewModel _eventsViewModel;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _launchViewModel = LaunchViewModel(repository: widget.repository);
    _eventsViewModel = EventsViewModel();
  }

  @override
  void dispose() {
    _launchViewModel.dispose();
    _eventsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          LaunchView(viewModel: _launchViewModel),
          EventsView(viewModel: _eventsViewModel),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Launch',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}

/// Tab that shows the live Meili event log, sourced from [EventsViewModel].
class EventsView extends StatelessWidget {
  /// Creates the events view bound to [viewModel].
  const EventsView({required this.viewModel, super.key});

  /// The shared events view model.
  final EventsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meili Events'),
        actions: [
          TextButton(
            onPressed: viewModel.clear,
            child: const Text('Clear'),
          ),
        ],
      ),
      body: EventsPanel(viewModel: viewModel),
    );
  }
}
