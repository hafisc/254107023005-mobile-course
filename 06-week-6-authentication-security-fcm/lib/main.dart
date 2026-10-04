import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';
import 'messaging/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (tambahkan options sesuai platform jika ada google-services.json)
  await Firebase.initializeApp();

  registerBackgroundHandler();

  final pushService = PushService();
  await pushService.initLocalNotifications();
  await pushService.requestNotificationPermission();
  
  // Langganan topik (contoh)
  await pushService.subscribeToTopic('pengumuman-kampus');

  // Mengirim FCM token ke backend (simulasi log)
  await pushService.initFcmToken(onToken: (token) async {
    debugPrint('FCM Token: ${token.substring(0, 12)}...');
    // Di sini akan dikirim ke API backend via dio.post('/devices', ...)
  });

  runApp(
    ProviderScope(
      overrides: [
        pushServiceProvider.overrideWithValue(pushService),
      ],
      child: const MainApp(),
    ),
  );
}

final pushServiceProvider = Provider<PushService>((ref) {
  throw UnimplementedError();
});

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        final loggedIn = ref.read(authStateProvider).value ?? false;
        final goingLogin = state.matchedLocation == AppRoutes.login;
        if (!loggedIn && !goingLogin) return AppRoutes.login;
        if (loggedIn && goingLogin) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomePage(),
        ),
        GoRoute(
          path: '${AppRoutes.announcementPrefix}/:id',
          builder: (_, state) => AnnouncementPage(
            id: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    );

    // Listen untuk auth changes
    ref.listenManual(
      authStateProvider,
      (previous, next) {
        _router.refresh();
      },
    );

    // Push service foreground & terminated handling
    final push = ref.read(pushServiceProvider);
    push.listenForeground((route) {
      if (mounted) _router.push(route);
    });
    
    // Memberi sedikit delay agar router siap, kemudian handle initial message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      push.handleTerminated((route) {
        if (mounted) _router.push(route);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}
