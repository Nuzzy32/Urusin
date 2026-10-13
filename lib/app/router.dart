import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/service_request.dart';
import '../screens/admin.dart';
import '../screens/check/analyzing.dart';
import '../screens/check/level1_flows.dart';
import '../screens/auth/auth_flow.dart';
import '../screens/booking/booking.dart';
import '../screens/booking/booking_confirmation.dart';
import '../screens/booking/booking_status.dart';
import '../screens/history.dart';
import '../screens/home.dart';
import '../screens/mitra/mitra_dashboard.dart';
import '../screens/profile/profile.dart';
import '../screens/profile/profile_flows.dart';
import '../screens/check/result.dart';
import '../screens/review.dart';
import '../screens/check/upload.dart';
import '../screens/workers/worker_profile.dart';
import '../screens/mitra/worker_registration_flow.dart';
import '../screens/workers/workers.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/workers/workers_directory.dart';
import 'navigation.dart';
import 'shell.dart';

final appFlowState = FlowState();

AppGo _go(BuildContext context) {
  return (route, [patch]) => navigateTo(context, appFlowState, route, patch);
}

Page<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.of(context).disableAnimations) return child;
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      name: 'splash',
      path: '/splash',
      pageBuilder: (context, state) =>
          _page(state, SplashScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      pageBuilder: (context, state) =>
          _page(state, LoginScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      pageBuilder: (context, state) =>
          _page(state, RegisterScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'otp',
      path: '/login/otp',
      pageBuilder: (context, state) =>
          _page(state, OtpScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'roleSelection',
      path: '/onboarding/role',
      pageBuilder: (context, state) =>
          _page(state, RoleSelectionScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'customerOnboarding',
      path: '/onboarding/customer',
      pageBuilder: (context, state) =>
          _page(state, CustomerOnboardingScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerOnboarding1',
      path: '/onboarding/worker/basic',
      pageBuilder: (context, state) =>
          _page(state, MitraDataDiriScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerOnboarding2',
      path: '/onboarding/worker/services',
      pageBuilder: (context, state) =>
          _page(state, MitraLayananScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerOnboarding3',
      path: '/onboarding/worker/area',
      pageBuilder: (context, state) =>
          _page(state, MitraAreaJadwalScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerOnboarding4',
      path: '/onboarding/worker/pricing',
      pageBuilder: (context, state) =>
          _page(state, MitraHargaScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerOnboarding5',
      path: '/onboarding/worker/verification',
      pageBuilder: (context, state) =>
          _page(state, MitraVerifikasiScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerReview',
      path: '/onboarding/worker/review',
      pageBuilder: (context, state) =>
          _page(state, MitraReviewScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerSubmitting',
      path: '/onboarding/worker/submitting',
      pageBuilder: (context, state) =>
          _page(state, MitraSubmittingScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerSubmitted',
      path: '/onboarding/worker/submitted',
      pageBuilder: (context, state) =>
          _page(state, MitraSubmittedScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'modeSwitch',
      path: '/login/mode',
      pageBuilder: (context, state) =>
          _page(state, ExistingModeSwitchScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerDashboard',
      path: '/mitra',
      pageBuilder: (context, state) =>
          _page(state, MitraDashboardScreen(go: _go(context))),
    ),
    GoRoute(
      name: 'workerFinalPrice',
      path: '/mitra/final-price',
      pageBuilder: (context, state) => _page(
        state,
        WorkerFinalPriceScreen(go: _go(context), state: appFlowState),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          name: 'home',
          path: '/',
          pageBuilder: (context, state) =>
              _page(state, HomeScreen(go: _go(context), state: appFlowState)),
        ),
        GoRoute(
          name: 'upload',
          path: '/check',
          pageBuilder: (context, state) =>
              _page(state, UploadScreen(go: _go(context), state: appFlowState)),
        ),
        GoRoute(
          name: 'symptomIntake',
          path: '/check/symptoms',
          pageBuilder: (context, state) => _page(
            state,
            SymptomIntakeScreen(go: _go(context), state: appFlowState),
          ),
        ),
        GoRoute(
          name: 'aiFollowUp',
          path: '/check/follow-up',
          pageBuilder: (context, state) => _page(
            state,
            AiFollowUpScreen(go: _go(context), state: appFlowState),
          ),
        ),
        GoRoute(
          name: 'fairPrice',
          path: '/price-check',
          pageBuilder: (context, state) => _page(
            state,
            FairPriceScreen(go: _go(context), state: appFlowState),
          ),
        ),
        GoRoute(
          name: 'analyzing',
          path: '/check/analyzing',
          pageBuilder: (context, state) =>
              _page(state, AnalyzingScreen(go: _go(context), state: appFlowState)),
        ),
        GoRoute(
          name: 'result',
          path: '/analysis/demo',
          pageBuilder: (context, state) =>
              _page(state, ResultScreen(go: _go(context), state: appFlowState)),
        ),
        GoRoute(
          name: 'workers',
          path: '/workers',
          pageBuilder: (context, state) =>
              _page(state, WorkersDirectoryScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'recommendedWorkers',
          path: '/workers/recommended',
          pageBuilder: (context, state) => _page(
            state,
            AIRecommendedWorkersScreen(go: _go(context), state: appFlowState),
          ),
        ),
        GoRoute(
          name: 'worker',
          path: '/workers/:id',
          pageBuilder: (context, state) {
            appFlowState.workerId =
                state.pathParameters['id'] ?? appFlowState.workerId;
            return _page(
              state,
              WorkerProfileScreen(go: _go(context), state: appFlowState),
            );
          },
        ),
        GoRoute(
          name: 'booking',
          path: '/booking/:id',
          pageBuilder: (context, state) {
            appFlowState.workerId =
                state.pathParameters['id'] ?? appFlowState.workerId;
            return _page(
              state,
              BookingScreen(go: _go(context), state: appFlowState),
            );
          },
        ),
        GoRoute(
          name: 'bookingConfirmation',
          path: '/booking/:id/confirmation',
          pageBuilder: (context, state) {
            appFlowState.workerId =
                state.pathParameters['id'] ?? appFlowState.workerId;
            return _page(
              state,
              BookingConfirmationScreen(go: _go(context), state: appFlowState),
            );
          },
        ),
        GoRoute(
          name: 'bookingStatus',
          path: '/booking/:id/status',
          pageBuilder: (context, state) {
            appFlowState.workerId =
                state.pathParameters['id'] ?? appFlowState.workerId;
            return _page(
              state,
              BookingStatusScreen(go: _go(context), state: appFlowState),
            );
          },
        ),
        GoRoute(
          name: 'chat',
          path: '/booking/:id/chat',
          pageBuilder: (context, state) {
            appFlowState.workerId =
                state.pathParameters['id'] ?? appFlowState.workerId;
            return _page(
              state,
              ChatScreen(go: _go(context), state: appFlowState),
            );
          },
        ),
        GoRoute(
          name: 'customerFinalPrice',
          path: '/booking/:id/final-price',
          pageBuilder: (context, state) {
            appFlowState.workerId =
                state.pathParameters['id'] ?? appFlowState.workerId;
            return _page(
              state,
              CustomerFinalPriceScreen(go: _go(context), state: appFlowState),
            );
          },
        ),
        GoRoute(
          name: 'history',
          path: '/history',
          pageBuilder: (context, state) =>
              _page(state, HistoryScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          pageBuilder: (context, state) =>
              _page(state, ProfileScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profileWorkerMode',
          path: '/profile/mitra',
          pageBuilder: (context, state) =>
              _page(state, ProfileScreen(go: _go(context), isWorkerMode: true)),
        ),
        GoRoute(
          name: 'profileAddresses',
          path: '/profile/addresses',
          pageBuilder: (context, state) =>
              _page(state, SavedAddressesScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profilePrices',
          path: '/profile/prices',
          pageBuilder: (context, state) =>
              _page(state, PriceHistoryScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profileSavedWorkers',
          path: '/profile/saved-workers',
          pageBuilder: (context, state) =>
              _page(state, SavedWorkersScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profileNotifications',
          path: '/profile/notifications',
          pageBuilder: (context, state) =>
              _page(state, NotificationSettingsScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profileSecurity',
          path: '/profile/security',
          pageBuilder: (context, state) =>
              _page(state, SecurityPrivacyScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profileWhy',
          path: '/profile/why',
          pageBuilder: (context, state) =>
              _page(state, WhyBeresinScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'profileSupport',
          path: '/profile/support',
          pageBuilder: (context, state) =>
              _page(state, SupportScreen(go: _go(context))),
        ),
        GoRoute(
          name: 'review',
          path: '/review/:requestId',
          pageBuilder: (context, state) => _page(
            state,
            ReviewScreen(
              go: _go(context),
              requestId: state.pathParameters['requestId'] ?? 'demo',
            ),
          ),
        ),
        GoRoute(
          name: 'admin',
          path: '/admin',
          pageBuilder: (context, state) => _page(state, const AdminScreen()),
        ),
      ],
    ),
  ],
);
