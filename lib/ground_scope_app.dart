import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/router/app_routers.dart';

class GroundScopeApp extends StatelessWidget {
  const GroundScopeApp({super.key, required this.appRouter});
  final AppRouter appRouter;
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // ToDo :App Main Size
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // initialRoute: Routes.onBoardingScreen,
        onGenerateRoute: AppRouter().generateRoute,
        title: 'GroundScope',
        // theme: ThemeData(
        //   primaryColor: ColorsManger.mainBlue,
        //   scaffoldBackgroundColor: Colors.white,
        // ),
      ),
    );
  }
}
