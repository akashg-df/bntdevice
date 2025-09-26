
import 'package:dfdevicewebview/typography.dart';
import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  TextEditingController? controller;
  bool isValidatorEnable, enabled, isOnTapEnable;
  String? Function(String?)? validator;
  String? Function(String?)? onSaved;
  IconData? prefixIcon;
  String? hintText;
  void Function()? onTap;

  InputTextField({
    super.key,
    this.controller,
    this.isValidatorEnable = false,
    this.enabled = false,
    this.isOnTapEnable = false,
    this.validator,
    this.onSaved,
    this.prefixIcon,
    this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: isValidatorEnable ? validator : null,
      onSaved: onSaved,
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(
        fontSize: bodyMedium,
        fontWeight: normal,
      ),
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        prefixIcon: Icon(prefixIcon, size: 20),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: bodyMedium,
          fontWeight: normal,
        ),
      ),
      onTap: isOnTapEnable ? onTap : null,
    );
  }
}