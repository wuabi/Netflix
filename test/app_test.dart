import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netflix/main.dart';
import 'package:netflix/models/app_state.dart';
import 'package:netflix/models/movie.dart';
import 'package:netflix/screens/login_screen.dart';
import 'package:netflix/screens/movies_screen.dart';
import 'package:netflix/screens/series_screen.dart';
import 'package:netflix/widgets/featured_carousel.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'support/fake_video_player.dart';

double _whiteContrast(Color background) {
  final luminance = background.computeLuminance();
  return 1.05 / (luminance + 0.05);
}

Future<void> openApp(
  WidgetTester tester, {
  Size size = const Size(1440, 1000),
  bool skipIntro = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(NetflixApp());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  if (skipIntro) {
    await tester.tap(find.byKey(const Key('skip-intro')));
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('login-user')), usuarioCorrecto);
  await tester.enterText(
    find.byKey(const Key('login-password')),
    passwordCorrecta,
  );
  await tester.ensureVisible(find.byKey(const Key('login-submit')));
  await tester.tap(find.byKey(const Key('login-submit')));
  await tester.pumpAndSettle();
}

Future<void> goTo(WidgetTester tester, String destination) async {
  await tester.tap(find.byKey(Key('nav-$destination')));
  await tester.pumpAndSettle();
}

void main() {
  late FakeVideoPlayer video;
  setUp(() {
    video = FakeVideoPlayer();
    VideoPlayerPlatform.instance = video;
  });

  testWidgets(
    'La intro inicia silenciada, permite audio y termina en el login',
    (tester) async {
      await openApp(tester, skipIntro: false);
      expect(find.byKey(const Key('skip-intro')), findsOneWidget);
      expect(find.byKey(const Key('intro-audio')), findsOneWidget);
      expect(find.byKey(const Key('login-user')), findsNothing);
      expect(video.volumes.last, 0);
      final audioButton = tester.getRect(find.byKey(const Key('intro-audio')));
      expect(audioButton.top, closeTo(24, 1));
      await tester.tap(find.byKey(const Key('intro-audio')));
      await tester.pump();
      expect(video.volumes.last, 1);
      final skipButton = tester.getRect(find.byKey(const Key('skip-intro')));
      expect(skipButton.bottom, closeTo(1000 - 24, 1));
      video.finish();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login-user')), findsOneWidget);
      expect(find.byKey(const Key('skip-intro')), findsNothing);
    },
  );

  testWidgets('El fondo exterior refleja el título destacado actual', (
    tester,
  ) async {
    for (final movie in movies) {
      final tint = featuredColorFor(movie);
      final backgroundColor = Color.lerp(tint, Colors.black, .42)!;
      expect(_whiteContrast(backgroundColor), greaterThanOrEqualTo(4.5));
    }

    await openApp(tester);
    await signIn(tester);

    var catalogBackground = tester.widget<DecoratedBox>(
      find.byKey(const Key('catalog-background')),
    );
    var backgroundDecoration = catalogBackground.decoration as BoxDecoration;
    var gradient = backgroundDecoration.gradient! as LinearGradient;
    expect(_whiteContrast(gradient.colors.first), greaterThanOrEqualTo(4.5));
    final firstBackgroundColor = gradient.colors.first;
    expect(
      tester.getSize(find.byKey(const Key('catalog-background'))).width,
      tester.view.physicalSize.width,
    );

    final panel = tester.widget<Container>(
      find.byKey(Key('featured-panel-${movies.first.id}')),
    );
    final panelContent = (panel.child! as ClipRRect).child! as Container;
    final panelDecoration = panelContent.decoration! as BoxDecoration;
    expect(panelDecoration.color, isNull);
    expect(panelDecoration.image, isNotNull);

    await tester.tap(find.byKey(const Key('featured-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('featured-panel-${movies[1].id}')), findsOneWidget);
    catalogBackground = tester.widget<DecoratedBox>(
      find.byKey(const Key('catalog-background')),
    );
    backgroundDecoration = catalogBackground.decoration as BoxDecoration;
    gradient = backgroundDecoration.gradient! as LinearGradient;
    expect(gradient.colors.first, isNot(firstBackgroundColor));
    expect(_whiteContrast(gradient.colors.first), greaterThanOrEqualTo(4.5));
  });

  testWidgets('Omitir la intro durante la carga lleva al login sin errores', (
    tester,
  ) async {
    video = FakeVideoPlayer(holdInitialization: true);
    VideoPlayerPlatform.instance = video;
    await openApp(tester);
    expect(find.byKey(const Key('login-user')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Un error del video permite acceder al login', (tester) async {
    video = FakeVideoPlayer(failInitialization: true);
    VideoPlayerPlatform.instance = video;
    await openApp(tester, skipIntro: false);
    expect(find.byKey(const Key('login-user')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Una intro que no carga no bloquea el acceso', (tester) async {
    video = FakeVideoPlayer(holdInitialization: true);
    VideoPlayerPlatform.instance = video;
    await openApp(tester, skipIntro: false);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-user')), findsOneWidget);
  });

  testWidgets('Un error de autoplay del reproductor no bloquea el login', (
    tester,
  ) async {
    video = FakeVideoPlayer(blockFirstPlay: true);
    VideoPlayerPlatform.instance = video;
    await openApp(tester, skipIntro: false);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-user')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Una restricción recuperable permite iniciar la intro con un clic',
    (tester) async {
      video = FakeVideoPlayer(throwFirstPlay: true);
      VideoPlayerPlatform.instance = video;
      await openApp(tester, skipIntro: false);
      expect(find.byKey(const Key('play-intro')), findsOneWidget);
      await tester.tap(find.byKey(const Key('play-intro')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(video.playCalls, greaterThanOrEqualTo(2));
      expect(find.byKey(const Key('play-intro')), findsNothing);
      video.finish();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login-user')), findsOneWidget);
    },
  );

  test('Mi lista añade, quita y limpia títulos', () {
    final state = AppState();
    state.toggle(movies.first);
    expect(state.saved, [movies.first]);
    state.toggle(movies.first);
    expect(state.saved, isEmpty);
    state.toggle(movies.last);
    state.clear();
    expect(state.saved, isEmpty);
  });

  testWidgets(
    'Valida campos y credenciales; muestra contraseña y cierra sesión',
    (tester) async {
      await openApp(tester);
      final submit = find.byKey(const Key('login-submit'));
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Ingresa tu usuario.'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
      expect(find.text('SIMULACIÓN ACADÉMICA'), findsNothing);

      await tester.enterText(find.byKey(const Key('login-user')), 'admin');
      await tester.enterText(
        find.byKey(const Key('login-password')),
        'incorrecta',
      );
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Usuario o contraseña incorrectos'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);

      await signIn(tester);
      expect(find.text('Tendencias ahora'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.tap(find.byKey(const Key('profile-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('logout')));
      await tester.pumpAndSettle();
      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byKey(const Key('nav-home')), findsNothing);
    },
  );

  testWidgets(
    'Películas y Series navegan; la búsqueda admite títulos en inglés',
    (tester) async {
      await openApp(tester);
      await signIn(tester);
      await goTo(tester, 'movies');
      expect(find.byType(MoviesScreen), findsOneWidget);
      expect(find.byKey(const Key('catalog-title')), findsOneWidget);
      expect(find.text('Durante la tormenta'), findsWidgets);
      expect(find.text('Naruto'), findsNothing);
      expect(find.byKey(const Key('catalog-row-all')), findsOneWidget);
      expect(find.byKey(const Key('featured-carousel')), findsOneWidget);
      expect(find.byKey(const Key('featured-panel-1')), findsOneWidget);
      expect(find.byKey(const Key('catalog-movies-all-1')), findsOneWidget);

      await goTo(tester, 'series');
      expect(find.byType(SeriesScreen), findsOneWidget);
      expect(find.byKey(const Key('catalog-title')), findsOneWidget);
      expect(find.text('Naruto'), findsWidgets);
      expect(find.text('Durante la tormenta'), findsNothing);
      expect(find.byKey(const Key('catalog-row-all')), findsOneWidget);
      expect(find.byKey(const Key('featured-carousel')), findsOneWidget);
      expect(find.byKey(const Key('featured-panel-0')), findsOneWidget);
      expect(find.byKey(const Key('catalog-series-all-2')), findsOneWidget);
      await tester.tap(find.byKey(const Key('featured-next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('featured-panel-2')), findsOneWidget);
      await tester.tap(find.byKey(const Key('genre-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('genre-option-Anime')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('featured-panel-2')), findsOneWidget);
      expect(find.byKey(const Key('featured-next')), findsNothing);
      expect(find.byKey(const Key('catalog-series-all-2')), findsOneWidget);
      expect(find.byKey(const Key('catalog-series-all-0')), findsNothing);
      expect(find.text('Series de Anime'), findsOneWidget);
      await tester.tap(find.byKey(const Key('genre-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('genre-option-Todos')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('catalog-series-all-0')), findsOneWidget);

      await goTo(tester, 'search');
      await tester.enterText(find.byKey(const Key('search-field')), 'MIRAGE');
      await tester.pumpAndSettle();
      expect(find.text('1 título encontrado'), findsOneWidget);
      expect(find.text('Durante la tormenta'), findsWidgets);
      await tester.enterText(find.byKey(const Key('search-field')), '');
      await tester.pumpAndSettle();
      expect(find.text('Explora el catálogo'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('search-field')), 'codigo');
      await tester.pumpAndSettle();
      expect(find.text('1 título encontrado'), findsOneWidget);
      await tester.tap(find.byKey(const Key('close-search')));
      await tester.pumpAndSettle();
      expect(find.byType(SeriesScreen), findsOneWidget);

      await goTo(tester, 'home');
      expect(find.text('Tendencias ahora'), findsOneWidget);
      final trendsScroll = find.descendant(
        of: find.byKey(const ValueKey('home-Tendencias ahora-scroll')),
        matching: find.byType(Scrollable),
      );
      final trendsPosition = tester
          .state<ScrollableState>(trendsScroll)
          .position;
      final trendsViewport = tester.getRect(
        find.byKey(const ValueKey('home-Tendencias ahora-scroll')),
      );
      final firstTrendCard = find.byKey(
        Key('home-Tendencias ahora-${movies.first.id}'),
      );
      final pageSize = (tester.getSize(firstTrendCard).width + 18) * 5;
      int fullyVisibleTrendCards() {
        return [
              for (final movie in movies.take(12))
                if (tester.any(
                  find.byKey(Key('home-Tendencias ahora-${movie.id}')),
                ))
                  tester.getRect(
                    find.byKey(Key('home-Tendencias ahora-${movie.id}')),
                  ),
            ]
            .where(
              (rect) =>
                  rect.left >= trendsViewport.left - 1 &&
                  rect.right <= trendsViewport.right + 1,
            )
            .length;
      }

      expect(fullyVisibleTrendCards(), 5);
      expect(find.byTooltip('Anterior: Tendencias ahora'), findsNothing);
      expect(find.byTooltip('Siguiente: Tendencias ahora'), findsOneWidget);
      await tester.tap(find.byTooltip('Siguiente: Tendencias ahora'));
      await tester.pumpAndSettle();
      expect(trendsPosition.pixels, closeTo(pageSize, 1));
      expect(fullyVisibleTrendCards(), 5);
      expect(find.byTooltip('Anterior: Tendencias ahora'), findsOneWidget);
      await tester.tap(find.byTooltip('Siguiente: Tendencias ahora'));
      await tester.pumpAndSettle();
      expect(trendsPosition.pixels, closeTo(pageSize * 2, 1));
      expect(trendsPosition.pixels, closeTo(trendsPosition.maxScrollExtent, 1));
      expect(find.byTooltip('Siguiente: Tendencias ahora'), findsNothing);
      expect(fullyVisibleTrendCards(), 2);
      await tester.tap(find.byTooltip('Anterior: Tendencias ahora'));
      await tester.pumpAndSettle();
      expect(trendsPosition.pixels, closeTo(pageSize, 1));
      expect(fullyVisibleTrendCards(), 5);
      await tester.tap(find.byTooltip('Anterior: Tendencias ahora'));
      await tester.pumpAndSettle();
      expect(trendsPosition.pixels, closeTo(0, 1));
      expect(find.byTooltip('Anterior: Tendencias ahora'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Mi lista conserva el título entre secciones y permite quitarlo',
    (tester) async {
      await openApp(tester);
      await signIn(tester);
      await tester.tap(find.byTooltip('Añadir a Mi lista'));
      await tester.pumpAndSettle();
      await goTo(tester, 'list');
      expect(find.text('1 títulos guardados'), findsOneWidget);
      final savedCardSize = tester.getSize(
        find.byKey(Key('movie-${movies.first.id}')),
      );
      expect(savedCardSize.width / savedCardSize.height, greaterThan(1.5));
      await goTo(tester, 'movies');
      await goTo(tester, 'list');
      expect(find.text('1 títulos guardados'), findsOneWidget);
      await tester.tap(find.byKey(Key('movie-${movies.first.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('save-movie-${movies.first.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Cerrar detalles'));
      await tester.pumpAndSettle();
      expect(find.text('0 títulos guardados'), findsOneWidget);
      expect(find.text('Explorar títulos'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Explorar títulos'));
      await tester.pumpAndSettle();
      expect(find.text('Tendencias ahora'), findsOneWidget);
    },
  );

  testWidgets(
    'Cabecera con cuatro enlaces, búsqueda y logo que regresa a Inicio',
    (tester) async {
      await openApp(tester);
      await signIn(tester);
      for (final section in ['home', 'movies', 'series', 'list']) {
        final tab = find.byKey(Key('nav-$section'));
        expect(tab, findsOneWidget);
        expect(tester.getTopLeft(tab).dy, lessThan(100));
      }
      expect(find.text('Búsqueda'), findsNothing);
      await goTo(tester, 'search');
      final field = find.byKey(const Key('search-field'));
      expect(tester.getTopLeft(field).dy, lessThan(100));
      await tester.enterText(field, 'no-existe-xyz');
      await tester.pumpAndSettle();
      expect(
        find.text('No encontramos títulos con esa búsqueda.'),
        findsOneWidget,
      );
      await tester.enterText(field, '');
      await tester.pumpAndSettle();
      expect(find.text('Explora el catálogo'), findsOneWidget);
      await tester.tap(find.byKey(const Key('suggestion-2')));
      await tester.pumpAndSettle();
      expect(find.text('1 título encontrado'), findsOneWidget);
      await tester.tap(find.byKey(const Key('search-save-2')));
      await tester.pumpAndSettle();
      await goTo(tester, 'list');
      expect(find.text('1 títulos guardados'), findsOneWidget);
      expect(find.text('Naruto'), findsOneWidget);
      await tester.tap(find.byKey(const Key('brand-home')));
      await tester.pumpAndSettle();
      expect(find.text('Tendencias ahora'), findsOneWidget);
    },
  );

  testWidgets('La X cierra Buscar y vuelve a la sección anterior', (
    tester,
  ) async {
    await openApp(tester);
    await signIn(tester);
    await goTo(tester, 'movies');
    await goTo(tester, 'search');
    await tester.enterText(find.byKey(const Key('search-field')), 'mirage');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close-search')));
    await tester.pumpAndSettle();
    expect(find.byType(MoviesScreen), findsOneWidget);
    expect(find.byKey(const Key('search-field')), findsNothing);
  });

  testWidgets(
    'Ventana estrecha mantiene la navegación superior sin desbordamientos',
    (tester) async {
      await openApp(tester, size: const Size(390, 844));
      await signIn(tester);
      expect(tester.takeException(), isNull);
      await goTo(tester, 'movies');
      expect(tester.takeException(), isNull);
      await goTo(tester, 'series');
      expect(tester.takeException(), isNull);
      await goTo(tester, 'search');
      expect(tester.takeException(), isNull);
      await goTo(tester, 'list');
      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets('Los nuevos títulos se pueden buscar, abrir y guardar', (
    tester,
  ) async {
    await openApp(tester);
    await signIn(tester);
    await goTo(tester, 'search');
    final field = find.byKey(const Key('search-field'));
    await tester.enterText(field, 'Sing 2');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('movie-16')), findsOneWidget);
    await tester.tap(find.byKey(const Key('movie-16')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-movie-16')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cerrar detalles'));
    await tester.pumpAndSettle();
    await tester.enterText(field, 'Squid Game');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('movie-28')), findsOneWidget);
    await goTo(tester, 'list');
    expect(find.byKey(const Key('movie-16')), findsOneWidget);
    expect(find.text('1 títulos guardados'), findsOneWidget);
  });

  testWidgets('La tarjeta abre una vista previa tras mantener el puntero', (
    tester,
  ) async {
    final size = const Size(1440, 1000);
    await openApp(tester, size: size);
    await signIn(tester);
    final card = find.byKey(const Key('home-Tendencias ahora-0'));
    await tester.ensureVisible(card);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(-10, -10));
    await gesture.moveTo(tester.getCenter(card));
    await tester.pump();
    final previewFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Material &&
          widget.key.toString().contains('hover-preview-'),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(previewFinder, findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(previewFinder, findsOneWidget);
    final preview = tester
        .widgetList<Material>(find.byType(Material))
        .firstWhere(
          (material) => material.key.toString().contains('hover-preview-'),
        );
    final previewId = int.parse(
      (preview.key as ValueKey<String>).value.substring(
        'hover-preview-'.length,
      ),
    );
    expect(find.byKey(ValueKey('hover-preview-$previewId')), findsOneWidget);
    final matchingCards = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.endsWith('-$previewId'),
    );
    final matchingCardCount = tester.widgetList<InkWell>(matchingCards).length;
    expect(matchingCardCount, greaterThan(0));
    final matchingCardRects = List.generate(
      matchingCardCount,
      (index) => tester.getRect(matchingCards.at(index)),
    );
    final previewRect = tester.getRect(
      find.byKey(ValueKey('hover-preview-$previewId')),
    );
    expect(previewRect.left, greaterThanOrEqualTo(0));
    expect(previewRect.top, greaterThanOrEqualTo(0));
    expect(previewRect.right, lessThanOrEqualTo(size.width));
    expect(previewRect.bottom, lessThanOrEqualTo(size.height));
    expect(matchingCardRects.any(previewRect.overlaps), isTrue);

    await tester.tap(find.byKey(ValueKey('preview-save-$previewId')));
    await tester.pump();
    final previewMovie = movies.firstWhere((movie) => movie.id == previewId);
    expect(
      find.descendant(
        of: find.byKey(ValueKey('hover-preview-$previewId')),
        matching: find.byTooltip('Quitar ${previewMovie.title} de Mi lista'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(ValueKey('preview-close-$previewId')));
    await tester.pump();
    expect(find.byKey(ValueKey('hover-preview-$previewId')), findsNothing);
    await gesture.removePointer();
    expect(tester.takeException(), isNull);
  });
}
