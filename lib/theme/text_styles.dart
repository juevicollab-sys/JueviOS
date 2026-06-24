import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class JueviText {
  static TextStyle pageTitle({double size = 32}) => GoogleFonts.barlowCondensed(
    fontSize: size,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    color: JueviColors.carmesim,
  );

  static TextStyle body({double size = 14, Color? color}) => GoogleFonts.dmSans(
    fontSize: size,
    color: color ?? JueviColors.chumbo,
  );

  static TextStyle bodyBold({double size = 14, Color? color}) => GoogleFonts.dmSans(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color ?? JueviColors.chumbo,
  );

  static TextStyle label({double size = 12, Color? color}) => GoogleFonts.dmSans(
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color ?? JueviColors.chumbo.withOpacity(0.6),
  );

  static TextStyle accent({double size = 18, Color? color}) => GoogleFonts.barlowCondensed(
    fontSize: size,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: color ?? JueviColors.chumbo,
  );
}
