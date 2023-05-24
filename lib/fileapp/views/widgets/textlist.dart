import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:xview/utils/log.dart';

// If we were to use the default `ListView`, the app would 'hang' during rapid
// scrolling, see:
// https://github.com/flutter/flutter/issues/75399
//
// To avoid this issue, we have defined our own custom `TextList`
class TextList extends BoxScrollView {
  final int Function(int) itemTextCount;
  final Function(String)? layoutNotifier;

  TextList.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.shrinkWrap,
    super.padding,
    required NullableIndexedWidgetBuilder itemBuilder,
    required this.itemTextCount,
    this.layoutNotifier,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    super.cacheExtent,
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  })  : childrenDelegate = _TextListBuilderDelegate(
          itemBuilder,
          itemTextCount: itemTextCount,
          layoutNotifier: layoutNotifier,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          semanticChildCount: semanticChildCount ?? itemCount,
        );

  final SliverChildDelegate childrenDelegate;

  @override
  Widget buildChildLayout(BuildContext context) {
    return _CustomSliverList(delegate: childrenDelegate);
  }
}

class _TextListBuilderDelegate extends SliverChildBuilderDelegate {
  final int Function(int) itemTextCount;
  final Function(String)? layoutNotifier;

  const _TextListBuilderDelegate(super.builder,
      {required this.itemTextCount,
      this.layoutNotifier,
      super.findChildIndexCallback,
      super.childCount,
      super.addAutomaticKeepAlives,
      super.addRepaintBoundaries,
      super.addSemanticIndexes});
}

/// [SliverList]
class _CustomSliverList extends SliverMultiBoxAdaptorWidget {
  const _CustomSliverList({required super.delegate});

  @override
  SliverMultiBoxAdaptorElement createElement() {
    return SliverMultiBoxAdaptorElement(this);
  }

  @override
  RenderSliverMultiBoxAdaptor createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return _CustomRenderSliverList(childManager: element);
  }
}

class _CustomRenderSliverList extends RenderSliverMultiBoxAdaptor {
  // we assume that font size is not change
  double? estimatedCharWidth;
  double? estimatedCharHeight;

  _CustomRenderSliverList({required super.childManager});

  void estimateSingleCharSize() {
    if (estimatedCharWidth != null && estimatedCharHeight != null) {
      return;
    }

    Size testTextSize(String text) {
      final testRenderObject = RenderParagraph(TextSpan(text: text),
          textDirection: TextDirection.ltr);
      return testRenderObject.computeDryLayout(const BoxConstraints());
    }

    final size = testTextSize("abcd中");

    estimatedCharWidth = size.width / 5;
    estimatedCharHeight = size.height;
  }

  // a helper method to get parent data as ... to make code cleaner
  SliverMultiBoxAdaptorParentData _pd(RenderBox child) {
    return child.parentData as SliverMultiBoxAdaptorParentData;
  }

  _TextListBuilderDelegate _delegate() {
    return (((childManager as SliverMultiBoxAdaptorElement).widget
            as SliverMultiBoxAdaptorWidget)
        .delegate as _TextListBuilderDelegate);
  }

  double _estimateHeightAtIndex(int index) {
    final maxWidth = constraints.asBoxConstraints().maxWidth;
    // tricky

    if (maxWidth.isInfinite) {
      return estimatedCharHeight!;
    }

    // it seems like there's room for optimazition, but I'm not entirely certain
    // if it's necessary
    int countPerLine = (maxWidth / estimatedCharWidth!).round();
    int textCount = _delegate().itemTextCount(index);
    int lineCount = (textCount / countPerLine).round() + 1;

    return lineCount * estimatedCharHeight!;
  }

  double _estimateChildHeight(RenderBox child) {
    if (child.hasSize) {
      return child.size.height;
    }
    final pd = _pd(child);
    if (pd.index == null) {
      return estimatedCharHeight!;
    }
    return _estimateHeightAtIndex(pd.index!);
  }

  double _estimateOffsetAtIndex(int index) {
    if (index == 0) {
      return 0;
    }

    int? first;
    int? last;
    if (firstChild != null) {
      first = _pd(firstChild!).index;
      last = _pd(lastChild!).index;
    }
    if (first != null && last != null && index >= first && index <= last) {
      var child = firstChild;
      while (child != null) {
        final pd = _pd(child);
        if (pd.index != null && pd.index == index) {
          return pd.layoutOffset!;
        }
        child = childAfter(child);
      }
    }

    int baseIndex = 0;
    double baseOffset = 0;
    if (first != null && index < first) {
      baseIndex = first;
      baseOffset = _pd(firstChild!).layoutOffset!;
    } else if (last != null && index > last) {
      baseIndex = last;
      baseOffset = _pd(lastChild!).layoutOffset!;
    }

    if ((baseIndex - index).abs() > 2000) {
      return baseOffset + (index - baseIndex) * estimatedCharHeight!;
    }

    int step = index > baseIndex ? 1 : -1;
    while (baseIndex != index) {
      baseIndex = baseIndex + step;
      baseOffset += step * _estimateHeightAtIndex(baseIndex);
    }
    return baseOffset;
  }

  int _estimateIndexAtOffset(double offset) {
    if (offset == 0.0) {
      return 0;
    }

    double? first;
    double? last;
    if (firstChild != null) {
      first = _pd(firstChild!).layoutOffset;
      last = _pd(lastChild!).layoutOffset;
    }
    if (first != null && last != null && offset >= first && offset <= last) {
      var child = firstChild;
      while (child != null) {
        final pd = _pd(child);
        if (offset >= pd.layoutOffset!) {
          return pd.index!;
        }
      }
    }

    int baseIndex = 0;
    double baseOffset = 0;
    if (first != null && offset < first) {
      baseOffset = first;
      baseIndex = _pd(firstChild!).index!;
    } else if (last != null && offset > last) {
      baseOffset = last;
      baseIndex = _pd(lastChild!).index!;
    }

    if ((offset - baseOffset).abs() > (2000 * estimatedCharHeight!)) {
      return baseIndex + ((offset - baseOffset) / estimatedCharHeight!).round();
    }

    int step = offset > baseOffset ? 1 : -1;
    while (((offset - baseOffset) * step) > 0) {
      baseOffset += step * (_estimateHeightAtIndex(baseIndex));
      baseIndex += step;
    }

    return baseIndex - 1;
  }

  int? _collectFarAwayGarbage2(double scrollStart, double scrollEnd) {
    bool isFarAwayForward(RenderBox child) {
      final pd = _pd(child);
      if (pd.layoutOffset == null) {
        // why widget has no layout offset ?
        return true;
      }

      return (pd.layoutOffset! + _estimateChildHeight(child)) <
          (scrollStart - 250);
    }

    bool isFarAwayBackward(RenderBox child) {
      final pd = _pd(child);
      if (pd.layoutOffset == null) {
        // why widget has no layout offset ?
        return true;
      }

      return pd.layoutOffset! > (scrollEnd + 250);
    }

    if (firstChild == null) {
      return _estimateIndexAtOffset(scrollStart);
    }

    int leading = 0;
    int trailing = 0;
    var child = firstChild;
    while (child != null && isFarAwayForward(child)) {
      leading += 1;
      child = childAfter(child);
    }

    // to avoid deleting a node more than once, we're removing it from just one side
    if (leading == 0) {
      child = lastChild;
      while (child != null && isFarAwayBackward(child)) {
        trailing += 1;
        child = childBefore(child);
      }
    }
    textlistLog.info(
        'collect garbage. child count: $childCount, $leading ~ $trailing');

    int? index;
    if (leading + trailing == childCount) {
      index = _estimateIndexAtOffset(scrollStart);
      textlistLog.info("layout firstChild at index: $index");
    }
    collectGarbage(leading, trailing);
    return index;
  }

  /// return false if can't create the first child
  bool ensureFirstChild(double offset, int? prefreIndex) {
    if (firstChild == null) {
      return addInitialChild(index: prefreIndex!, layoutOffset: offset);
    }

    return true;
  }

  SliverConstraints? preConstraints;
  bool isIndexVisible(int index) {
    if (firstChild == null) {
      return false;
    }
    final firstPd = _pd(firstChild!);
    final lastPd = _pd(lastChild!);
    if ((firstPd.index == null || index < firstPd.index!) ||
        (lastPd.index == null || index > lastPd.index!)) {
      return false;
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = _pd(child);
      if (pd.index == index) {
        return pd.layoutOffset == null
            ? false
            : isOffsetVisiableOnLastLayout(pd.layoutOffset!);
      } else {
        child = childAfter(child);
      }
    }
    return false;
  }

  // make `index` at center position if possible
  double _layoutTargetAtCenter(int targetIndex) {
    double offset = _estimateOffsetAtIndex(targetIndex);
    collectGarbage(childCount, 0);
    addInitialChild(index: targetIndex, layoutOffset: offset);

    double extent = constraints.remainingPaintExtent / 2;
    while (extent > 0) {
      final child = insertAndLayoutLeadingChild(constraints.asBoxConstraints(),
          parentUsesSize: true);
      if (child == null) {
        return 0;
      }

      offset -= child.size.height;
      extent -= child.size.height;

      if (offset < 0) {
        return 0;
      }

      final pd = _pd(child);
      pd.layoutOffset = offset;

      if (extent <= 0) {
        return offset;
      }
    }
    return 0;
  }

  SliverGeometry correctToVisiableIndex(int index) {
    // if we're asked to scroll to a specific index, usually it's triggered by a scroll event...
    // (though there may be some exceptional cases which we're ignoring for now)
    //
    // (note that if we actually encounter exceptional cases, we might want to go to index 0 instead of
    // throwing exceptions)
    assert(preConstraints != null);
    assert(firstChild != null);
    assert(lastChild != null);

    textlistLog.info('receive request to go to index: $index');

    if (isIndexVisible(index)) {
      // if the target index is already visible, we may want the list to appear unscrolled.
      // in this case, we can instruct the viewport to correct the offset to the previous
      // scroll offset
      textlistLog.info('index $index is visiable, keep previous scroll offset');
      return SliverGeometry(
          scrollOffsetCorrection:
              preConstraints!.scrollOffset - constraints.scrollOffset);
    }

    final targetOffset = _layoutTargetAtCenter(index);
    final correct = targetOffset - constraints.scrollOffset;
    textlistLog.info(
        'layout $index at center with target offset: $targetOffset. correct: $correct');

    return SliverGeometry(scrollOffsetCorrection: correct);
  }

  bool isOffsetVisiableOnLastLayout(double offset) {
    if (preConstraints == null) {
      return false;
    }
    // 1. > -cacheOrigin
    // 2. > offset + cache Origin
    final minOffset = max(-preConstraints!.cacheOrigin,
            preConstraints!.scrollOffset + preConstraints!.cacheOrigin) +
        25;
    // ensure 50 piexls, then we can see something
    final maxOffset = minOffset + preConstraints!.remainingPaintExtent - 50;

    return offset > minOffset && offset < maxOffset;
  }

  SliverGeometry correctToRestorePosition(double lf, int fli, double flo) {
    textlistLog.info(
        'request to restore position. layoutOffset: $lf, firstLayoutIndex: $fli, firstLayoutOffset: $flo');
    collectGarbage(childCount, 0);
    addInitialChild(index: fli, layoutOffset: flo);
    return SliverGeometry(
        scrollOffsetCorrection: flo - constraints.scrollOffset);
  }

  SliverGeometry? customCorrection() {
    final scrollOffset = constraints.scrollOffset;
    int? visiableIndex = decodeVisiableIndex(scrollOffset);
    if (visiableIndex != null) {
      return correctToVisiableIndex(visiableIndex);
    }

    // with cache origin?
    (double, int, double)? position = decodeRestorePosition(scrollOffset);
    if (position != null) {
      return correctToRestorePosition(position.$1, position.$2, position.$3);
    }

    return null;
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);
    estimateSingleCharSize();

    textlistLog.info(
        'offset-> ${constraints.scrollOffset}, cacheOrigin: ${constraints.cacheOrigin}, prev -> ${preConstraints?.scrollOffset}');

    final correct = customCorrection();
    if (correct != null) {
      geometry = correct;
      return;
    }
    preConstraints = constraints;

    _layout();
  }

  /// referenced from
  ///
  /// [RenderSliverList.performLayout]
  void _layout() {
    final SliverConstraints constraints = this.constraints;
    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    final double remainingExtent = constraints.remainingCacheExtent;
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    // clear the widiget that is far away from our current scroll range,
    // then we know `firstChild` is not far away layout range if it is exists
    // By removing any widget that is outside of our current scroll range, we can confirm
    // that `firstChild` is within the layout range or close to it (assuming it exists)
    int? preferIndex =
        _collectFarAwayGarbage2(scrollOffset, targetEndScrollOffset);

    // create first child (if not exists) at target scroll offset
    if (!ensureFirstChild(scrollOffset, preferIndex)) {
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }

    final BoxConstraints childConstraints = constraints.asBoxConstraints();
    RenderBox? leadingChildWithLayout, trailingChildWithLayout;
    RenderBox? earliestUsefulChild = firstChild;
    for (double earliestScrollOffset = childScrollOffset(earliestUsefulChild!)!;
        earliestScrollOffset > scrollOffset;
        earliestScrollOffset = childScrollOffset(earliestUsefulChild)!) {
      earliestUsefulChild =
          insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
      if (earliestUsefulChild == null) {
        // no more children now... so we make firstChild at 0.0
        final SliverMultiBoxAdaptorParentData parentData =
            firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
        parentData.layoutOffset = 0.0;

        if (scrollOffset == 0.0) {
          // make `firstChild` at zero position, then we layout from `firstChild`
          firstChild!.layout(childConstraints, parentUsesSize: true);
          earliestUsefulChild = firstChild;
          leadingChildWithLayout = earliestUsefulChild;
          trailingChildWithLayout ??= earliestUsefulChild;
          break;
        } else {
          // we have no more children to fill the scroll range.. viewport need to ajust
          // the scroll offset
          geometry = SliverGeometry(scrollOffsetCorrection: -scrollOffset);
          return;
        }
      }

      final double firstChildScrollOffset =
          earliestScrollOffset - paintExtentOf(firstChild!);
      // the left sapce it too small to layout another children, just
      // let viewport adjust scroll offset, then current children can be laied out at
      // 0.0
      if (firstChildScrollOffset < -precisionErrorTolerance) {
        geometry =
            SliverGeometry(scrollOffsetCorrection: -firstChildScrollOffset);
        final SliverMultiBoxAdaptorParentData childParentData =
            firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
        childParentData.layoutOffset = 0.0;
        return;
      }

      final SliverMultiBoxAdaptorParentData parentData =
          earliestUsefulChild.parentData! as SliverMultiBoxAdaptorParentData;
      parentData.layoutOffset = firstChildScrollOffset;
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout ??= earliestUsefulChild;
    }

    if (scrollOffset < precisionErrorTolerance) {
      if (indexOf(firstChild!) == 0 && childScrollOffset(firstChild!) != 0) {
        textlistLog.info('the firstChild index is 0 but the offset is not 0!');
        _pd(firstChild!).index = 0;
        _pd(firstChild!).layoutOffset = 0;
        earliestUsefulChild = firstChild!;
      } else {
        // we have now reached the zero position,
        // it is crucial that the child index 0 laied out at offset 0.0
        while (indexOf(firstChild!) > 0) {
          final double earliestScrollOffset = childScrollOffset(firstChild!)!;
          earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints,
              parentUsesSize: true);
          assert(earliestUsefulChild != null);
          final double firstChildScrollOffset =
              earliestScrollOffset - paintExtentOf(firstChild!);
          final SliverMultiBoxAdaptorParentData childParentData =
              firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
          childParentData.layoutOffset = 0.0;
          if (firstChildScrollOffset < -precisionErrorTolerance) {
            // interrupted state: while the scroll offset has been reached to 0.0, the
            // index has not yet reached to 0
            //
            // geometry = SliverGeometry(
            //   scrollOffsetCorrection: -firstChildScrollOffset,
            // );
            // return;
            textlistLog.info(
                'the scroll offset has been reached to 0. but the index is not 0');
            //TODO:
            _pd(firstChild!).layoutOffset = 0;
            earliestUsefulChild = firstChild!;
            break;
          }
        }
      }
    }

    if (leadingChildWithLayout == null) {
      earliestUsefulChild!.layout(childConstraints, parentUsesSize: true);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout = earliestUsefulChild;
    }

    bool inLayoutRange = true;
    RenderBox? child = earliestUsefulChild;
    int index = indexOf(child!);
    double endScrollOffset = childScrollOffset(child)! + paintExtentOf(child);
    int leadingGarbage = 0;
    int trailingGarbage = 0;
    bool reachedEnd = false;

    bool advance() {
      // returns true if we advanced, false if we have no more children
      // This function is used in two different places below, to avoid code duplication.
      assert(child != null);
      if (child == trailingChildWithLayout) {
        inLayoutRange = false;
      }
      child = childAfter(child!);
      if (child == null) {
        inLayoutRange = false;
      }
      index += 1;
      if (!inLayoutRange) {
        if (child == null || indexOf(child!) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.
          child = insertAndLayoutChild(
            childConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: true,
          );
          if (child == null) {
            // We have run out of children.
            return false;
          }
        } else {
          // Lay out the child.
          child!.layout(childConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      final SliverMultiBoxAdaptorParentData childParentData =
          child!.parentData! as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = endScrollOffset;
      assert(childParentData.index == index);
      endScrollOffset = childScrollOffset(child!)! + paintExtentOf(child!);
      return true;
    }

    // Find the first child that ends after the scroll offset.
    while (endScrollOffset < scrollOffset) {
      leadingGarbage += 1;
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        // we want to make sure we keep the last child around so we know the end scroll offset
        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        final double extent =
            childScrollOffset(lastChild!)! + paintExtentOf(lastChild!);
        geometry = SliverGeometry(
          scrollExtent: extent,
          maxPaintExtent: extent,
        );
        return;
      }
    }

    // Now find the first child that ends after our end.
    while (endScrollOffset < targetEndScrollOffset) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    // Finally count up all the remaining children and label them as garbage.
    if (child != null) {
      child = childAfter(child!);
      while (child != null) {
        trailingGarbage += 1;
        child = childAfter(child!);
      }
    }

    // At this point everything should be good to go, we just have to clean up
    // the garbage and report the geometry.

    collectGarbage(leadingGarbage, trailingGarbage);

    assert(debugAssertChildListIsNonEmptyAndContiguous());
    final double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      final count = _delegate().childCount!;
      final extent = estimatedCharHeight! * count;
      if (endScrollOffset < extent * 0.8) {
        estimatedMaxScrollOffset = extent;
      } else {
        estimatedMaxScrollOffset =
            max(extent, (endScrollOffset / indexOf(lastChild!)) * count);
      }
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: childScrollOffset(firstChild!)!,
      to: endScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: childScrollOffset(firstChild!)!,
      to: endScrollOffset,
    );
    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: endScrollOffset > targetEndScrollOffsetForPaint ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == endScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
    // Do not notify on laying out
    Future(() => notifyLayoutResult());
  }

  notifyLayoutResult() {
    final notifier = _delegate().layoutNotifier;
    if (notifier != null) {
      final pd = _pd(firstChild!);
      notifier(encodeRestorePosition(
          constraints.scrollOffset, pd.index!, pd.layoutOffset!));
    }
  }
}

class NoJumpBallisticController extends ScrollController {
  NoJumpBallisticController({
    super.initialScrollOffset = 0.0,
    super.keepScrollOffset = true,
    super.debugLabel,
  });

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return _Position(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _Position extends ScrollPositionWithSingleContext {
  _Position({
    required super.physics,
    required super.context,
    super.initialPixels = 0.0,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  @override
  void goBallistic(double velocity) {
    if (velocity.abs() < precisionErrorTolerance) {
      super.goIdle();
    } else {
      super.goBallistic(velocity);
    }
  }
}

double encodeVisiableIndex(int index) {
  final s = '0.1111${index.toString().padLeft(7, '0')}1';
  return double.parse(s);
}

int? decodeVisiableIndex(double offset) {
  if (offset > precisionErrorTolerance && offset < 0.2) {
    final s = offset.toString();
    if (s.length == 14 && s.startsWith("0.1111") && s.endsWith('1')) {
      return int.parse(s.substring(6, 13));
    }
  }
  return null;
}

// 4150.16~~~~~.......77
//         gap   index
String encodeRestorePosition(
  double layoutOffset,
  int firstChildIndex,
  double firstChildLayoutOffset,
) {
  assert(layoutOffset >= firstChildLayoutOffset);
  double flo = double.parse(firstChildLayoutOffset.toStringAsFixed(2));
  double lo = double.parse(layoutOffset.toStringAsFixed(2));

  // 2.22 => 002.22
  double gap = double.parse((lo - flo).toStringAsFixed(2));
  String gaps;
  if (gap > 999.99) {
    gaps = "99999";
  } else {
    gaps = gap.toString().replaceFirst('.', '').padLeft(5, '0');
  }

  return '$flo$gaps${firstChildIndex.toString().padLeft(7, '0')}77';
}

(double, int, double)? decodeRestorePosition(double offset) {
  final s = offset.toString();
  final len = s.length;

  final dot = s.indexOf('.');
  if (dot == len - 17) {
    if (s.endsWith("77")) {
      final flo = double.parse(offset.toStringAsFixed(2));
      final gap = double.parse(
          '${s.substring(dot + 3, dot + 8)}.${s.substring(dot + 8, dot + 10)}');
      final index = int.parse(s.substring(dot + 10, dot + 17));
      return (flo + gap, index, flo);
    }
  }
  return null;
}
