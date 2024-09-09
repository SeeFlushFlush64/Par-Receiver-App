import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final validator;
  final decoration;
  final leadingIcon;
  final Widget? suffixIcon;
  // final VoidCallback;
  // onTogglePasswordVisibility; // Callback for toggling password visibility

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.decoration,
    required this.suffixIcon, this.leadingIcon,
    // this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: leadingIcon,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          suffixIcon: suffixIcon,
          // suffixIcon: obscureText
          //     ? IconButton(
          //         icon: Icon(Icons.visibility),
          //         onPressed: onTogglePasswordVisibility,
          //       )
          //     : IconButton(
          //         icon: Icon(Icons.visibility_off),
          //         onPressed: onTogglePasswordVisibility,
          //       ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}
