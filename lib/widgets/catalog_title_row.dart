import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/movie.dart';
import 'search_result_card.dart';

class CatalogTitleRow extends StatefulWidget {
  const CatalogTitleRow({
    super.key,
    required this.title,
    required this.items,
    required this.state,
    required this.keyPrefix,
  });

  final String title;
  final List<Movie> items;
  final AppState state;
  final String keyPrefix;

  @override
  State<CatalogTitleRow> createState() => _CatalogTitleRowState();
}

class _CatalogTitleRowState extends State<CatalogTitleRow> {
  final _scroll = ScrollController();
  bool _canGoPrevious = false;
  bool _canGoNext = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateArrowVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrowVisibility();
    });
  }

  @override
  void didUpdateWidget(covariant CatalogTitleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrowVisibility();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_updateArrowVisibility);
    _scroll.dispose();
    super.dispose();
  }

  void _updateArrowVisibility() {
    if (!mounted || !_scroll.hasClients) return;
    final position = _scroll.position;
    final canGoPrevious = position.pixels > 1;
    final canGoNext = position.pixels < position.maxScrollExtent - 1;
    if (canGoPrevious == _canGoPrevious && canGoNext == _canGoNext) return;
    setState(() {
      _canGoPrevious = canGoPrevious;
      _canGoNext = canGoNext;
    });
  }

  void _move(double direction, double cardWidth) {
    if (!_scroll.hasClients) return;
    const gap = 18.0;
    final pageSize = (cardWidth + gap) * 5;
    final currentPage = (_scroll.offset / pageSize).round();
    final target = ((currentPage + direction) * pageSize)
        .clamp(0.0, _scroll.position.maxScrollExtent)
        .toDouble();
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 700;
      final margin = compact ? 20.0 : 44.0;
      final cardsPerPage = constraints.maxWidth >= 1050
          ? 5
          : constraints.maxWidth >= 700
          ? 3
          : 2;
      const gap = 18.0;
      final width =
          (constraints.maxWidth - margin * 2 - gap * (cardsPerPage - 1)) /
          cardsPerPage;
      final pageCount = (widget.items.length / cardsPerPage).ceil();
      final displayedItemCount = pageCount * cardsPerPage;
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(margin, 0, margin - 6, 14),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: compact ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.4,
                ),
              ),
            ),
            SizedBox(
              height: width * 9 / 16 + 10,
              child: Stack(
                children: [
                  NotificationListener<ScrollMetricsNotification>(
                    onNotification: (_) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateArrowVisibility();
                      });
                      return false;
                    },
                    child: ListView.builder(
                      key: ValueKey('${widget.keyPrefix}-scroll'),
                      controller: _scroll,
                      padding: EdgeInsets.fromLTRB(margin, 5, margin - gap, 5),
                      scrollDirection: Axis.horizontal,
                      itemExtent: width + gap,
                      itemCount: displayedItemCount,
                      itemBuilder: (context, index) {
                        if (index >= widget.items.length) {
                          return const SizedBox.shrink();
                        }
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: width,
                            child: SearchResultCard(
                              movie: widget.items[index],
                              state: widget.state,
                              keyPrefix: widget.keyPrefix,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_canGoPrevious)
                    Positioned(
                      left: compact ? 2 : 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          tooltip: 'Anterior: ${widget.title}',
                          onPressed: () => _move(-1, width),
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            size: 30,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xE6000000),
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            fixedSize: const Size(46, 46),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  if (_canGoNext)
                    Positioned(
                      right: compact ? 2 : 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          tooltip: 'Siguiente: ${widget.title}',
                          onPressed: () => _move(1, width),
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            size: 30,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xE6000000),
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            fixedSize: const Size(46, 46),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
