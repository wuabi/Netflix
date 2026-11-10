import 'package:flutter/material.dart';

import '../models/app_state.dart';
import 'catalog_screen.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) =>
      CatalogScreen(state: state, series: true);
}
