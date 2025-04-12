import 'package:flutter/material.dart';

/// A simple, reliable tree view for displaying repost-style content
/// This implementation avoids common layout pitfalls and overflow issues
class SimpleRepostTreeView extends StatelessWidget {
  /// The list of child widgets to display in the tree
  final List<Widget> children;

  /// Line properties
  final double lineWidth;
  final Color lineColor;
  final double indentation;
  final double heigh;

  const SimpleRepostTreeView({
    super.key,
    required this.children,
    this.lineWidth = 2.0,
    this.heigh = 100,
    this.lineColor = Colors.grey,
    this.indentation = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        // Root/parent node (original post)
        children.first,

        // Child nodes with connection lines
        for (int i = 1; i < children.length; i++)
          ConnectedNode(
            heigh: heigh,
            lineColor: lineColor,
            lineWidth: lineWidth,
            indentation: indentation,
            isLast: i == children.length - 1,
            child: children[i],
          ),
      ],
    );
  }
}

/// A node connected to a vertical tree line
class ConnectedNode extends StatelessWidget {
  final Widget child;
  final bool isLast;
  final Color lineColor;
  final double lineWidth;
  final double indentation;
  final double heigh;

  const ConnectedNode({
    super.key,
    required this.child,
    required this.isLast,
    required this.lineColor,
    required this.lineWidth,
    required this.heigh,
    required this.indentation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The child content with padding to make room for the line
        Padding(padding: EdgeInsets.only(left: indentation), child: child),

        // The connection line
        SizedBox(
          width: indentation,
          height: heigh, // Fixed height for the connecting line
          child: CustomPaint(
            painter: ConnectionLinePainter(
              isLast: isLast,
              lineWidth: lineWidth,
              lineColor: lineColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws the connection line
class ConnectionLinePainter extends CustomPainter {
  final bool isLast;
  final double lineWidth;
  final Color lineColor;

  ConnectionLinePainter({required this.isLast, required this.lineWidth, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final double centerX = size.width * 0.5;
    final double horizontalLineY = size.height * 0.5;

    final path = Path();

    // Start from the top center
    path.moveTo(centerX, 0);

    // Draw line down to the horizontal branch point
    path.lineTo(centerX, horizontalLineY);

    // Draw horizontal line to the right
    path.lineTo(size.width, horizontalLineY);

    // If not the last node, continue the vertical line down
    if (!isLast) {
      path.moveTo(centerX, horizontalLineY);
      path.lineTo(centerX, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ConnectionLinePainter oldDelegate) {
    return oldDelegate.isLast != isLast ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.lineColor != lineColor;
  }
}

/// Alternative tree view implementation without using ListView
/// Use this if you need to place the tree inside a column or other container
class ColumnRepostTreeView extends StatelessWidget {
  final List<Widget> children;
  final double lineWidth;
  final Color lineColor;
  final double indentation;
  final double heigh;

  const ColumnRepostTreeView({
    super.key,
    required this.children,
    this.lineWidth = 2.0,
    this.lineColor = Colors.grey,
    this.indentation = 24.0,
    this.heigh = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Root node
        children.first,

        // Connected child nodes
        for (int i = 1; i < children.length; i++)
          ConnectedNode(
            heigh: heigh,
            lineColor: lineColor,
            lineWidth: lineWidth,
            indentation: indentation,
            isLast: i == children.length - 1,
            child: children[i],
          ),
      ],
    );
  }
}
