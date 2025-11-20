import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_routers.dart';

class GroundScopeApp extends StatelessWidget {
  const GroundScopeApp({
    super.key,
    required this.appRouter,
    required this.initialScreen,
  });
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
          home: initialScreen,
          onGenerateRoute: appRouter.generateRoute,
          title: 'GroundScope',
          theme: ThemeData(
            primaryColor: Colors.white,
            scaffoldBackgroundColor: const Color(0xFF101922),
            canvasColor: const Color(0xFF101922),
            cardColor: const Color(0xFF101922),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF101922),
            ),
            colorScheme: const ColorScheme.dark(surface: Color(0xFF101922)),
            textTheme: GoogleFonts.interTextTheme(),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            useMaterial3: false,
          ),
          builder: (context, child) {
            return Container(color: const Color(0xFF101922), child: child);
          },
        );
      },
    );
  }
}
