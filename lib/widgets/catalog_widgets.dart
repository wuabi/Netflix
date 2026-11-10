import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../models/app_state.dart';

class Brand extends StatelessWidget {
  const Brand({super.key, this.width = 150});
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: width * 384 / 1428,
    // Encuadra el área visible del PNG oficial sin deformar el logotipo.
    child: ClipRect(
      child: OverflowBox(
        minWidth: width * 1800 / 1428,
        maxWidth: width * 1800 / 1428,
        minHeight: width * 756 / 1428,
        maxHeight: width * 756 / 1428,
        child: Image.asset(
          'assets/images/netflix_logo.png',
          width: width * 1800 / 1428,
          height: width * 756 / 1428,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          semanticLabel: 'Netflix',
        ),
      ),
    ),
  );
}

const _destinations = <({int index, String label, String key})>[
  (index: 0, label: 'Inicio', key: 'home'),
  (index: 2, label: 'Películas', key: 'movies'),
  (index: 3, label: 'Series', key: 'series'),
  (index: 4, label: 'Mi lista', key: 'list'),
];

// Inicio permanece como raíz; cambiar de sección no acumula rutas.
void navigateToSection(BuildContext context, int current, int selected) {
  if (selected == current) return;
  final navigator = Navigator.of(context);
  if (selected == 0) {
    navigator.popUntil(ModalRoute.withName('/home'));
    return;
  }
  final path = switch (selected) {
    1 => '/search',
    2 => '/movies',
    3 => '/series',
    4 => '/list',
    _ => '/home',
  };
  if (current == 0 || selected == 1) {
    navigator.pushNamed(path);
  } else {
    navigator.pushReplacementNamed(path);
  }
}

class CatalogScaffold extends StatelessWidget {
  const CatalogScaffold({
    super.key,
    required this.state,
    required this.index,
    required this.child,
    this.backgroundColor,
    this.searchController,
    this.onSearchChanged,
  });
  final AppState state;
  final int index;
  final Widget child;
  final ValueListenable<Color>? backgroundColor;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  Widget _body(Color tint) => DecoratedBox(
    key: const Key('catalog-background'),
    decoration: BoxDecoration(
      color: const Color(0xFF141414),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: const Alignment(0, .8),
        colors: [
          Color.lerp(tint, Colors.black, .42)!,
          Color.lerp(tint, const Color(0xFF141414), .72)!,
          const Color(0xFF141414),
        ],
        stops: const [0, .42, 1],
      ),
    ),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CatalogHeader(
            state: state,
            index: index,
            searchController: searchController,
            onSearchChanged: onSearchChanged,
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final notifier = backgroundColor;
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: notifier == null
          ? _body(const Color(0xFF193C48))
          : ValueListenableBuilder<Color>(
              valueListenable: notifier,
              builder: (context, tint, _) => _body(tint),
            ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.state,
    required this.index,
    required this.searchController,
    required this.onSearchChanged,
  });
  final AppState state;
  final int index;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  bool get _searching => index == 1 && searchController != null;

  Widget _brand(BuildContext context, {double width = 108}) => Tooltip(
    message: 'Ir a Inicio',
    child: InkWell(
      key: const ValueKey('brand-home'),
      onTap: () => navigateToSection(context, index, 0),
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Brand(width: width),
      ),
    ),
  );

  Widget _navigation(BuildContext context, {bool compact = false}) {
    final links = [
      for (final destination in _destinations)
        _TopNavLink(
          key: ValueKey('nav-${destination.key}'),
          label: destination.label,
          selected: index == destination.index,
          compact: compact,
          onTap: () => navigateToSection(context, index, destination.index),
        ),
    ];
    return Row(
      mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
      children: compact
          ? links.map((link) => Expanded(child: link)).toList()
          : links,
    );
  }

  Widget _search(BuildContext context) => IconButton(
    key: const ValueKey('nav-search'),
    tooltip: 'Buscar títulos',
    onPressed: () => navigateToSection(context, index, 1),
    icon: const Icon(Icons.search_rounded, size: 26),
    style: IconButton.styleFrom(
      foregroundColor: Colors.white,
      hoverColor: Colors.white.withValues(alpha: .13),
      minimumSize: const Size(44, 44),
    ),
  );

  Widget _profile(BuildContext context) => PopupMenuButton<String>(
    key: const ValueKey('profile-menu'),
    tooltip: 'Perfil de Admin',
    offset: const Offset(0, 52),
    color: const Color(0xFF191919),
    elevation: 12,
    constraints: const BoxConstraints(minWidth: 190),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: Colors.white.withValues(alpha: .12)),
    ),
    onSelected: (value) {
      if (value != 'logout') return;
      state.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    },
    itemBuilder: (context) => [
      const PopupMenuItem<String>(
        enabled: false,
        child: Text('Admin', style: TextStyle(color: Colors.white70)),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem<String>(
        key: ValueKey('logout'),
        value: 'logout',
        child: Row(
          children: [
            Icon(Icons.logout_rounded, size: 18),
            SizedBox(width: 12),
            Text('Cerrar sesión'),
          ],
        ),
      ),
    ],
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF326F88), Color(0xFF17364B)],
              ),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 24),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_drop_down_rounded, size: 20),
        ],
      ),
    ),
  );

  Widget _searchField(BuildContext context) => _HeaderSearchField(
    controller: searchController!,
    onChanged: onSearchChanged,
    onClose: () {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        navigator.pushReplacementNamed('/home');
      }
    },
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 1050;
      final outerPadding = desktop ? 16.0 : 12.0;
      final innerPadding = desktop ? 0.0 : 16.0;
      final searchOnOwnRow = _searching && constraints.maxWidth < 680;
      final header = desktop
          ? SizedBox(
              height: 70,
              child: Row(
                children: [
                  _brand(context),
                  const SizedBox(width: 24),
                  _navigation(context),
                  const Spacer(),
                  if (_searching)
                    SizedBox(
                      width: constraints.maxWidth >= 1260 ? 310 : 260,
                      child: _searchField(context),
                    )
                  else
                    _search(context),
                  const SizedBox(width: 12),
                  _profile(context),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 58,
                  child: Row(
                    children: [
                      _brand(context, width: 102),
                      const Spacer(),
                      if (_searching && !searchOnOwnRow)
                        SizedBox(width: 300, child: _searchField(context))
                      else if (!_searching)
                        _search(context),
                      const SizedBox(width: 10),
                      _profile(context),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(
                    height: 44,
                    child: _navigation(context, compact: true),
                  ),
                ),
                if (searchOnOwnRow)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 10),
                    child: _searchField(context),
                  ),
              ],
            );
      return Padding(
        padding: EdgeInsets.fromLTRB(
          outerPadding,
          desktop ? 4 : 10,
          outerPadding,
          desktop ? 4 : 8,
        ),
        child: Material(
          key: const ValueKey('catalog-header'),
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: innerPadding),
            child: header,
          ),
        ),
      );
    },
  );
}

class _TopNavLink extends StatelessWidget {
  const _TopNavLink({
    super.key,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.white : const Color(0xFFD0D8DB),
        backgroundColor: selected
            ? Colors.white.withValues(alpha: .18)
            : Colors.transparent,
        minimumSize: const Size(0, 44),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 18,
          vertical: 12,
        ),
        textStyle: TextStyle(
          fontSize: compact ? 13 : 15,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: const StadiumBorder(),
        overlayColor: Colors.white.withValues(alpha: .12),
      ),
      child: Text(label, maxLines: 1),
    ),
  );
}

class _HeaderSearchField extends StatefulWidget {
  const _HeaderSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onClose;

  @override
  State<_HeaderSearchField> createState() => _HeaderSearchFieldState();
}

class _HeaderSearchFieldState extends State<_HeaderSearchField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<TextEditingValue>(
    valueListenable: widget.controller,
    builder: (context, _, _) => TextField(
      key: const ValueKey('search-field'),
      controller: widget.controller,
      focusNode: _focus,
      autofocus: true,
      onChanged: widget.onChanged,
      autocorrect: false,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Buscar títulos',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: const Icon(Icons.search_rounded, size: 23),
        prefixIconColor: Colors.white,
        suffixIcon: IconButton(
          key: const ValueKey('close-search'),
          tooltip: 'Cerrar búsqueda',
          onPressed: widget.onClose,
          icon: const Icon(Icons.close_rounded, size: 21),
          color: Colors.white,
        ),
        filled: true,
        fillColor: Colors.black.withValues(alpha: .18),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .22)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .65)),
        ),
      ),
    ),
  );
}

void simulatePlay(BuildContext context, Movie movie) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Reproducción simulada: ${movie.title}. No se reproduce video.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showMovie(BuildContext context, Movie movie, AppState state) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0xFF181818),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 790,
          maxHeight: MediaQuery.sizeOf(dialogContext).height * .9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 230,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      movie.backdrop,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) =>
                          const ColoredBox(color: Color(0xFF202020)),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF181818)],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: IconButton.filled(
                        tooltip: 'Cerrar detalles',
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: ListenableBuilder(
                  listenable: state,
                  builder: (detailsContext, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      if (movie.originalTitle.isNotEmpty &&
                          movie.originalTitle != movie.title) ...[
                        const SizedBox(height: 6),
                        Text(
                          movie.originalTitle,
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Text(
                            '${movie.year}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            movie.format,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            movie.duration,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            movie.ageRating,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        movie.description,
                        style: const TextStyle(height: 1.6),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        movie.genre,
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              simulatePlay(context, movie);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Reproducir'),
                          ),
                          OutlinedButton.icon(
                            key: ValueKey('save-movie-${movie.id}'),
                            onPressed: () => state.toggle(movie),
                            icon: Icon(
                              state.contains(movie) ? Icons.check : Icons.add,
                            ),
                            label: Text(
                              state.contains(movie)
                                  ? 'Quitar de Mi lista'
                                  : 'Mi lista',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, required this.state});
  final Movie movie;
  final AppState state;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${movie.title}, ${movie.format}',
    child: Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFF202020),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        key: ValueKey('movie-${movie.id}'),
        onTap: () => showMovie(context, movie, state),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              movie.image,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) => const ColoredBox(
                color: Color(0xFF242424),
                child: Center(child: Icon(Icons.movie_outlined, size: 50)),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xF2000000)],
                  stops: [0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${movie.year}  ·  ${movie.format}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.items, required this.state});
  final List<Movie> items;
  final AppState state;
  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) => SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (constraints.crossAxisExtent / 190)
            .floor()
            .clamp(1, 6)
            .toInt(),
        childAspectRatio: 0.63,
        mainAxisSpacing: 22,
        crossAxisSpacing: 18,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => MovieCard(movie: items[index], state: state),
        childCount: items.length,
      ),
    ),
  );
}
