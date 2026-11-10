import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/movie.dart';
import '../widgets/catalog_title_row.dart';
import '../widgets/catalog_widgets.dart';
import '../widgets/featured_carousel.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.state, required this.series});
  final AppState state;
  final bool series;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final List<Movie> _items;
  late final List<String> _genres;
  late final ValueNotifier<Color> _backgroundColor;
  String _selectedGenre = 'Todos';

  @override
  void initState() {
    super.initState();
    _items = movies.where((movie) => movie.isSeries == widget.series).toList();
    _genres =
        _items.expand((movie) => movie.genre.split(' · ')).toSet().toList()
          ..sort();
    _backgroundColor = ValueNotifier(featuredColorFor(_items.first));
  }

  List<Movie> get _visibleItems => _selectedGenre == 'Todos'
      ? _items
      : _items
            .where((movie) => movie.genre.split(' · ').contains(_selectedGenre))
            .toList();

  List<({String key, String title, List<String> genres})> get _categories => [
    (key: 'action', title: 'Acción y aventura', genres: ['Acción', 'Aventura']),
    (
      key: 'drama',
      title: 'Drama y suspenso',
      genres: ['Drama', 'Suspenso', 'Crimen'],
    ),
    (
      key: 'fantasy',
      title: 'Fantasía y ciencia ficción',
      genres: ['Fantasía', 'Ciencia ficción'],
    ),
    (
      key: 'family',
      title: 'Animación y para toda la familia',
      genres: ['Animación', 'Familiar', 'Aventura', 'Comedia'],
    ),
    (key: 'comedy', title: 'Comedias para disfrutar', genres: ['Comedia']),
  ];

  List<Movie> _itemsForGenres(List<String> genres) => _visibleItems
      .where(
        (movie) =>
            genres.any((genre) => movie.genre.split(' · ').contains(genre)),
      )
      .toList();

  void _selectGenre(String genre) {
    setState(() => _selectedGenre = genre);
    _backgroundColor.value = featuredColorFor(_visibleItems.first);
  }

  @override
  void dispose() {
    _backgroundColor.dispose();
    super.dispose();
  }

  Widget _genreFilter() => PopupMenuButton<String>(
    key: const Key('genre-filter'),
    tooltip: 'Filtrar por género',
    initialValue: _selectedGenre,
    onSelected: _selectGenre,
    color: const Color(0xFF242424),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0x33FFFFFF)),
    ),
    itemBuilder: (context) => [
      for (final genre in ['Todos', ..._genres])
        PopupMenuItem(
          key: ValueKey('genre-option-$genre'),
          value: genre,
          child: Row(
            children: [
              Expanded(
                child: Text(genre == 'Todos' ? 'Todos los géneros' : genre),
              ),
              if (_selectedGenre == genre)
                const Icon(Icons.check_rounded, size: 18),
            ],
          ),
        ),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        border: Border.all(color: Colors.white.withValues(alpha: .2)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Géneros',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_drop_down_rounded, size: 20),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => CatalogScaffold(
    state: widget.state,
    index: widget.series ? 3 : 2,
    backgroundColor: _backgroundColor,
    child: ListView(
      key: PageStorageKey(widget.series ? 'series-catalog' : 'movies-catalog'),
      padding: const EdgeInsets.only(top: 18, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(44, 0, 44, 2),
          child: Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                key: const Key('catalog-title'),
                widget.series ? 'Series' : 'Películas',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _genreFilter(),
            ],
          ),
        ),
        FeaturedCarousel(
          key: ValueKey('featured-genre-$_selectedGenre'),
          movies: _visibleItems,
          state: widget.state,
          showLabel: false,
          onMovieChanged: (movie) =>
              _backgroundColor.value = featuredColorFor(movie),
        ),
        CatalogTitleRow(
          key: const ValueKey('catalog-row-all'),
          title: _selectedGenre == 'Todos'
              ? 'Populares en ${widget.series ? 'series' : 'películas'}'
              : '${widget.series ? 'Series' : 'Películas'} de $_selectedGenre',
          items: _visibleItems,
          state: widget.state,
          keyPrefix: 'catalog-${widget.series ? 'series' : 'movies'}-all',
        ),
        for (final category in _categories)
          if (_itemsForGenres(category.genres).isNotEmpty)
            CatalogTitleRow(
              key: ValueKey('catalog-row-${category.key}'),
              title: category.title,
              items: _itemsForGenres(category.genres),
              state: widget.state,
              keyPrefix:
                  'catalog-${widget.series ? 'series' : 'movies'}-${category.key}',
            ),
      ],
    ),
  );
}
