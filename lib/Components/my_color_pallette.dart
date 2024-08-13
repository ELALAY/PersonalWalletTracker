import 'package:flutter/material.dart';

class ColorPalette extends StatefulWidget {
  final List<Color> colors;
  final Function(Color) onColorSelected;

  const ColorPalette({
    Key? key,
    required this.colors,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  ColorPaletteState createState() => ColorPaletteState();
}

class ColorPaletteState extends State<ColorPalette> {
  Color? _selectedColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: widget.colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
            widget.onColorSelected(color);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: _selectedColor == color ? Colors.black : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
