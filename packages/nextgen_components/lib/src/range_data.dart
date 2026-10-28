part of 'data.dart';

/// A zero-based range in a stable, filtered/sorted server result.
class NgDataRangeRequest {
  final int startIndex, count;
  final String search;
  final List<NgSortDescriptor> sorts;
  NgDataRangeRequest(
    this.startIndex,
    this.count,
    this.search,
    List<NgSortDescriptor> sorts,
  ) : sorts = List.unmodifiable(sorts);
}

class NgDataRangeResult<T> {
  final int startIndex, total;
  final List<T> items;
  NgDataRangeResult(this.startIndex, List<T> items, this.total)
    : items = List.unmodifiable(items);
}

abstract final class NgDataRange {
  static const maxCount = 512, maxTotal = 100000;
  static void validateRequest(NgDataRangeRequest request) {
    if (request.startIndex < 0 ||
        request.startIndex > maxTotal ||
        request.count < 1 ||
        request.count > maxCount) {
      throw ArgumentError('Invalid range request.');
    }
  }

  static List<T> validate<T>(
    NgDataRangeResult<T> result,
    NgDataRangeRequest request,
    String Function(T) rowId,
  ) {
    validateRequest(request);
    final expected = (result.total - request.startIndex).clamp(
      0,
      request.count,
    );
    if (result.startIndex != request.startIndex ||
        result.total < 0 ||
        result.total > maxTotal ||
        result.items.length != expected) {
      throw ArgumentError(
        'Range response must echo the offset and contain every requested record within the total.',
      );
    }
    final ids = result.items.map(rowId).toList();
    if (ids.any((id) => id.trim().isEmpty) ||
        ids.toSet().length != ids.length) {
      throw ArgumentError('Range row IDs must be nonempty and unique.');
    }
    return List.unmodifiable(result.items);
  }
}
