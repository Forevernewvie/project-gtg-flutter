import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Wear OS Splash Screen & Icon Resource Integrity Test (WO-V15 48x48dp Brand Disclosure)',
    () {
      const androidRoot = 'android/app/src/main';

      test(
        '1. ic_launcher PNG assets exist across all density directories with valid PNG signature',
        () {
          final densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];
          const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

          for (final density in densities) {
            final iconFile = File(
              '$androidRoot/res/mipmap-$density/ic_launcher.png',
            );
            expect(
              iconFile.existsSync(),
              isTrue,
              reason: 'Missing icon for mipmap-$density',
            );

            final bytes = iconFile.readAsBytesSync();
            expect(
              bytes.length,
              greaterThan(100),
              reason: 'Icon in mipmap-$density is suspiciously small or empty',
            );

            final header = bytes.take(8).toList();
            expect(
              header,
              equals(pngSignature),
              reason: 'File in mipmap-$density is not a valid PNG image',
            );
          }
        },
      );

      test(
        '2. splash_screen_icon.xml explicitly enforces 48x48dp dimensions centered on black',
        () {
          final iconFile = File(
            '$androidRoot/res/drawable/splash_screen_icon.xml',
          );
          expect(
            iconFile.existsSync(),
            isTrue,
            reason: 'res/drawable/splash_screen_icon.xml must exist',
          );

          final content = iconFile.readAsStringSync();

          // Must explicitly enforce 48dp width and height
          expect(
            content.contains('android:width="48dp"'),
            isTrue,
            reason:
                'Must specify android:width="48dp" for Wear OS WO-V15 compliance',
          );
          expect(
            content.contains('android:height="48dp"'),
            isTrue,
            reason:
                'Must specify android:height="48dp" for Wear OS WO-V15 compliance',
          );
          expect(
            content.contains('android:gravity="center"'),
            isTrue,
            reason: 'Must specify android:gravity="center"',
          );
          expect(
            content.contains('android:drawable="@mipmap/ic_launcher"'),
            isTrue,
            reason: 'Must wrap @mipmap/ic_launcher',
          );
        },
      );

      test(
        '3. values/styles.xml properly implements Theme.SplashScreen pointing to 48dp splash_screen_icon',
        () {
          final stylesFile = File('$androidRoot/res/values/styles.xml');
          expect(stylesFile.existsSync(), isTrue);

          final content = stylesFile.readAsStringSync();

          // Must inherit from Theme.SplashScreen
          expect(
            content.contains('parent="Theme.SplashScreen"'),
            isTrue,
            reason: 'LaunchTheme must have parent="Theme.SplashScreen"',
          );

          // Must define pure black background for Wear OS OLED guidelines
          expect(
            content.contains(
              'name="windowSplashScreenBackground">@android:color/black<',
            ),
            isTrue,
            reason:
                'Must set windowSplashScreenBackground to black for Wear OS',
          );

          // Must point to @drawable/splash_screen_icon (enforcing 48dp)
          expect(
            content.contains(
              'name="windowSplashScreenAnimatedIcon">@drawable/splash_screen_icon<',
            ),
            isTrue,
            reason:
                'Must point windowSplashScreenAnimatedIcon to @drawable/splash_screen_icon for 48dp scaling',
          );

          // Must define postSplashScreenTheme
          expect(
            content.contains(
              'name="postSplashScreenTheme">@style/NormalTheme<',
            ),
            isTrue,
            reason:
                'Must define postSplashScreenTheme to transition to NormalTheme',
          );
        },
      );

      test(
        '4. values-night/styles.xml (Wear OS default) properly implements Theme.SplashScreen pointing to 48dp splash_screen_icon',
        () {
          final nightStylesFile = File(
            '$androidRoot/res/values-night/styles.xml',
          );
          expect(
            nightStylesFile.existsSync(),
            isTrue,
            reason: 'values-night/styles.xml must exist for Wear OS dark mode',
          );

          final content = nightStylesFile.readAsStringSync();

          // CRITICAL: Ensure legacy Theme.Black.NoTitleBar regression does not occur
          expect(
            content.contains('Theme.Black.NoTitleBar'),
            isFalse,
            reason:
                'Legacy Theme.Black.NoTitleBar must NOT be used in values-night (caused store rejection)',
          );

          // Must inherit from Theme.SplashScreen
          expect(
            content.contains('parent="Theme.SplashScreen"'),
            isTrue,
            reason:
                'values-night LaunchTheme must inherit from Theme.SplashScreen',
          );

          // Must point to @drawable/splash_screen_icon (enforcing 48dp)
          expect(
            content.contains(
              'name="windowSplashScreenAnimatedIcon">@drawable/splash_screen_icon<',
            ),
            isTrue,
            reason:
                'values-night must point windowSplashScreenAnimatedIcon to @drawable/splash_screen_icon for 48dp scaling',
          );

          // Must define pure black background
          expect(
            content.contains(
              'name="windowSplashScreenBackground">@android:color/black<',
            ),
            isTrue,
            reason:
                'values-night must set windowSplashScreenBackground to black',
          );
        },
      );

      test(
        '5. drawable and drawable-v21 launch_background explicitly enforce 48dp centered ic_launcher fallback',
        () {
          final drawables = [
            File('$androidRoot/res/drawable/launch_background.xml'),
            File('$androidRoot/res/drawable-v21/launch_background.xml'),
          ];

          for (final file in drawables) {
            expect(file.existsSync(), isTrue);
            final content = file.readAsStringSync();

            expect(
              content.contains('@mipmap/ic_launcher'),
              isTrue,
              reason:
                  '${file.path} must contain active @mipmap/ic_launcher for pre-Android 12 fallback',
            );
            expect(
              content.contains('android:width="48dp"'),
              isTrue,
              reason: '${file.path} must specify 48dp width for Wear OS',
            );
            expect(
              content.contains('android:height="48dp"'),
              isTrue,
              reason: '${file.path} must specify 48dp height for Wear OS',
            );
            expect(
              content.contains('@android:color/black'),
              isTrue,
              reason: '${file.path} must have black background for Wear OS',
            );
          }
        },
      );

      test(
        '6. AndroidManifest.xml and MainActivity.kt properly invoke SplashScreen API',
        () {
          final manifestFile = File('$androidRoot/AndroidManifest.xml');
          expect(manifestFile.existsSync(), isTrue);
          final manifestContent = manifestFile.readAsStringSync();

          expect(
            manifestContent.contains('android:theme="@style/LaunchTheme"'),
            isTrue,
            reason: 'Activity theme must be @style/LaunchTheme',
          );
          expect(
            manifestContent.contains('android:icon="@mipmap/ic_launcher"'),
            isTrue,
            reason: 'Application icon must be @mipmap/ic_launcher',
          );

          final activityFile = File(
            '$androidRoot/kotlin/com/forevernewvie/projectgtg/MainActivity.kt',
          );
          expect(activityFile.existsSync(), isTrue);
          final activityContent = activityFile.readAsStringSync();

          expect(
            activityContent.contains('installSplashScreen()'),
            isTrue,
            reason: 'MainActivity must call installSplashScreen()',
          );
          expect(
            activityContent.indexOf('installSplashScreen()'),
            lessThan(
              activityContent.indexOf('super.onCreate(savedInstanceState)'),
            ),
            reason:
                'installSplashScreen() MUST be called before super.onCreate() as per Android specification',
          );
        },
      );
    },
  );
}
