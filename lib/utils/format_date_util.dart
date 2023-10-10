//수정할 거 없음. 검토 완료.

//2023-01-01 00:00:00 형식으로 포맷하는 함수.
String formatDate(String inputDate) {
  DateTime parsedDate = DateTime.parse(inputDate);
  return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}:${parsedDate.second.toString().padLeft(2, '0')}";
}