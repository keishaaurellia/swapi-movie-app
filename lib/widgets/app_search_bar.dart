import 'package:flutter/material.dart';
import '../data/config/app_colors.dart';
import '../data/config/app_dimens.dart';
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsetsGeometry? margin;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search title or director...',
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.margin,
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _effectiveController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    final ctrl = widget.controller;
    if (ctrl == null) {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    } else {
      _effectiveController = ctrl;
    }
    _effectiveController.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChange);
      final newCtrl = widget.controller;
      if (newCtrl == null) {
        _effectiveController = TextEditingController();
        _isInternalController = true;
      } else {
        if (_isInternalController) {
          _effectiveController.dispose();
          _isInternalController = false;
        }
        _effectiveController = newCtrl;
      }
      _effectiveController.addListener(_handleTextChange);
    }
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearSearch() {
    _effectiveController.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChange);
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget searchWidget = TextField(
      controller: _effectiveController,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: const TextStyle(
        fontSize: AppDimens.textMain,
        color: AppColors.deepSlate,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppColors.lightSlate,
          fontSize: AppDimens.captionSmall,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.teal,
          size: 20,
        ),
        suffixIcon: _effectiveController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: 18,
                  color: AppColors.slate,
                ),
                tooltip: 'Clear search',
                onPressed: _clearSearch,
              )
            : null,
        fillColor: AppColors.surface,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryYellow,
            width: 2,
          ),
        ),
      ),
    );

    final margin = widget.margin;
    if (margin != null) {
      return Padding(
        padding: margin,
        child: searchWidget,
      );
    }

    return searchWidget;
  }
}
