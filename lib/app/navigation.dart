import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../models/service_request.dart';

typedef AppGo = void Function(String route, [Map<String, dynamic>? patch]);

void navigateTo(
  BuildContext context,
  FlowState flowState,
  String route, [
  Map<String, dynamic>? patch,
]) {
  final workerId = patch?['workerId'] as String?;
  if (workerId != null) flowState.workerId = workerId;
  final category = patch?['category'] as String?;
  if (category != null) flowState.cat = category;
  final problem = patch?['problem'] as String?;
  if (problem != null) flowState.selectedProblem = problem;
  final description = patch?['description'] as String?;
  if (description != null) flowState.desc = description;

  switch (route) {
    case 'splash':
      context.goNamed('splash');
      break;
    case 'login':
      context.goNamed('login');
      break;
    case 'register':
      context.goNamed('register');
      break;
    case 'otp':
      context.goNamed('otp');
      break;
    case 'roleSelection':
      context.goNamed('roleSelection');
      break;
    case 'customerOnboarding':
      context.goNamed('customerOnboarding');
      break;
    case 'workerOnboarding1':
      context.goNamed('workerOnboarding1');
      break;
    case 'workerOnboarding2':
      context.goNamed('workerOnboarding2');
      break;
    case 'workerOnboarding3':
      context.goNamed('workerOnboarding3');
      break;
    case 'workerOnboarding4':
      context.goNamed('workerOnboarding4');
      break;
    case 'workerOnboarding5':
      context.goNamed('workerOnboarding5');
      break;
    case 'workerReview':
      context.goNamed('workerReview');
      break;
    case 'workerSubmitting':
      context.goNamed('workerSubmitting');
      break;
    case 'workerSubmitted':
      context.goNamed('workerSubmitted');
      break;
    case 'modeSwitch':
      context.goNamed('modeSwitch');
      break;
    case 'workerDashboard':
      context.goNamed('workerDashboard');
      break;
    case 'home':
      context.goNamed('home');
      break;
    case 'upload':
    case 'check':
      context.goNamed('upload');
      break;
    case 'symptomIntake':
      flowState.unknownMode = true;
      context.goNamed('symptomIntake');
      break;
    case 'aiFollowUp':
      context.goNamed('aiFollowUp');
      break;
    case 'fairPrice':
      context.goNamed('fairPrice');
      break;
    case 'analyzing':
      context.goNamed('analyzing');
      break;
    case 'result':
      context.goNamed('result');
      break;
    case 'workers':
      context.goNamed('workers');
      break;
    case 'recommendedWorkers':
      context.goNamed('recommendedWorkers');
      break;
    case 'worker':
      // Track which screen the user came from so worker profile back button works correctly
      final fromRoute = patch?['from'] as String?;
      if (fromRoute != null) flowState.workerFromRoute = fromRoute;
      context.goNamed('worker', pathParameters: {'id': flowState.workerId});
      break;
    case 'booking':
      final bookingFrom = patch?['from'] as String?;
      if (bookingFrom != null) flowState.bookingFromRoute = bookingFrom;
      context.goNamed('booking', pathParameters: {'id': flowState.workerId});
      break;
    case 'bookingConfirmation':
      context.goNamed(
        'bookingConfirmation',
        pathParameters: {'id': flowState.workerId},
      );
      break;
    case 'bookingStatus':
      context.goNamed(
        'bookingStatus',
        pathParameters: {'id': flowState.workerId},
      );
      break;
    case 'customerFinalPrice':
      context.goNamed(
        'customerFinalPrice',
        pathParameters: {'id': flowState.workerId},
      );
      break;
    case 'chat':
      context.goNamed(
        'chat',
        pathParameters: {'id': flowState.workerId},
      );
      break;
    case 'workerFinalPrice':
      context.goNamed('workerFinalPrice');
      break;
    case 'history':
      context.goNamed('history');
      break;
    case 'profile':
      context.goNamed('profile');
      break;
    case 'profileWorkerMode':
      context.goNamed('profileWorkerMode');
      break;
    case 'profileAddresses':
      context.goNamed('profileAddresses');
      break;
    case 'profilePrices':
      context.goNamed('profilePrices');
      break;
    case 'profileSavedWorkers':
      context.goNamed('profileSavedWorkers');
      break;
    case 'profileNotifications':
      context.goNamed('profileNotifications');
      break;
    case 'profileSecurity':
      context.goNamed('profileSecurity');
      break;
    case 'profileWhy':
      context.goNamed('profileWhy');
      break;
    case 'profileSupport':
      context.goNamed('profileSupport');
      break;
    case 'review':
      context.goNamed(
        'review',
        pathParameters: {'requestId': patch?['requestId'] as String? ?? 'demo'},
      );
      break;
    case 'admin':
      context.goNamed('admin');
      break;
    default:
      context.goNamed('home');
  }
}
