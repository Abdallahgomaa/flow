import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A unified, theme-driven text field used across the whole application.
///
/// Wraps [TextFormField] and reads its look from `InputDecorationTheme`, so the
/// design system stays in charge of borders, radii and colors.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autovalidateMode,
    this.obscureToggleTooltip,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either a controller or an initialValue, not both.',
       );

  /// External controller. Mutually exclusive with [initialValue].
  final TextEditingController? controller;

  /// Uncontrolled initial text. Mutually exclusive with [controller].
  final String? initialValue;

  /// Already-localised field label.
  final String? label;

  /// Already-localised placeholder.
  final String? hint;

  /// Already-localised helper text shown below the field.
  final String? helperText;

  /// External error text; when set it overrides the validator message.
  final String? errorText;

  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? prefixText;
  final String? suffixText;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// When `true` the input is masked and a visibility toggle is added.
  final bool obscureText;

  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;

  /// Already-localised tooltip for the obscure toggle (accessibility).
  final String? obscureToggleTooltip;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.obscureText && _obscured,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      autovalidateMode: widget.autovalidateMode,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: _buildSuffixIcon(),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    final List<Widget> icons = <Widget>[
      if (widget.suffixIcon != null) Icon(widget.suffixIcon),
      if (widget.obscureText)
        IconButton(
          onPressed: () => setState(() => _obscured = !_obscured),
          tooltip: widget.obscureToggleTooltip,
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
    ];

    return switch (icons.length) {
      0 => null,
      1 => icons.first,
      _ => Row(mainAxisSize: MainAxisSize.min, children: icons),
    };
  }
}
