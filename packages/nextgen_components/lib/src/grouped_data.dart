part of 'data.dart';

class NgGroupedDataRequest extends NgDataRequest {
  final List<String> groupKeys;
  NgGroupedDataRequest(
    super.page,
    super.pageSize,
    super.search,
    super.sorts,
    List<String> groupKeys,
  ) : groupKeys = List.unmodifiable(groupKeys);
  Map<String, Object?> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'search': search,
    'sorts': [
      for (final s in sorts) {'key': s.key, 'descending': s.descending},
    ],
    'groupKeys': groupKeys,
  };
}

class NgGroupSummary {
  final String title;
  final double? value;
  const NgGroupSummary(this.title, this.value);
}

class NgRemoteGroup {
  final List<String> path;
  final int count;
  final List<NgGroupSummary> summaries;
  NgRemoteGroup(List<String> path, this.count, List<NgGroupSummary> summaries)
    : path = List.unmodifiable(path),
      summaries = List.unmodifiable(summaries);
}

class NgGroupedItem<T> {
  final T item;
  final List<String> path;
  NgGroupedItem(this.item, List<String> path) : path = List.unmodifiable(path);
}

class NgGroupedDataResult<T> {
  final List<NgGroupedItem<T>> items;
  final int total;
  final List<NgRemoteGroup> groups;
  NgGroupedDataResult(
    List<NgGroupedItem<T>> items,
    this.total,
    List<NgRemoteGroup> groups,
  ) : items = List.unmodifiable(items),
      groups = List.unmodifiable(groups);
  factory NgGroupedDataResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) decode,
  ) => NgGroupedDataResult(
    [
      for (final row in json['items'] as List)
        NgGroupedItem(
          decode(Map<String, dynamic>.from(row['item'] as Map)),
          List<String>.from(row['path'] as List),
        ),
    ],
    json['total'] as int,
    [
      for (final group in json['groups'] as List)
        NgRemoteGroup(
          List<String>.from(group['path'] as List),
          group['count'] as int,
          [
            for (final summary in group['summaries'] as List)
              NgGroupSummary(
                summary['title'] as String,
                (summary['value'] as num?)?.toDouble(),
              ),
          ],
        ),
    ],
  );
}

class NgGroupedData {
  static void validateKeys(List<String> keys) {
    if (keys.isEmpty ||
        keys.length > 8 ||
        keys.any((k) => k.trim().isEmpty) ||
        keys.toSet().length != keys.length)
      throw ArgumentError('Provide one to eight distinct nonblank group keys.');
  }

  static List<NgGridGroup<T>> validate<T>(
    NgGroupedDataResult<T> result,
    NgGroupedDataRequest request,
    String Function(T) rowId,
  ) {
    validateKeys(request.groupKeys);
    final remaining = result.total - (request.page - 1) * request.pageSize;
    final expected = remaining < 0
        ? 0
        : remaining > request.pageSize
        ? request.pageSize
        : remaining;
    if (request.page < 1 ||
        request.pageSize < 1 ||
        result.total < 0 ||
        result.items.length != expected)
      throw ArgumentError('Invalid grouped page size or total.');
    final ids = <String>{},
        paths = <String, List<String>>{},
        members = <String, List<T>>{},
        children = <String, List<String>>{'': []};
    final previous = List<String?>.filled(request.groupKeys.length, null);
    final visited = List.generate(request.groupKeys.length, (_) => <String>{});
    for (final row in result.items) {
      final id = rowId(row.item);
      if (id.trim().isEmpty ||
          !ids.add(id) ||
          row.path.length != request.groupKeys.length)
        throw ArgumentError('Invalid grouped row identity or path.');
      for (var depth = 1; depth <= row.path.length; depth++) {
        final path = row.path.take(depth).toList(),
            key = ngGroupId(row.path.take(depth));
        if (previous[depth - 1] != key && !visited[depth - 1].add(key))
          throw ArgumentError('Group records must be contiguous.');
        previous[depth - 1] = key;
        if (!members.containsKey(key)) {
          members[key] = [];
          paths[key] = path;
          children[key] = [];
          children[ngGroupId(path.take(depth - 1))]!.add(key);
        }
        members[key]!.add(row.item);
      }
    }
    final metadata = <String, NgRemoteGroup>{};
    for (final group in result.groups) {
      if (group.path.isEmpty || group.path.length > request.groupKeys.length)
        throw ArgumentError('Invalid metadata path.');
      final id = ngGroupId(group.path), rows = members[ngGroupId(group.path)];
      if (rows == null ||
          metadata.containsKey(id) ||
          group.count < rows.length ||
          group.count > result.total)
        throw ArgumentError('Inconsistent group count or duplicate metadata.');
      if (group.summaries.any(
            (s) =>
                s.title.trim().isEmpty || s.value != null && !s.value!.isFinite,
          ) ||
          group.summaries.map((s) => s.title).toSet().length !=
              group.summaries.length)
        throw ArgumentError('Invalid group summaries.');
      metadata[id] = group;
    }
    if (metadata.length != members.length)
      throw ArgumentError('Missing group metadata.');
    for (final entry in children.entries) {
      final maximum = entry.key.isEmpty
          ? result.total
          : metadata[entry.key]!.count;
      if (entry.value.fold<int>(0, (sum, id) => sum + metadata[id]!.count) >
          maximum)
        throw ArgumentError('Sibling counts exceed parent total.');
    }
    NgGridGroup<T> build(String id) => NgGridGroup(
      paths[id]!,
      members[id]!,
      children[id]!.map(build).toList(),
      total: metadata[id]!.count,
      summaries: metadata[id]!.summaries,
    );
    return List.unmodifiable(children['']!.map(build));
  }

  /// Reference adapter over the complete filtered/sorted data, before paging.
  static NgGroupedDataResult<T> page<T>(
    List<T> filteredSorted,
    List<String Function(T)> selectors,
    List<NgGroupAggregate<T>> aggregates,
    int page,
    int size,
  ) {
    if (selectors.isEmpty || selectors.length > 8 || page < 1 || size < 1)
      throw ArgumentError('Invalid grouped page request.');
    final tree = ngGroupTree(filteredSorted, selectors);
    final flat = ngAllGroups(tree)
        .where((g) => g.children.isEmpty)
        .expand((g) => g.items.map((r) => NgGroupedItem(r, g.path)))
        .toList();
    final rows = flat.skip((page - 1) * size).take(size).toList();
    final needed = <String>{
      for (final row in rows)
        for (var n = 1; n <= row.path.length; n++) ngGroupId(row.path.take(n)),
    };
    final metadata = ngAllGroups(tree)
        .where((g) => needed.contains(g.id))
        .map(
          (g) => NgRemoteGroup(
            g.path,
            g.items.length,
            aggregates
                .map((a) => NgGroupSummary(a.title, a.calculate(g.items)))
                .toList(),
          ),
        )
        .toList();
    return NgGroupedDataResult(rows, filteredSorted.length, metadata);
  }
}
