import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// default `ListView` will hang app on quick scroll
//
// https://github.com/flutter/flutter/issues/75399
class ListViewExt extends BoxScrollView {
  ListViewExt.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required NullableIndexedWidgetBuilder itemBuilder,
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
  })  : childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
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
  _CustomRenderSliverList({required super.childManager});

  double? collectFarAwayGarbage(double scrollStart, double scrollEnd) {
    if (firstChild == null) {
      return null;
    }
    // for our use case, each item size should not be vary too much
    firstChild!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    if (childCount != 1) {
      lastChild!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    }

    final height = (firstChild!.size.height + lastChild!.size.height) / 2;
    final min = scrollStart - (height * 61);
    final max = scrollEnd + (height * 61);

    int leading = 0;
    var child = firstChild;
    while (child != null) {
      final SliverMultiBoxAdaptorParentData p =
          child.parentData as SliverMultiBoxAdaptorParentData;
      if (p.layoutOffset != null && p.layoutOffset! < min) {
        leading += 1;
        child = childAfter(child);
      } else {
        break;
      }
    }

    int trailing = 0;
    child = lastChild;
    while (child != null) {
      final SliverMultiBoxAdaptorParentData p =
          child.parentData as SliverMultiBoxAdaptorParentData;
      if (p.layoutOffset != null && p.layoutOffset! > max) {
        trailing += 1;
        child = childBefore(child);
      } else {
        break;
      }
    }
    // print('### preCollectGarbage: $leading ~ $trailing');
    collectGarbage(leading, trailing);
    return height;
  }

  /// return false if can't create the first child
  bool ensureFirstChild(double offset, double? itemHeight) {
    if (firstChild != null) {
      return true;
    }
    // if we didn't known it's height, just guess one..
    //
    // how to support scroll to index?
    itemHeight = itemHeight ?? 36;
    int guessIndex = (offset / itemHeight).round();
    return addInitialChild(index: guessIndex, layoutOffset: offset);
  }

  /// referenced from
  ///
  /// [RenderSliverList.performLayout]
  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final SliverConstraints constraints = this.constraints;
    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    final double remainingExtent = constraints.remainingCacheExtent;
    final double targetEndScrollOffset = scrollOffset + remainingExtent;
    // print("### scrollOffset: $scrollOffset ~ $targetEndScrollOffset");

    // clear the widiget that is far away from our current scroll range,
    // then we know `firstChild` is not far away layout range if it is exists
    final itemHeight =
        collectFarAwayGarbage(scrollOffset, targetEndScrollOffset);

    // create first child (if not exists) at target scroll offset
    if (!ensureFirstChild(scrollOffset, itemHeight)) {
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }

    // The following are extactly same with ListView :)
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
      while (indexOf(firstChild!) > 0) {
        final double earliestScrollOffset = childScrollOffset(firstChild!)!;
        earliestUsefulChild =
            insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
        assert(earliestUsefulChild != null);
        final double firstChildScrollOffset =
            earliestScrollOffset - paintExtentOf(firstChild!);
        final SliverMultiBoxAdaptorParentData childParentData =
            firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
        childParentData.layoutOffset = 0.0;
        if (firstChildScrollOffset < -precisionErrorTolerance) {
          geometry = SliverGeometry(
            scrollOffsetCorrection: -firstChildScrollOffset,
          );
          return;
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
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild!),
        lastIndex: indexOf(lastChild!),
        leadingScrollOffset: childScrollOffset(firstChild!),
        trailingScrollOffset: endScrollOffset,
      );
      assert(estimatedMaxScrollOffset >=
          endScrollOffset - childScrollOffset(firstChild!)!);
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
  }
}
