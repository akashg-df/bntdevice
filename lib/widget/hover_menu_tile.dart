
import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class HoverDrawerTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HoverDrawerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<HoverDrawerTile> createState() => _HoverDrawerTileState();
}

class _HoverDrawerTileState extends State<HoverDrawerTile> {
  bool _isHovered = false;

  void _setHover(bool value) {
    if (_isHovered != value) {
      setState(() => _isHovered = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setHover(true),  // Simulate hover on touch down
        onTapUp: (_) => _setHover(false),   // Remove hover after tap
        onTapCancel: () => _setHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _isHovered ? buttonHover.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 25,
                color: _isHovered ? buttonNavy : secText,
              ),
              const SizedBox(width: 8),
              TextWidget(
                text: widget.label,
                fontWeight: semiBold,
                color: secText,
                fontsize: bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


