import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/movie.dart';
import '../widgets/catalog_widgets.dart';
import '../widgets/catalog_title_row.dart';
import '../widgets/featured_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ValueNotifier<Color> _backgroundColor;

  @override
  void initState() {
    super.initState();
    _backgroundColor = ValueNotifier(featuredColorFor(movies.first));
  }

  @override
  void dispose() {
    _backgroundColor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatalogScaffold(
    state: widget.state,
    index: 0,
    backgroundColor: _backgroundColor,
    child: ListView(
      key: const PageStorageKey('home-scroll'),
      children: [
        FeaturedCarousel(
          movies: movies,
          state: widget.state,
          onMovieChanged: (movie) =>
              _backgroundColor.value = featuredColorFor(movie),
        ),
        CatalogTitleRow(
          title: 'Tendencias ahora',
          items: movies.take(12).toList(),
          state: widget.state,
          keyPrefix: 'home-Tendencias ahora',
        ),
        CatalogTitleRow(
          title: 'Tu próxima noche de cine',
          items: movies.where((movie) => !movie.isSeries).toList(),
          state: widget.state,
          keyPrefix: 'home-Tu próxima noche de cine',
        ),
        CatalogTitleRow(
          title: 'Series para maratonear',
          items: movies.where((movie) => movie.isSeries).toList(),
          state: widget.state,
          keyPrefix: 'home-Series para maratonear',
        ),
        CatalogTitleRow(
          title: 'Misterios que te atrapan',
          items: movies
              .where(
                (movie) =>
                    movie.genre.contains('Suspenso') ||
                    movie.genre.contains('Crimen'),
              )
              .toList(),
          state: widget.state,
          keyPrefix: 'home-Misterios que te atrapan',
        ),
        CatalogTitleRow(
          title: 'Para ver en familia',
          items: movies
              .where(
                (movie) =>
                    (movie.genre.contains('Animación') ||
                        movie.genre.contains('Aventura') ||
                        movie.genre.contains('Comedia')) &&
                    ['7+', '13+'].contains(movie.ageRating),
              )
              .toList(),
          state: widget.state,
          keyPrefix: 'home-Para ver en familia',
        ),
        const SizedBox(height: 48),
      ],
    ),
  );
}
