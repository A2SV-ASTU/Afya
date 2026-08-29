import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/animated_floating_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AppStarted());
  }

  void _onGetStartedPressed(AuthState state) {
    if (state is Authenticated) {
      context.go(RoutePaths.dashboard);
    } else {
      context.go(RoutePaths.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Auto-navigate only if user is already authenticated
        if (state is Authenticated) {
          context.go(RoutePaths.dashboard);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: AnimatedFloatingBackground(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space24,
                vertical: AppDimensions.space24,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.space32),
                  
                  // Top Brand Header Logo (Heart + AfyaMind)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      Text(
                        'Afya',
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Center Copy: Headline & Subtitle
                  Text(
                    'Your digital\nhealthcare\nassistant',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
                    child: Text(
                      'Book appointments, review your\nmedical history and track your\nmedications',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom White Pill Button: Get Started ->
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _onGetStartedPressed(state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.tealPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.tealPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.tealPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
