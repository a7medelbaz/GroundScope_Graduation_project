import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_routers.dart';
import 'core/router/routes.dart';
import 'core/themes/app_colors.dart';

class GroundScopeApp extends StatelessWidget {
  const GroundScopeApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.onBoardingScreen,
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
