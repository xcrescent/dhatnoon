import 'package:dhatnoon/features/login/view/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhatnoon/core/router/auto_route_observer.dart';
import 'package:dhatnoon/core/router/router_pod.dart';
import 'package:dhatnoon/core/theme/app_theme.dart';
import 'package:dhatnoon/core/theme/theme_controller.dart';
import 'package:dhatnoon/l10n/l10n.dart';
import 'package:dhatnoon/shared/helper/global_helper.dart';
import 'package:dhatnoon/shared/pods/locale_pod.dart';
import 'package:dhatnoon/shared/widget/no_internet_widget.dart';
import 'package:dhatnoon/shared/widget/responsive_wrapper.dart';

///This class holds Material App or Cupertino App
///with routing,theming and locale setup .
///Also responsive framerwork used for responsive application
///which auto resize or autoscale the app.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with GlobalHelper {
  @override
  Widget build(BuildContext context) {
    final approuter = ref.watch(autorouterProvider);
    final currentTheme = ref.watch(themecontrollerProvider);
    final locale = ref.watch(localePod);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData) {
          // User is not logged in, show LoginScreen.
          return const LoginPage();
        } else if (snapshot.hasError) {
          // An error occurred, show a message.
          return Container(
            color: Colors.white,
            child: const Center(
              child: Text('An error occurred.'),
            ),
          );
        }

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Example App',
          theme: Themes.theme,
          darkTheme: Themes.darkTheme,
          themeMode: currentTheme,
          routerConfig: approuter.config(
            navigatorObservers: () => [
              RouterObserver(),
            ],
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          builder: (context, child) {
            if (mounted) {
              ///Used for responsive design
              ///Here you can define breakpoint and how the responsive should work
              child = ResponsiveBreakPointWrapper(
                child: child!,
              );

              /// Add support for maximum text scale according to changes in
              /// accessibilty in sytem settings
              final mediaquery = MediaQuery.of(context);
              child = MediaQuery(
                data: mediaquery.copyWith(
                  textScaler: TextScaler.linear(
                      mediaquery.textScaleFactor.clamp(0, 1.5)),
                ),
                child: child,
              );

              /// Added annotate region by default to switch according to theme which
              /// customize the system ui veray style
              child = AnnotatedRegion<SystemUiOverlayStyle>(
                value: currentTheme == ThemeMode.dark
                    ? SystemUiOverlayStyle.light.copyWith(
                        statusBarColor: Colors.white.withOpacity(0.4),
                        systemNavigationBarColor: Colors.black,
                        systemNavigationBarDividerColor: Colors.black,
                        systemNavigationBarIconBrightness: Brightness.dark,
                      )
                    : currentTheme == ThemeMode.light
                        ? SystemUiOverlayStyle.dark.copyWith(
                            statusBarColor: Colors.white.withOpacity(0.4),
                            systemNavigationBarColor: Colors.grey,
                            systemNavigationBarDividerColor: Colors.grey,
                            systemNavigationBarIconBrightness: Brightness.light,
                          )
                        : SystemUiOverlayStyle.dark.copyWith(
                            statusBarColor: Colors.white.withOpacity(0.4),
                            systemNavigationBarColor: Colors.grey,
                            systemNavigationBarDividerColor: Colors.grey,
                            systemNavigationBarIconBrightness: Brightness.light,
                          ),
                child: GestureDetector(
                  child: child,
                  onTap: () {
                    hideKeyboard();
                  },
                ),
              );
            } else {
              child = const SizedBox.shrink();
            }

            ///Add toast support for flash
            return Toast(
              navigatorKey: navigatorKey,
              child: child,
            ).monitorConnection();
          },
        );
      },
    );
  }
}
