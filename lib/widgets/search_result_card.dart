import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/movie.dart';
import 'catalog_widgets.dart';

/// Tarjeta panorámica para los resultados, con acciones de teclado y ratón.
class SearchResultCard extends StatefulWidget {
  const SearchResultCard({
    super.key,
    required this.movie,
    required this.state,
    this.keyPrefix,
  });
  final Movie movie;
  final AppState state;
  final String? keyPrefix;

  @override
  State<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<SearchResultCard> {
  static const _previewDelay = Duration(milliseconds: 700);
  static const _previewCloseDelay = Duration(milliseconds: 250);
  static const _previewWidth = 390.0;
  static const _previewHeight = 330.0;

  bool _hovered = false;
  bool _focused = false;
  bool _previewVisible = false;
  Timer? _showTimer;
  Timer? _closeTimer;
  final _previewController = OverlayPortalController();

  @override
  void dispose() {
    _showTimer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  void _onPointerEnter() {
    _closeTimer?.cancel();
    setState(() => _hovered = true);
    _showTimer?.cancel();
    _showTimer = Timer(_previewDelay, _showPreview);
  }

  void _onPointerExit() {
    setState(() => _hovered = false);
    _showTimer?.cancel();
    _schedulePreviewClose();
  }

  void _schedulePreviewClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(_previewCloseDelay, _closePreview);
  }

  void _showPreview() {
    if (!mounted || !_hovered || _previewController.isShowing) return;
    setState(() => _previewVisible = true);
    _previewController.show();
  }

  void _closePreview() {
    _showTimer?.cancel();
    _closeTimer?.cancel();
    if (_previewVisible) {
      setState(() => _previewVisible = false);
      _previewController.hide();
    }
  }

  Widget _buildPreview(
    BuildContext context,
    OverlayChildLayoutInfo layoutInfo,
  ) {
    if (!_previewVisible || layoutInfo.childPaintTransform.determinant() == 0) {
      return const SizedBox.shrink();
    }
    final overlaySize = layoutInfo.overlaySize;
    final targetRect = MatrixUtils.transformRect(
      layoutInfo.childPaintTransform,
      Offset.zero & layoutInfo.childSize,
    );
    final previewWidth = math.min(_previewWidth, overlaySize.width - 24);
    final previewHeight = math.min(_previewHeight, overlaySize.height - 24);
    final left = (targetRect.center.dx - previewWidth / 2)
        .clamp(12.0, overlaySize.width - previewWidth - 12)
        .toDouble();
    final top = (targetRect.center.dy - previewHeight / 2)
        .clamp(12.0, overlaySize.height - previewHeight - 12)
        .toDouble();
    return Transform.translate(
      offset: Offset(left, top),
      child: Align(
        alignment: Alignment.topLeft,
        child: MouseRegion(
          onEnter: (_) {
            _closeTimer?.cancel();
          },
          onExit: (_) => _schedulePreviewClose(),
          child: SizedBox(
            width: previewWidth,
            height: previewHeight,
            child: _HoverPreview(
              movie: widget.movie,
              state: widget.state,
              onPlay: () {
                _closePreview();
                simulatePlay(context, widget.movie);
              },
              onDetails: () {
                _closePreview();
                showMovie(context, widget.movie, widget.state);
              },
              onClose: _closePreview,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final highlighted = _hovered || _focused;
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _previewController,
      overlayChildBuilder: _buildPreview,
      child: MouseRegion(
        onEnter: (_) => _onPointerEnter(),
        onExit: (_) => _onPointerExit(),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: highlighted ? 1.025 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Material(
            color: const Color(0xFF202020),
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              key: ValueKey('${widget.keyPrefix ?? 'movie'}-${movie.id}'),
              onTap: () => showMovie(context, movie, widget.state),
              onFocusChange: (focused) => setState(() => _focused = focused),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    movie.backdrop,
                    fit: BoxFit.cover,
                    semanticLabel: movie.title,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xF2080808)],
                        stops: [0.3, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${movie.year}  ·  ${movie.format}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        ListenableBuilder(
                          listenable: widget.state,
                          builder: (context, _) {
                            final saved = widget.state.contains(movie);
                            return IconButton(
                              key: ValueKey(
                                '${widget.keyPrefix ?? 'search'}-save-${movie.id}',
                              ),
                              tooltip: saved
                                  ? 'Quitar ${movie.title} de Mi lista'
                                  : 'Añadir ${movie.title} a Mi lista',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xA6282828),
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                minimumSize: const Size(34, 34),
                                padding: const EdgeInsets.all(6),
                              ),
                              onPressed: () => widget.state.toggle(movie),
                              icon: Icon(
                                saved ? Icons.check : Icons.add,
                                size: 19,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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

class _HoverPreview extends StatelessWidget {
  const _HoverPreview({
    required this.movie,
    required this.state,
    required this.onPlay,
    required this.onDetails,
    required this.onClose,
  });

  final Movie movie;
  final AppState state;
  final VoidCallback onPlay;
  final VoidCallback onDetails;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Material(
    key: ValueKey('hover-preview-${movie.id}'),
    color: const Color(0xFF181818),
    elevation: 20,
    clipBehavior: Clip.antiAlias,
    borderRadius: BorderRadius.circular(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                movie.backdrop,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Color(0xFF202020)),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xFF181818)],
                    stops: [.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 12,
                bottom: 12,
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton.filled(
                      key: ValueKey('preview-play-${movie.id}'),
                      tooltip: 'Reproducir ${movie.title}',
                      onPressed: onPlay,
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                    const SizedBox(width: 8),
                    ListenableBuilder(
                      listenable: state,
                      builder: (context, _) {
                        final saved = state.contains(movie);
                        return IconButton(
                          key: ValueKey('preview-save-${movie.id}'),
                          tooltip: saved
                              ? 'Quitar ${movie.title} de Mi lista'
                              : 'Añadir ${movie.title} a Mi lista',
                          onPressed: () => state.toggle(movie),
                          icon: Icon(saved ? Icons.check_rounded : Icons.add),
                        );
                      },
                    ),
                    IconButton(
                      key: ValueKey('preview-details-${movie.id}'),
                      tooltip: 'Más información de ${movie.title}',
                      onPressed: onDetails,
                      icon: const Icon(Icons.info_outline_rounded),
                    ),
                    const Spacer(),
                    IconButton(
                      key: ValueKey('preview-close-${movie.id}'),
                      tooltip: 'Cerrar vista previa',
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${movie.year}  ·  ${movie.format}  ·  ${movie.ageRating}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    movie.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
