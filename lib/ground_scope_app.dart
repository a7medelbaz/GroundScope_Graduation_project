import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_routers.dart';
import 'core/themes/app_colors.dart';

class GroundScopeApp extends StatelessWidget {
  const GroundScopeApp({super.key, required this.appRouter, required this.initialScreen});
  final AppRouter appRouter;
  final Widget initialScreen;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // initialRoute: Routes.onBoardingScreen,
          home:initialScreen,
          onGenerateRoute:
              appRouter.generateRoute,
          title: 'GroundScope',
          theme: ThemeData(
            primaryColor: Colors.white,
            scaffoldBackgroundColor: AppColors.darkBlue,
          ),
        );
      },
    );
  }
}
