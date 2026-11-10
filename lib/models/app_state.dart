import 'package:flutter/foundation.dart';

import 'movie.dart';

// Estado compartido en memoria. Se reinicia al cerrar sesión o recargar.
class AppState extends ChangeNotifier {
  final Set<int> _saved = {};
  bool contains(Movie movie) => _saved.contains(movie.id);
  List<Movie> get saved => movies.where(contains).toList();

  void toggle(Movie movie) {
    if (!_saved.add(movie.id)) _saved.remove(movie.id);
    notifyListeners();
  }

  void clear() {
    _saved.clear();
    notifyListeners();
  }
}
