import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/movie.dart';
import 'catalog_widgets.dart';

Color featuredColorFor(Movie movie) {
  final titleSeed = movie.title.codeUnits.fold<int>(
    movie.id,
    (value, unit) => (value * 31 + unit) & 0x7fffffff,
  );
  final hue = titleSeed % 360;
  return HSVColor.fromAHSV(1, hue.toDouble(), .68, .3).toColor();
}

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({
    super.key,
    required this.movies,
    required this.state,
    required this.onMovieChanged,
    this.showLabel = true,
  });

  final List<Movie> movies;
  final AppState state;
  final ValueChanged<Movie> onMovieChanged;
  final bool showLabel;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted || widget.movies.length < 2) return;
      final nextPage = (_currentPage + 1) % widget.movies.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 700;
      final margin = compact ? 16.0 : 44.0;
      final height = compact
          ? 640.0
          : ((constraints.maxWidth - margin * 2) / 2.15)
                .clamp(500.0, 650.0)
                .toDouble();
      final indicatorCount = widget.movies.length.clamp(1, 5);
      final activeIndicator = _currentPage % indicatorCount;

      return Padding(
        padding: EdgeInsets.fromLTRB(margin, 8, margin, 28),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              PageView.builder(
                key: const Key('featured-carousel'),
                controller: _pageController,
                itemCount: widget.movies.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  widget.onMovieChanged(widget.movies[index]);
                },
                itemBuilder: (context, index) => _FeaturedPanel(
                  movie: widget.movies[index],
                  state: widget.state,
                  compact: compact,
                  showLabel: widget.showLabel,
                ),
              ),
              if (widget.movies.length > 1)
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const Key('featured-previous'),
                        tooltip: 'Título destacado anterior',
                        onPressed: () => _showPage(
                          (_currentPage - 1 + widget.movies.length) %
                              widget.movies.length,
                        ),
                        icon: const Icon(Icons.chevron_left_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x66000000),
                        ),
                      ),
                      const SizedBox(width: 4),
                      for (var index = 0; index < indicatorCount; index++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            key: ValueKey('featured-dot-$index'),
                            onTap: () => _showPage(index),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: index == activeIndicator ? 20 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: index == activeIndicator
                                    ? Colors.white
                                    : Colors.white54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        key: const Key('featured-next'),
                        tooltip: 'Siguiente título destacado',
                        onPressed: () => _showPage(
                          (_currentPage + 1) % widget.movies.length,
                        ),
                        icon: const Icon(Icons.chevron_right_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x66000000),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _FeaturedPanel extends StatelessWidget {
  const _FeaturedPanel({
    required this.movie,
    required this.state,
    required this.compact,
    required this.showLabel,
  });

  final Movie movie;
  final AppState state;
  final bool compact;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 24.0 : 40.0;
    return Container(
      key: Key('featured-panel-${movie.id}'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(color: const Color(0x22FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x70000000),
            blurRadius: 44,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(movie.backdrop),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: .78),
                  Colors.black.withValues(alpha: .48),
                  Colors.black.withValues(alpha: .08),
                ],
                stops: const [0, .56, 1],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                padding,
                compact ? 34 : 50,
                padding,
                72,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLabel)
                    Text(
                      movie.isSeries ? 'SERIE DESTACADA' : 'PELÍCULA DESTACADA',
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 36 : 58,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  if (movie.originalTitle.isNotEmpty &&
                      movie.originalTitle != movie.title) ...[
                    const SizedBox(height: 8),
                    Text(
                      movie.originalTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 1,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      for (final label in [
                        movie.format,
                        movie.genre,
                        '${movie.year}',
                        movie.duration,
                        movie.ageRating,
                      ])
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFEBF0F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 590),
                    child: Text(
                      movie.description,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 14 : 16,
                        height: 1.5,
                        color: const Color(0xFFF0F1F2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () => simulatePlay(context, movie),
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text('Reproducir'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0x30FFFFFF),
                          side: const BorderSide(color: Color(0x55FFFFFF)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () => showMovie(context, movie, state),
                        child: const Text('Más información'),
                      ),
                      ListenableBuilder(
                        listenable: state,
                        builder: (context, _) => IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x33FFFFFF),
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.all(14),
                          ),
                          tooltip: state.contains(movie)
                              ? 'Quitar de Mi lista'
                              : 'Añadir a Mi lista',
                          onPressed: () => state.toggle(movie),
                          icon: Icon(
                            state.contains(movie) ? Icons.check : Icons.add,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
