import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'providers/lift_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const LiftApp());
}

class LiftApp extends StatelessWidget {
  const LiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF59A8FF);
    const backgroundColor = Color(0xFF050816);
    const surfaceColor = Color(0xFF0D1425);
    const neonMint = Color(0xFF34D1BF);
    const neonBlue = Color(0xFF59A8FF);

    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ).copyWith(
          primary: neonBlue,
          secondary: neonMint,
          surface: surfaceColor,
          onSurface: Colors.white,
          onPrimary: const Color(0xFF04111A),
          outline: Colors.white.withValues(alpha: 0.08),
        );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => LiftProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'liftup',
        builder: (context, child) {
          return ColoredBox(
            color: const Color(0xFF02040B),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: backgroundColor),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: backgroundColor,
          textTheme: baseTextTheme.copyWith(
            headlineMedium: baseTextTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.08,
            ),
            titleLarge: baseTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
            titleMedium: baseTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF111A2D),
            contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          dividerColor: Colors.white.withValues(alpha: 0.06),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          cardColor: surfaceColor,
          iconTheme: const IconThemeData(color: Colors.white),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: neonMint,
              foregroundColor: const Color(0xFF04111A),
              elevation: 0,
              minimumSize: const Size.fromHeight(58),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: baseTextTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(58),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: baseTextTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: neonBlue,
            linearTrackColor: Color(0x1AFFFFFF),
            circularTrackColor: Color(0x1AFFFFFF),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
