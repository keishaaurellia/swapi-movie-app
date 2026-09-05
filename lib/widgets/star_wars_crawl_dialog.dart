import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cinemax_app/data/config/app_dimens.dart';

class StarWarsCrawlDialog extends StatefulWidget {
  final String title;
  final int episodeId;
  final String openingCrawl;

  const StarWarsCrawlDialog({
    super.key,
    required this.title,
    required this.episodeId,
    required this.openingCrawl,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required int episodeId,
    required String openingCrawl,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'StarWarsCrawl',
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return StarWarsCrawlDialog(
          title: title,
          episodeId: episodeId,
          openingCrawl: openingCrawl,
        );
      },
    );
  }

  @override
  State<StarWarsCrawlDialog> createState() => _StarWarsCrawlDialogState();
}

class _StarWarsCrawlDialogState extends State<StarWarsCrawlDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPlaying = true;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
        _isPlaying = false;
      } else {
        _controller.forward();
        _isPlaying = true;
      }
    });
  }

  void _restart() {
    _controller.reset();
    _controller.forward();
    setState(() {
      _isPlaying = true;
    });
  }

  void _cycleSpeed() {
    setState(() {
      if (_speed == 1.0) {
        _speed = 1.5;
        _controller.duration = const Duration(seconds: 22);
      } else if (_speed == 1.5) {
        _speed = 2.0;
        _controller.duration = const Duration(seconds: 16);
      } else {
        _speed = 1.0;
        _controller.duration = const Duration(seconds: 32);
      }
      if (_isPlaying) {
        final current = _controller.value;
        _controller.forward(from: current);
      }
    });
  }

  String _toRoman(int num) {
    switch (num) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      case 5:
        return 'V';
      case 6:
        return 'VI';
      default:
        return num.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _StarfieldPainter(),
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                final delta = -(details.primaryDelta ?? 0.0) / (size.height * 1.5);
                _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
              },
              onVerticalDragEnd: (_) {
                if (_isPlaying) {
                  _controller.forward();
                }
              },
              child: ClipRect(
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0028)
                    ..rotateX(0.86),
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final progress = _controller.value;
                        final startY = size.height * 0.95;
                        final endY = -size.height * 1.4;
                        final dy = startY + (endY - startY) * progress;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: Center(
                        child: Container(
                          width: math.min(size.width * 0.88, 460),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'EPISODE ${_toRoman(widget.episodeId)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFE81F),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4.5,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.title.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFE81F),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3.5,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 36),
                              Text(
                                widget.openingCrawl.replaceAll('\r\n', '\n'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFE81F),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  height: 1.75,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.28,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black87,
                      Colors.black26,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(200),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFE81F).withAlpha(140),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_in_ar,
                            color: Color(0xFFFFE81F), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'OPENING CRAWL 3D',
                          style: TextStyle(
                            color: Color(0xFFFFE81F),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Tutup tampilan layar penuh',
                    child: Container(
                      width: AppDimens.buttonSize,
                      height: AppDimens.buttonSize,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFE81F).withAlpha(120),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: AppDimens.iconSize),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(220),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFE81F).withAlpha(100),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Ulangi crawl dari awal',
                      child: SizedBox(
                        width: AppDimens.buttonSizeLarge,
                        height: AppDimens.buttonSizeLarge,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.replay,
                              color: Color(0xFFFFE81F),
                              size: AppDimens.iconSizeLarge),
                          tooltip: 'Restart',
                          onPressed: _restart,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.buttonSpacing),
                    Semantics(
                      button: true,
                      label: _isPlaying
                          ? 'Jeda animasi crawl'
                          : 'Putar animasi crawl',
                      child: SizedBox(
                        width: AppDimens.buttonSizeLarge,
                        height: AppDimens.buttonSizeLarge,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: const Color(0xFFFFE81F),
                            size: 38,
                          ),
                          tooltip: _isPlaying ? 'Pause' : 'Play',
                          onPressed: _togglePlayPause,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.buttonSpacing),
                    Semantics(
                      button: true,
                      label: 'Kecepatan pemutaran ${_speed}x',
                      child: SizedBox(
                        height: AppDimens.buttonSizeLarge,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(AppDimens.buttonSizeLarge,
                                AppDimens.buttonSizeLarge),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _cycleSpeed,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE81F).withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFE81F).withAlpha(160),
                              ),
                            ),
                            child: Text(
                              '${_speed}x',
                              style: const TextStyle(
                                color: Color(0xFFFFE81F),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarWarsCrawlView extends StatefulWidget {
  final String title;
  final int episodeId;
  final String openingCrawl;
  final double height;
  final VoidCallback? onFullscreen;

  const StarWarsCrawlView({
    super.key,
    required this.title,
    required this.episodeId,
    required this.openingCrawl,
    this.height = 290,
    this.onFullscreen,
  });

  @override
  State<StarWarsCrawlView> createState() => _StarWarsCrawlViewState();
}

class _StarWarsCrawlViewState extends State<StarWarsCrawlView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
        _isPlaying = false;
      } else {
        _controller.forward();
        _isPlaying = true;
      }
    });
  }

  void _replay() {
    _controller.reset();
    _controller.forward();
    setState(() {
      _isPlaying = true;
    });
  }

  String _toRoman(int num) {
    switch (num) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      case 5:
        return 'V';
      case 6:
        return 'VI';
      default:
        return num.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFE81F).withAlpha(160),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _StarfieldPainter(),
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  final delta = -(details.primaryDelta ?? 0.0) / (widget.height * 1.8);
                  _controller.value =
                      (_controller.value + delta).clamp(0.0, 1.0);
                },
                onVerticalDragEnd: (_) {
                  if (_isPlaying) {
                    _controller.forward();
                  }
                },
                child: ClipRect(
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0028)
                      ..rotateX(0.86),
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final progress = _controller.value;
                          final startY = widget.height * 0.95;
                          final endY = -widget.height * 2.5;
                          final dy = startY + (endY - startY) * progress;
                          return Transform.translate(
                            offset: Offset(0, dy),
                            child: child,
                          );
                        },
                        child: Center(
                          child: OverflowBox(
                            minHeight: 0,
                            maxHeight: double.infinity,
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 340,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'EPISODE ${_toRoman(widget.episodeId)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFFE81F),
                                      fontSize: AppDimens.captionSmall,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.title.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFFE81F),
                                      fontSize: AppDimens.textMain,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    widget.openingCrawl.replaceAll('\r\n', '\n'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFFE81F),
                                      fontSize: AppDimens.captionSmall,
                                      fontWeight: FontWeight.w700,
                                      height: 1.45,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: widget.height * 0.35,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black87,
                        Colors.black38,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.45, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 35,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(200),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFE81F).withAlpha(140),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_in_ar,
                        size: 13, color: Color(0xFFFFE81F)),
                    SizedBox(width: 4),
                    Text(
                      '3D CRAWL',
                      style: TextStyle(
                        color: Color(0xFFFFE81F),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    button: true,
                    label: _isPlaying
                        ? 'Jeda animasi crawl'
                        : 'Putar animasi crawl',
                    child: Container(
                      width: AppDimens.buttonSize,
                      height: AppDimens.buttonSize,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFE81F).withAlpha(120),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: _isPlaying ? 'Pause' : 'Play',
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFFFFE81F),
                          size: AppDimens.iconSize,
                        ),
                        onPressed: _togglePlay,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.buttonSpacing),
                  Semantics(
                    button: true,
                    label: 'Ulangi crawl',
                    child: Container(
                      width: AppDimens.buttonSize,
                      height: AppDimens.buttonSize,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFE81F).withAlpha(120),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: 'Restart',
                        icon: const Icon(
                          Icons.replay,
                          color: Color(0xFFFFE81F),
                          size: AppDimens.iconSize,
                        ),
                        onPressed: _replay,
                      ),
                    ),
                  ),
                  if (widget.onFullscreen != null) ...[
                    const SizedBox(width: AppDimens.buttonSpacing),
                    Semantics(
                      button: true,
                      label: 'Tampilan layar penuh crawl',
                      child: Container(
                        width: AppDimens.buttonSize,
                        height: AppDimens.buttonSize,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFE81F).withAlpha(120),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Fullscreen',
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Color(0xFFFFE81F),
                            size: AppDimens.iconSize,
                          ),
                          onPressed: widget.onFullscreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  static final List<_Star> _stars = List.generate(120, (i) {
    final random = math.Random(i * 17);
    return _Star(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: random.nextDouble() * 1.5 + 0.4,
      alpha: random.nextInt(170) + 70,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      paint.color = Colors.white.withAlpha(star.alpha);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final int alpha;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
  });
}
