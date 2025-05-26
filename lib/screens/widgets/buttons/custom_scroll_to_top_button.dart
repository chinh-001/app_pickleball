import 'package:flutter/material.dart';

/// A floating action button that appears when scrolling down and allows
/// quick navigation to the top of a scrollable widget.
class CustomScrollToTopButton extends StatefulWidget {
  /// The scroll controller to monitor scroll position.
  final ScrollController scrollController;

  /// The threshold in pixels after which the button will appear.
  final double scrollThreshold;

  /// Custom button color, defaults to green.
  final Color? backgroundColor;

  /// Custom icon color, defaults to white.
  final Color? iconColor;

  const CustomScrollToTopButton({
    Key? key,
    required this.scrollController,
    this.scrollThreshold = 300,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  State<CustomScrollToTopButton> createState() =>
      _CustomScrollToTopButtonState();
}

class _CustomScrollToTopButtonState extends State<CustomScrollToTopButton>
    with SingleTickerProviderStateMixin {
  bool _showButton = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (widget.scrollController.offset >= widget.scrollThreshold &&
        !_showButton) {
      setState(() {
        _showButton = true;
        _animationController.forward();
      });
    } else if (widget.scrollController.offset < widget.scrollThreshold &&
        _showButton) {
      setState(() {
        _showButton = false;
        _animationController.reverse();
      });
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        heroTag: 'scrollToTopFab',
        onPressed: _scrollToTop,
        backgroundColor: widget.backgroundColor ?? Colors.green,
        mini: true,
        child: Icon(
          Icons.keyboard_arrow_up,
          color: widget.iconColor ?? Colors.white,
        ),
      ),
    );
  }
}
