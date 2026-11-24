import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local/app_database.dart';
import 'data/local/inspection_dao.dart';
import 'data/remote/inspection_api.dart';
import 'sync/background_sync.dart';
import 'sync/connectivity_monitor.dart';
import 'sync/sync_engine.dart';
import 'ui/pages/inspection_list_page.dart';
import 'viewmodels/inspection_list_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.open();
  final dao = InspectionDao(db);
  final engine = SyncEngine(dao, HttpInspectionApi());
  await registerBackgroundSync();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: dao),
        Provider.value(value: engine),
        ChangeNotifierProvider(
          create: (_) => InspectionListViewModel(
            dao: dao,
            engine: engine,
            connectivity: PlatformConnectivityMonitor(),
          )..init(),
        ),
      ],
      child: const FieldSyncApp(),
    ),
  );
}

class FieldSyncApp extends StatelessWidget {
  const FieldSyncApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FieldSync',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF0277BD),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorSchemeSeed: const Color(0xFF0277BD),
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    home: const InspectionListPage(),
  );
}
