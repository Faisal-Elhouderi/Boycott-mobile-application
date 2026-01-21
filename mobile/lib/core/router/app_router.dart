import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/scan/presentation/scan_result_screen.dart';
import '../../features/product/presentation/product_screen.dart';
import '../../features/company/presentation/company_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/debug/presentation/api_debug_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/alternatives/presentation/alternatives_screen.dart';
import '../../features/alternatives/presentation/alternative_detail_screen.dart';
import '../../features/companies/presentation/companies_screen.dart';
import '../../features/markets/presentation/markets_screen.dart';
import '../widgets/shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      
      // Full screen routes
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/scan/:barcode',
        name: 'scan-result',
        builder: (context, state) {
          final barcode = state.pathParameters['barcode']!;
          return ScanResultScreen(barcode: barcode);
        },
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/alternatives',
        name: 'alternatives',
        builder: (context, state) => const AlternativesScreen(),
      ),
      GoRoute(
        path: '/alternatives/:id',
        name: 'alternative-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AlternativeDetailScreen(alternativeId: id);
        },
      ),
      GoRoute(
        path: '/companies',
        name: 'companies',
        builder: (context, state) => const CompaniesScreen(),
      ),
      GoRoute(
        path: '/company/:id',
        name: 'company',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CompanyScreen(companyId: id);
        },
      ),
      GoRoute(
        path: '/markets',
        name: 'markets',
        builder: (context, state) => const MarketsScreen(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/debug',
        name: 'api-debug',
        builder: (context, state) => const ApiDebugScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});

