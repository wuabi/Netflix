import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../widgets/catalog_widgets.dart';
import '../widgets/search_result_card.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => CatalogScaffold(
    state: state,
    index: 4,
    child: ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final saved = state.saved;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Mi lista',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${saved.length} títulos guardados',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (saved.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_add_outlined,
                        size: 64,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tus próximas historias, en un solo lugar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Abre un título y pulsa Mi lista para guardarlo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, height: 1.5),
                      ),
                      const SizedBox(height: 26),
                      ElevatedButton(
                        onPressed: () => navigateToSection(context, 4, 0),
                        child: const Text('Explorar títulos'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final columns = (constraints.crossAxisExtent / 300)
                        .floor()
                        .clamp(1, 5)
                        .toInt();
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: 1.85,
                        mainAxisSpacing: 22,
                        crossAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            SearchResultCard(movie: saved[index], state: state),
                        childCount: saved.length,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
}
