import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/appConfigurationCubit.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/ui/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/utils/animationConfiguration.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Widget routeInstance() {
    return const SplashScreen();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<AppConfigurationCubit>().fetchAppConfiguration();
      }
    });
  }

  /// Returns `true` if app maintenance mode is active.
  bool _isUnderMaintenance() {
    final configCubit = context.read<AppConfigurationCubit>();
    return configCubit.appUnderMaintenance();
  }

  void navigateToNextScreen() {
    if (context.read<AuthCubit>().state is Unauthenticated) {
      Get.offNamed(Routes.auth);
    } else {
      Get.offNamed(
        (context.read<AuthCubit>().state as Authenticated).isStudent
            ? Routes.home
            : Routes.parentHome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AppConfigurationCubit, AppConfigurationState>(
        listener: (context, appConfigState) {
          if (appConfigState is AppConfigurationFetchSuccess) {
            if (!_isUnderMaintenance()) {
              navigateToNextScreen();
            }
          }
        },
        builder: (context, appConfigState) {
          if (appConfigState is AppConfigurationFetchFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<AppConfigurationCubit>().fetchAppConfiguration();
                },
                errorMessageCode: appConfigState.errorMessage,
              ),
            );
          }

          if (appConfigState is AppConfigurationFetchSuccess &&
              _isUnderMaintenance()) {
            return const AppUnderMaintenanceContainer();
          }

          return Center(
            child: Animate(
              effects: customItemZoomAppearanceEffects(
                delay: const Duration(
                  milliseconds: 10,
                ),
                duration: const Duration(
                  seconds: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Image.asset(
                  Utils.getImagePath("logo.png"),
                  width: MediaQuery.of(context).size.width * 0.75,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


