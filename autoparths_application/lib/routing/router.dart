import 'package:autoparths_application/routing/routes.dart';
import 'package:go_router/go_router.dart';
import '../ui/scaffold_with_navbar/scaffold_with_navbar.dart';
import '../ui/main/main_screen.dart';
import '../ui/categories/categories_screen.dart';
import '../ui/cart/cart_screen.dart';
import '../ui/profile/profile_screen.dart';
import '../ui/details/product_details.dart';
import '../ui/admin/admin_dashboard_screen.dart';
import '../ui/admin/admin_products_screen.dart';
import '../ui/admin/admin_categories_screen.dart';
import '../ui/admin/admin_users_screen.dart';
import '../ui/admin/admin_orders_screen.dart';
import '../ui/admin/admin_edit_product_screen.dart';
import '../models/product.dart';
import '../ui/categories/category_products_screen.dart';
import '../services/api_client.dart';

GoRouter router() => GoRouter(
      initialLocation: Routes.main,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.main,
                builder: (context, state) => MainScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.categories,
                builder: (context, state) => CategoriesScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => ProfileScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.cart,
                builder: (context, state) => CartScreen(),
              ),
            ]),
          ],
        ),

        GoRoute(
          path: '/category-products/:categorySlug',
          builder: (context, state) {
            final categorySlug = state.pathParameters['categorySlug']!;
            return CategoryProductsScreen(categorySlug: categorySlug);
          },
        ),

        GoRoute(
          path: Routes.ProductDetails,
          builder: (context, state) {
            final product = state.extra as Product;
            return ProductDetails(product: product);
          },
        ),
        
        // Маршруты админ-панели
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: 'products',
              builder: (context, state) => const AdminProductsScreen(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final product = state.extra as Product?;
                    return AdminEditProductScreen(product: product);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'categories',
              builder: (context, state) => const AdminCategoriesScreen(),
            ),
            GoRoute(
              path: 'users',
              builder: (context, state) => const AdminUsersScreen(),
            ),
            GoRoute(
              path: 'orders',
              builder: (context, state) => const AdminOrdersScreen(),
            ),
          ],
        ),
      ],
    );