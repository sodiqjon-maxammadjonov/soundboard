import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/library/libray.dart';

class MySearchField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;

  const MySearchField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.onChanged,
  });

  @override
  State<MySearchField> createState() => _MySearchFieldState();
}

class _MySearchFieldState extends State<MySearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: CupertinoTextField(
        controller: widget.controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        onChanged: widget.onChanged,
        placeholder: widget.placeholder,

        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
        ),
        placeholderStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),

        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.card,
            width: 1,
          ),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

        prefix: null,

        suffix: widget.controller.text.isNotEmpty
            ? Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                        onTap: () {
              widget.controller.clear();
              widget.onChanged?.call("");
                        },
                        child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.textSecondary,
              size: 20,
                        ),
                      ),
            )
            : null,
      ),
    );
  }
}
