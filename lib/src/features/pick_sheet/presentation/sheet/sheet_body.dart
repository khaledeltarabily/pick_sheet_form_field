import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The sheet's content: [top] and [bottom] at their natural heights, and
/// [list] in the space between them.
///
/// The list is never shorter than [minListHeight]. When the sheet is too
/// short for that (landscape or a small phone with the keyboard up), the
/// content becomes taller than the sheet and scrolls as a whole instead of
/// overflowing. With enough room it lays out like a `Column` with an
/// `Expanded` list, and nothing scrolls.
///
/// Rebuilding this widget with the same [top], [list] and [bottom] instances
/// doesn't rebuild them, so it can sit under a keyboard-driven `LayoutBuilder`.
class SheetBody extends StatelessWidget {
  /// Creates the sheet content.
  const SheetBody({
    super.key,
    required this.top,
    required this.list,
    required this.bottom,
    this.minListHeight = 160,
  });

  /// The parts above the list (header, search, toolbar).
  final Widget top;

  /// The list. It gets a tight height.
  final Widget list;

  /// The part below the list (confirm button).
  final Widget bottom;

  /// The least height the list gets.
  final double minListHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: _SheetBodyLayout(
          viewportHeight: constraints.maxHeight,
          minListHeight: minListHeight,
          children: [top, list, bottom],
        ),
      ),
    );
  }
}

class _SheetBodyLayout extends MultiChildRenderObjectWidget {
  const _SheetBodyLayout({
    required this.viewportHeight,
    required this.minListHeight,
    required super.children,
  });

  final double viewportHeight;
  final double minListHeight;

  @override
  _RenderSheetBody createRenderObject(BuildContext context) => _RenderSheetBody(
    viewportHeight: viewportHeight,
    minListHeight: minListHeight,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderSheetBody renderObject) {
    renderObject
      ..viewportHeight = viewportHeight
      ..minListHeight = minListHeight;
  }
}

class _SheetBodyParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSheetBody extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SheetBodyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SheetBodyParentData> {
  _RenderSheetBody({
    required double viewportHeight,
    required double minListHeight,
  }) : _viewportHeight = viewportHeight,
       _minListHeight = minListHeight;

  double get viewportHeight => _viewportHeight;
  double _viewportHeight;
  set viewportHeight(double value) {
    if (value == _viewportHeight) return;
    _viewportHeight = value;
    markNeedsLayout();
  }

  double get minListHeight => _minListHeight;
  double _minListHeight;
  set minListHeight(double value) {
    if (value == _minListHeight) return;
    _minListHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SheetBodyParentData) {
      child.parentData = _SheetBodyParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final top = firstChild!;
    final list = childAfter(top)!;
    final bottom = childAfter(list)!;

    // Like a Column with the default cross-axis alignment: children may be
    // narrower than the sheet and are centered.
    final loose = BoxConstraints(maxWidth: width);
    top.layout(loose, parentUsesSize: true);
    bottom.layout(loose, parentUsesSize: true);
    final listHeight = math.max(
      minListHeight,
      viewportHeight - top.size.height - bottom.size.height,
    );
    list.layout(
      BoxConstraints(
        maxWidth: width,
        minHeight: listHeight,
        maxHeight: listHeight,
      ),
      parentUsesSize: true,
    );

    var y = 0.0;
    for (final child in [top, list, bottom]) {
      (child.parentData! as _SheetBodyParentData).offset = Offset(
        (width - child.size.width) / 2,
        y,
      );
      y += child.size.height;
    }
    size = constraints.constrain(Size(width, y));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
