import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/movie.dart';
import '../widgets/catalog_widgets.dart';
import '../widgets/search_result_card.dart';

String normalizeSearch(String value) {
  const accents = 'áéíóúüñ';
  const letters = 'aeiouun';
  var normalized = value.toLowerCase().trim();
  for (var i = 0; i < accents.length; i++) {
    normalized = normalized.replaceAll(accents[i], letters[i]);
  }
  return normalized;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.state});
  final AppState state;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _useSuggestion(Movie movie) {
    _search.value = TextEditingValue(
      text: movie.title,
      selection: TextSelection.collapsed(offset: movie.title.length),
    );
    setState(() => _query = movie.title);
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizeSearch(_query);
    final results = movies
        .where(
          (movie) => normalizeSearch(
            '${movie.title} ${movie.originalTitle}',
          ).contains(query),
        )
        .toList();
    final suggestions = query.isEmpty
        ? movies.where((movie) => movie.isSeries).take(5).toList()
        : results.take(6).toList();
    return CatalogScaffold(
      state: widget.state,
      index: 1,
      searchController: _search,
      onSearchChanged: (value) => setState(() => _query = value),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final margin = constraints.maxWidth >= 900 ? 48.0 : 22.0;
          final gridWidth = constraints.maxWidth - margin * 2;
          final columns = (gridWidth / 285).floor().clamp(1, 5).toInt();
          return CustomScrollView(
            key: const PageStorageKey('search-results-scroll'),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(margin, 44, margin, 28),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              query.isEmpty
                                  ? 'Descubre tu próxima historia:'
                                  : 'Descubre títulos relacionados con:',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          for (var i = 0; i < suggestions.length; i++) ...[
                            TextButton(
                              key: ValueKey('suggestion-${suggestions[i].id}'),
                              onPressed: () => _useSuggestion(suggestions[i]),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                suggestions[i].title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (i < suggestions.length - 1)
                              const Text(
                                '│',
                                style: TextStyle(color: Colors.white30),
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        query.isEmpty
                            ? 'Explora el catálogo'
                            : '${results.length} ${results.length == 1 ? 'título encontrado' : 'títulos encontrados'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(margin, 32, margin, 64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          color: Colors.white38,
                          size: 44,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No encontramos títulos con esa búsqueda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Prueba otro título, en español o en su idioma original.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, height: 1.6),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Ver todo el catálogo'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(margin, 0, margin, 56),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 16 / 9,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 38,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => SearchResultCard(
                        movie: results[index],
                        state: widget.state,
                      ),
                      childCount: results.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
