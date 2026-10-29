part of 'data.dart';

/// Offsets count visible slots: group headers plus records, after collapse.
class NgGroupedRangeRequest extends NgDataRangeRequest {
  final List<String> groupKeys, collapsedGroups;
  NgGroupedRangeRequest(
    super.startIndex,
    super.count,
    super.search,
    super.sorts,
    List<String> groupKeys,
    List<String> collapsedGroups,
  ) : groupKeys = List.unmodifiable(groupKeys),
      collapsedGroups = List.unmodifiable(collapsedGroups);
}

class NgGroupedRangeEntry<T> {
  final List<String> path;
  final bool isGroup;
  final T? item;
  NgGroupedRangeEntry(List<String> path, this.isGroup, this.item)
    : path = List.unmodifiable(path);
}

class NgGroupedRangeResult<T> {
  final int startIndex, total, recordTotal;
  final List<NgGroupedRangeEntry<T>> entries;
  final List<NgRemoteGroup> groups;
  NgGroupedRangeResult(
    this.startIndex,
    this.total,
    this.recordTotal,
    List<NgGroupedRangeEntry<T>> entries,
    List<NgRemoteGroup> groups,
  ) : entries = List.unmodifiable(entries),
      groups = List.unmodifiable(groups);
}

abstract final class NgGroupedRange {
  static void validateRequest(NgGroupedRangeRequest request) {
    NgDataRange.validateRequest(request);
    NgGroupedData.validateKeys(request.groupKeys);
    if (request.collapsedGroups.length > NgDataRange.maxTotal ||
        request.collapsedGroups.any((id) => id.trim().isEmpty) ||
        request.collapsedGroups.toSet().length !=
            request.collapsedGroups.length) {
      throw ArgumentError('Invalid collapsed group IDs.');
    }
  }

  static NgGroupedRangeResult<T> validate<T>(
    NgGroupedRangeResult<T> result,
    NgGroupedRangeRequest request,
    String Function(T) rowId,
  ) {
    validateRequest(request);
    if (result.startIndex != request.startIndex ||
        result.total < 0 ||
        result.total > NgDataRange.maxTotal ||
        result.recordTotal < 0 ||
        result.recordTotal > NgDataRange.maxTotal ||
        (result.recordTotal == 0) != (result.total == 0) ||
        result.entries.length !=
            (result.total - request.startIndex).clamp(0, request.count)) {
      throw ArgumentError('Invalid grouped range offset, count or totals.');
    }
    if (request.startIndex==0 && result.entries.isNotEmpty && (!result.entries.first.isGroup || result.entries.first.path.length!=1)) {
      throw ArgumentError('The first slot must be a root group header.');
    }
    final metadata = <String, NgRemoteGroup>{};
    for (final g in result.groups) {
      if (g.path.isEmpty ||
          g.path.length > request.groupKeys.length ||
          g.count < 1 ||
          g.count > result.recordTotal ||
          g.summaries.any(
            (s) =>
                s.title.trim().isEmpty || s.value != null && !s.value!.isFinite,
          ) ||
          g.summaries.map((s) => s.title).toSet().length !=
              g.summaries.length ||
          metadata.containsKey(ngGroupId(g.path))) {
        throw ArgumentError('Invalid or duplicate group metadata.');
      }
      metadata[ngGroupId(g.path)] = g;
    }
    final needed = <String>{},
        headers = <String>{},
        ids = <String>{},
        closed = <String>{};
    final members = <String, int>{};
    var previous = <String>[];
    final collapsed = request.collapsedGroups.toSet();
    final entries = <NgGroupedRangeEntry<T>>[];
    for (final e in result.entries) {
      if (e.path.isEmpty ||
          e.path.length > request.groupKeys.length ||
          !e.isGroup && e.path.length != request.groupKeys.length) {
        throw ArgumentError('Invalid entry path.');
      }
      final ancestors = [
        for (var n = 1; n <= e.path.length; n++) ngGroupId(e.path.take(n)),
      ];
      final id = ancestors.last;
      closed.addAll(previous.where((p) => !ancestors.contains(p)));
      if (ancestors.any(closed.contains))
        throw ArgumentError('Noncontiguous groups.');
      for (var depth = 0; depth < ancestors.length; depth++) {
        final key = ancestors[depth];
        needed.add(key);
        if (!metadata.containsKey(key) ||
            (depth < ancestors.length - 1 || !e.isGroup) &&
                collapsed.contains(key)) {
          throw ArgumentError(
            'Missing ancestor or entry below collapsed group.',
          );
        }
        if (entries.isNotEmpty &&
            !previous.contains(key) &&
            (!e.isGroup || depth != ancestors.length - 1)) {
          throw ArgumentError('Missing group header inside window.');
        }
        if (!e.isGroup) members[key] = (members[key] ?? 0) + 1;
      }
      if (e.isGroup) {
        if (!headers.add(id) || members.containsKey(id))
          throw ArgumentError('Duplicate or late header.');
      } else if (e.item == null ||
          rowId(e.item as T).trim().isEmpty ||
          !ids.add(rowId(e.item as T))) {
        throw ArgumentError('Invalid record identity.');
      }
      entries.add(e);
      previous = ancestors;
    }
    if (needed.length != metadata.length ||
        members.entries.any((e) => e.value > metadata[e.key]!.count)) {
      throw ArgumentError('Unexpected metadata or invalid group counts.');
    }
    final siblingCounts = <String, int>{};
    for (final g in metadata.values) {
      final parent = ngGroupId(g.path.take(g.path.length - 1));
      siblingCounts[parent] = (siblingCounts[parent] ?? 0) + g.count;
    }
    for (final e in siblingCounts.entries) {
      final maximum = e.key.isEmpty
          ? result.recordTotal
          : metadata[e.key]?.count;
      if (maximum == null || e.value > maximum)
        throw ArgumentError('Sibling counts exceed parent total.');
    }
    return NgGroupedRangeResult(
      result.startIndex,
      result.total,
      result.recordTotal,
      entries,
      metadata.values.toList(),
    );
  }

  /// Reference in-memory adapter; filter/sort the whole source first.
  static NgGroupedRangeResult<T> window<T>(
    List<T> filteredSorted,
    List<String Function(T)> selectors,
    List<NgGroupAggregate<T>> aggregates,
    NgGroupedRangeRequest request,
  ) {
    validateRequest(request);
    if (selectors.length != request.groupKeys.length ||
        filteredSorted.length > NgDataRange.maxTotal) {
      throw ArgumentError('Invalid grouped range source.');
    }
    final tree = ngGroupTree(filteredSorted, selectors);
    final slots = <NgGroupedRangeEntry<T>>[];
    final collapsed = request.collapsedGroups.toSet();
    void walk(List<NgGridGroup<T>> nodes) {
      for (final g in nodes) {
        slots.add(NgGroupedRangeEntry(g.path, true, null));
        if (collapsed.contains(g.id)) continue;
        if (g.children.isNotEmpty) {
          walk(g.children);
        } else {
          slots.addAll(
            g.items.map((r) => NgGroupedRangeEntry(g.path, false, r)),
          );
        }
      }
    }

    walk(tree);
    if (slots.length > NgDataRange.maxTotal)
      throw ArgumentError('Grouped range exceeds visible-slot limit.');
    final entries = slots.skip(request.startIndex).take(request.count).toList();
    final needed = <String>{
      for (final e in entries)
        for (var n = 1; n <= e.path.length; n++) ngGroupId(e.path.take(n)),
    };
    final groups = ngAllGroups(tree)
        .where((g) => needed.contains(g.id))
        .map(
          (g) => NgRemoteGroup(
            g.path,
            g.count,
            aggregates
                .map((a) => NgGroupSummary(a.title, a.calculate(g.items)))
                .toList(),
          ),
        )
        .toList();
    return NgGroupedRangeResult(
      request.startIndex,
      slots.length,
      filteredSorted.length,
      entries,
      groups,
    );
  }
}
