class Pagination {
  final String afterDate;

  // final String beforeDate;
  final int limit;
  final String next;
  final int offset;
  final String previous;
  final String sort;

  Pagination({
    required this.afterDate,
    // required this.beforeDate,
    required this.limit,
    required this.next,
    required this.offset,
    required this.previous,
    required this.sort,
  });

  Map<String, dynamic> toJson() {
    return {
      'afterDate': afterDate,
      // 'beforeDate': beforeDate,
      'limit': limit,
      'next': next,
      'offset': offset,
      'previous': previous,
      'sort': sort,
    };
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      afterDate: json['afterDate'],
      // beforeDate: json['beforeDate'],
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      sort: json['sort'],
    );
  }

  @override
  String toString() {
    return 'Pagination(afterDate: $afterDate, '
        // 'beforeDate: $beforeDate, '
        'limit: $limit, next: $next, offset: $offset, previous: $previous, sort: $sort)';
  }
}
