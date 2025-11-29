import 'package:flutter/material.dart';

typedef PanStart = void Function(DragStartDetails details);
typedef PanUpdate = void Function(DragUpdateDetails details);
typedef PanEnd = void Function(List<int> list, Offset details);
typedef MultiSelectWidgetBuilder =
    Widget Function(BuildContext context, int index, bool selected);

class MultiSelectGridView extends StatefulWidget {
  const MultiSelectGridView({
    super.key,
    this.padding = const EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    required this.onPanEnd,
    required this.onPanUpdate,
    required this.onPanStart,
  });

  final PanUpdate onPanUpdate;
  final PanStart onPanStart;
  final PanEnd onPanEnd;
  final EdgeInsetsGeometry padding;
  final int itemCount;
  final MultiSelectWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;

  @override
  MultiSelectGridViewState createState() => MultiSelectGridViewState();
}

class MultiSelectGridViewState extends State<MultiSelectGridView> {
  final _elements = <_MultiSelectChildElement>[];
  final List<int> selectedItems = [];

  bool _isSelecting = false;
  int _startIndex = -1;
  int _endIndex = -1;
  int _lastSelected = -1;
  Offset endDetails = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: GridView.builder(
        padding: widget.padding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          final isSelected =
              selectedItems.contains(index) &&
              (_startIndex != -1 && _endIndex != -1);
          return _MultiSelectChild(
            index: index,
            child: widget.itemBuilder(context, index, isSelected),
          );
        },
        gridDelegate: widget.gridDelegate,
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    final index = _findMultiSelectChildFromOffset(event.localPosition);
    _setSelection(index, index);
    widget.onPanStart(DragStartDetails(globalPosition: event.position));
    setState(() => _isSelecting = index != -1);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_isSelecting) {
      _findMultiSelectChildFromOffset(event.localPosition);
      endDetails = event.position;
      widget.onPanUpdate(DragUpdateDetails(globalPosition: event.position));
      setState(() {});
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    widget.onPanEnd(selectedItems, endDetails);
    selectedItems.clear();
    _lastSelected = -1;
    setState(() => _isSelecting = false);
  }

  void _setSelection(int start, int end) {
    _startIndex = start;
    _endIndex = end;
  }

  int _findMultiSelectChildFromOffset(Offset offset) {
    final ancestor = context.findRenderObject();
    if (ancestor == null) return -1;

    for (final element in _elements) {
      if (element.containsOffset(ancestor, offset) &&
          _lastSelected != element.widget.index) {
        if (selectedItems.contains(element.widget.index)) {
          while (selectedItems.isNotEmpty &&
              selectedItems.last != element.widget.index) {
            selectedItems.removeLast();
          }
        } else {
          selectedItems.add(element.widget.index);
        }

        _lastSelected = element.widget.index;
        return element.widget.index;
      }
    }
    return -1;
  }
}

class _MultiSelectChild extends ProxyWidget {
  const _MultiSelectChild({required this.index, required super.child});
  final int index;

  @override
  _MultiSelectChildElement createElement() => _MultiSelectChildElement(this);
}

class _MultiSelectChildElement extends ProxyElement {
  _MultiSelectChildElement(_MultiSelectChild super.widget);

  MultiSelectGridViewState? _ancestorState;

  @override
  _MultiSelectChild get widget => super.widget as _MultiSelectChild;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _ancestorState = findAncestorStateOfType<MultiSelectGridViewState>();
    _ancestorState?._elements.add(this);
  }

  @override
  void unmount() {
    _ancestorState?._elements.remove(this);
    super.unmount();
  }

  bool containsOffset(RenderObject ancestor, Offset offset) {
    final box = renderObject as RenderBox;
    final rect = box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
    return rect.contains(offset);
  }

  @override
  void notifyClients(covariant ProxyWidget oldWidget) {}
}
