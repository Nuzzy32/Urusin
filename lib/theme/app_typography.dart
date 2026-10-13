import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle pj({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  FontStyle? fontStyle,
  TextDecoration? decoration,
}) => GoogleFonts.plusJakartaSans(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  letterSpacing: letterSpacing,
  height: height,
  fontStyle: fontStyle,
  decoration: decoration,
);

class AppTypography {
  static TextTheme textTheme() => GoogleFonts.plusJakartaSansTextTheme();
}
