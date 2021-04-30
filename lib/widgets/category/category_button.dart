import 'package:flutter/material.dart';

class CategoryButton extends StatefulWidget {
  final String text;
  final Color color;
  final double size;

  CategoryButton({
    this.text,
    this.color,
    this.size,
  });

  @override
  _CategoryButtonState createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool _selection = false;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: widget.color.withOpacity(0.8),
        child: InkResponse(
          onTap: () {
            setState(() {
              _selection = !_selection;
            });
          },
          highlightShape: BoxShape.circle,
          radius: widget.size,
          child: Container(
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'PT_Serif',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
            ),
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size),
              border:
                  _selection ? Border.all(width: 5, color: Colors.white) : null,
            ),
          ),
        ),
      ),
    );
  }
}
