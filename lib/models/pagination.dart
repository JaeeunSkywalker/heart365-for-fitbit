class Pagination {
  //이 날 이후의 데이터를 불러 온다.
  // final String afterDate;
  //이 날 전의 데이터를 불러 온다.
  final String beforeDate;
  //최대 10개, 요청 가능한 데이터 수.
  //한 번에 불러 올 수 있는 데이터의 양이 최대 10개라서,
  //그 이상의 데이터를 불러 오고 싶다면.
  //여러 번의 요청을 통해 데이터를 페이지네이션 방식으로 나누어 가져 와야 한다.
  final int limit;

  //다음 결과 페이지를 가져 오기 위한 요청의 URL.
  //예를 들어, 서버에 데이터가 50개 있으면,
  //총 5번 요청을 해야 한다.
  //첫 번째 요청 시에는 1-10번 데이터를 가져 오고,
  //이 URL을 사용해서 두 번째 요청을 하면 11-20번 아이템을 가져 오는 식이다.
  final String next;

  //offset은 데이터베이스 쿼리에서 특정 수의 레코드를 건너뛸 때 사용하는 매개변수다.
  //보통 페이지네이션에서 limit과 함께 사용된다.
  //DB에 100개의 레코드가 있고, 한 페이지에 10개의 레코드만 표시하려 하면 limit을 10으로 설정하면 된다.
  //이때, 첫 페이지를 보려면 offset을 0으로 설정하고, 두 번째 페이지를 보려면 offset을 10으로 설정한다.
  //i.e. limit = 10, offset = 0(1-10번 레코드).
  //offset은 몇 번째 레코드부터 시작할 것인가를 지정하는 인덱스와 유사하다.
  final int offset;

  //이전 결과 페이지를 가져 오기 위한 요청의 URL.
  final String previous;

  //ase or desc, afterDate 썼으면 ase, beforeDate 썼으면 desc.
  final String sort;

  Pagination({
    // required this.afterDate,
    required this.beforeDate,
    required this.limit,
    required this.next,
    required this.offset,
    required this.previous,
    required this.sort,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'afterDate': afterDate,
      'beforeDate': beforeDate,
      'limit': limit,
      'next': next,
      'offset': offset,
      'previous': previous,
      'sort': sort,
    };
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      // afterDate: json['afterDate'],
      beforeDate: json['beforeDate'],
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      sort: json['sort'],
    );
  }

  @override
  String toString() {
    return 'Pagination('
        // 'afterDate: $afterDate, '
        'beforeDate: $beforeDate, '
        'limit: $limit, next: $next, offset: $offset, previous: $previous, sort: $sort)';
  }
}
